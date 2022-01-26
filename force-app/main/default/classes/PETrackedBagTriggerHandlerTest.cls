@isTest
public class PETrackedBagTriggerHandlerTest {

  public static void setupData(){

        Profile profileRunner = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Runner'];

        UserRole runnerRole = new UserRole();
        runnerRole.DeveloperName = 'CustomRole';
        runnerRole.Name = 'Custom Role';
        insert runnerRole;

        User runner = new User();
        runner.LastName = 'John';
        runner.Alias = 'jhn';
        runner.Email = 'john@valueretai.com';
        runner.Username = 'john@valueretai.com';
        runner.CommunityNickname = 'johnvr';
        runner.UserRoleId = runnerRole.Id;
        runner.ProfileId = profileRunner.Id;
        runner.Village__c = 'Bicester';
        runner.TimeZoneSidKey = 'GMT';
        runner.LocaleSidKey = 'en_GB';
        runner.EmailEncodingKey = 'ISO-8859-1';
        runner.LanguageLocaleKey = 'en_US';
        insert runner;

        system.runAs(runner){
        // first create a village

          Logging_Enabled__c test = new Logging_Enabled__c();
          test.Name = 'PETrackedBagTriggerHandler';
          insert test;

          Village__c vill = TestDataGenerator.setupVillage(false);
          vill.Oracle_Source_Template_Number__c = '123456';
          vill.Oracle_Organisation__c = 'SourceOrg';
          vill.Name = 'Bicester';
          vill.village_code__c = 'BV';
		  vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		  vill.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
          insert vill;

          RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
          RecordType guestRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];

          Account brand = new Account();
          brand.RecordTypeId = brandRecordType.Id;
          brand.Name = 'Brand 1';
          insert brand;

          Village_Presence__c presentBrand = new Village_Presence__c();
          presentBrand.Name = 'Brand1 in village';
          presentBrand.Brand__c = brand.Id;
          presentBrand.Village__c = vill.Id;
          presentBrand.Lease_ID__c = 'BRAND1BIC';
          insert presentBrand;

          Case guestCase = new Case();
          guestCase.Village__c = vill.Id;
          guestCase.Service_Guest_ID__c = '11111';
          guestCase.Service_Guest_Number__c = 'XA1';
          guestCase.Guest_ID_Number_Part__c = 12;
          guestCase.Payment_Status__c = 'Paid';
          guestCase.Client_QR_Code__c = '22222';
          guestCase.Status = 'New';
          guestCase.Origin = 'Email';
          guestCase.Service_Date__c = system.today();
          insert guestCase;
      }
    }

    static testMethod void PETrackedBagCreatePurchase(){
        setupData();

        String json = '[{\"barcode__c\": 1772664829,\"oversize__c\": false},{\"barcode__c\": 1772664828,\"oversize__c\": true},{\"barcode__c\": 1772664827,\"oversize__c\": false }]';
        //JSON2Apex obj = JSON2Apex.parse(json);
        
        Tracked_Bag__e newTrackedBag = new Tracked_Bag__e(lease_id__c = 'BRAND1BIC',
                                                          brand_location_name__c = 'Brand1 in village',
                                                          txn_datetime_utc__c = system.now(),
                                                          estimated_spend__c = 510.50,
                                                          guest_barcode__c = '22222',
                                                          hfsbags_list__c = json,
                                                          numberofbags__c = 3);

        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(newTrackedBag);
        
        Test.stopTest();
        
        Case theCase = [SELECT Id FROM Case WHERE Client_QR_Code__c = '22222'];
        List<Case_Item__c> purchases = [SELECT Id, Case__c FROM Case_Item__c];
        List<HFS_Bag__c> theBags = [SELECT Id FROM HFS_Bag__c];
        
        system.assertEquals(1, purchases.size());
        system.assertEquals(theCase.Id, purchases[0].Case__c);
        system.assertEquals(newTrackedBag.numberofbags__c, theBags.size());
    }

    static testMethod void PETrackedBagHandlingErros(){
        setupData();

        String json = '[{\"barcode__c\": 1772664829,\"oversize__c\": false},{\"barcode__c\": 1772664828,\"oversize__c\": true},{\"barcode__c\": 1772664827,\"oversize__c\": false }]';
        //JSON2Apex obj = JSON2Apex.parse(json);
        
        Tracked_Bag__e newTrackedBag = new Tracked_Bag__e(lease_id__c = '0000000',
                                                          brand_location_name__c = 'Brand1 in village',
                                                          txn_datetime_utc__c = system.now(),
                                                          estimated_spend__c = 510.50,
                                                          guest_barcode__c = '22000',
                                                          hfsbags_list__c = json,
                                                          numberofbags__c = 3);

        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(newTrackedBag);
        
        Test.stopTest();

        List<Case_Item__c> purchases = [SELECT Id, Case__c FROM Case_Item__c];
        List<HFS_Bag__c> theBags = [SELECT Id FROM HFS_Bag__c];
        
        system.assertEquals(0, purchases.size());
        system.assertEquals(0, theBags.size());
    }

    static testMethod void PETrackedBagHandlingBagsErros(){
        setupData();

        String json = '[{\"barcode__c\": 123456,\"oversize__c\": false},{\"barcode__c\": 1000,\"oversize__c\": true},{\"barcode__c\": 10120,\"oversize__c\": false }]';
        //JSON2Apex obj = JSON2Apex.parse(json);
        User john = [SELECT Id FROM User WHERE Alias='jhn'];
        Village_Presence__c brand = [SELECT Id FROM Village_Presence__c];
        Case caseItem = [SELECT Id FROM Case];

        system.runAs(john){
          Case_Item__c hfsPurchase = new Case_Item__c();
          hfsPurchase.Case__c = caseItem.Id;
          hfsPurchase.Village_Presence__c = brand.Id;
          hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
          hfsPurchase.Start_Time__c = system.now();
          hfsPurchase.Item_Count__c = 3;
          hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
          hfsPurchase.Require_a_Runner__c = TRUE;
          hfsPurchase.HFS_Bag_Transfer__c = FALSE;
          insert hfsPurchase;
        }

        Tracked_Bag__e newTrackedBag = new Tracked_Bag__e(lease_id__c = 'BRAND1BIC',
                                                          brand_location_name__c = 'Brand1 in village',
                                                          txn_datetime_utc__c = system.now(),
                                                          estimated_spend__c = 510.50,
                                                          guest_barcode__c = '22222',
                                                          hfsbags_list__c = json,
                                                          numberofbags__c = 3);

        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(newTrackedBag);
        
        Test.stopTest();

        Case theCase = [SELECT Id FROM Case WHERE Client_QR_Code__c = '22222'];
        List<Case_Item__c> purchases = [SELECT Id, Case__c FROM Case_Item__c];
        List<HFS_Bag__c> theBags = [SELECT Id FROM HFS_Bag__c];
        
        system.assertEquals(1, purchases.size());
        system.assertEquals(3, theBags.size());
    }
}