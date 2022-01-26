global class B2BEventsEmailScheduler implements Schedulable, Database.Batchable<SObject>  {

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new B2BEventsEmailScheduler());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // Query chatter group subscriptions to determine distribution list

        string soqlStr = 'Select c.Name, c.Id,' 
        					+	'(Select MemberId From GroupMembers limit 199) From CollaborationGroup c' ;
  
                    
        return Database.getQueryLocator(soqlStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        
        //Create set of user Ids for all chatter groups to simplify later processing
        set<Id> allUserIds = new set<Id>();
        
        //Populate user map
        map<Id, User> allUsers = new map<Id, User>(); 
        
        // populate map of users to chatter groups
        map<Id, list<string>> userChatterGroups = new map<Id, list<string>>();
        
                
        for(Sobject obj : scope){ // for each group
        	list<Sobject> childList = null;
        	try {
        		childList = obj.getSobjects('GroupMembers'); // check there are members

        		if (childList.size() == 199){
					Id grpId = string.valueOf(obj.get('Id'));
					childList = [select MemberId from CollaborationGroupMember where CollaborationGroup.Id = :grpId];
        		}                       	

            } catch (exception e){
            	childList = null;
				// log error, but carry on ..
				system.debug('ERROR ...ERROR ... ERROR ' + string.valueOf(obj.get('Name')) + ' ... ' +
					e.getMessage() + ' : ' + e.getStackTraceString());
            
            }
            if (childList != null){
            	list<Id> userIds = new list<Id>();
system.debug( '@@@   Group Member Sizes ..  ' + obj.get('Name') + ' = ' + childList.size()); 
            	for (Sobject s :childList){ //get members          		
            		userIds.add(string.valueOf(s.get('MemberId')));
            		allUserIds.add(string.valueOf(s.get('MemberId')));
            		list<string> grpList = userChatterGroups.get(string.valueOf(s.get('MemberId')));
            		if (grpList == null){
            			grpList = new list<string>();
            		}
            		grpList.add(string.valueOf(obj.get('Name')));
      		
            		userChatterGroups.put(string.valueOf(s.get('MemberId')), grpList );
            	}
            }
            
        }

        if (!allUserIds.isEmpty()){
        	allUsers = new map<Id, User>([select Name, Email, Receive_B2B_Emails__c, Receive_Weekly_B2B_Emails__c 
        										from user 
        										where Id in:allUserIds
        										and (Receive_B2B_Emails__c = true Or Receive_Weekly_B2B_Emails__c = true)]);
	system.debug (' @@@   MY GROUPS   ' + userChatterGroups.get(userInfo.getUserId()));
	system.debug(' @@@ START Chatter Groups ..  ' + userChatterGroups);		
	        //Send daily report detailing forthcoming meetings
	        B2BEventsEmailSender.sendDailyEmail(userChatterGroups, allUsers);
	 
	         // Send Report Reminder
	        B2BEventsEmailSender.sendReportReminder(userChatterGroups, allUsers);
	        
	        // Determine whether weekly report is dues to be sent
	        Date startOWeekDate = System.today().toStartOfWeek();
	        if(startOWeekDate.addDays(3) == System.today()){
	        	B2BEventsEmailSender.sendWeeklyEmail(userChatterGroups, allUsers);	
	        }
	        
	        if(Test.isRunningTest()){
	        	B2BEventsEmailSender.sendWeeklyEmail(userChatterGroups, allUsers);
	        }
        }
    
    }    
    
    
    global void finish(Database.BatchableContext BC){
        
    }

}