@isTest
public class marketingCampaignscheduledBatchableTest {
    public static testmethod void testMarketingCampaignSchedule(){
        Test.startTest();
        marketingCampaignscheduledBatchable sh1 = new marketingCampaignscheduledBatchable();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test campaign Check', sch, sh1); 
        Test.stopTest();
        
    }  
    
}