trigger Marketing_Campaign_Triggers on Marketing_Campaign__c (before insert,before update, after insert, after update) {
    
    if(Trigger.isBefore){

        if (Trigger.isInsert) {
            MarketingCampaignTriggerHandler.handleBeforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            MarketingCampaignTriggerHandler.handlBeforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //SF-Oracle Integration Callout
            if(!System.isBatch()){
                MarketingCampaignTriggerHandler.handleAfterInsert(Trigger.new);               
            }
        }
     
        if (Trigger.isUpdate) {
            //SF-Oracle Integration Callout
            if(!System.isBatch()) {
                MarketingCampaignTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.new);
            }
        }

    } 
}