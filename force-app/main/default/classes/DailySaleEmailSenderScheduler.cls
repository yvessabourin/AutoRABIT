global class DailySaleEmailSenderScheduler implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    

/***** NOTES..   schedule commands using anonymous window  ****

// Job will run in accordance with User timezone (assuming run by UK user)

// Run job at 8AM UK time (9AM CET) for all regions other than UK/Ireland
DailySaleEmailSenderScheduler job = new DailySaleEmailSenderScheduler('NON-UK');
String sch = '0 0 8 * * ?';
system.schedule('DailySaleEmailSenderScheduler_CET', sch, job);

// Run job at 9AM UK time (10AM CET) for UK/Ireland region
DailySaleEmailSenderScheduler job = new DailySaleEmailSenderScheduler('UK');
String sch = '0 0 9 * * ?';
system.schedule('DailySaleEmailSenderScheduler_UK', sch, job);

**************************************************************/
	
	public string regionZone = '';
    public list<list<string>> lstBatchWrapper = new list<list<string>>();

	public DailySaleEmailSenderScheduler(){
		
	}
		
	public DailySaleEmailSenderScheduler(string region){
		
		regionZone = region;
		
	}
	        
	global Database.QueryLocator start(Database.BatchableContext BC)
    {     
        // Retrieve unconfirmed Daily Sale records older than a day
        string query = 'select Id, Store__c, Trading_Date__c, Status__c';
        query += ' from Daily_Sale__c';
		query += ' where Brand_Status__c = ' + '\'Not Confirmed\' and Trading_Date__c < TODAY';
		query += ' and Trading_Date__c = LAST_N_DAYS:7';
		query += ' and Store__r.Send_Daily_Sale_Email_Reminders__c = true';
		if (regionZone == 'UK'){
			query += ' and Store__r.Village__r.Region__r.Name = ' + '\'UK & Ireland\' ';
		} else {
			query += ' and Store__r.Village__r.Region__r.Name <> ' + '\'UK & Ireland\' ';
		}
		query += ' order by Trading_Date__c';
		
        return Database.getQueryLocator(query);
    }


    global void execute(SchedulableContext SC) {
        database.executebatch(new DailySaleEmailSenderScheduler(regionZone), 10);   	
    }
        
  	global void execute(Database.BatchableContext BC,List<Sobject> scope)
    {    
		set<string> vpIds = new set<string>();
		list<Daily_Sale__c> DailySalesList = new list<Daily_Sale__c>();
		
        map<Id, Village_Presence_Contact_Role__c> contactMap = new map<Id, Village_Presence_Contact_Role__c>();
        map<Id, User> contactUserMap = new map<Id, User>();
system.debug('@@@ regionZone ' + regionZone + ' -  scope ... ' + scope);		
		// Loop through unconfirmed records to retrieve Village presence ids
		if (!scope.isEmpty()){           
            for (Sobject ds :scope){
            	vpIds.add(string.valueOf(ds.get('Store__c')));
            	DailySalesList.add((Daily_Sale__c) ds );	            	
            }    	
		}
		
		// Retrieve associated Village presence contact roles where contact is authorised view and to confirm daily sale records
        map<Id, Village_Presence__c> vpcontactRoleList = new map<Id, Village_Presence__c>([select Id, Name, (SELECT id, Village_presence__c, Contact__c,
                                                                 Daily_Sales_Active_From__c, Daily_Sales_Active_To__c,
                                                                 Confirm_Daily_Sales_Records__c
                                                                 from Village_Presence_Contact_roles__r
                                                                 where Daily_Sales_Active_From__c != null
                                                                 and  Confirm_Daily_Sales_Records__c = true)
                                                            From Village_Presence__c
                                                            where Id in :vpIds]);
        
        //associate returned village presence contact roles with user contact id 
        for (Village_Presence__c vp : vpcontactRoleList.values()){
            list<Village_Presence_Contact_Role__c> contactRolesList = vp.Village_Presence_Contact_roles__r;
            if (!contactRolesList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :contactRolesList){
                    contactMap.put(vpcr.Contact__c, vpcr);
                }    
            }    
        }		
		
		
        contactUserMap = new map<Id, User>([select Id, Name, Email, ProfileId, ContactId, IsActive from User where ContactId in :contactMap.keySet()]);  
        
        map<Id, User> contactUserMap2 = new map<Id, User>();
        map<string, string> uniqueEmails = new map<string, string>();
        // associate contact id with their portal user record
        for (User u :contactUserMap.values()){
            contactUserMap2.put(u.ContactId, u);            
        }
       
        for (Daily_Sale__c ds :DailySalesList){
             
            string dsStatus = ds.Status__c;
            date dsTransactionDate = ds.Trading_Date__c;
            // now we have the daily sale records and associated village presence contact roles, need to construct a list of unique email addresses
            // where email should be sent
            list<Village_Presence_Contact_Role__c> contactRolesList = vpcontactRoleList.get(ds.Store__c).Village_Presence_Contact_roles__r;
            if (!contactRolesList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :contactRolesList){
                    Date startDt = vpcr.Daily_Sales_Active_From__c;
                    Date endDt = vpcr.Daily_Sales_Active_To__c;
                    User u = contactUserMap2.get(vpcr.Contact__c);
                    boolean profileStatusSetting = false;
system.debug('@@@ User .. ' + u + ' - ' + vpcr.Contact__c);
                    if (u != null && startDt != null && u.IsActive) {//contact is an active partner user and has a Daily Sales start date                    
                        string orgId = system.userInfo.getOrganizationId();
                        if (startDt <= dsTransactionDate && (endDt == null || endDt >= system.today())){ // only consider contacts with valid Daily Sales start and end dates
							uniqueEmails.put(u.Email, u.Id);
                        }
                    }
                }
            }
        }
        
        if (!uniqueEmails.isEmpty()){
system.debug(' @@@ uniqueEmails  ' + ' size= '+ uniqueEmails.size() + ' - ' + uniqueEmails);
        	integer emailListSize = uniqueEmails.size();
        	list<string> userIdList = uniqueEmails.values();
        	if (emailListSize > 10){
        		list<string> lstTemp;
				// split list into smaller lists with maximum size of 10, to avoid governor limit when sending emails 
				// (ie. Too many Email Invocations: 11)
 				for(Integer i = 0 ; i < (emailListSize / 10)+1 ; i++){
                	lstTemp = new List<string>();
                	for(Integer j=(i*10);(j<(i*10)+10) && j<userIdList.size() ; j++){
                    	lstTemp.add(userIdList.get(j));
                	}
                	lstBatchWrapper.add(lstTemp);
            	}        		
system.debug(' @@@@ lstBatchWrapper 1 ' + lstBatchWrapper);


        	} else {
        		EmailSender.sendDailySaleReminder(uniqueEmails.values());
        	}
        }
    
    }

	global void finish(Database.BatchableContext BC)
    {
system.debug(' @@@@ lstBatchWrapper 2 ' + lstBatchWrapper);
		if (!lstBatchWrapper.isEmpty()) {
			for(list<string> lst :lstBatchWrapper){
				Database.executeBatch(new EmailSenderBatch(lst));
			}
		}

    }
    
}