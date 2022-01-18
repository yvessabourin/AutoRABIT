trigger CaseTriggers on Case (after update) {

    if(trigger.isafter && trigger.isUpdate){
        caseTriggerHandler.handleAfterInsert(trigger.oldMap, trigger.newMap); 
    }

}