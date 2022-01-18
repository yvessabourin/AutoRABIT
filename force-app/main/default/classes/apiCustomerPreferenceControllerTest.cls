@isTest
public with sharing class apiCustomerPreferenceControllerTest {

	private static API_Configuration__c settings = new API_Configuration__c();
	private static API_Preference_Map__c prefSettings1 = new API_Preference_Map__c();
	private static API_Preference_Map__c prefSettings2= new API_Preference_Map__c();
	private static API_Preference_Map__c prefSettings3 = new API_Preference_Map__c();
	private static User usr = new User();
	private static User usr2 = new User();
	private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		
	static void setupData(){
		
   	// Create user
		usr = TestData_User.setupUser('BillyBones', null, 'System Administrator', true, true);
		usr = [select Id, Name from User where Id =:usr.Id];

		usr2 = TestData_User.setupUser('BarryBones', null, 'System Administrator', true, true);
		usr2 = [select Id, Name from User where Id =:usr.Id];
				
		system.runAs(usr){
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

	    	insert settings;
	    	
	    	prefSettings1.Name = 'Opt in Email';
	    	prefSettings1.API_Name__c = 'email';
	    	prefSettings1.Salesforce_Label__c = 'Opt In Email';
	    	insert prefSettings1;
	    	
	    	prefSettings2.Name = 'Opt in Post';
	    	prefSettings2.API_Name__c = 'post';
	    	prefSettings2.Salesforce_Label__c = 'Opt In Post';
	    	insert prefSettings2;
	    	
	    	prefSettings3.Name = 'Opt in Mobile';
	    	prefSettings3.API_Name__c = 'mobile';
	    	prefSettings3.Salesforce_Label__c = 'Opt In Mobile';
	    	insert prefSettings3;
		}

		multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c, 'TestAPI_GoodGuest');
		
		
	}
	
    static testMethod void testReadPreference() {
     	
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
  
			PageReference pg = new PageReference('/apex/apiCustomerPreferences?Id=' + a.Id);
	    	Test.setCurrentPage(pg);
				    	
	    	Apexpages.Standardcontroller  stdController = new Apexpages.Standardcontroller(a);
			apiCustomerPreferenceController controller = new apiCustomerPreferenceController(stdController);

		
			system.assertEquals(controller.customer.preferenceMap.size(), 3);
			
					
			test.stopTest();

		}    	
    	
        
    }

    static testMethod void testUpdatePreference() {
     	
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
  			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c + '/' + a.Customer_GUID__c + '|contactmodes|email', 'TestAPI_Preferences');
 			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c , 'TestAPI_Preferences');
			 
			PageReference pg = new PageReference('/apex/apiCustomerPreferences?Id=' + a.Id);
	    	Test.setCurrentPage(pg);
				    	
	    	Apexpages.Standardcontroller  stdController = new Apexpages.Standardcontroller(a);
			apiCustomerPreferenceController controller = new apiCustomerPreferenceController(stdController);

		
			system.assertEquals(controller.customer.preferenceMap.size(), 3);
			system.assertEquals(controller.customer.preferenceMap.get('Opt in Email'), 'true');
			
			controller.customer.preferenceMap.put('Opt in Email', 'false');
			
			controller.preference = 'Opt in Email';
			controller.savePreference();
			
			system.assertEquals(controller.customer.preferenceMap.get('Opt in Email'), 'false');
					
			test.stopTest();

		}    	
    	
        
    }
	
	static testMethod void testErrorResponse(){

     	setupData();
     	
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

			multimock.setStatusCode(400);
			multimock.setHeader('Content-Type', 'application/xml');
		
  			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c + '/' + a.Customer_GUID__c , 'TestAPI_Preferences');
  		 
			PageReference pg = new PageReference('/apex/apiCustomerPreferences?Id=' + a.Id);
	    	Test.setCurrentPage(pg);
				    	
	    	Apexpages.Standardcontroller  stdController = new Apexpages.Standardcontroller(a);
			apiCustomerPreferenceController controller = new apiCustomerPreferenceController(stdController);

system.debug('@@@@ controller.customer.preferenceMap ' + controller.customer.preferenceMap);		
			system.assert(string.isBlank(controller.customer.preferenceMap.get('Opt in Email')));
			
			multimock.setStatusCode(200);
			controller = new apiCustomerPreferenceController(stdController);

			controller.customer.preferenceMap.put('Opt in Email', 'false');
			
			controller.preference = 'Opt in Email';
  			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c + '/' + a.Customer_GUID__c + '|contactmodes|email', 'TestAPI_Preferences');
 			multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c , 'TestAPI_Preferences');
			
			
			multimock.setStatusCode(400);

			controller.savePreference();			
			
system.debug('@@@@ controller.customer.preferenceMap 2' + controller.customer.preferenceMap);

			List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
			    if (msg.getDetail().contains('The system is not available at present')) b = true;
			}
			system.assert(b);
								
			test.stopTest();

		}    	
		
		
	}
		
	static testmethod void testPreferenceOptions(){
		
		Account a = new Account();
    	Apexpages.Standardcontroller  stdController = new Apexpages.Standardcontroller(a);
		apiCustomerPreferenceController controller = new apiCustomerPreferenceController(stdController);
		
		list<SelectOption> prefOptions = controller.getPreferenceOptions();
		
		system.assert(prefOptions.size() == 3);	
		
	}
	    	    
}