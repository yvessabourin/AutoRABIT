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
@isTest(seeAllData=true)
private class TenancyUtilitiesTest {

	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Opportunity opportunity = new Opportunity();
	private static Village__c village = new Village__c();
	private static User adminUsr = new User();
	private static User usr = new user();
    
    static void setupData(){
    	
    	// Create test admin user
 		adminUsr = TestData_User.setupAdminUser(true);
 		
 		// Create test normal user
		usr = TestData_User.setupUser('BillyBones', null, 'Standard User', true, true); 
			
		system.runAs(usr){
			account = TestData_Account.setupBrandAccount(1, true);
			contact = TestData_Contact.setupContact('A',account, true);	
						
	 		village = new Village__c();
	 		village.Name = 'TestVillage';
	 		village.Village_Code__c = 'AA';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
	 		insert village;
			village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];
			
			//link opportunity to village
			opportunity = new Opportunity(name = 'TestOpp', Village__c = village.Id, AccountId = account.id, CloseDate = system.today().addDays(1), StageName = 'Pipeline');
			insert opportunity;	
	 
	 		//create village with no opportunity
	 		village = new Village__c();
	 		village.Name = 'TestVillage2'; 		
	 		village.Village_Code__c = 'BB';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
	 		insert village;
			village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1];
		}   	
    }
    
    
    static testMethod void testSingleSearch() {
        
        setupData();
                
        test.startTest();
        	// search for village where opp exists
        	village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];	
        	Opportunity opp = TenancyUtilities.getTenancy(village.Name, account.Name);
        	
        	// found
        	system.assertEquals(opp.Id, opportunity.Id);
        	
        	// search for village with no opp

        	village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1];	
        	opp = TenancyUtilities.getTenancy(village.Name, account.Name); 
        	
        	// not found
        	system.assertEquals(opp, null);
        	       
        test.stopTest();
        
        
    }
    
    static testMethod void testMapSearch(){
    	
    	setupData();
    	
    	map<string, list<string>> brandsVillages = new map<string, list<string>> ();
    	
    	list<string> villages = new list<string>();
    	villages.add('AA');
    	villages.add('BB');
    	
    	brandsVillages.put(account.Name, villages);
    	
    	test.startTest();
    		
    		map<string, map<String, Opportunity>> resultMap = TenancyUtilities.getTenancy(brandsVillages);
    		
    		system.assertEquals(resultMap.size(), 1);
    		
    		map<string, Opportunity> oppMap = resultMap.get(account.name);
    		
    		system.assertEquals(oppMap.size(), 1);
    		village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];	
    		// opportunity exists
    		system.assertEquals(oppMap.get(village.Name).Id, opportunity.Id);
    		
    		
    		village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1];	
    		// no opportunity
    		system.assertEquals(oppMap.get(village.Name), null);
    		
    	test.stopTest();
    	
    	
    	
    }
    
    static testMethod void testCreateDummyOpp(){
    	
    	setupData();
    	
    	village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1];
    	
    	test.startTest();

			OpportunityTriggerhelper.hasRun = false;
			   		
    		Opportunity opp = new Opportunity();
    		system.runas(adminUsr){
    			opp = TenancyUtilities.createDummyTenancy(account.Id, village.name, 'Test', usr.Id);
    		}
    		system.assertEquals(opp.Village__c, village.Id);
    		system.assertEquals(opp.OwnerId, usr.Id);
    		
    	
    	test.stopTest();
    	
    }


}