@isTest
private class addtoInitiativiesControllertest {

    public static Account account = new Account();
  private static Account account2 = new Account();
  private static Village_Presence__c vp = new Village_Presence__c();
  private static Village__c village = new Village__c();
  public static Opportunity firstOpp = new Opportunity();
  public static Opportunity secondOpp = new Opportunity();
  public static List<Opportunity> oppsList = new List<Opportunity>();

  static void setupData(){
        
        account = TestData_Account.setupBrandAccount(1, true);
                  
             //create village 1
             
             village.Name = 'TestVillage1';     
             village.Village_Code__c = 'AA';
			 village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			 village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
             insert village;
             village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];  
                            
            }

 
    
    @isTest static void addtoInitiativiesPasstest() {

      setupData();
        
      Initiative__c init = new Initiative__c();
        init.name = 'test2';
        init.Strategy__c = 'test strategy';
        insert init;
        
      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      firstopp.name = 'test1';
      firstOpp.RecordTypeid = oppNBrtid[0].id;
      firstopp.village__c = village.id;
      firstOpp.AccountId = account.id;
      firstopp.closedate = system.today();
      firstOpp.StageName = 'Pipeline';
      oppsList.add(firstOpp);

      secondOpp.name = 'test2';
      secondOpp.RecordTypeid = oppNBrtid[1].id;
      secondOpp.village__c = village.id;
      secondOpp.AccountId = account.id;
      secondOpp.closedate = system.today();
      secondOpp.StageName = 'Pipeline';
      oppsList.add(secondOpp);

      insert oppsList;
        
      Initiative_Member__c initiativeMember = new  Initiative_Member__c();
      initiativeMember.Initiative__c = init.id;
      initiativeMember.Opportunity__c = firstOpp.id;
      insert initiativeMember;

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoInitiativiesController sscontroller = new addtoInitiativiesController(stdSetController);
      stdSetController.setSelected(oppsList);
      sscontroller.deals = oppsList;
      sscontroller.initMem = initiativeMember; 
      sscontroller.save();
      test.stopTest();
      
      List<Initiative_Member__c> testList = [SELECT Id from Initiative_Member__c WHERE Initiative__c =: init.id ];
      system.assert(testList.size() == 2);
    }
    
    
    @isTest static void addtoInitiativiesErrortest() {

      setupData();
        
      Initiative__c init = new Initiative__c();
        init.name = 'test2';
        init.Strategy__c = 'test strategy';
        insert init;
        
      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      firstopp.name = 'test1';
      firstOpp.RecordTypeid = oppNBrtid[0].id;
      firstopp.village__c = village.id;
      firstOpp.AccountId = account.id;
      firstopp.closedate = system.today();
      firstOpp.StageName = 'Pipeline';
      oppsList.add(firstOpp);

      secondOpp.name = 'test2';
      secondOpp.RecordTypeid = oppNBrtid[1].id;
      secondOpp.village__c = village.id;
      secondOpp.AccountId = account.id;
      secondOpp.closedate = system.today();
      secondOpp.StageName = 'Pipeline';
      oppsList.add(secondOpp);

      insert oppsList;
        
      Initiative_Member__c initiativeMember = new  Initiative_Member__c();
      initiativeMember.Initiative__c = init.id;
      initiativeMember.Opportunity__c = firstOpp.id;
      insert initiativeMember;

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoInitiativiesController sscontroller = new addtoInitiativiesController(stdSetController);
      stdSetController.setSelected(oppsList);
      sscontroller.deals = oppsList;
      //sscontroller.initMem = initiativeMember; 
      sscontroller.save();
      test.stopTest();
      
      List<Initiative_Member__c> testList = [SELECT Id from Initiative_Member__c WHERE Initiative__c =: init.id ];
      system.assert(testList.size() == 1);
      
    }
    



    
}