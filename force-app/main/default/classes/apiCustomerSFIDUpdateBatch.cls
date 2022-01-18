global class apiCustomerSFIDUpdateBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
 
	global void execute(SchedulableContext SC) {
        Database.executeBatch(new apiCustomerSFIDUpdateBatch());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // Query Integration Salesforce Id queue object
        string soqlStr = 'select Salesforce_Id__c, Customer_GUID__c from Integration_Salesforce_Id_Queue__c' ;
                    
        return Database.getQueryLocator(soqlStr);        
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        
		apiCustomerSFIDUpdate.updateBatchIntegrationSFIDs(scope);
        
    } 
 
    global void finish(Database.BatchableContext BC){
        
    }
        
}