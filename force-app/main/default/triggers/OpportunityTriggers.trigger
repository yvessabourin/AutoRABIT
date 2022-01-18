trigger OpportunityTriggers on Opportunity (after insert, after update, before insert, before update) {

    String userName = UserInfo.getUserName();
    system.debug('username = ' + userName); 
    system.debug('label name = ' + label.DeploymentUser);     
    if(userName != label.DeploymentUser){
    
    if(trigger.isBefore && trigger.isInsert){
        OpportunityRatingCalculator.calculateRating(Trigger.new);
    }

    if(trigger.isInsert || trigger.isUpdate){
        

        if (trigger.isUpdate && trigger.isBefore && !ProcessorControl.inFutureContext){     
            //OpportunityProjectionYieldCalculator.calculateProjectionYield(Trigger.old, Trigger.new);
            OpportunityRatingCalculator.calculateRating(Trigger.new);
        }       
        
        if (trigger.isAfter && trigger.isInsert){
            OpportunityTriggerHelper.updateOpportunityName(trigger.newMap, null);
            
            list<Id> oppIds = new List<Id>(trigger.newMap.keySet());
            OpportunitySegmentSynch.syncSegmentationData(oppIds, false);        
        }
        
        if (trigger.isAfter && trigger.isUpdate){
            list<Opportunity> oppList = [select Id from Opportunity where id in :trigger.newMap.keySet()];
            OpportunityTriggerHelper.updateOpportunityName(trigger.newMap, null);
        }
    
        
    }
    }

}