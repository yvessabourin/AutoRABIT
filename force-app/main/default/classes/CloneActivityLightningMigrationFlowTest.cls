@isTest
public class CloneActivityLightningMigrationFlowTest {
        @testSetup
   static void setup(){
 Id recordTypeId = Schema.SObjectType.Marketing_Activity__c.getRecordTypeInfosByName().get('General Activity').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'userTest', Email='testuser@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='testUser@test.com.SMP');

        insert u;
        
        Profile pf = [select Id from Profile where name = 'Tourism'];
        
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


        Marketing_Activity__c activity = new Marketing_Activity__c();
        activity.Name = 'testActivity';
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
        activity.Creative_Agency_Access_To_Salesforce__c = communityUser.id;

        insert activity;
        
    }
    
        @isTest 
    static void testClone() {
        
        List<Marketing_Activity__c> mccLis = [SELECT Id, Name, Marketing_Campaign__c FROM Marketing_Activity__c WHERE Name =:'testActivity'];
          ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(mccLis);
             stdSetController.setSelected(mccLis);
        CloneActivityLightningMigrationFlow ctr = new CloneActivityLightningMigrationFlow(stdSetController);
    
        List<List<Marketing_Activity__c>> mkaList = new List<List<Marketing_Activity__c>>();
          mkaList.add(mccLis);
        Test.startTest();
        CloneActivityLightningMigrationFlow.cloneActivityFlow(mkaList);
          Test.stopTest();
      
    }
    

}