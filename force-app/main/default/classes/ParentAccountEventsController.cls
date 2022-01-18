public with sharing class ParentAccountEventsController {

private final account brandAccount;
Public list<event> ParentEvents;
    
    public ParentAccountEventsController(ApexPages.StandardController stdcontroller) {
        this.brandAccount = (Account)stdcontroller.getRecord();
        list<account> ParentAccountIdList = [SELECT parentid FROM Account WHERE id = :brandAccount.id];
        ParentEvents = [SELECT id, Location, Subject, Villages_Discussed__c, StartDateTime, owner.name, who.name, Reason__c FROM Event WHERE whatid = :ParentAccountIdList[0].parentid];
    }

    public list<event> getParentEvents()
    {
        return ParentEvents;
    }
    
    public boolean getdisplayresults()
    {
        
        if (ParentEvents.size() > 0)        {
            return true;
            }
        else{
           return false;
        }
    }
    
}