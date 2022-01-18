global class mcUpdatescheduledBatchable implements Schedulable{

   Map<Id, Marketing_Campaign__c> mcMap = new Map<Id, Marketing_Campaign__c>([SELECT Id, Name FROM Marketing_Campaign__c where Re_send_to_Oracle_Update__c=True]);

   global void execute(SchedulableContext sc) {
   
   System.debug('CampaignId :'+mcMap.keySet());
      MarketingCampaignUpdateBatchCallout mcbatch = new MarketingCampaignUpdateBatchCallout(mcMap.keySet()); 
      database.executebatch(mcbatch);
   }
}