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
private class OpportunityTriggerHelperTest {

	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Opportunity opportunity = new Opportunity();
	private static Event event = new Event();
	private static Village__c village = new Village__c();
	private static Unit__c unit = new Unit__c();
	
	static void setUpData(){

		account = TestData_Account.setupBrandAccount(1, true);
		contact = TestData_Contact.setupContact('A',account, true);	
						
	 	village = new Village__c();
	 	village.Name = 'TestVillage';
	 	village.B2B_Chatter_Group_Name__c = 'B2BTestVillage';
	 	village.Village_Code__c = 'OO';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
	 	insert village;
		village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'OO' LIMIT 1];
		
		unit = new Unit__c(Name='TU1', Village__c = village.Id, size_GEA__c = 20,  Unit_Status__c = 'Available');
		insert unit;
		unit = 	[select Id, Name from Unit__c where name = 'TU1'];
		
		opportunity = new Opportunity(name = 'TestOpp', Village__c = village.Id, AccountId = account.id, 
										CloseDate = system.today().addDays(1), StageName = 'Pipeline',
										Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100);
		insert opportunity;			
		
		
		
	}
	
    static testMethod void unitTest() {
        
    	test.startTest();
    	
    	setupData();
    	opportunity = [Select name, RecordType.Name, Unit__c, Unit__r.name from opportunity where id = :opportunity.Id];
    	system.assertEquals(opportunity.Name, account.Name + ' in ' + village.Name + ' - ' + opportunity.RecordType.Name.split(' ')[0]);    

		//OpportunityProjectionYieldCalculator.hasRun = false;	
    	opportunity.Unit__c = unit.Id;
    	OpportunityTriggerHelper.hasRun = false;
    	update opportunity;
    	
    	test.stopTest();
    	
    	opportunity = [Select name, RecordType.Name, Unit__c, Unit__r.name from opportunity where id = :opportunity.Id];
    	
    	system.assertEquals(opportunity.Name, account.Name + ' in ' + village.Name + ' (' + unit.Name + ')' +  ' - ' + opportunity.RecordType.Name.split(' ')[0] );
        
        
    }
}