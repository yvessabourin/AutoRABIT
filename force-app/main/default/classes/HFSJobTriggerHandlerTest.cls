@isTest
public class HFSJobTriggerHandlerTest {

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

            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brandS = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchase = new Case_Item__c();
            hfsPurchase.Village_Presence__c = presentBrand.Id;
            hfsPurchase.Case__c = guestCase.Id;
            hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchase.Start_Time__c = system.now();
            hfsPurchase.Item_Count__c = 3;
            hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
            hfsPurchase.Require_a_Runner__c = true;
            hfsPurchase.HFS_Bag_Transfer__c = false;
            hfsPurchase.Village_Presence__c = brandS.Id;
            insert hfsPurchase;

            Case_Item__c hfsPurchaseAssigned = new Case_Item__c();
            hfsPurchaseAssigned.Village_Presence__c = presentBrand.Id;
            hfsPurchaseAssigned.Case__c = guestCase.Id;
            hfsPurchaseAssigned.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchaseAssigned.Start_Time__c = system.now();
            hfsPurchaseAssigned.Item_Count__c = 2;
            hfsPurchaseAssigned.Bag_Barcodes_Manual__c = '1123456,false,1123457,true';
            hfsPurchaseAssigned.Require_a_Runner__c = true;
            hfsPurchaseAssigned.HFS_Bag_Transfer__c = false;
            hfsPurchaseAssigned.Village_Presence__c = brandS.Id;
            insert hfsPurchaseAssigned;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.Village__c = 'Bicester';
            newRunner.User__c = runner.Id;
            newRunner.Village__c = 'Bicester';
            insert newRunner;

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

    static testMethod void runnerWantJobTest(){
        setupData();

        User getRunner = [SELECT Id, Alias FROM User WHERE Alias = 'jhn'];
        Case_Item__c theHFSPurchase = [SELECT Id, Item_Count__c FROM Case_Item__c WHERE Item_Count__c = 3 LIMIT 1];

        test.startTest();
            system.runAs(getRunner){
                HFS_Job__c aJob = [SELECT Id, HFS_Purchase__c, Take_job_for_me__c, HFS_Runner__c FROM HFS_Job__c WHERE HFS_Purchase__c =: theHFSPurchase.Id];
                aJob.Take_job_for_me__c = true;
                update aJob;
            }
        test.stopTest();

        HFS_Job__c theJob = [SELECT Id, Take_job_for_me__c, HFS_Runner__c, Job_Status__c, RecordTypeId FROM HFS_Job__c WHERE HFS_Purchase__c =: theHFSPurchase.Id];
        HFS_Runner__c runner = [SELECT Id FROM HFS_Runner__c WHERE User__c =: getRunner.Id];
        RecordType recordTypeAcceptedJob = [SELECT Id, Name FROM RecordType WHERE Name = 'Accepted Jobs'];

        system.assertEquals('Accepted', theJob.Job_Status__c);
        system.assertEquals(runner.Id, theJob.HFS_Runner__c);
        system.assertEquals(true, theJob.Take_job_for_me__c);
        system.assertEquals(recordTypeAcceptedJob.Id, theJob.RecordTypeId);
    }

    static testMethod void runnerRejectJobTest(){
        setupData();

        User getRunner = [SELECT Id, Alias FROM User WHERE Alias = 'jhn'];
        Case_Item__c theHFSPurchase = [SELECT Id, Item_Count__c FROM Case_Item__c WHERE Item_Count__c = 2 LIMIT 1];

        test.startTest();
            system.runAs(getRunner){
                HFS_Job__c aJob = [SELECT Id, HFS_Purchase__c, Reject_Job__c, HFS_Runner__c, Job_Status__c FROM HFS_Job__c WHERE HFS_Purchase__c =: theHFSPurchase.Id];
                aJob.Reject_Job__c = true;
                update aJob;
            }
        test.stopTest();

        HFS_Job__c theJob = [SELECT Id, Job_Status__c, Reject_Job__c, RecordTypeId, HFS_Runner__c, Rejected_By__c FROM HFS_Job__c WHERE HFS_Purchase__c =: theHFSPurchase.Id];
        RecordType recordTypeRejectedJob = [SELECT Id, Name FROM RecordType WHERE Name = 'Rejected Jobs'];
        HFS_Runner__c runner = [SELECT Id, Name FROM HFS_Runner__c WHERE User__c =: getRunner.Id];

        system.assertEquals('Rejected', theJob.Job_Status__c);
        system.assertEquals(false, theJob.Reject_Job__c); // Due to the Workflow the Reject Job field is set as false.
        system.assertEquals(recordTypeRejectedJob.Id, theJob.RecordTypeId);
        system.assertEquals(null, theJob.HFS_Runner__c);
        system.assertEquals(runner.Name, theJob.Rejected_By__c);
    }
}