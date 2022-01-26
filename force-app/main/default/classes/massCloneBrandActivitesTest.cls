@isTest
private class massCloneBrandActivitesTest{

    Public Static List<Brand_Activity__c> thebrandActs = new List<Brand_Activity__c>();
    Public Static List<Brand_Activity__c> thebrandActs2 = new List<Brand_Activity__c>();
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
        thebrandActs.add(ba1);

    }

    

    @isTest static void test_method_one() {

        setupData();

        ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(thebrandActs);
        massCloneBrandActivities setcon = new massCloneBrandActivities(StdSetCon);

        Brand_Activity__c ba = [SELECT id, Name FROM Brand_Activity__c where name = 'test brand act 1 test'];

        PageReference pageRef = Page.massCloneBrandActivities;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', ba.id);

        test.startTest();
        setcon.brandActs = thebrandActs;
        setcon.cloneBrandActs();
        setcon.returl = ApexPages.currentPage().getParameters().put('id', ba.id);
        setcon.returntoOrigin();
        test.stopTest();

        list<Brand_Activity__c> BAs = [SELECT id, name FROM Brand_Activity__c WHERE brand__c =: testAccount.id];
        system.debug('BAs size' + BAs.Size());
        system.assert(BAs.size() == 2);
    }



    static void setupData2(){

        testAccount2 = TestData_Account.setupBrandAccount(1, true);  


        integer i = 1;
        WHILE(i <= 10){

        Brand_Activity__c ba = new Brand_Activity__c();
        ba.name = 'test brand act ' + i + ' test';
        ba.brand__c = testAccount2.id;
        ba.Brand_Activity_Type__c = 'Offer';
        ba.Start_Date__c = system.today();
        ba.End_Date__c = system.today() + 20;
        //ba.Status__c = 'To Be Confirmed';
        ba.Status__c = 'To Be Approved';
        thebrandActs2.add(ba);
        i++;

        }
        insert thebrandActs2;

    }

    @isTest static void test_method_two() {

        setupData2();

        ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(thebrandActs);
        massCloneBrandActivities setcon = new massCloneBrandActivities(StdSetCon);

        Brand_Activity__c ba = [SELECT id, Name FROM Brand_Activity__c where name LIKE 'test brand act 1 test'];

        PageReference pageRef = Page.massCloneBrandActivities;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', ba.id);

        test.startTest();
        setcon.brandActs = thebrandActs2;
        setcon.cloneBrandActs();
        setcon.returl = ApexPages.currentPage().getParameters().put('id', ba.id);
        setcon.returntoOrigin();
        test.stopTest();

        list<Brand_Activity__c> BAs2 = [SELECT id, name FROM Brand_Activity__c WHERE brand__c =: testAccount2.id];
        system.debug('BAs2 size' + BAs2.Size());
        system.assert(BAs2.size() == 10);

    }

}