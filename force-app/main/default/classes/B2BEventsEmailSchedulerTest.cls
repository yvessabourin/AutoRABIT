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
@isTest//(seeAllData=true)
private class B2BEventsEmailSchedulerTest {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	private static Event tomorrowsEvent = new Event();
	private static Event nextWeeksEvent = new Event();
	private static Village__c village = new Village__c();
	private static Village__c village2 = new Village__c();
	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Opportunity opportunity = new Opportunity();
	
	private static User usr = new User();
	private static User usr2 = new User();
	private static User usr3 = new User();
	
	
	private static CollaborationGroup chatterGrpVillage = new CollaborationGroup();
	private static CollaborationGroup chatterGrpDept = new CollaborationGroup();
	private static CollaborationGroup chatterGrpTenancy = new CollaborationGroup();
	private static CollaborationGroupMember grpMember = new CollaborationGroupMember();
		
	static void setUpData(){

		// Create test admin user
 		usr = TestData_User.setupAdminUser(true);
		
		// Create test normal user
		usr2 = TestData_User.setupUser('BillyBones', null, 'Standard User', true, true);
		usr2.Receive_B2B_Emails__c = true;
		usr2.Receive_Weekly_B2B_Emails__c = true;
		update usr2;
        
        // Create another test admin user to avoid mixed DML errors
 		usr3 = TestData_User.setupUser('sa', null, 'System Administrator', true, true);
		usr3.Receive_B2B_Emails__c = true;
		usr3.Receive_Weekly_B2B_Emails__c = true;
		update usr3;
 		
        System.runAs(usr) {
	 	     // Create test Chatter groups
	 		chatterGrpVillage = new CollaborationGroup (name = 'B2B Meetings in TestVillage1', CollaborationType = 'Public');
	 		insert chatterGrpVillage;
 		
 			chatterGrpDept = new CollaborationGroup(name='B2B Meetings - TestDept', CollaborationType = 'Public');
 			insert chatterGrpDept;
 			
 			chatterGrpTenancy = new CollaborationGroup(name='TestVillage Tenancy Meetings', CollaborationType = 'Public');
 			insert chatterGrpTenancy;
 			
 			grpMember = new CollaborationGroupMember(MemberId = usr2.Id, CollaborationGroupId = chatterGrpVillage.Id);
 			insert grpMember;
 
 			grpMember = new CollaborationGroupMember(MemberId = usr2.Id, CollaborationGroupId = chatterGrpDept.Id);
 			insert grpMember;

  			//grpMember = new CollaborationGroupMember(MemberId = usr3.Id, CollaborationGroupId = chatterGrpDept.Id);
 			//insert grpMember;	 			
 		}
        
       /*
 		System.runAs(usr3) {
 	
			account = TestData_Account.setupBrandAccount(1, true);
			contact = TestData_Contact.setupContact('A',account, true);	
		
	 		village = new Village__c();
	 		village.Name = 'TestVillage1';
	 		village.B2B_Chatter_Group_Name__c = 'B2B Meetings in TestVillage1';
	 		village.Village_Code__c = 'T1';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
	 		insert village;
			village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'T1' LIMIT 1];

	 		village2 = new Village__c();
	 		village2.Name = 'TestVillage2';
	 		village2.B2B_Chatter_Group_Name__c = 'B2B Meetings in TestVillage2';
	 		village2.Village_Code__c = 'T2';
			village2.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village2.CertSales_Report_Sales_Grace_Period_Days__c = 1;
	 		insert village2;
			village2 = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'T2' LIMIT 1];
						
			opportunity = new Opportunity(name = 'TestOpp', Village__c = village.Id, AccountId = account.id, CloseDate = system.today().addDays(1), StageName = 'Pipeline');
			insert opportunity;
		//}
		       
  		//System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
	        tomorrowsEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
	        						Share__c = false, StartDateTime = system.now().addDays(1), EndDateTime = system.now().addDays(1),
	        						Village_Activities__c = 'TestVillage - New Contract', 
	        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
	        						Description = 'Test Description',
	        						Auto_Create_Tasks__c = true);
	 
	 		insert tomorrowsEvent; // With associated opportunity
	 		
	  		// Add an invitee
	  		EventRelation er = new EventRelation(EventId = tomorrowsEvent.Id,RelationId = contact.Id);
	  		insert er;
	  		
	  		//update tomorrowsEvent; 		
	 		
	        tomorrowsEvent = new Event(Villages_Discussed__c = village2.Name + ';' + village.Name, whatId = account.Id, Event_Department__c = 'TestDept',
	        						Share__c = false, StartDateTime = system.now().addDays(1), EndDateTime = system.now().addDays(1),
	        						Village_Activities__c = 'TestVillage - New Contract',
	        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
	        						Description = 'Test Description',
	        						Auto_Create_Tasks__c = true);
	        						       						
	 		insert tomorrowsEvent; //without associated oportunity
	        /*
	   		// Add an invitee
	  		er = new EventRelation(EventId = tomorrowsEvent.Id,RelationId = contact.Id);
	  		insert er;
	        
	        update tomorrowsEvent; 
	        
	        Date startOfWeekDate = System.Now().addDays(7).Date().toStartOfWeek();
	 
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
	        						Share__c = false, StartDateTime = startOfWeekDate.addDays(1), EndDateTime = startOfWeekDate.addDays(1),
	        						Village_Activities__c = 'TestVillage - New Contract', 
	        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
	        						Description = 'Test Description',
	        						Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity
	 
	    		// Add an invitee
	  		er = new EventRelation(EventId = nextWeeksEvent.Id,RelationId = contact.Id);
	  		insert er;
	        
	        update nextWeeksEvent; 
	                
	        nextWeeksEvent = new Event(Villages_Discussed__c = village2.Name, whatId = account.Id, Event_Department__c = 'TestDept',
	        						Share__c = false, StartDateTime = startOfWeekDate.addDays(1), EndDateTime = startOfWeekDate.addDays(1),
	        						Village_Activities__c = 'TestVillage - New Contract', 
	        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
	        						Description = 'Test Description',
	        						Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // without associated opportunity
	   		// Add an invitee
	  		er = new EventRelation(EventId = nextWeeksEvent.Id,RelationId = contact.Id);
	  		insert er;
	        
	        update nextWeeksEvent; 
	
			// add more events for rest of the week
	
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
	        						Share__c = false, StartDateTime = startOfWeekDate.addDays(2), EndDateTime = startOfWeekDate.addDays(2),
	        						Village_Activities__c = 'TestVillage - New Contract', 
	        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
	        						Description = 'Test Description',
	        						Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity
	
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
	        						Share__c = false, StartDateTime = startOfWeekDate.addDays(3), EndDateTime = startOfWeekDate.addDays(3),
	        						Village_Activities__c = 'TestVillage - New Contract', 
	        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
	        						Description = 'Test Description',
	        						Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity
			
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
							Share__c = false, StartDateTime = startOfWeekDate.addDays(4), EndDateTime = startOfWeekDate.addDays(4),
							Village_Activities__c = 'TestVillage - New Contract', 
							Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
							Description = 'Test Description',
							Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity
			
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
							Share__c = false, StartDateTime = startOfWeekDate.addDays(5), EndDateTime = startOfWeekDate.addDays(5),
							Village_Activities__c = 'TestVillage - New Contract', 
							Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
							Description = 'Test Description',
							Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity
			
			
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
							Share__c = false, StartDateTime = startOfWeekDate.addDays(6), EndDateTime = startOfWeekDate.addDays(6),
							Village_Activities__c = 'TestVillage - New Contract', 
							Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
							Description = 'Test Description',
							Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity
			
	        nextWeeksEvent = new Event(whatId = opportunity.Id, Event_Department__c = 'TestDept',
							Share__c = false, StartDateTime = startOfWeekDate.addDays(7), EndDateTime = startOfWeekDate.addDays(7),
							Village_Activities__c = 'TestVillage - New Contract', 
							Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
							Description = 'Test Description',
							Auto_Create_Tasks__c = true);              						
		
			insert nextWeeksEvent; // with associated opportunity		*/
  		//}		
		
	}


   static testmethod void testSchedule() {
      	
      	test.startTest();

      		// Schedule the test job
      		String jobId = System.schedule('B2BEventsEmailSchedulerTest',
                        CRON_EXP, 
                        new B2BEventsEmailScheduler());
         
      		// Get the information from the CronTrigger API object
      		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         	NextFireTime
         	FROM CronTrigger WHERE id = :jobId];

      		// Verify the expressions are the same
      		System.assertEquals(CRON_EXP, ct.CronExpression);

      		// Verify the job has not run
      		System.assertEquals(0, ct.TimesTriggered);

			// Verify the next time the job will run
			System.assertEquals('2022-03-15 00:00:00', 
			String.valueOf(ct.NextFireTime));
			
			
		test.stopTest();

	      // Now that the scheduled job has executed after Test.stopTest(),
	}
	
	static testmethod void testBatch(){
      	
      	setUpData();
      	
      	test.startTest();

			B2BEventsEmailScheduler eventsScheduler = new B2BEventsEmailScheduler();
			Database.executeBatch(eventsScheduler);
			
			
		test.stopTest();

	      // Now that the scheduled job has executed after Test.stopTest(),

	}	
	
}