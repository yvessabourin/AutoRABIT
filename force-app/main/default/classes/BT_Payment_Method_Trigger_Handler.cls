public without sharing class BT_Payment_Method_Trigger_Handler {
    
    /*
     * Method created to delete from Salesforce some key payment method data
     */
    public static void deletePaymentMethodInformation (List <bt_stripe__Payment_Method__c> paymentMethods) {

        if (paymentMethods != null) {
            for (bt_stripe__Payment_Method__c paymentMethod : paymentMethods) {
                PaymentMethod.bt_stripe__Card_Holder_Name__c = null;
                PaymentMethod.bt_stripe__Card_Number__c = null;
                PaymentMethod.bt_stripe__Card_Expiration_Month__c = null;
                PaymentMethod.bt_stripe__Card_Expiration_Year__c = null;
                PaymentMethod.bt_stripe__CVV__c = null;
                PaymentMethod.bt_stripe__Card_Last_4_Digit__c = null;
                PaymentMethod.bt_stripe__Brand__c = null;
                PaymentMethod.bt_stripe__Country_ISO__c = null;
            }              
        }
    }

}