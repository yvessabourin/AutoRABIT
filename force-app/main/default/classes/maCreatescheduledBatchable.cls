global class maCreatescheduledBatchable implements Schedulable {

   Map<Id, Marketing_Activity__c> maMap = new Map<Id, Marketing_Activity__c>([SELECT Id, Name FROM Marketing_Activity__c where Re_send_to_Oracle_for_NewActivity__c=True]);

   global void execute(SchedulableContext sc) {
   
   System.debug('ActivityId :'+maMap.keySet());
      MarketingActivityBatchCallout mabatch = new MarketingActivityBatchCallout(maMap.keySet()); 
      database.executebatch(mabatch);
   }
}