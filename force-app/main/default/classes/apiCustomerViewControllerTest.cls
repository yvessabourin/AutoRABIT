@isTest
private class apiCustomerViewControllerTest {

	
	private static API_Configuration__c settings = new API_Configuration__c();
	private static API_Customer_Read_Items__c readSettings = new API_Customer_Read_Items__c();
	private static User usr = new User();
	private static User usr2 = new User();
	private static Account a = new Account();
	private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

	static void setupCustomSettings(){
		
		list<API_Customer_Read_Items__c> readSettingsList = new list<API_Customer_Read_Items__c>();
		
		settings.name = 'API Config LIVE';
    	settings.Api_host__c = 'https://test.apiCustomer.com';
    	settings.Api_key__c = '123456';
    	settings.Customer_Overview__c = '/customerOverview';

    	insert settings;

    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '05 Item';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = false;
    	readSettings.Item_Label__c = 'Opt In Status';
		readSettings.Property_Items__c = 'OPTOUTEMAIL,OPTOUTMOBILE,OPTOUTPOSTAL';        
        
        readSettingsList.add(readSettings);
        
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '10 CustomerStatus';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Customer Status';
    	
    	readSettingsList.add(readSettings);
    	
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '20 Village';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Village Summary';
    	
    	readSettingsList.add(readSettings);
    	
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '30 Visit';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Visits';
    	
    	readSettingsList.add(readSettings);
    	
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '40 Brand';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Brands';
    	
    	readSettingsList.add(readSettings);
    	
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '50 OfferRedemption';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Redemptions';
    	
    	readSettingsList.add(readSettings);
    	
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '60 EmailEvent';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Email Events';
    	
    	readSettingsList.add(readSettings);
    	
    	readSettings = new API_Customer_Read_Items__c();
    	readSettings.Name = '70 CustomerPreference';
    	readSettings.Active__c = true;
    	readSettings.Display_as_Table__c = true;
    	readSettings.Item_Label__c = 'Preferences';
    	
    	readSettingsList.add(readSettings);
    	
    	insert readSettingsList;
	}
				

	static void setupData(){
		
   	// Create user
		usr = TestData_User.setupUser('BillyBones', null, 'System Administrator', true, true);
		usr = [select Id, Name, Village__c from User where Id =:usr.Id];

		
		system.runAs(usr){

			usr2 = TestData_User.setupUser('BarryBones', null, 'System Administrator', true, true);
			usr2 = [select Id, Name from User where Id =:usr.Id];

		 	Village__c village = new Village__c();
		 	village.Name = 'TestVillage';
		 	village.Village_Code__c = 'OO';
		 	village.Integration_Language_Name__c = 'English';
		 	village.Integration_Village_Name__c = 'TestVillage';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
		 	insert village;
		 	
			village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'OO' LIMIT 1];
			
			usr.Village__c = village.Name;
			update usr;

			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
								
	    	setupCustomSettings();
		}

	}
	
    static testMethod void unitTest() {
     	setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
    	PageReference pg = new PageReference('/apex/apiCustomerMobile');
    	Test.setCurrentPage(pg);
    	
    	string msg = '';

		system.runAs(usr2){
			
	    	test.startTest();
		    	multimock.setStaticResource(settings.Api_Host__c + settings.Customer_Overview__c + '/123456-7890-1234-1234-123456789012', 'TestAPI_CustomerOverview');		    	
				    	
		    	
		    	Apexpages.StandardController stdController = new Apexpages.StandardController(a);
				apiCustomerViewController controller = new apiCustomerViewController(stdController);
				
				controller.getReadOnlyItems();
				system.debug(controller.readOnlyMap);
				system.assertEquals(controller.readOnlyMap.get('Brands'), '40 Brand');
				
				system.debug(controller.sortedReadOnlyList);
				system.assertEquals(controller.sortedReadOnlyList[0], 'Opt In Status');
				
				msg = apiCustomerViewController.callReadOnlyService(a.Customer_GUID__c);
		        
		        			
			test.stopTest();
			
			system.debug(msg);
			system.assert(msg.indexOf(a.Customer_GUID__c) > -1);


		}    	
        
    }

    static testMethod void unitTestError() {
     	setupData();

		multimock.setStatusCode(400);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
    	PageReference pg = new PageReference('/apex/apiCustomerMobile');
    	Test.setCurrentPage(pg);
    	
    	string msg = '';

		system.runAs(usr2){
			
	    	test.startTest();
		    	multimock.setStaticResource(settings.Api_Host__c + settings.Customer_Overview__c + '/123456-7890-1234-1234-123456789012', 'TestAPI_CustomerOverview');		    	
				    	
		    	
		    	Apexpages.StandardController stdController = new Apexpages.StandardController(a);
				apiCustomerViewController controller = new apiCustomerViewController(stdController);
				
				controller.getReadOnlyItems();
				
				msg = apiCustomerViewController.callReadOnlyService(a.Customer_GUID__c);
		        
		        			
			test.stopTest();
			
			system.debug(msg);
			system.assert(msg.indexOf('ERROR') > -1);


		}    	
        
    }
}