@isTest
private class DealUtilitiesTest {

	private static Account account = new Account();
	private static Opportunity opportunity1 = new Opportunity();
	private static Opportunity opportunity2 = new Opportunity();
	private static Opportunity opportunity3 = new Opportunity();
	private static Opportunity opportunity4 = new Opportunity();
	private static Village__c village = new Village__c();
	private static Unit__c unit = new Unit__c();
	private static Contract contract = new Contract();
	private static User usr1 = new User();
	private static User usr2 = new User();	

	// Get Opportunity record type Ids
	private static final id exitedRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Exit').RecordTypeId;
	private static final id reviewRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Contract Change').RecordTypeId;
	private static final id relocationRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Relocation').RecordTypeId;
	private static final id newRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('New Brand').RecordTypeId;
		
	static void setUpData(){

   		// Create user
		usr1 = TestData_User.setupUser('BillyBones', null, 'System Administrator', true, true);
		usr1.Brand_Captain__c = true;
		update usr1;

		
		usr2 = TestData_User.setupUser('BarryBones', null, 'System Administrator', true, true);
		usr2.Brand_Captain__c = true;
		update usr2;
		
		system.runAs(usr2){
			account = TestData_Account.setupBrandAccount(1, false);
			account.EU_Brand_Captain__c = usr2.Id;
			insert account;
			
	
							
		 	village = new Village__c();
		 	village.Name = 'TestVillage';
		 	village.Village_Code__c = 'OO';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
		 	insert village;
			village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'OO' LIMIT 1];
			
			unit = new Unit__c(Name='TU1', Village__c = village.Id, size_GEA__c = 200,  Unit_Status__c = 'Available');
			insert unit;
			unit = 	[select Id, Name from Unit__c where name = 'TU1'];
			
			// New Deal
			opportunity1 = new Opportunity(name = 'TestOpp1', Village__c = village.Id, AccountId = account.id, RecordTypeId = newRecordTypeID,
											CloseDate = system.today().addDays(1), StageName = 'Pipeline', unit__c = unit.id, OwnerId = usr1.Id,
											Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100,
											Lead_Negotiator_for_VR__c = usr2.Id);
			insert opportunity1;			
			OpportunityTriggerHelper.hasRun = false;
	
			
			// Review Deal
			opportunity2 = new Opportunity(name = 'TestOpp2', Village__c = village.Id, AccountId = account.id, RecordTypeId = reviewRecordTypeID,
											CloseDate = system.today().addDays(10), StageName = 'Pipeline', unit__c = unit.id, OwnerId = usr1.Id,
											Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100,
											Open_Date__c = system.today().addDays(-10), Signed_Date__c = system.today().addDays(-10),
											Lead_Negotiator_for_VR__c = usr2.Id);
			insert opportunity2;
			OpportunityTriggerHelper.hasRun = false;	
			
			//Terminated Deal
			opportunity3 = new Opportunity(name = 'TestOpp3', Village__c = village.Id, AccountId = account.id, RecordTypeId = exitedRecordTypeID,
											CloseDate = system.today().addDays(1), StageName = 'Pipeline', unit__c = unit.id, OwnerId = usr1.Id,
											Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100,
											Open_Date__c = system.today().addDays(-10), Exit_Date__c = system.today().addDays(+10)
											);
			insert opportunity3;
			OpportunityTriggerHelper.hasRun = false;
		}
	}

    static testMethod void testDealReassignment() {
		
		setupData();
		
		test.startTest();
		system.runAs(usr2){
			string s = DealUtilities.ReassignDealOwnertoLeadNegotiator(usr1.Username);
		}
		test.stopTest();
		
		list<Opportunity> oppList = [select Id from Opportunity where OwnerId = :usr1.Id];
		system.assert(oppList.isEmpty());
		
		oppList = [select Id from Opportunity where OwnerId = :usr2.Id];
		system.assertEquals(oppList.Size(), 3);

    }
}