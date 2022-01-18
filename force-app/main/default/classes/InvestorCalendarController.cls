public without sharing class InvestorCalendarController {
 
    public Boolean includeMyEvents {get;set;}
    public list<calEvent> events {get;set;}
    private static final id invRecordTypeID = Schema.SObjectType.Event.RecordTypeInfosByName.get('Investor Meeting').RecordTypeId; 
    
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    String dtFormat = 'EEE, d MMM yyyy HH:mm:ss';
     
    //constructor
    public InvestorCalendarController() {
        //Default showing my events to on
        includeMyEvents = false;
    }
     
    public PageReference pageLoad() {
        events = new list<calEvent>();
        //Get investor meetings
        for(Event evnt : [select Id, Subject, isAllDayEvent, StartDateTime, EndDateTime, Who.Name, What.Name from Event 
        								where RecordTypeId = :invRecordTypeID
        								And IsChild = false
        								and StartDateTime > :system.today().addDays(-100)
        								]){
            DateTime startDT = evnt.StartDateTime;
            DateTime endDT = evnt.EndDateTime;
            calEvent invEvent = new calEvent();
             
            invEvent.title = evnt.Who.Name + ' ' + evnt.What.Name + ' - ' + evnt.Subject;
            invEvent.allDay = evnt.isAllDayEvent;
            invEvent.startString = startDT.format(dtFormat);
            invEvent.endString = endDT.format(dtFormat);
            invEvent.url = '/' + evnt.Id;
            invEvent.className = 'event-investor';
            events.add(invEvent);
        }
//system.debug('@@@ events  ' + events.size() + ' - ' + events[events.size() - 1] + ' .... ' + events);
                  
        //Get my Events if we have selected the correct option
        if(includeMyEvents){
            for(Event evnt: [select Id, Subject, isAllDayEvent, StartDateTime, EndDateTime, Who.Name, What.Name 
            					from Event where OwnerID = :UserInfo.getUserId()            					
            					and StartDateTime > :system.today().addDays(-100)
            					and IsChild = false])
            {
                DateTime startDT = evnt.StartDateTime;
                DateTime endDT = evnt.EndDateTime;
                calEvent myEvent = new calEvent();
                 
                myEvent.title = evnt.Who.Name + ' ' + evnt.What.Name + ' - ' + evnt.Subject;
                myEvent.allDay = evnt.isAllDayEvent;
                myEvent.startString = startDT.format(dtFormat);
                myEvent.endString = endDT.format(dtFormat);
                myEvent.url = '/' + evnt.Id;
                myEvent.className = 'event-personal';
                events.add(myEvent);
            }
        }
        return null;
    }
     
    public PageReference toggleMyEvents() {
        if(includeMyEvents){
            includeMyEvents = false;
        }
        else{
            includeMyEvents = true;
        }
        pageload();
        return null;
    }
 
     
    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;set;}
        public String endString {get;set;}
        public String url {get;set;}
        public String className {get;set;}
    }
    
}