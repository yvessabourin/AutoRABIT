trigger VIPBrandPreferenceTrigger on VIP_Brand_Preference__c ( before insert, before update) {

 if(trigger.isBefore && trigger.isInsert){
        VIPBrandPreferenceUtilities.defaultName(trigger.new);
        
 }

 if (trigger.isBefore && trigger.isUpdate){
        VIPBrandPreferenceUtilities.defaultNameOnUpdate(trigger.old, trigger.new);
 }

}