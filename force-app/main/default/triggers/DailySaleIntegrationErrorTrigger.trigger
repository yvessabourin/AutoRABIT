trigger DailySaleIntegrationErrorTrigger on Daily_Sale_Integration_Error__c (after insert) {

	if(trigger.isInsert && trigger.isAfter){
		
		DailySaleIntegrationErrorTriggerHelper.postNewRecordChatter(trigger.newMap.keySet());
				
	}

    
}