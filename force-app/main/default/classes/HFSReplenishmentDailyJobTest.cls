@isTest
public class HFSReplenishmentDailyJobTest {

    static testmethod void testBatchExecution() {
        
        Village__c village = new Village__c();
 		village.Name = 'TestVillage1'; 		
 		village.Village_Code__c = 'AA';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        insert village;
         
        Account brand1 = TestData_Account.setupBrandAccount(1, true);
        Account brand2 = TestData_Account.setupBrandAccount(2, true);

        Village_Presence__c vp1 = new Village_Presence__c (Brand__c = brand1.Id, Village__c = village.Id, HFS_Bags_Used__c = 5, HFS_Bags_Received__c = 15, Is_HFS_Active__c=true);
        Village_Presence__c vp2 = new Village_Presence__c (Brand__c = brand2.Id, Village__c = village.Id, HFS_Bags_Used__c = 2, HFS_Bags_Received__c = 20, Is_HFS_Active__c=true);

        insert new List <Village_Presence__c> {vp1, vp2};

        Map <Id, Decimal> vpMap = new Map <Id, Decimal> {vp1.Id => 10, vp2.Id => 18};
        
        Global_Properties__c gp = new Global_Properties__c (Name='REPLENISHMENT_BAG_JOB_SIZE', Value__c='30');
        insert gp;

        Test.startTest();

        HFSReplenishmentDailyJob scheduler = new HFSReplenishmentDailyJob();
        scheduler.execute(null);

        Test.stopTest();

        for (Village_Presence__c vp : [SELECT Id, HFS_Bags_Used__c, HFS_Bags_Received__c FROM Village_Presence__c]) {
            system.assertEquals(0, vp.HFS_Bags_Used__c);
            system.assertEquals(vpMap.get(vp.Id), vp.HFS_Bags_Received__c);
        }

        
    }

}