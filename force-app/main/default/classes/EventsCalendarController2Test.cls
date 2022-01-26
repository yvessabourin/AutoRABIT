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
private class EventsCalendarController2Test {

	private static User usr = new User();
	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Event event = new Event();
	private static Village__c village = new Village__c();

	static void setUpData(){

		// Create test admin user
 		usr = TestData_User.setupAdminUser(true);
		 
 		system.runAs(usr){
 	
			account = TestData_Account.setupBrandAccount(1, true);
			contact = TestData_Contact.setupContact('A',account, true);	
						
	 		village = new Village__c();
	 		village.Name = 'TestVillage';
	 		village.B2B_Chatter_Group_Name__c = 'B2BTestVillage';
	 		village.Village_Code__c = 'TV';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
	 		insert village;
			village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'TV' LIMIT 1];


        	event = new Event(Villages_Discussed__c = village.Name, whatId = account.Id, Event_Department__c = 'TestDept',
        						Share__c = false, StartDateTime = system.now(), EndDateTime = system.now(),
        						Village_Activities__c = 'TestVillage - New Contract',
        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
        						Description = 'Test Description');
        	insert event;
        						     						
		}
					
	}

    static testMethod void unitTest() {

   		
   		setupData();
   		
   		PageReference pg = new PageReference('Page.EventsCalendar_v2');

		test.setCurrentPageReference(pg);

		test.startTest();
		
			EventsCalendarController2 ec = new EventsCalendarController2();
			
			EventsCalendarController2.EventWrapperJson data =  EventsCalendarController2.getEvents();
			
			string json = data.eventsJson;
			
			system.assert(json.indexOf(event.Id) > -1);
			
			ec.recordId = event.Id;
			
			ec.getEventRecord();
			
			PageReference pg2 = ec.gotoEvent();
			
			ec.showPopup();
			
			system.assertEquals(ec.displayPopup, true);
			
			ec.closePopup();
			system.assertEquals(ec.displayPopup, false);
			system.assertEquals(ec.recordId, null);
			
		test.stopTest();


    }
}