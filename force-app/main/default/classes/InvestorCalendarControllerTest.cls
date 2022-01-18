@isTest
private class InvestorCalendarControllerTest {

    private static final id invEnvRecordTypeID = Schema.SObjectType.Event.RecordTypeInfosByName.get('Investor Meeting').RecordTypeId; 
    private static final id invAccRecordTypeID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Investor').RecordTypeId; 
    //private static final id invConRecordTypeID = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Investor Contact').RecordTypeId; 

 
	@testSetup 
    static void setup() {
		Account account = new Account(Name='Test Invest Ltd', RecordTypeId=invAccRecordTypeID);
		insert account;
		
		//Contact contact = new Contact(LastName = 'Cash', email='cash@test.com', AccountId = account.Id, RecordTypeId = invConRecordTypeID);
        Contact contact = new Contact(LastName = 'Cash', email='cash@test.com', AccountId = account.Id);

		insert contact;
		
		list<Event> eventList = new list<Event>();
		
		for (integer i = 0; i < 3; i++){
        	Event event = new Event(whatId = account.Id, whoId = contact.Id, RecordTypeId=invEnvRecordTypeID,
        						StartDateTime = system.now().addDays(i), EndDateTime = system.now().addDays(i),
								Subject = 'TestMeeting' + i, OwnerID = UserInfo.getUserId() );
			eventList.add(event);
		}
		
		insert eventList;			
    }
    
    static testMethod void unitTest() {
		
		InvestorCalendarController controller = new InvestorCalendarController();
		PageReference pg = controller.pageLoad();
		
		list<InvestorCalendarController.calEvent> calEvents = controller.events;
		
		system.assertEquals(calEvents.size(), 3);
		
		pg =  controller.toggleMyEvents();
		
		calEvents = controller.events;
		
		system.assertEquals(calEvents.size(), 6);
		
		pg =  controller.toggleMyEvents();
		
		system.assert(!controller.includeMyEvents);
		
		
        
    }
}