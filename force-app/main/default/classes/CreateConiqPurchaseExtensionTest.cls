@isTest
private class CreateConiqPurchaseExtensionTest {


    private static HFS_IntegrationErrorTrackedBag__c integrationErrorTrackedBag = null;
    private static HFS_IntegrationErrorTrackedBag__c integrationErrorTrackedBagWrong = null;
    private static HFS_IntegrationErrorTrackedBag__c integrationErrorTrackedBagWrong2 = null;

    static void setupData(){
		
		RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];

		integrationErrorTrackedBag = new HFS_IntegrationErrorTrackedBag__c(
			Brand_Lease_Id__c = 'ID0105',
			Brand_Location_Name__c = 'Somewhere',
			DateTime__c = system.today(), 
			Estimated_Spend__c = 25,
			Guest_Code__c = '123456789',
			List_of_Bags__c = '[{"barcode__c": "321121","oversize__c": false},{"barcode__c": "7423432","oversize__c": true},{"barcode__c": "2324212","oversize__c": false}]',
			Number_of_Bags__c = 3,
			Is_Resolved__c = false);
		insert integrationErrorTrackedBag;
		
		integrationErrorTrackedBagWrong = new HFS_IntegrationErrorTrackedBag__c(
			Brand_Lease_Id__c = 'ID01056',
			Brand_Location_Name__c = 'Somewhere',
			DateTime__c = system.today(), 
			Estimated_Spend__c = 25,
			Guest_Code__c = '12345678',
			List_of_Bags__c = '[{"barcode__c": "321121","oversize__c": false},{"barcode__c": "7423432","oversize__c": true},{"barcode__c": "2324212","oversize__c": false},{"barcode__c": "9999999","oversize__c": false},{"barcode__c": "9999999","oversize__c": false}]',
			Number_of_Bags__c = 5,
			Is_Resolved__c = false);
		insert integrationErrorTrackedBagWrong;

		integrationErrorTrackedBagWrong2 = new HFS_IntegrationErrorTrackedBag__c(
			Brand_Lease_Id__c = 'ID0105',
			Brand_Location_Name__c = 'Somewhere',
			DateTime__c = system.today(), 
			Estimated_Spend__c = 25,
			Guest_Code__c = '123456789',
			List_of_Bags__c = '[{"barcode__c": "321121","oversize__c": false},{"barcode__c": "2312","oversize__c": false}]',
			Number_of_Bags__c = 5,
			Is_Resolved__c = false);
		insert integrationErrorTrackedBagWrong2;

		Logging_Enabled__c logEnabled = new Logging_Enabled__c(
			Name = 'PETrackedBagTriggerHandler');
		insert logEnabled;

		Village__c vill = TestDataGenerator.setupVillage(false);
        vill.Oracle_Source_Template_Number__c = '123456';
        vill.Oracle_Organisation__c = 'SourceOrg';
        vill.Name = 'Bicester';
		vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        insert vill;

		Case guestCase = new Case();
        guestCase.Village__c = vill.Id;
        guestCase.Service_Guest_ID__c = '123456789';
        guestCase.Service_Guest_Number__c = 'XA1';
        guestCase.Guest_ID_Number_Part__c = 12;
        guestCase.Payment_Status__c = 'Paid';
        guestCase.Client_QR_Code__c = '123456789';
        guestCase.Status = 'New';
        guestCase.Origin = 'Email';
        guestCase.Service_Date__c = system.today();
        insert guestCase;

        Account brand = new Account();
        brand.RecordTypeId = brandRecordType.Id;
        brand.Name = 'Brand 1';
        insert brand;

        Village_Presence__c presentBrand = new Village_Presence__c();
        presentBrand.Name = 'Brand1 in village';
        presentBrand.Brand__c = brand.Id;
        presentBrand.Village__c = vill.Id;
        presentBrand.Lease_Id__c = 'ID0105';
        insert presentBrand;

        Case_Item__c purchaseNew = new Case_Item__c();
        purchaseNew.Case__c = guestCase.Id;
        purchaseNew.Status__c = 'Awaiting Pick-up from Brand';
        purchaseNew.Start_Time__c = system.now();
        purchaseNew.Item_Count__c = 3;
        purchaseNew.Bag_Barcodes_Manual__c = '2312,false,123457,true,152635,false';
        purchaseNew.Require_a_Runner__c = true;
        purchaseNew.HFS_Bag_Transfer__c = false;
        purchaseNew.Village_Presence__c = presentBrand.Id;
        insert purchaseNew;

        HFS_Bag__c newBag = new HFS_Bag__c();
        newBag.Barcode__c = '2312';
        newBag.HFS_Bag_Active__c = true;
        newBag.HFS_Purchase__c = purchaseNew.Id;
        insert newBag;
	}

	static testMethod void verifyIfRunsCorrectly() {

		setupData();

		test.startTest();
			//Page reference to the VF page
			PageReference pageRef = Page.CreateConiqPurchasePage;
            Test.setCurrentPage(pageRef);
            //Pass the object to controller
            ApexPages.StandardController stdController = new ApexPages.StandardController(integrationErrorTrackedBag);
            //Call the controller
            CreateConiqPurchaseExtension controller = new CreateConiqPurchaseExtension(stdController);
            //Call method using controller ref
            controller.createConiqPurchase();
		test.stopTest();

		HFS_IntegrationErrorTrackedBag__c checkVar = [SELECT Id, Is_Resolved__c FROM HFS_IntegrationErrorTrackedBag__c WHERE Id =: integrationErrorTrackedBag.Id];
		System.assertEquals(true, checkVar.Is_Resolved__c);
	}

	static testMethod void verifyIfBagIsRepeated(){

		setupData();

		test.startTest();
		//Page reference to the VF page
			PageReference pageRef = Page.CreateConiqPurchasePage;
            Test.setCurrentPage(pageRef);
            //Pass the object to controller
            ApexPages.StandardController stdController = new ApexPages.StandardController(integrationErrorTrackedBagWrong);
            //Call the controller
            CreateConiqPurchaseExtension controller = new CreateConiqPurchaseExtension(stdController);
            //Call method using controller ref
            controller.createConiqPurchase();
		test.stopTest();

		List<LogFile__c> checkLogs = [SELECT Name FROM LogFile__c];
		System.assertEquals(false, checkLogs.isEmpty());	
	}

	static testMethod void verifyIfBarCodeAlreadyExists(){

		setupData();

		test.startTest();
		//Page reference to the VF page
			PageReference pageRef = Page.CreateConiqPurchasePage;
            Test.setCurrentPage(pageRef);
            //Pass the object to controller
            ApexPages.StandardController stdController = new ApexPages.StandardController(integrationErrorTrackedBagWrong2);
            //Call the controller
            CreateConiqPurchaseExtension controller = new CreateConiqPurchaseExtension(stdController);
            //Call method using controller ref
            controller.createConiqPurchase();
		test.stopTest();

		List<LogFile__c> checkLogs = [SELECT Name FROM LogFile__c];
		System.assertEquals(false, checkLogs.isEmpty());			
	}
}