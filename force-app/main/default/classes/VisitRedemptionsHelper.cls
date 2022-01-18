global with sharing class VisitRedemptionsHelper {

    public Boolean showHFSButton {public get; private set;}
//   private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('Partnership Promotion').RecordTypeId;
    private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('Partnership_Promotion').RecordTypeId;
    private static final id indBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByDeveloperName.get('Individuals_Partnership').RecordTypeId;
    private static final id grpBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByDeveloperName.get('Group_Booking').RecordTypeId;
    
    private static string[] statusFilterList = new List<string>{'Removed', 'Cancelled'};
    
    private static final Map<string,Id> imageFolders = populateImageFolders();
    
    public static final string usersVillage = getUsersVillage();
    private static final string usersVillageId = getUsersVillageId();
    private static final string defaultImageId = getDefaultImageId();
    private static final string imagePrefix = '/servlet/servlet.FileDownload?file=';
    
    private static final Map<string,Id> statusIcons = populateStatusIcons();
    
    public Id guestRecType {get; set;}
    public Id visitRecType {get; set;}
    public string visitList {get; set;}
    public string cleardownList {get;set;}
    public visit__c dummyVisit {get;set;} 
    
    public static string promotions {get; set;}

    public Boolean isCheckedIn {public get; private set;}
    public Boolean isCheckedOut {public get; private set;}

    public VisitRedemptionsHelper(apiCustomerController controller) {

    }
    
    public VisitRedemptionsHelper(ApexPages.StandardController controller) {
        guestRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Guest').RecordTypeId;
        visitRecType = Schema.SObjectType.Visit__c.RecordTypeInfosByDeveloperName.get('Standard').RecordTypeId;
        dummyVisit = new Visit__c(RecordTypeId = visitRecType);
        visitList = '';

        promotions = JSON.serialize(getTrendingCampaigns());  
        System.debug('promotions=====' + promotions);
        showHFSButton = false;
        isCheckedIn = false;
        isCheckedOut = false;
        String VisitID = ApexPages.currentPage().getParameters().get('visitId');

        if(VisitID != null && VisitID != ''){
            System.debug('VisitID === ' + VisitID);
            Visit__c thisvisit = [SELECT ID, Name, Visit_Date_Time__c, Check_Out_Date_Time__c FROM Visit__c WHERE ID =:VisitID];
            if(thisvisit.Visit_Date_Time__c != null){
                // means the arrival date is set, therefore they have checked in.
                isCheckedIn = true;
            }
            if(thisvisit.Check_Out_Date_Time__c != null){
                isCheckedOut = true;
            }
        }
        List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if(perm.PermissionSet.Name == 'Hands_Free_Shopping_Enabled'){
                showHFSButton = true;
            }     
        }   
    
          //  promotions = '[]';
         
    }
    
    public VisitRedemptionsHelper(){
        
        guestRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Guest').RecordTypeId;
        visitList = '';
          promotions = JSON.serialize(getTrendingCampaigns());  
         System.debug('promotions=====' + promotions);
           showHFSButton = false;
            List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if(perm.PermissionSet.Name == 'Hands_Free_Shopping_Enabled'){
                showHFSButton = true;
            }     
        }   
         showHFSButton = false;
        isCheckedIn = false;
        isCheckedOut = false;
        String VisitID = ApexPages.currentPage().getParameters().get('visitId');
        if(VisitID != null && VisitID != ''){
            System.debug('VisitID === ' + VisitID);
            Visit__c thisvisit = [SELECT ID, Name, Visit_Date_Time__c, Check_Out_Date_Time__c FROM Visit__c WHERE ID =:VisitID];
            if(thisvisit.Visit_Date_Time__c != null){
                // means the arrival date is set, therefore they have checked in.
                isCheckedIn = true;
            }
            if(thisvisit.Check_Out_Date_Time__c != null){
                isCheckedOut = true;
            }
        }
        
    }

    private static Map<string,Id> populateStatusIcons()
    {
        // get the status icons 
        Map<string,Id> returnIcons = new Map<string,Id>();
        System.debug('imageFolders = = ' + imageFolders);
         List<Document> documents = [select Id,Name from Document where FolderId = :imageFolders.get('Logos')];
         for(Document d :documents)
         {
              System.debug('Icon = ' + d);
            returnIcons.put(d.Name,d.Id);
         }
         System.debug('returnIcons = ' + returnIcons);
         return returnIcons;
    }
    
    private static Map<string,Id> populateImageFolders(){
        // get all the folders
        Map<string,Id> returnfolders = new Map<string,Id>();
         List<Folder> folders = [select Id,Name from Folder];
         for(Folder f :folders)
         {
            returnfolders.put(f.Name,f.Id);
         }
         return returnfolders;
    }    
    
    public static string getUsersVillage(){


        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
                            
        string village = users[0].Village__c;
        
        return village; 
                
    }

    public static string getUsersVillageId(){


        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
                            
        string village = users[0].Village__c;
        
        List<Village__c> v = [select Id from Village__c where Name = :village limit 1];
        string villageId = '';
        if (!v.isEmpty()){
            villageId = v[0].Id;
        }
        return villageId; 
                
    }
    

    private static string getDefaultImageId(){
        Id folderId;
        if (test.isRunningTest()){
            folderId = UserInfo.getUserId();
        } else {
            folderId = [select Id from Folder where Name = 'Partner Images'].Id; 
        }
        List<Document> docs = [select Id from Document where FolderId = :folderId and Name = 'Default'];
        string imageId = '';
        if(docs.size() > 0){
         imageId = docs[0].Id;
        }
        return imageId;
        
    }   
    
    @RemoteAction
    global static list<promotionKey> searchActivities(string param){
    
        list<promotionKey> returnList = new list<promotionKey>();
          

        
        string param1 = '\'' + '*' + param + '*' + '\'';
        string param2 = '\'' + param + '*' + '\'';
        string param3 = '\'' + '*' + param + '\'';
        string param4 = param;
        param = '\'' + param  + '\'';
        string searchParam = param4 + ' OR (' + param1 + ' OR ' + param2 + ' OR ' + param3 + ' OR ' + param + ')'; 
        
        system.debug(' @@@ Search for .. ' + searchParam );
            
        // Due a salesforce limitation on search numbers (only 2000 records at a time) we are forced to do 2 separate queries.... which could cause some delays :( 
        List<List<SObject>> searchList = [FIND :searchParam  IN ALL FIELDS 
                                          RETURNING 
                                             Marketing_Activity__c (Id, Name, Start_date__c, End_Date__c, Marketing_Campaign__r.Name,Partner__r.Name, Partner__r.Logo_Id__c, RecordType.Name, Other_Notes__c
                                                        WHERE recordtypeid =:promoRecordTypeId
                                                        AND (Marketing_Campaign_Village__c = :usersVillage OR Marketing_Campaign_Village__c = 'Group')
                                                        AND Start_Date__c <= :Date.today()
                                                        AND End_Date__c >= :Date.today()
                                                        AND Status__c NOT in :statusFilterList)];


system.debug('@@@@ searchList   ' + searchList);
system.debug('@@@@ searchList[0]   ' + searchList[0]);

          //add the campaigns that were found to this list                                  
        list<Marketing_Activity__c> foundPromos = ((List<Marketing_Activity__c>)searchList[0]);  
                 
        if(foundPromos.size() > 0){          
            for (Integer i=0; i<foundPromos.size(); i++) {
                promotionKey p = new promotionKey();
                p.Id = foundPromos[i].Id;
                p.Name = foundPromos[i].Name;
                p.campaignName = foundPromos[i].Marketing_Campaign__r.Name;
                p.Partner = foundPromos[i].Partner__r.Name;
                p.startDate =  foundPromos[i].Start_Date__c.format();
                p.endDate = foundPromos[i].End_Date__c.format();
                if (string.isnotBlank(foundPromos[i].Partner__r.Logo_Id__c)){
                  p.imageUrl = foundPromos[i].Partner__r.logo_id__c;
                } else {
                  p.imageUrl = imagePrefix + defaultImageId;
                }
                p.pType = 'Promotion';
                p.recType = foundPromos[i].RecordType.Name;
                p.notes = foundPromos[i].Other_Notes__c;   
                returnList.add(p);
            }
        }
        
        
        return returnList;  
        
    }

    
    @RemoteAction
    global static list<promotionKey> getTrendingCampaigns(){
        

        list <promotionKey> returnList = new list<promotionKey>();           
        
        map<Id, Marketing_Activity__c> villagePromoList = new map<Id, Marketing_Activity__c>(
                                [SELECT Id, Name, Start_date__c, End_Date__c, Partner__r.name, Marketing_Campaign__r.Name, Partner__r.Logo_Id__c, RecordType.Name, Other_Notes__c 
                                  FROM Marketing_Activity__c
                                  WHERE RecordtypeID = :promoRecordTypeId
                                  AND Start_Date__c <= :Date.today()
                                  AND End_Date__c >= :Date.today()
                                  AND (Marketing_Campaign_Village__c = :usersVillage OR Marketing_Campaign_Village__c = 'Group')
                                  AND Status__c NOT in :statusFilterList]);
         

System.debug('villagePromoList === ' + villagePromoList);
        DateTime lastFortnight = system.today() - 14;
        // including this many records is blowing the limit, so im adding a custom setting to go back n amount of days
        try{
            // get the custom setting to be able to go back some days to get trending visits
        Trending_Item_Range__c objDays = Trending_Item_Range__c.getValues('DaysBack');
      
        lastFortnight = system.today() - objDays.Days__c.intvalue();
        }
        catch(Exception ex)
        {
            // for now, we do nothing, because the code should just continue with the 14 days           
        }
        list<AggregateResult> arList1  = [select Partnership_Promotion__c, count(Id)visitCount, count(VIP_Cards_Exchanged__c)exchangeCount 
                                from Visit__c
                                where Partnership_Promotion__c in :villagePromoList.keySet()
                                and createddate > :lastFortnight
                                and village__c =:usersVillageId
                                group by Partnership_Promotion__c
                                order by count(Id) desc
                                limit 6 ];

        System.debug('arList1 === ' + arList1);
        list<visitCounter> visitCounterList = new list<visitCounter>();
        
        for (AggregateResult a :arList1){
            visitCounter v = new visitCounter();
            integer visitCount = integer.valueOf(a.get('visitCount'));
            string objId = string.valueOf(a.get('Partnership_Promotion__c'));
        
            v.visitCount = visitCount;
            v.recordId = objId;
            
            visitCounterList.add(v);
        }
        
       

system.debug(' @@@ visitCounterList 1  ' + visitCounterList);
        visitCounterList.sort();
system.debug(' @@@ visitCounterList 2  ' + visitCounterList);
        
        integer totalNumber = 0;
        for(visitCounter v :visitCounterList){
            if (totalNumber < 6){
                id objId = v.recordId;
                Schema.SObjectType objType = objId.getSobjectType();    
                if (objType.getDescribe().getName() == 'Marketing_Activity__c'){
                    promotionKey p = new promotionKey();
                    Marketing_Activity__c m = villagePromoList.get(objId);                  
                    p.Id = m.Id;
                    p.Name = m.Name;
                    p.campaignName = m.Marketing_Campaign__r.Name;
                    p.Partner = m.Partner__r.Name;
                    p.startDate =  m.Start_Date__c.format();
                    p.endDate = m.End_Date__c.format();         
                    if (string.isnotBlank(m.Partner__r.Logo_Id__c)){
                      p.imageUrl = m.Partner__r.logo_id__c;
                    } else {
                      p.imageUrl = imagePrefix + defaultImageId;
                    }
                    p.pType = 'Promotion';
                    p.recType = m.RecordType.Name;
                    p.notes = m.Other_Notes__c; 
                    
                    returnList.add(p);                  
                }               
                
                totalNumber ++;
            }
            
        }
                                                
       
                    
        return returnList;
    }


    @RemoteAction
    global static string getVisitDropdowns(){
        
        Map<String, Schema.SObjectField> objectFields 
                        = Schema.getGlobalDescribe().get('Visit__c').getDescribe().fields.getMap();
        
        map <string, list<string>> returnList = new map<string, list<string>>();
        
        map<string, string> locationValues =  PicklistUtilities.getPicklistValues('Visit__c', 
                                                                                    'Location__c', 
                                                                                    objectFields);
                                                                                    
        returnList.put('Location', locationValues.Values());
        
        map<string, string> transportValues =  PicklistUtilities.getPicklistValues('Visit__c', 
                                                                                    'Mode_of_Transport__c', 
                                                                                    objectFields);      
                                                                                            
        returnList.put('TransportMode', transportValues.Values());
        

        map<string, string> typeValues =  PicklistUtilities.getPicklistValues('Visit__c', 
                                                                                    'Type__c', 
                                                                                    objectFields);      
                                                                                            
        returnList.put('BusinessType', typeValues.Values());

        map<string, string> countryValues =  PicklistUtilities.getPicklistValues('Visit__c', 
                                                                                    'Country_of_Origin__c', 
                                                                                    objectFields);      
                                                                                            
        returnList.put('Country', countryValues.Values());
                        
        return json.serialize(returnList);
        
    }

    // method used on quick create guest screen to just retrieve the country dropdown
    @RemoteAction
    global static string getCountryDropdown(){
        
        map <string, map<string, string>> returnList = new map<string, map<string, string>>();
        
        map<string, string> countryValues =  apiCustomerUtilities.getEnumValueMap('Countries');     

        returnList.put('Country', countryValues);

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeFieldname('Country');
        gen.writeStartArray();
        for (string key :countryValues.keySet()){
            gen.writeStartObject();
            gen.writestringfield(key, countryValues.get(key));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.close();
        return gen.getAsString();
        //return json.serialize(returnList); //?? Reverse sorts the values map for some reason, therefore using JSON Generator      
        
    }

            
    // Method to quickly create a Guest record with minimal data
    @RemoteAction 
    global static string quickCreateGuest(string email, string phone, string firstName, 
                                            string lastName, string country, string promoId,
                                            string optoutEmail, string optoutMobile, string optoutPostal){
        
        string returnVal = '';
        try{        
            
            map<string, map<string, string>> enumMap = new map<string, map<string, string>>();
            apiCustomer.cls_Customer customer = new apiCustomer.cls_Customer();     
            //customer.x_CustomerId = guidGenerator.NewGuid();
            
            customer.name = new apiCustomer.cls_name();
            
            customer.name.x_given = firstName;
            customer.name.x_family = lastName;
            customer.x_source = 'SFVIP';
            
            if (string.isBlank(customer.x_VillagePrimary)){
                string villagePrimary = apiCustomerUtilities.getDefaultVillage();
                if (string.isnotBlank(villagePrimary)){
                    map<string, string> villageValues =  apiCustomerUtilities.getEnumValueMap('Villages');
                    enumMap.put('VillagePrimary', villageValues); 
                    customer.x_VillagePrimary = villagePrimary;
                }
            }
 
             if (string.isBlank(customer.x_Language)){
                string lang = apiCustomerUtilities.getDefaultLanguage();
                if (string.isnotBlank(lang)){
                    map<string, string> langValues =  apiCustomerUtilities.getEnumValueMap('Languages');
                    enumMap.put('Language', langValues); 
                    customer.x_Language = lang;
                }
            }
                       
            if (string.isnotBlank(country)){
                customer.address = new apiCustomer.cls_address();
                customer.address.x_country = country;
                map<string, string> countryValues =  apiCustomerUtilities.getEnumValueMap('Countries');     

                enumMap.put('Country', countryValues);                          
            }
    
            apiCustomer.cls_item REFitem = new apiCustomer.cls_item();
            apiCustomer.cls_item[] REFitems = new apiCustomer.cls_item[]{};
                
            REFitem.x_type = 'EMAIL';
            REFitem.y_text = email;
            
            REFitems.add(REFitem);
            
            apiCustomer.cls_references customerReferences = new apiCustomer.cls_references();
            customerReferences.item = REFitems;
            customer.References = customerReferences;
            
            apiCustomer.cls_item PROPitem = new apiCustomer.cls_item();
            apiCustomer.cls_item[] PROPitems = new apiCustomer.cls_item[]{};
                
            PROPitem.x_type = 'PHONENUMBER';
            PROPitem.y_text = phone;
            
            PROPitems.add(PROPitem);

            PROPitem = new apiCustomer.cls_item();            
            PROPitem.x_type = 'LEADSOURCE';
            PROPitem.y_text = promoId;            
            PROPitems.add(PROPitem);

            if (string.isnotBlank(optoutEmail)){
                PROPitem = new apiCustomer.cls_item();
                PROPitem.x_type = 'OPTOUTEMAIL';
                PROPitem.y_text = optoutEmail;            
                PROPitems.add(PROPitem);
            }
            
            if (string.isnotBlank(optoutMobile)){
                PROPitem = new apiCustomer.cls_item();
                PROPitem.x_type = 'OPTOUTMOBILE';
                PROPitem.y_text = optoutMobile;            
                PROPitems.add(PROPitem);
            }
            
            if (string.isnotBlank(optoutPostal)){
                PROPitem = new apiCustomer.cls_item();
                PROPitem.x_type = 'OPTOUTPOSTAL';
                PROPitem.y_text = optoutPostal;            
                PROPitems.add(PROPitem);
            }
                        
            apiCustomer.cls_properties customerProperties = new apiCustomer.cls_properties();      
            customerProperties.item = PROPitems;
            customer.Properties = customerProperties;
            
            string xmlCustomer = apiCustomer.convertToXML(customer);
            
            string apiCallResponse = apiService.postNewCustomer(xmlCustomer);
    system.debug('@@@@ Guest Creation response ...  ' + apiCallResponse);       
            if (apiCallResponse.contains('ERROR')){
                    returnVal = 'There was an error creating Guest data - please report to system administrator if error persists.';        
            } else {
                /*
                integer cStart = apiCallResponse.indexOf('CustomerId="');
                system.debug(cStart);
                integer istart = apiCallResponse.indexOf('"', cStart);
                system.debug(istart);
                integer iend = apiCallResponse.indexOf('"', istart + 1);
                system.debug(iend);
                string guid = apiCallResponse.substring(istart + 1, iend);
                system.debug(guid);             
                if (string.isnotBlank(optinEmail)){
                    string msg = '<CustomerPreference CustomerId="' + guid +'"';
                    msg += ' Group="contactmodes" Key="' + 'email';
                    msg += '" Value ="' + optinEmail + '"/>';
                    string apiPreferenceCallResponse = apiService.postPreference(msg);
                    if (apiPreferenceCallResponse.contains('ERROR')){                   
                        returnVal = 'Guest has been created successfully, but there was a problem setting marketing preferences - please report to system administrator if error persists.';
                    }
                }
                if (string.isnotBlank(optinSMS)){
                    string msg = '<CustomerPreference CustomerId="' + guid +'"';
                    msg += ' Group="contactmodes" Key="' + 'mobile';
                    msg += '" Value ="' + optinSMS + '"/>';
                    string apiPreferenceCallResponse = apiService.postPreference(msg);
                    if (apiPreferenceCallResponse.contains('ERROR')){                   
                        returnVal = 'Guest has been created successfully, but there was a problem setting marketing preferences - please report to system administrator if error persists.';
                    }
                }               
                */
                
                Account newAccount = apiCustomer.upsertCustomer(apiCallResponse, true, customer.x_CustomerId, enumMap);

               
                /* - Following code triggers async process to pass Salesforce ID to Microservice for
                 * new guest which may (or may not) be required
                Integration_Salesforce_Id_Queue__c q = new Integration_Salesforce_Id_Queue__c();
                q.Salesforce_Id__c = newAccount.Id;
                q.Customer_GUID__c = newAccount.Customer_GUID__c;   
                insert q;
                // queue async job to send sf id
                system.enqueueJob(new apiCustomerSFIDUpdateQueue());
                */          
    
                returnVal = newAccount.Id;
            }
        } catch (exception e){
            returnVal = 'There was an error creating Guest data - please report to system administrator if error persists.'; 
            system.debug(' @@@@@@@@@@    ERROR CREATING CUSTOMER FOR VIP REDEMPTION !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());  
        }
        return returnVal;       
    }   
    
    @RemoteAction
    global static string getVIPCards(string visitId){
        
        string returnString = '';
        
        if (string.isnotBlank(visitId)){
            list<Vip_Card_Exchange__c> vipCardList = [select VIP_Card_Code__c from VIP_Card_Exchange__c
                                                            where Visit__c = :visitId];
            
                for(Vip_Card_Exchange__c vip : vipCardList){
                    returnString += vip.Vip_Card_Code__c + ';';
                }
        }
        
        return returnString;
        
    }
    
    @RemoteAction
    global static string savePreScannedVisit(string codes,string visitId){
        // this will save just the pre-scanned cards to the visit record
          string returnValue = '';

        string invalidCodes = '';

        List<VIP_Card_Exchange__c> exchangeList = New list<VIP_Card_Exchange__c>();
            string badCodes = '';
        codes = codes.replaceAll('\\u00A0', ''); // remove all nbsp characters
            
            list<string> voucherCodesSplit = codes.split(';');
            set<string> uniqueVoucherCodeSplit = new set<string>();
            uniqueVoucherCodeSplit.addAll(voucherCodesSplit );
           
            system.debug('list of voucher codes: '+ uniqueVoucherCodeSplit);
                        
            //loop through the list (unique voucher codes) and add them to the exchangeList 
            for(string v  :uniqueVoucherCodeSplit)
            {
                // IB 7/3/2017 INC0305300
                v = v.trim(); // trim any leading or trailing whitespaces
                system.debug('In loop string: ' + v);
                    if (string.isnotblank(v) && (v.length() == 14 || v.length() == 16)) //the voucher code is valid 
                    {                      
                        exchangeList.add(New VIP_Card_Exchange__c(Visit__c = visitId, VIP_Card_Code__c = v, Guest__c = null));
                    }
                    else
                    {
                        invalidCodes = invalidCodes + v + ', ';
                    }    
            }//end for loop
            system.debug('@@@ Invalid Codes ... ' + invalidCodes);
            system.debug('@@@ exchange list ... ' + exchangeList);
            
            if(invalidCodes.length() > 2)
            {
               returnValue = exchangeList.size() + ' Cards recorded, there were badly formatted codes not processed - ' + invalidCodes + '\r\n';  
               if (exchangeList.size() > 0){                        
                    try {
                        insert exchangeList;
                    } catch (exception e){                      
                        system.debug(' @@@@@@@@@@    ERROR INSERTING CARDS !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());   
                    }
                    
                } else {
                    returnValue += 'Visit has been recorded, with no associated card redemptions \r\n';
                    // Database.rollback(sp);                  
                }
            }
            else 
            {
                if (exchangeList.size() > 0){                       
                    try {
                        insert exchangeList;
                        returnValue += 'Visit has been recorded, with ' + exchangeList.size() + ' card(s) successfully scanned \r\n';
                    } catch (exception e){
                        system.debug(' @@@@@@@@@@    ERROR INSERTING CARDS !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());   
                    }
                } else { // no valid codes scanned, therefore not a valid visit record
                    returnValue += 'Visit has been recorded, with no associated card redemptions \r\n';
                    // Database.rollback(sp);
                }   
               
               
            }
             return returnValue;
    }

    @RemoteAction
    global static string saveVisit(string codes, string promoId, string guestId, 
                                        string location, string transport, string businessType, string country, 
                                        string visitId, string visitNotes,string vehiclereg, string checkIn, string checkOut, string numberOfGuests, string numberOfChildren
                                        ) {
       
       //setup and default a return value. This string will be interogated by the JS in the VF page
        string returnValue = '';
        string invalidCodes = '';
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            // Create visit record attached to promotion
            Id pId = Id.valueOf(promoId);
            
            // first extract village Id from user's village
            Id villageId = [select Id from Village__c where Name = :usersVillage].Id;
            String objectAPIName = pId.getSObjectType().getDescribe().getName();
            Visit__c visit = null;
            
            if (string.isnotBlank(visitId)){
                
                visit = [select Id, Village__c, Location__c, Mode_Of_Transport__c, Type__c, Country_Of_Origin__c,
                            Visit_Date_Time__c, Check_Out_Date_Time__c, Visit_Notes__c, Number_of_Guests__c,Number_of_Children__c
                            from Visit__c
                            where Id =:visitId
                                ];
                                
                visit.Location__c = location;
                visit.Mode_Of_Transport__c = transport;
                visit.Type__c = businessType;
                visit.Country_of_Origin__c = country;
                visit.Visit_Notes__c = visitNotes;
                visit.Vehicle_Registration_Number__c = vehiclereg;
                if (string.isnotBlank(checkIn)){
                    Datetime dt = null;
                    try {
                        dt = DateTime.parse(checkIn);
                        visit.Visit_Date_Time__c = dt;
                    }catch (exception e){
                        // do nothing - invalid date
                    }
                } else {
                    visit.Visit_Date_Time__c = null;
                }
                if (string.isnotBlank(checkOut)){
                    Datetime dt = null;
                    try {
                        dt = DateTime.parse(checkOut);
                        visit.Check_Out_Date_Time__c = dt;
                    }catch (exception e){
                        // do nothing - invalid date
                    }
                } else {
                    visit.Check_Out_Date_Time__c = null;
                }               
                try {
                    visit.Number_Of_Guests__c = decimal.valueOf(numberOfGuests);
                } catch (exception e){
                    // do nothing - invalid number
                }
                try{
                    visit.Number_of_Children__c = decimal.valueOf(numberOfChildren);
                }
                catch (exception e){
                    // do nothing, value will be blank
                }
                Database.update (visit);
                                
            } else {

                Schema.SObjectType objType = pId.getSobjectType();
                string pRecType;    
                if (objType.getDescribe().getName() == 'Group_Booking__c'){
                    pRecType = [select RecordTypeId from Group_Booking__c where Id = :pId].RecordTypeId;
                }
                visit = new Visit__c (Village__c = villageId,
                                                Location__c = location,
                                                Mode_of_Transport__c = transport,
                                                Type__c = businessType,
                                                Country_of_Origin__c = country,                                                
                                                Visit_Notes__c = visitNotes ,Vehicle_Registration_Number__c = vehiclereg);
                // default check in time to now unless adding visit for a Group Booking type
                if (pRecType != grpBookingRecordTypeId){
                    visit.Visit_Date_Time__c = system.now();
                }
                if (string.isnotBlank(checkIn)){
                    Datetime dt = null;
                    try {
                        dt = DateTime.parse(checkIn);
                        visit.Visit_Date_Time__c = dt;
                    }catch (exception e){
                        // do nothing - invalid date
                        visit.Visit_Date_Time__c = system.now(); //default today
                    }
                }
                if (string.isnotBlank(checkOut)){
                    Datetime dt = null;
                    try {
                        dt = DateTime.parse(checkOut);
                        visit.Check_Out_Date_Time__c = dt;
                    }catch (exception e){
                        // do nothing - invalid date
                    }
                }               
                try {
                    visit.Number_Of_Guests__c = decimal.valueOf(numberOfGuests);
                } catch (exception e){
                    // do nothing - invalid number
                }      
                  try{
                    visit.Number_of_Children__c = decimal.valueOf(numberOfChildren);
                }
                catch (exception e){
                    // do nothing, value will be blank
                }     
            
                if (objectAPIName == 'Marketing_Activity__c'){
                    visit.Partnership_Promotion__c = pId; 
                }
                if (objectAPIName == 'Group_Booking__c'){
                    visit.Group_Booking__c = pId; 
                }
                                                                            
                Database.insert(visit);                                 
            }            
            
            List<VIP_Card_Exchange__c> exchangeList = New list<VIP_Card_Exchange__c>();
            string badCodes = '';
            
            // IB 7/3/2017 INC0305300
            codes = codes.replaceAll('\\u00A0', ''); // remove all nbsp characters
            
            list<string> voucherCodesSplit = codes.split(';');
            set<string> uniqueVoucherCodeSplit = new set<string>();
            uniqueVoucherCodeSplit.addAll(voucherCodesSplit );
           
            system.debug('list of voucher codes: '+ uniqueVoucherCodeSplit);
                        
            //loop through the list (unique voucher codes) and add them to the exchangeList 
            for(string v  :uniqueVoucherCodeSplit)
            {
                // IB 7/3/2017 INC0305300
                v = v.trim(); // trim any leading or trailing whitespaces
                system.debug('In loop string: ' + v);
                system.debug('Promotion.Id: ' + promoId);
                    if (string.isnotblank(v) && (v.length() == 14 || v.length() == 16)) //the voucher code is valid 
                    {
                        if (string.isBlank(guestId)){
                            guestId = null;
                        }
                        exchangeList.add(New VIP_Card_Exchange__c(Visit__c = visit.Id, VIP_Card_Code__c = v, Guest__c = guestId));
                    }
                    else
                    {
                        invalidCodes = invalidCodes + v + ', ';
                    }    
            }//end for loop
system.debug('@@@ Invalid Codes ... ' + invalidCodes);
system.debug('@@@ exchange list ... ' + exchangeList);
            
            if(invalidCodes.length() > 2)
            {
               returnValue = exchangeList.size() + ' Cards recorded, there were badly formatted codes not processed - ' + invalidCodes + '\r\n';  
               if (exchangeList.size() > 0){                        
                    try {
                        insert exchangeList;
                    } catch (exception e){                      
                        system.debug(' @@@@@@@@@@    ERROR INSERTING CARDS !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());   
                    }
                    
                } else {
                    returnValue += 'Visit has been recorded, with no associated card redemptions \r\n';
                    // Database.rollback(sp);                  
                }
            }
            else 
            {
                if (exchangeList.size() > 0){                       
                    try {
                        insert exchangeList;
                        returnValue += 'Visit has been recorded, with ' + exchangeList.size() + ' card(s) successfully scanned \r\n';
                    } catch (exception e){
                        system.debug(' @@@@@@@@@@    ERROR INSERTING CARDS !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());   
                    }
                } else { // no valid codes scanned, therefore not a valid visit record
                    returnValue += 'Visit has been recorded, with no associated card redemptions \r\n';
                    // Database.rollback(sp);
                }   
               
               
            }
            visit = [select Number_Of_Guests__c,Number_of_Children__c, VIP_Cards_Exchanged__c from Visit__c where Id = :visit.Id];
            if (visit.Number_Of_Guests__c == null  && visit.VIP_Cards_Exchanged__c > 0){
                visit.Number_Of_Guests__c = visit.VIP_Cards_Exchanged__c;
            } else if (visit.Number_Of_Guests__c == 0  && visit.VIP_Cards_Exchanged__c > 0){
                visit.Number_Of_Guests__c = visit.VIP_Cards_Exchanged__c;
            }
            Database.update (visit);
              
        } catch (exception e) {
            Database.rollback(sp);
            returnValue = 'ERROR - A technical error has occurred .. ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
            return returnValue;
            
        }
        return returnValue;
    }

    @RemoteAction
    global static string clearCards(string codes){
        
        string returnValue = '';
        list<string> cardList = codes.split(';');
        
        if (!cardList.isEmpty()){       
            try{
                List<VIP_Card_Exchange__c> exchangeList = [select Id from VIP_Card_Exchange__c 
                                                            where VIP_Card_Code__c in :cardList ];  
                
                if (!exchangeList.isEmpty()){
                    Database.DeleteResult[] dr = Database.delete(exchangeList, false);
                    returnValue = exchangeList.size() + ' cards, found and procesed';                   
                } else {
                    returnValue = 'All cards processed';
                }
                
            } catch (exception e){
                returnValue = 'ERROR - A technical error has occurred .. ' + e.getMessage() + ' : ' + e.getStackTraceString();
                system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
                return returnValue;         
            }
        }
        
        return returnValue;
    }     

    @RemoteAction
    global static string noShow(string visitId){
        string returnValue = '';
        try {                           
            Visit__c visit = [select No_Show__c from Visit__c  where Id = :visitId];
            
            visit.No_Show__c = true;
            update visit;

        } catch (exception e){
            returnValue = 'ERROR - A technical error has occurred .. ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
            return returnValue;             
                    
        }
        
        return returnValue;
    }
    
    @RemoteAction
    global static string resendCheckinEmail(string emailText,string visitId){
    
        LIST<string> toaddress = emailText.split(';');
        if(toaddress != null && toaddress.size() > 0 ){
            emailUtils checkinmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_In');
                   
            System.Debug('About to call SEND EMail == == ' + toaddress);
             emailUtils.emailSendResponse emailResponse = checkinmailUtils.sendEmail(toaddress,null,(ID)visitId,null,null,null);
            // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                System.Debug('emailResponse == == ' + emailResponse);
            if(emailResponse.emailSendResult){
                // if success, return blank                
                    return '';          
            }
            else{
                // if false, check message, else return generic
                if(emailResponse.emailResultMessage != null ){
                     system.debug('emailResponse.emailSendResult === ' + emailResponse.emailSendResult);
                      // need to surface an error if possible
                     return 'ERROR - Email Sending Failed - (' + emailResponse.emailResultMessage + ')'; 
                 }
                 else{
                    return 'ERROR - General Error occurred, Please Contact IT Support';
                }
            }
        }
        else
        {
            return 'ERROR - no email address found.';
        }

    }

    @RemoteAction
    global static string resendCheckoutEmail(string emailText,string visitId){

        
                LIST<string> toaddress = emailText.split(';');
        if(toaddress != null && toaddress.size() > 0){
               emailUtils checkoutmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_Out');
            System.Debug('About to call SEND EMail == == ' + toaddress);
             emailUtils.emailSendResponse emailResponse = checkoutmailUtils.sendEmail(toaddress,null,(ID)visitId,null,null,null);
            // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                System.Debug('emailResponse == == ' + emailResponse);
                      if(emailResponse.emailSendResult){
                // if success, return blank                
                    return '';          
            }
            else{
                // if false, check message, else return generic
                if(emailResponse.emailResultMessage != null ){
                     system.debug('emailResponse.emailSendResult === ' + emailResponse.emailSendResult);
                      // need to surface an error if possible
                     return 'ERROR - Email Sending Failed - (' + emailResponse.emailResultMessage + ')'; 
                 }
                 else{
                    return 'ERROR - General Error occurred, Please Contact IT Support';
                }
            }
        }
        else
        {
            return 'ERROR - no email address found.';
        }

    }
    public static void deleteExistingCards(list<VIP_Card_Exchange__c> VIPCards){  
        
        set<string> voucherSet =  new set<string>();
        
        for(VIP_Card_Exchange__c c : VIPCards )
        {
            voucherSet.add(c.VIP_Card_Code__c);
        }
        
        list<VIP_Card_Exchange__c> deletionList = [SELECT id from VIP_Card_Exchange__c
                                                         WHERE VIP_Card_Code__c in :voucherset];    
        
          
        delete deletionList;
 
    }
    
    public PageReference getVisitList(){
        
        string bookingId = System.currentPageReference().getParameters().get('promoId');
        Date dToday = System.Today();
        Datetime dt = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
        
        list<list<Sobject>> returnObjectList = new list<list<Sobject>>();
        
        list<Visit__c> returnList = new list<Visit__c>();
        
        if (string.isnotBlank(bookingId)){
            returnList = [select Id, Name, Visit_Date_Time__c, VIP_Cards_Exchanged__c, Number_of_Guests__c,Number_of_Children__c,
                            Mode_of_Transport__c, Location__c, Country_of_Origin__c, Group_Booking__r.Name,
                            Group_Booking__r.RecordType.Name, Check_Out_Date_Time__c, Visit_Notes__c, Type__c,Vehicle_Registration_Number__c 
                            from Visit__c 
                            where Group_Booking__c = :bookingId
                            and No_Show__c = false
                           // and 
                           //((Visit_Date_Time__c >= :dt or Expected_Arrival_Date_Time__c >= :dt)
                            //or 
                          //  (Visit_Date_Time__c = null and Expected_Arrival_Date_Time__c = null) //)
                            order by Visit_Date_Time__c asc];
                            
            list<Group_Booking__c> booking =  [select Id, Name, Organisation__r.Name, Visitors_Country_of_Origin__c, Contact__r.Name,
                                            RecordType.Name, Number_of_Visitors_Expected__c,Notes_and_Additional_Comments__c,
                                            Name_of_Event__c, Expected_Arrival__c, Expected_Mode_of_Transport__c, Requested_Check_In_Location__c,
                                            Group_Type__c
                                            from Group_Booking__c
                                            where Id = :bookingId];
                                            
            returnObjectList.add(returnList);
            returnObjectList.add(booking);                                             
        }

        //this.visitList = JSON.serialize(returnlist);
        this.visitList = JSON.serialize(returnObjectList);
        
        return null;
        
    }

    public PageReference getGroupCleardownList(){
        
        DateTime lastFortnight = system.today() - 14;
        
        list<Visit__c> visitCleardownList = [select Id, Name, Expected_Arrival_Date_Time__c, VIP_Cards_Exchanged__c, Number_of_Guests__c,Number_of_Children__c,
                            Mode_of_Transport__c, Location__c, Country_of_Origin__c, 
                            Check_Out_Date_Time__c, Visit_Notes__c, Type__c, Group_Booking__c,
                            Group_Booking__r.Name, Group_Booking__r.Number_of_Visitors_Expected__c, Group_Booking__r.Organisation__r.Name,
                            Group_Booking__r.Village__r.Name, Booking_Partnership_Name__c
                            from Visit__c 
                            where Visit_Date_Time__c = null
                            and Group_Booking__r.RecordTypeId = :grpBookingRecordTypeId
                            and Group_Booking__r.Village__c = :UsersVillageId
                            and No_Show__c = false
                            and (VIP_Cards_Exchanged__c > 0 or Number_of_Guests__c > 0)
                            and (Expected_Arrival_Date_Time__c <= Today and Expected_Arrival_Date_Time__c >= :lastFortnight)
                            order by Group_Booking__r.Village__r.Name asc, Expected_Arrival_Date_Time__c desc];
        
        this.cleardownList = JSON.serialize(visitCleardownList);
        return null;
    }    
    
    global class visitCounter implements Comparable{    
        integer visitCount;
        string recordId;

        global Integer compareTo(Object other) {
            Integer otherCount = other != null ? ((visitCounter)other).visitCount : 0;            
            // subtraction between this and other 
            return otherCount - this.visitCount;
        }
    }
    
 
    
                
    global class promotionKey{
        
        global promotionKey(){
                        
            this.Id = '';
            this.Name = '';
            this.Partner = '';
            this.startDate = '';
            this.endDate = '';
            this.arrivalTime = '';
            this.campaignName = '';
            this.imageUrl = '';
            this.statusimageUrl = ''; 
            this.pType = '';
            this.recType = '';
            this.numberOfVisitors = '';
            this.statusText = '';

        }
        
        public string Id {get; private set;}
        public string Name {get; private set;}
        public string campaignName {get; private set;}
        public string Partner{get; set;}
        public string startDate {get; set;}
        public string endDate {get; set;}
        public string arrivalTime {get; set;}
        public string imageUrl {get; set;}
        public string statusimageUrl {get; set;}
        public string statusText {get; set;}  
        public string pType {get; set;}
        public string recType {get; set;}
        public string numberOfVisitors {get; set;}
        public string fundingProgram{get; set;}
        public string notes {get;set;}
        
    }    

}