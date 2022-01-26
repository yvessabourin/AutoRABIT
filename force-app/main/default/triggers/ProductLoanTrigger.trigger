trigger ProductLoanTrigger on Product_Loan__c (before Insert, before Update, After Insert, After Update) {

        if(trigger.isBefore && trigger.isInsert){
            //productLoanTriggerhandler.isBeforeisInsert(trigger.new);        
        }

        if(trigger.isBefore && trigger.isUpdate){
            //productLoanTriggerhandler.isBeforeUpdate(trigger.new);      
        }
        
        
        if(trigger.isAfter && trigger.isInsert){
            //productLoanTriggerhandler.isAfterInsert(trigger.newmap);        
        }

        if(trigger.isAfter && trigger.isUpdate){
            //productLoanTriggerhandler.isAfterUpdate(trigger.oldMap, trigger.newmap);  
        }

}