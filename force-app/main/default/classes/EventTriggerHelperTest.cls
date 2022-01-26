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
private class EventTriggerHelperTest {
	
	private static User usr = new User();
	private static User usr2 = new User();
	private static User usr3 = new User();
	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Opportunity opportunity = new Opportunity();
	private static Event event = new Event();
	private static Village__c village = new Village__c();
	private static Village__c village2 = new Village__c();
	private static CollaborationGroup chatterGrpVillage = new CollaborationGroup();
	private static CollaborationGroup chatterGrpDept = new CollaborationGroup();
	private static CollaborationGroup chatterGrpTenancy = new CollaborationGroup();
	private static Default_Task_Value__c defaultTask = new Default_Task_Value__c();	
	
	static void setUpData(){

		// Create test admin user
 		usr = TestData_User.setupAdminUser(true);
		
		// Create test normal user
		usr2 = TestData_User.setupUser('BillyBones', null, 'Standard User', true, true);
		usr2.Send_Custom_B2B_Email__c = true;
		update usr2;
		
		// Create another test admin user to avoid mixed DML errors
 		usr3 = TestData_User.setupUser('sa', null, 'System Administrator', true, true);
 		
 		System.runAs(usr) {
	 	// Create test Chatter groups
	 		chatterGrpVillage = new CollaborationGroup (name = 'B2B Meetings in TestVillage', CollaborationType = 'Public');
	 		insert chatterGrpVillage;
 		
 			chatterGrpDept = new CollaborationGroup(name='B2B Meetings - TestDept', CollaborationType = 'Public');
 			insert chatterGrpDept;
 			
 			chatterGrpTenancy = new CollaborationGroup(name='TestVillage Tenancy Meetings', CollaborationType = 'Public');
 			insert chatterGrpTenancy;
 			
 			//Associate user with chatter groups
 			list<CollaborationGroupMember> memberList = new list<CollaborationGroupMember>();
 			CollaborationGroupMember m1 = new CollaborationGroupMember(MemberId = usr2.Id, CollaborationGroupId = chatterGrpVillage.Id);
 			memberList.add(m1);
 			
 			CollaborationGroupMember m2 = new CollaborationGroupMember(MemberId = usr2.Id, CollaborationGroupId = chatterGrpDept.Id);
 			memberList.add(m2);
 			
 			CollaborationGroupMember m3 = new CollaborationGroupMember(MemberId = usr2.Id, CollaborationGroupId = chatterGrpTenancy.Id);
 			memberList.add(m3); 					
 			
 			insert memberList; 			
 		}
 	
 		system.runAs(usr3){
 	
			account = TestData_Account.setupBrandAccount(1, true);
			contact = TestData_Contact.setupContact('A',account, true);	
						
	 		village = new Village__c();
	 		village.Name = 'TestVillage';
	 		village.B2B_Chatter_Group_Name__c = 'B2BTestVillage';
	 		village.Village_Code__c = 'TV';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
	 		insert village;
			village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'TV' LIMIT 1];

	 		village2 = new Village__c();
	 		village2.Name = 'TestVillage2';
	 		village2.B2B_Chatter_Group_Name__c = 'B2BTestVillage2';
	 		village2.Village_Code__c = 'T2';
			village2.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village2.CertSales_Report_Sales_Grace_Period_Days__c = 1;
	 		insert village2;
			village2 = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'T2' LIMIT 1];
						
			opportunity = new Opportunity(name = 'TestOpp', Village__c = village.Id, AccountId = account.id, CloseDate = system.today().addDays(1), StageName = 'Pipeline',
									Projected_Sales_Yield_Local__c = 100000, Projected_Return_Local__c =12 , Ideal_Size__c = 100);
			insert opportunity;	
			
			defaultTask = new Default_Task_Value__c(Default_Assignee__c = usr.Id, Due_Date_Offset__c = 7, Remerchandising_Activity__c = 'TestVillage - New Contract' );
			insert defaultTask;
		}
	
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = usr2.Id;
        test.setFixedSearchResults(fixedSearchResults);
			
		
	}
	
    static testMethod void testInsertWithTaskDefaultAssignee() {
        
        setUpData();
        event = new Event(Villages_Discussed__c = village.Name, whatId = account.Id, Event_Department__c = 'TestDept',
        						Share__c = false, StartDateTime = system.now(), EndDateTime = system.now(),
        						Village_Activities__c = 'TestVillage - New Contract',
        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
        						Description = 'Test Description',
        						Auto_Create_Tasks__c = true);

		
        
        test.startTest();
			
			system.runAs(usr3){
		        insert event;
		  		
		  		// Add an invitee
		  		EventRelation er = new EventRelation(EventId = event.Id,RelationId = usr2.Id);
		  		insert er;
		  		      
		        event.Share__c = true;
		        update event;
			}
			
        test.stopTest();
        
        list<Task> taskList = [select Id, Remerchandising_Activity__c, Villages_Discussed__c, Description, OwnerId, ActivityDate  
        					from Task where whatId = :account.Id];
        
        list<EventRelation> erList = [Select EventId, RelationId, relation.name  FROM EventRelation where EventId = :event.Id];

        // check task fields					
        system.assertEquals(taskList.size(), 1);
        system.assertEquals(taskList[0].OwnerId, usr.Id); //from Default task object
        system.assertEquals(taskList[0].ActivityDate, system.today().addDays(7)); // from Default task object
        system.assertEquals(taskList[0].Villages_Discussed__c, 'TestVillage');
        system.assert(taskList[0].Description.contains('This task has been created automatically as a result of a B2B Meeting'));					
        					

        // Check village presence post
        Village_Presence__c vp = [select Id, name from Village_Presence__c where Brand__c = :account.Id and Village__c = :village.Id];
        system.assertEquals(vp.Name, account.name + ' in ' + village.name);
        feedItem f = [select id, body from feedItem where ParentId = :vp.Id];
        
        system.assert(f.body.contains(event.Event_Headline__c));
        
        // check event chatter post        
        f = [select id, body from feedItem where ParentId = :event.Id];
        system.assert(f.body.contains(event.Event_Headline__c));
        system.assert(f.body.contains( erList[0].relation.name )); //check invitee included in post body       
        
    }
    
	static testMethod void testInsertWithTaskNamedAssignee() {
        
        setUpData();
        event = new Event(Villages_Discussed__c = village.Name +';'+village2.Name, whatId = account.Id, Event_Department__c = 'TestDept',
        						StartDateTime = system.now(), EndDateTime = system.now(),
        						Village_Activities__c = 'TestVillage - New Contract',
        						Follow_Up_Assignee__c = 'Bones', Follow_Up_Due_date__c = system.today().addDays(3),
        						Event_Headline__c = 'Test Headline',
        						Description = 'Test Description',
        						Auto_Create_Tasks__c = true,
        						Share__c = true);


        
        test.startTest();
			system.runAs(usr3){

		// check custom setting to determine whether village presence creation is switched on 
				VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
				if (settings != null) {
					settings.Create_Village_Presence__c = true;
				} else {
					settings = new VR1_Configuration_Settings__c();
					settings.Create_Village_Presence__c = true;
				}
				upsert settings;
				
	        	insert event;
			}
        
        test.stopTest();
        
        list<Task> taskList = [select Id, Remerchandising_Activity__c, Villages_Discussed__c, Description, OwnerId, ActivityDate  
        					from Task where whatId = :account.Id];
        

        // check task fields					
        system.assertEquals(taskList.size(), 1);
        system.assertEquals(taskList[0].OwnerId, usr2.Id);
        system.assertEquals(taskList[0].ActivityDate, system.today().addDays(3)); 
        system.assertEquals(taskList[0].Villages_Discussed__c, village.Name +';'+village2.Name);
        system.assert(taskList[0].Description.contains('This task has been created automatically as a result of a B2B Meeting'));					
        					        
        // Check village presence post
        Village_Presence__c vp = [select Id, name from Village_Presence__c where Brand__c = :account.Id and Village__c = :village.Id];
        system.assertEquals(vp.Name, account.name + ' in ' + village.name);
        feedItem f = [select id, body from feedItem where ParentId = :vp.Id];
        
        // check event chatter post        
        f = [select id, body from feedItem where ParentId = :event.Id];
        system.assert(f.body.contains(event.Event_Headline__c));

        
    }    

	static testMethod void testInsertWithNoAutoTask() {
        
        setUpData();
        event = new Event(Villages_Discussed__c = village.Name, whatId = account.Id, Event_Department__c = 'TestDept',
        						Share__c = false, StartDateTime = system.now(), EndDateTime = system.now(),
        						Village_Activities__c = 'TestVillage - New Contract',
        						Follow_Up_Assignee__c = 'Bones', Event_Headline__c = 'Test Headline',
        						Description = 'Test Description',
        						Auto_Create_Tasks__c = false);


        
        test.startTest();
			system.runAs(usr3){
		        insert event;
		        
		        event.Share__c = true;
		        update event;
			}
        test.stopTest();
        
        list<Task> taskList = [select Id, Remerchandising_Activity__c, Villages_Discussed__c, Description, OwnerId, ActivityDate  
        					from Task where whatId = :account.Id];
        

        //check no task created					
        system.assertEquals(taskList.size(), 0);
     					
    }
    

   static testMethod void testInsertWithOpportunityEvent() {
        
        setUpData();
        event = new Event(Villages_Discussed__c = village.Name, whatId = opportunity.Id, Event_Department__c = 'TestDept',
        						Share__c = false, StartDateTime = system.now(), EndDateTime = system.now(),
        						Village_Activities__c = 'TestVillage - New Contract',
        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
        						Description = 'Test Description',
        						Auto_Create_Tasks__c = true);

		// check custom setting to determine whether tenancyPosts are switched on
		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
		if (settings != null) {
			settings.Tenancy_Posts__c = true;
		} else {
			settings = new VR1_Configuration_Settings__c();
			settings.Tenancy_Posts__c = true;
		}
		system.runas(usr){
			upsert settings;		
		}
		
        test.startTest();
			
			system.runAs(usr3){
		        insert event;
		  		
		  		// Add an invitee
		  		EventRelation er = new EventRelation(EventId = event.Id,RelationId = usr2.Id);
		  		insert er;
		  		      
		        event.Share__c = true;
		        update event;
			}
			
        test.stopTest();
        
        // check event subject
        list<Event> eventList = [select Id, Subject from event where whatId = :opportunity.Id];
        //system.assert(eventList[0].subject.contains(opportunity.Name));
        
        list<Task> taskList = [select Id, Remerchandising_Activity__c, Villages_Discussed__c, Description, OwnerId, ActivityDate  
        					from Task where whatId = :account.Id];
        
        list<EventRelation> erList = [Select EventId, RelationId, relation.name  FROM EventRelation where EventId = :event.Id];

        // check task fields					
        system.assertEquals(taskList.size(), 1);
        system.assertEquals(taskList[0].OwnerId, usr.Id); //from Default task object
        system.assertEquals(taskList[0].ActivityDate, system.today().addDays(7)); // from Default task object
        system.assertEquals(taskList[0].Villages_Discussed__c, 'TestVillage');
        system.assert(taskList[0].Description.contains('This task has been created automatically as a result of a B2B Meeting'));					

        // check event chatter post        
        feedItem f = [select id, body from feedItem where ParentId = :event.Id];
        system.assert(f.body.contains(event.Event_Headline__c));
        system.assert(f.body.contains( erList[0].relation.name )); //check invitee included in post body       
        
    }

	static testMethod void testVillagePresenceEvent(){
		
		setUpData();
        
		test.startTest();
			system.runas(usr){
				Village_Presence__c vp = [select Id, name from Village_Presence__c where Brand__c = :account.Id and Village__c = :village.Id];
		         
		        
		        event = new Event(Villages_Discussed__c = village.Name, whatId = vp.Id, Event_Department__c = 'TestDept',
		        						Share__c = false, StartDateTime = system.now(), EndDateTime = system.now(),
		        						Village_Activities__c = 'TestVillage - New Contract',
		        						Follow_Up_Assignee__c = '', Event_Headline__c = 'Test Headline',
		        						Description = 'Test Description',
		        						Auto_Create_Tasks__c = false);		
				insert event;
		        // Check village presence post
		        vp = [select Id, name from Village_Presence__c where Brand__c = :account.Id and Village__c = :village.Id];
		        system.assertEquals(vp.Name, account.name + ' in ' + village.name);
	        		
			}
		test.stopTest();	
		
	}
        
    
}