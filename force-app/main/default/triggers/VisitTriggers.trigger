trigger VisitTriggers on Visit__c (after update, before update,before insert, after insert, after delete) {

        ByPass_Triggers__c bpt = ByPass_Triggers__c.getInstance(UserInfo.getUserId());
        boolean thisbpt = bpt.ByPass_Triggers__c;
        system.debug('thisbpt1 '+thisbpt);
        
    IF(!thisbpt){
     system.debug('thisbpt2 '+thisbpt);
    try {
        set<Id> visitIds = new set<Id>();
        if(trigger.isUpdate && trigger.isAfter){
            for (Visit__c v : trigger.new){
                if(trigger.oldMap.get(v.id).No_Show__c == false &&  v.No_Show__c == true){
                    visitIds.add(v.Id);
                }
            }
            if (!visitIds.isEmpty() )
                VisitTriggerHelper.setNoShow(visitIds);     
        }
        if((trigger.isInsert || trigger.isUpdate || trigger.isDelete ) && trigger.isAfter){
           if (!VisitTriggerHelper.processVisit){
            VisitTriggerHelper.processVisitAfter(trigger.oldMap, trigger.newMap);
           }
        }
        if(trigger.isUpdate && trigger.isBefore){

            VisitTriggerHelper.onBeforeUpdate(trigger.newMap);
        }
        if(trigger.isInsert && trigger.isBefore){

            VisitTriggerHelper.onBeforeInsert(trigger.new);
            System.debug('SU==> INSERT BEFORE');
        }
        
        
    } catch (exception e){
        system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());    
        // lets also try to add any errors to the error log
        LogFile__c log = new LogFile__c();
        log.Body__c   = 'Visit Trigger Error = ' + e.getMessage() + ' : ' + e.getStackTraceString();
        log.Type__c = 'VisitTriggerError';
        insert log;
    }
    }
}