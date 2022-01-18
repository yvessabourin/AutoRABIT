@isTest
private class MarketingSplitUtilitiesTest {

    static Marketing_Activity__c marketingActivity = null;
    static Marketing_Campaign__c marketingCampaignGroup = null;
    static Marketing_Campaign__c marketingCampaignVillage = null;
    static Village__c village = new Village__c(); 
    static final id GROUP_RECTYPE = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByName.get('TBVSC Brand Campaign').RecordTypeId;
    static Account account;
    
    static void setupData(){
        
        account = TestData_Account.setupTourismAccount(1, true);
        
        marketingCampaignGroup = new Marketing_Campaign__c();
        marketingCampaignGroup.Start_Date__c = system.today();
        marketingCampaignGroup.End_Date__c = system.today().addDays(30);
        marketingCampaignGroup.Name = 'Test Group Campaign';
        marketingCampaignGroup.Campaign_Level__c = 'Theme';
        marketingCampaignGroup.RecordTypeId = GROUP_RECTYPE;
        insert marketingCampaignGroup;

        village = new Village__c();
        village.Name = 'TestVillage';
        village.Village_Code__c = 'TV';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert village;
        
        marketingCampaignVillage = new Marketing_Campaign__c();
        marketingCampaignVillage.Start_Date__c = system.today();
        marketingCampaignVillage.End_Date__c = system.today().addDays(30);
        marketingCampaignVillage.Name = 'Test Village Campaign';
        marketingCampaignVillage.Campaign_Level__c = 'Theme';
        marketingCampaignVillage.Parent_Marketing_Campaign__c = marketingCampaignGroup.Id;
        marketingCampaignVillage.Village__c = village.Id;
        
        insert marketingCampaignVillage;               
        
    }
    

    static testMethod void unitTest() {
        
        setupData();
        
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
        
        marketingActivity = new Marketing_Activity__c();
        
        marketingActivity.name = 'Test Marketing Activity';
        marketingActivity.Start_Date__c = system.today().toStartOfWeek();
        marketingActivity.End_Date__c = system.today().toStartOfWeek().addDays(14); //15 days
        marketingActivity.Expected_Footfall__c = 1500; // therefore 100/day
        marketingActivity.Marketing_Campaign__c = marketingCampaignVillage.Id;
        marketingActivity.Responsible_Person__c = system.userInfo.getUserId();
        marketingActivity.Split_Type__c = 'Weekly';
        marketingActivity.Partner__c = account.Id;
        //marketingActivity.Creative_Agency_Access_To_Salesforce__c = usr1.id;
        insert marketingActivity;
        
        list<Marketing_Activity_Split__c> splitsList = [select Date__c, Expected_Footfall__c, Expected_Sales__c 
                                                        from Marketing_Activity_Split__c
                                                        where Marketing_Activity__r.Id = :marketingActivity.Id
                                                        order by Date__c asc];
        
        // check split records                                              
        system.assertEquals(splitsList.size(), 3);
        system.assertEquals(splitsList[0].Expected_Footfall__c, 700);
        system.assertEquals(splitsList[1].Expected_Footfall__c, 700);
        system.assertEquals(splitsList[2].Expected_Footfall__c, 100);
        system.assertEquals(splitsList[0].Expected_Sales__c, 0);
        system.assertEquals(splitsList[1].Expected_Sales__c, 0);
        system.assertEquals(splitsList[2].Expected_Sales__c, 0);
        system.assertEquals(splitsList[0].Date__c, system.today().toStartOfWeek());
        system.assertEquals(splitsList[1].Date__c, system.today().toStartOfWeek().addDays(7));
        system.assertEquals(splitsList[2].Date__c, system.today().toStartOfWeek().addDays(14));                                              
        
        // make amendment to marketing activity footfall figure
        marketingActivity.Expected_Footfall__c = 3000; // therefore 200/day
        update marketingActivity;

        splitsList = [select Date__c, Expected_Footfall__c, Expected_Sales__c 
                                                        from Marketing_Activity_Split__c
                                                        where Marketing_Activity__r.Id = :marketingActivity.Id
                                                        order by Date__c asc];
        
        // check split records                                              
        system.assertEquals(splitsList[0].Expected_Footfall__c, 1400);
        system.assertEquals(splitsList[1].Expected_Footfall__c, 1400);
        system.assertEquals(splitsList[2].Expected_Footfall__c, 200);       


        // make amendment to marketing activity date figures - so covers less than a week
        marketingActivity.Start_Date__c = system.today().toStartOfWeek();
        marketingActivity.End_Date__c = system.today().toStartOfWeek().addDays(3); 
        update marketingActivity;

        splitsList = [select Date__c, Expected_Footfall__c, Expected_Sales__c 
                                                        from Marketing_Activity_Split__c
                                                        where Marketing_Activity__r.Id = :marketingActivity.Id
                                                        order by Date__c asc];
        
         // check split records                                             
        system.assertEquals(splitsList.size(), 1);                                              
        system.assertEquals(splitsList[0].Expected_Footfall__c, 3000);
        system.assertEquals(splitsList[0].Date__c, marketingActivity.Start_Date__c);
        system.assertEquals(splitsList[0].Expected_sales__c, 0);            

    }
}