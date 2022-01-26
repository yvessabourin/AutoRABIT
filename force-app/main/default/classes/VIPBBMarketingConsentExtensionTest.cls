@isTest
private class VIPBBMarketingConsentExtensionTest{

        
    @TestSetup
    public static void SetupData(){

        List<Account> testAccounts = new List<Account>();

        testAccounts.add(new Account(FirstName = 'John', LastName = 'Smith' , PersonEmail='testemail@mail.com', RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId));
        testAccounts.add(new Account(FirstName = 'Frank', LastName = 'Jones' , PersonEmail='testemailJones@mail.com', RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId));
        testAccounts.add(new Account(FirstName = 'James', LastName = 'Williams' , PersonEmail='testemailWilliams@mail.com', RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId));
        
        insert testAccounts;

        // also insert a few language labels
        Custom_Label__c custlabel = new Custom_Label__c();
        custlabel.Custom_Label_Value__c = 'DECLINE';
        custlabel.Name = 'DeclineButton';
        custlabel.Language__c = 'en';
        custlabel.Used_in_App__c = 'test';
        insert custlabel;

    }
        static testMethod void testGuestUpdate() {
        
        Test.startTest();
        List<Account> accs = [SELECT ID, Name,PersonEmail FROM Account WHERE RecordTypeID = :Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId];
        System.debug('ALL Accounts = ' + accs);

        
        String result1 = VIPBBMarketingConsentExtension.saveMarketingConsent(accs[0].Id, accs[0].PersonEmail, '0123456', 'Street Address','City','PO57OD','United Kingdom' , 'true', 'true', 'true');
        
        String result2 = VIPBBMarketingConsentExtension.saveMarketingConsent(accs[1].Id, accs[1].PersonEmail, '01234567', 'Street Address','City','PO57OD','United Kingdom' , 'false', 'false', 'false');
        
        String result3 = VIPBBMarketingConsentExtension.saveMarketingConsent(accs[2].Id, accs[2].PersonEmail, '012345678', 'Street Address','City','PO57OD','United Kingdom' , 'true', 'false', 'false');
       
        Test.stopTest();

        System.assert(result1.contains('SAVEDID'));
        System.assert(result2.contains('SAVEDID'));
        System.assert(result3.contains('SAVEDID'));

        }

        static testMethod void testLanguages(){
            // this is sadly just a test for coverage sake, since it just gets the language labels from custom settings
            String languageLabels = VIPBBMarketingConsentExtension.getLanguageLabels('en');
            System.debug('languageLabels === ' + languageLabels);
            System.assert(languageLabels != '');
        }
}