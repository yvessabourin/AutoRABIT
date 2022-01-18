trigger PETrackedBagTrigger on Tracked_Bag__e (after insert) {
	if(trigger.isAfter){
		if(Trigger.isInsert){
			PETrackedBagTriggerHandler.createPurchase(Trigger.new);
		}
	}
}