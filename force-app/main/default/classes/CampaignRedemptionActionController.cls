global without sharing class CampaignRedemptionActionController{
    

    public CampaignRedemptionActionController(ApexPages.StandardController controller) {
        
    }
    
 

    // Method called by Submit button to post new Retail LIVE message
    @RemoteAction
    global static string ProcessRedemptions(string codes, id campId) {
       
       //setup and default a return value. This string will be interogated by the JS in the VF page
        string returnValue = 'Success';
       
        try {
                List<promotion_Redemption__c> TORList = New list<promotion_Redemption__c>();
                string badCodes = '';
                list<string> ListVoucherCodesSplit = codes.split(';');
                set<string> SetVoucherCodeSplit = new set<string>();
                SetVoucherCodeSplit.addAll(ListVoucherCodesSplit );
                
                system.debug('list of voucher codes: '+ SetVoucherCodeSplit);
               // system.debug('input String: ' + multiVouchers );
                        
                //loop through the list (VoucherCodesSplit ) and add them to the TORList 
                FOR(string s  :SetVoucherCodeSplit)
                {
                    system.debug('In loop string: ' + s);
                    system.debug('redeemableCampaign.Id: ' + campId);
                        if (string.isnotblank(s) && (s.length() == 14 || s.length() == 16)) //the voucher codes 
                        {
                            TORList.add(New Promotion_Redemption__c(Redeemable_Campaign__c = campId, Redeem_Date__c = system.today() , Voucher_Code__c = s, customer__c = null));
                        }
                        ELSE
                        {
                            badCodes = badCodes + s + ', ';
                        }    
                }//end for loop
                
                IF (badCodes.length() > 0)
                {
                   returnValue = 'Badly formatted codes';  
                }
                else 
                {
                   insert TORList;
                }

                badCodes = '';   
              
        } catch (exception e) {
            returnValue = 'A technical error has occurred .. ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
            return returnValue;
            
        }
        return returnValue; 
    }   

}