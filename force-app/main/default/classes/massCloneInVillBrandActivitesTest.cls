@isTest
private class massCloneInVillBrandActivitesTest{

  Public Static List<In_Village_Brand_Activity__c> thebrandActs = new List<In_Village_Brand_Activity__c>();
  Public Static List<In_Village_Brand_Activity__c> thebrandActs2 = new List<In_Village_Brand_Activity__c>();
  Public Static Account testAccount;
  Public Static Account testAccount2;


  static void setupData(){

    testAccount = TestData_Account.setupBrandAccount(1, true);  

    Brand_Activity__c ba1 = new Brand_Activity__c();
    ba1.name = 'test brand act 1 test';
    ba1.brand__c = testAccount.id;
    ba1.Brand_Activity_Type__c = 'Offer';
    ba1.Start_Date__c = system.today();
    ba1.End_Date__c = system.today() + 20;
    //ba1.Status__c = 'To Be Confirmed';
    ba1.Status__c = 'To Be Approved';
    insert ba1;

    In_Village_Brand_Activity__c iv = new In_Village_Brand_Activity__c();
    iv.name = 'In Village Test 1';
    iv.Brand_Activity__c = ba1.id;
    iv.Start_Date__c = system.today();
    iv.End_Date__c = system.today() + 30;
    //iv.Status__c = 'To Be Confirmed';
    iv.Status__c = 'To Be Approved';
    insert iv;
    thebrandActs.add(iv);

  }
 

  @isTest static void test_method_one() {

    setupData();

      ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(thebrandActs);
      massCloneInVillageBrandActivities setcon = new massCloneInVillageBrandActivities(StdSetCon);

      In_Village_Brand_Activity__c ba = [SELECT id, Name FROM In_Village_Brand_Activity__c where name = 'In Village Test 1'];

      PageReference pageRef = Page.massCloneBrandActivities;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', ba.id);

      test.startTest();
      setcon.brandActs = thebrandActs;
      setcon.cloneInVillageBrandActs();
      setcon.returl = ApexPages.currentPage().getParameters().put('id', ba.id);
      setcon.returntoOrigin();
      test.stopTest();

      Brand_Activity__c brandAct = [SELECT id, name FROM Brand_Activity__c WHERE name = 'test brand act 1 test'];
      list<In_Village_Brand_Activity__c> BAs = [SELECT id, name FROM In_Village_Brand_Activity__c WHERE Brand_Activity__c =: brandAct.id];
      system.debug('BAs size' + BAs.Size());
      system.assert(BAs.size() == 2);

  }



  static void setupData2(){

    testAccount2 = TestData_Account.setupBrandAccount(1, true);  

    Brand_Activity__c ba2 = new Brand_Activity__c();
    ba2.name = 'test brand act 2 test';
    ba2.brand__c = testAccount2.id;
    ba2.Brand_Activity_Type__c = 'Offer';
    ba2.Start_Date__c = system.today();
    ba2.End_Date__c = system.today() + 20;
    //ba2.Status__c = 'To Be Confirmed';
    ba2.Status__c = 'To Be Approved';
    insert ba2;

    integer i = 1;
    WHILE(i <= 10){
    In_Village_Brand_Activity__c iv = new In_Village_Brand_Activity__c();
    iv.name = 'In Village Test - ' + i;
    iv.Brand_Activity__c = ba2.id;
    iv.Start_Date__c = system.today();
    iv.End_Date__c = system.today() + 30;
    //iv.Status__c = 'To Be Confirmed';
    iv.Status__c = 'To Be Approved';
    thebrandActs2.add(iv);
    i++;
    }
    insert thebrandActs2;

  }

  @isTest static void test_method_two() {

    setupData2();

      ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(thebrandActs);
      massCloneInVillageBrandActivities setcon = new massCloneInVillageBrandActivities(StdSetCon);

      In_Village_Brand_Activity__c ba = [SELECT id, Name FROM In_Village_Brand_Activity__c where name = 'In Village Test - 1'];

      PageReference pageRef = Page.massCloneBrandActivities;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', ba.id);

      test.startTest();
      setcon.brandActs = thebrandActs;
      setcon.cloneInVillageBrandActs();
      setcon.returl = ApexPages.currentPage().getParameters().put('id', ba.id);
      setcon.returntoOrigin();
      test.stopTest();

      Brand_Activity__c brandAct = [SELECT id, name FROM Brand_Activity__c WHERE name = 'test brand act 2 test'];
      list<In_Village_Brand_Activity__c> BAs = [SELECT id, name FROM In_Village_Brand_Activity__c WHERE Brand_Activity__c =: brandAct.id];
      system.debug('BAs size' + BAs.Size());
      system.assert(BAs.size() ==10);

  }

  



  

  

}