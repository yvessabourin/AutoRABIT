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
private class UserTriggerHelperTest {

	private static User usr;
	private static User usr2;
	private static User usr3;
	private static UserRole role;
	private static UserRole role2;
	private static CollaborationGroup firstCollaborationGroup = new CollaborationGroup();
	private static CollaborationGroup secondCollaborationGroup = new CollaborationGroup();
	
 	static void setupdata() {
       
		// Create test admin user
 		usr = TestData_User.setupAdminUser(true);
       
        system.runAs(usr){
        	//Create Chatter Groups
        	firstCollaborationGroup = new CollaborationGroup(name = 'firstCollaborationGroup', collaborationtype = 'Public');
        	insert firstCollaborationGroup;

        	secondCollaborationGroup = new CollaborationGroup(name = 'secondCollaborationGroup', collaborationtype = 'Public');
        	insert secondCollaborationGroup;
        	
        	role = new UserRole(Name = 'AAA Role', parentRoleId = null);
        	insert role;
        	
        	role2 = new UserRole(Name = 'BBB Role', parentRoleId = null);
        	insert role2;
        }    
    }
    
    static testMethod void testInsert() {
		
		setupData();
		
		//set up custom settings for default chatter group/roles
		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
		if (settings == null){
			settings = new VR1_Configuration_Settings__c();
		}
		
		settings.Auto_Create_Chatter_Roles__c = true;
		settings.Default_Chatter_Groups__c = firstCollaborationGroup.Name.substring(0, 8);
		settings.Default_Chatter_Roles__c = role.Name.substring(0,3);
		
		system.runas(usr){
			upsert settings;		
		}		
		
		test.startTest();
			// Create test normal user
			usr2 = TestData_User.setupUser('BillyBones', role.Name, 'Standard User', true, false);
			usr2.Send_Custom_B2B_Email__c = true;
			usr2.B2B_Alerts__c = false;
			insert usr2;
			
			// create 2nd user with send custom B2B email flag set to false
			usr3 = TestData_User.setupUser('TedBed', role.Name, 'Standard User', true, false); 
			usr3.Send_Custom_B2B_Email__c = false;
			usr3.B2B_Alerts__c = true;
			insert usr3;
	    	
		test.stopTest();
        
 		/*List<CollaborationGroupMember> memberList = [select Id,CollaborationGroupId, NotificationFrequency from CollaborationGroupMember
 														where MemberId = :usr2.Id];
        system.assertEquals(memberList.size(), 1);
        system.assertEquals(memberList[0].CollaborationGroupId, firstCollaborationGroup.Id);
    	system.assertEquals(memberList[0].NotificationFrequency, 'N');
    	
 		memberList = [select Id,CollaborationGroupId, NotificationFrequency from CollaborationGroupMember
 														where MemberId = :usr3.Id];
        system.assertEquals(memberList.size(), 1);
        system.assertEquals(memberList[0].CollaborationGroupId, firstCollaborationGroup.Id);
    	system.assertEquals(memberList[0].NotificationFrequency, 'P');   */ 		
    }

    static testMethod void testUpdate() {
		
		setupData();
		
		//set up custom settings for default chatter group/roles
		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
		if (settings == null){
			settings = new VR1_Configuration_Settings__c();
		}
		
		settings.Auto_Create_Chatter_Roles__c = true;
		settings.Default_Chatter_Groups__c = firstCollaborationGroup.Name.substring(0, 8);
		settings.Default_Chatter_Roles__c = role.Name.substring(0,3) + ',' + role2.Name.substring(0,3);
		
		system.runas(usr){
			upsert settings;		
		}

		// Create test normal user
		test.startTest();
			usr2 = TestData_User.setupUser('JimmyJams', role.Name, 'Standard User', true, false);
			usr2.B2B_Alerts__c = true;
			insert usr2;	
				
			// Add another collaboration group to custom settings
			string defaultGroups = firstCollaborationGroup.Name.substring(0, 8) + ',' + secondCollaborationGroup.Name.substring(0, 8);
			settings.Default_Chatter_Groups__c = defaultGroups;
			system.runas(usr){
				upsert settings;		
			}
			
				
			// update users role
			usr2 = [select UserRoleId, Send_Custom_B2B_Email__c, B2B_Alerts__c from User where Id = :usr2.Id];
			usr2.UserRoleId = role2.Id;
			usr2.Send_Custom_B2B_Email__c = true; //should force notification frequency to N.
			//usr2.B2B_Alerts__c = false;
			update usr2;
			
		test.stopTest();
 	    /*
 		list<CollaborationGroupMember>memberList = [select Id,CollaborationGroupId, NotificationFrequency from CollaborationGroupMember
 														where MemberId = :usr2.Id];
        system.assertEquals(memberList.size(), 2);
        

        memberList = [select Id,CollaborationGroupId, NotificationFrequency from CollaborationGroupMember
						where MemberId = :usr2.Id and CollaborationGroupId = :secondCollaborationGroup.Id];
        // check that second group has been added to user, with N frequency
        system.assertEquals(memberList.size(), 1);
        system.assertEquals(memberList[0].CollaborationGroupId, secondCollaborationGroup.Id);
        system.assertEquals(memberList[0].NotificationFrequency, 'N');
 
  		// check existing member group notification frequency updated to N
  		memberList = [select Id,CollaborationGroupId, NotificationFrequency from CollaborationGroupMember
						where MemberId = :usr2.Id and CollaborationGroupId = :firstCollaborationGroup.Id];

        system.assertEquals(memberList.size(), 1);
        system.assertEquals(memberList[0].CollaborationGroupId, firstCollaborationGroup.Id);
        system.assertEquals(memberList[0].NotificationFrequency, 'N');*/
            
    }
}