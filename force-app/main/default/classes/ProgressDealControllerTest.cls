@isTest
private class ProgressDealControllerTest {

	private static Account account = new Account();
	private static Opportunity opportunity1 = new Opportunity();
	private static Opportunity opportunity2 = new Opportunity();
	private static Deal_Auto_Sync_Stages__c defaultSettings = new Deal_Auto_Sync_Stages__c();
	private static Village__c village = new Village__c();
	private static Unit__c unit = new Unit__c();

	// Get Opportunity record type Ids
	private static final id newRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('New Brand').RecordTypeId;
	private static final id reviewRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Contract Change').RecordTypeId;
		
	static void setupData(){
		
		account = TestData_Account.setupBrandAccount(1, true);
						
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
										CloseDate = system.today().addDays(1), StageName = 'Pipeline', unit__c = unit.id,
										Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100);
		insert opportunity1;			
		OpportunityTriggerHelper.hasRun = false;

		
		// Review Deal
		opportunity2 = new Opportunity(name = 'TestOpp2', Village__c = village.Id, AccountId = account.id, RecordTypeId = reviewRecordTypeID,
										CloseDate = system.today().addDays(10), StageName = 'Trading', unit__c = unit.id,
										Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100,
										Open_Date__c = system.today().addDays(-10), Signed_Date__c = system.today().addDays(-10));
		insert opportunity2;
		OpportunityTriggerHelper.hasRun = false;
		
		defaultSettings = new Deal_Auto_Sync_Stages__c(Name = 'Pipline', Stage_Name__c = 'Pipeline', Default_Sync_Value__c = false);
		insert defaultSettings;
		
		defaultSettings = new Deal_Auto_Sync_Stages__c(Name = 'Trading', Stage_Name__c = 'Trading', Default_Sync_Value__c = false);
		insert defaultSettings;
		
		defaultSettings = new Deal_Auto_Sync_Stages__c(Name = 'Agreed in Principle', Stage_Name__c = 'Agreed in Principle', Default_Sync_Value__c = true);
		insert defaultSettings;	
		
		defaultSettings = new Deal_Auto_Sync_Stages__c(Name = 'In discussion', Stage_Name__c = 'In discussion', Default_Sync_Value__c = true);
		insert defaultSettings;	
		
	}

    static testMethod void unitTest() {

		setupData();
        Test.startTest();
    	Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(opportunity1);
		ProgressDealController controller = new ProgressDealController(stdController);

		opportunity1 = controller.deal;
		opportunity1.Auto_Sync__c = true;
		controller.SaveRecord();

    	Village_Presence__c vp1 = [select Id, Name, Deal_in_Progress__c 
    									from Village_Presence__c
    									where id = :opportunity1.village_presence__r.Id ];
    									
    	system.assertEquals(vp1.Deal_in_Progress__c, opportunity1.Id);
    											
		controller.deal.StageName = 'In discussion';
		controller.SaveRecord();
		
		system.assertEquals(opportunity1.Auto_Sync__c, true);

		stdController = new Apexpages.Standardcontroller(opportunity2);
		controller = new ProgressDealController(stdController);

		opportunity2 = controller.deal;
		opportunity2.StageName = 'In discussion';
		controller.showWarning();
		controller.stageUpdate();
		controller.SaveRecord();		
		
		system.assertEquals(opportunity2.Auto_Sync__c, true);

    	vp1 = [select Id, Name, Deal_in_Progress__c 
    									from Village_Presence__c
    									where id = :opportunity1.village_presence__r.Id ];
    									
    	system.assertEquals(vp1.Deal_in_Progress__c, opportunity2.Id);

		Opportunity1 = [select Auto_sync__c from Opportunity where id = :opportunity1.Id];
		
		system.assertEquals(opportunity1.Auto_Sync__c, false);
		Test.stopTest();
    }
}