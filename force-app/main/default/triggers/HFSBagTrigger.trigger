trigger HFSBagTrigger on HFS_Bag__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            HFSBagTriggerHandler.insertedBagsUpdate(trigger.new);
        }
    }
}