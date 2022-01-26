@isTest
public class BP_Terms_Controller_Test {

    static void setupData(){

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
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
			vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
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

            BP_Brand_Term__c terms = new BP_Brand_Term__c();
            terms.BP_terms_Language__c = 'English';
            terms.Brand_Terms__c = 'TeCs Text Example';
            terms.CurrencyIsoCode = 'EUR';
            insert terms;

        }
        
    }


    static testMethod void guestExtensionTestBPTC1(){

        setupData();
        String tR = '';

        Test.startTest();   

            tR = BP_Terms_Controller.getTerms();

        Test.stopTest();
        
        User user = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Alias = 'jhn'];
        String userLanguage = user.LanguageLocaleKey;
        BP_Brand_Term__c terms = [SELECT Brand_Terms__c, BP_terms_Language__c FROM BP_Brand_Term__c WHERE BP_terms_Language__c =: userLanguage ];

        System.assertEquals(tR, terms.Brand_Terms__c);
    }
    
    
    static testMethod void guestExtensionTestBPTC2(){

        setupData();
        User user = [SELECT Id, Email FROM User WHERE Alias = 'jhn' ];
        Date aDate;

        Test.startTest();   
            system.runAs(user){
               BP_Terms_Controller.getSubmit();  
               aDate = system.today();            
            }
        Test.stopTest();

        string email = user.Email;
        
        Contact contact = [SELECT id FROM CONTACT 
                           WHERE Email =: email                       
                           LIMIT 1];            
        
        Village_Presence_Contact_Role__c vpr = [SELECT Contact__c, id, BP_HFS_Brand_TeC_Conf_Date__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: contact.Id LIMIT 1];                       
         
        dateTime aDateTime = vpr.BP_HFS_Brand_TeC_Conf_Date__c;
        System.assertEquals(aDate, date.newinstance(aDateTime.year(), aDateTime.month(), aDateTime.day()));

    }
    
    static testMethod void guestExtensionTestBPTC3(){

        setupData();
        String tR = '';
        String tRuser = '';

        User user = [SELECT Email, Name, id FROM USER 
                     WHERE Alias = 'jhn'
                     LIMIT 1]; 

        Test.startTest();   
            system.runAs(user){
                tRuser = ' ' + System.Label.DAILY_SALE_TERMS_APPROVED_BY + ' ';
                tR = BP_Terms_Controller.getTermsUser();
            }
        Test.stopTest();

        string email = user.Email;
        
        Contact contact = [SELECT id FROM CONTACT 
                           WHERE Email =: email                       
                           LIMIT 1];            
        
        Village_Presence_Contact_Role__c vpr = [SELECT Contact__c, id, BP_HFS_Brand_TeC_Conf_Date__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: contact.Id LIMIT 1];                       
         
        String tUserDate = string.valueofGmt(vpr.BP_HFS_Brand_TeC_Conf_Date__c);
        tRuser = tRuser +  user.Name + '  ' + tUserDate;

        System.assertEquals(tR, tRuser);
    }


    
}