@isTest
public class MAProjectNumberShowHandlerTest{

    static testmethod void maProjectNumberShow(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Village__c vlg = new Village__c(Name='Bicester', Village_Code__c ='BV', CertSales_Report_Sales_Grace_Period_Days__c =1, CertSales_CertPeriod_Cut_Off_Days__c = 1);
        insert vlg;
        Business_Unit__c bunittemp1 = new Business_Unit__c(Name='Value Retail Management (Bicester Village) Ltd', Business_Unit_Code__c ='US01', Village__c =vlg.id, OraclePrimaryBusinessUnit__c = 'True', Oracle_Organization_Name__c ='Local Brand & Communications', Oracle_Source_Template_Number__c ='MKT Campaigns US01');   
        insert bunittemp1; 
        
        Business_Unit__c bunittemp2 = new Business_Unit__c(Name='Value Retail Management (Bicester Village) Ltd1', Business_Unit_Code__c ='US02', Village__c =vlg.id, OraclePrimaryBusinessUnit__c = 'False', Oracle_Organization_Name__c ='Local Brand & Communications1', Oracle_Source_Template_Number__c ='MKT Campaigns US02');   
        insert bunittemp2;
        
        
        Marketing_Campaign__c mcamp = new Marketing_Campaign__c(Name='test shalu camp 242',Oracle_Project_Number__c='102996',Oracle_Secondary_Project_Number__c='102997', Short_Description__c='Camp desc test 242', Campaign_Level__c ='Theme', Campaign_Focus__c='Theme',Village__c = vlg.id, Status__c ='To Be Approved', Start_Date__c =Date.newInstance(2019, 12, 9), End_Date__c =Date.newInstance(2020, 12, 9), Responsible__c =u.id, Accountable_Person__c = u.Id, Proposition__c ='test data', Target_Audience__c ='Test Audience', KPI_Targets__c ='test target');
        insert mcamp;  
        
        Id maRecordTypeId = Schema.SObjectType.Marketing_Activity__c.getRecordTypeInfosByDeveloperName().get('General_Activity').getRecordTypeId();
        
        Marketing_Activity__c mactivity = new Marketing_Activity__c(Name='test shalu activity 22',RecordTypeId =maRecordTypeId, Business_Function__c ='Local Tourism Services', Channel__c ='Media', Sub_Channel__c ='Radio/ Audio Digital', Marketing_Campaign__c =mcamp.Id, Status__c ='To Be Approved', Start_Date__c=Date.newInstance(2019, 12, 9), End_Date__c =Date.newInstance(2020, 12, 9), Region__c ='Europe', Audience_Category__c='Domestic Local', Market__c ='France' ,Objective__c='test Activity', Response_Description__c='test description', Measurement_Description__c='manual description', Communication_Plan__c='test plan', Message__c ='test', Responsible_Person__c =u.id, Accountable1__c=u.Id);
        insert mactivity;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mactivity);
        
        MAProjectNumberShowHandler maProjNum = new MAProjectNumberShowHandler(sc);
        
    }
}