@IsTest
public class MultipleParticipatingBrands_Test {
    
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
            
            Account account = TestData_Account.setupTourismAccount(1, true);
            
            Profile pf = [select Id from Profile where name = 'Tourism'];
            
            Id brandRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordTypeId;
            brand.Name = 'Brand 1';
            insert brand;
            
            Id brandContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Brand Contact').RecordTypeId;
            
            Contact communityContact = new Contact();
            communityContact.RecordTypeId = brandContactRecordTypeId;
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
            
            Account accA = TestDataGenerator.setupB2BAccount(1, true);
            Account accB = TestDataGenerator.setupB2BAccount(2, true);
            Account accC = TestDataGenerator.setupB2BAccount(3, true);
            Account accD = TestDataGenerator.setupB2BAccount(4, true);
            
            Marketing_Campaign__c marketingCampaignGroup = new Marketing_Campaign__c();
            marketingCampaignGroup.Campaign_Level__c = 'Theme';
            marketingCampaignGroup.Start_Date__c = system.today();
            marketingCampaignGroup.End_Date__c = system.today().addDays(30);
            marketingCampaignGroup.Name = 'Test Group Campaign';
            marketingCampaignGroup.RecordTypeId = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByName.get('TBVSC Brand Campaign').RecordTypeId;
            insert marketingCampaignGroup;
            
            Village__c village = new Village__c();
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
            Village_Presence__c vpA = VillagePresenceUtilities.createVillagePresence(accA.Id, 'TV');
            vpA.Unit__c = u.id;
            vpList.add(vpA);
            Village_Presence__c vpB = VillagePresenceUtilities.createVillagePresence(accB.Id, 'TV');
            vpB.Unit__c = u.id;
            vpList.add(vpB);
            Village_Presence__c vpC = VillagePresenceUtilities.createVillagePresence(accC.Id, 'TV');
            vpC.Unit__c = u.id;
            vpList.add(vpC);
            Village_Presence__c vpD = VillagePresenceUtilities.createVillagePresence(accD.Id, 'TV');
            vpD.Unit__c = u.id;
            vpList.add(vpD);
            
            update vpList;
            
            for(Village_Presence__c vp : vpList){
                vp.status__c = 'Trading';
            }
            update vpList;
            
            
            Marketing_Campaign__c marketingCampaignVillage = new Marketing_Campaign__c();
            marketingCampaignVillage.Start_Date__c = system.today();
            marketingCampaignVillage.End_Date__c = system.today().addDays(30);
            marketingCampaignVillage.Name = 'Test Village Campaign';
            marketingCampaignVillage.Parent_Marketing_Campaign__c = marketingCampaignGroup.Id;
            marketingCampaignVillage.Village__c = village.Id;
            insert marketingCampaignVillage;                
            
            
            Marketing_Activity__c marketingActivity = new Marketing_Activity__c();
            
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
    
    static testMethod void testGetMarketingActivityName() {
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        Test.startTest();
        String result = MultipleParticipatingBrandsController.getMarketingActivityName(markAct.Id);
        Test.stopTest();
        system.assertEquals(markAct.Name, result);
    }
    
    static testMethod void testGetPicklistValues() {
        String objType = 'Account';
        String fieldName = 'Type';
        Test.startTest();
        Map<String, String> result = MultipleParticipatingBrandsController.getPicklistValues(objType, fieldName, true);
        Test.stopTest();
        system.assertEquals(Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues().size() + 1, result.size());
    }
    
    static testMethod void testSavePotentialBrandsSuccess1(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        Village_Presence__c vilPres = [SELECT Id, Name, Brand__c, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.Name,
                                       Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                                       Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, Status__c
                                       FROM Village_Presence__c LIMIT 1];
        
        MultipleParticipatingBrandsController.ParticipatingBrandWrapper pbw = new MultipleParticipatingBrandsController.ParticipatingBrandWrapper(vilPres);
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> pbwList = new List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper>{pbw};
            
            String partBrandWrapperListJSON = JSON.serialize(pbwList);
        
        Test.startTest();
        String result = MultipleParticipatingBrandsController.savePotentialBrands(markAct.Id, partBrandWrapperListJSON);
        Test.stopTest();
        List<Participating_Brand__c> partBrands = [SELECT Id FROM Participating_Brand__c WHERE Marketing_Activity__c = :markAct.Id];
        
        system.assertEquals(null, result);
        system.assertEquals(1, partBrands.size());
    }
    
    static testMethod void testSavePotentialBrandsSuccess2(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        List<Village_Presence__c> vilPres = [SELECT Id, Name, Brand__c, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.Name,
                                             Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                                             Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, Status__c
                                             FROM Village_Presence__c LIMIT 2];
        
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> pbwList = new List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper>{};
            
            for(Village_Presence__c vp: vilPres){
                MultipleParticipatingBrandsController.ParticipatingBrandWrapper pbw = new MultipleParticipatingBrandsController.ParticipatingBrandWrapper(vp);
                pbwList.add(pbw);
            }
        String partBrandWrapperListJSON = JSON.serialize(pbwList);
        MultipleParticipatingBrandsController.savePotentialBrands(markAct.Id, partBrandWrapperListJSON);
        
        pbwList.remove(0);
        
        Test.startTest();
        partBrandWrapperListJSON = JSON.serialize(pbwList);
        String result = MultipleParticipatingBrandsController.savePotentialBrands(markAct.Id, partBrandWrapperListJSON);
        Test.stopTest();
        
        List<Participating_Brand__c> partBrands = [SELECT Id FROM Participating_Brand__c WHERE Marketing_Activity__c = :markAct.Id];
        
        system.assertEquals(null, result);
        system.assertEquals(1, partBrands.size());
    }
    
    static testMethod void testGetPotentialParticipatingBrands1(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        
        Test.startTest();
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> result = MultipleParticipatingBrandsController.getPotentialParticipatingBrands(markAct.Id);
        Test.stopTest();
        
        system.assertNotEquals(0, result.size());
    }
    
    static testMethod void testGetPotentialParticipatingBrands2(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        List<Village_Presence__c> vilPres = [SELECT Id, Name, Brand__c, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.Name,
                                             Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                                             Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, Status__c
                                             FROM Village_Presence__c LIMIT 2];
        
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> pbwList = new List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper>{};
            
            for(Village_Presence__c vp: vilPres){
                MultipleParticipatingBrandsController.ParticipatingBrandWrapper pbw = new MultipleParticipatingBrandsController.ParticipatingBrandWrapper(vp);
                pbwList.add(pbw);
            }
        
        String partBrandWrapperListJSON = JSON.serialize(pbwList);
        MultipleParticipatingBrandsController.savePotentialBrands(markAct.Id, partBrandWrapperListJSON);
        
        Test.startTest();
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> result = MultipleParticipatingBrandsController.getPotentialParticipatingBrands(markAct.Id);
        Test.stopTest();
        
        system.assertNotEquals(0, result.size());
    }
    
    static testMethod void testGetPotentialParticipatingBrandsError(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        Set<String> errorStatuses = new Set<String>{'Trading','Deal Pending'};
            Map<String, String> vilPresStatus = MultipleParticipatingBrandsController.getPicklistValues('Village_Presence__c', 'Status__c', false);
        String errorStatus;
        for(String key: vilPresStatus.keySet()){
            String value = vilPresStatus.get(key);
            if(!errorStatuses.contains(value)){
                errorStatus = value;
                break;
            }
        }
        List<Village_Presence__c> vilPres = [SELECT Id, Name, Status__c FROM Village_Presence__c WHERE Status__c IN :errorStatuses];
        for(Village_Presence__c vp: vilPres){
            vp.Status__c = errorStatus;
        }
        update vilPres;
        
        Boolean hasError = false;
        
        Test.startTest();
        try{
            List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> result = MultipleParticipatingBrandsController.getPotentialParticipatingBrands(markAct.Id);
        }
        catch(Exception ex){
            hasError = true;
        }
        
        Test.stopTest();
        
        system.assertEquals(true, hasError);
    }
    
    static testMethod void testGetParticipatingBrands(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        Village_Presence__c vilPres = [SELECT Id, Name, Brand__c, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.Name,
                                       Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                                       Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, Status__c
                                       FROM Village_Presence__c LIMIT 1];
        
        MultipleParticipatingBrandsController.ParticipatingBrandWrapper pbw = new MultipleParticipatingBrandsController.ParticipatingBrandWrapper(vilPres);
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> pbwList = new List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper>{pbw};
            
            MultipleParticipatingBrandsController.savePotentialBrands(markAct.Id,  JSON.serialize(pbwList));
        
        Test.startTest();
        List<Participating_Brand__c> result = MultipleParticipatingBrandsController.getParticipatingBrands(markAct.Id);
        Test.stopTest();
        List<Participating_Brand__c> partBrandsList = [SELECT Id FROM Participating_Brand__c WHERE Marketing_Activity__c = :markAct.Id];
        system.assertEquals(result.size(), partBrandsList.size());
        
    }
    
    static testMethod void testUpdateParticipantBrands(){
        Marketing_Activity__c markAct = [SELECT Id, Name FROM Marketing_Activity__c LIMIT 1];
        List<Village_Presence__c> vilPres = [SELECT Id, Name, Brand__c, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.Name,
                                             Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                                             Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, Status__c
                                             FROM Village_Presence__c LIMIT 2];
        
        List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper> pbwList = new List<MultipleParticipatingBrandsController.ParticipatingBrandWrapper>{};
            
            for(Village_Presence__c vp: vilPres){
                MultipleParticipatingBrandsController.ParticipatingBrandWrapper pbw = new MultipleParticipatingBrandsController.ParticipatingBrandWrapper(vp);
                pbwList.add(pbw);
            }
        String partBrandWrapperListJSON = JSON.serialize(pbwList);
        MultipleParticipatingBrandsController.savePotentialBrands(markAct.Id, partBrandWrapperListJSON);
        
        List<Participating_Brand__c> partBrandsList = [SELECT Id, Village_Presence__c, Village_Presence__r.Name, Village_Presence__r.Brand__r.Name, Discount__c, Discount_Percentage__c, Minimum_Purchase__c, Minimum_Purchase_Amount__c,
                                                       Gift_With_Purchase__c, Gift_With_Purchase_Type__c, Feature_Details__c, Status__c, Participating_Brand_Link__c    
                                                       FROM Participating_Brand__c 
                                                       WHERE Marketing_Activity__c = :markAct.Id
                                                       ORDER BY Village_Presence__r.Brand__r.Name];  
        
        Map<String, String> statusChangedRows = new Map<String, String>();
        for(Participating_Brand__c pb: partBrandsList){
            pb.Discount__c = 'Yes';
            pb.Minimum_Purchase__c = 'Yes';
            pb.Gift_With_Purchase__c = 'Yes';
            statusChangedRows.put(pb.Id, pb.Status__c);
        }
        partBrandsList.remove(0);

        Test.startTest();
        partBrandWrapperListJSON = JSON.serialize(pbwList);
        String result = MultipleParticipatingBrandsController.updateParticipantBrands(partBrandsList, statusChangedRows);
        Test.stopTest();
        
        List<Participating_Brand__c> partBrands = [SELECT Id FROM Participating_Brand__c WHERE Marketing_Activity__c = :markAct.Id];
        
        system.assertEquals(null, result);
        system.assertEquals(pbwList.size(), partBrands.size());
    }
    
}