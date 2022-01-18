trigger ServiceItemTrigger on LGL_Service_Item__c (before update, after update, after insert) {
    
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            LGL_ServiceItemTriggerHandler.updateCheckoutDate(Trigger.oldMap, Trigger.new);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LGL_ServiceItemTriggerHandler.checkAnUpdateCloseServiceRequests(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LGL_ServiceItemTriggerHandler.closeServiceRequests(Trigger.oldMap, Trigger.new);
        }
    }
    
}