trigger DealBusinessHistoryTriggers on Deal_Business_History__c (after insert) {

	if (trigger.isAfter && trigger.isInsert){
		DealBusinessUtilities.recordApproval(trigger.newMap.keySet());
	}


}