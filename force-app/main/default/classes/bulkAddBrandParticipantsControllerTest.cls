@isTest
private class bulkAddBrandParticipantsControllerTest {

    
    static final id GROUP_RECTYPE = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByName.get('TBVSC Brand Campaign').RecordTypeId;
    
    static Marketing_Activity__c marketingActivity = null;
    static Marketing_Campaign__c marketingCampaignGroup = null;
    static Marketing_Campaign__c marketingCampaignVillage = null;
    static Village__c village = new Village__c();
    static Account accA = null;
    static Account accB = null;
    static Account accC = null;
    static Account accD = null;
    static Account account;
    
    static Village_Presence__c vpA = null;
    static Village_Presence__c vpB = null;
    static Village_Presence__c vpC = null;
    static Village_Presence__c vpD = null;
     
    static list<Participating_Brand__c> participatingBrandList = null;
    
    @testSetup static void setupData(){
    
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
        
        account = TestData_Account.setupTourismAccount(1, true);
        
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

        accA = TestDataGenerator.setupB2BAccount(1, true);
        accB = TestDataGenerator.setupB2BAccount(2, true);
        accC = TestDataGenerator.setupB2BAccount(3, true);
        accD = TestDataGenerator.setupB2BAccount(4, true);
        
        marketingCampaignGroup = new Marketing_Campaign__c();
        marketingCampaignGroup.Campaign_Level__c = 'Theme';
        marketingCampaignGroup.Start_Date__c = system.today();
        marketingCampaignGroup.End_Date__c = system.today().addDays(30);
        marketingCampaignGroup.Name = 'Test Group Campaign';
        marketingCampaignGroup.RecordTypeId = GROUP_RECTYPE;
        insert marketingCampaignGroup;

        village = new Village__c();
        village.Name = 'TestVillage';
        village.Village_Code__c = 'TV';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        insert village;
        
        Unit__c u = new Unit__c();
        u.name = 'Test';
        u.Suite_ID__c = '2';
        u.Phase_ID__c = 'BV1';
        u.village__c = village.Id;
        u.Size_GEA__c = 43;
        u.Unit_Status__c = 'Available';
        u.Unit_Designation__c = 'Retail';
        insert u;
        
        list<Village_Presence__c> vpList = new list<Village_Presence__c>();
        vpA = VillagePresenceUtilities.createVillagePresence(accA.Id, 'TV');
        //vpA.Status__c = 'Trading';
        vpA.Unit__c = u.id;
        vpList.add(vpA);
        vpB = VillagePresenceUtilities.createVillagePresence(accB.Id, 'TV');
        //vpB.Status__c = 'Trading';
        vpB.Unit__c = u.id;
        vpList.add(vpB);
        vpC = VillagePresenceUtilities.createVillagePresence(accC.Id, 'TV');
        //vpC.Status__c = 'Trading';
        vpC.Unit__c = u.id;
        vpList.add(vpC);
        vpD = VillagePresenceUtilities.createVillagePresence(accD.Id, 'TV');
        //vpD.Status__c = 'Trading';
        vpD.Unit__c = u.id;
        vpList.add(vpD);
        
        update vpList;
        
        for(Village_Presence__c vp : vpList){
            vp.status__c = 'Trading';
        }
        update vpList;
        
        
        marketingCampaignVillage = new Marketing_Campaign__c();
        marketingCampaignVillage.Start_Date__c = system.today();
        marketingCampaignVillage.End_Date__c = system.today().addDays(30);
        marketingCampaignVillage.Name = 'Test Village Campaign';
        marketingCampaignVillage.Parent_Marketing_Campaign__c = marketingCampaignGroup.Id;
        marketingCampaignVillage.Village__c = village.Id;
        insert marketingCampaignVillage;                


        marketingActivity = new Marketing_Activity__c();
        
        marketingActivity.name = 'Test Marketing Activity';
        marketingActivity.Start_Date__c = system.today().toStartOfWeek();
        marketingActivity.End_Date__c = system.today().toStartOfWeek().addDays(14); 
        marketingActivity.Marketing_Campaign__c = marketingCampaignVillage.Id;
        marketingActivity.Responsible_Person__c = system.userInfo.getUserId();
        marketingActivity.Partner__c = account.Id;
        marketingActivity.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
        insert marketingActivity;
        }
    }
    
  
    static testMethod void unitTest() {
           
        //setupData();

        Marketing_Activity__c marketingActivity = [SELECT id, Name FROM Marketing_Activity__c Where Name = 'Test Marketing Activity'];  
    
        list< Participating_Brand__c> pbList = new list< Participating_Brand__c>();     
        PageReference pg = new PageReference('/apex/bulkAddBrandParticipants');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);               
        
        test.startTest();
            bulkAddBrandParticipantsController controller  = new bulkAddBrandParticipantsController();
            
            // check we have 4 records available for selection
            system.assertEquals(4, controller.ParticipantBrandList.size());
            
            // select first item in list
            controller.ParticipantBrandList[0].selected = true;                     
            pg = controller.save();
            
            //check 1 item selected
            system.assertEquals(1, controller.SelectedParticipantBrands.size());
            
            // Check against object record
            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(1, pbList.size());
            system.assertEquals (pbList[0].Village_Presence__c, controller.SelectedParticipantBrands[0]. Village_Presence__c);
            
            controller  = new bulkAddBrandParticipantsController();
            // deselect 1st item
            controller.ParticipantBrandList[0].selected = false;
            controller.ParticipantBrandList[1].selected = true;
            controller.ParticipantBrandList[2].selected = true;
            controller.ParticipantBrandList[3].selected = true;                     
            pg = controller.save();

            //check 3 items selected
            system.assertEquals(3, controller.SelectedParticipantBrands.size());
            
            // Check against object record
            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(4, pbList.size());
                        
            controller  = new bulkAddBrandParticipantsController();
            // deselect all items
            controller.allSelected = false;
            pg = controller.checkAll();
            pg = controller.save();
            
            //check 0 items selected
            system.assertEquals(0, controller.SelectedParticipantBrands.size());
            
            // Check against object record, 0 items selected
            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(4, pbList.size());                      
            
            
            // for coverage, call methods to populate picklists and cancel
            
            list<selectoption> statusList = controller.getStatuses();
            system.assert(statusList != null);

            list<selectoption> discountList = controller.getDiscounts();
            system.assert(discountList != null);
            
            list<selectoption> minimumPurchaseList = controller.getMinimumPurchases();
            system.assert(minimumPurchaseList != null);

            list<selectoption> giftWithPurchaseList = controller.getGiftWithPurchases();
            system.assert(giftWithPurchaseList != null);
            
            pg = controller.cancel();           
            
        
        test.stopTest();
        
    }
    
    static testMethod void testDelete(){

        //setupData();

        Marketing_Activity__c marketingActivity = [SELECT id, Name FROM Marketing_Activity__c Where Name = 'Test Marketing Activity'];  
    
        list< Participating_Brand__c> pbList = new list< Participating_Brand__c>();     
        PageReference pg = new PageReference('/apex/bulkAddBrandParticipants');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);               
        
        test.startTest();

        bulkAddBrandParticipantsController controller  = new bulkAddBrandParticipantsController();

            controller.ParticipantBrandList[0].selected = true;
            controller.ParticipantBrandList[1].selected = true;                     
            pg = controller.save();

            
            //check 1 item selected
            system.assertEquals(2, controller.SelectedParticipantBrands.size());
            
            // Check against object record
            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(2, pbList.size());

            controller = new bulkAddBrandParticipantsController();
            
            controller.ParticipantBrandList[0].selected = true;
            controller.ParticipantBrandList[1].selected = false;
            pg = controller.deleteRecord();
            // Check against object record
            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(1, pbList.size());

            controller = new bulkAddBrandParticipantsController();
            // save all an then delete all

            controller.allSelected = true;
            pg = controller.checkAll();
            pg = controller.save();

            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(4, pbList.size());

            controller = new bulkAddBrandParticipantsController();

            controller.allSelected = true;
            pg = controller.checkAll();
            pg = controller.deleteRecord();

            pbList = [select Village_Presence__c from Participating_Brand__c where Marketing_Activity__c = :marketingActivity.Id];
            system.assertEquals(0, pbList.size());

    }
    
}