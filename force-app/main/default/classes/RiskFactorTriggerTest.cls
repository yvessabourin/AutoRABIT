@isTest
public class RiskFactorTriggerTest{

      public static void setupData(){

        Profile riskProfile = [SELECT ID, Name FROM Profile WHERE Name = 'Leasing'];

        UserRole riskRole = new UserRole();
        riskRole.DeveloperName = 'CustomRole';
        riskRole.Name = 'Custom Role';
        insert riskRole;

        User riskUser = new User();
        riskUser.LastName = 'John';
        riskUser.Alias = 'jhnD';
        riskUser.Email = 'johnDoe@valueretai.com';
        riskUser.Username = 'johnDoe@valueretai.com';
        riskUser.CommunityNickname = 'johnvr';
        riskUser.UserRoleId = riskRole.Id;
        riskUser.ProfileId = riskProfile.Id;
        riskUser.Village__c = 'Bicester';
        riskUser.TimeZoneSidKey = 'GMT';
        riskUser.LocaleSidKey = 'en_GB';
        riskUser.EmailEncodingKey = 'ISO-8859-1';
        riskUser.LanguageLocaleKey = 'en_US';
        insert riskUser;

        system.runAs(riskUser){
        // Create a village
          Village__c vill = TestDataGenerator.setupVillage(false);
          vill.Oracle_Source_Template_Number__c = '123456';
          vill.Oracle_Organisation__c = 'SourceOrg';
          vill.Name = 'BicesterTestVillage';
          vill.village_code__c = 'BV';
          vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
          vill.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
          insert vill;

          RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];

          Account brand = new Account();
          brand.RecordTypeId = brandRecordType.Id;
          brand.Name = 'Brand 1';
          insert brand;

          Village_Presence__c presentBrand = new Village_Presence__c();
          presentBrand.Name = 'Brand1 in village';
          presentBrand.Brand__c = brand.Id;
          presentBrand.Village__c = vill.Id;
          presentBrand.Lease_ID__c = 'BRAND1BIC';
          insert presentBrand;
      }
    }
       
    @isTest static void TestRiskFactor() {
        
        setupData();
      	
        User john = [SELECT Id FROM User WHERE Alias='jhnD'];
        Risk_Factor__c risk = new Risk_Factor__c();
        system.runAs(john){
            Village_Presence__c vp = [SELECT Id FROM Village_Presence__c WHERE Lease_ID__c = 'BRAND1BIC'];
            
            // Create a risk factor record for a village presence
            risk.Village_Presence__c=vp.Id;
            risk.Brand_Risk_Description__c='VP_Risk_Factor_Test';
            insert risk;        
        }
        // Verify   
        Risk_Factor__c rf = [SELECT Id,Primary_Key__c,Village_Presence__c FROM Risk_Factor__c WHERE Id= :risk.Id];      
        //System.assertEquals(rf.Primary_Key__c, risk.Village_Presence__c);
    }    
}