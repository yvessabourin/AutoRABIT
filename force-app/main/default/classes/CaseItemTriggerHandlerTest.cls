@isTest
private class CaseItemTriggerHandlerTest {

    static void setupData(){

        Profile profileRunner = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Runner'];
        Profile profileCoordinator = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Co-ordinator'];

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

        system.runAs(runner){
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
            guestCase.Status = 'New';
            guestCase.Origin = 'Email';
            insert guestCase;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.User__c = runner.Id;
            newRunner.Village__c = 'Bicester';
            insert newRunner;
        }
    }

    static testMethod void createNewJobandBagsTestN1(){
        setupData();
        User runner = [SELECT ID FROM User WHERE Alias = 'jhn'];

        system.runAs(runner){
            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brand = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchaseWithoutRunner = new Case_Item__c();
            hfsPurchaseWithoutRunner.Case__c = newGuest.Id;
            hfsPurchaseWithoutRunner.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchaseWithoutRunner.Start_Time__c = system.now();
            hfsPurchaseWithoutRunner.Item_Count__c = 5;
            hfsPurchaseWithoutRunner.Bag_Barcodes_Manual__c = '0123456,false,0123457,true,0152635,false,01201201,false,023232,false';
            hfsPurchaseWithoutRunner.Require_a_Runner__c = false;
            hfsPurchaseWithoutRunner.Village_Presence__c = brand.Id;
            hfsPurchaseWithoutRunner.HFS_Bag_Drop__c = false;
            hfsPurchaseWithoutRunner.HFS_Bag_Transfer__c = false;

            Test.startTest();
            insert hfsPurchaseWithoutRunner;
            Test.stopTest();

            Case_Item__c hfsPurchase = [SELECT ID, Item_Count__c FROM Case_Item__c WHERE Require_a_Runner__c = false];
            List<HFS_Bag__c> hfsBag = [SELECT ID, HFS_Runner__c FROM HFS_Bag__c WHERE HFS_Purchase__c = :hfsPurchase.Id];
            HFS_Runner__c runnerId = [SELECT ID FROM HFS_Runner__c WHERE User__c = :runner.Id];
            HFS_Job__c theJob = [SELECT ID, Job_Type__c, HFS_Runner__c FROM HFS_Job__c WHERE HFS_Purchase__c = :hfsPurchase.Id];

            system.assertEquals(hfsBag.size(), hfsPurchase.Item_Count__c);
            system.assertEquals(hfsBag[0].HFS_Runner__c, runnerId.Id);
            system.assertEquals(theJob.Job_Type__c, 'Original Pick-up Request');
        }
    }
    
    static testMethod void createNewJobandBagsTestN2(){
        setupData();
        User runner = [SELECT ID FROM User WHERE Alias = 'jhn'];

        system.runAs(runner){
            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brand = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchaseWithoutRunner = new Case_Item__c();
            hfsPurchaseWithoutRunner.Case__c = newGuest.Id;
            hfsPurchaseWithoutRunner.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchaseWithoutRunner.Start_Time__c = system.now();
            hfsPurchaseWithoutRunner.Item_Count__c = 5;
            hfsPurchaseWithoutRunner.Bag_Barcodes_Manual__c = '0123456,false,0123457,true,0152635,false,01201201,false,023232,false';
            hfsPurchaseWithoutRunner.Require_a_Runner__c = false;
            hfsPurchaseWithoutRunner.Village_Presence__c = brand.Id;
            hfsPurchaseWithoutRunner.HFS_Bag_Drop__c = true;
            hfsPurchaseWithoutRunner.HFS_Bag_Transfer__c = false;

            Test.startTest();
            insert hfsPurchaseWithoutRunner;
            Test.stopTest();

            Case_Item__c hfsPurchase = [SELECT ID, Item_Count__c FROM Case_Item__c WHERE Require_a_Runner__c = false];
            List<HFS_Bag__c> hfsBag = [SELECT ID, HFS_Runner__c FROM HFS_Bag__c WHERE HFS_Purchase__c = :hfsPurchase.Id];
            HFS_Runner__c runnerId = [SELECT ID FROM HFS_Runner__c WHERE User__c = :runner.Id];
            HFS_Job__c theJob = [SELECT ID, Job_Type__c, HFS_Runner__c FROM HFS_Job__c WHERE HFS_Purchase__c = :hfsPurchase.Id];

            system.assertEquals(hfsBag.size(), hfsPurchase.Item_Count__c);
            system.assertEquals(hfsBag[0].HFS_Runner__c, runnerId.Id);
            system.assertEquals(theJob.Job_Type__c, 'Bag Drop');
            system.assertEquals(theJob.HFS_Runner__c, runnerId.Id);
        }
    }

    static testMethod void createNewJobandBagsTestN3(){
        setupData();
        User runner = [SELECT ID FROM User WHERE Alias = 'jhn'];

        system.runAs(runner){
            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brand = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchaseWithoutRunner = new Case_Item__c();
            hfsPurchaseWithoutRunner.Case__c = newGuest.Id;
            hfsPurchaseWithoutRunner.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchaseWithoutRunner.Start_Time__c = system.now();
            hfsPurchaseWithoutRunner.Item_Count__c = 5;
            hfsPurchaseWithoutRunner.Bag_Barcodes_Manual__c = '0123456,false,0123457,true,0152635,false,01201201,false,023232,false';
            hfsPurchaseWithoutRunner.Require_a_Runner__c = true;
            hfsPurchaseWithoutRunner.Village_Presence__c = brand.Id;
            hfsPurchaseWithoutRunner.HFS_Bag_Drop__c = true;
            hfsPurchaseWithoutRunner.HFS_Bag_Transfer__c = false;

            Test.startTest();
            insert hfsPurchaseWithoutRunner;
            Test.stopTest();

            Case_Item__c hfsPurchase = [SELECT ID, Item_Count__c FROM Case_Item__c WHERE Require_a_Runner__c = true];
            List<HFS_Bag__c> hfsBag = [SELECT ID, HFS_Runner__c FROM HFS_Bag__c WHERE HFS_Purchase__c = :hfsPurchase.Id];
            HFS_Runner__c runnerId = [SELECT ID FROM HFS_Runner__c WHERE User__c = :runner.Id];
            HFS_Job__c theJob = [SELECT ID, Job_Type__c, HFS_Runner__c FROM HFS_Job__c WHERE HFS_Purchase__c = :hfsPurchase.Id];

            system.assertEquals(hfsBag.size(), hfsPurchase.Item_Count__c);
            system.assertEquals(hfsBag[0].HFS_Runner__c, null);
            system.assertEquals(theJob.Job_Type__c, 'Bag Drop');
            system.assertEquals(theJob.HFS_Runner__c, null);
        }
    }

    static testMethod void createNewJobandBagsTestN4(){
        setupData();
        User runner = [SELECT ID FROM User WHERE Alias = 'jhn'];

        system.runAs(runner){
            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brand = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchaseWithoutRunner = new Case_Item__c();
            hfsPurchaseWithoutRunner.Case__c = newGuest.Id;
            hfsPurchaseWithoutRunner.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchaseWithoutRunner.Start_Time__c = system.now();
            hfsPurchaseWithoutRunner.Require_a_Runner__c = true;
            hfsPurchaseWithoutRunner.Village_Presence__c = brand.Id;
            hfsPurchaseWithoutRunner.HFS_Bag_Drop__c = false;
            hfsPurchaseWithoutRunner.HFS_Bag_Transfer__c = true;

            Test.startTest();
            insert hfsPurchaseWithoutRunner;
            Test.stopTest();

            Case_Item__c hfsPurchase = [SELECT ID, Item_Count__c FROM Case_Item__c WHERE Require_a_Runner__c = true];
            List<HFS_Bag__c> hfsBag = [SELECT ID, HFS_Runner__c FROM HFS_Bag__c WHERE HFS_Purchase__c = :hfsPurchase.Id];
            HFS_Runner__c runnerId = [SELECT ID FROM HFS_Runner__c WHERE User__c = :runner.Id];
            HFS_Job__c theJob = [SELECT ID, Job_Type__c, HFS_Runner__c FROM HFS_Job__c WHERE HFS_Purchase__c = :hfsPurchase.Id];

            system.assertEquals(hfsBag.size(), 0);
            system.assertEquals(theJob.Job_Type__c, 'Bag Transfer');
            system.assertEquals(theJob.HFS_Runner__c, null);
        }
    }
}