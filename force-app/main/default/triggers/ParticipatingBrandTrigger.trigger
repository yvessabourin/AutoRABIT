trigger ParticipatingBrandTrigger on Participating_Brand__c (before insert, before update) {

	if(Trigger.isBefore){
		if(Trigger.isInsert){
			ParticipatingBrandTriggerHandler.handleBeforeInsert(Trigger.new);
		}
		else if(Trigger.isUpdate){
			ParticipatingBrandTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
		}
	}
}