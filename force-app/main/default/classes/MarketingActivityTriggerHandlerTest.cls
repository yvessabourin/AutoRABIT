@istest
public class MarketingActivityTriggerHandlerTest {

    private static Account account = new Account();
    private static Account account2 = new Account();
    public static Marketing_Campaign__c MC = new Marketing_Campaign__c();
    public static Marketing_Activity__c MA = new Marketing_Activity__c();

    static void setUpData(){
     
        // create a village
        Village__c vill = TestDataGenerator.setupVillage(false);
        vill.Oracle_Source_Template_Number__c = '123456';
        vill.Oracle_Organisation__c = 'SourceOrg';
        vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        vill.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        vill.Name = 'Bicester';
        insert vill;

        account = TestData_Account.setupBrandAccount(1, true);
        account2 = TestData_Account.setupBrandAccount(2, true);
        Account testAccount = new Account(name = 'Test Account', 
                                          RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId,
                                          Target_markets__c = 'England',
                                          Relevant_villages__c = 'Bicester');
        insert testAccount;
          
        Map <String,Schema.RecordTypeInfo> recordTypesadjustment = Marketing_Campaign__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id RecTypeIdinadj = recordTypesadjustment.get('Village Campaign').getRecordTypeId();

        MC.Name = 'TestCampaign';
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
        MA.Name = 'TestActivity';
        MA.recordtypeId = theRecId;
        MA.Start_Date__c = Date.today();
        MA.CurrencyIsoCode = 'EUR';
        MA.End_Date__c = Date.today().adddays(1);
        MA.Status__c = 'Approved';
        MA.Marketing_Campaign__c = MC.ID;
        MA.Partner__c = testAccount.Id;
        MA.Market__c = 'Germany';
        MA.Region__c = 'Europe';
        MA.Audience_Category__c='Domestic Local';
        MA.Channel__c='CRM';
        insert MA;
        
        Marketing_Activity__c ma1 = MA.clone(false, true);
        MA.Name = 'TestActivityClone'; 
        insert ma1;
    }


    @istest static void test1(){

        setUpData();

        Marketing_Activity__c ma = [SELECT Id, Market__c, Name, Domestic__c, Status__c FROM Marketing_Activity__c WHERE name = 'TestActivity' limit 1];

        Test.startTest();
        
        ma.Market__c = 'France';
        update ma;
        

        ma = [SELECT Id, Market__c, Name, Domestic__c, Status__c FROM Marketing_Activity__c WHERE name = 'TestActivity' limit 1];

        System.assertEquals(ma.Domestic__c, false);

        Test.stopTest();

    }
    
    
    @istest static void test2(){
    
        setUpData();

        Marketing_Activity__c ma = [SELECT Id, Market__c, Name, Domestic__c, Status__c FROM Marketing_Activity__c WHERE name = 'TestActivity' limit 1];

        Test.startTest();
        
        ma.Market__c = 'United Kingdom';
        update ma;

        ma = [SELECT Id, Market__c, Name, Domestic__c, Status__c FROM Marketing_Activity__c WHERE name = 'TestActivity' limit 1];
       
        System.assertEquals(ma.Domestic__c, true);

        Test.stopTest();
    
    }
    
    
}