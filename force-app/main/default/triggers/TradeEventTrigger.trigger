trigger TradeEventTrigger on Trade_Event__c (after update) {

	// Where trade event name or date is updated, need to update contact record latest trade events attended field for all associated attendees
	if(trigger.isAfter && trigger.isUpdate){

		// retrieve all attendance records for updated trade events
		map<Id, Trade_Event_Attendee__c> attendeeMap = new map<Id, Trade_Event_Attendee__c>([select Id, Trade_Event__c, Contact__c 
																								from Trade_Event_Attendee__c
		                                                    									where Trade_Event__c in :trigger.newMap.keySet()]);
				
		// call method to sync contact field with latest trade events attended
		ContactTradeEventSync.syncContactTradeEvents(attendeeMap.keySet());		
	}

}