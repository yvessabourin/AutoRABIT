/*
 * Test class for the BT_Payment_Method_Triggler_Handler class and also the BT_Payment_Method_Trigger apex Trigger
 */

@isTest
public class BT_Payment_Method_Trigger_Handler_Test {

    static testmethod void fieldDeletionTest () {

        bt_stripe__Payment_Method__c paymentMethod1 = new bt_stripe__Payment_Method__c (
            bt_stripe__Card_Holder_Name__c = 'GEORGE ORWELL',
            bt_stripe__Card_Number__c = '54123 564 65464 646',
            bt_stripe__Card_Expiration_Month__c = '12',
            bt_stripe__Card_Expiration_Year__c = '2032',
            bt_stripe__CVV__c = '245',
            bt_stripe__Card_Last_4_Digit__c = '2541',
            bt_stripe__Brand__c = 'Visa',
            bt_stripe__Country_ISO__c = 'UK',
            bt_stripe__Billing_Postal_Code__c = '46411',
            bt_stripe__Funding__c = 'Credit',
            bt_stripe__Send_to_Gateway__c = false
        );
        bt_stripe__Payment_Method__c paymentMethod2 = new bt_stripe__Payment_Method__c (
            bt_stripe__Card_Holder_Name__c = 'ROBERTSON DAVIES',
            bt_stripe__Card_Number__c = '2512 56165 141 5',
            bt_stripe__Card_Expiration_Month__c = '01',
            bt_stripe__Card_Expiration_Year__c = '2033',
            bt_stripe__CVV__c = '245',
            bt_stripe__Card_Last_4_Digit__c = '2541',
            bt_stripe__Brand__c = 'MasterCard',
            bt_stripe__Country_ISO__c = 'CA',
            bt_stripe__Billing_Postal_Code__c = '46411',
            bt_stripe__Funding__c = 'Debit',
            bt_stripe__Send_to_Gateway__c = false
        );

        Test.startTest();
        
        //Test Insert trigger
        
        insert new List <bt_stripe__Payment_Method__c> {paymentMethod1, paymentMethod2};


        List <bt_stripe__Payment_Method__c> paymentMethodsAfterInsert = [SELECT Id, bt_stripe__Card_Holder_Name__c, bt_stripe__Card_Number__c,
                        bt_stripe__Card_Expiration_Month__c, bt_stripe__Card_Expiration_Year__c, bt_stripe__CVV__c, bt_stripe__Card_Last_4_Digit__c,
                        bt_stripe__Brand__c, bt_stripe__Country_ISO__c, bt_stripe__Billing_Postal_Code__c, bt_stripe__Funding__c
                        FROM bt_stripe__Payment_Method__c];

        for (bt_stripe__Payment_Method__c paymentMethod : paymentMethodsAfterInsert) {
            Map <String, Object> objectAsMap = paymentMethod.getPopulatedFieldsAsMap();
            for (String objectField : objectAsMap.keySet()) {
                if (objectField == 'bt_stripe__Billing_Postal_Code__c' || objectField == 'bt_stripe__Funding__c' || objectField == 'Id') {
                    system.assert(objectAsMap.get(objectField) != null);
                } else {
                    system.assertEquals(null, objectAsMap.get(objectField));
                }
            }
        }

        //Test for update

        //We use the fact that the paymentMethod1 variable has already an Id after inserting but, because its the variable
        //that we have used initially, it retains the values initially set but with an Id, so we can use this to test for an update
        
        update paymentMethod1;

        List <bt_stripe__Payment_Method__c> paymentMethodsAfterUpdate = [SELECT Id, bt_stripe__Card_Holder_Name__c, bt_stripe__Card_Number__c,
                        bt_stripe__Card_Expiration_Month__c, bt_stripe__Card_Expiration_Year__c, bt_stripe__CVV__c, bt_stripe__Card_Last_4_Digit__c,
                        bt_stripe__Brand__c, bt_stripe__Country_ISO__c, bt_stripe__Billing_Postal_Code__c, bt_stripe__Funding__c
                        FROM bt_stripe__Payment_Method__c];

        for (bt_stripe__Payment_Method__c paymentMethod : paymentMethodsAfterUpdate) {
            Map <String, Object> objectAsMap = paymentMethod.getPopulatedFieldsAsMap();
            for (String objectField : objectAsMap.keySet()) {
                if (objectField == 'bt_stripe__Billing_Postal_Code__c' || objectField == 'bt_stripe__Funding__c' || objectField == 'Id') {
                    system.assert(objectAsMap.get(objectField) != null);
                } else {
                    system.assertEquals(null, objectAsMap.get(objectField));
                }
            }
        }


        Test.stopTest();

    }

}