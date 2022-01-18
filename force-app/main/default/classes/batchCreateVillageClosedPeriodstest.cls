@isTest
Public Class batchCreateVillageClosedPeriodstest{


    @isTest static void removeCalled() {

    setupdata1();

    id vilid = [SELECT Id, Name FROM Village__c WHERE NAME = 'Wertheim Village'].id;    

    batchCreateVillageClosedPeriods cnt = new batchCreateVillageClosedPeriods();
    PageReference pageRef = Page.batchCreateVillageClosedPeriods;
    Test.setCurrentPage(pageRef);
    cnt.year = String.Valueof(System.Today().year());
    cnt.vilId = vilid;
    test.startTest();
    cnt.getYearStartDay();
    cnt.selectAll();
    cnt.deselectAll();
    cnt.save();
    test.stopTest();

    system.assert(cnt.cVCPList.size() <= 52 && cnt.cVCPList.size() > 0 , 'there were actually' + cnt.cVCPList.size() + ' records created');

    }



    @isTest static void allRecordsCreated() {

    setupdata1();

    id vilid = [SELECT Id, Name FROM Village__c WHERE NAME = 'Bicester Village'].id;    

    batchCreateVillageClosedPeriods cnt = new batchCreateVillageClosedPeriods();
    PageReference pageRef = Page.batchCreateVillageClosedPeriods;
    Test.setCurrentPage(pageRef);
    cnt.year = String.Valueof(System.Today().addYears(1).year());
    cnt.vilId = vilid;
    test.startTest();
    cnt.getYearStartDay();
    cnt.selectAll();
    cnt.deselectAll();
    cnt.save();
    test.stopTest();

    system.assert(cnt.cVCPList.size() == 52 , 'there were actually' + cnt.cVCPList.size() + ' records created');

    }


    @isTest static void noRecordsCreated() {

    setupdata2();

    id vilid = [SELECT Id, Name FROM Village__c WHERE NAME = 'La Roca village'].id; 

    batchCreateVillageClosedPeriods cnt = new batchCreateVillageClosedPeriods();
    PageReference pageRef = Page.batchCreateVillageClosedPeriods;
    Test.setCurrentPage(pageRef);
    cnt.year = String.Valueof(System.Today().addYears(2).year());
    cnt.vilId = vilid;
    test.startTest();
    cnt.getYearStartDay();
    cnt.selectAll();
    cnt.deselectAll();
    cnt.save();
    test.stopTest();

    system.assert(cnt.cVCPList.size() == 0 , 'there were actually' + cnt.cVCPList.size() + ' records created');

    }


    @isTest static void canceltest() {

    setupdata1();

    id vilid = [SELECT Id, Name FROM Village__c WHERE NAME = 'Bicester Village'].id;    

    batchCreateVillageClosedPeriods cnt = new batchCreateVillageClosedPeriods();
    PageReference pageRef = Page.batchCreateVillageClosedPeriods;
    Test.setCurrentPage(pageRef);
    cnt.year = String.Valueof(System.Today().addYears(1).year());
    cnt.vilId = vilid;
    test.startTest();

    cnt.cancel();
    test.stopTest();

    }

    static void setupdata1(){
   
        list<Village__c> VilsToInsert = new list<Village__c>();

        Village__c Bicestervillage = new Village__c();
        Bicestervillage.Name = 'Bicester Village';     
        Bicestervillage.Village_Code__c = 'BV';
		Bicestervillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		Bicestervillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        VilsToInsert.add(Bicestervillage);

        Village__c Wertheimvillage = new Village__c();
        Wertheimvillage.Name = 'Wertheim Village';     
        Wertheimvillage.Village_Code__c = 'WV';
		Wertheimvillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		Wertheimvillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        VilsToInsert.add(Wertheimvillage);

        insert VilsToInsert;

    }

    static void setupdata2(){

        batchCreateVillageClosedPeriods cont = new batchCreateVillageClosedPeriods();
   
        list<Village__c> VilsToInsert = new list<Village__c>();

        Village__c LaRocavillage = new Village__c();  
        LaRocavillage.Name = 'La Roca village';     
        LaRocavillage.Village_Code__c = 'LR';
		LaRocavillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		LaRocavillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        VilsToInsert.add(LaRocavillage);
        insert VilsToInsert;

        id villid = [SELECT Id, Name FROM Village__c WHERE NAME = 'La Roca village'].id;    

        cont.year = String.Valueof(System.Today().addYears(2).year());
        cont.vilId = villid;
        cont.getYearStartDay();
        cont.selectAll();
        cont.save();

    }




}