global class UpdateRelatedAccountSchedulable Implements Schedulable {
    
    public List<Id> accidList;
    public String objectType;
    
    global void execute(SchedulableContext sc){
       	List<Account> accListToUpdate = new List<Account>();
        accListToUpdate = [SELECT Id FROM Account WHERE Id IN :accidList];
        
        for(Account acc : accListToUpdate){
            acc.Last_action_date__c = DateTime.now();
            acc.Last_action_type__c = objectType;
        }
        UPDATE accListToUpdate;
    }
	
    public updateRelatedAccountSchedulable(List<Id> idList, String sObjectType){
        accidList = idList;
        objectType = sObjectType;
    }
}