@isTest
public class BP_Home_Landing_Controller_Test {

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
            presentBrand.BP_HFS_Active__c = true;
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


    static testMethod void guestExtensionTestBPHL1(){

        setupData();
        boolean tRtrue;
        boolean tRfalse;
  		User user = [SELECT Id, Email FROM User WHERE Alias = 'jhn' ];

        Test.startTest();   
			system.runAs(user){
            	tRtrue = BP_Home_Landing_Controller.getDailySalesPermission();

            	string email = user.Email;
            	Contact contact = [SELECT id FROM CONTACT 
                			        WHERE Email =: email                       
                           			LIMIT 1];   

		        Village_Presence_Contact_Role__c vpr = [SELECT Contact__c, id, Village_Presence__c, Daily_Sales_Active_From__c, Daily_Sales_Active_To__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: contact.Id LIMIT 1];                       
		    	vpr.Daily_Sales_Active_From__c = null;
		        update vpr;

				tRfalse = BP_Home_Landing_Controller.getDailySalesPermission();

			}
        Test.stopTest();

        System.assertEquals(tRtrue, true);
        System.assertEquals(tRfalse, false);
		

    }

    static testMethod void guestExtensionTestBPHL2(){

        setupData();
        boolean tRtrue;
  		User user = [SELECT Id, Email FROM User WHERE Alias = 'jhn' ];

        Test.startTest();   
			system.runAs(user){
            	tRtrue = BP_Home_Landing_Controller.getHFSPermission();
			}
        Test.stopTest();
        
		System.assertEquals(tRtrue, true);

    }

    static testMethod void getCertPermissionTestBPHL2(){

        setupData();
        boolean tRtrue;
  		User user = [SELECT Id, Email FROM User WHERE Alias = 'jhn' ];

        Test.startTest();   
			system.runAs(user){
            	tRtrue = BP_Home_Landing_Controller.getCertPermission();
			}
        Test.stopTest();
        
		System.assertEquals(tRtrue, false);

    }

}