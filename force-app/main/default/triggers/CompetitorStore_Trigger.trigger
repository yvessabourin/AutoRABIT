trigger CompetitorStore_Trigger on Competitor_Store__c (after insert, after update) {

	if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		if (!CompetitorStoreTriggerHelper.hasUpdated){
			CompetitorStoreTriggerHelper.LinkVillagePresence(trigger.newMap);
		}
	} 
    
    
}