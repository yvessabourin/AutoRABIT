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
private class OpportunitySegmentSynchTest {

	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Opportunity opportunity = new Opportunity();
	private static Event event = new Event();
	private static Village__c village = new Village__c();
	private static Unit__c unit = new Unit__c();
	
	static void setUpData(){

		account = TestData_Account.setupBrandAccount(1, false);
		
		account.Brand_Segment__c = 'Department Test';
		account.Brand_Subsegment__c = 'Segment Test';
		account.Brand_VR_Positioning__c = 'Price Point Test';
		
		insert account;
		
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
		
		opportunity = new Opportunity(name = 'TestOpp', Village__c = village.Id, AccountId = account.id, CloseDate = system.today().addDays(1), StageName = 'Pipeline');
		insert opportunity;			
			
		
	}

    static testMethod void unitTest() {
       
		setupData();
		
		opportunity = [select Department__c, Segment__c, Price_point__c from Opportunity where id =:opportunity.Id];
		
		system.assertEquals(opportunity.Department__c, account.Brand_Segment__c);
		system.assertEquals(opportunity.Segment__c, account.Brand_Subsegment__c);
		system.assertEquals(opportunity.Price_point__c, account.Brand_VR_Positioning__c);
		
		opportunity.Department__c = 'Department updated';
		opportunity.Segment__c = null;
		opportunity.Price_Point__c = null;
		
		update opportunity;

		opportunity = [select Department__c, Segment__c, Price_point__c from Opportunity where id =:opportunity.Id];
		
		system.assertEquals(opportunity.Department__c, 'Department updated');
		system.assertEquals(opportunity.Segment__c, null);
		system.assertEquals(opportunity.Price_point__c, null);
				
		list<Id> idList = new list<Id>();
		idList.add(opportunity.Id);
		
		OpportunitySegmentSynch.syncSegmentationData(idList, true);
		
		opportunity = [select Department__c, Segment__c, Price_point__c from Opportunity where id =:opportunity.Id];
		
		system.assertEquals(opportunity.Department__c, account.Brand_Segment__c);
		system.assertEquals(opportunity.Segment__c, account.Brand_Subsegment__c);
		system.assertEquals(opportunity.Price_point__c, account.Brand_VR_Positioning__c);		


    }
}