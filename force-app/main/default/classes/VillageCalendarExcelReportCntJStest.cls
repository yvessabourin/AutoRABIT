@isTest
private class VillageCalendarExcelReportCntJStest{
  

    @isTest static void test_readThemeandCampaignsbyFocus() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(false, 'Bicester', focusList, string.valueof(Date.today().year()), 'NA', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    }   
        @isTest static void test_readThemeandCampaignsbyFocus2() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments', 'Theme', 'Awareness and Positioning', 'Promotional Moments', 'Tactical Product focus', 'Retail Brand Moments',
            'Local Moments', 'Destination Marketing Moments', 'International Always On', 'Non-Campaigns', 'BAU'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, string.valueof(Date.today().year()), 'Q1', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    } 
     @isTest static void test_readThemeandCampaignsbyFocus3() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments', 'Theme', 'Awareness and Positioning', 'Promotional Moments', 'Tactical Product focus', 'Retail Brand Moments',
            'Local Moments', 'Destination Marketing Moments', 'International Always On', 'Non-Campaigns', 'BAU'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, string.valueof(Date.today().year()), 'Q2', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    } 
     @isTest static void test_readThemeandCampaignsbyFocus4() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments', 'Theme', 'Awareness and Positioning', 'Promotional Moments', 'Tactical Product focus', 'Retail Brand Moments',
            'Local Moments', 'Destination Marketing Moments', 'International Always On', 'Non-Campaigns', 'BAU'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, string.valueof(Date.today().year()), 'Q3', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    } 
     @isTest static void test_readThemeandCampaignsbyFocus5() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments', 'Theme', 'Awareness and Positioning', 'Promotional Moments', 'Tactical Product focus', 'Retail Brand Moments',
            'Local Moments', 'Destination Marketing Moments', 'International Always On', 'Non-Campaigns', 'BAU'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, string.valueof(Date.today().year()), 'Q1-Q2', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    }
     @isTest static void test_readThemeandCampaignsbyFocus6() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments', 'Theme', 'Awareness and Positioning', 'Promotional Moments', 'Tactical Product focus', 'Retail Brand Moments',
            'Local Moments', 'Destination Marketing Moments', 'International Always On', 'Non-Campaigns', 'BAU'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, string.valueof(Date.today().year()), 'Q2-Q3', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    }
     @isTest static void test_readThemeandCampaignsbyFocus7() {
         string html1 = '';

        test.startTest();
        list<string> focusList = new list<string>{'International Moments', 'Theme', 'Awareness and Positioning', 'Promotional Moments', 'Tactical Product focus', 'Retail Brand Moments',
            'Local Moments', 'Destination Marketing Moments', 'International Always On', 'Non-Campaigns', 'BAU'};
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, string.valueof(Date.today().year()), 'Q3-Q4', null, null);
        test.stopTest();

        system.assert(html1 != '' );

    }
         @isTest static void test_readThemeandCampaignsbyFocus8() {
         string html1 = '';
         string html2 = '';
         string html3 = '';

        test.startTest();
        list<string> focusList = new list<string>();
        html1 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, '2019', 'NA', null, null);
        html2 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(true, 'All Villages', focusList, '2020', 'Q4', null, null);
        html3 = VillageCalendarExcelReportControllerJS.readThemeandCampaignsbyFocus(false, 'Bicester', focusList, '2020', 'Q4', null, null);
        test.stopTest();

        system.assert(html1 != '' );
        system.assert(html2 != '' );
        system.assert(html3 != '' );

    } 
    
    @testSetup static void setupdata(){
   
      MAP<string, id> rectypeMap = new MAP<string, id>();

   //   for(Recordtype rt :  [SELECT id,name,SobjectType from Recordtype WHERE (DeveloperName = 'Tourism' AND SobjectType = 'Account') OR (Name = 'TBVSC Brand Campaign' AND SobjectType = 'Marketing_Campaign__c') OR (Name = 'Village Campaign' AND SobjectType = 'Marketing_Campaign__c') OR (Name = 'General Activity' AND SobjectType = 'Marketing_Activity__c')] ){
      for(Recordtype rt :  [SELECT id,name, DeveloperName,SobjectType from Recordtype WHERE (Name = 'Partner' AND SobjectType = 'Account') OR (Name = 'TBVSC Brand Campaign' AND SobjectType = 'Marketing_Campaign__c') OR (Name = 'Village Campaign' AND SobjectType = 'Marketing_Campaign__c') OR (Name = 'Village General Activity' AND SobjectType = 'Marketing_Activity__c')] ){
        RectypeMap.put(rt.name + ' '+ rt.sObjectType, rt.id);
          system.debug('rt +: ' + rt.name + ' '+ rt.sObjectType);
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

    list<Marketing_Campaign__c> MCstoInsert = new list<Marketing_Campaign__c>();
    Date referenceDate = Date.newInstance(2020, 01, 01);
    Marketing_Campaign__c MC = new Marketing_Campaign__c();
    MC.Name = 'Theme 1';
    MC.Campaign_Level__c = 'Theme';
    MC.Campaign_Focus__c = 'Theme';
    MC.recordtypeid = recTypeMap.get('TBVSC Brand Campaign Marketing_Campaign__c');
    MC.Short_Description__c = 'TEST';
    //MC.status__c = 'Confirmed';
    MC.status__c = 'Approved';
    MC.Start_Date__c = referenceDate.addMonths(-12);
    MC.End_Date__c = referenceDate.addMonths(12);
    //MC.Responsible_Person__c = 'test';
    MC.Responsible__c = usr1.id;
    //MC.Accountable__c = 'test';
    MC.Accountable_Person__c = usr1.id;
    insert MC;


    Marketing_Campaign__c MC2 = new Marketing_Campaign__c();
    MC2.Name = 'Group Campaign 2';
    MC2.recordtypeid = recTypeMap.get('TBVSC Brand Campaign Marketing_Campaign__c');
    MC2.Short_Description__c = 'TEST';
    MC2.Campaign_Level__c = 'Lead Moment';
    MC2.Campaign_Focus__c = 'Local Moments';
    MC2.Parent_Marketing_Campaign__c = MC.id;
    //MC2.status__c = 'Confirmed';
    MC2.status__c = 'Approved';
    MC2.Start_Date__c = referenceDate.addMonths(-11);
    MC2.End_Date__c = referenceDate.addMonths(11);
    //MC2.Responsible_Person__c = 'test';
    MC2.Responsible__c = usr1.id;
    //MC2.Accountable__c = 'test';
    MC2.Accountable_Person__c = usr1.id;
    insert MC2;

    Marketing_Campaign__c MC21 = new Marketing_Campaign__c();
    MC21.Name = 'Group Campaign 2';
    MC21.recordtypeid = recTypeMap.get('TBVSC Brand Campaign Marketing_Campaign__c');
    MC21.Short_Description__c = 'TEST';
    MC21.Campaign_Focus__c = 'Promotional Moments';
    MC21.Campaign_Level__c = 'Lead Moment';
    MC21.Parent_Marketing_Campaign__c = MC.id;
    //MC21.status__c = 'Confirmed';
    MC21.status__c = 'Approved';
    MC21.Start_Date__c = referenceDate.addMonths(-11);
    MC21.End_Date__c = referenceDate.addMonths(11);
    //MC21.Responsible_Person__c = 'test';
    MC21.Responsible__c = usr1.id;
    //MC21.Accountable__c = 'test';
    MC21.Accountable_Person__c = usr1.id;
    insert MC21;

    Marketing_Campaign__c MC3 = new Marketing_Campaign__c();
    MC3.Name = 'Group Campaign 2';
    MC3.recordtypeid = recTypeMap.get('TBVSC Brand Campaign Marketing_Campaign__c');
    MC3.Short_Description__c = 'TEST';
    MC3.Campaign_Focus__c = 'Tactical Product Focus';
    MC3.Campaign_Level__c = 'Lead Moment';
    MC3.Parent_Marketing_Campaign__c = MC2.id;
    //MC3.status__c = 'Confirmed';
    MC3.status__c = 'Approved';
    MC3.Start_Date__c = referenceDate.addMonths(-9);
    MC3.End_Date__c = referenceDate.addMonths(9);
    //MC3.Responsible_Person__c = 'test';
    MC3.Responsible__c = usr1.id;
    //MC3.Accountable__c = 'test';
    MC3.Accountable_Person__c = usr1.id;
    insert MC3;

    /*Marketing_Campaign__c MC31 = new Marketing_Campaign__c();
    MC31.Name = 'Group Campaign 2';
    MC31.recordtypeid = recTypeMap.get('Group Campaign Marketing_Campaign__c');
    MC31.Short_Description__c = 'TEST';
    MC31.Campaign_Level__c = 'Lead Group Campaign';
    MC31.Parent_Marketing_Campaign__c = MC2.id;
    MC31.status__c = 'Confirmed';
    MC21.Start_Date__c = date.newInstance(Integer.valueOf(system.today().year()), 01, 01);
    MC21.End_Date__c = date.newInstance(Integer.valueOf(system.today().year()), 12, 31);
    MC31.Responsible_Person__c = 'test';
    MC31.Accountable__c = 'test';
    insert MC31;*/

    Marketing_Campaign__c VCBV = new Marketing_Campaign__c();
    VCBV.Name = 'Bicester Village campaign 1';
    VCBV.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
    VCBV.Short_Description__c = 'TEST';
    //VCBV.status__c = 'Confirmed';
    VCBV.status__c = 'Approved';
    VCBV.Start_Date__c = referenceDate.addMonths(-11);
    VCBV.Campaign_Focus__c = 'Tactical Product Focus';
    VCBV.End_Date__c = referenceDate.addMonths(11);
    //VCBV.Responsible_Person__c = 'test';
    VCBV.Responsible__c = usr1.id;
    //VCBV.Accountable__c = 'test';
    VCBV.Accountable_Person__c = usr1.id;
    VCBV.Campaign_Level__c = 'Local Moment';
    VCBV.Village__c = Bicestervillage.id;
    VCBV.Parent_Marketing_Campaign__c = MC2.id;
    VCBV.Proposition__c = 'test';
    VCBV.Target_Audience__c = 'test';
    VCBV.KPI_Targets__c = 'test';
    insert VCBV;

    Marketing_Campaign__c VCBV1 = new Marketing_Campaign__c();
    VCBV1.Name = 'Bicester Village campaign 1';
    VCBV1.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
    VCBV1.Short_Description__c = 'TEST';
    //VCBV1.status__c = 'Confirmed';
    VCBV1.status__c = 'Approved';
    VCBV1.Start_Date__c = referenceDate.addMonths(-11);
    VCBV1.End_Date__c = referenceDate.addMonths(11);
    //VCBV1.Responsible_Person__c = 'test';
    VCBV1.Responsible__c = usr1.id;
    VCBV1.Campaign_Focus__c = 'Tactical Product Focus';
    //VCBV1.Accountable__c = 'test';
    VCBV1.Accountable_Person__c = usr1.id;
    VCBV1.Campaign_Level__c = 'Local Moment';
    VCBV1.Village__c = Bicestervillage.id;
    VCBV1.Parent_Marketing_Campaign__c = MC2.id;
    VCBV1.Proposition__c = 'test';
    VCBV1.Target_Audience__c = 'test';
    VCBV1.KPI_Targets__c = 'test';
    insert VCBV1;

    Marketing_Campaign__c VCBV2 = new Marketing_Campaign__c();
    VCBV2.Name = 'Bicester Village campaign 2';
    VCBV2.recordtypeid = recTypeMap.get('Village Campaign Marketing_Campaign__c');
    VCBV2.Short_Description__c = 'TEST';
    //VCBV2.status__c = 'Confirmed';
    VCBV2.status__c = 'Approved';
    VCBV2.Start_Date__c = referenceDate.addMonths(-11);
    VCBV2.End_Date__c = referenceDate.addMonths(11);
    VCBV2.Campaign_Focus__c = 'Tactical Product Focus';
    //VCBV2.Responsible_Person__c = 'test';
    VCBV2.Responsible__c = usr1.id;
    //VCBV2.Accountable__c = 'test';
    VCBV2.Accountable_Person__c = usr1.id;
    VCBV2.Campaign_Level__c = 'Local Moment';
    VCBV2.Village__c = Bicestervillage.id;
    VCBV2.Parent_Marketing_Campaign__c = MC3.id;
    VCBV2.Proposition__c = 'test';
    VCBV2.Target_Audience__c = 'test';
    VCBV2.KPI_Targets__c = 'test';
    insert VCBV2;

    }
}