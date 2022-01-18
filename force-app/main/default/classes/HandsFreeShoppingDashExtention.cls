global  with sharing class HandsFreeShoppingDashExtention {

    private final sObject mysObject;
  
      // The extension constructor initializes the private member
      // variable mysObject by using the getRecord method from the standard
      // controller.
      public static String userVillage {get; set;}
      public static String userVillageCode {get; set;}
      public static String getAllPickupLocations {get; set;}
      public static Integer totalExperiences {get; set;}
      public static Integer liveExperiences {get; set;}
      public static Integer activeExperiences {get; set;}
      public static Integer closedExperiences {get; set;}
      public static Integer didNotParticipateExperiences {get; set;}
      public static Decimal totalBagsforDay {get; set;}    
      public static Decimal totalJobsforDay {get;set;}
      public static String totalSpend {get;set;}
      public static String location {get; set;}
      public static String getAllPendingCases {get; set;}
      public static List<HFS_IntegrationErrorTrackedBag__c> errorList {get;set;}
  
      public static Boolean isHFShost { get;  set;}
      public static Boolean isHFSHistoric { get;  set;}
      public static Boolean isNewHFSx { get;  set;}
      public static Boolean allErrorsResolved{get;set;}
      public static Boolean showIntegrationErrors{get;set;}
      public static Integer totalErrors{get;set;}
      public static String hfsdashsummary{get;set;}
      public static HFSSpentLevelCalculator currencyLevelCalculator;
      public static Boolean hasClickCollect {get; set;}
      public static Boolean showClickCollect {get; set;}
  
      public HandsFreeShoppingDashExtention(ApexPages.StandardController stdController) {
          this.mysObject = (sObject)stdController.getRecord();
          // need to also get the users village setting to show only HFS records from that village
          Id profileId=userinfo.getProfileId();
          String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
  
          userVillage = getUsersVillage();
          currencyLevelCalculator = HFS_Utils.getCurrencyLevelCalculator(userVillageCode);
          getAllPickupLocations = getPickupLocations();
  
          //getAllPendingCases = getPendingCases();
          HFS_Features__mdt villageMetadata = getVillageHFSFeatures(userVillage)[0];
          hasClickCollect = villageMetadata.Click_And_Collect__c;
  
          isHFShost = false;
          isHFSHistoric = true;
          isNewHFSx = true;
          allErrorsResolved = true;
          totalErrors = 0;
          showIntegrationErrors = false;
          showClickCollect = false;
  
          if (System.currentPagereference().getParameters().get('showClickCollect') != null){
              showClickCollect = Boolean.valueOf(System.currentPagereference().getParameters().get('showClickCollect'));
          }
          
          System.debug('ProfileName: ' + profileName);    
  
          if(profileName == 'HFS Co-ordinator' || profileName == 'System Administrator'){
              //isNewHFSx = false;
              showIntegrationErrors = true;
          }     
          if(profileName == 'HFS Host'){
              isHFShost = true;
              isHFSHistoric = false;
          } 
          errorList = [SELECT Id, CreatedDate, Brand_Lease_Id__c, Brand_Location_Name__c, DateTime__c, Estimated_Spend__c, Guest_Code__c, List_of_Bags__c, Number_of_Bags__c, Is_Resolved__c
                       FROM HFS_IntegrationErrorTrackedBag__c];      
          
      }
  
      private static string getUsersVillage(){
  
          string userId = UserInfo.getUserId();
          list<user> users = [SELECT id, Village__c FROM USER 
                              WHERE id = :userId
                              LIMIT 1];
          
          Village__c uservillage  = [SELECT Name, Village_Code__c FROM Village__c WHERE Name =:users[0].Village__c LIMIT 1];
                              
          string village = users[0].Village__c;
          userVillageCode = uservillage.Village_Code__c;
          
          return village; 
                  
      }
  
  
      public static List<HFS_Features__mdt> getVillageHFSFeatures(String villageName){
          return [SELECT Click_And_Collect__c FROM HFS_Features__mdt WHERE MasterLabel =:villageName];
      }
  
      @RemoteAction
      global static String filterErrors(string startdate, string enddate,string actionedValue, string techSupportreqd){  
          //global static String filterErrors(string startdate, string enddate, string resolvedValue, string actionedValue, string categoryValue){  
                   
          list<string> startitems = startdate.split('-');
          list<string> enditems = enddate.split('-');
          
          DateTime thestartDate = DateTime.newInstanceGMT(integer.valueOf(startitems[0]), integer.valueOf(startitems[1]),integer.valueOf(startitems[2]), 0,0,0);
          DateTime theendDate = DateTime.newInstanceGMT(integer.valueOf(enditems[0]), integer.valueOf(enditems[1]),integer.valueOf(enditems[2]), 23,59,59);
         
          System.debug('thestartDate ' + thestartDate);
          System.debug('theendDate ' + theendDate); 
      
         string userId = UserInfo.getUserId();
                  list<user> users = [SELECT id,Email, Village__c FROM USER 
                                      WHERE id = :userId
                                      LIMIT 1];
                  
                  Village__c theuservillage  = [SELECT Name, Village_Code__c FROM Village__c WHERE Name =:users[0].Village__c LIMIT 1];                                   
    
                  string userVillageCode = theuservillage.Village_Code__c;                               
                  string searchTerm = userVillageCode+'%';         
          
                      set<boolean> techsupportOptions;
                      set<boolean> actionedOptions;
          
                     if(techSupportreqd == '<tech Support reqd>'){
                         techsupportOptions = new Set<boolean>{true,false};
                      }
                     else if(techSupportreqd == 'Yes'){
                             techsupportOptions = new Set<boolean>{true};       
                     }else{
                        techsupportOptions = new Set<boolean>{false};
                     }
          
                      if(actionedValue == '<Is Actioned>'){
                          actionedOptions = new Set<boolean>{true,false};
                      }
                      else if(actionedValue == 'Yes'){
                              actionedOptions = new Set<boolean>{true};       
                      }else{
                          actionedOptions = new Set<boolean>{false};
                      }
          
       // LIST<string> theCategories = new LIST<String>{'Bag(s) already inserted in the system'};
       //   set<string> resolvedOptions = new Set<String>{'Yes','No'};
       //   set<string> actionedOptions = new Set<String>{'Yes','No'};
              
  
          List <HFS_IntegrationErrorTrackedBag__c> errors = [SELECT Id, Error_Category__c,Requires_Technical_Support__c,HFS_Case__c, HFS_Guest_ID__c, CreatedDate, Name, Brand_Lease_Id__c, Brand_Location_Name__c, DateTime__c, Estimated_Spend__c, Guest_Code__c, List_of_Bags__c, Number_of_Bags__c, Is_Resolved__c
                                                            FROM HFS_IntegrationErrorTrackedBag__c 
                                                            WHERE Brand_Location_Name__c LIKE:searchTerm AND DateTime__c >= :thestartDate AND DateTime__c <= :theendDate  
                                                            AND Is_Resolved__c IN:actionedOptions AND Requires_Technical_Support__c IN:techsupportOptions
                                                            ORDER BY CreatedDate 
                                                            DESC LIMIT 200];
  
          return JSON.serialize(errors);
  
      }
  
      
      
      
      
  
      global static String getErrors(){
          
          
          string searchTerm = userVillageCode+'%';
          List <HFS_IntegrationErrorTrackedBag__c> errors = [SELECT Id, Error_Category__c,Requires_Technical_Support__c,HFS_Case__c, HFS_Guest_ID__c, CreatedDate, Name, Brand_Lease_Id__c, Brand_Location_Name__c, DateTime__c, Estimated_Spend__c, Guest_Code__c, List_of_Bags__c, Number_of_Bags__c, Is_Resolved__c
                                                            FROM HFS_IntegrationErrorTrackedBag__c WHERE Brand_Location_Name__c LIKE:searchTerm AND DateTime__c = today
                                                            ORDER BY CreatedDate 
                                                            DESC LIMIT 200];
          for(HFS_IntegrationErrorTrackedBag__c errorBag : errors){
              if(!errorBag.Is_Resolved__c){
                  allErrorsResolved = false;
                  if(errorBag.CreatedDate.date() == Datetime.now().date()){
                      totalErrors++;
                  }
              }
          }
          return JSON.serialize(errors);
      }
  
  
      global static String getVPS() {
  
          list<Village_Presence__c> vps = [SELECT id, Name,HFS_Bags_Left__c ,HFS_Bags_Received__c,HFS_Bags_Used__c,HFS_Threshold__c, Replenish__c FROM Village_Presence__c WHERE Village__r.Name =:userVillage AND Is_HFS_Active__c = true ORDER BY NAME ASC];
  
          return JSON.serialize(vps);
       
      }
  
     global static String getCases() {
  
          List<Case> cases = [SELECT Id, SuppliedName,SuppliedPhone, SuppliedEmail,Type,Village__c,Mode_of_Transport__c, 
                                          HFS_Collection_Location__c,Service_Guest_ID__c,Service_Guest_Number__c ,Guest_ID_Number_Part__c , Status, Payment_Status__c, Guest_Arrive_at_Collection_Point__c,Guest_Collection_Point_has_changed__c,Total_Bags_at_wrong_Collection_Point__c, Total_Spent_Amount__c, Country_of_residence__c,
                                          HFS_Click_And_Collect__c, HFS_Collection_Date__c
                                          FROM Case WHERE Service_Date__c = TODAY AND Village__r.Name =:userVillage AND HFS_Click_And_Collect__c = false ORDER BY CreatedDate DESC];
         
          List<Case_Item__c> caseitems = [SELECT Status__c, Item_Count__c,Case__c FROM Case_Item__c WHERE Case__c in :cases];
  
          Map<ID,List<Case_Item__c> > caseitemsmap = new Map<ID,List<Case_Item__c> >();
          // populate MAP
          List<CaseDashItem> returnobj = new List<CaseDashItem>();
  
          // lets add up the people in each status
               hfsSummary summary = new hfsSummary();
  
          Integer totalNew = 0;
          Integer totalClosed = 0;
          Integer totalShopping = 0;
          Integer totalDidNotParticipate = 0;
          Integer totalTotal = 0;
  
          for(Case cs : cases){
              CaseDashItem cdi = new CaseDashItem();
              cdi.Id = cs.Id;
              cdi.SuppliedName = cs.SuppliedName;
              cdi.SuppliedPhone = cs.SuppliedPhone;
              cdi.SuppliedEmail = cs.SuppliedEmail;
              cdi.Type = cs.Type;
              cdi.Village = cs.Village__c;
              cdi.Mode_of_Transport = cs.Mode_of_Transport__c;
              cdi.HFS_Collection_Location = cs.HFS_Collection_Location__c;
              cdi.Service_Guest_ID = cs.Service_Guest_ID__c;
              cdi.Service_Guest_Number = cs.Service_Guest_Number__c;
              cdi.Guest_ID_Number_Part = String.valueOf(cs.Guest_ID_Number_Part__c);
              cdi.Status = cs.Status;
              cdi.Payment_Status = cs.Payment_Status__c;
              cdi.Guest30minutes = cs.Guest_Arrive_at_Collection_Point__c;
              cdi.CollectionPointhaschanged = cs.Guest_Collection_Point_has_changed__c;
              cdi.TotalBagsatwrongCollectionPoint = cs.Total_Bags_at_wrong_Collection_Point__c;
              cdi.totalSpend = cs.Total_Spent_Amount__c.setScale(2);
              cdi.isClickAndCollect = cs.HFS_Click_And_Collect__c;
              cdi.collectionDateClickAndCollect = cs.HFS_Collection_Date__c;
              cdi.totalSpendFormatted = currencyLevelCalculator.getFormattedCurrency(cs.Total_Spent_Amount__c);
  
              HFS_SpentLevel guestLevel = currencyLevelCalculator.getGuestLevel(cs.Total_Spent_Amount__c, cs.Country_of_residence__c);
              cdi.spendLevel = guestLevel.name();
             
              switch on cdi.Status {
                 when 'New' {
                     totalNew ++;
                 }
                 when 'Shopping' {
                    totalShopping++;
                 }
                 when 'Closed' {
                    totalClosed++;
                 }
                 when 'Did Not Participate' {
                    totalDidNotParticipate++;
                 }
              }
              totalTotal ++;
  
              // the rest needs counting up
              Integer ItemCount = 0;
              Integer ItemsCollected = 0;
              Integer ItemsAwaiting = 0;
              Integer ItemsBagCount = 0;
              for(Case_Item__c casitem :caseitems){
                  if(casitem.Case__c == cs.Id){
                      ItemCount++;
                      // then we check if its collected etc...
                      if(casitem.Status__c == 'Awaiting Pick-up from Brand' || casitem.Status__c == 'In transit' ){
                          ItemsAwaiting ++;
                      }
                      if(casitem.Status__c == 'Ready for Guest Collection'){
                          ItemsCollected ++;
                      }
                      ItemsBagCount += Integer.valueOf(casitem.Item_Count__c);
                  }
              }
              cdi.ItemCount = String.valueOf(ItemCount);
              cdi.ItemsCollected = String.valueOf(ItemsCollected);
              cdi.ItemsAwaiting = String.valueOf(ItemsAwaiting);
              cdi.ItemsBagCount = String.valueOf(ItemsBagCount);
  
              returnobj.add(cdi);
          }
  
          // lets add the numbers to the summary object
          summary.statusnew = String.valueOf(totalNew);
          summary.shopping = String.valueOf(totalShopping);
          summary.closed = String.valueOf(totalClosed);
          summary.didNotParticipate = String.valueOf(totalDidNotParticipate);
          summary.total = String.valueOf(totalTotal);
  
          hfsdashsummary = JSON.serialize(summary);
          // Awaiting Collection from Brand = in brand (red)
          // Awaiting Customer Collection = in collection point (green)
          return JSON.serialize(returnobj);
     }
      
      
      
          
          @RemoteAction
          global static String techSupportRequired(string IntegrationErrorId){ 
              
              HFS_IntegrationErrorTrackedBag__c theError = [SELECT id,Requires_Technical_Support__c,Brand_Lease_Id__c,Brand_Location_Name__c,DateTime__c,Error_Category__c,Estimated_Spend__c,Guest_Code__c,HFS_Case__c,
                                                            HFS_Guest_ID__c,List_of_Bags__c,Number_of_Bags__c
                                                            FROM HFS_IntegrationErrorTrackedBag__c WHERE Id =:IntegrationErrorId ];
              
              theError.Requires_Technical_Support__c = true;
              
               Savepoint sp = Database.setSavepoint();
              try{
                 
                  update theError;
                  
                  string userId = UserInfo.getUserId();
                  list<user> users = [SELECT id,Email, Village__c FROM USER 
                                      WHERE id = :userId
                                      LIMIT 1];              
                  
                      String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                      message.toAddresses = new String[] { users[0].email, 'ITSupport@valueretail.com' };
                      message.optOutPolicy = 'FILTER';
                      message.subject = 'FAO Salesforce Support - Hands Free Shopping Integration Error';
                      message.plainTextBody = ' Link: ' + baseUrl + '/' + theError.Id ;
                      message.plainTextBody += '\n Error Id: ' + theError.Id + '\n Error Date: ' + theError.DateTime__c + '\n Brand Lease Id: ' + theError.Brand_Lease_Id__c + '\n Brand Location Name: ' + theError.Brand_Location_Name__c ;
                      message.plainTextBody += '\n Error Category: ' + theError.Error_Category__c + '\n Estimated Spend: ' + theError.Estimated_Spend__c +  '\n Guest Code: ' + theError.Guest_Code__c + '\n HFS Case: ' + theError.HFS_Case__c  ;
                      message.plainTextBody += '\n HFS Guest ID: ' + theError.HFS_Guest_ID__c + '\n Number of Bags: ' + theError.Number_of_Bags__c + '\n List of Bags: ' + theError.List_of_Bags__c  ;
                  
                      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                      
                      if (results[0].success) 
                      {
                          System.debug('The email was sent successfully.');
                          return 'Success';
                      } else 
                      {
                          Database.rollback(sp);
                          System.debug('The email failed to send: ' + results[0].errors[0].message);
                          return 'The email failed to send, please contact support - ' + results[0].errors[0].message;
                      }
                            
              }
              catch(exception e){
                  Database.rollback(sp);
                  system.debug('techSupportRequired failed --- ' + e);
                  return 'An error occured, please forward this to your administrator \n' + e.getmessage();                  
              }
              
              
          }
      
          @RemoteAction
          global static String resolveIntegrationError(string IntegrationErrorId){  
              
              HFS_IntegrationErrorTrackedBag__c theError = [SELECT id,Is_Resolved__c FROM HFS_IntegrationErrorTrackedBag__c WHERE Id =:IntegrationErrorId ];
              
              theError.Is_Resolved__c = true;
              
              try{
                  update theError;         
                  return 'Success';
              }
              catch(exception e){
                  system.debug('resolveIntegrationError failed --- ' + e);
                  return 'An error occured, please forward this to your administrator \n' + e.getmessage();                  
              }
          
          }
      
      
      
          @RemoteAction
          global static String getBagRecord(string bagID){  
           list<HFS_Bag__c> theBags = [SELECT Id, Name FROM HFS_Bag__c WHERE Barcode__c =:bagID ];
              
              if(theBags.size() == 1){
                  return theBags[0].Id;
              }
              else if(theBags.size() > 1){
                  return 'Bag Barcode used more than once, please search manually';               
              }
              else{
                  return 'There are no Bags with that Barcode being used in the system currently';
              }
  
          }
      
      @RemoteAction
      global static String getHFSrecords(string startdate, string enddate, string userVillage){     
        
          string varDate1 = startdate + ' 00:00:00';
          string varDate2 = enddate + ' 23:59:59';        
          date thestartDate = Date.valueOf(varDate1);
          date theendDate = Date.valueOf(varDate2);
          System.debug('thestartDate ' + thestartDate);
          System.debug('theendDate ' + theendDate);
          
          List<Case> cases = [SELECT Id, SuppliedName,SuppliedPhone, SuppliedEmail,Type,Village__c,Mode_of_Transport__c,
                                          HFS_Collection_Location__c,Service_Guest_ID__c,Service_Guest_Number__c ,Guest_ID_Number_Part__c , Status, Payment_Status__c, Guest_Arrive_at_Collection_Point__c
                                          ,Total_Purchases_of_Guest__c,Total_Concluded_Purchases_of_Guest__c,Total_Bags_of_the_Guest__c,Total_Scanned_Bags_of_Guest__c,Historic_Close_Reason__c
                                          FROM Case WHERE Service_Date__c >= :thestartDate AND Service_Date__c <= :theendDate AND Village__r.Name =:userVillage AND Was_Historically_Closed__c = true ORDER BY CreatedDate DESC];
          
         List<Case_Item__c> caseitems = [SELECT Status__c, Item_Count__c,Case__c FROM Case_Item__c WHERE Case__c in :cases];
         
         system.debug('caseitems - ' + caseitems.size());
         
         Map<ID,List<Case_Item__c> > caseitemsmap = new Map<ID,List<Case_Item__c> >();
         
         for(Case_Item__c caseitem : caseitems ){
             if(caseitemsmap.get(caseitem.Case__c) == NULL){
                 caseitemsmap.put(caseitem.Case__c,new list<Case_Item__c>{caseitem});
             }  
             else{
                 caseitemsmap.get(caseitem.Case__c).add(caseitem);
             }
             
         }
          // populate MAP
          List<CaseDashItem> returnobj = new List<CaseDashItem>();
  
          for(Case cs : cases){
              CaseDashItem cdi = new CaseDashItem();
              cdi.Id = cs.Id;
              cdi.SuppliedName = cs.SuppliedName;
              cdi.SuppliedPhone = cs.SuppliedPhone;
              cdi.SuppliedEmail = cs.SuppliedEmail;
              cdi.Type = cs.Type;
              cdi.Village = cs.Village__c;
              cdi.Mode_of_Transport = cs.Mode_of_Transport__c;
              cdi.HFS_Collection_Location = cs.HFS_Collection_Location__c;
              cdi.Service_Guest_ID = cs.Service_Guest_ID__c;
              cdi.Service_Guest_Number = cs.Service_Guest_Number__c;
              cdi.Guest_ID_Number_Part = String.valueOf(cs.Guest_ID_Number_Part__c);
              cdi.Status = cs.Status;
              cdi.Payment_Status = cs.Payment_Status__c;
              cdi.Guest30minutes = cs.Guest_Arrive_at_Collection_Point__c;
              cdi.Historic_Close_Reason = cs.Historic_Close_Reason__c;
              
              // the rest needs counting up
              Integer ItemCount = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsCollected =Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
              Integer ItemsAwaiting = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsBagCount = Integer.valueOf(cs.Total_Bags_of_the_Guest__c);
              Integer ItemsBagCollected = Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
  
              cdi.ItemCount = String.valueOf(ItemCount);
              cdi.ItemsCollected = String.valueOf(ItemsCollected);
              cdi.ItemsAwaiting = String.valueOf(ItemsAwaiting);
              cdi.ItemsBagCount = String.valueOf(ItemsBagCount);
            
              Integer itemNotResolvedCount = 0;
              Integer itemResolvedCount = 0;
                
              returnobj.add(cdi);           
              
          }
     
          system.debug('returnobj - ' + returnobj);
          system.debug('returnobj - ' + returnobj.size());
          return JSON.serialize(returnobj);
    
      }
      
      @RemoteAction
      global static String updateHFSHousekeepingRecords(string idlist){
          
          system.debug('idlist ' + idlist);
          set<id> thecaseIds = new set<id>();
          list<string> caseIds = idlist.split(',');
          system.debug('caseIds ' + caseIds);
          
          for(string str : caseIds ){
              thecaseIds.add(str.trim().replace('[','').replace(']',''));
          }
          
          List<case> caseUpdates = new list<case>();
          List<case> thecases = [SELECT Id, SuppliedName,SuppliedPhone, SuppliedEmail,Type,Village__c,Mode_of_Transport__c,
                                          HFS_Collection_Location__c,Service_Guest_ID__c,Service_Guest_Number__c ,Guest_ID_Number_Part__c , Status, Payment_Status__c, Guest_Arrive_at_Collection_Point__c
                                          ,Total_Purchases_of_Guest__c,Total_Concluded_Purchases_of_Guest__c,Total_Bags_of_the_Guest__c,Total_Scanned_Bags_of_Guest__c,Historic_Close_Reason__c,Service_Date__c
                                          FROM Case WHERE id  IN: thecaseIds ORDER BY CreatedDate DESC];
         
          
          for(case hfs : thecases){
              hfs.status = 'Did Not Participate'; 
              caseUpdates.add(hfs);
          }
           system.debug('caseUpdates ' + caseUpdates);
          
          try{
              update caseUpdates ; 
              List<CaseDashItem> returnobj = new List<CaseDashItem>();
                  for(Case cs : thecases){
                  CaseDashItem cdi = new CaseDashItem();
              cdi.Id = cs.Id;
              cdi.SuppliedName = cs.SuppliedName;
              cdi.SuppliedPhone = cs.SuppliedPhone;
              cdi.SuppliedEmail = cs.SuppliedEmail;
              cdi.Type = cs.Type;
              cdi.Village = cs.Village__c;
              cdi.Mode_of_Transport = cs.Mode_of_Transport__c;
              cdi.HFS_Collection_Location = cs.HFS_Collection_Location__c;
              cdi.Service_Guest_ID = cs.Service_Guest_ID__c;
              cdi.Service_Guest_Number = cs.Service_Guest_Number__c;
              cdi.Guest_ID_Number_Part = String.valueOf(cs.Guest_ID_Number_Part__c);
              cdi.Status = cs.Status;
              cdi.Payment_Status = cs.Payment_Status__c;
              cdi.Guest30minutes = cs.Guest_Arrive_at_Collection_Point__c;
              cdi.Historic_Close_Reason = cs.Historic_Close_Reason__c;
              cdi.selected = false;
              cdi.ServiceDate = cs.Service_Date__c;
              
              // the rest needs counting up
              Integer ItemCount = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsCollected =Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
              Integer ItemsAwaiting = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsBagCount = Integer.valueOf(cs.Total_Bags_of_the_Guest__c);
              Integer ItemsBagCollected = Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
  
              cdi.ItemCount = String.valueOf(ItemCount);
              cdi.ItemsCollected = String.valueOf(ItemsCollected);
              cdi.ItemsAwaiting = String.valueOf(ItemsAwaiting);
              cdi.ItemsBagCount = String.valueOf(ItemsBagCount);
            
              Integer itemNotResolvedCount = 0;
              Integer itemResolvedCount = 0;
                
              returnobj.add(cdi);    
                  }
              return JSON.serialize(returnobj);
          }
          catch (exception e){
          system.debug('HFSGuestsDidNotParticipateJob failed --- ' + e);
          return 'An error occured, please send this to your administrator ' + e.getmessage();        
          }
          
          
      }
      
      @RemoteAction
      global static String getHFSHousekeepingRecords(string startdate, string enddate, string userVillage){     
        
          string varDate1 = startdate + ' 00:00:00';
          string varDate2 = enddate + ' 23:59:59';        
          date thestartDate = Date.valueOf(varDate1);
          date theendDate = Date.valueOf(varDate2);
          System.debug('thestartDate ' + thestartDate);
          System.debug('theendDate ' + theendDate);
          
          List<Case> cases = [SELECT Id, SuppliedName,SuppliedPhone, SuppliedEmail,Type,Village__c,Mode_of_Transport__c,
                                          HFS_Collection_Location__c,Service_Guest_ID__c,Service_Guest_Number__c ,Guest_ID_Number_Part__c , Status, Payment_Status__c, Guest_Arrive_at_Collection_Point__c
                                          ,Total_Purchases_of_Guest__c,Total_Concluded_Purchases_of_Guest__c,Total_Bags_of_the_Guest__c,Total_Scanned_Bags_of_Guest__c,Historic_Close_Reason__c,Service_Date__c
                                          FROM Case WHERE Service_Date__c >= :thestartDate AND Service_Date__c <= :theendDate AND Service_Date__c != today AND Village__r.Name =:userVillage AND Status = 'New' AND HFS_Click_And_Collect__c = false ORDER BY CreatedDate DESC];
          
         List<Case_Item__c> caseitems = [SELECT Status__c, Item_Count__c,Case__c FROM Case_Item__c WHERE Case__c in :cases];
         
         system.debug('caseitems - ' + caseitems.size());
         
         Map<ID,List<Case_Item__c> > caseitemsmap = new Map<ID,List<Case_Item__c> >();
         
         for(Case_Item__c caseitem : caseitems ){
             if(caseitemsmap.get(caseitem.Case__c) == NULL){
                 caseitemsmap.put(caseitem.Case__c,new list<Case_Item__c>{caseitem});
             }  
             else{
                 caseitemsmap.get(caseitem.Case__c).add(caseitem);
             }
             
         }
          // populate MAP
          List<CaseDashItem> returnobj = new List<CaseDashItem>();
  
          for(Case cs : cases){
              CaseDashItem cdi = new CaseDashItem();
              cdi.Id = cs.Id;
              cdi.SuppliedName = cs.SuppliedName;
              cdi.SuppliedPhone = cs.SuppliedPhone;
              cdi.SuppliedEmail = cs.SuppliedEmail;
              cdi.Type = cs.Type;
              cdi.Village = cs.Village__c;
              cdi.Mode_of_Transport = cs.Mode_of_Transport__c;
              cdi.HFS_Collection_Location = cs.HFS_Collection_Location__c;
              cdi.Service_Guest_ID = cs.Service_Guest_ID__c;
              cdi.Service_Guest_Number = cs.Service_Guest_Number__c;
              cdi.Guest_ID_Number_Part = String.valueOf(cs.Guest_ID_Number_Part__c);
              cdi.Status = cs.Status;
              cdi.Payment_Status = cs.Payment_Status__c;
              cdi.Guest30minutes = cs.Guest_Arrive_at_Collection_Point__c;
              cdi.Historic_Close_Reason = cs.Historic_Close_Reason__c;
              cdi.selected = false;
              cdi.ServiceDate = cs.Service_Date__c;
              
              // the rest needs counting up
              Integer ItemCount = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsCollected =Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
              Integer ItemsAwaiting = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsBagCount = Integer.valueOf(cs.Total_Bags_of_the_Guest__c);
              Integer ItemsBagCollected = Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
  
              cdi.ItemCount = String.valueOf(ItemCount);
              cdi.ItemsCollected = String.valueOf(ItemsCollected);
              cdi.ItemsAwaiting = String.valueOf(ItemsAwaiting);
              cdi.ItemsBagCount = String.valueOf(ItemsBagCount);
            
              Integer itemNotResolvedCount = 0;
              Integer itemResolvedCount = 0;
                
              returnobj.add(cdi);           
              
          }
     
          system.debug('returnobj - ' + returnobj);
          system.debug('returnobj - ' + returnobj.size());
          return JSON.serialize(returnobj);
    
      }
  
  
     global static String getPendingCases() {
  
          Date varDate = system.TODAY() - 7;
          Date todayDate = system.TODAY();
  
          System.debug('Data ' + vardate);
  
          List<Case> cases = [SELECT Id, SuppliedName,SuppliedPhone, SuppliedEmail,Type,Village__c,Mode_of_Transport__c,Historic_Close_Reason__c,
                                          HFS_Collection_Location__c,Service_Guest_ID__c,Service_Guest_Number__c ,Guest_ID_Number_Part__c , Status, Payment_Status__c, Guest_Arrive_at_Collection_Point__c
                                          ,Total_Purchases_of_Guest__c,Total_Concluded_Purchases_of_Guest__c,Total_Bags_of_the_Guest__c,Total_Scanned_Bags_of_Guest__c, HFS_Collection_Date__c, HFS_Click_And_Collect__c
                                          FROM Case WHERE (Service_Date__c > :varDate OR HFS_Click_And_Collect__c = true) AND Service_Date__c != :todayDate AND Village__r.Name =:userVillage AND Status = 'Shopping' ORDER BY HFS_Collection_Date__c NULLS LAST, CreatedDate DESC];
         
         system.debug('cases - ' + cases);
          
          List<Case_Item__c> caseitems = [SELECT Status__c, Item_Count__c,Case__c FROM Case_Item__c WHERE Case__c in :cases];
         
         system.debug('caseitems - ' + caseitems.size());
         
         Map<ID,List<Case_Item__c> > caseitemsmap = new Map<ID,List<Case_Item__c> >();
         
         for(Case_Item__c caseitem : caseitems ){
             if(caseitemsmap.get(caseitem.Case__c) == NULL){
                 caseitemsmap.put(caseitem.Case__c,new list<Case_Item__c>{caseitem});
             }  
             else{
                 caseitemsmap.get(caseitem.Case__c).add(caseitem);
             }
             
         }
          // populate MAP
          List<CaseDashItem> returnobj = new List<CaseDashItem>();
  
          for(Case cs : cases){
              CaseDashItem cdi = new CaseDashItem();
              cdi.Id = cs.Id;
              cdi.SuppliedName = cs.SuppliedName;
              cdi.SuppliedPhone = cs.SuppliedPhone;
              cdi.SuppliedEmail = cs.SuppliedEmail;
              cdi.Type = cs.Type;
              cdi.Village = cs.Village__c;
              cdi.Mode_of_Transport = cs.Mode_of_Transport__c;
              cdi.HFS_Collection_Location = cs.HFS_Collection_Location__c;
              cdi.Service_Guest_ID = cs.Service_Guest_ID__c;
              cdi.Service_Guest_Number = cs.Service_Guest_Number__c;
              cdi.Guest_ID_Number_Part = String.valueOf(cs.Guest_ID_Number_Part__c);
              cdi.Status = cs.Status;
              cdi.Payment_Status = cs.Payment_Status__c;
              cdi.Guest30minutes = cs.Guest_Arrive_at_Collection_Point__c;
              cdi.Historic_Close_Reason = cs.Historic_Close_Reason__c;
              cdi.collectionDateClickAndCollect = cs.HFS_Collection_Date__c;
              cdi.isClickAndCollect = cs.HFS_Click_And_Collect__c;
              
  
              // the rest needs counting up
              Integer ItemCount = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsCollected =Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
              Integer ItemsAwaiting = Integer.valueOf(cs.Total_Purchases_of_Guest__c);
              Integer ItemsBagCount = Integer.valueOf(cs.Total_Bags_of_the_Guest__c);
              Integer ItemsBagCollected = Integer.valueOf(cs.Total_Concluded_Purchases_of_Guest__c);
  
              cdi.ItemCount = String.valueOf(ItemCount);
              cdi.ItemsCollected = String.valueOf(ItemsCollected);
              cdi.ItemsAwaiting = String.valueOf(ItemsAwaiting);
              cdi.ItemsBagCount = String.valueOf(ItemsBagCount);
  
             
              
              Integer itemNotResolvedCount = 0;
              Integer itemResolvedCount = 0;
             
             
             if(caseitemsmap.get(cs.Id) != NULL){
             
             
                  for(Case_Item__c ci : caseitemsmap.get(cs.Id)){
                      
                      if(ci.Status__c != 'Guest Collected' ){
                          itemNotResolvedCount += 1;
                      }else{
                          itemResolvedCount += 1;
                      }
                          
                  }
              
                  if(itemNotResolvedCount == 0 ){
                      cdi.ItemIsResolved = true;
                  }else{
                      cdi.ItemIsResolved = false;
                  }
              }
              
              //returnobj.add(cdi);
  
              returnobj.add(cdi);
              
          }
          // Awaiting Collection from Brand = in brand (red)
          // Awaiting Customer Collection = in collection point (green)
          
          system.debug('returnobj - ' + returnobj);
          system.debug('returnobj - ' + returnobj.size());
          return JSON.serialize(returnobj);
  
     }
  
  
      public class CaseDashItem{
  
          String ID {get;set;}
          String SuppliedName {get;set;}
          String SuppliedPhone {get;set;}
          String SuppliedEmail {get;set;}
          String Type {get;set;}
          String Village {get;set;}
          String Mode_of_Transport {get;set;}
          String HFS_Collection_Location {get;set;}
          String Service_Guest_ID {get;set;}
          String Service_Guest_Number  {get;set;}
          String Guest_ID_Number_Part  {get;set;}
          String Status {get;set;}
          String Payment_Status {get;set;}
          String ItemCount  {get;set;}
          String ItemsCollected {get;set;}
          String ItemsAwaiting {get;set;}
          String ItemsBagCount {get;set;}
          Datetime Guest30minutes {get;set;}
          Boolean CollectionPointhaschanged {get;set;}
          Decimal TotalBagsatwrongCollectionPoint {get;set;}
          Boolean ItemIsResolved {get;set;}
          String Historic_Close_Reason {get;set;}
          boolean selected {get;set;}
          Date ServiceDate {get;set;}
          Decimal totalSpend;
          String totalSpendFormatted;
          String spendLevel;
          Boolean isClickAndCollect;
          Date collectionDateClickAndCollect;
          
          public CaseDashItem () {}
          
          public CaseDashItem (Case cs) {
  
          }
  
      }
      //DEV TEAM L
      public class pickupLocationPickUp{
  
          String Location_name {get;set;}
          Integer NumberHFS {get;set;}
  
      }
  
  
      public static String getPickupLocations(){
  
          List<Guest_Services_Data__c> queryPickupLocations = [SELECT id, Data_Label__c, Service_Data_Type__c, Village__c FROM Guest_Services_Data__c
                                                               WHERE Village__c =: userVillage
                                                               AND Service_Data_Type__c = 'HFS Collection Location'];
  
          Village__c village = [SELECT id, Name FROM Village__c
                                WHERE Name =: userVillage];
  
          List<Case> allExperiences = [SELECT id, HFS_Collection_Location__c, Service_Date__c, Type, Village__c, Status,Total_Bags_of_the_Guest__c,Total_Jobs__c, Total_Spent_Amount__c FROM Case
                                       WHERE Service_Date__c = TODAY and HFS_Click_And_Collect__c = false
                                       AND Village__c =: village.Id];
  
          List <pickupLocationPickUp> PickUpLocations = new List <pickupLocationPickUp>();
  
          totalExperiences = 0;
          activeExperiences = 0;
          didNotParticipateExperiences = 0;
          closedExperiences = 0;
          totalBagsforDay = 0;
          totalJobsforDay = 0;
          liveExperiences = 0;
          Decimal totalSpendAmount = 0;
          
          for(Guest_Services_Data__c pl : queryPickupLocations){
              Integer numberOfExperiences = 0;
              for(Case oneExperience : allExperiences){
                  
                  if(oneExperience.Type == 'Hands Free Shopping' && oneExperience.HFS_Collection_Location__c == pl.Data_Label__c){
                   numberOfExperiences = numberOfExperiences + 1;
                   totalExperiences = totalExperiences + 1;
                   totalBagsforDay = totalBagsforDay + oneExperience.Total_Bags_of_the_Guest__c; 
                   totalJobsforDay = totalJobsforDay + oneExperience.Total_Jobs__c ;
                   totalSpendAmount += oneExperience.Total_Spent_Amount__c; 
                  }
                                   
                  if(oneExperience.Type == 'Hands Free Shopping' && oneExperience.HFS_Collection_Location__c == pl.Data_Label__c && oneExperience.Status != 'Closed'){
                     
                      if(oneExperience.Status == 'Shopping'){
                          activeExperiences = activeExperiences + 1;
                          liveExperiences = liveExperiences + 1;
                      }
                      if(oneExperience.Status == 'new'){
                          liveExperiences = liveExperiences + 1;
                      }
                      if(oneExperience.Status == 'Did Not Participate'){
                          didNotParticipateExperiences = didNotParticipateExperiences + 1;
                      }
                  }
                  Else if(oneExperience.Type == 'Hands Free Shopping' && oneExperience.HFS_Collection_Location__c == pl.Data_Label__c && oneExperience.Status == 'Closed'){
                      closedExperiences = closedExperiences + 1;
                  }
              }
  
              pickupLocationPickUp item = new pickupLocationPickUp();
              item.Location_name = pl.Data_Label__c;
              item.NumberHFS = numberOfExperiences;
              PickUpLocations.add(item);
              
              totalSpend = currencyLevelCalculator.getFormattedCurrency(totalSpendAmount);
          }
  
          return JSON.serialize(PickUpLocations);
  
      }
      
      public static String getClickCollectCases () {
  
          List<Case> todaysClickCollectCases = [SELECT Id, SuppliedName,SuppliedPhone, SuppliedEmail,Type,Village__c,Mode_of_Transport__c, 
                                          HFS_Collection_Location__c,Service_Guest_ID__c,Service_Guest_Number__c ,Guest_ID_Number_Part__c , Status, Payment_Status__c, Guest_Arrive_at_Collection_Point__c,Guest_Collection_Point_has_changed__c,Total_Bags_at_wrong_Collection_Point__c, Total_Spent_Amount__c, Country_of_residence__c,
                                          HFS_Click_And_Collect__c, HFS_Collection_Date__c, Total_Bags_of_the_Guest__c
                                          FROM Case WHERE Service_Date__c = TODAY AND Village__r.Name =:userVillage AND HFS_Click_And_Collect__c = true ORDER BY CreatedDate DESC];
          
          List<Case_Item__c> caseitems = [SELECT Status__c, Item_Count__c,Case__c FROM Case_Item__c WHERE Case__c in :todaysClickCollectCases];
  
  
          List<Case_Item__c> pendingPurchasesToCollect = [SELECT Estimated_Spend__c, Bags_in_Storage_Location__c FROM Case_Item__c 
                                                          WHERE Case__r.Village__r.Name =:userVillage AND Case__r.HFS_Click_And_Collect__c = true AND (NOT Case__r.Status IN ('Did Not Participate', 'Closed'))];
  
          List<AggregateResult> todaysCollectionsTotals = [SELECT SUM(Total_Bags_of_the_Guest__c) totalBags, SUM(Total_Spent_Amount__c) totalSpend, COUNT(Id) totalCount FROM Case
                                                           WHERE Village__r.Name =:userVillage AND HFS_Click_And_Collect__c = true AND Experience_Close__c = TODAY];
          
          List<Case_Item__c> todaysPurchases = [SELECT Village_Presence__r.Brand__r.Name, Estimated_Spend__c, Total_Bags__c from Case_Item__c
                                                          where case__c in :todaysClickCollectCases];
  
          
          ClickCollectSummaryDetails clickCollectCaseDetails = new ClickCollectSummaryDetails();
          
          Map <String, BrandAggregate> purchaseDetailsMap = new Map <String, BrandAggregate> ();
  
          for (Case_Item__c purchase : todaysPurchases) {
              BrandAggregate brandAggregateDetails;
              if (purchaseDetailsMap.containsKey(purchase.Village_Presence__r.Brand__r.Name)) {
                  brandAggregateDetails = purchaseDetailsMap.get(purchase.Village_Presence__r.Brand__r.Name);
              } else {
                  brandAggregateDetails = new BrandAggregate ();
                  brandAggregateDetails.brandName = purchase.Village_Presence__r.Brand__r.Name;
                  purchaseDetailsMap.put(purchase.Village_Presence__r.Brand__r.Name,brandAggregateDetails);
              }
              brandAggregateDetails.totalBrandBags += purchase.Total_Bags__c;
              brandAggregateDetails.totalBrandBagsValueNumeric += purchase.Estimated_Spend__c;
              brandAggregateDetails.totalBrandBagsValue = currencyLevelCalculator.getFormattedCurrency(brandAggregateDetails.totalBrandBagsValueNumeric);
          }
  
          Decimal pendingAmount = 0;
  
          for (Case_Item__c purchase : pendingPurchasesToCollect) {
              if (purchase.Bags_in_Storage_Location__c != 0) {
                  clickCollectCaseDetails.totalGuestsPendingCollect++;
                  clickCollectCaseDetails.totalBagsPendingCollect += purchase.Bags_in_Storage_Location__c;
                  pendingAmount += purchase.Estimated_Spend__c;
              }
          }
  
          clickCollectCaseDetails.totalValueBagsPendingCollect = currencyLevelCalculator.getFormattedCurrency(pendingAmount);
  
          Decimal todaySpent = 0;
          clickCollectCaseDetails.brandsData = purchaseDetailsMap.values();
  
          for (Case todaysClickCollectCase : todaysClickCollectCases) {
              clickCollectCaseDetails.totalBagsToday += todaysClickCollectCase.Total_Bags_of_the_Guest__c;
              todaySpent += todaysClickCollectCase.Total_Spent_Amount__c;
  
              CaseDashItem cdi = new CaseDashItem();
              cdi.Id = todaysClickCollectCase.Id;
              cdi.SuppliedName = todaysClickCollectCase.SuppliedName;
              cdi.SuppliedPhone = todaysClickCollectCase.SuppliedPhone;
              cdi.SuppliedEmail = todaysClickCollectCase.SuppliedEmail;
              cdi.Type = todaysClickCollectCase.Type;
              cdi.Village = todaysClickCollectCase.Village__c;
              cdi.Mode_of_Transport = todaysClickCollectCase.Mode_of_Transport__c;
              cdi.HFS_Collection_Location = todaysClickCollectCase.HFS_Collection_Location__c;
              cdi.Service_Guest_ID = todaysClickCollectCase.Service_Guest_ID__c;
              cdi.Service_Guest_Number = todaysClickCollectCase.Service_Guest_Number__c;
              cdi.Guest_ID_Number_Part = String.valueOf(todaysClickCollectCase.Guest_ID_Number_Part__c);
              cdi.Status = todaysClickCollectCase.Status;
              cdi.Payment_Status = todaysClickCollectCase.Payment_Status__c;
              cdi.Guest30minutes = todaysClickCollectCase.Guest_Arrive_at_Collection_Point__c;
              cdi.CollectionPointhaschanged = todaysClickCollectCase.Guest_Collection_Point_has_changed__c;
              cdi.TotalBagsatwrongCollectionPoint = todaysClickCollectCase.Total_Bags_at_wrong_Collection_Point__c;
              cdi.totalSpend = todaysClickCollectCase.Total_Spent_Amount__c.setScale(2);
              cdi.isClickAndCollect = todaysClickCollectCase.HFS_Click_And_Collect__c;
              cdi.collectionDateClickAndCollect = todaysClickCollectCase.HFS_Collection_Date__c;
              cdi.totalSpendFormatted = currencyLevelCalculator.getFormattedCurrency(todaysClickCollectCase.Total_Spent_Amount__c);
  
              HFS_SpentLevel guestLevel = currencyLevelCalculator.getGuestLevel(todaysClickCollectCase.Total_Spent_Amount__c, todaysClickCollectCase.Country_of_residence__c);
              cdi.spendLevel = guestLevel.name();
  
              Integer ItemCount = 0;
              Integer ItemsCollected = 0;
              Integer ItemsAwaiting = 0;
              Integer ItemsBagCount = 0;
              for(Case_Item__c casitem :caseitems){
                  if(casitem.Case__c == todaysClickCollectCase.Id){
                      ItemCount++;
                      if(casitem.Status__c == 'Awaiting Pick-up from Brand' || casitem.Status__c == 'In transit' ){
                          ItemsAwaiting ++;
                      }
                      if(casitem.Status__c == 'Ready for Guest Collection'){
                          ItemsCollected ++;
                      }
                      ItemsBagCount += Integer.valueOf(casitem.Item_Count__c);
                  }
              }
              cdi.ItemCount = String.valueOf(ItemCount);
              cdi.ItemsCollected = String.valueOf(ItemsCollected);
              cdi.ItemsAwaiting = String.valueOf(ItemsAwaiting);
              cdi.ItemsBagCount = String.valueOf(ItemsBagCount);
  
              clickCollectCaseDetails.clickCollectCases.add(cdi);
          }
  
          clickCollectCaseDetails.totalValueBagsToday = currencyLevelCalculator.getFormattedCurrency(todaySpent);
  
          clickCollectCaseDetails.totalCasesToday = todaysClickCollectCases.size();
  
          clickCollectCaseDetails.totalGuestsCollected = (Integer)todaysCollectionsTotals.get(0).get('totalCount');
          clickCollectCaseDetails.totalBagsCollected = todaysCollectionsTotals.get(0).get('totalBags') != null ? (Decimal)todaysCollectionsTotals.get(0).get('totalBags') : 0;
          clickCollectCaseDetails.totalValueBagsCollected = todaysCollectionsTotals.get(0).get('totalSpend') != null ? currencyLevelCalculator.getFormattedCurrency((Decimal)todaysCollectionsTotals.get(0).get('totalSpend')) : currencyLevelCalculator.getFormattedCurrency(0);
  
  
          return JSON.serialize(clickCollectCaseDetails);
  
      } 
  
      @RemoteAction
      global static List<String> searchGuestID(String guestID, String village){        
              
          List <String> id_Guest = new List <String>();
  
          String j= guestID+'%';     
          List <Case> searchID = new List <Case>();
          Date nowDate = system.today();
  
  
          if( guestID.length() < 4){
             searchID = [SELECT Service_Guest_Number__c FROM Case WHERE village__r.Name = :village AND  Service_Guest_Number__c LIKE :j AND Service_Date__c = :nowDate ];
     
          }
  
          for (Integer i = 0; i <  searchID.size() ; i++) {
              id_Guest.add(searchID[i].Service_Guest_Number__c);
          }
  
          System.debug('VillageX: ' + id_Guest);        
  
          return id_Guest;
      }
  
  
      @RemoteAction
      global static String getlocations(String message){
          Date nowDate = system.today();
          Case guestCase = [SELECT Id FROM Case WHERE Client_QR_Code__c = :message AND Service_Date__c = :nowDate];
          system.debug(guestCase.Id);
          return guestCase.Id;
      }
  
      @RemoteAction
      global static String goToGuestPage(String message){
          Date nowDate = system.today();
          Case guestCase = [SELECT Id FROM Case WHERE Service_Guest_Number__c = :message AND Service_Date__c = :nowDate];
          system.debug(guestCase.Id);
          return guestCase.Id;
      }
      
      @RemoteAction
      global static String saveReplenishments(String vpArray){
        system.debug('vpArray : ' + vpArray);
        List<vpJSON> vpJSONList = (List<vpJSON>)JSON.deserialize(vpArray, List<vpJSON>.Class);
        system.debug('vpJSONList : ' + vpJSONList);
        
        set<string> vpIdSet = new set<string>();
        for(vpJSON vp : vpJSONList){
          vpIdSet.add(vp.id);        
        }
        
        List<village_presence__c> vpList = [SELECT Id, name,HFS_Threshold__c,HFS_Bags_Received__c FROM Village_Presence__c WHERE id IN:vpIdSet];
        
        map<id, village_presence__c> vpMap = new map<id, village_presence__c>();
        
        for(village_presence__c vp : vpList){
          vpMap.put(vp.id, vp);        
        }
        
        
        try{
        list<village_presence__c> vpUpdates = new list<village_presence__c>();
        for(vpJSON vp : vpJSONList){
          
              boolean isChanged = false;
              
             village_presence__c thevp = (village_presence__c)vpMap.get(vp.id);
               system.debug('thevp : ' + thevp);
              system.debug('integer.valueof(vp.Threshold) : ' + integer.valueof(vp.Threshold));
              system.debug('thevp.HFS_Threshold__c : ' + thevp.HFS_Threshold__c);
              system.debug(thevp.HFS_Threshold__c == integer.valueof(vp.Threshold) );
      
              if(theVP.HFS_Threshold__c != integer.valueof(vp.Threshold)){
            system.debug('entered 1');
                  thevp.HFS_Threshold__c = integer.valueof(vp.Threshold);
                  isChanged = true;
                  
              }
              
              if(thevp.HFS_Bags_Received__c + integer.valueof(vp.bagsToAdd) != thevp.HFS_Bags_Received__c ){
                  system.debug('entered 2');
             thevp.HFS_Bags_Received__c = thevp.HFS_Bags_Received__c + integer.valueof(vp.bagsToAdd);
                  isChanged = true;
                  
              }
            system.debug('isChanged : ' + isChanged);
              if(isChanged){ 
          vpUpdates.add(thevp);
              }
        }
              system.debug('the vpUpdates : ' + vpUpdates);
              if(vpUpdates.size() > 0){
                  update vpUpdates;
                  return 'Success';
              }
              else{
                  return 'You have not made any changes, please edit some fields';
              }
          
          
        }
        catch (exception e){
          system.debug(' e --- ' + e);
          return 'An error occured, please send this to your administrator ' + e.getmessage();        
        }
      //return 'Success';
      }
  
      public class ClickCollectSummaryDetails {
  
          public Integer totalCasesToday = 0;
          public Decimal totalBagsToday = 0;
          public String totalValueBagsToday = '0';
  
          public Integer totalGuestsCollected = 0;
          public Decimal totalBagsCollected = 0;
          public String totalValueBagsCollected = '0';
  
          public Integer totalGuestsPendingCollect = 0;
          public Decimal totalBagsPendingCollect = 0;
          public String totalValueBagsPendingCollect = '0';
          
          public List<CaseDashItem> clickCollectCases = new List<CaseDashItem> ();
          public List<BrandAggregate> brandsData = new List<BrandAggregate> ();
      }
  
      public class BrandAggregate {
  
          public String brandName = '';
          public String totalBrandBagsValue = '0';
          public Decimal totalBrandBags = 0;
          public Decimal totalBrandBagsValueNumeric = 0;
  
      }
      
      
      global class vpJSON{
        public string id {get;set;}
        public string Threshold {get;set;}
        public string bagsToAdd {get;set;}
      }
  
      
      global class hfsSummary{
          
          global hfsSummary(){
              this.closed = '';
              this.statusnew = '';
              this.shopping = '';
              this.didNotParticipate = '';
              this.total = '';
          }
  
          public string closed {get; private set;}
          public string statusnew {get; private set;}
          public string shopping {get; set;}
          public string didNotParticipate {get; set;}
          public string total {get; set;}
      }
  
  }