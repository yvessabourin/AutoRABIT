@isTest
public class HFSFindHelperControllerTest {
    
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
            hfsPurchase.Case__c = guestCase.Id;
            hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchase.Start_Time__c = system.now();
            hfsPurchase.Item_Count__c = 3;
            hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
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
    
    // To initialize the controller
    static testMethod void autoRunMethodTestN1(){
        setupData();
        
        Test.startTest();
        PageReference pageRef = Page.HFSFindHelper;
        Test.setCurrentPage(pageRef);
        
        HFSFindHelperController controller = new HFSFindHelperController();
        controller.autoRun();
        
        Test.stopTest();
        
        System.assertEquals(null, controller.storageLocationQR);
        System.assertEquals(null, controller.bagBarcode);
        System.assertEquals(null, controller.bagId);
        System.assertEquals(null, controller.qrCodeStorageLocation);
        controller.autoRun();
    }
    
    // For Reassign New Storage Location
    static testMethod void autoRunMethodTestN2(){
        setupData();
        
        HFS_Job__c job = [SELECT Id FROM HFS_Job__c];
        HFS_Storage_Location__c sl = [SELECT Id, QR_Code_hidden__c FROM HFS_Storage_Location__c];
        List<HFS_Bag__c> allBags = [SELECT Id, HFS_Storage_Location__c FROM HFS_Bag__c];
        User getRunner = [SELECT Id, Alias FROM User WHERE Alias = 'jhn'];
        
        Test.startTest();
        system.runAs(getRunner){
            PageReference pageRef = Page.HFSFindHelper;
            Test.setCurrentPage(pageRef);
            
            pageRef.getParameters().put('bagId', allBags[0].Id);
            pageRef.getParameters().put('qrCodeStorageLocation', sl.QR_Code_hidden__c);
            HFSFindHelperController controller = new HFSFindHelperController();
            controller.autoRun();
            
            HFS_Bag__c theBag = [SELECT Id, HFS_Storage_Location__c FROM HFS_Bag__c WHERE Id =: allBags[0].Id];
            
            System.assertEquals(null, controller.storageLocationQR);
            System.assertEquals(null, controller.bagBarcode);
            System.assertEquals(theBag.Id, controller.bagId);
            System.assertEquals(sl.QR_Code_hidden__c, controller.qrCodeStorageLocation);
            System.assertNotEquals(null, controller.autoRun());
            System.assertEquals(theBag.HFS_Storage_Location__c, sl.Id);
        }
        Test.stopTest();
        
        
    }
    
    // For STORAGE LOCATION FIND
    static testMethod void autoRunMethodTestN3(){
        setupData();
        
        HFS_Job__c job = [SELECT Id FROM HFS_Job__c];
        HFS_Storage_Location__c sl = [SELECT Id, QR_Code_hidden__c FROM HFS_Storage_Location__c];
        
        Test.startTest();
        PageReference pageRef = Page.HFSFindHelper;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('qrCodeLocation', sl.QR_Code_hidden__c);
        HFSFindHelperController controller = new HFSFindHelperController();
        controller.autoRun();
        
        Test.stopTest();
        
        System.assertEquals(sl.QR_Code_hidden__c, controller.storageLocationQR);
        System.assertEquals(null, controller.bagBarcode);
        System.assertEquals(null, controller.bagId);
        System.assertEquals(null, controller.qrCodeStorageLocation);
        System.assertNotEquals(null, controller.autoRun());
    }
    
    // For BAG FIND
    static testMethod void autoRunMethodTestN4(){
        setupData();
        
        HFS_Job__c job = [SELECT Id FROM HFS_Job__c];
        List<HFS_Bag__c> allBags = [SELECT Id, Barcode__c FROM HFS_Bag__c];
        
        Test.startTest();
        PageReference pageRef = Page.HFSFindHelper;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('bagBarcode', allBags[0].Barcode__c);
        HFSFindHelperController controller = new HFSFindHelperController();
        controller.autoRun();
        
        Test.stopTest();
        
        System.assertEquals(null, controller.storageLocationQR);
        System.assertEquals(allBags[0].Barcode__c, controller.bagBarcode);
        System.assertEquals(null, controller.bagId);
        System.assertEquals(null, controller.qrCodeStorageLocation);
        System.assertNotEquals(null, controller.autoRun());
    }
    
    // FOR PURCHASE FIND
    static testMethod void autoRunMethodTestN5(){
        setupData();
        
        Case_Item__c hfsPurchase =[SELECT Id, Name FROM Case_Item__c];
        Test.StartTest(); 
        PageReference pageRef = Page.HFSFindHelper;
        HFSFindHelperController controller = new HFSFindHelperController();
        controller.purchaseCode = String.valueOf(hfsPurchase.Name);
        controller.autoRun();
        Test.stopTest();
        
        System.assertEquals(null, controller.storageLocationQR);
        System.assertEquals(null, controller.bagBarcode);
        System.assertEquals(null, controller.bagId);
        System.assertEquals(null, controller.qrCodeStorageLocation);
        System.assertEquals(hfsPurchase.Name,controller.purchaseCode);
        System.assertNotEquals(null, controller.autoRun());
    }
}