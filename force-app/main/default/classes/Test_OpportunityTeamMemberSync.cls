/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_OpportunityTeamMemberSync {
	
	private static final id brandRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
	
    static testMethod void testOppTeam() {

        Opportunity opportunity = new Opportunity();
        
        //Set up Users
        //UserRole ur = [select id from UserRole where name = 'Group Value Retail'];
        UserRole ur = [select id from UserRole where name = 'Group Leasing'];
        Profile pf = [select Id from Profile where name = 'System Administrator'];
        
        // User u1 = TestDataGenerator.setupUser('Testu1', ur, pf, true, true);
        // User u2 = TestDataGenerator.setupUser('Testu2', ur, pf, true, true);
        // User u3 = TestDataGenerator.setupUser('Testu3', ur, pf, true, true);  
        
        User u1 = new User(LastName = 'Testu1',
            Alias = 'Testu1',
            Email = 'Testu1@valueretail.com',
            Username = 'Testu1@valueretail.com',
            Communitynickname = 'Testu1' + 'Nickname',
            userroleId = ur.Id,
            profileId = pf.Id,
            timezonesidkey = 'Europe/London',
            emailencodingkey = 'UTF-8',
            languagelocalekey = 'en_US',
            localesidkey = 'en_GB',
            isActive = true);
        insert u1;
            
        User u2 = new User(LastName = 'Testu2',
            Alias = 'Testu2',
            Email = 'Testu2@valueretail.com',
            Username = 'Testu2@valueretail.com',
            Communitynickname = 'Testu2' + 'Nickname',
            userroleId = ur.Id,
            profileId = pf.Id,
            timezonesidkey = 'Europe/London',
            emailencodingkey = 'UTF-8',
            languagelocalekey = 'en_US',
            localesidkey = 'en_GB',
            isActive = true);
        insert u2;

        User u3 = new User(LastName = 'Testu3',
            Alias = 'Testu3',
            Email = 'Testu3@valueretail.com',
            Username = 'Testu3@valueretail.com',
            Communitynickname = 'Testu3' + 'Nickname',
            userroleId = ur.Id,
            profileId = pf.Id,
            timezonesidkey = 'Europe/London',
            emailencodingkey = 'UTF-8',
            languagelocalekey = 'en_US',
            localesidkey = 'en_GB',
            isActive = true);
        insert u3;

// insert some custom settings



        system.runAs(u1){
            VR1_Configuration_Settings__c mycs = new VR1_Configuration_Settings__c(Brand_to_Deal_Role_Sync_Items__c= 'EU Brand Captain,Lead Negotiator,Legal Lead');
insert mycs;
            // Set up Account test data
            Account account = new Account(Name='TestA', RecordTypeId = brandRecordTypeId);
            insert account;
            
            // Set up Region        
            Region__c region1 = new Region__c(Name = 'China');
            insert region1;
            
            Region__c region2 = new Region__c(Name = 'GB');
            insert region2;
            
            
            // Set up Village test data
            Village__c village = new Village__c(Name='TestV', Std_Break_Clause__c = 'Test_Std_Break_Clause__c',
                                            Std_Fit_Out_days__c = 7, Default_Contract_Type__c = 'Lease',
                                            Std_Lease_Term_months__c = 12, Village_Code__c = 'TT', Region__c = region2.Id, CertSales_CertPeriod_Cut_Off_Days__c = 1, CertSales_Report_Sales_Grace_Period_Days__c = 1);
            insert village;
            
            //Set up Opportunity test data
            opportunity = new Opportunity(Name='TestO', StageName = 'In discussion', 
                                            AccountId = account.Id, CloseDate=system.today()+7,
                                            Village__c = village.id);
            insert opportunity;
        
        
            test.startTest();
            
            //Add team members to opportunity
            OpportunityTeamMember otm1 = new OpportunityTeamMember(UserId = u1.Id,TeamMemberRole = 'EU Brand Captain', OpportunityId = opportunity.Id);     
            insert otm1;
    
            OpportunityTeamMember otm2 = new OpportunityTeamMember(UserId = u2.Id,TeamMemberRole = 'Lead Negotiator', OpportunityId = opportunity.Id);      
            insert otm2;
    
            OpportunityTeamMember otm3 = new OpportunityTeamMember(UserId = u3.Id,TeamMemberRole = 'Legal Lead', OpportunityId = opportunity.Id);       
            insert otm3;
            
                    // lets try to add a team member
          AccountTeamMember atm1 = new AccountTeamMember(UserId = u1.Id,TeamMemberRole = 'EU Brand Captain', AccountId = account.Id);     
            insert atm1;
        
            AccountTeamMember atm2 = new AccountTeamMember(UserId = u2.Id,TeamMemberRole = 'Lead Negotiator', AccountId = account.Id);     
            insert atm2;

            AccountTeamMember atm3 = new AccountTeamMember(UserId = u3.Id,TeamMemberRole = 'Legal Lead', AccountId = account.Id);     
            insert atm3;

            test.stopTest();

             OpportunityTeamMemberSync.syncAccountRecordListPersonnel(new List<Id>{account.Id});

        }
        
        opportunity = [select Id, Lead_Negotiator_VR__c, Brand_Captain__c
                            from Opportunity where id = :opportunity.Id];
        
        u1 = [select Name from User where Id =:u1.Id];
        u2 = [select Name from User where Id =:u2.Id];
        
        system.assertEquals(opportunity.Brand_Captain__c, u1.Name);                 
        system.assertEquals(opportunity.Lead_Negotiator_VR__c, u2.Name);                    




    }
    
    static testMethod void testOppRole() {

  UserRole ur = [select id from UserRole where name = 'Group Leasing'];
        Profile pf = [select Id from Profile where name = 'System Administrator'];

        User u1 = new User(LastName = 'Testu1',
            Alias = 'Testu1',
            Email = 'Testu1@valueretail.com',
            Username = 'Testu1@valueretail.com',
            Communitynickname = 'Testu1' + 'Nickname',
            userroleId = ur.Id,
            profileId = pf.Id,
            timezonesidkey = 'Europe/London',
            emailencodingkey = 'UTF-8',
            languagelocalekey = 'en_US',
            localesidkey = 'en_GB',
            isActive = true);
        insert u1;
      system.runAs(u1){
        // Set up Account test data
        Account account = new Account(Name='TestA', RecordTypeId=brandRecordTypeId);
        insert account;
        
        // Set up Village test data
        Village__c village = new Village__c(Name='TestV', Std_Break_Clause__c = 'Test_Std_Break_Clause__c',
                                        Std_Fit_Out_days__c = 7, Default_Contract_Type__c = 'Lease',
                                        Std_Lease_Term_months__c = 12, Village_Code__c = 'TT', CertSales_CertPeriod_Cut_Off_Days__c = 1, CertSales_Report_Sales_Grace_Period_Days__c = 1 );
        insert village;
        
        //Set up Opportunity test data
        Opportunity opportunity = new Opportunity(Name='TestO', StageName = 'In discussion', 
                                        AccountId = account.Id, CloseDate=system.today()+7,
                                        Village__c = village.id);
        insert opportunity;                 
                                    
        // Set up Contact test data
        Contact contact = new Contact(FirstName = 'c1', LastName= 'Test', AccountId = account.id, email = 'test@contact.com');
        insert contact;
        
        OpportunityContactRole ocr = new OpportunityContactRole(isPrimary=true, ContactId=contact.id, OpportunityId=opportunity.Id);
        insert ocr;
        
        // lets try to add a team member
          AccountTeamMember atm1 = new AccountTeamMember(UserId = u1.Id,TeamMemberRole = 'EU Brand Captain', AccountId = account.Id);     
            insert atm1;
        
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);

        OpportunityTeamMemberSync testController = new OpportunityTeamMemberSync(sc);
        
        testController.triggerUpdateOppBrandLeadNegotiator();

 OpportunityTeamMemberSync.syncAccountRecordListPersonnel(new List<Id>{account.Id});

        opportunity = [select Id, Lead_Negotiator_Brand__c
                            from Opportunity where id = :opportunity.Id];
        
        contact = [select Name from Contact where FirstName='c1' and LastName='Test'];
        
        system.assertEquals(opportunity.Lead_Negotiator_Brand__c, contact.Name);        
        
        string sUrl = testController.getPageURL();

        system.assert(sUrl.length() > 0);
        
        // Remove primary flag and check Lead_Negotiator_Brand__c value is cleared on opportunity
        ocr.IsPrimary = false;
        update ocr;
        testController.triggerUpdateOppBrandLeadNegotiator();

        opportunity = [select Id, Lead_Negotiator_Brand__c
                            from Opportunity where id = :opportunity.Id];       
        
        system.assert(string.isBlank(opportunity.Lead_Negotiator_Brand__c));
        
        // Test opportunity with no roles
        delete ocr;
        testController.triggerUpdateOppBrandLeadNegotiator();
        
        // lets also test from the accounts

        

        test.stopTest();        
        
        opportunity = [select Id, Lead_Negotiator_Brand__c
                            from Opportunity where id = :opportunity.Id];       
        
        system.assert(string.isBlank(opportunity.Lead_Negotiator_Brand__c));
        
                }

            
    }

/*
    static testMethod void testOppRole() {

  // Set up Account test data
        Account account = new Account(Name='TestA', RecordTypeId=brandRecordTypeId);
        insert account;
        
        // Set up Village test data
        Village__c village = new Village__c(Name='TestV', Std_Break_Clause__c = 'Test_Std_Break_Clause__c',
                                        Std_Fit_Out_days__c = 7, Default_Contract_Type__c = 'Lease',
                                        Std_Lease_Term_months__c = 12, Village_Code__c = 'TT');
        insert village;
        
        //Set up Opportunity test data
        Opportunity opportunity = new Opportunity(Name='TestO', StageName = 'In discussion', 
                                        AccountId = account.Id, CloseDate=system.today()+7,
                                        Village__c = village.id);
        insert opportunity;                 
                                    
        // Set up Contact test data
        Contact contact = new Contact(FirstName = 'c1', LastName= 'Test', AccountId = account.id, email = 'test@contact.com');
        insert contact;
        
        OpportunityContactRole ocr = new OpportunityContactRole(isPrimary=true, ContactId=contact.id, OpportunityId=opportunity.Id);
        insert ocr;


        syncAccountRecordPersonnel


        // sync account too
        OpportunityTeamMemberSync.syncAccountPersonnel(String.valueOf(account.Id),new List<Id>());
    }*/
}