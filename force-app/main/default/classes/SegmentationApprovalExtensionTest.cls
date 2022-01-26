@isTest
private class SegmentationApprovalExtensionTest {
	
	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static User usr = new User();
	
    
    static void setupData(){
    
    	System.runAs(new user(ID = UserInfo.getUserID())){
			usr = TestData_User.setupAdminUser(true);	
			TestData_User.addPermissionSetToUser(usr.Id, 'Approve_Brand_Segmentation');    	
		}		

		account = TestData_Account.setupBrandAccount(1, true);
		contact = TestData_Contact.setupBrandContact('A',account, true);	
	}

	@isTest 
	static void testSegmentationApproval() {
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

		update bsas;
		//-----------------------------------------

		Test.startTest();
		String ErrorValue;
		system.runAs(usr) {
			
	        // Set test page passing initial parameters.
	        PageReference aPage = Page.ApproveSingleSegmentation;
	       // aPage.getParameters().put('AnyVariable', 'Test Value');
	        test.setCurrentPage(aPage);
	 
	        // Instantiate the standard controller
	        Apexpages.StandardController sc = new Apexpages.standardController(bsas[0]);
	 
	        // Instantiate the extension
	        SegmentationApprovalExtension ext = new SegmentationApprovalExtension(sc);

	        PageReference resultPage = ext.approveSegmentationRecord();
	        ErrorValue = ext.errormessage;
    	}
        Test.stopTest();

        //-----------------------------------------
		Brand_Segmentation_Approval__c resultBSA = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c WHERE ID = :bsas[0].Id];

		System.assertEquals(resultBSA.Status__c, 'Approved', 'Status Should be approved.' + ErrorValue);

		// this is great, but we need to make sure that the same values are on the account.
		account = [SELECT ID, Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c FROM Account WHERE ID = :account.ID ];

		System.assertEquals(account.Brand_Gender__c, 'Mixed', 'Brand Gender should be Mixed');
		System.assertEquals(account.Brand_Guest_Relevance__c, 'Europe', 'Brand Guest Relevance should be Europe');
	}
	
	@isTest
 	static void testSegmentationApprovalExtension() {
		setupData();
		List<Brand_Segmentation_Approval__c> brandSegApprovalList = [SELECT ID, Name,Approval_Date__c, Assigned_To__c, Assigned_To__r.Email, Assigned_To__r.Name, Brand__c, Brand__r.Name, Brand_Gender__c,  Brand_Guest_Relevance__c,  Brand_Segment__c,  Brand_Subsegment__c,  Brand_VR_Positioning__c,  Email_Notification_Date__c,  Status__c FROM Brand_Segmentation_Approval__c];

		Test.startTest();
		System.runAs(usr){
			Test.setCurrentPage(Page.ApproveSegmentation);
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(brandSegApprovalList);
			stdSetController.setSelected(brandSegApprovalList);
			SegmentationApprovalExtension segApprovalExt = new SegmentationApprovalExtension(stdSetController);
			segApprovalExt.approveSegmentationRecord();
		}
		Test.stopTest();

	}

}