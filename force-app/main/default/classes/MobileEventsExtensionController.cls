public with sharing class MobileEventsExtensionController {

    public MobileEventsExtensionController(ApexPages.StandardController controller) {}
    public MobileEventsExtensionController(ApexPages.StandardSetController controller) {}

    public string searchValue {get; set;}


    Public list<Event> GetPreviousEvents()
    {
        list<event> listOfEvents = [SELECT id, StartDateTime, Subject, Village_Activities__c,
                                                 Villages_Discussed__c, Event_Department__c,
                                                                                        Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
                                                                                        OwnerId
                                    FROM Event 
                                    WHERE StartDateTime = LAST_N_DAYS:7 and whatId != null
                                    and isChild = false 
                                    ORDER BY StartDateTime
                                    LIMIT 100];
                                    
        return ProcessEvents(listOfEvents);
    }
    
    Public list<Event> GetEvenMoveEvents()
    {
        list<event> listOfEvents = [SELECT id, StartDateTime, Subject, Village_Activities__c,
                                                 Villages_Discussed__c, Event_Department__c,
                                                                                        Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
                                                                                        OwnerId
                                    FROM Event 
                                    WHERE StartDateTime >= LAST_N_DAYS:14 and StartDateTime < LAST_N_DAYS:7 and whatId != null
                                    and isChild = false 
                                    LIMIT 100];
                                    
               return ProcessEvents(listOfEvents);
    }
 
 
    Public list<Event> GetFutureEvents()
    {
 

        list<event> listOfEvents = [SELECT id, StartDateTime, Subject, Village_Activities__c,
                                                 Villages_Discussed__c, Event_Department__c,
                                                                                        Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
                                                                                        OwnerId 
                                            FROM Event 
                                            WHERE StartDateTime >  NEXT_N_DAYS:7 and StartDateTime = NEXT_90_DAYS and whatId != null
                                            and isChild = false 
                                            LIMIT 15];
        
                return ProcessEvents(listOfEvents);
    }   
    
   
    Public list<Event> GetTodaysEvents()
    {
        list<event> listOfEvents = [SELECT id, StartDateTime, Subject, Village_Activities__c,
                                                 Villages_Discussed__c, Event_Department__c,
                                                                                        Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
                                                                                        OwnerId 
                                            FROM Event 
                                            WHERE StartDateTime = TODAY and whatId != null
                                            and isChild = false 
                                            LIMIT 100];
        
        return ProcessEvents(listOfEvents);
    } 
    
    
    Public list<Event> GetThisWeeksEvents()
    {
        list<event> listOfEvents = [SELECT id, StartDateTime, Subject, Village_Activities__c,  
                                                 Villages_Discussed__c, Event_Department__c,
                                                                                        Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
                                                                                        OwnerId 
                                         FROM Event WHERE StartDateTime = THIS_WEEK and StartDateTime > TODAY  and whatId != null 
                                         and isChild = false 
                                         LIMIT 100];
        
       return ProcessEvents(listOfEvents);
    } 
    
    Public list<Event> GetNextWeeksEvents()
    {
        list<event> listOfEvents = [SELECT id, StartDateTime, Subject, Village_Activities__c,  
                                                Villages_Discussed__c, Event_Department__c,
                                                                                        Description,Reason__c, Account.Name, Event_Status__c, Event_Headline__c, 
                                                                                        OwnerId 
                                         FROM Event WHERE StartDateTime = NEXT_WEEK and whatId != null
                                         and isChild = false 
                                         LIMIT 100];
        
        return ProcessEvents(listOfEvents);
    } 



    private list<Event> ProcessEvents(list<Event> Events){
    
        IF (Events == NULL) Return null ;
        
        list<Event> shortenedEvents = Events;
    
        FOR (Event cEvent : shortenedEvents ){
        
         if (string.isnotblank(cEvent.description) && cEvent.description.length() >= 50 ){
                cEvent.description = cEvent.description.substring(0,50) + '...';
            }
        }
        
        return shortenedEvents;
    }



}