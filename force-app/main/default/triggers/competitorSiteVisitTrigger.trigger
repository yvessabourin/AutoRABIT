trigger competitorSiteVisitTrigger on Competitor_Visit__c (before insert, after insert, before update, after update) {


    if(trigger.isBefore && trigger.isInsert){
        competitorSiteVisitTriggerHandler.handleBeforeInsert();
    }
    
    
    if(trigger.isAfter && trigger.isInsert){
        competitorSiteVisitTriggerHandler.handleAfterInsert();
    }
    
    
    if(trigger.isBefore && trigger.isUpdate){
        competitorSiteVisitTriggerHandler.handleBeforeUpdate();
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        competitorSiteVisitTriggerHandler.handleAfterUpdate(trigger.oldMap, trigger.newMap);
    }



}