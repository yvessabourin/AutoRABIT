@isTest(seeAllData=true)
global class  deleteGiftsFromFlowSelectionTest{

  private static Account account = new Account();
  private static Village__c village3 = new Village__c();
  private static Opportunity opp = new Opportunity();

        static void setupData(){
            
            account = TestData_Account.setupBrandAccount(1, true);
                  
             //create village 1
             village3 = new Village__c();
             village3.Name = 'TestVillage3';     
             village3.Village_Code__c = 'AA';
			 village3.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			 village3.CertSales_Report_Sales_Grace_Period_Days__c = 1;
             insert village3;
             village3 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];    
             
                
            
            }


        private static testMethod void doTest() {
        
        setupData();
        
        list <deleteGiftsFromFlowSelection.giftDeleteRequest> listofdgffs = new list<deleteGiftsFromFlowSelection.giftDeleteRequest>();
        
        deleteGiftsFromFlowSelection.giftDeleteRequest dgffs = new deleteGiftsFromFlowSelection.giftDeleteRequest();
                
                opp = new Opportunity(name = 'TestOpp', Village__c = village3.Id, AccountId = account.id, 
                CloseDate = system.today().addDays(1), StageName = 'Pipeline');
                insert opp;     
                
                gift__c gift1 = new gift__c();
                gift1.name = 'test';
                gift1.Gift_Value__c = 40.00;
                gift1.deal__c = opp.id;
                insert gift1;
                
                gift__c gift2 = new gift__c();
                gift2.name = 'test';
                gift2.Gift_Value__c = 40.00;
                gift2.deal__c = opp.id;
                insert gift2;
        
                dgffs.Ids = gift1.id;
                                
                listofdgffs.add(dgffs);

                Test.startTest();
                deleteGiftsFromFlowSelection.deleteGifts(listofdgffs);   
                Test.stopTest();
                
                list<Gift__c> finalgifts = [SELECT id FROM Gift__c WHERE deal__c =:opp.id];
                system.assert(finalgifts.size() == 1);
                
                
        
            }
}