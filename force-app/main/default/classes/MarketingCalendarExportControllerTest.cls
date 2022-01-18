@isTest
private class MarketingCalendarExportControllerTest{
    
    @testSetup static void setupdata(){
        
        map<string, id> rectypeMap = new Map<string, id>();

      /*  for(Recordtype rt :  [SELECT id, name, SobjectType 
                              FROM Recordtype 
                              WHERE (DeveloperName = 'Tourism' AND SobjectType = 'Account') 
                              OR (Name = 'Village Campaign' AND SobjectType = 'Marketing_Campaign__c') 
                              OR (Name = 'General Activity' AND SobjectType = 'Marketing_Activity__c')] ){*/
        
        for(Recordtype rt :  [SELECT id, name, SobjectType 
                              FROM Recordtype 
                              WHERE (Name = 'Partner' AND SobjectType = 'Account') 
                              OR (Name = 'Village Campaign' AND SobjectType = 'Marketing_Campaign__c') 
                              OR (Name = 'Village General Activity' AND SobjectType = 'Marketing_Activity__c')] ){                        
            RectypeMap.put(rt.Name + ' '+ rt.sObjectType, rt.id);
            system.debug('rt +: ' + rt.Name + ' '+ rt.sObjectType);
        }

      //integer thedate = system.today().year();
      //system.debug('thedate :' + thedate);
      //string thedatestring = string.valueof(system.today().year());

        Profile pf = [select Id from Profile where name = 'Tourism'];

        User usr1 = new User();
        usr1.LastName = 'myTestu1';
        usr1.Alias = 'myTestu2';
        usr1.Email = 'myTestu2@valueretail.com';
        usr1.Username = 'controllertest123456789@valueretail.com';
        usr1.Communitynickname = 'myTestu2' + 'Nickname';
        usr1.profileId = pf.Id;
        usr1.PortalRole = 'Manager';
        usr1.timezonesidkey = 'Europe/London';
        usr1.emailencodingkey = 'UTF-8';
        usr1.languagelocalekey = 'en_US';
        usr1.localesidkey = 'en_GB';
        usr1.isActive = true;   
        
        insert usr1;
      
        Village__c LaRocavillage = new Village__c();  
        list<Village__c> VilsToInsert = new list<Village__c>();
        LaRocavillage.Name = 'La Roca village';     
        LaRocavillage.Village_Code__c = 'LR';
        LaRocavillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        LaRocavillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        
        VilsToInsert.add(LaRocavillage);

        Village__c Bicestervillage = new Village__c();
        Bicestervillage.Name = 'Bicester';     
        Bicestervillage.Village_Code__c = 'BV';
        Bicestervillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        Bicestervillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        
        VilsToInsert.add(Bicestervillage);
        insert VilsToInsert;

        Account account = new Account();
        account.name = 'ControllerTest';
        account.recordtypeid = recTypeMap.get('Partner Account');
        account.country__c = 'Albania';
        account.Type_of_Business__c = 'Airline';
        account.Target_markets__c = 'England';
        account.Relevant_villages__c = 'Bicester';
        
        insert account;
        
        Date campaignDate = Date.newInstance(2020, 01, 01);
        
        List<Marketing_Campaign__c> marketingCampaigns = new List<Marketing_Campaign__c>();
        List<Marketing_Activity__c> marketingActivities = new List<Marketing_Activity__c>();
        
        Marketing_Campaign__c MC1 = new Marketing_Campaign__c();
        MC1.Name = 'Bicester Village Campaign 1';
        MC1.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
        MC1.Short_Description__c = 'TEST';
        //MC1.status__c = 'Confirmed';
        MC1.status__c = 'Approved';
        MC1.Start_Date__c = campaignDate;
        MC1.End_Date__c = campaignDate.addMonths(5);
        MC1.Campaign_Focus__c = 'Theme';
        MC1.Campaign_Level__c = 'Theme';
        //VCBV.Responsible_Person__c = 'test';
        MC1.Responsible__c = usr1.id;
        //VCBV.Accountable__c = 'test';
        MC1.Accountable_Person__c = usr1.id;
        MC1.Village__c = Bicestervillage.id;
        MC1.Proposition__c = 'test';
        MC1.Target_Audience__c = 'test';
        MC1.KPI_Targets__c = 'test';
        MC1.Retail_Marketing_Participation__c = true;
        
        marketingCampaigns.add(MC1);
        
        Marketing_Campaign__c MC2 = new Marketing_Campaign__c();
        MC2.Name = 'La Roca Village Campaign 1';
        MC2.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
        MC2.Short_Description__c = 'TEST';
        //MC2.status__c = 'Confirmed';
        MC2.status__c = 'Approved';
        MC2.Start_Date__c = campaignDate.addMonths(-10);
        MC2.End_Date__c = campaignDate.addMonths(-4);
        MC2.Campaign_Focus__c = 'Theme';
        MC2.Campaign_Level__c = 'Theme';
        //VCBV.Responsible_Person__c = 'test';
        MC2.Responsible__c = usr1.id;
        //VCBV.Accountable__c = 'test';
        MC2.Accountable_Person__c = usr1.id;
        MC2.Village__c = Bicestervillage.id;
        MC2.Proposition__c = 'test';
        MC2.Target_Audience__c = 'test';
        MC2.KPI_Targets__c = 'test';
        MC2.Retail_Marketing_Participation__c = true;
        
        marketingCampaigns.add(MC2);
        
        Marketing_Campaign__c MC3 = new Marketing_Campaign__c();
        MC3.Name = 'La Roca Village Campaign 2';
        MC3.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
        MC3.Short_Description__c = 'TEST';
        //MC3.status__c = 'Confirmed';
        MC3.status__c = 'Approved';
        MC3.Start_Date__c = campaignDate.addMonths(-4);
        MC3.End_Date__c = campaignDate.addMonths(8);
        MC3.Campaign_Focus__c = 'Theme';
        MC3.Campaign_Level__c = 'Theme';
        //VCBV.Responsible_Person__c = 'test';
        MC3.Responsible__c = usr1.id;
        //VCBV.Accountable__c = 'test';
        MC3.Accountable_Person__c = usr1.id;
        MC3.Village__c = Bicestervillage.id;
        MC3.Proposition__c = 'test';
        MC3.Target_Audience__c = 'test';
        MC3.KPI_Targets__c = 'test';
        MC3.Retail_Marketing_Participation__c = true;
        
        marketingCampaigns.add(MC3);
        
        Marketing_Campaign__c MC4 = new Marketing_Campaign__c();
        MC4.Name = 'La Roca Village Campaign 3';
        MC4.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
        MC4.Short_Description__c = 'TEST';
        //MC4.status__c = 'Confirmed';
        MC4.status__c = 'Approved';
        MC4.Start_Date__c = campaignDate.addMonths(4);
        MC4.End_Date__c = campaignDate.addMonths(7);
        MC4.Campaign_Focus__c = 'Theme';
        MC4.Campaign_Level__c = 'Theme';
        //VCBV.Responsible_Person__c = 'test';
        MC4.Responsible__c = usr1.id;
        //VCBV.Accountable__c = 'test';
        MC4.Accountable_Person__c = usr1.id;
        MC4.Village__c = Bicestervillage.id;
        MC4.Proposition__c = 'test';
        MC4.Target_Audience__c = 'test';
        MC4.KPI_Targets__c = 'test';
        MC4.Retail_Marketing_Participation__c = false;
        
        marketingCampaigns.add(MC4);
        
        INSERT marketingCampaigns;

        //Create Marketing Activities

        Id activityRecordTypeId = Schema.SObjectType.Marketing_Activity__c.getRecordTypeinfosByDeveloperName().get('General_Activity').getRecordTypeId();
        

        Marketing_Activity__c MA1 = new Marketing_Activity__c();
        MA1.Name = 'La Roca Campaign Activity';
        MA1.Business_Function__c = 'Local Tourism';
        MA1.Channel__c = 'CRM';
        MA1.Sub_Channel__c = 'Email';
        MA1.Marketing_Campaign__c = MC3.Id;
        MA1.Status__c = 'Approved';
        MA1.Start_Date__c = campaignDate.addMonths(2);
        MA1.End_Date__c = campaignDate.addMonths(4);
        MA1.recordtypeid = activityRecordTypeId;

        marketingActivities.add(MA1);

        Marketing_Activity__c MA2 = new Marketing_Activity__c();
        MA2.Name = 'La Roca Campaign Activity 2';
        MA2.Business_Function__c = 'Local Tourism';
        MA2.Channel__c = 'CRM';
        MA2.Sub_Channel__c = 'Email';
        MA2.Marketing_Campaign__c = MC2.Id;
        MA2.Status__c = 'Approved';
       MA2.Start_Date__c = campaignDate.addMonths(-2);
    //     MA2.Start_Date__c = campaignDate.addMonths(-8);
        MA2.End_Date__c = campaignDate.addMonths(1);
   //     MA2.End_Date__c = campaignDate.addMonths(-2);
        MA2.recordtypeid = activityRecordTypeId;

        marketingActivities.add(MA2);

        Marketing_Activity__c MA3 = new Marketing_Activity__c();
        MA3.Name = 'Bicester Campaign Activity';
        MA3.Business_Function__c = 'Local Tourism';
        MA3.Channel__c = 'CRM';
        MA3.Sub_Channel__c = 'Email';
        MA3.Marketing_Campaign__c = MC1.Id;
        MA3.Status__c = 'Approved';
        MA3.Start_Date__c = campaignDate.addMonths(-4);
  //      MA3.End_Date__c = campaignDate.addMonths(8);
        MA3.End_Date__c = campaignDate.addMonths(4);
        MA3.recordtypeid = activityRecordTypeId;

        marketingActivities.add(MA3);

        INSERT marketingActivities;


    }
    
    @isTest static void calendarTestAllVillages(){
        test.startTest();
        
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q1', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q2', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q3', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q4', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q1-Q2', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q2-Q3', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'Q3-Q4', System.Label.Campaigns);
        
        test.stopTest();
    }
    
    @isTest static void calendarTestBicester(){
        test.startTest();
        
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'NA', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q1', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q2', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q3', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q4', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q1-Q2', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q2-Q3', System.Label.Campaigns);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('Bicester', '2020', 'Q3-Q4', System.Label.Campaigns);
        
        test.stopTest();
    }
    
    @isTest static void calendarTestEmptyFilters(){
        test.startTest();
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '', 'NA', System.Label.Campaigns_and_Activities);
        test.stopTest();
    }

    @IsTest static void calendarTestActivities(){
        test.startTest();
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2020', 'NA', System.Label.Campaigns_and_Activities);
        MarketingCalendarExportController.readThemeandCampaignsbyFocus('All Villages', '2019', 'NA', System.Label.Campaigns_and_Activities);
        test.stopTest();
    }


}