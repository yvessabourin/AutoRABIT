global class marketingCampaignscheduledBatchable implements Schedulable {

   Map<Id, Marketing_Campaign__c> mcMap = new Map<Id, Marketing_Campaign__c>([SELECT Id, Name FROM Marketing_Campaign__c where Re_send_to_Oracle__c=True]);

   global void execute(SchedulableContext sc) {
   
   System.debug('CampaignId :'+mcMap.keySet());
      MarketingCampaignBatchCallout mcbatch = new MarketingCampaignBatchCallout(mcMap.keySet()); 
      database.executebatch(mcbatch);
   }
}