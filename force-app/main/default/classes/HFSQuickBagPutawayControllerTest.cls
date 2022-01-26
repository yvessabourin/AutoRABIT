@isTest
public class HFSQuickBagPutawayControllerTest {

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
            
         
            list<HFS_Bag__c> bags = [SELECT Id, Name,HFS_Runner__c FROM HFS_Bag__c WHERE Barcode__c = '1223457'];
            bags[0].HFS_Runner__c = newRunner.id;
            bags[0].HFS_Job__c = jobAssigned.id;
            update bags[0]; 
        }
    }
    
    //---------------------------------------------
    
    static testMethod void initialActionQuickStorage(){
        setupData();     
        User runner = [SELECT Id FROM User WHERE Name = 'John'];      
       system.runAs(runner){
            List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
            Test.startTest();
                PageReference pageRef = Page.QuickBagPutaway;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('bagId', '1223457');
    
                HFSQuickBagPutawayController controller = new HFSQuickBagPutawayController();
                controller.scanLocationCode();
                controller.scanBagsCode();


            Test.stopTest();
            System.assert(controller.CurrentJob != NULL);
        
        }
    }
     
     static testMethod void addQRCodeTest(){
        setupData();     
        User runner = [SELECT Id FROM User WHERE Name = 'John'];      
       system.runAs(runner){
            List<HFS_Job__c> job = [SELECT Id, HFS_Runner__c, Assigned_to_me__c FROM HFS_Job__c WHERE HFS_Runner__c != null];
            Test.startTest();
                PageReference pageRef = Page.QuickBagPutaway;
                Test.setCurrentPage(pageRef);

                pageRef.getParameters().put('bagId', '1223457');
                pageRef.getParameters().put('qrCodeLocation', '123456789');     
    
                HFSQuickBagPutawayController controller = new HFSQuickBagPutawayController();
                controller.updateRecords();



            Test.stopTest();
            System.assert(controller.CurrentJob != NULL);
        
        }
    }
       
}