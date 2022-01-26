@isTest
public class SendEmailToCertifyTest {

    static void setupData(){
        
        Profile profileSysAdmin = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator'];

        UserRole adminRole = new UserRole();
        adminRole.DeveloperName = 'CustomRole';
        adminRole.Name = 'Custom Role';
        insert adminRole;

        User admin = new User();
        admin.FirstName = 'FirstName';
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
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
            vill.Village_Code__c = 'BC';
            vill.CertSales_Tot_Variance_Max_Percent__c = 5;
            vill.CertSales_Report_Sales_Grace_Period_Days__c = 7;
            vill.CertSales_CertPeriod_Cut_Off_Days__c = 7;
            insert vill;
            
            Unit__c unit = new Unit__c();
            unit.Village__c = vill.Id;
            unit.Name = 'BIC1';
            unit.Size_GEA__c = 120;
            unit.Suite_ID__c = 'S1';
            unit.Phase_Id__c = 'P1';
            insert unit;
            
            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
            
            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Unit__c = unit.Id;
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            presentBRand.Daily_Sales_Active__c = true;
            presentBrand.Status__c = 'Trading';
            presentBrand.Lease_ID__c = 'ABC123';
            presentBrand.Expected_Unit__c = unit.Id;
            insert presentBrand;
            
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
            cert.Name = 'Brand in Village';
            cert.Village_Presence__c = presentBrand.Id;
            cert.Period_Start_Date__c = system.today()-2;
            cert.Period_End_Date__c = system.today()-1;
            cert.Status__c = 'Generated';
            insert cert;
            
            RecordType dsRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Current'];
            
            Daily_Sale__c ds1 = new Daily_Sale__c();
            ds1.RecordTypeId = dsRecordType.Id;
            ds1.Trading_Date__c = system.today();
            ds1.Store__c = presentBrand.Id;
            ds1.Lease_ID__c = '1234';
            ds1.Status__c = 'Created';
            ds1.Certification_Batch__c = cert.Id;
            insert ds1;
            
            Daily_Sale__c ds2 = new Daily_Sale__c();
            ds2.RecordTypeId = dsRecordType.Id;
            ds2.Trading_Date__c = system.today();
            ds2.Store__c = presentBrand.Id;
            ds2.Lease_ID__c = '4321';
            ds2.Status__c = 'Created';
            ds2.Certification_Batch__c = cert.Id;
            insert ds2;
            
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
    
    static testMethod void sendEmailToCertifyMethodTest(){
        setupData();
        
        Test.startTest();
        
            Set<Id> theSet = new Set<Id>();
            List<Village_Presence__c> theVPs = [SELECT Id FROM Village_Presence__c];

            for(Village_Presence__c vp : theVPs){
                theSet.add(vp.Id);
            }

            Map<Id, Date> theMap = new Map<Id, Date>();
            List<Village__c> theVillages = [SELECT Id, CertSales_CertPeriod_Cut_Off_Days__c FROM Village__c];
            List<Daily_Sales_Certification_Batch__c> certification = [SELECT Id, Village_Presence__r.Village__c, Period_End_Date__c
                                                                    FROM Daily_Sales_Certification_Batch__c
                                                                    WHERE Status__c = 'Generated'];
            
            for(Daily_Sales_Certification_Batch__c dscb : certification){
                for(Village__c vil : theVillages){
                    theMap.put(dscb.Village_Presence__r.Village__c, dscb.Period_End_Date__c.addDays(Integer.valueOf(vil.CertSales_CertPeriod_Cut_Off_Days__c)));
                }
            }

        	SendEmailToCertify.SendEmailToCertify(theSet, theMap);
        	Integer actualLimits = Limits.getEmailInvocations();
        Test.stopTest();
        
        Integer expectedLimits = 1;
        System.assertEquals(expectedLimits, actualLimits);
    }
}