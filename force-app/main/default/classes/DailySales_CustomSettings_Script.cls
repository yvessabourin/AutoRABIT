public class DailySales_CustomSettings_Script {
    
    public static void CustomSettingsOptions(){
        DailySales_Validation_Override__c dsvoRecord = DailySales_Validation_Override__c.getOrgDefaults();
        dsvoRecord.DailySales_Override__c = false;
        
        try{
          insert dsvoRecord;
        }catch(Exception e) {
          logFile__c log = new logFile__c();
          log.Body__c = 'Error trying to implement validation Override ' + e.getMessage();
          log.Type__c = 'Daily Sales Custom Settings Script, Override insert';
          insert log;
          system.debug('Error trying to implement validation Override ' + e.getMessage());
        }
        
        Profile pSystema = [SELECT Id FROM Profile WHERE name = 'System Administrator'];
        Profile pDailySales = [SELECT Id FROM Profile WHERE name = 'Daily Sales API'];
        Profile pFinanceSales = [SELECT Id FROM Profile WHERE name = 'Finance Sales Certification'];
        User uIService = [SELECT Id FROM User WHERE name = 'Integration Service'];
        
        DailySales_Validation_Override__c inProfSys = new DailySales_Validation_Override__c (SetupOwnerId= pSystema.Id, DailySales_Override__c = true);      
        DailySales_Validation_Override__c inProfDailyS = new DailySales_Validation_Override__c (SetupOwnerId= pDailySales.Id, DailySales_Override__c = true);
        DailySales_Validation_Override__c inProfFinanceS = new DailySales_Validation_Override__c (SetupOwnerId= pFinanceSales.Id, DailySales_Override__c = true);
        DailySales_Validation_Override__c inUsIntService = new DailySales_Validation_Override__c (SetupOwnerId= uIService.Id, DailySales_Override__c = true);
                
        try{
          insert inProfSys;
          insert inProfDailyS;
          insert inProfFinanceS;
          insert inUsIntService;
        }catch(Exception e) {
          logFile__c log = new logFile__c();
          log.Body__c = 'Error trying to implement validation Override ' + e.getMessage();
          log.Type__c = 'Daily Sales Custom Settings Script, Override insert';
          insert log;
          system.debug('Error trying to implement validation Override ' + e.getMessage());
        }
        
        
        
        Daily_Sales_Status_Map__c dssmR = [SELECT Id, Audited__c, Certified__c, Created__c, Reported_Complete__c, Reported_Confirmed__c, Reported_Incomplete__c, TOR__c, Certified_Approved__c, Certified_Complete__c, Certified_Pending__c, Certified_Re_opened__c FROM Daily_Sales_Status_Map__c];
        //Daily_Sales_Status_Map__c dssmRecord = Daily_Sales_Status_Map__c.getOrgDefaults();
        dssmR.Audited__c = 'Hidden';
        dssmR.Certified__c = 'Hidden';
        dssmR.Created__c = 'Edit';
        dssmR.Reported_Complete__c = 'Hidden';
        dssmR.Reported_Confirmed__c = 'Edit';
        dssmR.Reported_Incomplete__c = 'Edit';
        dssmR.TOR__c = 'Edit';
        dssmR.Certified_Approved__c = 'Read';
        dssmR.Certified_Complete__c = 'Read';
        dssmR.Certified_Pending__c = 'Edit';
        dssmR.Certified_Re_opened__c = 'Edit';
        try{
          update dssmR;
        }catch(Exception e) {
          logFile__c log = new logFile__c();
          log.Body__c = 'Error trying to update Global Settings' + e.getMessage();
          log.Type__c = 'Daily Sales Custom Settings Script, Global Settings';
          insert log;
          system.debug('Error trying to update Global Settings ' + e.getMessage());
        }
        
        
        VR1_Configuration_Settings__c confSettingR = [SELECT id, Default_Chatter_Roles__c FROM VR1_Configuration_Settings__c];
        //VR1_Configuration_Settings__c confSettingRecord = VR1_Configuration_Settings__c.getOrgDefaults();
        confSettingR.Default_Chatter_Roles__c = 'Leasing,Legal,Retail';
        
        try{
          update confSettingR;
        }catch(Exception e) {
          logFile__c log = new logFile__c();
          log.Body__c = 'Error trying to update Global Settings' + e.getMessage();
          log.Type__c = 'Daily Sales Custom Settings Script, Global Settings';
          insert log;
          system.debug('Error trying to update Global Settings ' + e.getMessage());
        }

        
        String sched2am = '0 0 2 ? * * *';  //at 2:00 AM every day
        DailySalesGraceScheduler SC = new DailySalesGraceScheduler();
        if(!Test.isRunningTest()){
        	System.schedule('DailySalesGraceScheduler - 2AM', sched2am, SC); 
        }
        
        String schedopendays = '0 0 4 ? * * *';  //at 4:00 AM every day
        CertificationOpenDaysScheduler SCopendays = new CertificationOpenDaysScheduler();
        if(!Test.isRunningTest()){
        	System.schedule('CertificationOpenDaysScheduler - 4AM', schedopendays, SCopendays); 
        }    
        
    }
}