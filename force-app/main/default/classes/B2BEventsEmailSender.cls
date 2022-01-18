public with sharing class B2BEventsEmailSender {
	
	private static final String CALENDAR_VIEW_DATE_FORMAT = 'dd/MM/yyyy HH:mm';
	private static final id B2BMeetingRecordTypeID = Schema.SObjectType.Event.RecordTypeInfosByName.get('B2B meeting').RecordTypeId;
	private static final string NO_VILLAGE_TEXT = Label.NO_VILLAGE_TEXT;
	
	private static string displayName = ''; // 
	private static string replyTo = ''; //
	private static string replyId = '';
	private static string calendarUrl = '';
	
	private static list<String> eventVillageCategory = new list<string>();
	 
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
		
	//??
	public static void sendReportReminder(map<Id, list<string>> chatterGroupMembers, map<Id, User> allUsers){
		
		
	}
	
	
	public static void sendDailyEmail(map<Id, list<string>> chatterGroupMembers, map<Id, User> allUsers){
		
		map<Id,Event> allOfTommorrowsEvents = new Map<Id,Event> ();
		
		if (!test.isRunningTest()){
			if (string.isBlank(replyId)){
				getSettings();
			}
		}

		// Get all the Events for Tommorrow Or Monday
		string meetingSubject = 'B2B Meeting Summary – Day View: Tomorrow\'s Meetings '+ System.now().addDays(1).format('dd MMM yyyy');
		Date startOWeekDate = System.today().toStartOfWeek();
		// Check If today is friday
		if(startOWeekDate.addDays(4) == System.today()){
			// get Monday's Meeting
			meetingSubject = 'B2B Meeting Summary – Day View:  Monday\'s Meetings '+ System.now().addDays(3).format('dd MMM yyyy');
			allOfTommorrowsEvents = getDayEvents(System.now().addDays(3));
		} else {
			// get tommorrow's meetings
			allOfTommorrowsEvents = getDayEvents(System.now().addDays(1));
		}		
system.debug(' @@@  allOfTommorrowsEvents    ' + allOfTommorrowsEvents);
		//Organise by subject type and village  
		Map<String,Map<String,List<Event>>>  eventsByVillageAndDepartment = initializeDataViewMap();
	  
		for(Event anEvent : allOfTommorrowsEvents.values()){
			string eventDept = anEvent.Event_Department__c;
			string eventVillage = anEvent.Opportunity_village__c;
			if (string.isBlank(eventVillage)){
				eventVillage = anEvent.Villages_Discussed__c;
			}
          	// no village
          	if (string.isBlank(eventVillage)){
          		eventVillage = NO_VILLAGE_TEXT;
          	}
          	        
			// check if the Event is relevent to more than one village
			if(null != eventVillage && eventVillage.indexOf(';') >= 0 ){
				string[] villagesOftheEvent = eventVillage.split(';');
                for(String avillageOption : villagesOftheEvent){
                    if(eventsByVillageAndDepartment.get(eventDept) != null  && null != eventsByVillageAndDepartment.get(eventDept).get(avillageOption)){
                        ( eventsByVillageAndDepartment.get(eventDept).get(avillageOption) ).add(anEvent);
                    }
                }
            }else if( (null != eventVillage && eventVillage.trim().length() > 0 ) && eventVillage.indexOf(';') < 0){
                if(eventsByVillageAndDepartment.get(eventDept) != null  && null != eventsByVillageAndDepartment.get(eventDept).get(eventVillage)){
                    ( eventsByVillageAndDepartment.get(eventDept).get(eventVillage) ).add(anEvent); 
                }
            }   
        }
 
 system.debug(' @@@ eventsByVillageAndDepartment    ' + eventsByVillageAndDepartment);           
        // Build the Email mapped by the contact
        Map<String,Map<String,String>> emailMessageMap =  new Map<String,Map<String,String>>(); 
		map <string, User> sendList = new map<string, User>();
        for (string userId :chatterGroupMembers.keySet()){
	        list<string> chatterGroups = chatterGroupMembers.get(userId);
		        
		    if (allusers.containsKey(userId)){
			    string emailAddress = allUsers.get(userId).Email;		    
			    if (allUsers.get(userId).Receive_B2B_Emails__c){
					Map<String,String> personalizedMailing = buildPersonalizedEventAlert(chatterGroups,
																						eventsByVillageAndDepartment,
																						allUsers.get(userId));
				            
					emailMessageMap.put(emailAddress ,personalizedMailing);
					sendList.put(emailAddress, allUsers.get(userId));
			    }
		    }    
        }        

        // Iterate through and send the Emails
        List<Messaging.SingleEmailMessage> readyToGoEmails = new List<Messaging.SingleEmailMessage>();
                
        Integer mailing_tracker_logger = 0;
        if (!emailMessageMap.isEmpty()){
            for( User user : sendList.values() ){
                Messaging.SingleEmailMessage aRecipientEmailMsg = new Messaging.SingleEmailMessage();
                
                Map<String,String> currentRecipientsPersonalMessage = emailMessageMap.get(user.Email);
                
                aRecipientEmailMsg.setSubject(meetingSubject);
                aRecipientEmailMsg.setHtmlBody(currentRecipientsPersonalMessage.get('HTML-MSG'));

                aRecipientEmailMsg.setTargetObjectId(user.Id);
                    
                 // Specify the address used when the recipients reply to the email.          
	            if (string.isnotBlank(replyId)){
		            aRecipientEmailMsg.setReplyTo(replyTo);
		            //aRecipientEmailMsg.setSenderDisplayName(displayName);
		            aRecipientEmailMsg.setOrgWideEmailAddressId(replyId);
	            }

                aRecipientEmailMsg.setUseSignature(false);
                aRecipientEmailMsg.setSaveAsActivity(false);
                    
                readyToGoEmails.add(aRecipientEmailMsg);
        	}
        	Messaging.sendEmail(readyToGoEmails);
        }
		
	}


	public static void sendWeeklyEmail(map<Id, list<string>> chatterGroupMembers, map<Id, User> allUsers){
		
		if (!test.isRunningTest()){
			if (string.isBlank(replyId)){
				getSettings();
			}
		}
				
		boolean success = sendWeeklyAlerts(allUsers);
		
	}


    private static Map<Id,Event> getDayEvents(DateTime eventDate){
        if(null == eventDate)eventDate = System.now();
        Map <Id,Event> eventsFilteredForDay = new Map<Id,Event>();
        
        Date filterOnStartDate = eventDate.dateGmt().addDays(-4);
        Date filterOnEndDate = eventDate.dateGmt().addDays(-1);
        
        // Query to retrieve Events Data
        for(Event anEvent : [SELECT id, StartDateTime, EndDateTime, Subject, Village_Activities__c,
								villages_Discussed__c, Event_Department__c,WhatId, Opportunity_Village__c,
								Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
								OwnerId, Owner.name, who.name, what.name, Location, Opportunity_Brand__c
							FROM Event 
                    		WHERE
                    			RecordTypeId = :B2BMeetingRecordTypeID
                    		And
                    		(StartDateTime > :filterOnStartDate  And EndDateTime > :filterOnEndDate )
                    		And 
                    		IsChild = false
                    		And
                    		whatId != null                    
                    		Order By StartDateTime DESC
                    		LIMIT 4900
                    		]){
	           // Pick out the day from StartDateString  and EnddateTimeString
	           // If  Start DayDate <= And End DayDate >= todayDate
	           String  startString =  anEvent.StartDateTime.format(CALENDAR_VIEW_DATE_FORMAT);
	           String endDateString = anEvent.EndDateTime.format(CALENDAR_VIEW_DATE_FORMAT);
	           

	           Integer startDay = 0;
	           Integer startYear = 0;
	           Integer startMonth = 0;
	           
	           Integer endDay = 0;
	           Integer endYear = 0;
	           Integer endMonth = 0;
	           
	           if(Null != startString && startString.trim().length() > 12){
	                startDay =  Integer.valueOf( ( startString.substring(0,2) ) );
	                startYear =     Integer.valueOf( ( startString.substring(6,10) ) );
	                startMonth =    Integer.valueOf( ( startString.substring(3,5) ) );
	           }
	           
	           if(Null != endDateString && endDateString.trim().length() > 12){
	                endDay =    Integer.valueOf( ( endDateString.substring(0,2) ) );
	                endYear =   Integer.valueOf( ( endDateString.substring(6,10) ) );
	                endMonth =  Integer.valueOf( ( endDateString.substring(3,5) ) );
	           }
	           
	           Integer todayDateDay = eventDate.dateGmt().day();
	           Integer todayDatemonth = eventDate.dateGmt().month();
	           Integer todayDateYear = eventDate.dateGmt().year();
	           
	           
	           Date startDateFromString = Date.newInstance(startYear, startMonth, startDay);
	           Date endDateFromString = Date.newInstance(endYear, endMonth, endDay);
	           
	           if(startDay == todayDateDay && startMonth == todayDatemonth){
	                // add to return Map
	                eventsFilteredForDay.put(anEvent.Id,anEvent);
	           }else if( startDateFromString <= eventDate.dateGmt() && endDateFromString >= eventDate.dateGmt() ){
	                // add to return Map
	                eventsFilteredForDay.put(anEvent.Id,anEvent);
	           }
        
        }
        
        return eventsFilteredForDay;
    }

    private static Map<String,Map<String,List<Event>>>   initializeDataViewMap(){
        Map<String,Map<String,List<Event>>> eventsByVillageAndDepartment = new Map<String,Map<String,List<Event>>>();
        
        Set<String> deptTypes = describeDepartmentPickList();
        List<String> villages = describeEventVillageCategory();
        
        for(String dept : deptTypes ){
            if(eventsByVillageAndDepartment.get(dept) == null){
                
                Map<String,List<Event>> avillageEvents = new Map<String,List<Event>>();
                for(String aVillage : villages){
                    avillageEvents.put(aVillage, new List<Event>());
                }
                eventsByVillageAndDepartment.put(dept,avillageEvents);
            }
        }
        return eventsByVillageAndDepartment; 
    }
    
    private static Set<String> describeDepartmentPickList(){
        // Get the pickList Values
        Set<String> filterOptions = new Set<String>(); 
        Schema.DescribeFieldResult fieldDesc = Event.Event_Department__c.getDescribe();
        for (Schema.PicklistEntry pickOption : fieldDesc.getPicklistValues()){
            filterOptions.add(pickOption.getLabel());
        }
        if(Test.isRunningTest()){
        	filterOptions.add('TestDept');
        }
        return filterOptions;
    }

    public static List<String> describeEventVillageCategory(){
        // Get the pickList Values
        List<String> villageOptions = new List<String>(); 
        /*
        Schema.DescribeFieldResult fieldDesc = Event.villages_Discussed__c.getDescribe();
        
        for (Schema.PicklistEntry pickOption : fieldDesc.getPicklistValues()){
            villageOptions.add(pickOption.getLabel());
        }
        */
        if (eventVillageCategory.isEmpty()){
	        list<Village__c> villageList = [select name from village__c];
	        for(Village__c village :villageList){
	        	villageOptions.add(village.Name);
	        	eventVillageCategory.add(village.Name);
        	}
        	villageOptions.add(NO_VILLAGE_TEXT);
        	eventVillageCategory.add(NO_VILLAGE_TEXT);
        } else {
        	villageOptions = eventVillageCategory;
        }
        return villageOptions;
        
    }
        
    private static Map<String,String> buildPersonalizedEventAlert(list<string> chatterGroups, 
    							Map<String,Map<String, List<Event>>>  eventsByVillageAndDept, 
    							User user){
                
        Date startOWeekDate = System.today().toStartOfWeek();
         // Check If today is friday
        String messageLine1 = 'Please find below a list of the meetings due to take place tomorrow:<BR/><BR/>';
        if(startOWeekDate.addDays(4) == System.today()){
            // get Monday's Meeting
            messageLine1 = 'Please find below a list of the meetings due to take place next monday.<BR/><BR/>';
        }                   
        Map<String,String> personalizedMailing = new Map<String,String>();
                    
        List<String> subjectsOfInterest= null;
        List<String> villagesOfInterest = null;
        
        // Build Subjects/Departments of Interest
        subjectsOfInterest = new List<String>();
        villagesOfInterest = new List<String>();
        
        //loop through the chatter groups that user is subscribed to
        for (string chatterGroup :chatterGroups){     	
        	// extract department groups 
        	if (chatterGroup.contains('B2B Meetings - ')){
				string deptName = chatterGroup.substringAfter('B2B Meetings - ');
				subjectsOfInterest.add(deptName);
        		
        	}	
        	
        	// extract village specific groups
        	if (chatterGroup.contains('B2B Meetings in ')){
        		string villageName = chatterGroup.substringAfter('B2B Meetings in ');
        		villagesOfInterest.add(villageName);
        	}
        	
        }
		villagesOfInterest.add(NO_VILLAGE_TEXT);

        // Iterate through the Preferences
        String htmlMessage = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
            htmlMessage += ('Dear '+ user.name +',<BR/><BR/>');
        htmlMessage+='</SPAN>';
         if(null != subjectsOfInterest && null != villagesOfInterest ){
            htmlMessage += '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
                htmlMessage += messageLine1;
            htmlMessage+='</SPAN>';
            htmlMessage += getHeaderSection();

            for(String asubj : subjectsOfInterest){
                htmlMessage += '<FONT class="subjHeader" >'+asubj+'</FONT><BR/>';
//                htmlMessage += getEventsHTMLForSubjecOfInterest(asubj,eventsByVillageAndSubject.get(asubj),villagesOfInterest,attendeesByEventId);
				htmlMessage += getEventsHTMLForSubjecOfInterest(asubj,eventsByVillageAndDept.get(asubj),villagesOfInterest);
            }
            htmlMessage += getFooterSection();
         }else{
            htmlMessage += '<FONT color="red" size="4pt" style="font-weight : bold">';
                htmlMessage += 'You have been added to the B2B distribution list but your account has not been set up with the appropriate mailing subscriptions. Please reply to this message with your village and department of interest to start receiving the B2B Alerts.';
            htmlMessage += '</FONT>';
            
            htmlMessage += '<BR/><BR/>';
            
            htmlMessage  += getRemoveFromListAndRegards();
            
            
         }

                
        personalizedMailing.put('HTML-MSG',htmlMessage);
        personalizedMailing.put('TEXT-MSG','');

        return personalizedMailing;
    }    


       /////////////////////////////////////////////////////////////////////////////////
        
    private static String getEventsHTMLForSubjecOfInterest(String theSubject, Map<String,List<Event>> theEvents,
        List<String> villagesOfInterest){

        boolean backgroundToggle = true;
            String rowBck = '';
            
        Set<Id> addedEvents = new Set<Id>();
        String sectionHTML = '';
           
        sectionHTML += '<TABLE style="font-size : 11px;" width="90%">';
            sectionHTML += '<TR class="datatableHeading">';

                sectionHTML += '<TD width="20%">';
                    sectionHTML += 'Subject';
                sectionHTML += '</TD>';
                                
                sectionHTML += '<TD width="10%">';
                    sectionHTML += 'Villages';
                sectionHTML += '</TD>';
                
                sectionHTML += '<TD width="10%">';
                    sectionHTML += 'Brand';
                sectionHTML += '</TD>';
                
                sectionHTML += '<TD width="16%">';
                    sectionHTML += 'Reason';
                sectionHTML += '</TD>';
                
                sectionHTML += '<TD width="10%">';
                    sectionHTML += 'VR Contact';
                sectionHTML += '</TD>';
                
                sectionHTML += '<TD width="16%">';
                    sectionHTML += 'Brand Contact';
                sectionHTML += '</TD>';
                
                sectionHTML += '<TD width="10%">';
                    sectionHTML += 'Location';
                sectionHTML += '</TD>';
                
                sectionHTML += '<TD width="8%">';
                    sectionHTML += 'Time';
                sectionHTML += '</TD>';
            sectionHTML += '</TR>';
            
            String currentVillage ='NA';
            
            // To add seperator lines
                
            
            for(String villageName : villagesOfInterest){
                if(theEvents == null) continue;
                    List<Event> theVillageEvents = theEvents.get(villageName);
                    if(null == theVillageEvents)continue;
                    
                    for(Event theEvent : theVillageEvents){
                        if(backgroundToggle){
                            rowBck = ' style= "font-family: Calibri,Sans-Serif;background-color: #E8E8E8;padding : 2px ; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;" ';
                        }else{
                            rowBck  = ' style="font-family: Calibri,Sans-Serif;background-color: #F8F8F8 ;padding : 2px; border:3px solid #FFFFFF;font-size : 11px; vertical-align : top;"';
                        }

                        if(addedEvents.contains(theEvent.Id))continue;
                        backgroundToggle = !backgroundToggle;
                        
                        sectionHTML += '<TR '+rowBck +'>';
                        
                        sectionHTML += '<TD >';
							// Create the event URL from the base URL.
							string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       			'/' + theEvent.Id;
							sectionHTML +=  '<a href='  + eventURL + '>'  + theEvent.Subject + '</a>' ; 
                        sectionHTML += '</TD>';
                        
                        
                        sectionHTML += '<TD >';
                            String formattedVillagesDiscussed = formatVillagesDiscussed(theEvent.villages_Discussed__c);
                            //if(currentVillage != formattedVillagesDiscussed){
                                currentVillage = formattedVillagesDiscussed;
                                sectionHTML += formattedVillagesDiscussed; 
                            //}
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += theEvent.What.Name;
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += theEvent.Reason__c;
                        sectionHTML += '</TD>';
                                
                        sectionHTML += '<TD>';
                            sectionHTML += theEvent.Owner.Name;
                            sectionHTML += '<BR/>';

                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            sectionHTML += theEvent.Who.Name;
                            sectionHTML += '<BR/>';

                        sectionHTML += '</TD>';
                                
                        sectionHTML += '<TD>';
                            sectionHTML += theEvent.Location;
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
							String  startString =  theEvent.StartDateTime.format(CALENDAR_VIEW_DATE_FORMAT);
	           				String endDateString = theEvent.EndDateTime.format(CALENDAR_VIEW_DATE_FORMAT);
                            //if(null != theEvent.StartDateTimeString__c && theEvent.StartDateTimeString__c.length() > 10){
                                sectionHTML += (startString.substring(10,startString.length()) +' '); // +theEvent.Location_Time_Zone__c);    
                           // }
                        sectionHTML += '</TD>';
                        
                    sectionHTML += '</TR>';
                    
                    addedEvents.add(theEvent.Id);
                }   
        	}
                
        sectionHTML += '</TABLE>';
        sectionHTML += '<BR/><BR/>';
            
        if(addedEvents.isEmpty()){
            sectionHTML = 'There are no meetings for this department. <BR/><BR/>' ;
        }
            
        return sectionHTML;
    }

    private static String formatVillagesDiscussed(String unFormattedVillagesDiscussed){
        String villagesDiscussed ='';
        if(null != unFormattedVillagesDiscussed && unFormattedVillagesDiscussed.length() > 0){
                List<String>  villagesDiscussedList = unFormattedVillagesDiscussed.split(';');
                Integer villageCounter = 0;
                for(String aVillage : villagesDiscussedList){
                    villageCounter++;
                    villagesDiscussed += aVillage;
                    if(villageCounter < villagesDiscussedList.size()) villagesDiscussed+=', ';
                }

            }
        return  villagesDiscussed;
    }

    private static String getHeaderSection(){
        String sectionHTML = '';
        sectionHTML += '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
        
            sectionHTML += '<style type="text/css">';
                sectionHTML += '.subjHeader{';
                    sectionHTML += 'font-size : 12px; text-decoration : underline;font-weight : bold';
                sectionHTML += '}';
                sectionHTML += '.datatableHeading{';
                    sectionHTML += 'font-family: Calibri,Sans-Serif;font-weight : bold;';
                    sectionHTML += 'background-color :  #C0C0C0;';
                    sectionHTML += 'text-align :  center;';
                sectionHTML += '}';
                sectionHTML += '.datatableHeading td {';
                    sectionHTML += 'vertical-align : top;';
               sectionHTML += '}';
            sectionHTML += '</style>';

        return sectionHTML;
    }

        private static String getFooterSection(){
            String sectionHTML = '';
            for(Integer xx=0;xx<3;xx++){
                sectionHTML += '<BR/>';
            }
            sectionHTML += 'Consistent and transparent communication is vital in order to maximise opportunities for every Brand within the group.';
            /* sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "' + calendarUrl + '" >';
            sectionHTML += 'Please view the full calendar ';
            sectionHTML += '<font style="text-decoration : underline; "> here </font>';
            sectionHTML += 'on a regular basis to ensure that all opportunities to leverage brand relationships have been explored.';
            sectionHTML += '</A>'; */
            
            sectionHTML += '<BR/><BR/><BR/>';
            
            sectionHTML += getRemoveFromListAndRegards();

            sectionHTML += '</SPAN>'; // End With Closing SPAN
            
            return sectionHTML;
        }

        private static String getRemoveFromListAndRegards(){
            String sectionHTML = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; 

            sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "mailto:' + replyTo +'?subject=Please remove me from the Salesforce - Meeting Alert/Reports Distribution List" >';
            sectionHTML += 'If you would like to be removed from this distribution list please click';
            sectionHTML += '<font style="text-decoration : underline; "> here </font>';
            sectionHTML += '</A>';
            
            sectionHTML += '<BR/><BR/>';
            
            sectionHTML += 'Kind Regards';
            sectionHTML += '</SPAN>';
            
            return sectionHTML;
            
        }
		
	// Weekly Email Specific methods 
	
    private static map <Id,Event> getWeeklyViewOfEventData(){

		Datetime newDateRange = DateTime.newInstanceGmt(System.now().date(), System.now().time());
		Set<string> departments = describeDepartmentPickList();
   
        // Set Start Date
        newDateRange = newDateRange.adddays(7); //add 7 days to ensure records for the following week are returned
        Date filterStartDate = newDateRange.date().toStartOfWeek();
        filterStartDate = filterStartDate.addDays(-1); // Make allowance for Time Zone differences;
        Date filterEndDate = filterStartDate.addDays(6);
          
        // Query to retrieve Events Data
        Map <Id,Event> eventsFilteredForWeek =  new Map <Id,Event>
        					([SELECT id, StartDateTime, EndDateTime, Subject,
							villages_Discussed__c, Event_Department__c,WhatId,
							Account.Name, Event_Status__c,who.name, what.name, Location,
							Opportunity_Brand__c, Opportunity_Village__c
				FROM Event 
                WHERE
                (Event_Department__c IN :departments  Or Subject IN :departments )
                And
                RecordTypeId = :B2BMeetingRecordTypeID
                And 
                IsChild = false
                And 
                (StartDateTime >= :filterStartDate
                And
                EndDateTime <= :filterEndDate)
                Order By StartDateTime, What.Name
                LIMIT 4900                    
                ]);     
        
        if(null != eventsFilteredForWeek){
            return eventsFilteredForWeek;
        }else{
            return new Map<Id,Event>();   
        }
    }
	
	//Method to return all events for the week grouped by day of week and village
	private static map<string, map<string, set<string>>> getWeeksMeetingsGrouped(list<Event> eventsFilteredForWeek){

       
       map<string, map<string, set<string>>> weeksEventsGrouped = new map<string, map<string, set<string>>>();
       
       if (!eventsFilteredForWeek.isEmpty()){
        
	        
	        map<string, set<string>> villageBrands = new  map<string, set<string>>();
	        set<string> daysBrands = new set<string>();
 
	        for (Event ev :eventsFilteredForWeek){
	        	DateTime startTime = (DateTime) ev.StartDateTime;
	        	string brand = ev.what.name;
				string village = '';
				
				Schema.SObjectType objType = ev.whatId.getSobjectType();	
				if (objType.getDescribe().getName() == 'Opportunity'){
					brand = ev.Opportunity_Brand__c;
					village = ev.Opportunity_Village__c;
					if (string.isBlank(brand)){
						brand = ev.subject.substringAfter(' : ');
						brand = brand.substringBefore(' in ');
					}
			
				}
				// extract village from subject
				if (string.isBlank(village)){
		        	if (ev.subject.contains(brand + ' in ')){
		        		village = ev.subject.substringAfter(brand + ' in ');
		        	}
		        	if (string.isBlank(village)){
		        		list<string> villageList = new list<string>();
		        		if (string.isnotBlank(ev.Villages_Discussed__c)){
			        		villageList = ev.Villages_Discussed__c.split(';');
			        		village = villageList[0];
		        		}	
		        	}
				}
				
				if (string.isBlank(village)){
					village = NO_VILLAGE_TEXT;
				}
				
	        	if (string.isnotBlank(village)){
					string dayOfWeek = startTime.format('E');
					// dayOfWeek is Sun, Mon, Tue, etc.
					villageBrands =  weeksEventsGrouped.get(dayOfWeek);
					if (villageBrands == null){
						villageBrands =  new map<string, set<string>> ();
					}
					daysBrands = villageBrands.get(village);
					if (daysBrands == null){
						daysBrands = new set<string>();
					}
					daysBrands.add(ev.Id + '##' + brand); // add brand with event Id prefix for later splitting when constructing email HTML.
					villageBrands.put(village, daysBrands);
					weeksEventsGrouped.put(dayOfWeek, villageBrands);          	
	        	} 
	        
	        }
        } 		
	
		return weeksEventsGrouped;
	
	}    	


	private static string buildWeeklyMessageFOrRecipients(map<string, map<string, set<string>>> groupedEvents, User user){
        
        DateTime dt = system.Now();
        dt= dt.addDays(7);
        dt = dt.Date().toStartOfWeek();
system.debug('GROUPED EVENTS ...   ' + groupedEvents);        
        String sectionHTML = '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">'; // Start With Opening SPAN
                sectionHTML += 'Dear '+user.name;
                sectionHTML += '<BR/><BR/>';
                sectionHTML += 'Please find below the calendar of the meetings due to take place next week:</BR></BR>';
        sectionHTML+='</SPAN>';

         sectionHTML += '<SPAN style="font-family: Calibri,Sans-Serif;font-size : 12px;">';
            sectionHTML += '<style type="text/css">';
                sectionHTML += 'table{';
                    sectionHTML += 'font-family: Calibri,Sans-Serif;font-size : 11px;';
                sectionHTML += '}';
                sectionHTML += '.datatableHeading{';
                    sectionHTML += 'font-weight : bold;';
                    sectionHTML += 'background-color :  #BFEFFF;';
                sectionHTML += '}';
                sectionHTML += '.datatableHeading td {';
                    sectionHTML += 'vertical-align : top;';
               sectionHTML += '}';
            sectionHTML += '</style>';
                
            sectionHTML += '<TABLE width="95%" style="background-color:#F8F8F8 ;border-collapse:collapse;font-size : 11px;" >';
                sectionHTML += '<TR>';
                    sectionHTML += '<TD>';
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD>';
                        sectionHTML += 'Monday </BR>';
                        sectionHTML += dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                        
                    sectionHTML += '<TD>';
                    	dt = dt.addDays(1);
                        sectionHTML += 'Tuesday</BR>';
                        sectionHTML +=dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD>';
                    	dt = dt.addDays(1);
                        sectionHTML += 'Wednesday</BR>';
                        sectionHTML +=dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                        
                    sectionHTML += '<TD>';
                        dt = dt.addDays(1);
                        sectionHTML += 'Thursday</BR>';
                        sectionHTML += dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD>';
                        dt = dt.addDays(1);
                        sectionHTML += 'Friday</BR>';
                        sectionHTML += dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD>';
                    	dt = dt.addDays(1);
                        sectionHTML += 'Saturday</BR>';
                        sectionHTML +=dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                    
                    sectionHTML += '<TD>';
                        dt = dt.addDays(1);
                        sectionHTML += 'Sunday</BR>';
                        sectionHTML +=dt.format('dd/MM/yyyy');
                    sectionHTML += '</TD>';
                sectionHTML += '</TR>';
                    
                boolean backgroundToggle = false;
                String rowBck = '';
                list<string> villageList = describeEventVillageCategory();
                for(String aVillage : villageList){
                    map<string, set<string>> daysEvents = new map<string, set<string>>();
                    set<string> villageBrands = new set<string>();
                    if(backgroundToggle){
                        rowBck = ' style= "background-color: #E8E8E8  ;padding : 2px ; border:3px solid #FFFFFF;" ';
                    }else{
                        rowBck  = ' style="background-color: #F8F8F8 ;padding : 2px; border:3px solid #FFFFFF;"';
                    }
                        

                    backgroundToggle = !backgroundToggle;
                    
                    sectionHTML += '<TR '+rowBck +'>';
                        sectionHTML += '<TD style="vertical-align : top; background-color: #C0C0C0;padding : 2px;text-align:left;border:3px solid #FFFFFF;font-size:11.5px" >';
                            sectionHTML += aVillage;
                        sectionHTML += '</TD>';
                        
                        sectionHTML += '<TD>';
                            // Monday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Mon');
                           
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                           	
                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                            
                        sectionHTML += '<TD>';
                            // Tuesday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Tue');
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                            	
                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                            
                        sectionHTML += '<TD>';
                            // Wednesday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Wed');
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                            	
                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                            
                        sectionHTML += '<TD>';
                            // Thursday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Thu');
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                            	                            
                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }   
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                            
                        sectionHTML += '<TD>';
                            // Friday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Fri');                            
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                            	                            

                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                            
                        sectionHTML += '<TD>';
                            // Saturday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Sat');
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                            	                            
                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                            
                        sectionHTML += '<TD>';
                            // Sunday
                            sectionHTML += '<TABLE width="100%">';
                            daysEvents = groupedEvents.get('Sun');
                            villageBrands = new set<string>();
                            if (daysEvents != null){
                            	villageBrands = daysEvents.get(aVillage);
                            	if (villageBrands == null){
                            		villageBrands = new set<string>();
                            	}
                            }else{
                            	villageBrands = new set<string>();
                            }
                            	                            
                            for(string brand : villageBrands){
                                list<string> vbev = brand.split('##'); // string should be of format eventId##brand name
                                if (vbev.size() > 1){
									// Create the event URL from the base URL.
									string eventURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                       					'/' + vbev[0];
									brand =  '<a href='  + eventURL + '>'  + vbev[1] + '</a>' ; 
                                }
                                sectionHTML += '<TR>';
                                    sectionHTML += '<TD>';
                                        sectionHTML += brand;
                                    sectionHTML += '</TD>';
                                sectionHTML += '</TR>';
                            }
                            sectionHTML += '</TABLE>';
                        sectionHTML += '</TD>';
                    sectionHTML += '</TR>';
                    }
            sectionHTML += '</TABLE>';
            
            //sectionHTML += '<BR/><BR/>';
            sectionHTML += getFooterSection_Week();
            
        sectionHTML += '</SPAN>';
            
        return sectionHTML;
    }
        
    public static Boolean sendWeeklyAlerts(map<Id, User> allUsers){
        
        list<User> sendList = new list<User>();
        map<string, map<string, set<string>>> groupedEvents = new map<string, map<string, set<string>>>(); 
        Boolean allSent = false;
        map <Id,Event> eventsFilteredForWeek = getWeeklyViewOfEventData();
        if (!eventsFilteredForWeek.isEmpty()){
        	groupedEvents = getWeeksMeetingsGrouped(eventsFilteredForWeek.values());
        }
        
        
        Map<String,String> messagesByEmail = new Map<String,String>();
        for(User user : allusers.values()){
            if (user.Receive_Weekly_B2B_Emails__c){
	            String msgHTML = buildWeeklyMessageFOrRecipients(groupedEvents, user);
	            messagesByEmail.put(user.email , msgHTML);
	            sendList.add(user);
            
            }
        }

        Date startOfWeekDate = System.now().addDays(7).date().toStartOfWeek();
        DateTime DateForFormat = DateTime.newInstance(startOfWeekDate.year(),startOfWeekDate.month(),startOfWeekDate.day());
        String alertSubject = 'B2B Meeting Summary – Weekly Calendar – Week Beginning ' + DateForFormat.format('dd MMM yyyy');
        
        List<Messaging.SingleEmailMessage> weeklyMessagesByRecipients = new List<Messaging.SingleEmailMessage>();
                  
        for(User user :sendList){
            Messaging.SingleEmailMessage weeklyAlertMsg = new Messaging.SingleEmailMessage();
            weeklyAlertMsg.setSubject(alertSubject);
            weeklyAlertMsg.setHtmlBody(messagesByEmail.get(user.email));
            
            if(null != user.email){
                weeklyAlertMsg.setTargetObjectId(user.id);
            }else{
                weeklyAlertMsg.setToAddresses(new String [] {user.email});
            }
          
            if (string.isnotBlank(replyId)){
	            weeklyAlertMsg.setReplyTo(replyTo);
	            //weeklyAlertMsg.setSenderDisplayName(displayName);
	            weeklyAlertMsg.setOrgWideEmailAddressId(replyId);
            }
            
            weeklyAlertMsg.setUseSignature(false);
            weeklyAlertMsg.setSaveAsActivity(false);
            
            weeklyMessagesByRecipients.add(weeklyAlertMsg);
        }
                
        Messaging.sendEmail(weeklyMessagesByRecipients);
        
        allSent = true;
        
        return allSent;
    }

	private static string getFooterSection_Week(){
        String sectionHTML = '';
        for(Integer xx=0;xx<3;xx++){
            sectionHTML += '<BR/>';
        }
        sectionHTML += 'Consistent and transparent communication is vital in order to maximise opportunities for every Brand within the group. ';
        /* sectionHTML += '<A style="color: black;text-decoration : none; " HREF = "' + calendarUrl +'" >';
        sectionHTML += 'Please view the interactive  calendar ';
        sectionHTML += '<font style="text-decoration : underline; "> here </font>';
        sectionHTML += 'on a regular basis to ensure that all opportunities to leverage brand relationships have been explored.';
        sectionHTML += '</A>'; */
            
		sectionHTML += '<BR/><BR/><BR/>';
            
		sectionHTML += getRemoveFromListAndRegards();

		sectionHTML += '</SPAN>'; // End With Closing SPAN
            
		return sectionHTML;
	}
		    
}