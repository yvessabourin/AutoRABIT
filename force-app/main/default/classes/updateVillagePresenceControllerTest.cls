@isTest
private class updateVillagePresenceControllerTest {

	private static Account account = new Account();
	private static Opportunity opportunity1 = new Opportunity();
	private static Opportunity opportunity2 = new Opportunity();
	private static Opportunity opportunity3 = new Opportunity();
	private static Opportunity opportunity4 = new Opportunity();
	private static Village__c village = new Village__c();
	private static Unit__c unit = new Unit__c();
	private static Contract contract = new Contract();
	

	// Get Opportunity record type Ids
	private static final id exitedRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Exit').RecordTypeId;
	private static final id reviewRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Contract Change').RecordTypeId;
	private static final id relocationRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Relocation').RecordTypeId;
	private static final id newRecordTypeID = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('New Brand').RecordTypeId;
		
	static void setUpData(){

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
		
	//	contract.StartDate = system.today();		
	//	contract.AccountId = account.Id;
	//	contract.Opportunity__c = opportunity1.Id;
	//	insert contract;
		
		// Review Deal
		opportunity2 = new Opportunity(name = 'TestOpp2', Village__c = village.Id, AccountId = account.id, RecordTypeId = reviewRecordTypeID,
										CloseDate = system.today().addDays(10), StageName = 'Pipeline', unit__c = unit.id,
										Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100,
										Open_Date__c = system.today().addDays(-10), Signed_Date__c = system.today().addDays(-10));
		insert opportunity2;
		OpportunityTriggerHelper.hasRun = false;	
		
		//Terminated Deal
		opportunity3 = new Opportunity(name = 'TestOpp3', Village__c = village.Id, AccountId = account.id, RecordTypeId = exitedRecordTypeID,
										CloseDate = system.today().addDays(1), StageName = 'Pipeline', unit__c = unit.id,
										Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100,
										Open_Date__c = system.today().addDays(-10), Exit_Date__c = system.today().addDays(+10));
		insert opportunity3;
		OpportunityTriggerHelper.hasRun = false;
		
		Deal_Auto_Sync_Stages__c defaultSettings = new Deal_Auto_Sync_Stages__c (Name = 'Pipeline', Stage_Name__c = 'Pipeline', Default_Sync_Value__c = false, Closed_Success__c = true);
		insert defaultSettings;
	}
	
    static testMethod void testFromController() {
    	
    	setupData();

    	// Test new deal
    	  
  		opportunity1 = [select Id, name, StageName,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__c
    					from Opportunity where Id = :opportunity1.Id]; 
    	
    	PageReference pg = new PageReference('/apex/updateVillagePresence');
    	pg.getParameters().put('stage', opportunity1.StageName);
    	pg.getParameters().put('Id', opportunity1.Id);
    	Test.setCurrentPage(pg);
    					    	
    	Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(opportunity1);
		updateVillagePresenceController controller = new updateVillagePresenceController(stdController);
		
		test.startTest();
			
		controller = new updateVillagePresenceController();
		PageReference pg1 = controller.saveVillagePresence();

    	
    	Village_Presence__c vp1 = [select Id, Name, Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    									Projected_Income_Yield__c, Latest_Review_Deal__c, New_Deal__c, Exit_Deal__c, 
    									Sales_Rating__c, Income_Rating__c 
    									from Village_Presence__c
    									where id = :opportunity1.village_presence__c ];
		

		system.assertEquals(vp1.New_Deal__c, opportunity1.Id);
		system.assertEquals(vp1.Latest_Review_Deal__c, null);
		system.assertEquals(vp1.Exit_Deal__c, null);		

    	// Test review deal
    	
    	pg.getParameters().put('stage', opportunity2.StageName);
    	pg.getParameters().put('Id', opportunity2.Id);
    	
   		opportunity2 = [select Id, name, StageName, Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity2.Id];     	
    	
    	Apexpages.Standardcontroller stdController2 = new Apexpages.Standardcontroller(opportunity2);
		updateVillagePresenceController controller2 = new updateVillagePresenceController(stdController2);

    	pg = new PageReference('/apex/updateVillagePresence');
    	pg.getParameters().put('stage', opportunity2.StageName);
    	pg.getParameters().put('Id', opportunity2.Id);
    	Test.setCurrentPage(pg);

		controller2 = new updateVillagePresenceController();
		PageReference pg2 = controller2.saveVillagePresence();


    	Village_Presence__c vp2 = [select Id, Name, Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    									Projected_Income_Yield__c, Latest_Review_Deal__c, New_Deal__c, Exit_Deal__c, 
    									Sales_Rating__c, Income_Rating__c 
    									from Village_Presence__c
    									where id = :opportunity2.village_presence__c ];
		

		system.assertEquals(vp2.New_Deal__c, opportunity1.Id);
		system.assertEquals(vp2.Latest_Review_Deal__c, opportunity2.Id);
		system.assertEquals(vp2.Exit_Deal__c, null);


		
		// Test exit deal
		
		opportunity3 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity3.Id];      					    					    									    									     							
		
    	Apexpages.Standardcontroller stdController3 = new Apexpages.Standardcontroller(opportunity3);
		updateVillagePresenceController controller3 = new updateVillagePresenceController(stdController3);
		PageReference pg3 = controller3.saveVillagePresence();
		test.setCurrentPageReference(pg3);
    	
    	Village_Presence__c vp3 = [select Id, Name, Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    									Projected_Income_Yield__c, Latest_Review_Deal__c, New_Deal__c, Exit_Deal__c, 
    									Sales_Rating__c, Income_Rating__c 
    									from Village_Presence__c
    									where id = :opportunity3.village_presence__c ];
		

		system.assertEquals(vp3.New_Deal__c, opportunity1.Id);
		system.assertEquals(vp3.Latest_Review_Deal__c, opportunity2.Id);
		system.assertEquals(vp3.Exit_Deal__c, opportunity3.Id);

		pg3 = controller3.cancelUpdate();

		test.stopTest();
	
    }


	static testMethod void testBulkCall() {
    	
    	setupData();

		opportunity1 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity1.Id];    	   
   
   		opportunity2 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity2.Id];  
    					
		opportunity3 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity3.Id];  
    					    					
    	set<Id> oppIdList = new set<Id>();
    	oppIdList.add(opportunity1.Id);
    	oppIdList.add(opportunity2.Id);
    	oppIdList.add(opportunity3.Id);
    	
    	list<Id> vpIdList = new list<Id>();
    	vpIdList.add(opportunity1.village_presence__c);
    	vpIdList.add(opportunity2.village_presence__c);
    	vpIdList.add(opportunity3.village_presence__c);    	    									
		
		updateVillagePresenceController controller = new updateVillagePresenceController();
		
		string bulkCall = updateVillagePresenceController.updateVillagePresenceList(oppIdList);    									
 
     	map<Id, Village_Presence__c> vpMap = new Map<id, Village_Presence__c> ([select Id, Name, Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    									Projected_Income_Yield__c, Latest_Review_Deal__c, New_Deal__c, Exit_Deal__c, Sales_Rating__c,
    									Income_Rating__c 
    									from Village_Presence__c
    									where id in :vpIdList]);
 
 
		system.assertEquals(vpMap.get(opportunity1.village_presence__c).New_Deal__c, opportunity1.Id);
		system.assertEquals(vpMap.get(opportunity1.village_presence__c).Latest_Review_Deal__c, opportunity2.Id);
		system.assertEquals(vpMap.get(opportunity1.village_presence__c).Exit_Deal__c, opportunity3.Id);	
    
	}							

    
	static testMethod void  testErrors(){
		
		setupData();
		
        Test.startTest();
		// temporarily switch off validation rules to create invalid data
		Global_Object_Validation__c settings = Global_Object_Validation__c.getInstance(userinfo.getProfileId());
		if (settings != null) {
			settings.Deal_Validations_Active__c = false;
		} else {
			settings = new Global_Object_Validation__c();
			settings.Deal_Validations_Active__c = false;
		}
		upsert settings;
		
		opportunity1 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
				Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
				from Opportunity where Id = :opportunity1.Id];
				
		opportunity1.Projected_Sales_Yield_Local__c = null;
		update opportunity1;
		
		settings.Deal_Validations_Active__c = true;
		upsert settings;

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(opportunity1);
        updateVillagePresenceController controller = new updateVillagePresenceController(stdController);	
        try {
            test.setCurrentPageReference(controller.saveVillagePresence());
        } catch (exception e){
            // do nothing 
        }

 		List<Apexpages.Message> msgs = ApexPages.getMessages();
	    boolean b = false;
		for(Apexpages.Message msg:msgs){
			if (msg.getDetail().contains('The Village presence could not be saved')) b = true;
	    }
	   // system.assert(b);    
		
    
    	// test error with bulk call

        opportunity1 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
                        Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
                        from Opportunity where Id = :opportunity1.Id];    	   
   
   		opportunity2 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity2.Id];  
    					
		opportunity3 = [select Id, name,  Projected_Sales_Yield_Local__c, Projected_Return_Local__c,
    					Projected_Income_Yield__c, Sales_Rating__c, Income_Rating__c, village_presence__r.Id
    					from Opportunity where Id = :opportunity3.Id];  
    					    					
    	set<Id> oppIdList = new set<Id>();
    	oppIdList.add(opportunity1.Id);
    	oppIdList.add(opportunity2.Id);
    	oppIdList.add(opportunity3.Id);
   											
		controller = new updateVillagePresenceController();
		
		string bulkCall = updateVillagePresenceController.updateVillagePresenceList(oppIdList);    			
        system.debug ( ' @@@@@@@@@@@@@@@  BULK CALL ..  ' + bulkCall);
    	system.debug(' @@@@@@@@@@@@@@@ END');
        Test.stopTest();
 //       system.assert(bulkCall.contains('Deal Update Error'));
        

	}    
}