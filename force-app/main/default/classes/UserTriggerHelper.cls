public with sharing class UserTriggerHelper {
    
    public static boolean isRunning = false;
    
    // This method creates chatter group memberships when a user is created or role is
    // updated. The memberships created are determined by default settings configured
    // as a custom setting and dependant on the user's role. The incoming parameters are 
    // a set of role Ids to check (this is NOT the list of default roles but a list of roles
    // extracted from the inbound user list to verify whether they match the default list 
    // configured in the Custom settings) and a set of user ids.
    
    @future
    public static void addUserChatterGroups(set<Id> roleIdList, set<Id> userIdList){
        
        map<Id, UserRole> roleMap = new map<Id, UserRole>([Select Id, Name from UserRole where Id in:roleIdList]);
        list<User> userList = [select Id, UserRoleId, UserPreferencesDisableAllFeedsEmail, 
                                        B2B_Alerts__c, Send_Custom_B2B_Email__c
                                     from User where Id in:userIdList];
        
        // Retrieve default chatter group member search parameters from custom settings
        VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
        
        // First check flag to indicate whether default groups should be applied where relevant
        boolean addDefaults = orgSettings.Auto_Create_Chatter_Roles__c;
        
        if (addDefaults){
            isRunning = true;
            // retrieve default role and group parameters
            string defaultRoles = orgSettings.Default_Chatter_Roles__c;
            string defaultGroups = orgSettings.Default_Chatter_Groups__c;
        
            if (string.isnotBlank(defaultRoles) && string.isnotBlank(defaultGroups)){
                // retrieve all groups
                map<Id, CollaborationGroup> groupMap = new map<Id, CollaborationGroup>([Select Id, Name from CollaborationGroup]);
                
                // populate default groups list
                list<CollaborationGroup> defaultGroupList = new list<CollaborationGroup>();
                list<string> defaultGroupsSearchList = defaultGroups.split(',');
                
                for (string s :defaultGroupsSearchList){
                    for(CollaborationGroup grp :groupMap.Values()){
                        if (grp.Name.indexOf(s) > -1){
                            defaultGroupList.add(grp);
                            
                        }
                        
                    }
                }
                
                // populate default roles list
                map<Id, UserRole> defaultRoleMap = new map<Id, UserRole>();
                list<string> defaultRolesSearchList = defaultRoles.split(',');
                
                for (string s :defaultRolesSearchList){
                    for (UserRole role :roleMap.Values()){
                        if (role.Name.indexOf(s) > -1){
                            defaultRoleMap.put(role.Id, role);
                            
                        }
                        
                    }
                    
                }                               
                
                // Create list of membership records to upsert
                list<CollaborationGroupMember> CGMs = new list<CollaborationGroupMember>();
                
                // Loop through incoming User Id list to determine if their role requires 
                // default memberships to be created
                
                for (User u :userList){
                    u.UserPreferencesDisableAllFeedsEmail = true;
                }
                update userList;
                
                for(User u :userList){
                    string frequency =  '';
                    // Determine chatter group notification frequency based on
                    // whether user has elected to receive B2B Alerts (on user profile) 
                    boolean alertsFlag = u.B2B_Alerts__c;
                    if (alertsFlag){
                        frequency = 'P'; //All posts
                    } else {
                        frequency = 'N'; //Never
                    }
                    if (defaultRoleMap.containsKey(u.UserRoleId)){
                        for (CollaborationGroup grp :defaultGroupList){
                            CollaborationGroupMember CGM = new CollaborationGroupMember();
                            CGM.CollaborationGroupId = grp.Id;
                            CGM.MemberId = u.Id;
                            CGM.NotificationFrequency = frequency;
                            CGM.CollaborationRole='Standard';
                            CGMs.add(CGM);
                        }
                        
                    }
                    
                }
                // DML Upsert to create membership records
                if (!CGMs.isEmpty()){
                    Database.upsert(CGMs, false);
                }           
            
            }
            
        }
                

        for (User u :userList){
            u.UserPreferencesDisableAllFeedsEmail = false;
        }
        update userList;            
        
        
    }

    // Update default chatter group frequencies to N (Never) if user's B2B Alerts flag is false, 
    // or P (All Posts) if flag is set to true
    @future
    public static void updateUserChatterFrequency(set<Id> userIdList){

        isRunning = true;
        
        // Retrieve default chatter group member search parameters from custom settings
        VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults(); 

        string defaultGroups = orgSettings.Default_Chatter_Groups__c;

        // retrieve all groups
        map<Id, CollaborationGroup> groupMap = new map<Id, CollaborationGroup>([Select Id, Name from CollaborationGroup]);
        
        // populate default groups list
        if (string.isnotBlank(defaultGroups)){
            map<Id, string> defaultGroupMap = new map<Id, string>();
            list<string> defaultGroupsSearchList = defaultGroups.split(',');
            
            for (string s :defaultGroupsSearchList){
                for(CollaborationGroup grp :groupMap.Values()){
                    if (grp.Name.indexOf(s) > -1){
                        defaultGroupMap.put(grp.Id, grp.Name);
                        
                    }
                    
                }
            }       
        
            // Create list of membership records to update
            list<CollaborationGroupMember> CGMs = [select NotificationFrequency, CollaborationGroupId, MemberId
                                                    from CollaborationGroupMember
                                                    where MemberId in:userIdList];
            // Retrieve users
            map<Id, User> userMap = new map<Id, User>([select Id, Send_Custom_B2B_Email__c, B2B_Alerts__c 
                                                        from User where Id in :userIdList]);
            
            if (!CGMS.isEmpty()){
                for (CollaborationGroupMember cgm :CGMs){
                    if (defaultGroupMap.containsKey(cgm.CollaborationGroupId)){
                        string frequency =  '';
                        boolean alertsFlag = userMap.get(cgm.MemberId).B2B_Alerts__c;
                        if (alertsFlag){
                            frequency = 'P';
                        } else {
                            frequency = 'N';
                        }
                        cgm.NotificationFrequency = frequency;              
                    }
                }
                
                update CGMs;
            }
        }
            
    
    }
    
    @future
	public static void updateUserLookupOnContactId(Set<Id> userIdList){
    	
        Map<Id,User> contacMap = new Map<Id, User>();
       	List <User> userList = [SELECT Id, ContactId FROM User WHERE Id in :userIdList];
        
        for (User us :userList){
        	contacMap.put(us.ContactId, us);            
        }
        
																											  	 
        List<Contact> ContactList = [SELECT Id, Brand_Portal_User__c FROM Contact WHERE Id in :contacMap.keySet()];
        if (!ContactList.isEmpty()){
            for (Contact c :ContactList){
                c.Brand_Portal_User__c = contacMap.get(c.id).id;
            }	
        }
        update ContactList;
    }   
    
}