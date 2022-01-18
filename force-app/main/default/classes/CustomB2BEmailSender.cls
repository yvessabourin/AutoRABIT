// This class is used to construct a custom email for an individual B2B meeting for those user's
// who have set the 'Send Custom B2B Email' flag on their user profile.
// There is no test class for this class itself but test coverage is covered by the EventTriggerHelperTest
// test class.

public with sharing class CustomB2BEmailSender {

	private static final String SERVERL_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
	private static Map<Id, String> emailBodyHTMLByEventId = new Map<Id, String>();
	private static Map<Id, String> emailBodyPlainByEventId = new Map<Id, String>();
	
	private static final String CALENDAR_VIEW_DATE_FORMAT = 'dd/MM/yyyy HH:mm';
	private static final id B2BMeetingRecordTypeID = Schema.SObjectType.Event.RecordTypeInfosByName.get('B2B meeting').RecordTypeId;
	
	private static string displayName = ''; // 
	private static string replyTo = ''; //
	private static string replyId = '';
	private static string calendarUrl = '';
	 
	private static void getSettings(){

		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
		if (settings != null) {
			displayName = settings.B2B_Alert_Display_Name__c;
			calendarUrl = settings.B2B_Calendar_VRNET_URL__c;		
		}
		for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) {		
			if(owa.DisplayName.contains(displayName)){ 
				replyId = owa.Id;
				replyTo = owa.Address;
				break;				 
			}
		}
				
	}	
		
	public static void sendCustomB2BEmail(set<Id> eventIds, set<Id> userIds){

		if (!eventIds.isEmpty() && !userIds.isEmpty()){
			
			getSettings();						
			
			list<Event> eventList = [SELECT id, StartDateTime, EndDateTime, Subject, Village_Activities__c,
								villages_Discussed__c, Event_Department__c,WhatId, Opportunity_Village__c,
								Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
								OwnerId, Owner.name, who.name, what.name, Location, Opportunity_Brand__c,
								Non_VR_Outlet_Full_Price_Performance__c 
								FROM Event 
                    			WHERE
                    				RecordTypeId = :B2BMeetingRecordTypeID
                    			AND
                 					Id IN :eventIds];
            map<Id, User> userMap = new map<Id, User>([select Id from User where id in:userIds]);
            
  system.debug (' ###########   User Map  ' + userMap);
  	          
            list<CollaborationGroupMember> memberList = [Select Id, MemberId, CollaborationGroup.Name  From CollaborationGroupMember where memberId in:userIds];        		

  system.debug (' ###########  Member List  ' + memberList);
			map<Id, list<string>> memberGroups = new map<Id, list<string>>();
			
			// put user chatter group name list into a map, keyed by user id
			for (CollaborationGroupMember member :memberList){
				list<string> groupList = memberGroups.get(member.memberId);
				if (groupList == null){
					groupList = new list<string>();					
				}
				groupList.add(member.CollaborationGroup.Name);
				memberGroups.put(member.memberId, groupList);
			}

system.debug (' ###########   Member Groups  ' + memberGroups);	
			
			for (event e:eventList){
				// put users to receive an email into a list, so can send email as a single bulkified call
				list<User> recipientsList = new list<User>();				
				
				string department = e.Event_Department__c;
				string villages = e.Villages_Discussed__c;
				list<string> villageList = new list<string>();
				User user = null;
				boolean valid = false;
				if (string.isnotBlank(villages)){
					villageList = villages.split(';');
				}
				for (Id memberId :memberGroups.keySet()){
					list<string> memberGroupList = memberGroups.get(memberId);
system.debug(' @@@@@@@@@@@@@@@@   Validating ... ' + memberId + ' ----  ' + memberGroupList);				
					valid = validToSend(department, villageList, memberGroupList);
					if (valid){
						user = userMap.get(memberId);
						recipientsList.add(user);
						
					}
				}
				if(!recipientsList.isEmpty()){ //there are users to send email to ..
					sendB2BEmail(recipientsList, e);
					
				}				
			}                    		
			
		}
		
	}


    private static void sendB2BEmail(list<User> userList, Event event) {

system.debug(' @@@@@@@@@@@@@@@@   User List ... ' + userList + ' ----  ' + event.Id);	

	    list<Messaging.SingleEmailMessage> mailList = new list<Messaging.SingleEmailMessage>();
	    
	    for (User user :userList){
		    // Create a new single email message object
	    	// that will send out a single email to the addresses in the To, CC & BCC list.
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
	        // Specify the address used when the recipients reply to the email.
	        mail.setReplyTo(replyTo);
	        	        
	        // Specify the name used as the display name.
	        mail.setOrgWideEmailAddressId(replyId);
	            	    
		    // Specify the subject line for your email address.
	    	mail.setSubject(event.What.Name + ' - ' + event.Subject + ' - B2B Meeting Report');
			
			mail.setSaveAsActivity(false);
			
			// Specify the text content of the email.
			mail.setPlainTextBody(getPlainBody(event));
	        
			// Specify the html version of the content as well.
			mail.setHtmlBody(getHTMLBody(event));
	
	       	mail.setTargetObjectId(user.Id);
	       	
	       	// add mail object to list so call to send email can be made in a single transaction
	       	// for all users, therefore avoiding the 'Too many email invocations 11' governor limit
	       	mailList.add(mail);
	    }
	    
	    if (!mailList.isEmpty()){
	    	// Send all the emails created.
    		Messaging.sendEmail(mailList);
	    
	    }

    }

    private static string getHTMLBody(final Event event) {
        String emailBodyHTML = emailBodyHTMLByEventId.get(event.Id);        
        if (emailBodyHTML != null)
            return emailBodyHTML;
    
        //open main span    
        emailBodyHTML = '<span style="font-weight: bold;font-size: 10pt;font-family: \'Arial\', \'Helvetica\';">';
        
        emailBodyHTML +=
                '<span style="color: black;">' + 
                'Account/Brand - </span><span style="color: blue;font-size: 12pt;">' + event.What.Name + '</span>'+
                '<br>';
        emailBodyHTML += ''+
                'Subject - <span style="color: blue;">' + event.Subject + '</span>' +
                '<br>';

        emailBodyHTML += ''+
                'Department - <span style="color: blue;">' + event.Event_Department__c + '</span>' +
                '<br>';
                
        emailBodyHTML += '<br>';
        emailBodyHTML += 'Villages Discussed:<br>';
        emailBodyHTML += '<span style="color: green;">' + getWhoIsInvolved(event, true) + '</span><br>';
        
        emailBodyHTML += 'Key Contact - <span style="font-weight: normal;">' + event.Who.Name + '</span><br>';
        emailBodyHTML += 'Assigned To - <span style="font-weight: normal;">' + event.Owner.Name + '</span><br>';
        emailBodyHTML += 'Other Invitees:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getEventInvitees(event.id, true) + '</span><br>';
        
        emailBodyHTML += 'Non-VR Outlet & Full Price Performance:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(event.Non_VR_Outlet_Full_Price_Performance__c, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        emailBodyHTML += 'Reason:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(event.Reason__c, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        emailBodyHTML += 'Meeting Comments:<br>';
        emailBodyHTML += '<span style="font-weight: normal;">' + getNotNull(event.Description, true) + '</span><br>';
        
        emailBodyHTML += '<br>';
        
        if (event.StartDateTime != null)
            emailBodyHTML += 'Start Date - <span style="font-weight: normal;">'+ event.StartDateTime.format(CALENDAR_VIEW_DATE_FORMAT) +'</span><br>';

        
		if (event.EndDateTime != null){
			emailBodyHTML += 'End Date - <span style="font-weight: normal;">'+ event.EndDateTime.format(CALENDAR_VIEW_DATE_FORMAT) + '</span><br>';
		}
            

            
        emailBodyHTML += 'Location - <span style="font-weight: normal;">'+ getNotNull(event.Location, true) +'</span><br>';
        //emailBodyHTML += 'Lease Book Handed Over - <span style="font-weight: normal;">' + (event.Lease_Book_Handed_Over__c? 'Yes':'No') + '</span><br>';
        //emailBodyHTML += 'Follow Up - <span style="font-weight: normal;">'+ getNotNull(event.Follow_Up_1__c, true) +'</span><br>';
        emailBodyHTML += 'Link to Report in Salesforce - <span style="font-weight: normal;"><a href="'+SERVERL_URL + event.id+'">' + event.Subject + '</a>' +'</span><br>';
        emailBodyHTML += '</span>';//close main span
        //save for future use
        emailBodyHTMLByEventId.put(event.Id, emailBodyHTML);         
        return emailBodyHTML;   
    }
    
    private static string getPlainBody(final Event event) {
        String emailBodyPlain = emailBodyPlainByEventId.get(event.Id);      
        if (emailBodyPlain != null)
            return emailBodyPlain;
            
        String emailBody;
        emailBody = '';
        
        emailBody += 'Account/Brand - ' + event.What.Name + '\n';
        emailBody += 'Subject - ' + event.Subject + '\n';
		emailBody += 'Department - ' + event.Event_Department__c + '\n';	

        emailBody += '\n';
        emailBody += 'Who is Involved:\n';
        emailBody += getWhoIsInvolved(event, false) + '\n';
        
        emailBody += 'Key Contact - ' + event.Who.Name + '\n';
        emailBody += 'Assigned To - ' + event.Owner.Name + '\n';
        emailBody += 'Other Invitees:\n';
        emailBody += getEventInvitees(event.id, false) + '\n';
        
        emailBody += 'Non-VR Outlet & Full Price Performance\n';
        emailBody += getNotNull(event.Non_VR_Outlet_Full_Price_Performance__c, false) + '\n';
        
        emailBody += '\n';
        emailBody += 'Reason:\n';
        emailBody += getNotNull(event.Reason__c, false) + '\n';
        
        emailBody += '\n';
        emailBody += 'Meeting Comments:\n';
        emailBody += getNotNull(event.Description, false) + '\n';
        
        emailBody += '\n';
        
        if (event.StartDateTime != null)
            emailBody += 'Start Date - '+ event.StartDateTime.format(CALENDAR_VIEW_DATE_FORMAT) + '\n';
        
        if (event.EndDateTime != null)
            emailBody += 'End Date - '+ event.EndDateTime.format(CALENDAR_VIEW_DATE_FORMAT) + '\n';

                        
        emailBody += 'Location - '+ getNotNull(event.Location, false) +'\n';
       // emailBody += 'Lease Book Handed Over - ' + (event.Lease_Book_Handed_Over__c? 'Yes':'No')+'\n';
       // emailBody += 'Follow Up - '+ getNotNull(event.Follow_Up_1__c, false) +'\n';
        emailBody += 'Link to Report in Salesforce:' + SERVERL_URL + event.id + '\n';
        emailBodyPlain = emailBody;
        
        //save for future use
        emailBodyPlainByEventId.put(event.Id, emailBodyPlain);       
        
        return emailBodyPlain;  
    }

    private static string getNotNull(String value, Boolean isHtml) {
        return getNotNull(value, null, isHtml); 
    }
    
    private static String getNotNull(String value, String defaultVal, Boolean isHtml) {
        Pattern newLinePattern = Pattern.compile('\n');
        String retValue = '';
        if (value != null)
            retValue = value;
        else if (defaultVal != null)
            retValue = defaultVal;
        
        if (isHtml) {
            //replace lines separator
            retValue = newLinePattern.matcher(retValue).replaceAll('<br>');
        }   
        return retValue;
            
    }

    private static string getWhoIsInvolved(Event theEvent, Boolean isHtml) {
        string villageList = '';
        
        // Set villages discussed
        if(null != theEvent.Villages_Discussed__c && theEvent.Villages_Discussed__c.length() > 0){
            List<String>  villagesDiscussedList = theEvent.Villages_Discussed__c.split(';');
            
            for(String aVillage : villagesDiscussedList){
                villageList += '-'+aVillage + (isHtml?'<br>':'\n') ;
            }            
        }
        return villageList;
        
    }

    private static String getEventInvitees (ID eventId, Boolean isHtml) {
        String namesList = '';
        map<Id, EventRelation> inviteeMap = new map<Id, EventRelation> ([Select EventId, RelationId, relation.name  
        																	FROM EventRelation where EventId =:eventId
        																	AND IsWhat = false]);
system.debug(' @@@@@@@@@@  OLD STYLE b2b ' + inviteeMap);
        																	
        for ( EventRelation eventAttendee :inviteeMap.values()){ 
            namesList += '- ' + (isUser(eventAttendee.RelationId)? 'VR' : 'Brand') + ' - ' + eventAttendee.relation.Name + (isHtml?'<br>':'\n');
        }
        return namesList;
    }
    private static boolean isUser(ID attendeeId) {
        String attId = attendeeId;
        return attId.startsWith('005');
    }


	// Checks event villages and department against user's chatter group membership
	// to determine whether to send B2B email
	private static boolean validToSend(string eventDepartment, 
										list<string>villageList, 
										list<string> membershipList){
		
		boolean returnValue = false;
		
		map<string, string> departmentMap = new map<string, string> ();
		map<string, string> villageMap = new map<string, string>();
		
		for (string chatterGroup :membershipList){
			string deptName = '';
			string villageName = '';						
	    	
	    	// extract department group from group name 
	    	if (chatterGroup.contains('B2B Meetings - ')){
				deptName = chatterGroup.substringAfter('B2B Meetings - ');
				departmentMap.put(deptName, deptName);			
	    	}	
	        	
	    	// extract village specific groups
	    	if (chatterGroup.contains('B2B Meetings in ')){
	    		villageName = chatterGroup.substringAfter('B2B Meetings in ');
	    		villageMap.put(villageName, villageName);
	    	}
		}	
		
		// check user is subscribed to event department chatter group
		boolean validDepartment = departmentMap.containsKey(eventDepartment);
		if (validDepartment){
			// subscribed to dept therefore valid to send email
			returnValue = true;
		} else {
			// check if user is subscribed to one of the villages mentioned on the event
			for (string village :villageList){
				if (villageMap.containsKey(village)){
					// subscribed to village, therefore valid to send email!
					returnValue = true;
					break;
				}
			}
			
		}
		
		return returnValue;
	}
	

}