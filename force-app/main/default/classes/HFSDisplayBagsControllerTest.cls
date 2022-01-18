@isTest
public class HFSDisplayBagsControllerTest {

    static void setupData(){

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

            HFS_Runner__c runnerRecord = new HFS_Runner__c();
            runnerRecord.Name = 'John';
            runnerRecord.Village__c = 'Bicester';
            runnerRecord.User__c = runner.Id;
            insert runnerRecord;

            Case guestCase = new Case();
            guestCase.Village__c = vill.Id;
            guestCase.Service_Guest_ID__c = '123456789';
            guestCase.Service_Guest_Number__c = 'XA1';
            guestCase.Guest_ID_Number_Part__c = 12;
            guestCase.Payment_Status__c = 'Paid';
            guestCase.Client_QR_Code__c = '123456789';
            guestCase.Status = 'New';
            guestCase.Origin = 'Email';
            guestCase.Service_Date__c = system.today();
            insert guestCase;

            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];

            Case_Item__c hfsPurchase = new Case_Item__c();
            hfsPurchase.Case__c = guestCase.Id;
            hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchase.Start_Time__c = system.now();
            hfsPurchase.Item_Count__c = 3;
            hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
            hfsPurchase.Require_a_Runner__c = true;
            hfsPurchase.HFS_Bag_Transfer__c = false;
            hfsPurchase.Village_Presence__c = presentBrand.Id;
            insert hfsPurchase;

            HFS_Job__c jobAssigned = [SELECT Id, HFS_Runner__c, HFS_Purchase__c FROM HFS_Job__c WHERE HFS_Purchase__c =: hfsPurchase.Id];
            jobAssigned.HFS_Runner__c = runnerRecord.Id;
            jobAssigned.Take_job_for_me__c = true;
            update jobAssigned;
        }
    }

    static testMethod void getBagsMethodTestN1(){
        setupData();

        HFS_Job__c purchaseJob = [SELECT Id FROM HFS_Job__c WHERE HFS_Purchase__r.Item_Count__c = 3];
        User userRunner = [SELECT Id FROM User WHERE Name = 'John'];

        System.runAs(userRunner){
            Test.startTest();
                PageReference pageRef = Page.HFSDisplayBags;
                Test.setCurrentPage(pageRef);
                
                pageRef.getParameters().put('id', purchaseJob.Id);
                pageRef.getParameters().put('barcodeBag', '123000');
                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseJob);
                HFSDisplayBagsController controller = new HFSDisplayBagsController(sc);
                controller.updateBags();
                controller.finishJob();
            Test.stopTest();

            System.assertEquals(null, controller.finishJob());
        }
    }

    static testMethod void getBagsMethodTestN2(){
        setupData();

        
        User userRunner = [SELECT Id FROM User WHERE Name = 'John'];

        System.runAs(userRunner){
            HFS_Job__c purchaseJob = [SELECT Id, Total_Bags__c, HFS_Runner__c, Assigned_to_me__c, Take_job_for_me__c, Bags_collected__c FROM HFS_Job__c WHERE HFS_Purchase__r.Item_Count__c = 3];
            Test.startTest();
                PageReference pageRef = Page.HFSDisplayBags;
                Test.setCurrentPage(pageRef);
                
                pageRef.getParameters().put('id', purchaseJob.Id);
                pageRef.getParameters().put('barcodeBag', '123456');
                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseJob);
                HFSDisplayBagsController controller = new HFSDisplayBagsController(sc);
                system.debug('pep ' + purchaseJob);
                controller.updateBags();
                controller.scanBag();
                controller.finishJob();
            Test.stopTest();

            List<HFS_Job__c> thePurchaseJob = [SELECT Id, Job_Status__c, Job_Type__c FROM HFS_Job__c WHERE HFS_Purchase__r.Item_Count__c = 3];
            HFS_Bag__c theBag = [SELECT Id, Status__c, Scanned__c, HFS_Runner__c, HFS_Job__c FROM HFS_Bag__c WHERE Barcode__c = '123456'];
            HFS_Runner__c theRunner = [SELECT Id FROM HFS_Runner__c WHERE User__c = :userRunner.Id];

            System.assertNotEquals(null, controller.scanBag());
            System.assertEquals('In Transit', theBag.Status__c);
            System.assertEquals(true, theBag.Scanned__c);
            System.assertEquals(theRunner.Id, theBag.HFS_Runner__c);
            System.assertEquals(2, thePurchaseJob.size());
            System.assertNotEquals(purchaseJob.Total_Bags__c, purchaseJob.Bags_collected__c);
        }
    }

    static testMethod void getBagsMethodTestN3(){
        setupData();

        Case_Item__c purchaseId = [SELECT Id FROM Case_Item__c WHERE Item_Count__c = 3];
        HFS_Job__c purchaseJob = [SELECT Id, Total_Bags__c, Bags_collected__c FROM HFS_Job__c WHERE HFS_Purchase__c = :purchaseId.Id];
        User userRunner = [SELECT Id FROM User WHERE Name = 'John'];

        System.runAs(userRunner){
            HFS_Bag__c newTBCBag = new HFS_Bag__c();
            newTBCBag.Barcode__c = 'TBC';
            newTBCBag.HFS_Purchase__c = purchaseId.Id;
            insert newTBCBag;

            Test.startTest();
                PageReference pageRef = Page.HFSDisplayBags;
                Test.setCurrentPage(pageRef);
                
                pageRef.getParameters().put('id', purchaseJob.Id);
                pageRef.getParameters().put('barcodeBag', '0120302');
                ApexPages.StandardController sc = new ApexPages.StandardController(purchaseJob);
                HFSDisplayBagsController controller = new HFSDisplayBagsController(sc);
                controller.updateBags();
                controller.scanBag();
                controller.finishJob();
            Test.stopTest();

            List<HFS_Job__c> thePurchaseJob = [SELECT Id, Job_Status__c, Job_Type__c FROM HFS_Job__c WHERE HFS_Purchase__c = :purchaseId.Id];
            HFS_Bag__c theBag = [SELECT Id, Status__c, Scanned__c, HFS_Runner__c, HFS_Job__c FROM HFS_Bag__c WHERE Barcode__c = '0120302'];
            HFS_Runner__c theRunner = [SELECT Id FROM HFS_Runner__c WHERE User__c = :userRunner.Id];

            System.assertNotEquals(null, controller.scanBag());
            System.assertEquals('In Transit', theBag.Status__c);
            System.assertEquals(true, theBag.Scanned__c);
            System.assertEquals(theRunner.Id, theBag.HFS_Runner__c);
            System.assertEquals(2, thePurchaseJob.size());
            System.assertNotEquals(purchaseJob.Total_Bags__c, purchaseJob.Bags_collected__c);
        }
    }
}