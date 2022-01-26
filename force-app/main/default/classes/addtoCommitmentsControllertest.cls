@isTest
private class addtoCommitmentsControllertest {

  public static Account account = new Account();
  private static Account account2 = new Account();
  private static Village_Presence__c vp = new Village_Presence__c();
  private static Village__c village = new Village__c();
  public static Opportunity firstOpp = new Opportunity();
  public static Opportunity secondOpp = new Opportunity();
  public static Opportunity thirdOpp = new Opportunity();
  public static Opportunity forthOpp = new Opportunity();
  public static Opportunity fifthOpp = new Opportunity();
  public static Opportunity sixthOpp = new Opportunity();
  public static Opportunity seventhOpp = new Opportunity();
  public static Opportunity eigthOpp = new Opportunity();
  public static Opportunity ninthOpp = new Opportunity();
  public static Opportunity tenthOpp = new Opportunity();
  public static List<Opportunity> oppsList = new List<Opportunity>();
  public static List<Opportunity> oppsList2 = new List<Opportunity>();
  public static List<Opportunity> oppsList3 = new List<Opportunity>();
  public static List<Opportunity> dealList1 = new List<Opportunity>();
  //public static List<Opportunity> dealList1 = new List<Opportunity>();
  public static Commitment_Letter__c comit = new Commitment_Letter__c();


  static void setupData(){
        
        account = TestData_Account.setupBrandAccount(1, true);
                  
             //create village 1
             
             village.Name = 'TestVillage1';     
             village.Village_Code__c = 'AA';
			 village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			 village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
             insert village;
             village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];  
             
             vp = VillagePresenceUtilities.createVillagePresence(account.Id, village.Name);
             
             comit.Active__c = TRUE;
             comit.Brand__c = account.id;
             insert comit;
             
              list<CreateCommitmentURLs__c > ccs = new list<CreateCommitmentURLs__c >();
      
              CreateCommitmentURLs__c cc = new CreateCommitmentURLs__c();
              cc.name = 'https://valueretail--vr1uat';
              cc.value__c = 'https://valueretail--vr1uat.cs83.my.salesforce.com/a2J/e?CF00N4E000000SeZ0_lkid=001b000000XbKzC&retURL=%2F001b000000XbKzC';
              ccs.add(cc);
              
              CreateCommitmentURLs__c cc1 = new CreateCommitmentURLs__c();
              cc1.name = 'https://valueretail--vrdev2';
              cc1.value__c = 'https://valueretail--vrdev2.cs88.my.salesforce.com/a2P/e?CF00N9E000001QZ85_lkid=0019E00000QouhG&retURL=%2F0019E00000QouhG';
              ccs.add(cc1); 
              
              CreateCommitmentURLs__c cc2 = new CreateCommitmentURLs__c();
              cc2.name = 'https://valueretail.my.salesforce.com';
              cc2.value__c = 'https://valueretail.my.salesforce.com/a2K/e?CF00Nb000000A5tBB_lkid=001b000000XbMjq&retURL=%2F001b000000XbMjq';
              ccs.add(cc2);
              
              insert ccs;
                            
            }

 
    
    @isTest static void addtoCommitmentPasstest() {

      setupData();
        
        
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

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
      stdSetController.setSelected(oppsList);
      sscontroller.opp.Commitment_Letter__c = comit.id;
      sscontroller.save();
      test.stopTest();
      
      List<Opportunity> testList = [SELECT id, name FROM Opportunity WHERE Commitment_Letter__c =: comit.name];
      system.assert(testList.size() == 2);
    }



    @isTest static void addtoCommitmentDupetest() {

      setupData();
        
      Commitment_Letter__c comit2 = new Commitment_Letter__c();
        comit2.Active__c = TRUE;
        comit2.Brand__c = account.id;
        insert comit2;
        
      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      thirdOpp.name = 'test3';
      thirdOpp.RecordTypeid = oppNBrtid[0].id;
      thirdOpp.village__c = village.id;
      thirdOpp.AccountId = account.id;
      thirdOpp.closedate = system.today();
      thirdOpp.StageName = 'Pipeline';
      thirdOpp.Commitment_Letter__c = comit2.name;
      oppsList2.add(thirdOpp);

      forthOpp.name = 'test4';
      forthOpp.RecordTypeid = oppNBrtid[1].id;
      forthOpp.village__c = village.id;
      forthOpp.AccountId = account.id;
      forthOpp.closedate = system.today();
      forthOpp.Commitment_Letter__c = comit2.name;
      forthOpp.StageName = 'Pipeline';
      oppsList2.add(forthOpp);

      fifthOpp.name = 'test5';
      fifthOpp.RecordTypeid = oppNBrtid[1].id;
      fifthOpp.village__c = village.id;
      fifthOpp.AccountId = account.id;
      fifthOpp.closedate = system.today();
      fifthOpp.Commitment_Letter__c = null;
      fifthOpp.StageName = 'Pipeline';
      oppsList2.add(fifthOpp);

      insert oppsList2;

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList2);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
      stdSetController.setSelected(oppsList2);
      //sscontroller.deals = oppsList2;
      sscontroller.opp.Commitment_Letter__c = comit2.id;
      sscontroller.save();
      test.stopTest();
      
      List<Opportunity> testList = [SELECT id, name FROM Opportunity WHERE Commitment_Letter__c =: comit2.name];
      system.debug('testlist size '+testList.size());
      system.assert(testList.size() == 3);
    }


    @isTest static void addtoCommitmentDupetest2() {

      setupData();
        
      Commitment_Letter__c comit3 = new Commitment_Letter__c();
        comit3.Active__c = TRUE;
        comit3.Brand__c = account.id;
        insert comit3;
        
      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      sixthOpp.name = 'test6';
      sixthOpp.RecordTypeid = oppNBrtid[0].id;
      sixthOpp.village__c = village.id;
      sixthOpp.AccountId = account.id;
      sixthOpp.closedate = system.today();
      sixthOpp.StageName = 'Pipeline';
      sixthOpp.Commitment_Letter__c = comit3.name;
      oppsList3.add(sixthOpp);

      seventhOpp.name = 'test7';
      seventhOpp.RecordTypeid = oppNBrtid[1].id;
      seventhOpp.village__c = village.id;
      seventhOpp.AccountId = account.id;
      seventhOpp.closedate = system.today();
      seventhOpp.Commitment_Letter__c = comit3.name;
      seventhOpp.StageName = 'Pipeline';
      oppsList3.add(seventhOpp);

      eigthOpp.name = 'test8';
      eigthOpp.RecordTypeid = oppNBrtid[1].id;
      eigthOpp.village__c = village.id;
      eigthOpp.AccountId = account.id;
      eigthOpp.closedate = system.today();
      eigthOpp.Commitment_Letter__c = null;
      eigthOpp.StageName = 'Pipeline';
      oppsList3.add(eigthOpp);

      insert oppsList3;

      list<Opportunity> selected = [SELECT id,name,Commitment_Letter__c FROM Opportunity WHERE (id =:sixthOpp.id OR id =:seventhOpp.id) ];
      system.debug('selected size '+ selected);
      list<Opportunity> dealtoadd = [SELECT id,name,Commitment_Letter__c FROM Opportunity WHERE id =:eigthOpp.id  ];
      system.debug('dealtoadd size '+ dealtoadd);

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList3);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
     // stdSetController.setSelected(dealtoadd);
      sscontroller.deals = dealtoadd;
      sscontroller.opp.Commitment_Letter__c = comit3.name;
      sscontroller.save();
      test.stopTest();
      
      List<Opportunity> testList = [SELECT id, name FROM Opportunity WHERE Commitment_Letter__c =: comit3.name];
      system.debug('testlist size '+testList.size());
      //system.assert(testList.size() == 1);
      system.assertEquals(1, sscontroller.dupeCountList.size() , 'not 1');
    }

    @isTest static void CreateNewCommitment() {

      setupData();

      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      ninthOpp.name = 'test9';
      ninthOpp.RecordTypeid = oppNBrtid[1].id;
      ninthOpp.village__c = village.id;
      ninthOpp.AccountId = account.id;
      ninthOpp.closedate = system.today();
      ninthOpp.Commitment_Letter__c = null;
      ninthOpp.StageName = 'Pipeline';
      oppsList.add(ninthOpp);

      insert oppsList;

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
      PageReference pageRef = Page.AddtoCommitments;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('retURL', 'https://valueretail--vrdev2.cs88.my.salesforce.com/006/o');
      sscontroller.CreateNewCommitment();
      test.stopTest();

    }

    @isTest static void Cancel() {

      setupData();

      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      tenthOpp.name = 'test10';
      tenthOpp.RecordTypeid = oppNBrtid[1].id;
      tenthOpp.village__c = village.id;
      tenthOpp.AccountId = account.id;
      tenthOpp.closedate = system.today();
      tenthOpp.Commitment_Letter__c = null;
      tenthOpp.StageName = 'Pipeline';
      oppsList.add(tenthOpp);

      insert oppsList;

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
      PageReference pageRef = Page.AddtoCommitments;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('retURL', 'https://valueretail--vrdev2.cs88.my.salesforce.com/006/o');

      sscontroller.Cancel();
      test.stopTest();

    }
    
     @isTest static void redirectToVPtest() {

      setupData();

      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];

      tenthOpp.name = 'test10';
      tenthOpp.RecordTypeid = oppNBrtid[1].id;
      tenthOpp.village__c = village.id;
      tenthOpp.AccountId = account.id;
      tenthOpp.closedate = system.today();
      tenthOpp.Village_Presence__c = vp.id;
      tenthOpp.Commitment_Letter__c = null;
      tenthOpp.StageName = 'Pipeline';
      oppsList.add(tenthOpp);

      insert oppsList;

      test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
      PageReference pageRef = Page.AddtoCommitments;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('retURL', 'https://valueretail--vrdev2.cs88.my.salesforce.com/006/o');
      sscontroller.oppVP = tenthOpp;
      sscontroller.redirectToVP();
      test.stopTest();

    }
    
     @isTest static void addDealtoCommitment() {
     
     setupData();
     
     Commitment_Letter__c comit3 = new Commitment_Letter__c();
        comit3.Active__c = TRUE;
        comit3.Brand__c = account.id;
        insert comit3;
     
      LIST<recordtype> oppNBrtid = [SELECT id from Recordtype WHERE SobjectType = 'Opportunity' AND (Name = 'New Brand' OR Name = 'Exit')];    
      List<opportunity> theOppslist = new list<Opportunity>();
      
      Opportunity thisOpp2 = new Opportunity();
      thisOpp2.name = 'test11';
      thisOpp2.RecordTypeid = oppNBrtid[1].id;
      thisOpp2.village__c = village.id;
      thisOpp2.AccountId = account.id;
      thisOpp2.closedate = system.today();
      thisOpp2.Village_Presence__c = vp.id;
      thisOpp2.Commitment_Letter__c = null;
      thisOpp2.StageName = 'Pipeline';
      insert thisOpp2;
      
      Opportunity thisOpp = new Opportunity();
      thisOpp.name = 'test11';
      thisOpp.RecordTypeid = oppNBrtid[1].id;
      thisOpp.village__c = village.id;
      thisOpp.AccountId = account.id;
      thisOpp.closedate = system.today();
      thisOpp.Village_Presence__c = vp.id;
      thisOpp.Village_Chain_Deal_Link__c = thisOpp2.id;
      thisOpp.Commitment_Letter__c = null;
      thisOpp.StageName = 'Pipeline';
      theOppslist.add(thisOpp);

      insert theOppslist;
     
      Test.startTest();
      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppsList);
      addtoCommitmentsController sscontroller = new addtoCommitmentsController(stdSetController);
      PageReference pageRef = Page.AddExistingDeal;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('retURL', 'https://valueretail--vrdev2.cs88.my.salesforce.com/006/o');
      sscontroller.commitmentOpp = thisOpp;
      sscontroller.commitrecordId = comit3.id;
      sscontroller.returlcommit = comit3.id;
      system.debug('sscontroller.commitmentOpp === '+sscontroller.commitmentOpp);
      sscontroller.addDealtoCommitment();
      test.stopTest();
      
      Opportunity Opp = [SELECT Id, Name,Commitment_Letter__c FROM Opportunity WHERE id =:thisOpp2.id LIMIT 1];
      system.assert(Opp.Commitment_Letter__c == comit3.id );
     
     }

    
}