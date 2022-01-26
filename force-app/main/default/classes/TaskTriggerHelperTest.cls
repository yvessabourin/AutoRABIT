@isTest
private class TaskTriggerHelperTest {
	
	static Account account1;
	static Account account2;
	static Contact contact;
	static Retail_Live_Email__c retailLive;
	static Retail_Live_Email__c retailLive2;
	static Village__c testVillage;
	
	
	private static void setupData(){
	 	User u1 = TestData_User.setupAdminUser(false);
	    u1.Username = 'vr_u1@test.com';
	    u1.Email = 'vr_u1@test.com';
	    insert u1;
		system.runAs(u1){		
		 		testVillage = new Village__c();
		 		testVillage.Name = 'Test Test';
		 		testVillage.Village_Code__c = 'TT';
				testVillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
				testVillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
		 		insert testVillage;
		
				id B2BAccountRecordTypeID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
				account1 = new Account(Name='RLTestBrand', RecordTypeId = B2BAccountRecordTypeID);
				insert account1;
				account1 = [select Id, Name from Account where Id = :account1.Id];
				
				account2 = new Account(Name='Test BrandRL', RecordTypeId = B2BAccountRecordTypeID);
				insert account2;
				
				contact = new Contact(email='test1@sf.com', FirstName = 'Albert', LastName='Table', 
													AccountId = account1.id);
				insert contact;
				
				retailLive = new Retail_Live_Email__c(Subject__c = 'Unit Test Retail Live',
												Subject_Unique__c = 'Unit Test Retail Live',
												ToAddress__c = contact.email, 
												village__c = testVillage.Id,
												brand__c = account1.Id);
				insert retailLive;
				retailLive = [select Id, brand__c, subject__c, Subject_Unique__c, reply_count__c 
										from Retail_Live_Email__c where id = :retailLive.Id];

				retailLive2 = new Retail_Live_Email__c(Subject__c = 'Unit Test Retail Live2',
												Subject_Unique__c = 'Unit Test Retail Live2',
												ToAddress__c = contact.email, 
												village__c = testVillage.Id,
												brand__c = account1.Id);
				insert retailLive2;
				retailLive2 = [select Id, brand__c, subject__c, Subject_Unique__c, reply_count__c 
										from Retail_Live_Email__c where id = :retailLive.Id];				
		    }
	}

    static testMethod void unitTest() {
		
		setupData();

		// create task for brand (mimicing outlook task association)
		Task t1 = new Task(WhatId = account1.Id, Subject = retailLive.Subject__c, 
																ActivityDate = system.today());

		// create task for brand with different subject														
		Task t3 = new Task(WhatId = account1.Id, Subject = 'Unit Test Brand Subject', 
													ActivityDate = system.today());
		
		list<Task> taskList = new list<Task>();
		taskList.add(t1);													
		taskList.add(t3);
		
		test.startTest();
			insert taskList;
		test.stopTest();
		
		t1 = [select Id, RecordTypeId, WhoId, WhatId, Subject,  
                            	Retail_Live__c, Retail_Live_From__c,Retail_Live_Reply__c                                                         
                                from Task 
                                where id = :t1.Id ]; 
                                
                                
        // check task has reassigned to retail live record
        system.assertEquals(t1.whatId, retailLive.Id);         
 
 		t3 = [select Id, RecordTypeId, WhoId, WhatId, Subject,  
                            	Retail_Live__c, Retail_Live_From__c,Retail_Live_Reply__c                                                         
                                from Task 
                                where id = :t3.Id ]; 
                                
        // check task still assigned to brand
        system.assertEquals(t3.whatId, account1.Id);                                     
    }

	static testMethod void unitTest2() {
		
		setupData();
		
		// create task for retail live record directly														
		Task t2 = new Task(WhatId = retailLive2.Id, Subject = retailLive2.Subject__c + ' From Retail Live', 
													ActivityDate = system.today());

		// create task for brand with different subject														
		Task t3 = new Task(WhatId = account1.Id, Subject = 'Unit Test Brand Subject', 
													ActivityDate = system.today());
		
		list<Task> taskList = new list<Task>();													
		taskList.add(t2);
		taskList.add(t3);
		
		test.startTest();
			insert taskList;
		test.stopTest();
		

		t2 = [select Id, RecordTypeId, WhoId, WhatId, Subject,  
                            	Retail_Live__c, Retail_Live_From__c,Retail_Live_Reply__c                                                         
                                from Task 
                                where id = :t2.Id ]; 
                                
        // check task still assigned to retail live record
        system.assertEquals(t2.whatId, retailLive2.Id);         
 
 		t3 = [select Id, RecordTypeId, WhoId, WhatId, Subject,  
                            	Retail_Live__c, Retail_Live_From__c,Retail_Live_Reply__c                                                         
                                from Task 
                                where id = :t3.Id ]; 
                                
        // check task still assigned to brand
        system.assertEquals(t3.whatId, account1.Id);                                     
    }
	
    static testMethod void updateRelatedAccountTest(){
        setupData();
    
    	String lastActionBegin = [SELECT Last_action_type__c FROM Account WHERE Id = :account1.Id].Last_action_type__c;
        
        List<Task> taskList = new List<Task>();       
        Task t1 = new Task(WhatId = account1.Id, Subject = retailLive.Subject__c, 
													ActivityDate = system.today());
        INSERT t1;
        taskList.add(t1);
        
		test.startTest();
            TaskTriggerHelper.updateRelatedAccount(taskList);
        test.stopTest();
        
        String lastActionEnd = [SELECT Last_action_type__c FROM Account WHERE Id = :account1.Id].Last_action_type__c;
        
        System.assertNotEquals(lastActionBegin, lastActionEnd, 'Wrong result');
        System.assertEquals('Task', lastActionEnd, 'Wrong result');
    }

}