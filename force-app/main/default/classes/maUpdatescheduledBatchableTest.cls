@isTest
public class maUpdatescheduledBatchableTest {
    public static testmethod void testMarketingActivitySchedule(){
        Test.startTest();
        maUpdatescheduledBatchable sh1 = new maUpdatescheduledBatchable();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Activity Check', sch, sh1); 
        Test.stopTest();
        
    }  
}