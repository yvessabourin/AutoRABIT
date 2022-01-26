@isTest
private class CampaignExcelReportControllerJStest {
    
    @isTest static void test_method_one() {
        Marketing_Campaign__c MCtopassin1 = [SELECT Id, Name from Marketing_Campaign__c where Name = 'Group Campaign 1' ];
        string html1 = '';

        test.startTest();
        html1 = CampaignExcelReportControllerJS.readCampaigns(MCtopassin1.id);
        test.stopTest();

        system.assert(html1 != '<b>There are no activites to show</b>' , 'html returned not as expected');
    }

    @isTest static void test_method_two() {
        Marketing_Campaign__c MCtopassin2 = [SELECT Id, Name from Marketing_Campaign__c where Name = 'Group Campaign 2' ];
        string html3 = '';

        test.startTest();
        html3 = CampaignExcelReportControllerJS.readCampaigns(MCtopassin2.id);
        test.stopTest();

        system.assert(html3 == '<b>There are no activites to show</b>' , 'html returned not as expected');
    }
    
    
    @testSetup static void setupdata(){
    
        Profile profileSysAdmin = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator'];

        UserRole adminRole = new UserRole();
        adminRole.DeveloperName = 'CustomRole';
        adminRole.Name = 'Custom Role';
        insert adminRole;

        User admin = new User();
        admin.LastName = 'AdministratorForTestingHere';
        admin.Alias = 'admin';
        admin.Email = 'adminFortests@valueretai.com';
        admin.Username = 'adminFortests@valueretai.com';
        admin.CommunityNickname = 'admin';
        admin.UserRoleId = adminRole.Id;
        admin.ProfileId = profileSysAdmin.Id;
        admin.Village__c = 'Bicester';
        admin.TimeZoneSidKey = 'GMT';
        admin.LocaleSidKey = 'en_GB';
        admin.EmailEncodingKey = 'ISO-8859-1';
        admin.LanguageLocaleKey = 'en_US';
        insert admin;
    
        system.runAs(admin){
   
        MAP<string, id> RectypeMap = new MAP<string, id>();

        for(Recordtype rt :  [SELECT id,name,DeveloperName,SobjectType from Recordtype WHERE (DeveloperName = 'Tourism' AND SobjectType = 'Account') OR (DeveloperName = 'TBVSC_Brand_Campaign' AND SobjectType = 'Marketing_Campaign__c') OR (DeveloperName = 'Village_Campaign' AND SobjectType = 'Marketing_Campaign__c') OR (DeveloperName = 'General_Activity' AND SobjectType = 'Marketing_Activity__c')] ){
                RectypeMap.put(rt.DeveloperName + ' '+ rt.sObjectType, rt.id);
        }
        
        RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;

        RecordType brandContactRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Brand_Contact'];
        
            Contact communityContact = new Contact();
            communityContact.RecordTypeId = brandContactRecordType.Id;
            communityContact.LastName = 'John';
            communityContact.AccountId = brand.Id;
            communityContact.Village_Presence__c = 'Bicester';
            communityContact.Email = 'testcommunity.contact@brand.com';
            insert communityContact;
            
            Profile profileCommunity = [SELECT ID, Name FROM Profile WHERE Name = 'Third Party Community User'];
                
            User communityUser = new User();
            communityUser.LastName = communityContact.LastName;
            communityUser.Alias = 'jhn';
            communityUser.Email = communityContact.Email;
            communityUser.Username = 'john@valueretai.com';
            communityUser.CommunityNickname = 'johnvr';
            communityUser.ProfileId = profileCommunity.Id;
            communityUser.Village__c = 'Bicester';
            communityUser.TimeZoneSidKey = 'GMT';
            communityUser.LocaleSidKey = 'en_GB';
            communityUser.EmailEncodingKey = 'ISO-8859-1';
            communityUser.LanguageLocaleKey = 'en_US';
            communityUser.ContactId = communityContact.Id;
            communityUser.PortalRole = 'Manager';
            insert communityUser;
      
        Village__c LaRocavillage = new Village__c();  
        list<Village__c> VilsToInsert = new list<Village__c>();
        LaRocavillage.Name = 'La Roca village';     
        LaRocavillage.Village_Code__c = 'LR';
        LaRocavillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        LaRocavillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        VilsToInsert.add(LaRocavillage);

        Village__c Bicestervillage = new Village__c();
        Bicestervillage.Name = 'Bicester Village';     
        Bicestervillage.Village_Code__c = 'BV';
        Bicestervillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        Bicestervillage.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        VilsToInsert.add(Bicestervillage);
        insert VilsToInsert;

        Account account = new Account();
        account.name = 'ControllerTest';
        account.recordtypeid = recTypeMap.get('Tourism Account');
        account.country__c = 'Albania';
        account.Type_of_Business__c = 'Airline';
        insert account;

        list<Marketing_Campaign__c> MCstoInsert = new list<Marketing_Campaign__c>();
        Marketing_Campaign__c MC = new Marketing_Campaign__c();
        MC.Name = 'Group Campaign 1';
        MC.Campaign_Level__c = 'Theme';
        MC.recordtypeid = recTypeMap.get('TBVSC_Brand_Campaign Marketing_Campaign__c');
        MC.Short_Description__c = 'TEST';
        MC.status__c = 'Approved';
        MC.Start_Date__c = system.today();
        MC.End_Date__c = system.today() + 10;
        MC.Responsible__c = admin.id;
        MC.Accountable_Person__c = admin.id;
        MCstoInsert.add(MC);

        Marketing_Campaign__c MC2 = new Marketing_Campaign__c();
        MC2.Name = 'Group Campaign 2';
        MC2.Campaign_Level__c = 'Theme';
        MC2.recordtypeid = recTypeMap.get('TBVSC_Brand_Campaign Marketing_Campaign__c');
        MC2.Short_Description__c = 'TEST';
        MC2.status__c = 'Approved';
        MC2.Start_Date__c = system.today();
        MC2.End_Date__c = system.today() + 10;
        MC2.Responsible__c = admin.id;
        MC2.Accountable_Person__c = admin.id;
        MCstoInsert.add(MC2);
        insert MCstoInsert;
        MCstoInsert.clear();

        Marketing_Campaign__c VCLRV = new Marketing_Campaign__c();
        VCLRV.Name = 'La Roca Village campaign 1';
        VCLRV.recordtypeid = recTypeMap.get('Village_Campaign Marketing_Campaign__c');
        VCLRV.Short_Description__c = 'TEST';
        VCLRV.status__c = 'Approved';
        VCLRV.Start_Date__c = system.today() + 2;
        VCLRV.End_Date__c = system.today() + 8;
        VCLRV.Responsible__c = admin.id;
        VCLRV.Accountable_Person__c = admin.id;
        VCLRV.Campaign_Level__c = 'Tactical Campaign';
        VCLRV.Village__c = LaRocavillage.id;
        VCLRV.Parent_Marketing_Campaign__c = MC.id;
        VCLRV.Proposition__c = 'test';
        VCLRV.Target_Audience__c = 'test';
        VCLRV.KPI_Targets__c = 'test';
        MCstoInsert.add(VCLRV);

        Marketing_Campaign__c VCBV = new Marketing_Campaign__c();
        VCBV.Name = 'Bicester Village campaign 1';
        VCBV.recordtypeid = recTypeMap.get('Village_Campaign Marketing_Campaign__c');
        VCBV.Short_Description__c = 'TEST';
        VCBV.status__c = 'Approved';
        VCBV.Start_Date__c = system.today() + 2;
        VCBV.End_Date__c = system.today() + 8;
        VCBV.Responsible__c = admin.id;        
        VCBV.Accountable_Person__c = admin.id;
        VCBV.Campaign_Level__c = 'Tactical Campaign';
        VCBV.Village__c = Bicestervillage.id;
        VCBV.Parent_Marketing_Campaign__c = MC.id;
        VCBV.Proposition__c = 'test';
        VCBV.Target_Audience__c = 'test';
        VCBV.KPI_Targets__c = 'test';
        MCstoInsert.add(VCBV);
        insert MCstoInsert;

        list<Marketing_Activity__c> MAsToInsert = new list<Marketing_Activity__c>();
        Marketing_Activity__c MALRV = new Marketing_Activity__c();
        MALRV.Name = 'La Roca MA 1';
        //MALRV.recordtypeid = recTypeMap.get('General Activity Marketing_Activity__c');
      	MALRV.recordtypeid = recTypeMap.get('General_Activity Marketing_Activity__c');	 
        MALRV.Business_Function__c = 'Local Tourism';
        MALRV.Channel__c = 'CRM';
        MALRV.sub_channel__c = 'Direct Mail';
        MALRV.Marketing_Campaign__c = VCLRV.id;
        MALRV.Status__c = 'Approved';
        MALRV.Start_Date__c = system.today() + 2;
        MALRV.End_Date__c = system.today() + 8;
        MALRV.Objective__c = 'test';
        MALRV.Response_Description__c = 'test';
        MALRV.Measurement_Description__c = 'test';
        MALRV.Communication_Plan__c = 'test';
        MALRV.Message__c = 'test';
        MALRV.Accountable1__c = admin.id;
        MALRV.Responsible_Person__c = admin.id;
        MALRV.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
        MAsToInsert.add(MALRV);

        Marketing_Activity__c MABV = new Marketing_Activity__c();
        MABV.Name = 'Bicester MA 1';
		//MABV.recordtypeid = recTypeMap.get('General Activity Marketing_Activity__c'); 
        MABV.recordtypeid = recTypeMap.get('General_Activity Marketing_Activity__c'); 
        MABV.Business_Function__c = 'Local Tourism';
        MABV.Channel__c = 'CRM';
        MABV.sub_channel__c = 'Direct Mail';
        MABV.Marketing_Campaign__c = VCBV.id;
        MABV.Status__c = 'Approved';
        MABV.Start_Date__c = system.today() + 2;
        MABV.End_Date__c = system.today() + 8;
        MABV.Objective__c = 'test';
        MABV.Response_Description__c = 'test';
        MABV.Measurement_Description__c = 'test';
        MABV.Communication_Plan__c = 'test';
        MABV.Message__c = 'test';
        MABV.Accountable1__c = admin.id;
        MABV.Responsible_Person__c = admin.id;
        MABV.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
        MAsToInsert.add(MABV);

        Marketing_Activity__c MABV2 = new Marketing_Activity__c();
        MABV2.Name = 'Bicester MA 2';
		//MABV2.recordtypeid = recTypeMap.get('General Activity Marketing_Activity__c');
        MABV2.recordtypeid = recTypeMap.get('General_Activity Marketing_Activity__c');
        MABV2.Business_Function__c = 'Local Tourism';
        MABV2.Channel__c = 'CRM';
        MABV2.sub_channel__c = 'Direct Mail';
        MABV2.Marketing_Campaign__c = VCBV.id;
        MABV2.Status__c = 'Approved';
        MABV2.Start_Date__c = system.today() + 2;
        MABV2.End_Date__c = system.today() + 8;
        MABV2.Objective__c = 'test';
        MABV2.Response_Description__c = 'test';
        MABV2.Measurement_Description__c = 'test';
        MABV2.Communication_Plan__c = 'test';
        MABV2.Message__c = 'test';
        MABV2.Accountable1__c = admin.id;
        MABV2.Responsible_Person__c = admin.id;
        MABV2.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
        MAsToInsert.add(MABV2);

        insert MAsToInsert;
        }

    }
}