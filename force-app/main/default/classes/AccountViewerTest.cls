@isTest
private class AccountViewerTest {

	private static Account account = new Account();
	private static Account childAccount = new Account();
	private static Village__c village = new Village__c();
	private static Unit__c unit = new Unit__c();
	private static Opportunity deal = new Opportunity();
    private static final id reviewRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Contract Change').RecordTypeId;
    	
    static void setupData(){
    
		account = TestData_Account.setupGroupAccount(1, true);	
		childAccount = 	TestData_Account.setupBrandAccount(2, false);
		childAccount.ParentId = account.Id;
		insert childAccount;
					
 		//create village 1
 		village = new Village__c();
 		village.Name = 'TestVillage1'; 		
 		village.Village_Code__c = 'AA';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
 		insert village;
		village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];   	

		unit = new Unit__c(Name='TU1', Village__c = village.Id, size_GEA__c = 200,  Unit_Status__c = 'Available');
		insert unit;
		unit = 	[select Id, Name from Unit__c where name = 'TU1'];
		
	// New Deal
		deal = new Opportunity(name = 'TestOpp1', Village__c = village.Id, AccountId = childAccount.id, RecordTypeId = reviewRecordTypeID,
										CloseDate = system.today().addDays(1), StageName = 'Pipeline', unit__c = unit.id, 
										Contract_Tenant_Break_Date__c = system.today().addDays(20), 
										Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100);
		insert deal;
		
    
    }
	
	static testMethod void unitTest(){
		
		setupData();
		
    	PageReference pg = new PageReference('/apex/AccountTreeView');
    	pg.getParameters().put('Id', account.Id);
    	Test.setCurrentPage(pg);
    					    	
    			
		test.startTest();
		set<Id> oppIdList = new set<Id>();
    	oppIdList.add(deal.Id);

		string vpUpdate = updateVillagePresenceController.updateVillagePresenceList(oppIdList);	
		    	
    	Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(account);
		AccountViewer controller = new AccountViewer(stdController);
		
					
		test.stopTest();
		
		string tree = controller.AccountTree;
		
		system.assert(tree.indexOf('"VillageName":"TestVillage1"') > -1);
		system.assert(tree.indexOf('"ProjectedSalesYieldLocalConverted":"100000.00"') > -1);
		system.assert(tree.indexOf('"Unit":"TU1"') > -1);
		
	}
}