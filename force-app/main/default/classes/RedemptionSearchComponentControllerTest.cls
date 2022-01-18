@isTest
private class RedemptionSearchComponentControllerTest {

	private Static Campaign redeemableCampaign = new Campaign(); 
	private static string village = 'Test Village'; 
	private static village__c testvillage = new village__c();
	private static Account TourismAccount = new Account();
	private static User usr = new User(); 
	
	private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
	private static list<Id> fixedSearchResults = new list<Id>();   
    
    public static testMethod void searchCampaign() 
    {
        setupData();
        list<Campaign> campaignList = new list<Campaign>();
           
		test.startTest();
			system.runAs(usr){
				Test.setFixedSearchResults(fixedSearchResults);
				campaignList = RedemptionSearchComponentController.findCampaigns('Test');
			}            
		test.stopTest();
      	
      	system.assertEquals(campaignList.size(), 1);	
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
        
        		// Create test admin user
 		usr = TestData_User.setupAdminUser(false);
 		usr.Village__c = testVillage.Name;
 		insert usr;
 		
        fixedSearchResults.add(redeemableCampaign.Id); 

    }

}