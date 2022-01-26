global without sharing class EventsCalendarController2 {

    public string recordId{get;set;}
    public Event eventRecord {get; set;}
    public string tabOpt {get;set;}
    public string SFInstanceUrl {get; set;}    

    
    public EventsCalendarController2(){        
        
        tabOpt = 'detailsTab';

		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
		if (settings != null) {
			SFInstanceUrl = settings.Salesforce_Instance_URL__c;		
		} else {
			SFInstanceUrl = '';
		}

    }
    
    public pageReference gotoEvent(){

        PageReference newPage = new PageReference('/' + recordId);
        newPage.setRedirect(true);
        return newPage;    
    
    }
    
    public void getEventRecord(){

        if (!string.isBlank(recordId)){
            eventRecord = [SELECT Id, Event_headline__c, RecordTypeId,Subject,Event_Department__c,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, 
                            ActivityDate, StartDateTime, EndDateTime, Description,AccountId, Owner.Name, OwnerId, Type, 
                            IsChild, IsGroupEvent,GroupEventType, CreatedDate, CreatedById,Reason__c
                        from Event 
                        where id = :recordId];
            showPopup();
            
        }    
    
    }
    
    // Event WrapperJson returned to UI
    global Class EventWrapperJson{
		public string eventsJson;
		private list<Event> eventList;       	
    }
    
    @remoteAction
    global static EventWrapperJson getEvents()
    {
    
        EventWrapperJson returnWrapper = new EventWrapperJson();  
        
        // Only retrieve previous 3 months data, and following 3 months data
        Date pastEvents = system.today().addMonths(-3);
        pastEvents = pastEvents.toStartOfMonth();
        
        Date futureEvents = system.today().addMonths(13);
        futureEvents = futureEvents.toStartOfMonth();
        futureEvents = futureEvents.addDays(-1);
        
        list<event> eventsForCal = [SELECT Id, RecordTypeId,Subject,Event_Department__c,WhatId, What.Name, WhoId, Who.Name,Location, IsAllDayEvent, ActivityDateTime, 
        ActivityDate, StartDateTime, EndDateTime, Description, AccountId, Owner.Name, OwnerId, Type, 
        IsChild, IsGroupEvent,GroupEventType, CreatedDate, CreatedById, Department_Colour__c
            from Event 
            WHERE whatId != null
            and StartDateTime >= :pastEvents
            and EndDateTime <= :futureEvents
            and isChild = false
            order by startdatetime asc];

                
        if (!eventsForCal.isEmpty()){
        	returnWrapper.EventsJson =  Json.serialize(eventsForCal);
        	returnWrapper.eventList = eventsForCal;         	
        }
        
        return returnWrapper;
    }

	//--popup menu 
 	public boolean displayPopup {get; set;}     

    public void closePopup() {        
        displayPopup = false; 
        recordId = null;   
    }     

    public void showPopup() {          
        displayPopup = true;    
    } //end of popupmenu


}