trigger CaseItemTrigger on Case_Item__c (after insert){
	if(trigger.isAfter){
		if(trigger.isInsert){
			CaseItemTriggerHandler.createNewJobandBags(trigger.new);
		}
	}
}