@isTest
public class DailySales_CustomSettings_Script_Test {
    
    static testMethod void CustomSettingsOptionsTest(){
        Daily_Sales_Status_Map__c newDSSM = Daily_Sales_Status_Map__c.getOrgDefaults();
        newDSSM.TOR__c = 'Read';
        insert newDSSM;
        
        VR1_Configuration_Settings__c newVR1CS = VR1_Configuration_Settings__c.getOrgDefaults();
        newVR1CS.Default_Chatter_Roles__c = 'Leasing,Legal,Retail,Finance';
        insert newVR1CS;
        
        Test.startTest();
        	DailySales_CustomSettings_Script.CustomSettingsOptions();
        Test.stopTest();
        
        Daily_Sales_Status_Map__c dssmR = [SELECT Id, Audited__c, Certified__c, Created__c, Reported_Complete__c, Reported_Confirmed__c, Reported_Incomplete__c,
                                           TOR__c, Certified_Approved__c, Certified_Complete__c, Certified_Pending__c, Certified_Re_opened__c
                                           FROM Daily_Sales_Status_Map__c];
        VR1_Configuration_Settings__c confSettingR = [SELECT id, Default_Chatter_Roles__c FROM VR1_Configuration_Settings__c];
        
        system.assertEquals('Read', dssmR.Certified_Approved__c);
        system.assertEquals('Edit', dssmR.TOR__c);
        system.assertEquals('Leasing,Legal,Retail', confSettingR.Default_Chatter_Roles__c);
    }
}