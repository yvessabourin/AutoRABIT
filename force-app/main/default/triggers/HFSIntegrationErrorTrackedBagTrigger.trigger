trigger HFSIntegrationErrorTrackedBagTrigger on HFS_IntegrationErrorTrackedBag__c (before update, before delete) {
	if(Trigger.isBefore){
		if(Trigger.isUpdate){
			IntegrationErrorTrackedBagTriggerHandler.checkBagList(Trigger.new);
		}
		if(Trigger.isDelete){
			IntegrationErrorTrackedBagTriggerHandler.checkIfResolved(Trigger.old);
		}
	}
}