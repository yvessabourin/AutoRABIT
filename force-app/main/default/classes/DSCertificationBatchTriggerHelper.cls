global class DSCertificationBatchTriggerHelper implements Queueable, Database.AllowsCallouts{

    private static final String shareReason = Schema.Daily_Sales_Certification_Batch__Share.RowCause.Status_managed_changes__c;
    
    public Set<Id> dscbSet = new Set<Id>();
    
    public DSCertificationBatchTriggerHelper(Set<Id> DSCertificationListIds){
        
        this.dscbSet = DSCertificationListIds;
    }

    public void execute(QueueableContext context) {

    }

    // Triggered from User record upsert
    // has to be a future method to avoid mixed DML type errors
    @future
    public static void ProcessShares(set<Id> vpcrIdList){
        
        list<Village_Presence_Contact_Role__c> vpcrList = [SELECT Id, Contact__c, Contact__r.AccountId, 
                                                           Village_Presence__r.Brand__c, Village_Presence__c 
                                                           FROM Village_Presence_Contact_Role__c
                                                           WHERE id IN :vpcrIdList];
        
        list<string> vpList = new list<string>();
        if (!vpcrList.isEmpty()){
            for (Village_Presence_Contact_Role__c vpcr :vpcrList){
                vpList.add(vpcr.Village_Presence__c);
            }    
        }
        
        Map<Id, Daily_Sales_Certification_Batch__c> dscbList = new Map<Id, Daily_Sales_Certification_Batch__c>([SELECT Id, Name, Village_Presence__c
                                                                                                                FROM Daily_Sales_Certification_Batch__c 
                                                                                                                WHERE Village_Presence__c IN :vpList]);
        
        if (!dscbList.isEmpty()){
            ProcessShares(dscbList.Values(), dscbList.keySet());
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
    public static void ProcessShares(List<Village_Presence_Contact_Role__c> vpcrList){

        Set<Id> vpList = new Set<Id>();
        Set<Id> vpcrIds = (new Map<Id, Village_Presence_Contact_Role__c>(vpcrList)).keySet();
        
        vpcrList = [SELECT Id, Contact__c, Contact__r.AccountId, Village_Presence__r.Brand__c, Village_Presence__c 
                    FROM Village_Presence_Contact_Role__c
                    WHERE id IN :vpcrIds ALL ROWS];
        
        for (Village_Presence_Contact_Role__c vpcr :vpcrList){
            vpList.add(vpcr.Village_Presence__c);            
        }
        
        Map<Id, Daily_Sales_Certification_Batch__c> dscbList = new Map<Id, Daily_Sales_Certification_Batch__c>([SELECT Id, Name, Village_Presence__c
                                                                                                                FROM Daily_Sales_Certification_Batch__c 
                                                                                                                WHERE Village_Presence__c IN :vpList]);
        
        if (!dscbList.isEmpty()){
            ProcessShares(dscbList.Values(), dscbList.keySet());
        }
    }
  
    // Triggered from Daily Sale record upsert     
    public static void ProcessShares(List<Daily_Sales_Certification_Batch__c> DDCBList, Set<Id> DailySalesListIds) {
              
        set<string> vpIdSet = new set<string>() ;
        Map<Id, Village_Presence_Contact_Role__c> contactMap = new Map<Id, Village_Presence_Contact_Role__c>();
        Map<Id, User> contactUserMap = new Map<Id, User>();
        List<Daily_Sales_Certification_Batch__Share> dscbShareListDelete = new List<Daily_Sales_Certification_Batch__Share>();
        List<Daily_Sales_Certification_Batch__Share> dscbShareListInsert = new List<Daily_Sales_Certification_Batch__Share>();
               
        for(Daily_Sales_Certification_Batch__c dscb : DDCBList){
            vpIdSet.add(dscb.Village_Presence__c);
        }
        
        // system.debug('@@@@ vpIdSet ' + vpIdSet);
        
        Map<Id, Village_Presence__c> vpcontactRoleList = new Map<Id, Village_Presence__c>([SELECT Id, Name, (SELECT id, Village_presence__c, Contact__c,
                                                                                                             Daily_Sales_Active_From__c, Daily_Sales_Active_To__c,
                                                                                                             Confirm_Daily_Sales_Records__c, Certification_Active__c
                                                                                                             FROM Village_Presence_Contact_roles__r
                                                                                                             WHERE Certification_Active__c = true)
                                                                                           FROM Village_Presence__c
                                                                                           WHERE Id IN :vpIdSet]);

        for (Village_Presence__c vp : vpcontactRoleList.values()){
            List<Village_Presence_Contact_Role__c> contactRolesList = vp.Village_Presence_Contact_roles__r;
            if (!contactRolesList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :contactRolesList){
                    contactMap.put(vpcr.Contact__c, vpcr);
                }    
            }    
        }
        system.debug('@@@ contactMap .. ' + contactMap);
        contactUserMap = new Map<Id, User>([SELECT Id, Name, ProfileId, ContactId, IsActive FROM User WHERE ContactId IN :contactMap.keySet()]);  
        Map<Id, User> contactUserMap2 = new Map<Id, User>();
        for (User u :contactUserMap.values()){
            contactUserMap2.put(u.ContactId, u);
        }
        system.debug('@@@ contactUserMap .. ' + contactUserMap);
        system.debug('@@@ contactUserMap2 .. ' + contactUserMap2);

        for (Daily_Sales_Certification_Batch__c dscb : DDCBList){
            system.debug('@@@ Daily_Sales_Certification_Batch__c dscb .. ' + dscb);
            
            List<Village_Presence_Contact_Role__c> contactRolesList = vpcontactRoleList.get(dscb.Village_Presence__c).Village_Presence_Contact_roles__r;
            if (!contactRolesList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :contactRolesList){
                    Boolean certActive = vpcr.Certification_Active__c;
                    User u = contactUserMap2.get(vpcr.Contact__c);
                    system.debug('@@@ User .. ' + u + ' - ' + vpcr.Contact__c);
                    if (u != null && certActive == true && u.IsActive) {//contact is an active partner user and has a Daily Sales start date
                        Daily_Sales_Certification_Batch__Share dsShare = new Daily_Sales_Certification_Batch__Share();
                        dsShare.ParentId = dscb.Id;
                        dsShare.RowCause = shareReason;
                        dsShare.UserOrGroupId = u.Id;
                        dsShare.AccessLevel = 'Edit';
						dscbShareListInsert.add(dsShare);
                    }
                }
            }    
        }
        
        // Perform DML transactions on share object
        Savepoint sp = Database.setSavepoint();
        try {
            dscbShareListDelete = [SELECT Id FROM Daily_Sales_Certification_Batch__Share WHERE ParentId IN :DailySalesListIds AND RowCause =:shareReason];
            
            if (!dscbShareListDelete.isEmpty() ){
                Database.delete(dscbShareListDelete);
                
            }
            system.debug(' @@@@@ dscbShareListInsert  ' + dscbShareListInsert);             
            if (!dscbShareListInsert.isEmpty()){
                Database.insert(dscbShareListInsert);
            }
            
            
        } catch (exception e){
            
            Database.rollback(sp);
            system.debug('ERROR ...Applying Status Sharing Rules...  ' + e.getMessage() + ' : ' + e.getStackTraceString());
        }
    }

    private static void processAccountShares(map<Id, Id> accountShareMap){
        
        list<AccountShare> accountShares = new list<AccountShare>();
        map<Id, User> contactUserMap = new map<Id, User>([SELECT Id, Name, ProfileId, ContactId, IsActive FROM User WHERE ContactId IN :accountShareMap.values()]);  
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