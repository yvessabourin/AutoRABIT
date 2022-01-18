@isTest
public class transferRedmptionsBatchableTest {
    
     public static Account account = new Account();
     public static Account account2 = new Account();
     public static Marketing_Activity__C MA = new Marketing_Activity__C();
     public static Marketing_Campaign__C MC = new Marketing_Campaign__C();
     public static Village__c village = new Village__c();
     public static Village__c village2 = new Village__c();
     public static User usr = new User();
     public static Contact contact = new Contact();
       
    @testSetup static void setupdata(){
      
        UserRole r = [SELECT id FROM UserRole WHERE Name = 'CEO'];     
        Profile Profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Usr.LastName = 'TEST';
        USr.FirstName = 'TESTY';
        Usr.Alias = 'TESTTEST';
        Usr.Username = 'dan08978stest@test.com';
        Usr.Email = 'dans08978test@test.com';
        Usr.CommunityNickname = 'Test';
        Usr.Title = 'Senior Dev';
        Usr.Village__c = 'TestVillage1';
        usr.UserRoleId = r.id;
        Usr.ProfileId = Profile.id;
        Usr.EmailEncodingKey = 'ISO-8859-1';
        Usr.TimeZoneSidKey = 'America/Los_Angeles';
        Usr.LocaleSidKey = 'en_US';
        Usr.LanguageLocaleKey = 'en_US';
        
        insert Usr;
        usr = [SELECT ID FROM User WHERE UserName = 'dan08978stest@test.com'];
     
  }
         
    static testMethod void myTest(){
        
        //create village 1
        village.Name = 'TestVillage1';     
        village.Village_Code__c = 'AA';
        village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert village;
        
        //create village 2
        village2.Name = 'Group';     
        village2.Village_Code__c = '01';
        village2.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village2.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert village2;
        
        LIST<recordtype> actrtid = [SELECT id from Recordtype WHERE Name = 'Partner' AND SobjectType = 'Account'];
        LIST<recordtype> conrtid = [SELECT id from Recordtype WHERE Name = 'Tourism Contact' AND SobjectType = 'Contact'];
        recordtype maRT = [SELECT id from Recordtype WHERE Name = 'Partnership Promotion' AND SobjectType = 'Marketing_Activity__c'];
        //recordtype maRT = [SELECT id from Recordtype WHERE Name = 'Village Partnership Promotion' AND SobjectType = 'Marketing_Activity__c'];
        //recordtype maRT = [SELECT id from Recordtype WHERE Name = 'TBVSC Brand Partnership Promotion' AND SobjectType = 'Marketing_Activity__c'];
        recordtype mcRT = [SELECT id from Recordtype WHERE Name = 'TBVSC Brand Campaign' AND SobjectType = 'Marketing_Campaign__c'];
                       
        //create accounts
      account.name = 'LeadActionsControllerTest';
      account.recordtypeid = actrtid[0].id;
      account.country__c = 'Albania';
      account.Type_of_Business__c = 'Airline';
      insert account;
      
      account2.name = 'LeadActionsControllerTest2';
      account2.recordtypeid = actrtid[0].id;
      account2.country__c = 'Albania';
      account2.Type_of_Business__c = 'Airline';
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account2, dmlOptions); 
      
      contact.FirstName = 'Paul';
      contact.LastName = 'Smith';
      contact.Email = 'paul.smith@valueretail.com';
      contact.Phone = '098786745333';
      insert contact;
        
        date startDate = date.today();
        date endDate = date.today()+1;  
        
        MC.RecordTypeId = mcRT.id;
        MC.Name = 'test Marketing Campaign';
        MC.Short_Description__c = 'short description';
        MC.Campaign_Level__c = 'Tactical';
        MC.Village__c = village2.id;
        MC.Status__c = 'Approved';
        MC.Start_Date__c = startDate;
        MC.End_Date__c = endDate;
        MC.CurrencyIsoCode = 'GBP';
        MC.Responsible__c = Usr.id;
        MC.Accountable_Person__c = Usr.id;
        MC.Proposition__c = 'Test Prop';
        MC.Target_Audience__c = 'Test Target Audience';
        MC.KPI_Targets__c = 'Test KPIs';
        MC.Campaign_Level__c = 'Theme';
        insert MC;
        
        MA.RecordTypeId = maRT.id;
        MA.Name = 'TEST MA';
        MA.Channel__c = 'Community';
        MA.Marketing_Campaign__c = MC.id;
        MA.Status__c = 'To Be Approved';
        MA.Start_Date__c = startDate;
        MA.End_Date__c = endDate;
        MA.Partner_Contact__c = contact.id;
        MA.Responsible_Person__c = Usr.id;
        MA.Accountable1__c = Usr.id;
        MA.Partner__c = account.id;
        insert MA;
                
        recordtype campRT = [SELECT id from Recordtype WHERE Name = 'Redeemable Campaign' AND SobjectType = 'Campaign'];
        
        village__c vill = [SELECT id from Village__C WHERE name = 'TestVillage1'];
                
        date TstartDate = date.today();
        date TendDate = date.today()+1;
        Campaign camp = new Campaign();
        camp.RecordTypeId = campRT.id;
        camp.Name = 'Test Campaign For batch Processing';
        camp.CurrencyIsoCode = 'GBP';
        camp.Villages__c = 'Bicester';
        camp.Village__c = vill.id;
        camp.Redemptions_Transfered__c = 0;
        camp.Communication_Channel__c = 'Email';
        camp.StartDate = TstartDate;
        camp.EndDate = TendDate;
        camp.VIP_2_0_Activity_ID__c = MA.id;
        
        insert camp;     
                
        integer i = 1;
        list<Promotion_Redemption__c> redsToInsert = new list<Promotion_Redemption__c>();
        list<Campaign> campid = [SELECT Id FROM Campaign WHERE NAME LIKE '%Test Campaign For batch Processing' Limit 1 ];
        While(i < 100){
            
           Promotion_Redemption__c reds = new Promotion_Redemption__c();
           reds.Voucher_Code__c = '0000000000'+ i;
           reds.Redeemable_Campaign__c = campid[0].id;
           //DateTime todayDatetest = Datetime.newInstance(2015,6,12,0,0,0); 
           reds.Redeem_Date__c = date.today();
           reds.Has_Been_Transfered__c = False;
           reds.Location__c = 'TIC';
           reds.Mode_of_Transport__c = 'car';
           reds.Visit_Type__c = 'Leisure';
           system.debug(i+' '+reds);
           reds.Country_of_Origin__c = 'United Kingdom';
           
           redsToInsert.add(reds);
           i++;        
            
        }
        insert redsToInsert;
        User testUser = [SELECT ID FROM User WHERE UserName = 'dan08978stest@test.com'];
        insert new ByPass_Triggers__c(SetupOwnerId=testUser.id,ByPass_Triggers__c = true);
        System.runAs(testUser) {        
            
        list<Promotion_Redemption__c> insertedReds = [SELECT id FROM Promotion_Redemption__c WHERE Has_Been_Transfered__C = false AND Redeemable_Campaign__c =:camp.id];    
        //system.assert(insertedReds.size() == 99, 'the Promotion redemptions were not created');
            
        test.startTest();
            DateTime startDatetest = system.today()-1; 
            DateTime endDatetest = system.today()+1;
            transferRedemptionsBatchable myBatchObject = new transferRedemptionsBatchable(camp.id,startDatetest,endDatetest); 
            Id batchId = Database.executeBatch(myBatchObject);    
        test.stopTest();
        }
        
        //list<Promotion_Redemption__c> updatedReds = [SELECT id FROM Promotion_Redemption__c WHERE Has_Been_Transfered__C = true AND Redeemable_Campaign__c =:camp.id];       
        //system.assert(updatedReds.size() == 99, 'the Promotion redemptions were not updated');
        //system.debug('redstoinsert'+redsToInsert.size());
        //system.debug('updatedReds'+updatedReds.size());
        //list<visit__c> insertedvisits = [SELECT id FROM visit__c WHERE Partnership_Promotion__c =:MA.id];
        //system.assert(insertedvisits.size() == 99, 'the visits records were not created');
        //system.debug('visits inserted'+insertedvisits.size());
        //list<VIP_Card_Exchange__c> insertedVIPs = [SELECT id FROM VIP_Card_Exchange__c WHERE visit__c IN :insertedvisits];
        //system.debug('VIP Cards inserted'+insertedVIPs.size());
    }

}