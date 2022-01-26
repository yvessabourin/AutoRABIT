public without sharing class ContactTradeEventSync {
	
	// This method updates the contact Latest_Trade_Events_Attended__c field with most recent 3
	// trade events attended. The method accepts a list of Trade Event Attendance record Ids.
	public static void syncContactTradeEvents(set <Id> tradeEventAttendeeIds){
		
		final integer MAX = 3; //Constant value to identify how many most recent trade event records to retrieve 
		
		// Retrieve all associated contacts which have been passed into the method call
		map<Id, Contact> contactMap = new map<Id, Contact>([select Id, Latest_Trade_Events_Attended__c from contact
		                                                    where Id in (select Contact__c from Trade_Event_Attendee__c 
		                                                   					 where Id in :tradeEventAttendeeIds) ALL ROWS]);
		
		// Retrieve most recent Trade events attended for each contact
		list<Contact> contactList = [SELECT Id, Name, Latest_Trade_Events_Attended__c, 
											(SELECT Trade_Event_Name__c, Trade_Event_Date__c 
		                                        FROM Trade_Event_Attendees__r 
		                                        order by Trade_Event_Date__c desc limit :MAX) 
		                             			FROM Contact where Id in :contactMap.keySet()];
		
		//loop through contact records
		for (Contact c :contactList){
		    list<Trade_Event_Attendee__c> attendanceList = c.getSobjects('Trade_Event_Attendees__r');
		    string tradeEventNames = '';
		    integer icount = 0;
		    // loop through trade events for each contact
		    if (attendanceList == null){
		    	c.Latest_Trade_Events_Attended__c = ''; // no trade event attendances found
		    } else {
			    for (Trade_Event_Attendee__c attendance :attendanceList){
			        // concatenate semi-colon separated string of trade event names
			        tradeEventNames += attendance.Trade_Event_Name__c; 
			        icount ++;
			        if (icount < MAX){
			        	tradeEventNames += ';';
			        }
			    }
	system.debug('@@@@  Latest Trade Events for .. ' + c.Name + ' - ' + tradeEventNames);
			    // set field value on contact with concatenated string value
			    c.Latest_Trade_Events_Attended__c = tradeEventNames;
		    }
		}
		
		// update the contact list
		update contactList;
		
		
	}
	


}