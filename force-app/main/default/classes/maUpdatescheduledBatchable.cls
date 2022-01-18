global class maUpdatescheduledBatchable implements Schedulable{

   Map<Id, Marketing_Activity__c> maMap = new Map<Id, Marketing_Activity__c>([SELECT Id, Name FROM Marketing_Activity__c where Re_send_to_Oracle_for_ActivityUpdate__c=True]);

   global void execute(SchedulableContext sc) {
   
   System.debug('ActivityId :'+maMap.keySet());
      MarketingActivityUpdateBatchCallout mabatch = new MarketingActivityUpdateBatchCallout(maMap.keySet()); 
      database.executebatch(mabatch);
   }
}