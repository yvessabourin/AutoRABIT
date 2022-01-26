@isTest
private class SegmentationEmailExtensionTest {
	
	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static User usr = new User();
    
    static void setupData(){
    
		account = TestData_Account.setupBrandAccount(1, true);
		contact = TestData_Contact.setupBrandContact('A',account, true);	
		
		contact.Email = 'testContact@valueretail.com';
		update contact;		  
	    System.runAs(new user(ID = UserInfo.getUserID())){
			usr = TestData_User.setupAdminUser(true);	
			TestData_User.addPermissionSetToUser(usr.Id, 'Email_Brand_Segmentation');    	
		}	          
        
	}

	@isTest 
	static void testSegmentationPendingEmail() {
		setupData();
		// after creating a new brand account, it should trigger the creation of a segmentation approval record.
		List<Brand_Segmentation_Approval__c> bsas = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE Brand__c = :account.Id];
		System.debug('account:===== ' + account.Id);
		System.debug('bsas: ' + bsas);
		System.assertEquals(bsas.size(),1,'There should be a segmentation record created' + bsas);

		// now we can test for approvals of this
		bsas[0].Brand_Gender__c = 'Mixed';
		bsas[0].Brand_Guest_Relevance__c = 'Europe';
		bsas[0].Brand_Segment__c = 'Apparel';
		bsas[0].Brand_Subsegment__c = 'Formal Apparel';
		bsas[0].Brand_VR_Positioning__c = 'Accessible';
		bsas[0].Status__c = 'Pending';
		bsas[0].Assigned_To__c = usr.Id;

		update bsas;
		//-----------------------------------------

		Test.startTest();
		system.runAs(usr) {
	        // Set test page passing initial parameters.
	        PageReference aPage = Page.EmailSingleSegmentation;
	       // aPage.getParameters().put('AnyVariable', 'Test Value');
	        test.setCurrentPage(aPage);
	 
	        // Instantiate the standard controller
	        Apexpages.StandardController sc = new Apexpages.standardController(bsas[0]);
	 
	        // Instantiate the extension
	        SegmentationEmailExtension ext = new SegmentationEmailExtension(sc);

	        PageReference resultPage = ext.emailSegmentationRecord();
    	}
        Test.stopTest();

        //-----------------------------------------
		Brand_Segmentation_Approval__c resultBSA = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE ID = :bsas[0].Id];

		System.assert(resultBSA.Email_Notification_Date__c != null, 'Email Sent Date Should be set.' + resultBSA.Email_Notification_Date__c );

	}

		@isTest 
	static void testSegmentationReqEmail() {
		setupData();
		// after creating a new brand account, it should trigger the creation of a segmentation approval record.
		List<Brand_Segmentation_Approval__c> bsas = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE Brand__c = :account.Id];
		System.debug('account:===== ' + account.Id);
		System.debug('bsas: ' + bsas);
		System.assertEquals(bsas.size(),1,'There should be a segmentation record created' + bsas);

		// now we can test for approvals of this
		bsas[0].Brand_Gender__c = 'Mixed';
		bsas[0].Brand_Guest_Relevance__c = 'Europe';
		bsas[0].Brand_Segment__c = 'Apparel';
		bsas[0].Brand_Subsegment__c = 'Formal Apparel';
		bsas[0].Brand_VR_Positioning__c = 'Accessible';
		bsas[0].Status__c = 'Requesting Approval';
		bsas[0].Assigned_To__c = usr.Id;

		update bsas;
		//-----------------------------------------

		Test.startTest();
		system.runAs(usr) {
	        // Set test page passing initial parameters.
	        PageReference aPage = Page.EmailSingleSegmentation;
	       // aPage.getParameters().put('AnyVariable', 'Test Value');
	        test.setCurrentPage(aPage);
	 
	        // Instantiate the standard controller
	        Apexpages.StandardController sc = new Apexpages.standardController(bsas[0]);
	 
	        // Instantiate the extension
	        SegmentationEmailExtension ext = new SegmentationEmailExtension(sc);

	        PageReference resultPage = ext.emailSegmentationRecord();
    	}
        Test.stopTest();

        //-----------------------------------------
		Brand_Segmentation_Approval__c resultBSA = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE ID = :bsas[0].Id];

		//System.assert(resultBSA.Email_Notification_Date__c != null, 'Email Sent Date Should be set.' + resultBSA.Email_Notification_Date__c );

	}

	@isTest 
	static void testSegmentationRequestingEmailList() {
		setupData();
		// after creating a new brand account, it should trigger the creation of a segmentation approval record.
		//account.Assignment_Type__c = 'Local Village';
		//update account;

		List<Brand_Segmentation_Approval__c> bsas = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE Brand__c = :account.Id];
		System.debug('account:===== ' + account.Id);
		System.debug('bsas: ' + bsas);
		System.assertEquals(bsas.size(),1,'There should be a segmentation record created' + bsas);

		// now we can test for approvals of this
		bsas[0].Brand_Gender__c = 'Mixed';
		bsas[0].Brand_Guest_Relevance__c = 'Europe';
		bsas[0].Brand_Segment__c = 'Apparel';
		bsas[0].Brand_Subsegment__c = 'Formal Apparel';
		bsas[0].Brand_VR_Positioning__c = 'Accessible';
		bsas[0].Status__c = 'Requesting Approval';
		bsas[0].Assigned_To__c = usr.Id;

		update bsas;
		//-----------------------------------------

		Test.startTest();
		system.runAs(usr) {
	        // Set test page passing initial parameters.
	        PageReference aPage = Page.EmailSingleSegmentation;
	       // aPage.getParameters().put('AnyVariable', 'Test Value');
	        test.setCurrentPage(aPage);
	 
	        // Instantiate the standard controller
	        Apexpages.StandardSetController sc = new Apexpages.standardSetController(bsas);
	  		sc.setSelected(bsas);
	        // Instantiate the extension
	        SegmentationEmailExtension ext = new SegmentationEmailExtension(sc);

	        PageReference resultPage = ext.emailSegmentationRecord();
    	}
        Test.stopTest();

	}

	@isTest 
	static void testSegmentationPendingEmailList() {
		setupData();
		// after creating a new brand account, it should trigger the creation of a segmentation approval record.
		//account.Assignment_Type__c = 'Local Village';
		//update account;

		List<Brand_Segmentation_Approval__c> bsas = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE Brand__c = :account.Id];
		System.debug('account:===== ' + account.Id);
		System.debug('bsas: ' + bsas);
		System.assertEquals(bsas.size(),1,'There should be a segmentation record created' + bsas);

		// now we can test for approvals of this
		bsas[0].Brand_Gender__c = 'Mixed';
		bsas[0].Brand_Guest_Relevance__c = 'Europe';
		bsas[0].Brand_Segment__c = 'Apparel';
		bsas[0].Brand_Subsegment__c = 'Formal Apparel';
		bsas[0].Brand_VR_Positioning__c = 'Accessible';
		bsas[0].Status__c = 'Pending';
		bsas[0].Assigned_To__c = usr.Id;

		update bsas;
		//-----------------------------------------

		Test.startTest();
		system.runAs(usr) {
	        // Set test page passing initial parameters.
	        PageReference aPage = Page.EmailSingleSegmentation;
	       // aPage.getParameters().put('AnyVariable', 'Test Value');
	        test.setCurrentPage(aPage);
	 
	        // Instantiate the standard controller
	        Apexpages.StandardSetController sc = new Apexpages.standardSetController(bsas);
	  		sc.setSelected(bsas);
	        // Instantiate the extension
	        SegmentationEmailExtension ext = new SegmentationEmailExtension(sc);

	        PageReference resultPage = ext.emailSegmentationRecord();
    	}
        Test.stopTest();

	}
	
}