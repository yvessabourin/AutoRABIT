@isTest (seeAllData=true)
private class calculateRatingsForVillageButtonFlowTest {
    static testMethod void testRatingUpdate() {
        
        Account testAccount = TestDataGenerator.setupB2BAccount(1, true);
        Village__c ratedVillage = TestDataGenerator.setupVillage(true);
        Village__c unratedVillage = TestDataGenerator.setupVillage(false);
        unratedVillage.Village_Code__c = 'ZY';
        unratedVillage.Name = 'UNRATEDVILLAGE';
        
        Village__c villageIn = TestDataGenerator.setupVillage(false);
        villageIn.Village_Code__c = 'AB';
        villageIn.Name = 'TESTUNIT';
        List<Village__c> listvilla = new List<Village__c> {unratedVillage, villageIn};
            
            insert listvilla;
        
        list<Id> testId = new List<Id>();
        testId.add(listvilla[0].id);
     
        test.startTest();
         calculateRatingsForVillageButtonFlow.calculateRatingsForVillage(testId);   
        test.stopTest();
              
    }
}