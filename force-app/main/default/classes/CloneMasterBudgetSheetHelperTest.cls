@isTest
private class CloneMasterBudgetSheetHelperTest {
    
    static void setup() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'userTest', Email='testuser@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='testUser@test.com.SMP');

        insert u;
        
        Profile pf = [select Id from Profile where name = 'Tourism'];
        
        RecordType brandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
        
            RecordType brandContactRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Brand_Contact'];
        
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
        
        Village__c village = new Village__c();
        village.Name = 'test';
        village.Village_Code__c = '12';
        village.CurrencyIsoCode = 'EUR';
        village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village.CertSales_Report_Sales_Grace_Period_Days__c = 1;

        insert village;

        Marketing_Campaign__c campaign = new Marketing_Campaign__c();
        campaign.Name = 'UnitTestCampaign';
        campaign.Short_Description__c = 'test';
        campaign.Campaign_Level__c = 'THEME';
        campaign.Village__c = village.Id;
        //campaign.Status__c = 'Confirmed';
        campaign.Status__c = 'Approved';
        campaign.Start_Date__c = Date.today();
        campaign.End_Date__c = Date.today().addMonths(1);
        campaign.CurrencyIsoCode = 'EUR';
        //campaign.Responsible_Person__c = 'test';
        campaign.Responsible__c = u.Id;
        //campaign.Accountable__c = 'test';
        campaign.Accountable_Person__c = u.Id;
        campaign.Proposition__c = 'test';
        campaign.Target_Audience__c = 'test';
        campaign.KPI_Targets__c = 'test';

        insert campaign;
        
    	Id recordTypeId = Schema.SObjectType.Marketing_Activity__c.getRecordTypeInfosByDeveloperName().get('General_Activity').getRecordTypeId();
        Marketing_Activity__c activity = new Marketing_Activity__c();
        activity.Name = 'testActivity';
        activity.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
        activity.Start_Date__c = Date.today();
        activity.End_Date__c = Date.today().addMonths(1);
        activity.Business_Function__c = 'Local Tourism';
        activity.Channel__c = 'Campaign Support';
        activity.Sub_Channel__c = 'App Innovations';
        activity.Marketing_Campaign__c = campaign.Id;
        //activity.Status__c = 'Confirmed';
        activity.Status__c = 'Approved';
        activity.Objective__c = 'test';
        activity.Response_Description__c = 'test';
        activity.Measurement_Description__c = 'test';
        activity.Communication_Plan__c = 'test';
        activity.Message__c = 'test';
        //activity.Accountable__c = 'test';
        activity.Accountable1__c = u.Id; 
        activity.Responsible_Person__c = u.Id;
        activity.RecordTypeId = recordTypeId;

        insert activity;

        List<Master_Budget_Sheet__c> sheetList = new List<Master_Budget_Sheet__c>();

        Master_Budget_Sheet__c budgetSheet1 = new Master_Budget_Sheet__c();
        budgetSheet1.Name = 'UnitTestSheet';
        budgetSheet1.Budget_Village__c= village.id;
        budgetSheet1.Month__c= 'March';
        
        sheetList.add(budgetSheet1);

        Master_Budget_Sheet__c budgetSheet2 = new Master_Budget_Sheet__c();
        budgetSheet2.Name = 'UnitTestSheet';
        budgetSheet2.Budget_Village__c= village.id;
        budgetSheet2.Month__c= 'January';
         

        sheetList.add(budgetSheet2);
        insert sheetList;
        
    }

    @isTest
    static void testClone(){
        setup();
        List<Master_Budget_Sheet__c> sheetList = [SELECT Id, Name FROM Master_Budget_Sheet__c WHERE Name = :'UnitTestSheet'];
        List<String> sheetIdList = new List<String>();
        for(Master_Budget_Sheet__c sheet : sheetList){
            sheetIdList.add(sheet.Id);
        }
        

        
        Test.startTest();
        CloneMasterBudgetSheetHelper.clone(sheetIdList);
        Test.stopTest();
        List<Master_Budget_Sheet__c> cloneSheetList = [SELECT Id, Name FROM Master_Budget_Sheet__c WHERE Name = :'UnitTestSheet'];
        system.assert(cloneSheetList.size() == 4); 

    }
    

    
    @isTest
    static void testCloneVFController(){
        
        setup();
        List<Master_Budget_Sheet__c> sheetList = [SELECT Id, Name FROM Master_Budget_Sheet__c WHERE Name = :'UnitTestSheet'];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(sheetList);
        stdSetController.setSelected(sheetList);
        CloneMasterBudgetSheetController ctr = new CloneMasterBudgetSheetController(stdSetController);
        
        List<List<Master_Budget_Sheet__c>> auxList = new List<List<Master_Budget_Sheet__c>>();
        auxList.add(sheetList);
        
        Test.startTest();
        CloneMasterBudgetSheetController.CloneMasterBudgetSheet(auxList);
        Test.stopTest();
        List<Master_Budget_Sheet__c> cloneSheetList = [SELECT Id, Name FROM Master_Budget_Sheet__c WHERE Name = :'UnitTestSheet'];
        system.assert(cloneSheetList.size() == 4);         
    }
    
}