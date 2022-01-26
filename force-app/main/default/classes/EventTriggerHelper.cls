/************************************************
Author : Constantine Chimonides
Class Purpose : Used by Event After insert/update trigger to perform B2B collaboration actions. 
				This includes performing a chatter post on relevant opportunities and creating
				task records where the B2B meeting includes a remerchandise action.
Version History:
================
Created  : 17/04/2014

************************************************/
public without sharing class EventTriggerHelper {

	// default prefix message to chatter post 
	private static final string chatterMsg = 'A B2B meeting has taken place that references this Village Presence ';
	private static final String DATE_FORMAT_ALL_DAY_EVENT = 'dd MMM yyyy';
    private static final String DATE_FORMAT = 'dd MMM yyyy HH:mm';
    private static final id B2BMeetingRecordTypeID = Schema.SObjectType.Event.RecordTypeInfosByName.get('B2B meeting').RecordTypeId;
    
    public static boolean oppsFound = false;
    public static boolean vpsFound = false;
    public static boolean defSubj = false;
          
	// Default subject where meeting has an Account, Opportunity or Village Presence association
	public static void defaultSubject(list<Event> eventList){
		
		list<Id> userList = new list<Id>();
		map<Id, User> userMap = new map<Id, User>();
		
		list<Id> accountList = new list<Id>();
		map<Id, Account> accountMap = new map<Id, Account>();
		
		list<Id> opportunityList = new list<Id>();
		map<Id, Opportunity> opportunityMap = new map<Id, Opportunity>();
		
		list<Id> villagePresenceList = new list<Id>();
		map<Id, Village_Presence__c> villagePresenceMap = new map<Id, Village_Presence__c>();
		
		// determine the object that the event has been created against
		for (Event e :eventList){
			Schema.SObjectType objType = e.whatId.getSobjectType();	
			if (objType.getDescribe().getName() == 'Account'){
				userList.add(e.OwnerId);
				accountList.add(e.whatId);
			}
			if (objType.getDescribe().getName() == 'Opportunity'){
				userList.add(e.OwnerId);
				opportunityList.add(e.whatId);
			}
			
			if (objType.getDescribe().getName() == 'Village_Presence__c'){
				userList.add(e.OwnerId);
				villagePresenceList.add(e.whatId);
			}
				
		}
		if (!userList.isEmpty()){
			 userMap = new map<Id, User> ([select Id, Name from User where Id in: userList ]);
		}

		if (!opportunityList.isEmpty()){
			opportunityMap = new map<Id, Opportunity> ([select id, Name, Account.Id, Village__c, Village__r.Name
														from Opportunity 
														where Id in :opportunityList]);
			for (Opportunity opp :opportunityMap.values()){
				accountList.add(opp.Account.Id);
			}
		}	
				
		if (!accountList.isEmpty()){
			accountMap = new map<Id, Account> ([select id, Name from Account where Id in :accountList]);
		}
		
		if (!villagePresenceList.isEmpty()){
			villagePresenceMap = new map<Id, Village_Presence__c>([select id, name, brand__r.name, village__r.name from Village_Presence__c where Id in :villagePresenceList]);
		}
        
        System.debug('VillagePresenceMap ===== ' + villagePresenceMap);
			
		for (Event e :eventList){
 			Schema.SObjectType objType = e.whatId.getSobjectType();	
			if (objType.getDescribe().getName() == 'Account' || objType.getDescribe().getName() == 'Opportunity'){
				String dateFormat = e.IsAllDayEvent ? DATE_FORMAT_ALL_DAY_EVENT : DATE_FORMAT;
				string user = userMap.get(e.OwnerId).Name;
				string brand = '';
				string eventTime = e.StartDateTime.format(dateFormat);
				if (objType.getDescribe().getName() == 'Account') {
					brand = accountMap.get(e.whatId).Name;
					e.Subject = user + ' meeting with ' + brand + ' on ' + eventTime;
				}
				if (objType.getDescribe().getName() == 'Opportunity') {
					Opportunity opp = opportunityMap.get(e.whatId);
					string oppName = opp.Name;
					string oppVillage = opp.Village__r.Name;
					brand = accountMap.get(opp.Account.Id).Name;					
					e.Subject = user + ' meeting with ' + brand + ' on ' + eventTime + ' Reference Tenancy : '+ oppName;
					e.Opportunity_Brand__c = brand;
					e.Opportunity_Village__c = oppVillage;
				}
			
			}

			if (objType.getDescribe().getName() == 'Village_Presence__c') {
				Village_Presence__c vp = villagePresenceMap.get(e.whatId);
				string vpBrand = vp.brand__r.name;
				string vpVillage = vp.village__r.name;
				string user = userMap.get(e.OwnerId).Name;
				String dateFormat = e.IsAllDayEvent ? DATE_FORMAT_ALL_DAY_EVENT : DATE_FORMAT;
				string eventTime = e.StartDateTime.format(dateFormat);
				e.Subject = user + ' meeting with ' + vpBrand + ' (' + vpVillage + ') on ' + eventTime;				
				e.Opportunity_Brand__c = vpBrand;
				e.Opportunity_Village__c = vpVillage;
				// default villages discussed on event object if not set..
				string villagesDiscussed = e.Villages_Discussed__c;
				if (villagesDiscussed != null){
					if (!villagesDiscussed.contains(vpVillage)){
						villagesDiscussed += ';' + vpVillage;
						e.Villages_Discussed__c = villagesDiscussed;
					}
				} else {
					e.Villages_Discussed__c = vpVillage;
				}
                System.debug('STRING VP BRAND ==== '+ vpBrand);
			}	
		}
        defSubj = true;
	}



	// Method to return Map of Village Presence records associated with event, based on villages associated with events
	public static map<Id, list<Village_Presence__c>> getEventVillagePresences(map<Id, Event> oldEventMap, map<Id, Event> newEventMap){
		
		// return map of village presences associated with event Id based on villages associated with the event
		map <Id, list<Village_Presence__c>> eventVillagePresenceMap = new map<Id, list<Village_Presence__c>>();
						
		try{
			// Check share flag to determine whether event should be processed
			boolean shareFlag = false;
			list<string> eventIdList = new list<string>();
			
			// retrieve map of village records for later lookups
			Map<Id, village__c> villageMap = new Map<Id, Village__c>([SELECT Id, Name FROM Village__c]);
			
			for (string key :newEventMap.keySet()){			
				shareFlag = newEventMap.get(key).Share__c;
                
                System.debug('Shareflag ===== ' + shareFlag);
				
				if (oldEventmap != null){
					if (oldEventMap.get(key).Share__c != shareFlag && shareFlag == true){				
						eventIdList.add(key);				
					}
				} else {
					if (shareFlag == true){
						eventIdList.add(key);
					}
				}			
			}
            
            System.debug('EVENTIDLIST ==== ' + eventIdList);
			// There are events to process
			if (!eventIdList.isEmpty()){
				//extract event data
				list<Event> eventList = [select Village_Activities__c, whatid,
											Villages_Discussed__c, AccountId, Account.Name from Event where id in:eventIdList];
				
	        	VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
	        	string url = settings.Salesforce_Instance_URL__c;
	        	boolean createVillagePresence = settings.Create_Village_Presence__c;

				//loop through each event in the list
				for (event e :eventList){
					list<string> villageList = new list<string>();
					// check villages discussed
					if (string.isnotBlank(e.Villages_Discussed__c)){
												
						Schema.SObjectType objType = e.whatId.getSobjectType();	
						if (objType.getDescribe().getName() == 'Account' || objType.getDescribe().getName() == 'Village_Presence__c'){
							villageList = e.Villages_Discussed__c.split(';');
	    					// create village presence records if required
	    					if (createVillagePresence){ // Custom Setting set to true, therefore VP's required!
		    					map<string, list<string>> brandsVillages = new map<string, list<string>> ();    	
		    					brandsVillages.put(e.Account.Name, villageList);
		    					map<string, map<String, Village_Presence__c>> resultMap = VillagePresenceUtilities.getVillagePresence(brandsVillages);
								if (resultMap != null){
									map<string, Village_Presence__c> villagePresenceMap = resultMap.get(e.Account.Name);								
									for (string village :villageList){
										if(!villagePresenceMap.containsKey(village)){
											Village_Presence__c vp = VillagePresenceUtilities.createVillagePresence(e.AccountId, village);
										}
									}								
								} else {
									for (string village :villageList){								
										Village_Presence__c vp = VillagePresenceUtilities.createVillagePresence(e.AccountId, village);
									}
								}
	    					}
	    					
						}
						
						list<string> villageIdList = new list<string>();
						// loop through each village discussed
						for(string village :villageList){
							// get the village id from village map populated earlier 
							for (string villageKey :villageMap.keySet()){
								if(village == villageMap.get(villageKey).Name){
									villageIdList.add(villageKey);								
								}
							}
							
						}
                        
                        System.debug('VILLAGEIDLIST ===== '+ villageIdList);

						// Find village presences relevant to the account and village
						if (!villageIdList.isEmpty()){
							list<Village_Presence__c> vpList = new list<Village_Presence__c>();														
							try {								
								vpList = [select Id, brand__c from Village_Presence__c where brand__c = :e.AccountId and village__c in:villageIdList];																											
							} catch (exception err){
								vpList = new list<Village_Presence__c>();								
							}
							// populate return map of all village presences associated with event, based on villages mentioned in the event	
							eventVillagePresenceMap.put(e.Id, vpList);
						}
						

					}
				
				} // end of event list loop

			}
			
		} catch (exception e){
			
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());			
		}
		vpsFound = true;
		return eventVillagePresenceMap;
	}



/*	
	// Method to return Map of Opportunities associated with event, based on villages associated with events
	public static map<Id, list<Opportunity>> getEventOpportunities(map<Id, Event> oldEventMap, map<Id, Event> newEventMap){
		
		// return map of opportunities associated with event Id based on villages associated with the event
		map <Id, list<Opportunity>> eventOpportunityMap = new map<Id, list<Opportunity>>();
						
		try{
			// Check share flag to determine whether event should be processed
			boolean shareFlag = false;
			list<string> eventIdList = new list<string>();
			
			// retrieve map of village records for later lookups
			Map<Id, village__c> villageMap = new Map<Id, Village__c>([SELECT Id, Name FROM Village__c]);
			
			for (string key :newEventMap.keySet()){			
				shareFlag = newEventMap.get(key).Share__c;
				
				if (oldEventmap != null){
					if (oldEventMap.get(key).Share__c != shareFlag && shareFlag == true){				
						eventIdList.add(key);				
					}
				} else {
					if (shareFlag == true){
						eventIdList.add(key);
					}
				}			
			}
			// There are events to process
			if (!eventIdList.isEmpty()){
				//extract event data
				list<Event> eventList = [select Village_Activities__c, whatid,
											Villages_Discussed__c, AccountId, Account.Name from Event where id in:eventIdList];
				
	        	VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
	        	string url = settings.Salesforce_Instance_URL__c;
					
				//loop through each event in the list
				for (event e :eventList){
					list<string> villageList = new list<string>();
					// check villages discussed
					if (string.isnotBlank(e.Villages_Discussed__c)){
						
						// create dummy opportunities if required
						Schema.SObjectType objType = e.whatId.getSobjectType();	
						if (objType.getDescribe().getName() == 'Account'){
							villageList = e.Villages_Discussed__c.split(';');
	    					map<string, list<string>> brandsVillages = new map<string, list<string>> ();    	
	    					brandsVillages.put(e.Account.Name, villageList);
	    					map<string, map<String, Opportunity>> resultMap = TenancyUtilities.getTenancy(brandsVillages);
							if (resultMap != null){
								map<string, Opportunity> villageOppMap = resultMap.get(e.Account.Name);								
								for (string village :villageList){
									if(!villageOppMap.containsKey(village)){
		        						string description = 'This tenancy was created automatically by the system'
	        							+ ' because ' +  e.Account.Name + ' was inferred, by a B2B,'
	        							+ ' to be in ' + village + ' but a tenancy record was not present.'
										+ '\n\n B2B : ' + url + '/' + e.Id;
										Opportunity opp = TenancyUtilities.createDummyTenancy(e.AccountId, village, description, '');
									}
								}								
							} else {
								for (string village :villageList){
	        						string description = 'This tenancy was created automatically by the system'
        							+ ' because ' +  e.Account.Name + ' was inferred, by a B2B,'
        							+ ' to be in ' + village + ' but a tenancy record was not present.'
									+ '\n\n B2B : ' + url + '/' + e.Id;									
									Opportunity opp = TenancyUtilities.createDummyTenancy(e.AccountId, village, description, '');
								}
							}
						}
						
						list<string> villageIdList = new list<string>();
						// loop through each village discussed
						for(string village :villageList){
							// get the village id from village map populated earlier 
							for (string villageKey :villageMap.keySet()){
								if(village == villageMap.get(villageKey).Name){
									villageIdList.add(villageKey);								
								}
							}
							
						}

						// Find opportunities relevant to the account and village
						if (!villageIdList.isEmpty()){
							list<Opportunity> oppList = new list<Opportunity>();														
							try {
								// to do - filter opportunities to retrieve the latest one only?..or check a particular status?
								oppList = [select Id, AccountId from Opportunity where AccountId = :e.AccountId and village__c in:villageIdList];																											
							} catch (exception err){
								oppList = new list<Opportunity>();								
							}
							// populate return map of all Opportunities associated with event, based on villages mentioned in the event	
							eventOpportunityMap.put(e.Id, oppList);
						}
						

					}
				
				} // end of event list loop

			}
			
		} catch (exception e){
			
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());			
		}
		oppsFound = true;
		return eventOpportunityMap;
	}

*/

	// Method to perform chatter post on relevant village presence records associated with event (and account)
	public static void postVillagePresenceChatter(list<Village_Presence__c> vpList, Event event){
		
		Id currentVp = null;
		Schema.SObjectType objType = event.whatId.getSobjectType();	
		if (objType.getDescribe().getName() == 'Village_Presence__c'){
			currentVp = event.whatId; 
		}
		
		list<string> remerchandiseActivitiesList = new list<string>();
		string remerchandiseActivities = '';
		
		if (!string.isBlank(event.Village_Activities__c)){			
			remerchandiseActivitiesList = event.Village_Activities__c.split(';');	
			for(string s :remerchandiseActivitiesList){
				list<string> itemList = s.split('-');
				remerchandiseActivities += 	itemList[1].trim() + ';';
			}
			integer i = remerchandiseActivities.lastIndexOf(';');
			if (i > -1){
				remerchandiseActivities = remerchandiseActivities.substring(0, i);
			}
		}
		
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		//Create MessageBodyInput (child of FeedItemInput) to hold message segments
		feedItemInput.body = new ConnectApi.MessageBodyInput();

        //Create Message Segments Holder//
		List<ConnectApi.MessageSegmentInput> segments = new list <ConnectApi.MessageSegmentInput>();

		//Create text segment to hold message body//
		ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();		
		string postBody = chatterMsg;
		postBody += '\n\n ' +  event.Subject;
		postBody += '\n\n Headline: ' +  event.Event_Headline__c ;
		postBody += '\n\n Remerchandising Activities Discused: ' + remerchandiseActivities;
		
		textSegment.text = postBody;
		//Add body to message segment//

		segments.add(textSegment);

		feedItemInput.body.messageSegments = segments;
        ConnectApi.LinkAttachmentInput linkInput = new ConnectApi.LinkAttachmentInput();
        linkInput.urlName = event.Subject;
        linkInput.url = '/' + event.Id;
        feedItemInput.attachment = linkInput;
        
        
        set<string> postedToAccountIds = new set<string>();

        for (Village_Presence__c vp :vpList){ 
        	try{   			
				if (vp.Id != currentVp)
					ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, vp.Id, feedItemInput, null);
        	} catch (exception e){
        		// do nothing
        		// log error (in case), but most likely a force.com user licence error (no permissions)
        		system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
        		break;
        	}
			/* Now handled using standard feed tracking configuration
			//also post to the account ..once only			
			IF (!postedToAccountIds.contains(opp.accountId))
				ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, opp.accountId, feedItemInput, null);
			
			postedToAccountIds.add(opp.accountId);
        	*/
        }
                
	}


/*
// Method to perform chatter post on relevant opportunities associated with event (and account)
	public static void postOpportunityChatter(list<Opportunity> oppList, Event event){

		
		list<string> remerchandiseActivitiesList = new list<string>();
		string remerchandiseActivities = '';
		
		if (!string.isBlank(event.Village_Activities__c)){			
			remerchandiseActivitiesList = event.Village_Activities__c.split(';');	
			for(string s :remerchandiseActivitiesList){
				list<string> itemList = s.split('-');
				remerchandiseActivities += 	itemList[1].trim() + ';';
			}
			integer i = remerchandiseActivities.lastIndexOf(';');
			if (i > -1){
				remerchandiseActivities = remerchandiseActivities.substring(0, i);
			}
		}
		
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		//Create MessageBodyInput (child of FeedItemInput) to hold message segments
		feedItemInput.body = new ConnectApi.MessageBodyInput();

        //Create Message Segments Holder//
		List<ConnectApi.MessageSegmentInput> segments = new list <ConnectApi.MessageSegmentInput>();

		//Create text segment to hold message body//
		ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();		
		string postBody = chatterMsg;
		postBody += '\n\n ' +  event.Subject;
		postBody += '\n\n Headline: ' +  event.Event_Headline__c ;
		postBody += '\n\n Remerchandising Activities Discused: ' + remerchandiseActivities;
		
		textSegment.text = postBody;
		//Add body to message segment//

		segments.add(textSegment);

		feedItemInput.body.messageSegments = segments;
        ConnectApi.LinkAttachmentInput linkInput = new ConnectApi.LinkAttachmentInput();
        linkInput.urlName = event.Subject;
        linkInput.url = '/' + event.Id;
        feedItemInput.attachment = linkInput;
        
        
        set<string> postedToAccountIds = new set<string>();

        for (opportunity opp :oppList){ 
        	try{   
				ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, opp.Id, feedItemInput, null);
        	} catch (exception e){
        		// do nothing
        		// log error (in case), but most likely a force.com user licence error (no permissions)
        		system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
        		break;
        	}
        }
                
	}
*/
	
	//Create a task for each remerchandise action on the event
	public static void createTask(set<Id> eventIdList){
	
		//Extract event data
		list<Event> eventList = [select Id,  Villages_Discussed__c, Follow_Up_Assignee__c, Village_Activities__c, Auto_Create_Tasks__c, 
													Follow_Up_Due_date__c, OwnerId, AccountId, Account.Name from Event where id in:eventIdList];	
		
		// list of remerchandise actions associated with event
		list<string> brandActionsList = new list<string>();
		
		// map of default assignee values
		map<Id, Default_Task_Value__c> defaultTaskMap = new map<Id, Default_Task_Value__c>([select id, Default_Assignee__c, Default_Assignee__r.Id, Due_Date_Offset__c, Remerchandising_Activity__c from Default_Task_Value__c]);
		
		list<Task> taskList = new list<Task>();	

		// loop through each event
		for (event e :eventList){
			
			//Extract remerchandise actions
			brandActionsList = getEventActions(e);
					
			if (!brandActionsList.isEmpty()){
				string assignee = e.Follow_Up_Assignee__c;
				string userId = e.OwnerId;
				if (string.isnotBlank(assignee)){
					User foundUser = findUser(assignee);
					if (foundUser != null){
						userId = foundUser.Id;
						e.Follow_Up_Assignee__c = foundUser.Name;
					}
				} 
				
				//create task for each event action
				for (string action :e.Village_Activities__c.split(';')){
					date dueDate = system.today();
					if (e.Follow_Up_Due_date__c != null){
						dueDate = e.Follow_Up_Due_date__c;
					}
					for (string s :defaultTaskMap.keySet()){
						Default_Task_Value__c defaultTask = defaultTaskMap.get(s);
						
						if (defaultTask.Remerchandising_Activity__c == action){
							if (string.isBlank(assignee)){
								userId = defaultTask.Default_Assignee__r.Id;
								if (string.isBlank(userId)){
									userId = e.OwnerId;
								}
							}
							if (e.Follow_Up_Due_date__c == null){
								dueDate = dueDate.addDays(integer.valueOf(defaultTask.Due_Date_Offset__c));
							} else {
								dueDate = e.Follow_Up_Due_date__c;
							}
							
							break;
						}
					}
					if (e.Auto_Create_Tasks__c){ // only create task if event flag indicates they should be	
						Task t = new Task(Subject = e.Account.Name + ' - ' + action, Status='Not Started',
											WhatId = e.AccountId,
											Villages_discussed__c = e.Villages_Discussed__c,
											Remerchandising_Activity__c = action,
											Related_Meeting_ID__c = e.Id,
											ActivityDate = dueDate,
											OwnerId = userId
											);
						string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + e.Id;
						string taskDescription = 'This task has been created automatically as a result of a B2B Meeting : ' + eventURL + '\n\n\n\n\n\n' 
													+ ' Please only reassign ownership of this task in Salesforce, not Outlook.';
						t.Description = taskDescription;
						taskList.add(t);
					}
				}
			}
		
		}
	
		update eventList;
		
		// Insert task list into database
		if (!taskList.isEmpty()){
			insert taskList;
		}

		
	}


	public static void postGroupChatter(set<Id> eventIdList){
		
		//Extract event data
		list<Event> eventList = [select Id, Village_Activities__c, Villages_Discussed__c, Event_Department__c, whatId, Subject,
													Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
													OwnerId, AccountId, Non_VR_Outlet_Full_Price_Performance__c
													from Event where id in:eventIdList];	

		
		// retrieve map of village records for later lookups
		map<Id, Village__c> villageMap = new Map<Id, Village__c>([SELECT Id, Name, B2B_Chatter_Group_Name__c FROM Village__c]);
		
		// retrieve map of event invitee records
		map<Id, EventRelation> inviteeMap = new map<Id, EventRelation> ([Select EventId, RelationId, relation.name  
																			FROM EventRelation 
																			where EventId in:eventIdList and IsWhat = false]);

system.debug(' @@@@@@@@@@  CHATTER POST  ' + inviteeMap);
	
		// retrieve map of B2B chatter group records for later lookups
		map<Id, CollaborationGroup> chatterGroupMap = new map<Id, CollaborationGroup>([SELECT Id, Name from CollaborationGroup where name like '%B2B%']);
	
		// Keep list of opportunity records if event is associated with Opportunity, this is needed for later posting to 
		// Tenancy specific chatter groups which Force.com subscription users must join in order to receive Opportunity
		// event postings
		map<Id, Event> opportunityEventMap = new map<Id, Event>();
			
		for (Event e :eventList){
			Schema.SObjectType objType = e.whatId.getSobjectType();	
			if (objType.getDescribe().getName() == 'Opportunity'){
				opportunityEventMap.put(e.whatId, e);
			}
						
			e.Event_Status__c = 'Meeting Completed';
			list<Id> chatterGroupIds = new list<Id>();
			string relation = '';
			for (EventRelation r :inviteeMap.Values()){
				if (r.EventId == e.Id){
					relation = relation + r.relation.name + ', ';
				}
			}		
			// check villages discussed 			
			if (string.isnotBlank(e.Villages_Discussed__c)){
						
				list<string> villageList = e.Villages_Discussed__c.split(';');
						
				list<string> villageIdList = new list<string>();
				// loop through each village discussed
				for(string village :villageList){
					// get the village chatter group from village map populated earlier 
					for (string villageKey :villageMap.keySet()){
						if(village == villageMap.get(villageKey).Name){
							string chatterGroup = villageMap.get(villageKey).B2B_Chatter_Group_Name__c;
							// get chatter group id from chatter group map populated earlier
							for(string grpKey :chatterGroupMap.keySet()){
								if (chatterGroupMap.get(grpKey).Name == chatterGroup){
									chatterGroupIds.add(grpKey);
									break;
								}
							}
															
						}
					}
					
				}

			}
			
			// check event department
			if(string.isnotBlank(e.Event_Department__c)){
				string grpName = 'B2B Meetings - ' + e.Event_Department__c;	
				// get chatter group id from chatter group map populated earlier
				for(string grpKey :chatterGroupMap.keySet()){
					if (chatterGroupMap.get(grpKey).Name == grpName){
						chatterGroupIds.add(grpKey);
						break;
					}
				}				
				
				
			}
			
			//Post chatter
			chatterPost(e, chatterGroupIds, relation, false);
			
		} //end of Event loop 
		update eventList;

		// check custom setting to determine whether tenancyPosts are switched on
		boolean tenancyPosts = true;
		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
		if (settings != null) {
			tenancyPosts = settings.Tenancy_Posts__c;		
		}
		
		if (tenancyPosts){
			// Check if post to Tenancy group is required		
			if(opportunityEventMap.size() > 0){ //also need to post to Tenancy chatter groups
				// retrieve map of B2B chatter group records for later lookups
				chatterGroupMap = new map<Id, CollaborationGroup>([SELECT Id, Name from CollaborationGroup where name like '%Tenancy%']);			
				// retrieve opportunity villages
				map<Id, Opportunity> opportunityMap = new map<Id, Opportunity>([select Id, village__c, village__r.name from Opportunity where id in:opportunityEventMap.keySet()]);				
				for (Id oppId :opportunityEventMap.keySet()){
					list<Id> chatterGroupIds = new list<Id>();
					Event e = opportunityEventMap.get(oppId);
					string villageName = opportunityMap.get(oppId).village__r.name;
					string grpName = villageName + ' Tenancy Meetings';	
					// get chatter group id from chatter group map populated earlier
					for(string grpKey :chatterGroupMap.keySet()){
						if (chatterGroupMap.get(grpKey).Name == grpName){
							chatterGroupIds.add(grpKey);
							string relation = '';
							for (EventRelation r :inviteeMap.Values()){
								if (r.EventId == e.Id){
									relation = relation + r.relation.name + ', ';
								}
							}	
							//Post chatter
							chatterPost(e, chatterGroupIds, relation, true);						
							break;
						}
					}				
					
				}			
			}
			
		} // end if tenancyPosts
	}


	private static void chatterPost(Event event, list<Id> chatterGroupIds, string invitees, boolean oppPost){
		

		// extract remerchandise activities string from Village Activities field	
		list<string> remerchandiseActivitiesList = new list<string>();
		string remerchandiseActivities = '';
		if (!string.isBlank(event.Village_Activities__c)){			
			remerchandiseActivitiesList = event.Village_Activities__c.split(';');	
			for(string s :remerchandiseActivitiesList){
				list<string> itemList = s.split('-');
				remerchandiseActivities += 	itemList[1].trim() + ';';
			}
			integer i = remerchandiseActivities.lastIndexOf(';');
			if (i > -1){
				remerchandiseActivities = remerchandiseActivities.substring(0, i);
			}
		}
			
		//chatter posts can only handle 5000 chars. With upto 1000 chars taken up by other fields we want to 
		//cut off the description field at 4000 chars
		string max4000Description;
		if (string.isnotBlank(event.Description)){
			if (event.Description.length() >= 4000){
				max4000Description = event.Description.substring(0, 3900) + '...\n<Meeting text too large to post in full. Please click the meeting link to view full text.>';
			}
			else{
				max4000Description = event.Description;
			}
		}
		if (string.isBlank(max4000Description) || max4000Description == 'null'){
			max4000Description = '';
		}
		
		ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
            
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegment;
        

           
        //Creating the post body :: made up of a list of individual segments
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
     
            
        //segment item is the text of the post
        textSegment = new ConnectApi.TextSegmentInput();
        string headline ='';
        if (string.isnotBlank(Event.Event_Headline__c)){
        	headline = '\n' + Event.Event_Headline__c + '\n\n';
        }
        textSegment.text = headline + '\n A B2B Event has been recorded for -  \n'
        + 'Brand : ' + event.Account.Name + ' \n' 
        + 'Villages : ' +  event.Villages_Discussed__c + ' \n' 
        + 'Reason : ' +  event.Reason__c + ' \n' 
        + 'Remerchandise Actions : ' + remerchandiseActivities + ' \n'
        + 'Department : ' + event.Event_Department__c +  + ' \n'
        + 'Invitees : ' + invitees +'\n\n'       
        + max4000Description +'\n\n'
        + 'Non-VR Outlet & Full Price Performance : \n'
        + event.Non_VR_Outlet_Full_Price_Performance__c 
        + '\n\n Posted to group(s): ';
        messageInput.messageSegments.add(textSegment);
        
        System.debug('TEXTSEGMENT ==== ' + textSegment);
		
		// Post to Tenancy chatter group directly if event is for an Opportunity
		if (oppPost){
			string comment = string.valueOf(textSegment.text);
			comment += '\n\n Please Note: You may not have permission to view the Tenancy Opportunity or Event record in Salesforce. \n';
			comment += 'Contact the System Administrator if access is required.'; 
			comment = comment.replace('\n\n Posted to group(s): ','');
			string title = 	event.subject;		
			// No longer needed if Village Presence record posting works ok ... to do
			//postDirectToGroup(chatterGroupIds[0], comment, title, event.Id);
		} else {

			//last segment item is the @mention for the chatter group ids
	        for (id grpId :chatterGroupIds){
	        	ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
	        	mentionSegment.id = grpId;
	        	messageInput.messageSegments.add(mentionSegment);
	        }
	            
	        //assign the messageInput list to the inputbody
	        input.body = messageInput;
	            
	        //call the post command, sending it the items created above
	        ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem('internal', feedType, event.id, input, null);
			
			//post topic to feed item - one topic for each remerchandise action
			if (string.isnotBlank(remerchandiseActivities)){
				list<string> actionsList =  remerchandiseActivities.split(';');
				for (string action :actionsList){
					try{
						ConnectApi.Topic topic = ConnectApi.Topics.assignTopicByName('Internal', feedItemRep.Id, action);
					} catch (exception e){
						// log error, but carry on ..
						system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
					}
				}
			}
		}
		
		
		
		set<Id> eventIds = new set<Id>();
		map<Id,User> userMap = new map<Id, User>([select Id from User where Send_Custom_B2B_Email__c = true]);
		eventIds.add(event.Id);
		CustomB2BEmailSender.sendCustomB2BEmail(eventIds, userMap.keySet());
	}


	private static void postDirectToGroup(string parentChatterGroup, string comment, string title, string recId){

		feeditem newPost = new feeditem();

        if (string.isnotBlank(comment) && string.isnotBlank (parentChatterGroup)) {
	        
	        if (string.isnotBlank(parentChatterGroup)){
				newPost.parentid = parentChatterGroup;
		        newPost.Title = title;
		        newPost.LinkUrl = '/' + recId;
				newPost.Body = comment;
				
		        insert newPost;
	        }
        }		
	}
	
	// perform SOSL on User object to return a single unique match
	private static User findUser(string searchText){
		
 		User returnUser = null;
 		
 		List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS 
                                              RETURNING 
                                                 User (id, Name, Username, Email)];
		
		list<User> foundUsers = ((List<User>)searchList[0]);

        if (foundUsers.size() == 1){
        	returnUser = foundUsers[0];
        }
        
        return returnUser;
                   		
	}
	
	// Populate list of remerchandise activities from event Village Activities field
	private static list<string> getEventActions(Event e){
	
		list<string> returnList = new list<string>();
		list<string> brandVillageActionsList = new list<string>();
		
		if (string.isnotBlank(e.Village_Activities__c)){
			brandVillageActionsList = e.Village_Activities__c.split(';');
			for (string s :brandVillageActionsList){
				list<string> itemList = s.split('-');
				returnList.add(itemList[1].trim());
			}	
		}	
		
		return returnList;
		
	}

}