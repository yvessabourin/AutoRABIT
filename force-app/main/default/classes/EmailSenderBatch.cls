// Due to governor limit of only allowing 10 emails to be sent in a single process thread, this batch
// class can be used to accept a list of upto 10 user ids 
global with sharing class EmailSenderBatch implements Database.Batchable<SObject>{

	public list<string> userIdList;
	
	public EmailSenderBatch(list<string> idList){		
		userIdList = idList;		
	}
	    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
		//just run a query, as cannot return null
		return Database.getQueryLocator('select id from user limit 1');       
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        
        // call email sender class to send the email  - userIdList size should not be greater than 10 
        EmailSender.sendDailySaleReminder(userIdList);
    } 
 
    global void finish(Database.BatchableContext BC){
        
    }    
    
}