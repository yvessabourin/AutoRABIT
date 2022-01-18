@isTest
Public Class MarketingActivityUtilitiesTest{

    private static Account account = new Account();
    private static Account account2 = new Account();
    public static Marketing_Campaign__c MC = new Marketing_Campaign__c();
    public static Marketing_Activity__c MA = new Marketing_Activity__c();
    public static Associated_Account__c AA = new Associated_Account__c();

    static void setUpData(){
   
    
            // first create a village
        Village__c vill = TestDataGenerator.setupVillage(false);
        vill.Oracle_Source_Template_Number__c = '123456';
        vill.Oracle_Organisation__c = 'SourceOrg';
        vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        vill.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert vill;

        account = TestData_Account.setupBrandAccount(1, true);
        account2 = TestData_Account.setupBrandAccount(2, true);
        Account testAccount = new Account(name = 'Test Account', 
                                          RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId,
                                          Target_markets__c = 'England',
                                          Relevant_villages__c = 'Bicester');
        insert testAccount;
          
        Village_Presence__c VP = new Village_Presence__c();
        VP.Name = 'test';
        VP.Brand__c = account2.id;
        VP.Village__c = vill.id;
        insert VP;

        Map <String,Schema.RecordTypeInfo> recordTypesadjustment = Marketing_Campaign__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id RecTypeIdinadj = recordTypesadjustment.get('Village Campaign').getRecordTypeId();

        MC.Name = 'TestCampaignForTestingSync';
        //MC.Marketing_Campaign_Ref__c = 'MCREF001';
        MC.Short_Description__c = 'TestCampaign Description';
        MC.Start_Date__c = Date.today();
        MC.End_Date__c = Date.today();
        MC.Campaign_Level__c = 'Theme';
        MC.Village__c = vill.Id;
        MC.RecordTypeId = RecTypeIdinadj;

        insert MC;

        // and now insert an activity

     //   id theRecId =  Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('General Activity').RecordTypeId;

        id theRecId =  Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('General_Activity').RecordTypeId;
        MA.Name = 'TestActivity for MAUtilites Test';
        //MA.Marketing_Activity_Ref__c = 'MA Ref';
        MA.recordtypeId = theRecId;
        MA.Start_Date__c = Date.today();
        MC.CurrencyIsoCode = 'EUR';
        MA.End_Date__c = Date.today().adddays(1);
        MA.Status__c = 'Approved';
        MA.Marketing_Campaign__c = MC.ID;
        MA.Partner__c = testAccount.Id;
        insert MA;

        AA.Partner_Brand_Account__c = account.ID;
        AA.Marketing_Activity__c = MA.ID;
        insert AA;

        date activeFromDate = date.newInstance(system.today().year(), 01, 01);
        date activeToDate = date.newInstance(system.today().year(), 12, 31);

        id LeaseLedRecTypeId = Schema.SObjectType.Brand_permission__c.getRecordTypeInfosByName().get('Lease-led Annual').getRecordTypeId();

        Brand_Permission__c bp = new Brand_Permission__c();
        bp.RecordTypeId = LeaseLedRecTypeId;
        bp.active_From_Date__c = activeFromDate;
        bp.active_To_Date__c = activeToDate;
        bp.Village__c = vill.id;
        bp.brand__c = account.id;
        bp.Marketing_Activity__c = MA.id;
        bp.status__c = 'System Generated';
        bp.currency__c = 'GBP';
        insert bp;

        Product_Loan__c pl = new Product_Loan__c();
        pl.Name = 'Test Pl';
        pl.Status__c = 'Request for Collection';
        pl.Collection_Date__c = system.today();
        pl.Reason_For_Loan__c = MA.id;
        pl.Brand__c = account.id;
        pl.Currency__c = 'GBP';
        insert pl;

        brand_Activity__c BA = new brand_Activity__c();
        BA.Name = 'test';
        BA.Brand__c = account .id;
        BA.Brand_Activity_Type__c = 'Product launch';
        BA.Start_Date__c = system.today();
        BA.End_Date__c = system.today() + 360;
        //BA.Status__c = 'Confirmed';
        BA.Status__c = 'Approved';
        insert BA;
        


        In_Village_Brand_Activity__c iv = new In_Village_Brand_Activity__c();
        iv.Name = 'test';
        iv.Marketing_Activity__c = MA.id;
        iv.Start_Date__c = system.today();
        iv.End_Date__c = system.today()+12;
        //iv.Status__c = 'Confirmed';
        iv.Status__c = 'Approved';
        iv.Brand__c = account.id;
        iv.Brand_Activity__c = BA.id;
        iv.Village_Presence__c = VP.id;
        insert iv;
        
        Activity_Budget_Split__c abs = new Activity_Budget_Split__c();
        abs.Marketing_Activity__c = MA.id;
        abs.year__c = String.ValueOf(system.today().year());
        abs.Split_Start_Date__c = system.today();
        abs.Split_End_Date__c = system.today().adddays(1);
        abs.X01_January__c = 12;
        abs.X02_Febraury__c = 12;
        abs.X03_March__c = 12;
        abs.X04_April__c = 12;
        abs.X05_May__c = 12;
        abs.X06_June__c = 12;
        abs.X07_July__c = 12;
        abs.X08_August__c = 12;
        abs.X09_September__c = 12;
        abs.X10_October__c = 12;
        abs.X11_November__c = 12;
        abs.X12_December__c = 12;
        insert abs;
        

        // and now a brand association
    }


    @istest static void test1(){

        setUpData();

        Marketing_Activity__c ma = [SELECT Id,Name, Status__c FROM Marketing_Activity__c WHERE name = 'TestActivity for MAUtilites Test'];

        Test.startTest();
        try{
        ma.Status__c = 'Completed';
        update ma;
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Test.stopTest();

        //system.assertEquals();

    }
    
    
    @istest static void test2(){
    
    setUpData();
    
    Marketing_Activity__c MA = [SELECT id,CurrencyIsoCode,  Name from Marketing_Activity__c WHERE NAME = 'TestActivity for MAUtilites Test'];
    Activity_Budget_Split__c ABS = [SELECT Id,CurrencyIsoCode  from Activity_Budget_Split__c WHERE MArketing_Activity__c =: MA.id];
    
    system.assert(ABS.CurrencyIsoCode == MA.CurrencyIsoCode);
    
    Test.startTest();
        MA.CurrencyIsoCode = 'GBP';
        update MA;
    Test.stopTest();
    
    Marketing_Activity__c MA2 = [SELECT id,CurrencyIsoCode,  Name from Marketing_Activity__c WHERE NAME = 'TestActivity for MAUtilites Test'];
    Activity_Budget_Split__c ABS2 = [SELECT Id,CurrencyIsoCode  from Activity_Budget_Split__c WHERE MArketing_Activity__c =: MA2.id];
    
    system.assert(ABS2.CurrencyIsoCode == MA2.CurrencyIsoCode);
    
    }
}