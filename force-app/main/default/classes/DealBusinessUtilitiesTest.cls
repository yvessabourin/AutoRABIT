@isTest
private class DealBusinessUtilitiesTest {
    
    static Account testAccount;
    static Village__c testVillage;
    static Opportunity testOpp;
    
    static void setupData(){
        
        testAccount = TestDataGenerator.setupB2BAccount(1, true);
        testVillage = TestDataGenerator.setupVillage(true);

        testOpp = new Opportunity(Village__c = testVillage.Id, AccountId = testAccount.Id,
                                               Name = 'TESTOPP1', CloseDate = system.today(),
                                               StageName = 'Agreed in Principle');
        insert testOpp;
        
    }

    static testMethod void unitTest() {

        setupData();
        
        testOpp.Tier_Level__c = 'Yes- Tier 1';
        testOpp.Tier_Level_Rationale__c = 'All good';
        
        update testOpp;
        
        Deal_Business_History__c history = new Deal_Business_History__c();
        history.Deal__c = testOpp.Id;
        history.Approved_Date__c = system.now().addDays(-3);
        history.Review_Comment__c = 'abc';
        history.Approved_By__c = 'Mr Test';
        
        insert history;
        
        history = [select Id, Approved_Date__c, Tier_Level__c, Tier_Level_Rationale__c from Deal_Business_History__c
                            where Id = :history.Id];
        
        testOpp = [select Id,Approved_Date__c, Tier_Level__c, Tier_Level_Rationale__c from Opportunity 
                        where Id = :testOpp.Id];
        
        // check history tier fields have been populated with values from parent deal
        system.assertEquals(history.Tier_Level__c, testOpp.Tier_Level__c);
        system.assertEquals(history.Tier_Level_Rationale__c, testOpp.Tier_Level_Rationale__c);
        
        // check approval date updated on parent deal record
        system.assertEquals(testOpp.Approved_Date__c, history.Approved_Date__c);
                            
        

    }
}