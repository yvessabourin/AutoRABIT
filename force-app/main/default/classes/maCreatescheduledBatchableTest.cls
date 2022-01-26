@isTest
public class maCreatescheduledBatchableTest {
    public static testmethod void testMarketingActivitySchedule(){
        Test.startTest();
        maCreatescheduledBatchable sh1 = new maCreatescheduledBatchable();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Activity Check', sch, sh1); 
        Test.stopTest();
        
    }  
}