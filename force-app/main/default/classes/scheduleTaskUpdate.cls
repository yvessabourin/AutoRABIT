global with sharing class scheduleTaskUpdate implements Schedulable {
	
	global set<Id> taskIdList;
	
    global void execute(SchedulableContext SC) {
		TaskTriggerHelper.RetailLiveCheck(taskIdList);
    }

    public scheduleTaskUpdate (set <Id> taskIds) {
		taskIdList = taskIds;
		
    }
    
}