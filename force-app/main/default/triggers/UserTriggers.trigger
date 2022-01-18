trigger UserTriggers on User (before insert, after insert, after update) {

	set<Id> roleIdList = new set<Id>();
	set<Id> userIdList = new set<Id>();
	
	set<Id> customEmailList = new set<Id>();
    set<Id> contactIdList = new set<Id>();
	
	
	if(trigger.isAfter && trigger.isUpdate){

    	for(User u : Trigger.New){
      		string roleId = u.UserRoleId;
      		boolean alertsFlag = u.B2B_Alerts__c;
      		if (u.isActive){
	      		if(Trigger.oldMap.get(u.id).UserRoleId != roleId 
	      			|| Boolean.valueOf(Trigger.oldMap.get(u.id).isActive) == false){
					// keep track of changed user roles
					roleIdList.add(roleId);
					userIdList.add(u.Id);
	      		}
	      		
	      		// check if update is to send B2B Alerts flag
	      		if(Trigger.oldMap.get(u.id).B2B_Alerts__c != alertsFlag 
	      			|| Boolean.valueOf(Trigger.oldMap.get(u.id).isActive) == false){
					// keep track of changed B2B Alerts flag
					customEmailList.add(u.Id);
	      		}
	      		
      		}
    	}
    	// Update chatter group memberships if role changed
    	if (!UserTriggerHelper.isRunning && (!userIdList.isEmpty())){
    		UserTriggerHelper.addUserChatterGroups(roleIdList, userIdList);
    	}
    	
    	// Update chatter group email frequency if Custom B2B Email flag is changed
		if (!UserTriggerHelper.isRunning && (!customEmailList.isEmpty())){
    		UserTriggerHelper.updateUserChatterFrequency(customEmailList);
    	} 
         	
    	
  	}
  	
  	if(trigger.isBefore && trigger.isInsert){
  		for (User u :trigger.new){
  			u.UserPreferencesDisableAllFeedsEmail = true;
  		}

  	}
  	
  	if(trigger.isAfter && trigger.isInsert){
    
      Profile brandProfile = [SELECT Id FROM Profile WHERE Name = 'Brand Marketing SP' LIMIT 1];
      List<Id> marketingUsersId = new List<Id>();

  		for (User u :trigger.new){
  			if (u.isActive){
	  			roleIdList.add(u.UserRoleId);
	  			userIdList.add(u.Id);
	  			if (string.isnotBlank(u.contactId))
	  				contactIdList.add(u.ContactId);                
  			}
        if(u.ProfileId == brandProfile.Id){
           marketingUsersId.add(u.Id);
        }     
  		}

      if (!marketingUsersId.isEmpty()){
        SendEmailUserProfile.sendEmail(marketingUsersId);
      }
  		if (!userIdList.isEmpty()){
			//Update chatter group memberships
	  		UserTriggerHelper.addUserChatterGroups(roleIdList, userIdList);  		
  		}
  		if (!contactIdList.isEmpty()){
  			map<Id, Village_Presence_Contact_Role__c> vpcrIdList = new map<Id, Village_Presence_Contact_Role__c>(
  																		[select Id from Village_Presence_Contact_Role__c
  																		where Contact__c in :contactIdList]);
  			if (!vpcrIdList.isEmpty()){
  				DailySaleTriggerHelper.processShares(vpcrIdList.keySet());
          DSCertificationBatchTriggerHelper.processShares(vpcrIdList.keySet());
  			}

            // Update user lookup on contact if the contact id on user is not empty: US #34393
            UserTriggerHelper.updateUserLookupOnContactId(userIdList);
  		}    
  	}         
}