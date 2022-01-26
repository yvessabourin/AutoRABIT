public with sharing class updateVillagePresenceController {
    
    // Get Opportunity record type Ids
    private static final id exitedRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Exit').RecordTypeId;
    private static final id contractChangeRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Contract Change').RecordTypeId;
    private static final id relocationRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Relocation').RecordTypeId;
    private static final id newRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('New Brand').RecordTypeId;
    private static final id shopfitRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('ShopRefit').RecordTypeId;
    
    // Objects used on VF page 
    public Village_Presence__c villagePresence {get; set;} // Record to commit
    public Village_Presence__c currentVillagePresence {get; set;} // Current Record values before commit
    public string currentUnit {get; set;}
    
    public string dealId {get; set;}
    public string updateReturn {get; set;} // for possible Mobile page implementation (to be completed)
    public boolean enableSaveBtn {get; set;}
    
    private Opportunity deal;
    private string previousStage = '';
    private string currentStage = '';
    
    public updateVillagePresenceController(){
                    
        try {   
            
            dealId = ApexPages.currentPage().getParameters().get('Id');
            previousStage = ApexPages.currentPage().getParameters().get('previousStage');
            currentStage = ApexPages.currentPage().getParameters().get('stage');
            initializeVillagePresence();
            
        } catch (exception e){
            string errMsg = 'A technical error has occurred : ' + 
                                e.getMessage() + ' : ' + e.getStackTraceString();
            enableSaveBtn = false;                              
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errMsg));           
        }
        
    }
    
    // On class instantiation from Visualforce page, populated village presence record with
    // values from Deal.
    public updateVillagePresenceController(ApexPages.StandardController controller) {

        try {
            // Id of Deal record currently in focus
            dealId = controller.getId();
            initializeVillagePresence();

        
        } catch (exception e){
            string errMsg = 'A technical error has occurred : ' + 
                                e.getMessage() + ' : ' + e.getStackTraceString();
            enableSaveBtn = false;                              
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errMsg));
        }   
        
        
        
        
    }
    
    private void initializeVillagePresence(){
        
        boolean valid = true;
        
        // Retrieve Deal field values to be copied
        deal = [select Id, CloseDate, Unit__c, Open_Date__c, Lease_Type__c, Lease_Id__c, StageName, RecordTypeId,
                             Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
                             Sales_Rating__c, Income_Rating__c, Position_rating__c,
                             Tourism_rating__c, Distributor__c, village_presence__r.Id,
                             Brand_Captain__c, China_Brand_Captain__c, GRS_Captain__c, Expected_Exit_Date__c, 
                             Strategy__c, Expected_Open_Date__c, Contract_Tenant_Break_Date__c,
                             Contract_Expiry_Date__c, Type, village_presence__c, Auto_Sync__c,
                             Matures_to_Standard_On__c, Standard_Terms__c, TOR_Schedule_Description__c                                                                     
                             FROM Opportunity where Id =:dealId];
                             
        if (deal.RecordTypeId == newRecordTypeID || deal.RecordTypeId == contractChangeRecordTypeId){
            if (deal.Unit__c == null){
                enableSaveBtn = false;
                valid = false;
                string msg = 'You must assign a unit to the deal before it can be closed';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,msg));              
            }           
        }
            
        /*
        1.set villagePresence to the opportunity.Village_Presence__c.id
        2. set the villagePresence attributes according to the deal
        */
        if (valid) {
            // Retrieve Village Presence record associated with current Deal (should only be 1!)
            villagePresence = [SELECT id, Name, status__c, Initial_Opened_Date__c, 
                                Unit__c, Unit__r.Name, Lease_Type__c, Newness_Date__c, Last_Remerchandising_Date__c, 
                                Lease_ID__c, Projected_Sales_Yield_Local__c,
                                Projected_Return_Local__c, Sales_Rating__c,
                                Income_Rating__c, Position_rating__c,
                                Tourism_rating__c, Distributor__c, Latest_Review_deal__c,
                                Contract_Type__c, Contract_Expiry_Date__c, New_Deal__c,
                                Strategy__c, Expected_Open_Date__c, Contract_Tenant_Break_Date__c,
                                Expected_Exit_Date__c, Deal_Type__c, Deal_in_Progress__c, Stage__c,
                                Matures_to_Standard_On__c, Standard_Terms__c, TOR_Schedule_Description__c     
                                FROM village_presence__c 
                                WHERE id = :deal.village_presence__c];
        
            // Take snapshot of current values
            if (villagePresence.Unit__c != null){
                currentUnit = villagePresence.Unit__r.Name;
            }
            currentVillagePresence = new Village_Presence__c();
            currentVillagePresence.status__c =  villagePresence.status__c;
            currentVillagePresence.Newness_Date__c = villagePresence.Newness_Date__c;
            currentVillagePresence.Last_Remerchandising_Date__c = villagePresence.Last_Remerchandising_Date__c;
            currentVillagePresence.Lease_Type__c = villagePresence.Lease_Type__c;
            currentVillagePresence.Contract_Expiry_Date__c = villagePresence.Contract_Expiry_Date__c;      
            currentVillagePresence.Contract_Type__c = villagePresence.Contract_Type__c;
            currentVillagePresence.Lease_ID__c = villagePresence.Lease_ID__c;
            currentVillagePresence.Projected_Sales_Yield_Local__c=  villagePresence.Projected_Sales_Yield_Local__c;
            currentVillagePresence.Projected_Return_Local__c = villagePresence.Projected_Return_Local__c;
            currentVillagePresence.Sales_Rating__c = villagePresence.Sales_Rating__c ;
            currentVillagePresence.Income_Rating__c = villagePresence.Income_Rating__c ;
            currentVillagePresence.Position_rating__c = villagePresence.Position_rating__c;
            currentVillagePresence.Tourism_rating__c = villagePresence.Tourism_rating__c;
            currentVillagePresence.Distributor__c = villagePresence.Distributor__c;                                    
            currentVillagePresence.Initial_Opened_Date__c = villagePresence.Initial_Opened_Date__c; 
            currentVillagePresence.New_deal__c = villagePresence.New_deal__c;
            currentVillagePresence.Latest_Review_deal__c = villagePresence.Latest_Review_deal__c;                               
            currentVillagePresence.Strategy__c = villagePresence.Strategy__c;
            currentVillagePresence.Expected_Open_Date__c = villagePresence.Expected_Open_Date__c;
            currentVillagePresence.Contract_Tenant_Break_Date__c = villagePresence.Contract_Tenant_Break_Date__c;
            currentVillagePresence.Standard_Terms__c = villagePresence.Standard_Terms__c;
            currentVillagePresence.Matures_to_Standard_On__c = villagePresence.Matures_to_Standard_On__c;
            currentVillagePresence.TOR_Schedule_Description__c = villagePresence.TOR_Schedule_Description__c;
            
            copyValues();
        
            enableSaveBtn = true;
        
        }
    
        
    }
    
    private void copyValues(){
        copyValues(villagePresence, deal, currentVillagePresence);
    }
    
    private static void copyValues(Village_Presence__c villagePresence, Opportunity deal, Village_Presence__c currentVillagePresence){
        
        // For all deals
        villagePresence.Last_Remerchandising_Date__c = deal.CloseDate;
        
        // For New deal only
        if(deal.recordtypeid == newRecordTypeID){
             
            villagePresence.Initial_Opened_Date__c = deal.Expected_Open_Date__c; 
            villagePresence.New_deal__c = deal.id; //set new deal record lookup on village presence 
            villagePresence.Latest_Review_deal__c = null; // remove review deal lookup as not applicable in this scenario (new deal)
            villagePresence.Status__c = 'Trading';
        }
        
        // For any Remerchandise deal only
        if (deal.RecordTypeId == contractChangeRecordTypeId || 
            deal.RecordTypeId == relocationRecordTypeID ||
            deal.RecordTypeId == shopFitRecordTypeId){
                
            villagePresence.Latest_Review_deal__c = deal.id; // Set review deal lookup on vilage presence to current deal         
            villagePresence.Status__c = 'Trading';
        }
        
        // For New or any Remerchandise deal
        if (deal.RecordTypeId == newRecordTypeId || 
            deal.RecordTypeId == contractChangeRecordTypeId ||
            deal.RecordTypeId == shopfitRecordTypeId || 
            deal.RecordTypeId == relocationRecordTypeID ){
            
            //Unit
            if (string.isnotBlank(deal.unit__c)){
                villagePresence.unit__c = deal.unit__c;
            }
            
            //Lease details
            villagePresence.Lease_Type__c = deal.Lease_Type__c; 
            if (string.isnotBlank(deal.Lease_ID__c)){
                villagePresence.Lease_ID__c = deal.Lease_ID__c;
            }
            
            // Sales
            villagePresence.Projected_Sales_Yield_Local__c= deal.Projected_Sales_Yield_Local__c;
            villagePresence.Projected_Return_Local__c = deal.Projected_Return_Local__c;
            
            //Ratings
            villagePresence.Sales_Rating__c = deal.Sales_Rating__c ;
            villagePresence.Income_Rating__c = deal.Income_Rating__c ;
            villagePresence.Position_rating__c = deal.Position_rating__c;
            villagePresence.Tourism_rating__c = deal.Tourism_rating__c;
                    
            //Distributor
            villagePresence.Distributor__c = deal.Distributor__c;
            
            
            //key dates        
            villagePresence.Newness_Date__c = deal.Expected_Open_Date__c;
            villagePresence.Contract_Tenant_Break_Date__c = deal.Contract_Tenant_Break_Date__c;
            villagePresence.Contract_Expiry_Date__c = deal.Contract_Expiry_Date__c;
            
            //strategy
            villagePresence.Strategy__c = deal.Strategy__c;
            
            //terms
            villagePresence.Standard_Terms__c = deal.Standard_Terms__c;
            villagePresence.Matures_to_Standard_On__c = deal.Matures_to_Standard_On__c;
                
            //TOR
            villagePresence.TOR_Schedule_Description__c = deal.TOR_Schedule_Description__c;    
        
        }
        
        // For Exit Deal only
        if(deal.recordtypeid == exitedRecordTypeID){
            villagePresence.Exit_deal__c = deal.id;
            villagePresence.Actual_Exit_Date__c = deal.Expected_Exit_Date__c;
            villagePresence.Status__c = 'Exited';
            villagePresence.Standard_Terms__c = '';
            villagePresence.TOR_Schedule_Description__c = '';
            villagePresence.Matures_to_Standard_On__c = null;
        }           
        
        // Exceptions
        if (deal.RecordTypeId == contractChangeRecordTypeId){
            villagePresence.Newness_Date__c = currentVillagePresence.Newness_Date__c;
        }
        
    }

        
    // Receives a list of deal Ids and updates associated Village Presence records.
    // Ideally, associated village presence records should be unique across the list
    // of deal Ids passed in
    /*
    To be used for mass update of Village Presence records. Can be run from Anonymous window,
    system debug logs will report any errors.
    
    script example ...

    // Query for deal records to be processed,
    map<Id, Opportunity> dealList = new map<Id, Opportunity>([select Id from Opportunity where StageName not in('Closed', 'Terminated')]);
    // call method to update associated village presences (examine debug logs after process has run)
    string bulkUpdate = updateVillagePresenceController.updateVillagePresenceList(dealList.keySet());
    system.debug(bulkUpdate);
    
    */
    public static string updateVillagePresenceList(set<Id> dealIdList){
        
        string returnString = '';
        
        try{
            // Retrieve deal details and associated village presence record (should only be 1 !)
            map<Id, Opportunity> oppMap = new map<Id, Opportunity>([select Id, CloseDate, Name, Unit__c, Open_Date__c, 
                                 Lease_Type__c, Lease_Id__c, StageName, RecordTypeId, LastModifiedDate,
                                 Projected_Sales_Yield_Local__c, Projected_Return_Local__c, Expected_Exit_Date__c, 
                                 Sales_Rating__c, Income_Rating__c, Position_rating__c,
                                 Tourism_rating__c, Distributor__c, village_presence__r.Id,
                                 Brand_Captain__c, China_Brand_Captain__c, GRS_Captain__c,
                                 Strategy__c, Expected_Open_Date__c, Contract_Tenant_Break_Date__c,
                                 Contract_Expiry_Date__c , Type, village_presence__c, Auto_Sync__c,
                                 Matures_to_Standard_On__c, Standard_Terms__c, TOR_Schedule_Description__c                                                                           
                                 FROM Opportunity where Id in :dealIdList
                                 order by LastModifiedDate asc]);   
            
            set<Id> vpIdList = new set<Id>();
            
            for(Opportunity opp :oppMap.values()){
                vpIdList.add(opp.village_presence__r.Id);
            }
            
            map<Id, Village_Presence__c> villagePresenceUpdateMap = new map<Id, Village_Presence__c>();
            
            map<Id, Village_Presence__c> villagePresenceMap = new Map<Id, Village_Presence__c>([
                                SELECT id, Name, status__c, Initial_Opened_Date__c,
                                Unit__c, Unit__r.Name, Lease_Type__c, Newness_Date__c, Last_Remerchandising_Date__c,  
                                Lease_ID__c, Projected_Sales_Yield_Local__c,
                                Projected_Return_Local__c, Sales_Rating__c,
                                Income_Rating__c, Position_rating__c,
                                Tourism_rating__c, Distributor__c, Latest_Review_deal__c,
                                Contract_Type__c,  Contract_Expiry_Date__c, New_Deal__c,
                                Strategy__c, Expected_Open_Date__c, Contract_Tenant_Break_Date__c,
                                Expected_Exit_Date__c,Deal_Type__c, Deal_in_Progress__c, Stage__c,
                                Matures_to_Standard_On__c, Standard_Terms__c, TOR_Schedule_Description__c      
                                FROM Village_Presence__c where Id in :vpIdList]);                               
            
            for (Opportunity opp :oppMap.values()){         
                if (string.isnotBlank(opp.Village_Presence__c)) {
                    Village_Presence__c villagePresence =   villagePresenceMap.get(opp.Village_Presence__c);
                    
                    copyValues(villagePresence, opp, villagePresence);                   
                    
                    //Due to possible bad data, put in map, to ensure only 1 VP record for each VP Id
                    //It is possible for deal Ids passed in to relate to the same VP record.                
                    villagePresenceUpdateMap.put(villagePresence.Id, villagePresence); 
                }               

            }
            list<Village_Presence__c> villagePresenceList = new list<Village_Presence__c>(villagePresenceUpdateMap.values());
            
            //system.debug(' @@@  Found ' + villagePresenceList.size() + ' records to process ..');
            returnString = ' @@@  Found ' + villagePresenceList.size() + ' records to process ..';
            
            integer index = 0;
                    
            if (!villagePresenceList.isEmpty()){
                Database.SaveResult[] resultList = null;
                resultList = Database.update(villagePresenceList, false); // update Village Presence list
                map<Id, Village_Presence__c> successMap = new map<Id, Village_Presence__c>();
                map<Id, string> errorIdMap = new map<Id, string>();             
                index = 0;
                for (Database.SaveResult r : resultList){                   
                    if (!r.isSuccess()){  
                        for (Database.Error e : r.getErrors()){  // Examine errors  
                            StatusCode status = e.getStatusCode();
                            string statusMsg = e.getMessage();
                            string errMsg = 'Village Presence Update Error ..  Status :- ' + status + ' : Message :- ' + statusMsg;                             
                            returnString += ' \r\n ' + errMsg;
                            string vpId = villagePresenceList[index].Id;
                            errorIdMap.put(vpId, errMsg);
                        }   
                    } else {
                        successMap.put(villagePresenceList[index].Id, villagePresenceList[index]);
                    }
                    index++;                    
                } 
                //system.debug(' @@@  Successfully updated ' + successMap.size() + ' Village Presence records ..');             
 
            
                // Update parent deal records with appropriate Stage if village presence update successful
  /*
  
                list<Opportunity> dealList = [select Id, StageName, village_presence__c, RecordTypeId
                                                    From Opportunity 
                                                    where id in :dealIdList];
                list<Opportunity> dealUpdateList = new list<Opportunity>();
                for (Opportunity opp :dealList){
                    if (successMap.containsKey(opp.village_presence__c)){ // village presence update successful
                        // Update Deal stage as appropriate
                        if (opp.RecordTypeId == newRecordTypeID)
                        {                           
                            opp.StageName = 'Completed - New Brand opened in Village'; //?       
                        } else if (opp.RecordTypeId == contractChangeRecordTypeId){
                            opp.StageName = 'Completed - Brand Refreshed';
                            
                        } else {
                            opp.StageName = 'Completed - Brand Exited';  //?
                        }
                        
                            
                                                
                        dealUpdateList.add(opp);                    
                    }
                }
                
                if (!dealUpdateList.isEmpty()){
                    resultList = Database.update(dealUpdateList, false); // update Deal list                    
                    index = 0;
                    for (Database.SaveResult r : resultList){                   
                        if (!r.isSuccess()){  
                            for (Database.Error e : r.getErrors()){  // Examine errors  
                                StatusCode status = e.getStatusCode();
                                string statusMsg = e.getMessage();
                                string errMsg = 'Deal Update Error (although VP update successful) ..  Status :- ' + status + ' : Message :- ' + statusMsg;
                                returnString += ' \r\n '+ errMsg; 
                                string oppId = dealUpdateList[index].Id;
                                errorIdMap.put(oppId, errMsg);
                            }   
                        }
                        index++;                
                    }                               
                }
                // log errors to debug log
                if (!errorIdMap.isEmpty()){
                    //system.debug(' @@@  Following Errors Occurred .. ');
                    returnString += ' \r\n @@@  Following Errors Occurred .. ';
                    for (string key :errorIdMap.keySet()){
                        //system.debug(' @@@  Error with record Id  : ' + key + ' : ' + errorIdMap.get(key));                       
                        returnString += ' \r\n @@@  Error with record Id  : ' + key + ' : ' + errorIdMap.get(key); 
                    }
                    
                } else {
                    // system.debug(' @@@  There were no errors. ');
                    returnString += ' \r\n @@@ There were no errors. ';
                }

*/

            }
      
        
        } catch (exception e){
            string errMsg = 'A technical error has occurred : ' + 
                                e.getMessage() + ' : ' + e.getStackTraceString(); 
            returnString += ' \r\n ' + errMsg;          
            
        }
        
        return returnString;
    
    }
    
    // Used by Visualforce page to update Deal stage once Village Presence
    // field values have been confirmed
    public PageReference saveVillagePresence()
    {
        PageReference pg = new PageReference('/' + deal.Id);     
        Savepoint sp = Database.setSavepoint();
 
        //system.debug(' @@@@  save  deal type ... ' + villagePresence.deal_type__c);
        //system.debug(' @@@@  save  deal in progress ... ' + villagePresence.deal_in_progress__c);
        //system.debug(' @@@@  save  vp id ... ' + villagePresence.Id);
         
        try {                                    
            
            // Update Deal stage and auto synch flag as appropriate            
            currentStage = ApexPages.currentPage().getParameters().get('stage');
 system.debug(' @@@@  current stage ... ' + currentStage);
            deal.StageName = currentStage;
            deal.Auto_Sync__c = false;
            
            update villagePresence;            
            update deal;
            
        } catch (exception e){
            Database.rollback(sp);
            string errMsg = 'Record could not be saved. Please review any error(s) displayed';
            errMsg += ' or report to System Administrator.\n' + ' ---- ' + e.getMessage();                                 
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());                       
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errMsg));
            pg = null;
        }               
        
        return pg;
    }
    
    public void saveRecordSf1(){
        
        PageReference pg = saveVillagePresence();

    }    
    // for possible mobile implementation .. (to be finished)   
//    @RemoteAction
//  public static string saveVillagePresence2(Sobject vp){

//          Savepoint sp = Database.setSavepoint();
//        string saveReturn = 'Start'; 
//        try {                 
//          update vp;                  
            /*
            if (deal.RecordTypeId == newRecordTypeID || deal.RecordTypeId == contractChangeRecordTypeId)
            {
                deal.StageName = 'Closed'; //?       
            }
            else{
                deal.StageName = 'Terminated';  //?
            }
            
            update deal;
            */
        /*
            saveReturn = 'Success';
            
        } catch (exception e){
            Database.rollback(sp);
            string errMsg = 'The Village presence could not be saved. Please review error : ' + 
                                     e.getMessage() + ' : ' + e.getStackTraceString();
            saveReturn = errMsg;                         
        
        }                       
        return saveReturn;
        */
//  }
        
      
    public PageReference cancelUpdate()
    {
        if (string.isnotBlank(previousStage)){
            deal.StageName = previousStage;
            update deal;
        }
        PageReference pg = new PageReference('/'+ deal.Id);
        pg = null; //force client-side refresh      

        return pg;
    }
    


}