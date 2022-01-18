@isTest
public class CampaignRedemptionActionController_Test {

 //properties
Private Static Campaign redeemableCampaign = new Campaign(); 
private static string village = 'Test Village'; 
private static village__c testvillage = new village__c();
private static Account TourismAccount = new Account(); 

private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
private static list<Id> fixedSearchResults = new list<Id>();   
    
    public static testMethod void RedeemAgainstCampaign_happypath() 
    {
        setupData();
           
          test.startTest();   
            CampaignRedemptionActionController.ProcessRedemptions('12345678901234;12345678901234hh', redeemableCampaign.id);    
          test.stopTest();
        
        integer countredemptions = [select count() from promotion_redemption__c];   
        system.assertEquals(2,countredemptions);          
    } 
    
        public static testMethod void RedeemAgainstCampaign_badCodes() 
    {
        setupData();
           
          test.startTest();   
            CampaignRedemptionActionController.ProcessRedemptions('BAD;12345678901234hh', redeemableCampaign.id);    
          test.stopTest();
        
        integer countredemptions = [select count() from promotion_redemption__c];   
        system.assertEquals(0,countredemptions);          
    }   
    
    //////////////Data setup//////////////////// 
    static void setupdata()
    {  

        //Setup new test Village
        testvillage.Name = village;
        testvillage.Village_Code__c = 'TV';
		testvillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		testvillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        insert testvillage;
        
        //Setup Partner
       TourismAccount = TestData_Account.setupTourismAccount(1,true);
 
        //new redeemable campaign    
        redeemableCampaign.Name = 'My Test redeemable campaign for ' + village;
        redeemableCampaign.Communication_Channel__c = 'Email';
        redeemableCampaign.Village__c = testvillage.id;
        redeemableCampaign.Partner__c = TourismAccount.id;
        redeemableCampaign.description = 'This is my test campaign';
        redeemableCampaign.startdate = Date.today();
        redeemableCampaign.enddate = Date.today()+3;
        redeemableCampaign.recordtypeid = RedeemableCampRecordTypeId;
        
        insert redeemableCampaign;
        
        fixedSearchResults.add(redeemableCampaign.Id); 

    }
    
    
}