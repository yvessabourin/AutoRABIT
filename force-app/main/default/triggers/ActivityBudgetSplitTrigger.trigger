trigger ActivityBudgetSplitTrigger on Activity_Budget_Split__c (before insert, before update) {


    if(trigger.isBefore && trigger.isinsert){
        ActivityBudgetSplitTriggerHelper.SetDefaultCurrency(trigger.new);
            ActivityBudgetSplitTriggerHelper.handleBeforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isupdate){
        ActivityBudgetSplitTriggerHelper.SetDefaultCurrency(trigger.new);
    }
   

}