@isTest
public class HFSOperationGuidesTilesControllerTest {

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

			Folder theFolderEN = [SELECT Id FROM Folder WHERE DeveloperName = 'HFS_Operational_Guides_EN'];
			Folder theFolderGER = [SELECT Id FROM Folder WHERE DeveloperName = 'HFS_Operational_Guides_GER'];
			Folder theFolderESP = [SELECT Id FROM Folder WHERE DeveloperName = 'HFS_Operational_Guides_ESP'];
			Folder theFolderFR = [SELECT Id FROM Folder WHERE DeveloperName = 'HFS_Operational_Guides_FR'];
			Folder theFolderIT = [SELECT Id FROM Folder WHERE DeveloperName = 'HFS_Operational_Guides_IT'];
	        
	        Document aDocumentEN = new Document();
	        aDocumentEN.Body = Blob.valueOf('Some Text');
			aDocumentEN.ContentType = 'application/pdf';
			aDocumentEN.DeveloperName = 'my_document_EN';
			aDocumentEN.IsPublic = true;
			aDocumentEN.Name = 'My Document EN';
			aDocumentEN.FolderId = theFolderEN.id;
	        insert aDocumentEN;

	        Document aDocumentGER = new Document();
	        aDocumentGER.Body = Blob.valueOf('Some Text');
			aDocumentGER.ContentType = 'application/pdf';
			aDocumentGER.DeveloperName = 'my_document_GER';
			aDocumentGER.IsPublic = true;
			aDocumentGER.Name = 'My Document GER';
			aDocumentGER.FolderId = theFolderGER.id;
	        insert aDocumentGER;

	        Document aDocumentESP = new Document();
	        aDocumentESP.Body = Blob.valueOf('Some Text');
			aDocumentESP.ContentType = 'application/pdf';
			aDocumentESP.DeveloperName = 'my_document_ESP';
			aDocumentESP.IsPublic = true;
			aDocumentESP.Name = 'My Document ESP';
			aDocumentESP.FolderId = theFolderESP.id;
	        insert aDocumentESP;

       		Document aDocumentFR = new Document();
	        aDocumentFR.Body = Blob.valueOf('Some Text');
			aDocumentFR.ContentType = 'application/pdf';
			aDocumentFR.DeveloperName = 'my_document_FR';
			aDocumentFR.IsPublic = true;
			aDocumentFR.Name = 'My Document FR';
			aDocumentFR.FolderId = theFolderFR.id;
	        insert aDocumentFR;

	        Document aDocumentIT = new Document();
	        aDocumentIT.Body = Blob.valueOf('Some Text');
			aDocumentIT.ContentType = 'application/pdf';
			aDocumentIT.DeveloperName = 'my_document_IT';
			aDocumentIT.IsPublic = true;
			aDocumentIT.Name = 'My Document IT';
			aDocumentIT.FolderId = theFolderIT.id;
	        insert aDocumentIT;
	    }
    }

    static testMethod void HFSOperationGuidesTilesEN(){
    	setupData();

    	User us = [SELECT Id FROM User WHERE Alias = 'jhn'];

    	system.runAs(us){
	    	Test.startTest();
		        Document getDocumentEN = [SELECT Id FROM Document WHERE Name = 'My Document EN'];

	    		List<Document> allDocuments = HFSOperationGuidesTilesController.getDocuments();
	    		String url = HFSOperationGuidesTilesController.DownloadAttachment(getDocumentEN.Id);
	    	Test.stopTest();

	    	system.assertNotEquals(null, url);
	    	system.assertNotEquals(null, allDocuments);
	    }
    }

    static testMethod void HFSOperationGuidesTilesESP(){
    	setupData();

    	User us = [SELECT Id, LanguageLocaleKey FROM User WHERE Alias = 'jhn'];
    	us.LanguageLocaleKey = 'es';
    	update us;

    	system.runAs(us){
	    	Test.startTest();
		        Document getDocumentESP = [SELECT Id FROM Document WHERE Name = 'My Document ESP'];

	    		List<Document> allDocuments = HFSOperationGuidesTilesController.getDocuments();
	    		String url = HFSOperationGuidesTilesController.DownloadAttachment(getDocumentESP.Id);
	    	Test.stopTest();

	    	system.assertNotEquals(null, url);
	    	system.assertNotEquals(null, allDocuments);
	    }
    }

    static testMethod void HFSOperationGuidesTilesGER(){
    	setupData();

    	User us = [SELECT Id FROM User WHERE Alias = 'jhn'];
    	us.LanguageLocaleKey = 'de';
    	update us;

    	system.runAs(us){
	    	Test.startTest();
		        Document getDocumentGER = [SELECT Id FROM Document WHERE Name = 'My Document GER'];

	    		List<Document> allDocuments = HFSOperationGuidesTilesController.getDocuments();
	    		String url = HFSOperationGuidesTilesController.DownloadAttachment(getDocumentGER.Id);
	    	Test.stopTest();

	    	system.assertNotEquals(null, url);
	    	system.assertNotEquals(null, allDocuments);
	    }
    }

    static testMethod void HFSOperationGuidesTilesIT(){
    	setupData();

    	User us = [SELECT Id FROM User WHERE Alias = 'jhn'];
    	us.LanguageLocaleKey = 'it';
    	update us;

    	system.runAs(us){
	    	Test.startTest();
		        Document getDocumentIT = [SELECT Id FROM Document WHERE Name = 'My Document IT'];

	    		List<Document> allDocuments = HFSOperationGuidesTilesController.getDocuments();
	    		String url = HFSOperationGuidesTilesController.DownloadAttachment(getDocumentIT.Id);
	    	Test.stopTest();

	    	system.assertNotEquals(null, url);
	    	system.assertNotEquals(null, allDocuments);
	    }
    }

    static testMethod void HFSOperationGuidesTilesFR(){
    	setupData();

    	User us = [SELECT Id FROM User WHERE Alias = 'jhn'];
    	us.LanguageLocaleKey = 'fr';
    	update us;

    	system.runAs(us){
	    	Test.startTest();
		        Document getDocumentFR = [SELECT Id FROM Document WHERE Name = 'My Document FR'];

	    		List<Document> allDocuments = HFSOperationGuidesTilesController.getDocuments();
	    		String url = HFSOperationGuidesTilesController.DownloadAttachment(getDocumentFR.Id);
	    	Test.stopTest();

	    	system.assertNotEquals(null, url);
	    	system.assertNotEquals(null, allDocuments);
	    }
    }
        
}