/*
*Class: PromotionredemptionTrigger
*purpose: 
*Created by: Ian Womack
*Date: 10/03/2014
*
**/

trigger PromotionredemptionTrigger on Promotion_Redemption__c (before insert) {

 if(Trigger.isInsert)  
    {
     
        PromotionRedemptionTriggerHelper.DeleteExisting(Trigger.new);
    }   
    
}