@isTest
public class MarketingCampaignDataReceiveTest {
    static testmethod void mcDataStore(){
        
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
        
        
        Marketing_Campaign__c mcamp = new Marketing_Campaign__c(Name='test shalu camp 242', Short_Description__c='Camp desc test 242', Campaign_Level__c ='Theme', Campaign_Focus__c='Theme',Village__c = vlg.id, Status__c ='To Be Approved', Start_Date__c =Date.newInstance(2019, 12, 9), End_Date__c =Date.newInstance(2020, 12, 9), Responsible__c =u.id, Accountable_Person__c = u.Id, Proposition__c ='test data', Target_Audience__c ='Test Audience', KPI_Targets__c ='test target');
        insert mcamp;  
        
        MarketingCampaignDataReceive.BusinessUnit[] tempBU = new MarketingCampaignDataReceive.BusinessUnit[2]; 
        
        MarketingCampaignDataReceive.BusinessUnit bunit1 = new MarketingCampaignDataReceive.BusinessUnit();
        bunit1.BusinessUnitCode ='US01';
        bunit1.OracleProjectId ='300000026105113';
        bunit1.OracleProjectNumber ='102996';
        
        MarketingCampaignDataReceive.BusinessUnit bunit2 = new MarketingCampaignDataReceive.BusinessUnit();
        bunit2.BusinessUnitCode ='US02';
        bunit2.OracleProjectId ='300000026105114';
        bunit2.OracleProjectNumber ='102997';
        
        tempBU[0] =  bunit1;
        tempBU[1] = bunit2 ;
        
        MarketingCampaignDataReceive.ResponseStatus rsp = new MarketingCampaignDataReceive.ResponseStatus();
        rsp.Code = '0';
        rsp.Message =''; 
        
        MarketingCampaignDataReceive.BusinessUnitWrapper respwrap = new MarketingCampaignDataReceive.BusinessUnitWrapper();
        respwrap.SessionId = '985e0e64-769c-4e1c-ba61-e637251cf16d';
        respwrap.SalesforceId = mcamp.id;
        respwrap.BusinessUnit = tempBU;
        respwrap.ResponseStatus =rsp;
        
      
        Business_Unit__c[] burec = [select Business_Unit_Code__c from Business_Unit__c where Village__r.Name=:vlg.Name];  
      
        System.debug('BusinessUnitCode ***:'+ respwrap.BusinessUnit[0].BusinessUnitCode);
        if(respwrap.BusinessUnit[0].BusinessUnitCode == burec[0].Business_Unit_Code__c ||respwrap.BusinessUnit[1].BusinessUnitCode == burec[1].Business_Unit_Code__c ){
        MarketingCampaignDataReceive.projectDetailsReceivedfromOracle(respwrap);
        }
    } 
 }