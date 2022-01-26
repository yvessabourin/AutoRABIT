@isTest
public class AdbuilderTriggerHandlerTest {
    
    public static Marketing_Activity__c MACtivity = new Marketing_Activity__c();
    public static Marketing_Campaign__c MCampaign = new Marketing_Campaign__c();
    
    @testSetup
    static void setUpData(){
        
        Village__c village = TestDataGenerator.setupVillage(false);
        village.Oracle_Source_Template_Number__c = '123456598';
        village.Oracle_Organisation__c = 'SourceOrg';
        village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert village;
        
        Map <String,Schema.RecordTypeInfo> recordTypesadjustment = Marketing_Campaign__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id RecTypeIdinadj = recordTypesadjustment.get('Village Campaign').getRecordTypeId();
        
        MCampaign.Name = 'Test Campaign';
        MCampaign.Short_Description__c = 'TestCampaign Description';
        MCampaign.Start_Date__c = Date.today();
        MCampaign.End_Date__c = Date.today();
        MCampaign.Campaign_Level__c = 'Theme';
        MCampaign.Village__c = village.Id;
        MCampaign.RecordTypeId = RecTypeIdinadj;
        
        insert MCampaign;
        
        Account AccountTest = new Account(name = 'Test Account2', 
                                          RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId,
                                          Target_markets__c = 'England',
                                          Relevant_villages__c ='Bicester');
        
        
        insert AccountTest;
        
    //    Id  theRecId =  Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('General Activity').RecordTypeId;
       	Id  theRecId =  Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('General_Activity').RecordTypeId; 
        MACtivity.Name = 'Test MACtivity';
        MACtivity.recordtypeId = theRecId;
        MACtivity.Start_Date__c = Date.today();
        MACtivity.CurrencyIsoCode = 'EUR';
        MACtivity.End_Date__c = Date.today();
        MACtivity.Marketing_Campaign__c = MCampaign.ID;
        MACtivity.Partner__c = AccountTest.Id;
        insert MACtivity;
        
    }
    
    @isTest
    static  void AdbuilderInsertTest(){
        
        List<Marketing_Activity__c> mActList = [SELECT Id, Name FROM Marketing_Activity__c Limit 1];
        List<Adbuilder__c> add = [SELECT Id, Marketing_Activity__c from Adbuilder__c  where Marketing_Activity__c =:mActList[0].Id limit 1 ];
        
        Test.startTest();
        AdbuilderTriggerHandler.AdbuilderInsert(add);
        // Adbuilder__c AdBuilder = new  Adbuilder__c(Marketing_Activity__c = mActList[0].Id);
        Test.stopTest();
        
    }
    
    @isTest
    static  void AdbuilderUpdateTest(){
        
        List<Marketing_Campaign__c> vpList = [SELECT Id FROM Marketing_Campaign__c];
        
        
        List<Marketing_Activity__c> mActList = [SELECT Id FROM Marketing_Activity__c Limit 1];
        
        Adbuilder__c add = new Adbuilder__c(Marketing_Campaign__c = vpList.get(0).Id, Marketing_Activity__c = mActList.get(0).Id);
        INSERT add;
        
        Map<Id, Adbuilder__c> parameter = new Map<Id, Adbuilder__c>{add.Id => add};
            
            Test.startTest();
        AdbuilderTriggerHandler.dbuilderBeforeInsert(parameter, parameter);
        Test.stopTest();
    }
 
    @isTest
    static  void getMarketingCampaTest(){
 
        List<Marketing_Campaign__c> vpList = [SELECT Id FROM Marketing_Campaign__c];
     
        List<Marketing_Activity__c> mActList = [SELECT Id FROM Marketing_Activity__c Limit 1];
        
        Adbuilder__c add = new Adbuilder__c(Marketing_Campaign__c = vpList.get(0).Id, Marketing_Activity__c = mActList.get(0).Id);
        INSERT add;
        
        Map<Id, Adbuilder__c> parameter = new Map<Id, Adbuilder__c>{add.Id => add};
            
            Test.startTest();
        AdbuilderTriggerHandler.getMarketingCampa(new List<Adbuilder__c>{add});
        
        Test.stopTest();
    }
    
    
}