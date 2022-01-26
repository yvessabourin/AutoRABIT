@isTest
public class DailySales_Batch_Script_Test {
    static void setupData(){
        /*Id dsNetRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('Net').RecordTypeId;
        Id dsFullPriceRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Full_Price').RecordTypeId;
        Id dsGrossRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('Gross').RecordTypeId;
        Id dsFBCoversRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('F & B Covers').RecordTypeId;*/
        
        Id dsCurrentRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Current').RecordTypeId;
        
        Profile profileSysAdmin = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator'];
        
        UserRole adminRole = new UserRole();
        adminRole.DeveloperName = 'CustomRole';
        adminRole.Name = 'Custom Role';
        insert adminRole;
        
        User admin = new User();
        admin.LastName = 'AdministratorForTestingHere';
        admin.Alias = 'admin';
        admin.Email = 'adminFortests@valueretai.com';
        admin.Username = 'adminFortests@valueretai.com';
        admin.CommunityNickname = 'admin';
        admin.UserRoleId = adminRole.Id;
        admin.ProfileId = profileSysAdmin.Id;
        admin.Village__c = 'Bicester';
        admin.TimeZoneSidKey = 'GMT';
        admin.LocaleSidKey = 'en_GB';
        admin.EmailEncodingKey = 'ISO-8859-1';
        admin.LanguageLocaleKey = 'en_US';
        insert admin;
        
        system.runAs(admin){
            
            DailySales_Validation_Override__c dsvoRecord = DailySales_Validation_Override__c.getOrgDefaults();
            dsvoRecord.DailySales_Override__c = true;
            insert dsvoRecord;
            
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
            vill.Village_Code__c = 'BC';
            vill.CertSales_Tot_Variance_Max_Percent__c = 5;
            vill.CertSales_Report_Sales_Grace_Period_Days__c= 5;
            vill.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            vill.VR_Finance_Email__c = 'test@valueretai.com';
            insert vill;
            
            Unit__c unit = new Unit__c();
            unit.Village__c = vill.Id;
            unit.Name = 'BIC1';
            unit.Size_GEA__c = 120;
            unit.Suite_ID__c = 'S1';
            unit.Phase_Id__c = 'P1';
            insert unit;
            
            Unit__c unit2 = new Unit__c();
            unit2.Village__c = vill.Id;
            unit2.Name = 'BIC2';
            unit2.Size_GEA__c = 120;
            unit2.Suite_ID__c = 'S2';
            unit2.Phase_Id__c = 'P2';
            insert unit2;
            
            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
            
            Account brand2 = new Account();
            brand2.RecordTypeId = brandRecordType.Id;
            brand2.Name = 'Brand 2';
            insert brand2;
            
            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in Bicester';
            presentBrand.Unit__c = unit.Id;
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            presentBRand.Daily_Sales_Active__c = true;
            presentBrand.Status__c = 'Trading';
            presentBrand.Lease_ID__c = 'ABC123';
            presentBrand.Expected_Unit__c = unit.Id;
            presentBrand.CertSales_Active__c = true;
            presentBrand.CertSales_CertPeriod_Type__c = 'Quarterly';
            insert presentBrand;
            
            Village_Presence__c presentBrand2 = new Village_Presence__c();
            presentBrand2.Name = 'Brand2 in Bicester';
            presentBrand2.Unit__c = unit2.Id;
            presentBrand2.Brand__c = brand2.Id;
            presentBrand2.Village__c = vill.Id;
            presentBrand2.Daily_Sales_Active__c = true;
            presentBrand2.Status__c = 'Trading';
            presentBrand2.Lease_ID__c = 'LPP123';
            presentBrand2.Expected_Unit__c = unit2.Id;
            presentBrand2.CertSales_Active__c = true;
            presentBrand2.CertSales_CertPeriod_Type__c = 'Monthly';
            insert presentBrand2;
            
            RecordType brandContactRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand Contact'];
            
            Contact communityContact = new Contact();
            communityContact.RecordTypeId = brandContactRecordType.Id;
            communityContact.LastName = 'John';
            communityContact.AccountId = brand.Id;
            communityContact.Village_Presence__c = 'Bicester';
            communityContact.Email = 'testcommunity.contact@brand.com';
            insert communityContact;
            
            Village_Presence_Contact_Role__c communityContactRole = new Village_Presence_Contact_Role__c();
            communityContactRole.Contact__c = communityContact.Id;
            communityContactRole.Retail_Role__c = 'Retail';
            communityContactRole.Village_Presence__c = presentBrand.Id;
            communityContactRole.Daily_Sales_Active_From__c = Date.newInstance(2018, 10, 1);
            communityContactRole.Daily_Sales_Active_To__c = Date.newInstance(2025, 10, 1);
            communityContactRole.Confirm_Daily_Sales_Records__c = true;
            communityContactRole.BP_HFS_Brand_TeC_Conf_Date__c = Date.newInstance(2025, 10, 1);
            communityContactRole.Certification_Active__c = true;
            insert communityContactRole;
            
            UserRole communityRole = new UserRole();
            communityRole.DeveloperName = 'NewBalanceCustomerUser5';
            communityRole.Name = 'NewBalanceCustomerUser1';
            insert communityRole;
            
            Profile profileCommunity = [SELECT ID, Name FROM Profile WHERE Name = 'Brand Community Plus User (with Export)'];
            
            User communityUser = new User();
            communityUser.LastName = communityContact.LastName;
            communityUser.Alias = 'jhn';
            communityUser.Email = communityContact.Email;
            communityUser.Username = 'john@valueretai.com';
            communityUser.CommunityNickname = 'johnvr';
            communityUser.ProfileId = profileCommunity.Id;
            communityUser.Village__c = 'Bicester';
            communityUser.TimeZoneSidKey = 'GMT';
            communityUser.LocaleSidKey = 'en_GB';
            communityUser.EmailEncodingKey = 'ISO-8859-1';
            communityUser.LanguageLocaleKey = 'en_US';
            communityUser.ContactId = communityContact.Id;
            communityUser.PortalRole = 'Manager';
            insert communityUser;
            
            Daily_Sales_Certification_Batch__c cert = new Daily_Sales_Certification_Batch__c();
            cert.Name = 'Brand1 in Village - today';
            cert.Village_Presence__c = presentBrand.Id;
            cert.Period_Start_Date__c = system.today()-1;
            cert.Period_End_Date__c = system.today()+1;
            insert cert;
            
            Daily_Sales_Certification_Batch__c cert2 = new Daily_Sales_Certification_Batch__c();
            cert2.Name = 'Brand2 in Village - today';
            cert2.Village_Presence__c = presentBrand2.Id;
            cert2.Period_Start_Date__c = system.today()-1;
            cert2.Period_End_Date__c = system.today()+1;
            insert cert2;
            
            Daily_Sale__c ds1 = new Daily_Sale__c();
            
            ds1.Trading_Date__c = system.today();
            ds1.Store__c = presentBrand.Id;
            ds1.Lease_ID__c = '1234';
            ds1.RecordTypeId = dsCurrentRecordTypeId;
            ds1.Status__c = 'TOR';
            ds1.Total_NET_SALES__c  = 123;
            ds1.NET_Value_of_Discounts__c  = 132;
            insert ds1;
            
            Daily_Sale__c ds2 = new Daily_Sale__c();
            
            ds2.Trading_Date__c = system.today();
            ds2.Store__c = presentBrand.Id;
            ds2.Lease_ID__c = '4321';
            ds2.RecordTypeId = dsCurrentRecordTypeId;
            ds2.Status__c = 'TOR';
            ds2.Total_NET_SALES__c  = 123;
            ds2.NET_Value_of_Discounts__c  = 132;
            insert ds2;
            
            Daily_Sale__c ds3 = new Daily_Sale__c();
            
            ds3.Trading_Date__c = system.today();
            ds3.Store__c = presentBrand.Id;
            ds3.Lease_ID__c = '4221';
            ds3.RecordTypeId = dsCurrentRecordTypeId;
            ds3.Status__c = 'TOR';
            ds3.Total_NET_SALES__c  = 123;
            ds3.NET_Value_of_Discounts__c  = 132;
            insert ds3; 
            
            Daily_Sale__c ds4 = new Daily_Sale__c();
            
            ds4.Trading_Date__c = system.today();
            ds4.Store__c = presentBrand.Id;
            ds4.Lease_ID__c = '4121';
            ds4.RecordTypeId = dsCurrentRecordTypeId;
            ds4.Status__c = 'Certified Complete';
            ds4.Total_NET_SALES__c  = 123;
            ds4.NET_Value_of_Discounts__c  = 132;
            insert ds4;
            
            Daily_Sale__c ds5 = new Daily_Sale__c();
            
            ds5.Trading_Date__c = system.today();
            ds5.Store__c = presentBrand2.Id;
            ds5.Lease_ID__c = '4121';
            ds5.RecordTypeId = dsCurrentRecordTypeId;
            ds5.Status__c = 'Created';
            ds5.Total_NET_SALES__c  = 123;
            ds5.NET_Value_of_Discounts__c  = 132;
            insert ds5;
            
            API_Configuration__c settings = new API_Configuration__c();
            settings.name = 'API Config LIVE';
            settings.Api_host__c = 'https://test.apiCustomer.com';
            settings.Api_key__c = '123456';
            settings.Customer_create__c = '/createCustomer';
            settings.Customer_read_GUID__c = '/readCustomer';
            settings.Debug_mode__c = true;
            settings.Enum_read__c = '/enumRead';
            settings.Lookup_read__c = '/lookupRead';
            settings.Preference_create__c = '/prefCreate';
            settings.Preference_read__c = '/prefRead';
            settings.Email_Change__c = '/emailChange';
            settings.Lease_List__c = '/leaseList';
            insert settings;    
        }
    }
    
    static testMethod void DailyProdBatch1(){
        setupData();
        
        List<string> brand = new List<String>{'Brand 1', 'Brand 2'};
        String village = 'Bicester';
        String startDate = String.valueOf(system.today());
        String endDate = String.valueOf(system.today());
        
        User admin = [SELECT Id, ContactId FROM User WHERE Alias = 'admin'];
        
        system.runAs(admin){
            
            Test.startTest();
            
            DailySales_Batch_Script obj = new DailySales_Batch_Script(brand,village,startDate,endDate);
            DataBase.executeBatch(obj);
            
            Test.stopTest();
        }
        
        List<Daily_Sale__c> allUpdatedDS = [SELECT Id, Certification_Batch__c FROM Daily_Sale__c WHERE Certification_Batch__c != NULL];
        system.assertEquals(allUpdatedDS.isEmpty(), false);
    }
}