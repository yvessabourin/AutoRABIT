trigger BrandEventTrigger on Event (before insert, after insert, after update, before update) {
	
	try{

		
		set<Id> eventIdList = new set<Id>();
		
		// default subject string before insert
		if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            if (!EventTriggerHelper.defSubj){
				EventTriggerHelper.defaultSubject(Trigger.new);
            }
			
			//check whether event update is an update to the share flag
      		// set meeting status to Meeting Completed, where event has been updated to be shared
      		for(Event e : trigger.new)
    		{  
      			if (trigger.isUpdate){
      				if(trigger.oldMap.get(e.id).Share__c != e.Share__c && e.Share__c == true)
						e.Event_Status__c = 'Meeting Completed';
      			}
      			if (trigger.isInsert){
      				if (e.Share__c == true)
      					e.Event_Status__c = 'Meeting Completed';
      			}
      		}
						
		}
		
		// Check share flag to determine whether to continue processing
		if(trigger.isAfter && trigger.isUpdate)
 		{             
			for(Event e : trigger.new)
    		{    
          		//check whether event update is an update to the share flag
          		// only create task, where event has been updated to be shared
          		if(trigger.oldMap.get(e.id).Share__c != e.Share__c && e.Share__c == true
          			&& e.Date_Time_B2B_Posted__c == null){ 
system.debug(' @@@@@  Date Shared  ...  ' + trigger.newMap.get(e.id).Date_time_B2B_Posted__c);					
					eventIdList.add(e.id);
          		}
				
    		}
 		}
 		
 		//only continue process for events which have been created and shared
 		if (trigger.isAfter && trigger.isInsert){
 			for (event e :trigger.new){
 				if (e.Share__c){
 					
 					eventIdList.add(e.Id);			
 				}
 			}
 		}
        System.debug('EVENTIDLIST ==== ' + eventIdList);
		

		if (!eventIdList.isEmpty()){ // There are records to process	
			// retrieve any associated village presences with event, based on villages discussed
			if (!EventTriggerHelper.vpsFound){
				map<Id, list<Village_Presence__c>> eventVillagePresenceMap = EventTriggerHelper.getEventVillagePresences(trigger.oldMap,  trigger.newMap);				
				// Perform chatter post for each opportunity found for each village discussed in B2B Event
				for (string eventId :eventVillagePresenceMap.keySet()){
					EventTriggerHelper.postVillagePresenceChatter(eventVillagePresenceMap.get(eventId), trigger.newMap.get(eventId));
				}
			}
	
			// Create task for each event with a remerchandise action
			EventTriggerHelper.createTask(eventIdList);
					
			// Perform chatter post to relevant Groups
			EventTriggerHelper.postGroupChatter(eventIdList);
		} 


/*		
		if (!eventIdList.isEmpty()){ // There are records to process	
			// retrieve any associated opportunities with event, based on villages discussed
			if (!EventTriggerHelper.oppsFound){
				map<Id, list<Opportunity>> eventOpportunityMap = EventTriggerHelper.getEventOpportunities(trigger.oldMap,  trigger.newMap);
				
				// Perform chatter post for each opportunity found for each village discussed in B2B Event
				for (string eventId :eventOpportunityMap.keySet()){
					EventTriggerHelper.postOpportunityChatter(eventOpportunityMap.get(eventId), trigger.newMap.get(eventId));
				}
			}
	
			// Create task for each event with a remerchandise action
			EventTriggerHelper.createTask(eventIdList);
					
			// Perform chatter post to relevant Groups
			EventTriggerHelper.postGroupChatter(eventIdList);
		}  
*/
	} catch (exception e){
		
		system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
	}
}