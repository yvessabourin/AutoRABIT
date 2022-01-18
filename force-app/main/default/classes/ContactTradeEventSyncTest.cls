@isTest

private class ContactTradeEventSyncTest {
	
	private static Trade_Event__c tradeEvent;	
	private static Account account;
	private static Contact contact;
	
	static void setupData(){
		
		account = TestData_Account.setupTourismAccount(1, true);
		contact = TestData_Contact.setupTourismContact('test', account, true);
		
		tradeEvent = new Trade_Event__c(Name = 'Test Event', Event_Date__c = system.today());
		insert tradeEvent;
		
		
	}
	
    static testMethod void unitTest() {
        
        setupData();
        
        Trade_event_attendee__c attendee = new Trade_Event_Attendee__c(Trade_Event__c = tradeEvent.Id, Contact__c = contact.Id);
        
        test.startTest();
        	
        	//test new attendee
        	insert attendee;
        	contact = [select Latest_Trade_Events_Attended__c from Contact where Id = :contact.Id];
        	
        	system.assert(contact.Latest_Trade_Events_Attended__c.contains(tradeEvent.Name));
        
        	// test update to trade event name
        	tradeEvent.Name = 'Updated Name';
        	update tradeEvent;
        	
			contact = [select Latest_Trade_Events_Attended__c from Contact where Id = :contact.Id];        	
        	system.assert(contact.Latest_Trade_Events_Attended__c.contains(tradeEvent.Name));        	
        	
 			// test attendee deletion
 			delete attendee;
 			
 			contact = [select Latest_Trade_Events_Attended__c from Contact where Id = :contact.Id];        	
        	system.assert(string.isBlank(contact.Latest_Trade_Events_Attended__c)); 
        				       
        test.stopTest();
        
        
    }
}