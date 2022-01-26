/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This Apex Test Class is to test the functionality of  PI_PersonalPrefController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Barry White
* @created       01/07/2019
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@isTest 
public with sharing class PI_PersonalPrefControllerTest {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * The Setup method is used to create common test data that is used by all other test methods in 
    * the class.
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @testSetup 
    static void setup() {

        Account acc = new Account();
        acc.FirstName = 'Baker';
        acc.LastName = 'Mayfield';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VIP Guest').getRecordTypeId();
        insert acc;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Test the save method and country code mapping
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    static testMethod void testSave(){
        
        
        Account customer = [SELECT Id, PersonContactId FROM ACCOUNT LIMIT 1][0];

        ApexPages.StandardController controller = new ApexPages.StandardController(customer);
        PI_PersonalPrefController extension = new PI_PersonalPrefController(controller);
        PageReference pageRef = Page.pi_personalPref;
        pageRef.getParameters().put('Id', String.valueOf(customer.Id));
        Test.setCurrentPage(pageRef);

        Test.startTest();
            // create a personal pref
            extension.personalPref.Lead_Source__c = 'Other';
            extension.personalPref.Body_Shape__c = 'small';
            extension.personalPref.Style__c = 'cool';
            // Save
            extension.save();

        Test.stopTest();

        list<Personal_Shopping_Preference__c> listPersonalprefs = [SELECT Id, Body_Shape__c FROM Personal_Shopping_Preference__c];
        system.assertEquals(1, listPersonalprefs.size(), 'Expected 1 preference, found ' + listPersonalprefs.size());
        system.assertEquals('small', listPersonalprefs[0].Body_Shape__c, 'Expected small as body shape, found ' + listPersonalprefs[0].Body_Shape__c);
    }
}