@isTest
public class mcUpdatescheduledBatchableTest {
    public static testmethod void testMarketingCampaignUpadteSchedule(){
        Test.startTest();
        mcUpdatescheduledBatchable sh1 = new mcUpdatescheduledBatchable();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test campaign Check', sch, sh1); 
        Test.stopTest();
        
    }  
}