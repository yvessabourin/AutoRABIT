global class DailySaleTriggerHelper implements Queueable, Database.AllowsCallouts{
    
    private static final string shareReason = Schema.Daily_Sale__Share.RowCause.Status_managed_changes__c;
    
    public set<Id> dsIdList = new set<Id>();
    
    public DailySaleTriggerHelper(set<Id> DailySalesListIds){
        
        this.dsIdList = DailySalesListIds;
    }
    
    // Triggered from Daily Sale record upsert 
    public void execute(QueueableContext context) {
        
        getLeaseIds(dsIdList);
        
    }  
    
    // Triggered from User record upsert
    // has to be a future method to avoid mixed DML type errors
    @future
    public static void ProcessShares(set<Id> vpcrIdList){
        
        // list<Village_Presence_Contact_Role__c> vpcrList = [select Id, Village_Presence__c from Village_Presence_Contact_Role__c where Id in :vpcrIdList];
        
        list<Village_Presence_Contact_Role__c> vpcrList = [select Id, Contact__c, Contact__r.AccountId, 
                                                           Village_Presence__r.Brand__c, Village_Presence__c 
                                                           from Village_Presence_Contact_Role__c
                                                           where id in :vpcrIdList];
        
        list<string> vpList = new list<string>();
        if (!vpcrList.isEmpty()){
            for (Village_Presence_Contact_Role__c vpcr :vpcrList){
                vpList.add(vpcr.Village_Presence__c);
            }    
        }
        
        map<Id, Daily_Sale__c> dsList = new map<Id, Daily_Sale__c>([select Id, Name, Store__c, Status__c, Trading_Date__c
                                                                    from Daily_Sale__c 
                                                                    where Store__c in :vpList]);
        
        if (!dsList.isEmpty()){
            ProcessShares(dsList.Values(), dsList.keySet());
        }
        
        // Share account record if associated with more than one village presence
        map<Id, Id> accountShareMap = new map<Id, Id>();        
        
        for (Village_Presence_Contact_Role__c vpcr :vpcrList){
            if (vpcr.Contact__r.AccountId != vpcr.Village_Presence__r.Brand__c){ // Contact Account different from VPCR Brand
                accountShareMap.put(vpcr.Village_Presence__r.Brand__c, vpcr.Contact__c);
            }
            
        }
        if (!accountShareMap.isEmpty()){
            processAccountShares(accountShareMap);
        }
        
    }
    
    // Triggered from Village presence contact role record upsert 
    public static void ProcessShares(list<Village_Presence_Contact_Role__c> vpcrList){
        
        set<Id> vpList = new set<Id>();
        set<Id> vpcrIds = (new Map<Id, Village_Presence_Contact_Role__c>(vpcrList)).keySet();
        map<Id, Id> accountShareMap = new map<Id, Id>();
        
        vpcrList = [select Id, Contact__c, Contact__r.AccountId, Village_Presence__r.Brand__c, Village_Presence__c 
                    from Village_Presence_Contact_Role__c
                    where id in :vpcrIds all rows];
        
        for (Village_Presence_Contact_Role__c vpcr :vpcrList){
            vpList.add(vpcr.Village_Presence__c);
            if (vpcr.Contact__r.AccountId != vpcr.Village_Presence__r.Brand__c){
                accountShareMap.put(vpcr.Village_Presence__r.Brand__c, vpcr.Contact__c);
            }
            
        }
        
        map<Id, Daily_Sale__c> dsList = new map<Id, Daily_Sale__c>([select Id, Name, Store__c, Status__c, Trading_Date__c
                                                                    from Daily_Sale__c 
                                                                    where Store__c in :vpList AND Trading_Date__c = LAST_N_DAYS:95]);
        
        System.debug('result'+dsList);
        
        if (!dsList.isEmpty()){
            ProcessShares(dsList.Values(), dsList.keySet());
        }
        if (!accountShareMap.isEmpty()){
            processAccountShares(accountShareMap);
        }
    }
    
    // Triggered from Daily Sale record upsert     
    public static void ProcessShares(list<Daily_Sale__c> DailySalesList, set<Id> DailySalesListIds) {
        
        // system.debug('@@@@ DailySalesListIds ' + DailySalesListIds);
        // system.debug('@@@@ DailySalesList ' + DailySalesList);
        
        Map<string, string> statusMapFields = new Map<string, string>();                
        set<string> vpIdSet = new set<string>() ;
        Map<Id, Village_Presence_Contact_Role__c> contactMap = new Map<Id, Village_Presence_Contact_Role__c>();
        Map<Id, User> contactUserMap = new Map<Id, User>();
        list<Daily_Sale__Share> dsShareListDelete = new list<Daily_Sale__Share>();
        list<Daily_Sale__Share> dsShareListInsert = new list<Daily_Sale__Share>();
        
        // Retrieve status Map custom setting records and fields
        // Using query rather than custom setting methods allows code to be more generic - not hard coding specific status values
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType csSchema = schemaMap.get('Daily_Sales_Status_Map__c');
        Map<String, Schema.SObjectField> csFieldMap = csSchema.getDescribe().fields.getMap();
        string csQuery = 'select ';
        for (String fieldName: csfieldMap.keySet()) {
            csQuery += fieldName + ',';
            csfieldMap.get(fieldName).getDescribe().getLabel();//get the object field label.
        }
        csQuery = csQuery.substring(0, csQuery.length() - 1);
        csQuery  =csQuery + ' from Daily_Sales_Status_Map__c';
        list<Sobject> csDataList = Database.query(csQuery);
        
        for(Daily_Sale__c ds: DailySalesList)
        {
            vpIdSet.add(ds.Store__c);
        }
        
        // system.debug('@@@@ vpIdSet ' + vpIdSet);
        
        Map<Id, Village_Presence__c> vpcontactRoleList = new Map<Id, Village_Presence__c>([select Id, Name, (SELECT id, Village_presence__c, Contact__c,
                                                                                                             Daily_Sales_Active_From__c, Daily_Sales_Active_To__c,
                                                                                                             Confirm_Daily_Sales_Records__c, Certification_Active__c
                                                                                                             from Village_Presence_Contact_roles__r
                                                                                                             where (Daily_Sales_Active_From__c != null OR Certification_Active__c = true))
                                                                                           From Village_Presence__c
                                                                                           where Id in :vpIdSet]);

        for (Village_Presence__c vp : vpcontactRoleList.values()){
            list<Village_Presence_Contact_Role__c> contactRolesList = vp.Village_Presence_Contact_roles__r;
            if (!contactRolesList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :contactRolesList){
                    contactMap.put(vpcr.Contact__c, vpcr);
                }    
            }    
        }
        system.debug('@@@ contactMap .. ' + contactMap);
        contactUserMap = new Map<Id, User>([select Id, Name, ProfileId, ContactId, IsActive from User where ContactId in :contactMap.keySet()]);  
        Map<Id, User> contactUserMap2 = new Map<Id, User>();
        for (User u :contactUserMap.values()){
            contactUserMap2.put(u.ContactId, u);
        }
        system.debug('@@@ contactUserMap .. ' + contactUserMap);
        system.debug('@@@ contactUserMap2 .. ' + contactUserMap2);
        for (Daily_Sale__c ds :DailySalesList){
            system.debug('@@@ Daily_Sale__c ds .. ' + ds);
            string dsStatus = ds.Status__c;
            date dsTransactionDate = ds.Trading_Date__c;
            
            list<Village_Presence_Contact_Role__c> contactRolesList = vpcontactRoleList.get(ds.Store__c).Village_Presence_Contact_roles__r;
            if (!contactRolesList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :contactRolesList){
                    Date startDt = vpcr.Daily_Sales_Active_From__c;
                    Date endDt = vpcr.Daily_Sales_Active_To__c;
                    Boolean certActive = vpcr.Certification_Active__c;
                    User u = contactUserMap2.get(vpcr.Contact__c);
                    boolean profileStatusSetting = false;
                    system.debug('@@@ User .. ' + u + ' - ' + vpcr.Contact__c);
                    if (u != null && (startDt != null || certActive == true) && u.IsActive) {//contact is an active partner user and has a Daily Sales start date
                        string orgId = system.userInfo.getOrganizationId();
                        if ((startDt <= dsTransactionDate && (endDt == null || endDt >= system.today())) || (startDt == null && certActive == true)){
                        // only consider contacts with valid Daily Sales start and end dates (LIS DEV Team added:) OR Daily Sales start date null but certification active true 

                            Daily_Sales_Status_Map__c statusMap = null;
                            try {
                                statusMap =  Daily_Sales_Status_Map__c.getInstance(u.ProfileId);
                                string recId = statusMap.Id;
                                if (string.isBlank(recId)){ //No custom setting for this user profile
                                    profileStatusSetting = false;
                                    statusMap = null;
                                } else {                              
                                    profileStatusSetting = true;
                                }    
                            } catch (exception e){
                                
                                statusMap = null;
                                profileStatusSetting = false;
                            }
                            if (statusMap == null){ // use the org settings
                                statusMap =  Daily_Sales_Status_Map__c.getOrgDefaults();
                            }
                            Daily_Sale__Share dsShare = new Daily_Sale__Share();
                            dsShare.ParentId = ds.Id;
                            dsShare.RowCause = shareReason;
                            dsShare.UserOrGroupId = u.Id;
                            
                            string statusMapAccess = '';
                            system.debug(' @@@@@ profileStatusSetting  ' + profileStatusSetting);
                            system.debug(' @@@@@ csDataList  ' + csDataList);
                            // compare daily sales status with custom setting to determine access level
                            for (Sobject cs :csDataList){
                                string csOwner = string.valueOf(cs.get('SetupOwnerId'));
                                boolean matchedSetting = false;
                                if (profileStatusSetting){
                                    if (csOwner == u.ProfileId){
                                        matchedSetting = true;
                                    }
                                } else if (csOwner == orgId) {
                                    matchedSetting = true;
                                }
                                if (matchedSetting) { //found correct custom setting record for user
                                    for (String fieldName: csfieldMap.keySet()) { // find matching custom setting field for equivalent Daily Sale record status
                                        string fldLabel = csfieldMap.get(fieldName).getDescribe().getLabel();//get the object fields label.
                                        if (dsStatus == fldLabel){ // Daily Sale status matches custom setting field label
                                            statusMapAccess = string.valueOf(cs.get(fieldName)); // return access level for the status
                                        }
                                    }
                                    system.debug(' @@@@@ statusMapAccess  ' + statusMapAccess +  ' - ' + dsStatus);                                      
                                    break;
                                }
                            }
                            
                            if (statusMapAccess != 'Hidden'){ // Only create a share record if access should not be hidden ??
                                if (string.isBlank(statusMapAccess)){ // default access status if no matching custom setting ?? .. or.. no sharing rule ??
                                    statusMapAccess = 'Read';
                                }
                                dsShare.AccessLevel = statusMapAccess;
                                dsShareListInsert.add(dsShare);
                            }
                        }
                    }
                }    
            }
            
        }
        
        // Perform DML transactions on share object
        Savepoint sp = Database.setSavepoint();
        try {
            dsShareListDelete = [select Id from Daily_Sale__share where ParentId in :DailySalesListIds and RowCause =:shareReason];
            
            if (!dsShareListDelete.isEmpty() ){
                Database.delete(dsShareListDelete);
                
            }
            system.debug(' @@@@@ dsShareListInsert  ' + dsShareListInsert);             
            if (!dsShareListInsert.isEmpty()){
                Database.insert(dsShareListInsert);
            }
            
            
        } catch (exception e){
            
            Database.rollback(sp);
            system.debug('ERROR ...Applying Status Sharing Rules...  ' + e.getMessage() + ' : ' + e.getStackTraceString());
        }
        
    }
    
    //  invoked by Async queueable call     
    public static void getLeaseIds(set<Id> dsIdList2) {
        system.debug(' @@@@  dsIdList2    ' + dsIdList2 + '  SIZE ... ' + dsIdList2.size());        
        if (!dsIdList2.isEmpty()) {
            
            list<Daily_Sale__c> dsList = [select Lease_Id__c, Integration_Message__c, store__r.Brand__c, 
                                          store__r.unit__r.MRI_Unit_Id__c, store__r.unit__r.Phase_ID__c, store__r.unit__r.Suite_ID__c, 
                                          Store__r.Village__r.Village_Code__c, MRI_Phase_Id__c, MRI_Suite_Id__c, Store__r.Lease_ID__c,Store__c 
                                          from Daily_Sale__c where Id in :dsIdList2 ];
            
            map<ID,String> VPMap = new map<ID,String>();                 
                    
            for(Daily_Sale__c ds :dsList) {
                string unitId = '';
                string phaseId = '';
                string suiteId = '';
                if (ds.store__r.Unit__r != null){
                    unitId = ds.store__r.Unit__r.MRI_Unit_Id__c;
                    phaseId = ds.store__r.Unit__r.Phase_Id__c;
                    suiteId = ds.store__r.Unit__r.Suite_Id__c;
                }
                string brandId = ds.store__r.Brand__c;
                if (test.isRunningTest())
                    brandId = 'SF_TEST';
                string villageCode = ds.Store__r.Village__r.Village_Code__c;
                string leaseId = getLeaseId(brandId, villageCode, phaseId, suiteId);
                if (leaseId.contains('ERROR') || string.isBlank(leaseId)){
                    //handle error where no lease id found
                    //ds.Integration_Message__c = leaseId;
                    //ds.lease_Id__c = '';
                    
                    if(leaseId.contains('HTTP Status Code 4')){ 
                        
                        if(leaseId.contains('HTTP Status Code 404')){
                            ds.Integration_Message__c = 'ERROR - No Lease found for Brand Id ' + brandId;
                    		ds.lease_Id__c = '';
                        }  
                        
                        else {
                            ds.Integration_Message__c = 'ERROR returned from read lease api call - ' + leaseId;
                    		ds.lease_Id__c = '';                          
                        }
                    }
                    else {
                        ds.Integration_Message__c = 'ERROR returned from read lease api call - ' + leaseId;
                    	ds.lease_Id__c = '';                        
                    }
                    
                } 
                else {
                    list<string> leaseDetails = leaseId.split(',');
                    ds.Lease_ID__c = leaseDetails[0];
                    ds.MRI_Phase_Id__c = leaseDetails[1];
                    ds.MRI_Suite_Id__c = leaseDetails[2];
                    ds.Integration_Message__c = '';
                    VPMap.put(ds.Store__c,ds.Lease_ID__c);
                }    
            }
                        
            list<Village_Presence__c> VPsUpdate = [SELECT id, Lease_ID__c FROM Village_Presence__c WHERE ID IN:VPMap.Keyset() ];
            
            for(Village_Presence__c VP : VPsUpdate ){
                VP.Lease_ID__c = VPMap.get(VP.ID);
            }
            
            update VPsUpdate;           
            update dsList;
        }
        
    }
    
    private static string getLeaseId(string brandId, string villageCode, string phaseId, string suiteId){
        // make api call to retrieve lease id        
        string returnValue = '';
        string xmlLease = apiService.readLeaseList(brandId, villageCode, system.today());
        //string xmlLease = apiService.readLeaseList(' SF_HBOSB', 'WV', system.today() );
        system.debug('@@@ xmlLease .. ' + xmlLease);
        if (xmlLease.indexOf('ERROR') > -1){
            // ERROR returned from read lease api call ??
            returnValue = xmlLease; 
            system.debug('ERROR returned from read lease api call  .. ' + xmlLease);
        } else {
            list<apiLease.cls_LeaseItem> leaseList = apiLease.parseXML(xmlLease);
            system.debug('@@@ leaseList .. ' + leaseList);        
            if (!leaseList.isEmpty()){
                //Loop through returned list and return lease id which matches unit
                string leaseUnit = '';
                string leaseUnitsAll = '';
                string leasePhase = '';
                string leaseSuite = '';
                boolean matchedUnit = false;
                for (apiLease.cls_LeaseItem lease :leaseList){                    
                    leaseUnit = lease.PhaseId + lease.UnitId;
                    leaseUnitsAll += leaseUnit + ' ';
                    leasePhase = lease.PhaseId;
                    leaseSuite = lease.UnitId;
                    string leaseId = lease.leaseId;
                    //?? compare matching field(s) on Salesforce record
                    if (phaseId == leasePhase && suiteId == leaseSuite){ 
                        returnValue = leaseId + ',' + leasePhase + ',' + leaseSuite;
                        matchedUnit = true;
                        break;
                    }   
                }
                if (!matchedUnit){
                    returnValue = 'ERROR - No Lease found which matches Village Presence unit (' + phaseId + suiteId + ')';
                    returnValue += '\r\n MRI Unit(s) returned - ' + leaseUnitsAll;
                }
            } else {
                returnValue = 'ERROR - No Lease found for Brand Id ' + brandId;
                returnValue += '\r\n no items returned'; 
            }       
        }
        return returnValue;
        
    }
    
    private static void processAccountShares(map<Id, Id> accountShareMap){
        
        list<AccountShare> accountShares = new list<AccountShare>();
        map<Id, User> contactUserMap = new map<Id, User>([select Id, Name, ProfileId, ContactId, IsActive from User where ContactId in :accountShareMap.values()]);  
        map<Id, User> contactUserMap2 = new map<Id, User>();
        for (User u :contactUserMap.values()){
            contactUserMap2.put(u.ContactId, u);
        }       
        for (Id key :accountShareMap.keySet()){
            string contactId = accountShareMap.get(key);
            User usr = contactUserMap2.get(contactId);
            if (usr != null){
                string userId = usr.Id;
                AccountShare accShare = new AccountShare( AccountId = key,
                                                         UserOrGroupId = userId,
                                                         AccountAccessLevel = 'Read',
                                                         OpportunityAccessLevel = 'Read'
                                                        );
                accountShares.add(accShare);
            }
        }   
        
        system.debug('@@@@ Account Shares ... ' + accountShares);
        
        if (!accountShares.isEmpty()){
            insert accountShares;
        }
    }
}