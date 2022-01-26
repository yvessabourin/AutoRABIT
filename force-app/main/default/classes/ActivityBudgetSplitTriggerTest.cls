@isTest
Public Class ActivityBudgetSplitTriggerTest{   

private static Account account = new Account();
    private static Account account2 = new Account();
    public static Marketing_Campaign__c MC = new Marketing_Campaign__c();
    public static Marketing_Activity__c MA = new Marketing_Activity__c();
    public static Associated_Account__c AA = new Associated_Account__c();

    @testSetup 
    static void setUpData(){
    
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
        
        RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
        
            RecordType brandContactRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand Contact'];
        
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
            
        // first create a village
        Village__c vill = TestDataGenerator.setupVillage(false);
        vill.Oracle_Source_Template_Number__c = '123456';
        vill.Oracle_Organisation__c = 'SourceOrg';
		vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        insert vill;

        account = TestData_Account.setupBrandAccount(1, true);
        account2 = TestData_Account.setupBrandAccount(2, true);
        Account testAccount = new Account(name = 'Test Account' , RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId);
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.AllowSave = true;
        Database.insert(testAccount, dmlOptions);
          
        Village_Presence__c VP = new Village_Presence__c();
        VP.Name = 'test';
        VP.Brand__c = account2.id;
        VP.Village__c = vill.id;
        insert VP;

        Map <String,Schema.RecordTypeInfo> recordTypesadjustment = Marketing_Campaign__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id RecTypeIdinadj = recordTypesadjustment.get('Village Campaign').getRecordTypeId();

        MC.Name = 'TestCampaignForTestingSync';
        //MC.Marketing_Campaign_Ref__c = 'MCREF001';
        MC.Short_Description__c = 'TestCampaign Description';
        MC.Start_Date__c = Date.newInstance(2020, 12, 12);
        MC.End_Date__c = Date.newInstance(2021, 12, 12);
        MC.Campaign_Level__c = 'Theme';
        MC.Village__c = vill.Id;
        MC.RecordTypeId = RecTypeIdinadj;
        insert MC;

        // and now insert an activity

    //    id theRecId =  Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('General Activity').RecordTypeId;
		id theRecId =  Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('General_Activity').RecordTypeId;
        MA.Name = 'TestActivity for MAUtilites Test';
        //MA.Marketing_Activity_Ref__c = 'MA Ref';
        MA.recordtypeId = theRecId;
        MA.Start_Date__c = Date.newInstance(2020, 12, 12);
        MA.End_Date__c = Date.newInstance(2021, 12, 12);
        MA.Marketing_Campaign__c = MC.ID;
        MA.Partner__c = testAccount.Id;
        MA.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
        MA.CurrencyIsoCode = 'GBP';
        insert MA;
        }
}
    
    
    @istest static void test1(){
    
        //setUpData();
        Marketing_Activity__c MA = [select id, name, Start_Date__c FROM Marketing_Activity__c WHERE NAME ='TestActivity for MAUtilites Test'];
    
        Activity_Budget_Split__c  ABS = new Activity_Budget_Split__c ();
        ABS.Marketing_Activity__c = MA.id;
        ABS.Year__c = String.valueOf(MA.Start_Date__c.year());
        ABS.X01_January__c = 100;
        ABS.CurrencyIsoCode = 'EUR';
        
        Test.startTest();
        try{
            insert ABS;
        }
        catch(Exception e){
            System.debug('ABS error ' + e.getMessage());
        }

        Test.stopTest();
        
        Activity_Budget_Split__c ABSplit = [SELECT ID, CurrencyIsoCode FROM Activity_Budget_Split__c WHERE id =: ABS.id];
        system.debug('ABS : ' +  ABS);
        System.Assert(ABSplit.CurrencyIsoCode == 'GBP' );
        //System.assertequals('GBP',ABSplit.CurrencyIsoCode, 'error');

        
        
    
    }
        
        
}