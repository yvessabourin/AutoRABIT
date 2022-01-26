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
private class MobileEventsSearchControllerTest {

	private static Account account = new Account();
	private static Event event = new Event();


	static void setUpData(){
	
		account = TestData_Account.setupBrandAccount(1, true);

        event = new Event(whatId = account.Id, Event_Department__c = 'TestDept',
        						StartDateTime = system.now(), EndDateTime = system.now(),
       							Event_Headline__c = 'Test Headline',
        						Description = 'Test Description contains the string Find my event',
        						Auto_Create_Tasks__c = false,
        						Share__c = false);
        
        insert event;
        						
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = event.Id;
        test.setFixedSearchResults(fixedSearchResults);
			
		
	}
 
    static testMethod void myUnitTest() {
 
        setUpData();

        						   	
    	PageReference pg = new PageReference('Page.ProcessImportFile');
		pg.getParameters().put('searchString', 'Find my event');     	
		
		test.setCurrentPageReference(pg);
 
 		test.startTest();	
			MobileEventsSearchController controller = new MobileEventsSearchController(null);
			
			// check search parameter
			string criteria = controller.getsearchString();
    		system.assertEquals(criteria, 'Find my event');
    		
    		// perform search
    		controller.DoSearch();
    		
    		// check results
    		system.assertEquals(controller.resultsList.size(), 1);   		
    		system.assertEquals(controller.resultsList[0].Id, event.Id);
    		
    		// reset search string and check
    		controller.setsearchString('amended search string');
			criteria = controller.getsearchString();
    		system.assertEquals(criteria, 'amended search string');    		
    		    	
    	test.stopTest();
    }



}