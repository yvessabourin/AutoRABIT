public with sharing class MassEditTradeEventAttendees {

    //test
    public id recordId {get;set;}
    Public list<Trade_Event_Attendee__c> registeredAttendees {get;set;}
    Public List<cTradeAttendee> attendeesToEdit {get;set;}
    public Trade_Event_Attendee__c selectOptions {get;set;}

    public MassEditTradeEventAttendees(ApexPages.StandardController standardController) {
        selectOptions = new Trade_Event_Attendee__c();
        recordId = standardController.getId();
        attendeesToEdit = new list<cTradeAttendee>();
        registeredAttendees = [SELECT ID, Name,Contact__c,Invite_Status__c,Followed_Up__c,Title__c  FROM Trade_Event_Attendee__c WHERE Trade_Event__c =:recordId ORDER BY Name ASC ];
        system.debug('registeredAttendees' + registeredAttendees);
            for (Trade_Event_Attendee__c TEA : registeredAttendees ){
                system.debug('test');
                attendeesToEdit.add(new cTradeAttendee(TEA));
            }
    }


    Public Pagereference Cancel() {
    PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }



    Public Pagereference saveSelected() {
        list<Trade_Event_Attendee__c> TEAUpdates = new List<Trade_Event_Attendee__c>();
            for(cTradeAttendee cTEA: attendeesToEdit) {
                    if(cTEA.selected == true) {
                        TEAUpdates.add(cTEA.attendee); 
                    }
            }        
        update TEAUpdates;        
        PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }


    Public Pagereference selectAll() {
        for(cTradeAttendee cTEA : attendeesToEdit){
            cTEA.selected = true;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }

    Public Pagereference deselectAll() {
        for(cTradeAttendee cTEA : attendeesToEdit){
            cTEA.selected = false;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }

    Public Pagereference setAllStatus() {
        for(cTradeAttendee cTEA : attendeesToEdit){
            cTEA.attendee.Invite_Status__c = selectOptions.Invite_Status__c;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }


    Public Pagereference setAllFollowUps() {
        for(cTradeAttendee cTEA : attendeesToEdit){
            cTEA.attendee.Followed_Up__c = selectOptions.Followed_Up__c;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }





    public class cTradeAttendee{
        public Trade_Event_Attendee__c attendee {get; set;}
        public Boolean selected {get; set;}

        public cTradeAttendee(Trade_Event_Attendee__c tea) {
            attendee = tea;
            selected = false;

        }
    }
}