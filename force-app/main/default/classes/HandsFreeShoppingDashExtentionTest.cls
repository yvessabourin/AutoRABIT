@isTest
public class HandsFreeShoppingDashExtentionTest{

    static void setupData(){

        Profile profileRunner = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Runner'];
        Profile profileCoordinator = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Co-ordinator'];
        Profile profileHost = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Co-ordinator'];

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

        User coordinator = new User();
        coordinator.LastName = 'Paul';
        coordinator.Alias = 'pal';
        coordinator.Email = 'paul@valueretai.com';
        coordinator.Username = 'paul@valueretai.com';
        coordinator.CommunityNickname = 'paulas';
        coordinator.UserRoleId = runnerRole.Id;
        coordinator.ProfileId = profileCoordinator.Id;
        coordinator.Village__c = 'Bicester';
        coordinator.TimeZoneSidKey = 'GMT';
        coordinator.LocaleSidKey = 'en_GB';
        coordinator.EmailEncodingKey = 'ISO-8859-1';
        coordinator.LanguageLocaleKey = 'en_US';
        insert coordinator;

        User host = new User();
        host.LastName = 'HostPaul';
        host.Alias = 'hpal';
        host.Email = 'Hostpaul@valueretai.com';
        host.Username = 'Hostpaul@valueretai.com';
        host.CommunityNickname = 'hpaulas';
        host.UserRoleId = runnerRole.Id;
        host.ProfileId = profileCoordinator.Id;
        host.Village__c = 'Bicester';
        host.TimeZoneSidKey = 'GMT';
        host.LocaleSidKey = 'en_GB';
        host.EmailEncodingKey = 'ISO-8859-1';
        host.LanguageLocaleKey = 'en_US';
        insert host;

        system.runAs(coordinator){
            // first create a village
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
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
            insert presentBrand;

            Case guestCase = new Case();
            guestCase.Village__c = vill.Id;
            guestCase.Service_Guest_ID__c = '123456789';
            guestCase.Service_Guest_Number__c = 'XA1';
            guestCase.Guest_ID_Number_Part__c = 12;
            guestCase.Payment_Status__c = 'Paid';
            guestCase.Client_QR_Code__c = '123456789';
            guestCase.HFS_Collection_Location__c = 'Apartment';
            guestCase.Status = 'New';
            guestCase.Origin = 'Email';
            guestCase.Type = 'Hands Free Shopping';
            guestCase.Service_Date__c = system.today();
            insert guestCase;

            Case pendingCase = new Case();
            pendingCase.Village__c = vill.Id;
            pendingCase.Service_Guest_ID__c = '023456789';
            pendingCase.Service_Guest_Number__c = 'XA1';
            pendingCase.Guest_ID_Number_Part__c = 12;
            pendingCase.Payment_Status__c = 'Paid';
            pendingCase.Client_QR_Code__c = '023456789';
            pendingCase.Status = 'New';
            pendingCase.Origin = 'Email';
            pendingCase.Service_Date__c = system.today() - 1;
            insert pendingCase;
            
            HFS_IntegrationErrorTrackedBag__c IE = new HFS_IntegrationErrorTrackedBag__c();
            IE.Action_Taken__c = 'test';
            IE.Brand_Lease_Id__c = 'TEST123';
            IE.Brand_Location_Name__c = 'Test Brand';
            DateTime theDate = DateTime.newInstanceGMT(2020, 1,4, 0,0,0);
            IE.DateTime__c = theDate;
            IE.Error_Category__c = 'System Error';
            IE.List_of_Bags__c = '[{"oversized__c":false,"barcode__c":"001100177"}]';
            IE.Number_of_Bags__c = 1;
            IE.Is_Resolved__c = false;
            IE.Requires_Technical_Support__c = false;
            insert IE;        
               
            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brandS = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];


            Case_Item__c hfsPurchase = new Case_Item__c();
            hfsPurchase.Case__c = guestCase.Id;
            hfsPurchase.Village_Presence__c = brandS.Id;
            hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchase.Start_Time__c = system.now();
            hfsPurchase.Item_Count__c = 3;
            hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
            hfsPurchase.Require_a_Runner__c = TRUE;
            insert hfsPurchase;

            Case_Item__c hfsPurchase2 = new Case_Item__c();
            hfsPurchase2.Case__c = guestCase.Id;
            hfsPurchase2.Village_Presence__c = brandS.Id;
            hfsPurchase2.Status__c = 'Ready for Guest Collection';
            hfsPurchase2.Start_Time__c = system.now();
            hfsPurchase2.Item_Count__c = 3;
            hfsPurchase2.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
            hfsPurchase2.Require_a_Runner__c = TRUE;
            insert hfsPurchase2;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.Village__c = 'Bicester';
            newRunner.User__c = runner.Id;
            insert newRunner;


            Guest_Services_Data__c serviceData = new Guest_Services_Data__c();
            serviceData.Data_Code__c = 'A';
            serviceData.Data_Label__c = 'Apartment';
            serviceData.Village__c = 'Bicester';
            serviceData.Service_Data_Type__c = 'HFS Collection Location';
            insert serviceData;

        }
    }
    
     static testMethod void techSupportRequiredTest(){
         setupData();
         
         HFS_IntegrationErrorTrackedBag__c IE = [SELECT Id, Name FROM HFS_IntegrationErrorTrackedBag__c LIMIT 1];
           
         Date nowDate = system.today()-1;
         User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];         
         Case guestCase = [SELECT ID FROM Case WHERE Service_Date__c = :nowDate ];
       
         system.runAs(hfsCoordinator){
         Test.startTest();
         
         ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
         HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);
         
         // string startdate, string enddate,string actionedValue, string techSupportreqd)
             
         String allerrors = HandsFreeShoppingDashExtention.techSupportRequired(IE.Id);
         
         Test.stopTest();
         
         System.assertNotEquals(null, allerrors);
         
         }
         
         
     }
    
    static testMethod void resolveIntegrationErrorTest(){
         setupData();
         
         HFS_IntegrationErrorTrackedBag__c IE = [SELECT Id, Name FROM HFS_IntegrationErrorTrackedBag__c LIMIT 1];
           
         Date nowDate = system.today()-1;
         User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];         
         Case guestCase = [SELECT ID FROM Case WHERE Service_Date__c = :nowDate ];
       
         system.runAs(hfsCoordinator){
         Test.startTest();
         
         ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
         HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);
         
         // string startdate, string enddate,string actionedValue, string techSupportreqd)
             
         String allerrors = HandsFreeShoppingDashExtention.resolveIntegrationError(IE.Id);
         
         Test.stopTest();
         
         System.assertNotEquals(null, allerrors);
         
         }
         
         
     }
    
    
     static testMethod void filterErrorsTest(){
         setupData();
         
         Date nowDate = system.today()-1;
         Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
         User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
         Case guestCase = [SELECT ID FROM Case WHERE Service_Date__c = :nowDate ];
       
          system.runAs(hfsCoordinator){
          Test.startTest();
         
          ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);
         
        // string startdate, string enddate,string actionedValue, string techSupportreqd)
             
          String allerrors = HandsFreeShoppingDashExtention.filterErrors('2020-02-01', '2020-01-01' , 'Yes','Yes');
         
         Test.stopTest();
         
         System.assertNotEquals(null, allerrors);
          }
         
     }

    static testMethod void getUsersVillageTest(){
        setupData();

        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
              
        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;

        Date nowDate = system.today()-1;
        Case guestCase = [SELECT ID FROM Case WHERE Service_Date__c = :nowDate ];

        string res = '';

        system.runAs(hfsCoordinator){
            Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);

            String allCases = HandsFreeShoppingDashExtention.getCases();

            Test.stopTest();

        System.assertNotEquals(null, allCases);
        }
    }

    static testMethod void getlocationsTest(){
        setupData();

        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];

        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;

        Date nowDate = system.today();
        Case guestCase = [SELECT ID, Client_QR_Code__c FROM Case WHERE Service_Date__c = :nowDate] ;
        system.debug(guestCase);

        string res = '';

        system.runAs(hfsCoordinator){
            Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);

            String getCase = HandsFreeShoppingDashExtention.getlocations('123456789');

            Test.stopTest();

        Case aCase = [SELECT Id FROM Case WHERE Client_QR_Code__c = '123456789'];
        System.assertEquals(aCase.Id, getCase);
        }
    }

    static testMethod void searchGuestIDtest(){
        setupData();
        
        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];      
        
        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;

        Date nowDate = system.today();
        Case guestCase = [SELECT ID, Client_QR_Code__c FROM Case WHERE Service_Date__c = :nowDate ] ;

        string res = '';

        system.runAs(hfsCoordinator){
            Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);

            List<String> getTheCase = HandsFreeShoppingDashExtention.searchGuestID('XA1','Bicester');

            Test.stopTest();

        List<Case> aCase = [SELECT Id, Service_Guest_Number__c FROM Case WHERE Service_Guest_Number__c = 'XA1' AND Service_Date__c = :nowDate];
        List<String> stringCase = new List<String>();
        for(Case oneCase : aCase){
            stringCase.add(oneCase.Service_Guest_Number__c);
        }
        System.assertEquals(stringCase, getTheCase);
        }
    }

    static testMethod void goToGuestPageTest(){
        setupData();
        
        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];      
        
        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;

        Date nowDate = system.today();
        Case guestCase = [SELECT ID, Client_QR_Code__c FROM Case WHERE Service_Date__c = :nowDate ] ;

        string res = '';

        system.runAs(hfsCoordinator){
            Test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);

            String getCase = HandsFreeShoppingDashExtention.goToGuestPage('XA1');

            Test.stopTest();

        Case aCase = [SELECT Id FROM Case WHERE Service_Guest_Number__c = 'XA1' AND Service_Date__c = :nowDate];
        System.assertEquals(aCase.Id, getCase);
        }
    }
    
    static testMethod void getErrorsTest(){
        
        setupData();
        
        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];      
        
        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;

        Date nowDate = system.today();
        Case guestCase = [SELECT ID, Client_QR_Code__c FROM Case WHERE Service_Date__c = :nowDate ] ;

        string res = '';
         system.runAs(hfsCoordinator){
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
        HandsFreeShoppingDashExtention hFSDext = new HandsFreeShoppingDashExtention(sc);
        HandsFreeShoppingDashExtention.getErrors();
        Test.stopTest();
         }
        
    }
    
}