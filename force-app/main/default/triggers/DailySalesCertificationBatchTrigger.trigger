trigger DailySalesCertificationBatchTrigger on Daily_Sales_Certification_Batch__c (after insert, after update, before update) {

    // ***    After Insert ... ***//
	if (trigger.isInsert && trigger.isAfter){
		DSCertificationBatchTriggerHelper.ProcessShares(trigger.new, trigger.newMap.keySet());
	}

    // ***    After Update ... ***//
    if (trigger.isUpdate && trigger.isAfter){
    	DSCertificationBatchTriggerHelper.ProcessShares(trigger.new, trigger.newMap.keySet());
    }
}