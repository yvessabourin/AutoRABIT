@isTest
public class HFSRemoveBagControllerTest {
    
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
    static testMethod void HFSRemoveBagMethodTestN1() {
        setupData();
        
        User us = [SELECT Id FROM User WHERE Alias = 'jhn' ];
        Test.StartTest(); 
        
        System.runAs(us){
            PageReference pageRef = Page.HFSRemoveBag;
            Test.setCurrentPageReference(pageRef);
            
            
            Case_Item__c thePurchase = [SELECT Id, Bag_Barcodes_Manual__c  FROM Case_Item__c WHERE Item_Count__c = 3 ];
            List<HFS_Bag__c> Bag = [SELECT Id, HFS_Remove_Reason__c FROM HFS_Bag__c WHERE HFS_Purchase__c =:thePurchase.Id AND Barcode__c=:thePurchase.Bag_Barcodes_Manual__c  LIMIT 2 ];
            
            pageRef.getParameters().put('id',thePurchase.Id);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Bag);
            HFSRemoveBagController controller = new HFSRemoveBagController(sc);
            
            
            controller.selectedBag = '152635';
            controller.aBag.HFS_Remove_Reason__c ='Brand Error';
            controller.RemoveBag();
            controller.getBags();
            Controller.cancel();
            
            System.assertEquals(null, controller.RemoveBag());
            
        }
        Test.stopTest();
        
        HFS_Bag__c Bags = [SELECT Id, HFS_Remove_Reason__c  FROM HFS_Bag__c WHERE Barcode__c = '152635'];
        
        
        System.assertEquals('Brand Error', Bags.HFS_Remove_Reason__c);
        
        
        
        
    }
    
    
    
    
}