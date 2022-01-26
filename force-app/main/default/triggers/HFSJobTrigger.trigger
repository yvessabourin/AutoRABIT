trigger HFSJobTrigger on HFS_Job__c (before update) {
	if(trigger.isBefore){
        if(trigger.isUpdate){
        	HFSJobTriggerHandler.runnerChangeStatus(trigger.old,trigger.new);
        }
    }
}