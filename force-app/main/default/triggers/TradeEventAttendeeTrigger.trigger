trigger TradeEventAttendeeTrigger on Trade_Event_Attendee__c (after insert, after delete) {

	
	if (trigger.isAfter && trigger.isInsert){
		// call method to sync contact field with latest trade events attended
		ContactTradeEventSync.syncContactTradeEvents(trigger.newMap.keySet());	
	}
	
	if (trigger.isAfter && trigger.isDelete){		
		// call method to sync contact field with latest trade events attended
		ContactTradeEventSync.syncContactTradeEvents(trigger.oldMap.keySet());	
	}

}