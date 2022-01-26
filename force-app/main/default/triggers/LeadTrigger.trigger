trigger LeadTrigger on Lead (after update,after insert, before insert, before update){

    IF(trigger.isAfter && trigger.isUpdate){
        LeadTriggerHandler.handlAfterUpdate(trigger.oldmap, trigger.newmap);
        system.debug('after update');
        
        
    }
  
    IF(trigger.isAfter && trigger.isinsert){ 
        if (!LeadTriggerHandler.isAfterInsert){
            LeadTriggerHandler.handleAfterInsert(Trigger.new);
            system.debug('after insert');
        }
    }
  
    IF(trigger.isbefore && trigger.isinsert){ 
        LeadTriggerHandler.handlBeforeInsert(Trigger.new);
         system.debug('before insert');
    }
    
    //IF(trigger.isbefore && trigger.isUpdate){
    //    LeadTriggerHandler.handlebeforeUpdate(trigger.new);
    //     system.debug('before update');
    //}    
    
    
  
}