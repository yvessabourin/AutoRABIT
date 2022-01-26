/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TradeEventRestSvcTest {

	private static Trade_Event__c tradeEventToday = null;
	private static Trade_Event__c tradeEvent = null;
	private static Account account = null;
	
	static void setupData(){
		
		tradeEventToday = new Trade_Event__c(Description__c = 'Test Event 1', Event_Date__c = system.today(), location__c = 'London');
		insert tradeEventToday;
		
		tradeEvent = new Trade_Event__c(Description__c = 'Test Event 2', Event_Date__c = system.today() + 7, location__c = 'London');
		insert tradeEvent;
		
		account = TestData_Account.setupTourismAccount(1, true);
	}
	

	static testMethod void getTest() {
        
        setupData();

  		RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
		string sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
		
    	req.requestURI = sfdcURL + '/services/apexrest/v.1.0/tradeevents';  
    	req.httpMethod = 'GET';        

   		RestContext.request = req;
    	RestContext.response = res;
    	
    	test.startTest();
			list<Sobject> returnListAll = TradeEventRestSvc.doGet();
			
			req.requestURI = sfdcURL + '/services/apexrest/v.1.0/tradeevents/today';
			list<Sobject> returnListToday = TradeEventRestSvc.doGet();
			
			req.requestURI = sfdcURL + '/services/apexrest/v.1.0/tradeevents/accounts';
			list<Sobject> returnListAccounts = TradeEventRestSvc.doGet();
			
    	test.stopTest();
    	
		system.assertEquals(returnListAll.size(), 2);
		
		system.assertEquals(returnListToday.size(), 1);
		system.assertEquals(returnListToday[0].get('Id'), tradeEventToday.Id);
		
		system.assertEquals(returnListAccounts.size(), 1);
		system.assertEquals(returnListAccounts[0].get('Id'), account.Id);		
         
    }

	static testMethod void postTest() {
        
        setupData();
  		RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
		string sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
		
    	req.requestURI = sfdcURL + '/services/apexrest/v.1.0/tradeevents/attendee';  
    	req.httpMethod = 'POST';
    	req.addHeader('Content-Type', 'application/json');
    	
    	string jsonRequest = '{ "tradeeventid": ' + '"' + tradeEventToday.Id + '"' 
  								+ ' , "accountname":' + '"' + account.Name + '"' 
  								+ ' , "email":"test@test.com"'
  								+ ' , "firstname": "John"'
  								+ ' , "lastname": "Smith"'
  								+ ' , "title": "Director"'
  								+ ' , "mobile": "0777888999"'
  								+ ' , "phone": "0200123222"'
  								+ ' , "notes": "Could be a good contact" }';
  								

    	req.requestBody = Blob.valueOf(jsonRequest);
    	RestContext.request = req;
    	RestContext.response = res;
    	
    	test.startTest();
			Sobject returnAttendee  = TradeEventRestSvc.doPost();
    	test.stopTest();
    	
		Contact contact = [select FirstName, LastName from Contact where Email = 'test@test.com'];
		system.assertEquals(contact.FirstName, 'John');     
        system.assertEquals(contact.LastName, 'Smith');	
	
	}
}