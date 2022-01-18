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
private class AccountTriggerHelperTest {
	
	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Village__c village = new Village__c();
	private static Opportunity opportunity = new Opportunity();
	
    
    static void setupData(){
    
		account = TestData_Account.setupBrandAccount(1, true);
		contact = TestData_Contact.setupBrandContact('A',account, true);	
					
 		//create village 1
 		village = new Village__c();
 		village.Name = 'TestVillage1'; 		
 		village.Village_Code__c = 'AA';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
 		insert village;
		village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];   	

		opportunity = new Opportunity(name = 'TestOpp', Village__c = village.Id, AccountId = account.id, 
											CloseDate = system.today().addDays(1), StageName = 'Pipeline');
		insert opportunity;		
    }
    
    static testMethod void unitTest() {
    	
    	setupData();

    	string testName = 'Changed';
    	// check opportunity and vp names do not contain testName string
    	opportunity = [select name from Opportunity where id = :opportunity.Id];
    	Village_Presence__c vp = [select name,status__c from Village_Presence__c 
    								where Brand__c = :account.Id and Village__c = :village.Id];
        //system.debug('vp unittest1 ' + vp.status__c);
    	
    	system.assertEquals(opportunity.Name.indexOf(testName), -1);
    	system.assertEquals(vp.Name.indexOf(testName), -1);
    	
    	//update account name
    	account.name = testName;
    	OpportunityTriggerHelper.hasRun = false;
    	update account;
    	
    	// check opportunity and vp names now do contain testName string
    	opportunity = [select name from Opportunity where id = :opportunity.Id];
    	vp = [select name from Village_Presence__c 
    								where Brand__c = :account.Id and Village__c = :village.Id];
   	
       	system.assert(opportunity.Name.indexOf(testName) > -1);
    	system.assert(vp.Name.indexOf(testName) > -1); 	
    	    
    
    }

    static testMethod void TestAssignmentTypeSetting() {
        
        setupData();
        account = [Select ID, Name, Assignment_Type__c FROM Account WHERE ID = :account.Id];
        // check that the Assignment type is set
        System.assertEquals(account.Assignment_Type__c, 'No Village', 'Assignment type should be No Village');

        string testName = 'Changed2';
        // check opportunity and vp names do not contain testName string
        opportunity = [select name from Opportunity where id = :opportunity.Id];
        Village_Presence__c vp = [select name,status__c from Village_Presence__c 
                                    where Brand__c = :account.Id and Village__c = :village.Id];
        
        system.assertEquals(opportunity.Name.indexOf(testName), -1);
        system.assertEquals(vp.Name.indexOf(testName), -1);
        
        //update account name
        account.name = testName;
        OpportunityTriggerHelper.hasRun = false;
        update account;
        
        // check opportunity and vp names now do contain testName string
        opportunity = [select name from Opportunity where id = :opportunity.Id];
        vp = [select name, status__c from Village_Presence__c 
                                    where Brand__c = :account.Id and Village__c = :village.Id];
        //system.debug('vp unittest2 ' + vp.status__c );
        vp.status__c = 'Trading';
        update vp;
    
        system.assert(opportunity.Name.indexOf(testName) > -1);
        system.assert(vp.Name.indexOf(testName) > -1);  
        // after adding 1 Village Presence, assignment type should now be 'Local'
        account = [Select ID, Name, Assignment_Type__c,GRS_Captain__c FROM Account WHERE ID = :account.Id];
        System.assertEquals('Local Village', account.Assignment_Type__c, 'Assignment type should be Local');
    
        // and then, adding a GRS captain, should make it a 'GRS' assignment type

        account.GRS_Captain__c = UserInfo.getUserId();
        update account;

        account = [Select ID, Name, Assignment_Type__c,GRS_Captain__c FROM Account WHERE ID = :account.Id];
        System.assertEquals(account.Assignment_Type__c, 'Group Retail', 'Assignment type should be GRS');
    }

    @isTest
    static void checkForPrimaryVillageTest(){
        Account testAccount = new Account(Name = 'Test Acc');
        INSERT testAccount;

        List<Account> accList = new List<Account>{testAccount};

        Test.startTest();
            AccountTriggerHelper.checkForPrimaryVillage(accList);
        Test.stopTest();
    }
    
    @isTest
    static void checkDuplicateRuleRecordTypeTest_Success(){
        Id vipGuestRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('VIP_Guest').getRecordTypeId();

        List<Account> accList = new List<Account>();
        accList.add(new Account(FirstName = 'Acc 1', LastName = 'Test', RecordTypeId = vipGuestRecordTypeId, PersonMobilePhone = '123456789'));
        accList.add(new Account(FirstName = 'Acc 2', LastName = 'Test', RecordTypeId = vipGuestRecordTypeId, PersonMobilePhone = '123456789'));
        insert accList;
        
        Account masterAcc = accList[0];
        Account mergedAcc = accList[1];
        
        Test.startTest();
        try {
            merge masterAcc mergedAcc;
        } catch (Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }
        Test.stopTest();
        
        accList = [SELECT Id FROM Account WHERE Id IN :accList];
        system.assertEquals(1, accList.size());
    }
    
    @isTest
    static void checkDuplicateRuleRecordTypeTest_Error(){
        Id vipGuestRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('VIP_Guest').getRecordTypeId();
        Id guestRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Guest').getRecordTypeId();

        List<Account> accList = new List<Account>();
        accList.add(new Account(FirstName = 'Acc 1', LastName = 'Test', RecordTypeId = vipGuestRecordTypeId, PersonMobilePhone = '123456789'));
        accList.add(new Account(FirstName = 'Acc 2', LastName = 'Test', RecordTypeId = guestRecordTypeId, PersonMobilePhone = '123456789', Customer_GUID__c = '1234'));
        insert accList;
        
        Account masterAcc = accList[0];
        Account mergedAcc = accList[1];
        
        Test.startTest();
        try {
            merge masterAcc mergedAcc;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('CustomDuplicateRuleException'));
        }
        Test.stopTest();
        
        accList = [SELECT Id FROM Account WHERE Id IN :accList];
        system.assertEquals(2, accList.size());
    }
}