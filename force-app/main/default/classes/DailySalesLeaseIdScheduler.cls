public class DailySalesLeaseIdScheduler implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{

    
    public void execute(SchedulableContext SC) {
		Database.executeBatch(new DailySalesLeaseIdScheduler(), 50);    
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC){
        
        
        // Query Daily Sales records for records missing a lease id 
        string soqlStr = 'select Id from Daily_Sale__c where Lease_Id__c = null and Status__c != \'Not Valid\' ';
                    
        return Database.getQueryLocator(soqlStr);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> scope){
    
        set<Id> dsIds = new set<Id>();
        for ( Sobject ds :scope){
            dsIds.add(string.valueOf(ds.get('Id')));            
        }
        
        DailySaleTriggerHelper.getLeaseIds(dsIds);
        
        
    }

	public void finish(Database.BatchableContext BC){
    
    }    
    
}