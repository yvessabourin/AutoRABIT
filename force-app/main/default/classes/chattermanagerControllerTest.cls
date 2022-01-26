@isTest
public class chattermanagerControllerTest{
 
//properties
private static user testUser;
private static user runningUser;
private static CollaborationGroup myCollaborationGroup;
     
    public static testMethod void test1()
    {
            //setup test data      
            setupdata();           
 			
            test.startTest();  
            system.runAs(runningUser){
                chattermanagerController controller = new chattermanagerController();
 
                //get all the basics setup
                controller.getUsers();
        		controller.getChatterGroups();
        		controller.getFrequencies();
        		
        		//refresh users
                controller.refreshUsers();
        		
        		//no changes have currently been made but save the "changes" anyway!
        		controller.SaveChanges();
        		controller.selectedGroupId = myCollaborationGroup.id;

        		controller.selectedFrequency = 'W';
        		controller.refreshTable();
        		//Add our selected user as a member 
        		controller.addMember();
          		controller.CGMs[0].NotificationFrequency = 'W';
          		controller.selectedUsers.add(new SelectOption(testUser.Id, 'test'));    

        		
        		controller.SaveGroup();
        
        		//now we need to assert that our testuser is a member of this group and receiving Weekly alerts
        		//TO-DO
        		list<CollaborationGroupMember> testMemberRecord= [SELECT id,CollaborationGroupId,CollaborationRole,
                                                            Member.name,NotificationFrequency, CollaborationGroup.name 
                                                            FROM CollaborationGroupMember 
                                                            WHERE MemberId = :testUser.Id and CollaborationGroupId = :myCollaborationGroup.id
                                                            and NotificationFrequency = 'W'];
                                                            
  system.debug(' @@@@@@   Notification Frequency 1 '    + testMemberRecord[0].NotificationFrequency);         		
        		system.assertEquals('W', testMemberRecord[0].NotificationFrequency);
				system.assertEquals( myCollaborationGroup.id, testMemberRecord[0].CollaborationGroupId);        
        
        		//Now we can test the exception handling by adding the user to the group AGAIN = fail
        		controller.addMember();
        		controller.CGMs[1].CollaborationGroupId = myCollaborationGroup.id;
        		controller.selectedFrequency = 'W';
        		controller.CGMs[1].NotificationFrequency = 'W';
				controller.SaveChanges(); //should cause a fail        		
            }
            test.stopTest();        
    }

	public static testMethod void test2(){
		

		setupdata();           

    	//PageReference pg = new PageReference('Page.chattermanager');
   			
		//test.setCurrentPageReference(pg);
		 			
        test.startTest();
        system.runAs(runningUser){  
			chattermanagerController controller = new chattermanagerController();
 
            //get all the basics setup
            controller.getUsers();
    		controller.getChatterGroups();
    		controller.getFrequencies();
        
    		//refresh users
            controller.refreshUsers();
    		
    		//no changes have currently been made but save the "changes" anyway!
    		controller.SaveChanges();
    		controller.selectedGroupId = myCollaborationGroup.id;

    		controller.selectedFrequency = 'D';
    		controller.refreshTable();
    		//Add our selected user as a member 
    		controller.addMember();
      		controller.CGMs[0].NotificationFrequency = 'D';
      		controller.selectedUsers.add(new SelectOption(testUser.Id, 'test'));    

        		
        	controller.SaveGroup();
    
    		//now we need to assert that our testuser is a member of this group and receiving Daily alerts
    		//TO-DO
    		list<CollaborationGroupMember> testMemberRecord= [SELECT id,CollaborationGroupId,CollaborationRole,
                                                        Member.name,NotificationFrequency, CollaborationGroup.name 
                                                        FROM CollaborationGroupMember 
                                                        WHERE MemberId = :testUser.Id and CollaborationGroupId = :myCollaborationGroup.id
                                                        and NotificationFrequency = 'D'];
        		
    		controller.selectedUsers = new list<SelectOption>();
    		system.assertEquals('D', testMemberRecord[0].NotificationFrequency);
			system.assertEquals( myCollaborationGroup.id, testMemberRecord[0].CollaborationGroupId);        
    
    		//Now we can test the exception handling by adding the user to the group AGAIN
			// with a different frequency configuration
       		// replicate the frequency being selected
			controller.selectedFrequency = 'W';
			controller.selectedGroupId = myCollaborationGroup.id;
			        		
        		//refresh the users now a user is selected
            controller.refreshUsers();
								
				// add user to selected users list				
			controller.selectedUsers.add(new SelectOption(testUser.Id, 'test'));
			
				// save group
			controller.saveGroup(); // this will fail
			
				//check error
			List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
			    if (msg.getDetail().contains('You are attempting to insert at least one user who is already a member of this group')) b = true;
			}
			system.assert(b);
					     		
        	controller.selectedGroupId = myCollaborationGroup.id;
        	controller.selectedUserId = '';
        	controller.selectedFrequency = 'D';
        	controller.refreshUsers();	
			
        	// now delete member
        	//controller.refreshTable(); 
        	controller.selectedUsers.clear();	  			
   				// save group
			controller.saveGroup();      	
 
     		testMemberRecord= [SELECT id,CollaborationGroupId,CollaborationRole,
                                                        Member.name,NotificationFrequency, CollaborationGroup.name 
                                                        FROM CollaborationGroupMember 
                                                        WHERE MemberId = :testUser.Id and CollaborationGroupId = :myCollaborationGroup.id
                                                        and NotificationFrequency = 'D'];
                                                   
				// check no longer a member
			system.assertEquals(0, testMemberRecord.size());	                                                               		
        }		
        test.stopTest();        
		
		
		
	}     
     
    static void setupdata()
    {
       //creation of test data should utilise external classes for example TestData_Account
       
       //Create a user to play with
       testUser = TestData_User.setupAdminUser(false);
       testUser.Receive_B2B_Emails__c = true;
       testUser.Receive_Weekly_B2B_Emails__c = true;
       testUser.Send_Custom_B2B_Email__c = true;
       testUser.B2B_Alerts__c = true;
       insert testUser;

	   User u1 = TestData_User.setupAdminUser(false);
	   u1.Username = 'vr_u1@test.com';
	   u1.Email = 'vr_u1@test.com';
	   insert u1;       

	   runningUser = TestData_User.setupAdminUser(false);
	   runningUser.Username = 'vr_u1_run@test.com';
	   runningUser.Email = 'vr_u1_run@test.com';
	   insert runningUser; 
	          
       //Create Chatter Groups
       system.runAs(u1){
	       myCollaborationGroup = new CollaborationGroup(name = 'myCollaborationGroup', collaborationtype = 'Public');
	       insert myCollaborationGroup;
       }
          
    }
   
}