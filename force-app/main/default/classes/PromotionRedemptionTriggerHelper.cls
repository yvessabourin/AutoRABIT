public class PromotionRedemptionTriggerHelper{

    public static void DeleteExisting(List<Promotion_Redemption__c> redemptionsToDelete)
    {
      	system.debug('***what to delete***' + redemptionsToDelete);   
        
        set<string> voucherset =  new set<string>();
        
        FOR(Promotion_Redemption__c cRedemption : redemptionsToDelete )
        {
        	voucherset.add(cRedemption.Voucher_Code__c);
        }
        
        list<Promotion_Redemption__c> RedemptionList = [SELECT id from Promotion_Redemption__c WHERE Voucher_Code__c in :voucherset];    
        
        
        system.debug('DELETING: ' + RedemptionList);  
        delete RedemptionList;
        system.debug('I\'m here!!');   
    }
    
    
}