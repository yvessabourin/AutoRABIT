@isTest
private class apiCustomerControllerTest {
	
	
	private static API_Configuration__c settings = new API_Configuration__c();
	private static User usr = new User();
	private static User usr2 = new User();
	private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

	static void setupCustomSettings(){

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

    	insert settings;				
	}
	
	static void setupMessages(){
		
		multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Villages', 'TestAPI_Villages');
		multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Languages', 'TestAPI_Languages');
		multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Genders', 'TestAPI_Genders');
		multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Countries', 'TestAPI_Countries');
		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c , 'TestAPI_GoodGuest');
		
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
				
	    	setupCustomSettings();
		}

		setupMessages();

	}
	
    static testMethod void testCreateReadGuest() {
     	
     	setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
    	PageReference pg = new PageReference('/apex/apiCustomer');
    	Test.setCurrentPage(pg);
    	PageReference pg1 = null;
    	
    	
	
		system.runAs(usr2){
			
	    	test.startTest();
		    	multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/123456-7890-1234-1234-123456789012' + '?subscription-key=' + settings.Api_key__c, 'TestAPI_GoodGuest');
		    	
		    	list<Account> accountList = new list<account>();				    	
		    	Apexpages.StandardSetcontroller stdSetController = new Apexpages.StandardSetcontroller(accountList);
				apiCustomerController controller = new apiCustomerController(stdSetController);
		
				pg1 = controller.saveCustomer();
		        
		        			
			test.stopTest();
			
			Account a = [select Id, Customer_GUID__c from Account where PersonEmail = 'Jay@tee.com'];
	        
	        system.assert(pg1.getUrl().indexOf(a.id) > -1);
	        



		}    	
    	
        
    }
	
	static testmethod void readGuest(){

		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
		}
		
        system.runAs(usr){
			test.startTest();

 			multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
  			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c + '/' + a.Customer_GUID__c , 'TestAPI_Preferences');
  
			PageReference pg = new PageReference('/apex/apiCustomer?Id=' + a.Id);
	    	Test.setCurrentPage(pg);
    	 				       
	    	list<Account> accountList = new list<account>();				    	
	    	Apexpages.StandardSetcontroller  stdSetController = new Apexpages.StandardSetcontroller(accountList);
			apiCustomerController controller = new apiCustomerController(stdSetController);

	        //just for coverage...
	        PageReference pg1 = controller.cancel();		
					
			test.stopTest();
        }
		//pg1 = controller.saveCustomer();
		
	}

	static testmethod void readGuestMobile(){

		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
		}
		
        system.runAs(usr){
			test.startTest();

 			multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
  			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c + '/' + a.Customer_GUID__c , 'TestAPI_Preferences');

			string s = apiCustomerController.readGuest(a.Id);
			
			system.assert(s.indexOf(a.Customer_GUID__c) > -1);
					
			test.stopTest();
        }
		
	}
	
	
	static testmethod void saveGuestMobile(){
		
		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
		}
 			
 		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
  		multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c + '/' + a.Customer_GUID__c , 'TestAPI_Preferences');
		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c , 'TestAPI_UpdateGuest');
		
        system.runAs(usr){
			test.startTest();		
			
			string s = apiCustomerController.saveGuest(a.Id, 'Mr', 'Jay', 'Tee', 'Male', '05/05/1955', '', 'jay@tee.com',
														'','','','','','','','','SFTIC','1','0','0');
			
			system.assert(s.indexOf(a.Id) > -1);


			s = apiCustomerController.saveGuest('', 'Mrs', 'Jay', 'Tee', 'Female', '05/05/1955', '', 'mrsjay@tee.com',
														'','','','','','','','','SFTIC','1','0','0');			
    		test.stopTest();							
        }
        
	}
		
	static testmethod void readDropdownsMobile(){
		
		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        system.runAs(usr){
        	test.startTest();
	        string s = apiCustomerController.getDropdownValues();
	        
	        s = apiCustomerController.getLeadSourceTextValues();
	        
	        s = apiCustomerController.getDefaultVillage();
	        
	        s =  apiCustomerController.getDefaultLanguage();
	
			test.stopTest();        
        }
	}

	static testMethod void testUpdateEmailMobile(){

		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;

		}
 			
 		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
 		multimock.setStaticResource(settings.Api_Host__c + settings.Email_Change__c + '/' + a.Customer_GUID__c , 'TestAPI_UpdateEmailResponse');
 		
        system.runAs(usr){
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone, PersonEmail from Account where PersonEmail = 'Jay@tee.com'];
			test.startTest();

			string s = apiCustomerController.saveEmailfromMobile(a.Customer_Guid__c, a.PersonEmail, 'Jay2@tee.com');

 							
			test.stopTest();
        }

				
	}

	static testMethod void testDeleteGuest(){

		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;

		}
 			
 		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
 		multimock.setStaticResource(settings.Api_Host__c + settings.Email_Change__c + '/' + a.Customer_GUID__c , 'TestAPI_DeleteGuestResponse');
 		
        system.runAs(usr){
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone, PersonEmail from Account where PersonEmail = 'Jay@tee.com'];
			test.startTest();

			string s = apiCustomerController.deleteGuest(a.Id);

 							
			test.stopTest();
        }

				
	}
			
	static testmethod void updateGuest(){

		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
		}
 			
 		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
  		multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c + '/' + a.Customer_GUID__c , 'TestAPI_Preferences');
		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c , 'TestAPI_UpdateGuest');
		
        system.runAs(usr){
			test.startTest();

 			PageReference pg = new PageReference('/apex/apiCustomer?Id=' + a.Id);
	    	Test.setCurrentPage(pg);
    	 				       
	    	list<Account> accountList = new list<account>();				    	
	    	Apexpages.StandardSetcontroller  stdSetController = new Apexpages.StandardSetcontroller(accountList);
			apiCustomerController controller = new apiCustomerController(stdSetController);
		
			controller.customer.properties.item[1].y_text = 'German';
			controller.customer.address.x_Country =  'Germany';
			
			
			PageReference pg1 = controller.saveCustomer();
					
			test.stopTest();
        }

		a = [select Id, Customer_GUID__c, Country_of_Residence__c, Preferred_Language__c, PersonMailingCountry 
					 from Account where PersonEmail = 'Jay@tee.com'];
		
		system.assertEquals(a.Preferred_Language__c, 'German');
		system.assertEquals(a.PersonMailingCountry, 'Germany');
		system.assertEquals(a.Country_of_Residence__c, 'Germany');
		
	}
	
	static testMethod void testUpdateEmail(){

		setupData();

		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;

		}
 			
 		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
 		multimock.setStaticResource(settings.Api_Host__c + settings.Email_Change__c + '/' + a.Customer_GUID__c , 'TestAPI_UpdateEmailResponse');
 		
        system.runAs(usr){
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone, PersonEmail from Account where PersonEmail = 'Jay@tee.com'];
			test.startTest();

 			PageReference pg = new PageReference('/apex/apiCustomerEmail?Id=' + a.Id + '&guid=' + a.Customer_GUID__c + '&currentEmail=' + a.PersonEmail);
	    	Test.setCurrentPage(pg);
    	 				       
	    	list<Account> accountList = new list<account>();				    	
	    	Apexpages.Standardcontroller  stdController = new Apexpages.Standardcontroller(a);
			apiCustomerController controller = new apiCustomerController(stdController);
			
			controller.newEmail = 'Jay2@tee.com';
			
			
			controller.saveEmail();

 							
			test.stopTest();
        }


				
	}
	
	static testMethod void testUpdateError(){

		setupData();
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a  = null;
		
		system.runAs(usr2){
			a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
			insert a;
			
			a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
		}
 			
 		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
  		multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c + '/' + a.Customer_GUID__c , 'TestAPI_Preferences');
		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c , 'TestAPI_UpdateGuest');
		
        system.runAs(usr){
			test.startTest();

 			PageReference pg = new PageReference('/apex/apiCustomer?Id=' + a.Id);
	    	Test.setCurrentPage(pg);
    	 				       
	    	list<Account> accountList = new list<account>();				    	
	    	Apexpages.StandardSetcontroller  stdSetController = new Apexpages.StandardSetcontroller(accountList);
			apiCustomerController controller = new apiCustomerController(stdSetController);
		
			controller.customer.properties.item[1].y_text = 'German';
			controller.customer.address.x_Country =  'Germany';
			
			multimock.setStatusCode(400); //force error
			PageReference pg1 = controller.saveCustomer();
			
			List<Apexpages.Message> msgs = ApexPages.getMessages();	
			boolean b = false;
			for(Apexpages.Message msg:msgs){
			    if (msg.getDetail().contains('There was an error updating Customer data')) b = true;
			}
			system.assert(b);		        
		        			
			test.stopTest();

		}    			
		
		
	}

	static testMethod void testReadError(){

     	setupData();

		multimock.setStatusCode(400);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
    	PageReference pg = new PageReference('/apex/apiCustomer');
    	Test.setCurrentPage(pg);
    	PageReference pg1 = null;

		system.runAs(usr){
			
	    	test.startTest();
		    	
		    	list<Account> accountList = new list<account>();				    	
		    	Apexpages.StandardSetcontroller stdSetController = new Apexpages.StandardSetcontroller(accountList);
				apiCustomerController controller = new apiCustomerController(stdSetController);

				List<Apexpages.Message> msgs = ApexPages.getMessages();
				boolean b = false;
				for(Apexpages.Message msg:msgs){
				    if (msg.getDetail().contains('The system is not available at present')) b = true;
				}
				system.assert(b);		        
		        			
			test.stopTest();

		}    			
		
		
	}
	
	static testMethod void testUpdateIdBatchProcess(){
      	
      	setupCustomSettings();
      	setupMessages();


		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
		Account a = null;
		Account a2 = null;
		
    	//system.runAs(usr2){    			      	
	      	test.startTest();
				a = new Account(PersonEmail='Jay@tee.com', Customer_GUID__c = '123456-7890-1234-1234-123456789012', FirstName = 'Jay', LastName = 'tee');
				insert a;
				a = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay@tee.com'];
				
				a2 = new Account(PersonEmail='Jay2@tee.com', Customer_GUID__c = '123456-7890-1234-1234-000000000000', FirstName = 'Jay', LastName = 'tee');
				insert a2;
				a2 = [select Id, Customer_GUID__c, PersonMobilePhone from Account where PersonEmail = 'Jay2@tee.com'];
				
				multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/' + a.Customer_GUID__c , 'TestAPI_GoodGuest');
				
        		Integration_Salesforce_Id_Queue__c q = new Integration_Salesforce_Id_Queue__c();
        		q.Salesforce_Id__c = a.Id;
        		q.Customer_GUID__c = a.Customer_GUID__c;	
        		insert q;

        		Integration_Salesforce_Id_Queue__c q2 = new Integration_Salesforce_Id_Queue__c();
        		q2.Salesforce_Id__c = a2.Id; 
        		q2.Customer_GUID__c = a2.Customer_GUID__c;	
        		insert q2; //to force a retry (no read message for GUID)
        			        		
				apiCustomerSFIDUpdateBatch batchUpdate = new apiCustomerSFIDUpdateBatch();
				Database.executeBatch(batchUpdate);
				
				
			test.stopTest();
    	//}
    	
		list<Integration_Salesforce_Id_Queue__c> qList = [select Salesforce_Id__c, Customer_GUID__c, Error_Details__c
																 from Integration_Salesforce_Id_Queue__c];

		system.assertEquals(qList.size(), 1);
		system.assertEquals(qList[0].Customer_GUID__c, a2.Customer_GUID__c);
		system.debug(' @@@ ' + qList[0].Error_Details__c);
		system.assert(qList[0].Error_Details__c.length() > 1);
		
	
	}		
}