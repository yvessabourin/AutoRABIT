@isTest(SeeAllData=true)
private class TravelTradeMeetingHelper_TestClass{
   
   static testMethod void createAndShareMeeting(){
    
    // Perform our data preparation.
	Account TourismAccount;
	Contact TourismContact;
	
    User u1 = TestData_User.setupAdminUser(false);
    u1.Username = 'vr_u1@test.com';
    u1.Email = 'vr_u1@test.com';
    insert u1;
	
	system.runAs(u1){
	    //Account
	    TourismAccount = TestData_Account.setupTourismAccount(1, true);    
	
	    //Contact
	    TourismContact = TestData_Contact.setupContact('1', TourismAccount, true);
	}
	  
    //User
    User adminUser = TestData_User.setupAdminUser(true);
           
   //Create a Chatter Group
   //List<CollaborationGroup> TTMgrps = [SELECT id, name FROM CollaborationGroup WHERE name = 'Travel Trade Meetings'];

    //the group does not exist, so create and add the admin as a user
    CollaborationGroup grp= new CollaborationGroup();
    grp.Name = 'Test Chatter Group'; 
    grp.CollaborationType = 'Public';                   
    insert grp;
    //Chatter Group Member
    CollaborationGroupMember grpMr = new CollaborationGroupMember();
    grpMr.memberid = adminUser.Id;
    grpMr.CollaborationGroupId = Grp.Id;
    insert grpMr; 
  

    
    //Travel Trade Meeting with immediate sharing
    Travel_Trade_Meeting__c TestTTMImmediate = new Travel_Trade_Meeting__c(Date_of_Meeting__c = system.today(), Meeting_Location__c = 'Test Location'
    ,Meeting_Minutes__c = 'Test Meeting Minutes', Tourism_Account__c = TourismAccount.id, Tourism_Contact__c = TourismContact.id, 
    VR_Representative__c = adminUser.id, share__c = true);

    //Travel Trade Meeting with Manual sharing
    Travel_Trade_Meeting__c TestTTMManual = new Travel_Trade_Meeting__c(Date_of_Meeting__c = system.today(), Meeting_Location__c = 'Test Location'
    ,Meeting_Minutes__c = 'Test Meeting Minutes', Tourism_Account__c = TourismAccount.id, Tourism_Contact__c = TourismContact.id, 
    VR_Representative__c = adminUser.id, share__c = false);
  
    // reset the limits
    test.startTest();
       
    //insert TTM with that should immediatly be shared   
    insert TestTTMImmediate;
    
     //Insert THEN update (to reflect the manual process) TTM with Share__c = true
    insert TestTTMManual;
    TestTTMManual.Share__c = true;
    update TestTTMManual;
     
    // Stop the test, this changes limit context back to test from trigger.
    test.stopTest();
    
    //Fetch and verify the results
    
    //Ensure there are two feeditems in the chatter feed
    integer countimmediateposts = [SELECT COUNT() FROM FeedItem WHERE ParentID = :TestTTMImmediate.Id];
    system.debug('countimmediateposts = ' + countimmediateposts);
    system.assertEquals(countimmediateposts, 1);  
    
    integer countManualposts = [SELECT COUNT() FROM FeedItem WHERE ParentID = :TestTTMManual.Id];
    system.debug('countManualposts = ' + countManualposts);
    system.assertEquals(countManualposts, 1);  
       
}
    static testMethod void updateRelatedAccountTest(){
        // Test Data
        List<Travel_Trade_Meeting__c> travelTradeMeetingList = new List <Travel_Trade_Meeting__c>();
        
		Id TourismRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tourism').getRecordTypeId();
        Account acct = new Account(Name = 'TestAccountTest', RecordTypeId = TourismRecordType);
        
        INSERT acct;
        
		Contact con = new Contact(FirstName = 'Cristiano', LastName = 'Ronaldo', AccountId = acct.Id, email = 'CRonaldo@123emailtest123.com');
        
        INSERT con;
        
        Travel_Trade_Meeting__c travelTradeMeeting = new Travel_Trade_Meeting__c(Date_of_Meeting__c = system.today(), Meeting_Location__c = 'Test Location', 
                                                                                 Meeting_Minutes__c = 'Test Meeting Minutes', Tourism_Account__c = acct.Id, 
				                                                                 Tourism_Contact__c = con.Id);
		INSERT travelTradeMeeting;
        
        travelTradeMeetingList.add(travelTradeMeeting);
		       
        String lastActionBegin = [SELECT Last_action_type__c FROM Account WHERE Id = :acct.Id].Last_action_type__c;
        
        //Test
        
		test.startTest();
			TravelTradeMeetingTriggerHelper.updateRelatedAccount(travelTradeMeetingList);  
		test.stopTest();
        
        String lastActionEnd = [SELECT Last_action_type__c FROM Account WHERE Id = :acct.Id].Last_action_type__c;

        System.assertNotEquals(lastActionBegin, lastActionEnd, 'Wrong result');
        System.assertEquals('Travel Trade Meeting', lastActionEnd, 'Wrong result');
    } 
   
}