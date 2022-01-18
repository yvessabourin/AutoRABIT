trigger AdbuilderTrigger on Adbuilder__c ( before insert, before update) {

	if(Trigger.isBefore){
 if(trigger.isInsert){
            AdbuilderTriggerHandler.AdbuilderInsert(trigger.new);
            
        }else if(Trigger.isUpdate){
			AdbuilderTriggerHandler.dbuilderBeforeInsert(Trigger.oldMap, Trigger.newMap);
		}
    }    
}