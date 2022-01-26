public with sharing class HFSJobTriggerHandler{
	
	public static void runnerChangeStatus(List<HFS_Job__c> oldEditedJobs, List<HFS_Job__c> newEditedJobs){

		Id runnerId = UserInfo.getUserId();
		Id profileId = UserInfo.getProfileId();
		Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: profileId];
		List<HFS_Runner__c> allhfsRunner = [SELECT Id, Name, User__c FROM HFS_Runner__c];
		
		for(HFS_Runner__c hfsRunner : allhfsRunner){
			if(hfsRunner.User__c == runnerId){
				for(HFS_Job__c oneOldJob : oldEditedJobs){			
					for(HFS_Job__c oneNewJob : newEditedJobs){
						if(oneOldJob.Take_job_for_me__c == false && oneNewJob.Take_job_for_me__c == true){
							oneNewJob.HFS_Runner__c = hfsRunner.Id;
							oneNewJob.Job_Status__c = 'Accepted';
						} else if(oneOldJob.Assigned_to_me__c == false && profile.Name == 'HFS Runner'){
							oneNewJob.addError('This job is already assigned to another runner');
						}

						if(oneOldJob.Reject_Job__c == false && oneNewJob.Reject_Job__c == true){
							oneNewJob.Job_Status__c = 'Rejected';
							oneNewJob.Rejected_By__c = hfsRunner.Name;
							oneNewJob.HFS_Runner__c = null;
							oneNewJob.Take_job_for_me__c = false;
						}
					}
				}
			}
		}
	}
}