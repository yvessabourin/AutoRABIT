@isTest
public class PromotionRedemptionTriggerHelperTest{

//properties
Private Static Campaign multiChannelCampaign = new Campaign(); 
private static string village = 'Test Village'; 
private static village__c testvillage = new village__c();
private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
private static integer countOfPromotions;
 
    
    public static testMethod void duplicateRedemptionTest()
    {
    	setupdata();
        Promotion_Redemption__c  firstPromoRedemption = new Promotion_Redemption__c(
                                                            voucher_code__c = '14xxxxxxxxxxxx',
                                                            redeem_date__c = date.today(),
                                                            Redeemable_Campaign__c = multiChannelCampaign.Id);
        
        Promotion_Redemption__c  secondPromoRedemption = new Promotion_Redemption__c(
                                                            voucher_code__c = '14xxxxxxxxxxxx',
                                                            redeem_date__c = date.today(),
                                                            Redeemable_Campaign__c = multiChannelCampaign.Id);
        test.startTest();
            insert firstPromoRedemption;
            
        	//ensure the insert went in
            countOfPromotions = [SELECT count() FROM Promotion_Redemption__c 
                                 WHERE voucher_code__c = :firstPromoRedemption.voucher_code__c];
            system.assertEquals(1, countOfPromotions);
            
        	//insert a duplicate
        	insert 	secondPromoRedemption;
       		test.stopTest();
        
        	//ensure there is still only one record with the '14xxxxxxxxxxxx' voucher code
            countOfPromotions = [SELECT count() FROM Promotion_Redemption__c 
                                WHERE voucher_code__c = :firstPromoRedemption.voucher_code__c];
            system.assertEquals(1, countOfPromotions);
    }


	static void setupdata()
    {
        //Setup new test Village
        testvillage.Name = village;
        testvillage.Village_Code__c = 'TV';
		testvillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		testvillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert testvillage;
                      
        //new redeemable campaign    
        multiChannelCampaign.Name = 'My Test Group Campaign';
        multiChannelCampaign.Communication_Channel__c = 'Email';
        multiChannelCampaign.Status = 'In Progress' ;
        multiChannelCampaign.isActive = true ;
        multiChannelCampaign.Village__c = testvillage.id;
        multiChannelCampaign.description = 'This is my test campaign';
        multiChannelCampaign.startdate = Date.today();
        multiChannelCampaign.enddate = Date.today()+3;
        multiChannelCampaign.RecordTypeId = RedeemableCampRecordTypeId;
        
        insert multiChannelCampaign;
    }

    
}