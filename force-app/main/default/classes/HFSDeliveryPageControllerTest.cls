@isTest
public class HFSDeliveryPageControllerTest {

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

            Case guestCase2 = new Case();
            guestCase2.Village__c = vill.Id;
            guestCase2.Service_Guest_ID__c = '1234567890';
            guestCase2.Service_Guest_Number__c = 'XA1';
            guestCase2.Guest_ID_Number_Part__c = 123;
            guestCase2.Payment_Status__c = 'Paid';
            guestCase2.Client_QR_Code__c = '1234567890';
            guestCase2.Status = 'New';
            guestCase2.Origin = 'Email';
            insert guestCase2;

            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brandS = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchase = new Case_Item__c();
            hfsPurchase.Case__c = guestCase.Id;
            hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchase.Start_Time__c = system.now();
            hfsPurchase.Item_Count__c = 3;
            hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,false,152635,false';
            hfsPurchase.Require_a_Runner__c = true;       // RIC
            hfsPurchase.HFS_Bag_Transfer__c = false;
            hfsPurchase.Village_Presence__c = brandS.Id; //RIC
            insert hfsPurchase;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.Village__c = 'Bicester';
            newRunner.User__c = runner.Id;
            insert newRunner;

            Case_Item__c hfsPurchaseAssigned = new Case_Item__c();
            hfsPurchaseAssigned.Case__c = guestCase2.Id;
            hfsPurchaseAssigned.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchaseAssigned.Start_Time__c = system.now();
            hfsPurchaseAssigned.Item_Count__c = 2;
            hfsPurchaseAssigned.Bag_Barcodes_Manual__c = '1223456,true,1223457,true';
            hfsPurchaseAssigned.Require_a_Runner__c = true;       // RIC
            hfsPurchaseAssigned.HFS_Bag_Transfer__c = false;
            hfsPurchaseAssigned.Village_Presence__c = brandS.Id; //RIC
            insert hfsPurchaseAssigned;

            HFS_Job__c jobAssigned = [SELECT Id, HFS_Runner__c, HFS_Purchase__c FROM HFS_Job__c WHERE HFS_Purchase__c =: hfsPurchaseAssigned.Id];
            jobAssigned.HFS_Runner__c = newRunner.Id;
            jobAssigned.Take_job_for_me__c = true;
            update jobAssigned;

            HFS_Storage_Point__c newSP = new HFS_Storage_Point__c();
            newSP.Name = 'Bicester Village Center';
            newSP.Village__c = 'Bicester';
            insert newSP;

            HFS_Storage_Location__c newSL = new HFS_Storage_Location__c();
            newSL.Name = 'B1';
            newSL.HFS_Storage_Point__c = newSP.Id;
            newSL.Status__c = 'Empty';
            newSL.QR_Code_hidden__c = '123456789';
            insert newSL;
        }
    }

    static testMethod void initialActionStorageLocationMethodTestN1(){
        setupData();

        
        
        User runner = [SELECT Id FROM User WHERE Name = 'John'];
        HFS_Storage_Location__c sl = [SELECT Id, Name, QR_Code_hidden__c FROM HFS_Storage_Location__c];

        system.runAs(runner){
            List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
            Test.startTest();
                PageReference pageRef = Page.HFSDeliveryPage;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('id', job[0].Id);
                pageRef.getParameters().put('qrCodeLocation', sl.QR_Code_hidden__c);
                ApexPages.StandardController sc = new ApexPages.StandardController(job[0]);
                HFSDeliveryPageController controller = new HFSDeliveryPageController(sc);

            Test.stopTest();

            System.assertEquals(sl.Name, controller.getLocationName);
            System.assertEquals(sl.Id, controller.getLocationId);
        }
    }

    static testMethod void initialActionStorageLocationMethodTestN2(){
        setupData();

        User runner = [SELECT Id FROM User WHERE Name = 'John'];
        HFS_Storage_Location__c sl = [SELECT Id, Name FROM HFS_Storage_Location__c];

        system.runAs(runner){
            List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
            Test.startTest();
                PageReference pageRef = Page.HFSDeliveryPage;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('id', job[0].Id);
                pageRef.getParameters().put('StorageLocation', sl.Id);
                ApexPages.StandardController sc = new ApexPages.StandardController(job[0]);
                HFSDeliveryPageController controller = new HFSDeliveryPageController(sc);

            Test.stopTest();

            System.assertEquals(sl.Name, controller.getLocationName);
            System.assertEquals(sl.Id, controller.getLocationId);
        }
    }

    static testMethod void getCurrentBagsMethodTest(){
        setupData();

        
        User runner = [SELECT Id FROM User WHERE Name = 'John'];
        Case_Item__c hfsPurchase = [SELECT Id, Name, Item_Count__c FROM Case_Item__c WHERE Item_Count__c = 2];
        

        system.runAs(runner){
            List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
            List<HFS_Bag__c> relatedBags = [SELECT Barcode__c, In_Storage_Point__c, Oversized__c, HFS_Storage_Location__c, HFS_Job__c FROM HFS_Bag__c WHERE Oversized__c = true];
            HFS_Storage_Location__c sl = [SELECT Id, Name FROM HFS_Storage_Location__c];
            relatedBags[0].HFS_Storage_Location__c = sl.Id;
            update relatedBags;

            Test.startTest();
                PageReference pageRef = Page.HFSDeliveryPage;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('id', job[0].Id);
                ApexPages.StandardController sc = new ApexPages.StandardController(job[0]);
                HFSDeliveryPageController controller = new HFSDeliveryPageController(sc);

            Test.stopTest();

            HFS_Bag__c theBag = [SELECT Id, Name, HFS_Storage_Location__c, HFS_Storage_Location__r.Name FROM HFS_Bag__c WHERE HFS_Purchase__c =: hfsPurchase.Id AND HFS_Storage_Location__c != NULL];
            System.assertEquals(theBag.HFS_Storage_Location__r.Name, controller.getLocationName);
            System.assertEquals(theBag.HFS_Storage_Location__c, controller.getLocationId);
        }
    }

    static testMethod void redirectToScansMethodsTest(){
        setupData();

        List<HFS_Job__c> job = [SELECT Id FROM HFS_Job__c];
        User runner = [SELECT Id FROM User WHERE Name = 'John'];
        HFS_Storage_Location__c sl = [SELECT Id, Name FROM HFS_Storage_Location__c];

        system.runAs(runner){
            Test.startTest();
                PageReference pageRef = Page.HFSDeliveryPage;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('id', job[0].Id);
                ApexPages.StandardController sc = new ApexPages.StandardController(job[0]);
                HFSDeliveryPageController controller = new HFSDeliveryPageController(sc);
                controller.scanLocationCode();

                pageRef.getParameters().put('StorageLocation',sl.Id);
                controller.scanBagsCode();
                controller.updateRecords();

            Test.stopTest();

            System.assertNotEquals(null, controller.scanLocationCode());
            System.assertNotEquals(null, controller.scanBagsCode());
        }
    }

    static testMethod void updateRecordsMethodTestN1(){
        setupData();
        User runner = [SELECT Id FROM User WHERE Name = 'John'];
        


        system.runAs(runner){
                List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
                HFS_Storage_Location__c sl = [SELECT Id, Name FROM HFS_Storage_Location__c];
                List<HFS_Bag__c> allBags = [SELECT Barcode__c, In_Storage_Point__c, Oversized__c, HFS_Storage_Location__c, HFS_Job__c FROM HFS_Bag__c WHERE Oversized__c = true];
                
                Test.startTest();
                PageReference pageRef = Page.HFSDeliveryPage;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('id', job[0].Id);
                pageRef.getParameters().put('barcodeBag', allBags[0].Barcode__c);
                pageRef.getParameters().put('StorageLocation', sl.Id);
                ApexPages.StandardController sc = new ApexPages.StandardController(job[0]);
                HFSDeliveryPageController controller = new HFSDeliveryPageController(sc);
                system.debug('pep ' + job);
                controller.updateRecords();
            Test.stopTest();

            HFS_Bag__c theBag = [SELECT Id, In_Storage_Point__c, HFS_Storage_Location__c FROM HFS_Bag__c WHERE Barcode__c =: allBags[0].Barcode__c];
            HFS_Job__c theJob = [SELECT Id, Job_Status__c FROM HFS_Job__c WHERE ID =: job[0].Id];

            System.assertEquals(true, controller.stopLoopBags);
            System.assertEquals(0, controller.countAllJobBagsInStorage);
            System.assertEquals(false, theBag.In_Storage_Point__c);
            System.assertEquals(null, theBag.HFS_Storage_Location__c);
            System.assertEquals('Bags Putaway', theJob.Job_Status__c);
        }
    }

    static testMethod void updateRecordsMethodTestN2(){
        setupData();

        User runner = [SELECT Id FROM User WHERE Name = 'John'];
        HFS_Runner__c theRunner = [SELECT Id FROM HFS_Runner__c];
        HFS_Storage_Location__c sl = [SELECT Id, Name FROM HFS_Storage_Location__c];

        system.runAs(runner){
            List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c, HFS_Purchase__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
            List<HFS_Bag__c> allBags = [SELECT Barcode__c, In_Storage_Point__c, HFS_Storage_Location__c, HFS_Runner__c, Guest_ID_Code__c FROM HFS_Bag__c WHERE HFS_Purchase__c =: job[0].HFS_Purchase__c];
            allBags[0].HFS_Runner__c = theRunner.Id;
            allBags[0].HFS_Job__c = job[0].Id;
            allBags[1].HFS_Runner__c = theRunner.Id;
            allBags[1].HFS_Job__c = job[0].Id;
            allBags[1].HFS_Storage_Location__c = sl.Id;
            update allBags[0];
            update allBags[1];
            system.debug(allBags);
            Test.startTest();
                PageReference pageRef = Page.HFSDeliveryPage;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('id', job[0].Id);
                pageRef.getParameters().put('barcodeBag', allBags[0].Barcode__c);
                pageRef.getParameters().put('StorageLocation', sl.Id);
                ApexPages.StandardController sc = new ApexPages.StandardController(job[0]);
                HFSDeliveryPageController controller = new HFSDeliveryPageController(sc);
                controller.updateRecords();

            Test.stopTest();

            HFS_Bag__c theBag = [SELECT ID, In_Storage_Point__c, HFS_Storage_Location__c FROM HFS_Bag__c WHERE Id =: allBags[0].Id];

            System.assertEquals(false, controller.stopLoopBags);
            System.assertEquals(1, controller.countAllJobBagsInStorage);
            System.assertEquals(true, theBag.In_Storage_Point__c);
            System.assertEquals(sl.Id, theBag.HFS_Storage_Location__c);
        }
    }
}