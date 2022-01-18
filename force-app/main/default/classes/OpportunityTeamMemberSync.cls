/************************************************
Author : Constantine Chimonides
Purpose : Class created to handle after insert/update trigger when creating a new
		Opportunity Team Member and synchronising with relevant fields on
		parent Opportunity record.
		This class is also used to synchronise the primary Opportunity Contact Role
		with the Opportunity Lead Negotiator Brand field. This update is performed
		using an inline VF page as a workaround because the OpportunityContactRole
		object does not support triggers.
Version History:
================
Created  : 25/11/2013
Modifications : 10/11/2014 - Added syncAccountRecordPersonnel method to allow for Account Team
							changes to be synchronised with related Deals (Opportunities). 
				
				28/11/2014 - Added synchAccountRecordListPersonnel to enable multiple Accounts
							to be processed when synchronising roles. This methd is called by
							an Account list view button. In adition, the process can be called from the 
							Developer console as follows, if desired ..
							
							**** Sample Anonymous Script start ****
							
							id BrandRecordTypeID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
							// construct desired SOQL
							map<Id, Account> accountMap = new map<Id, Account>([select Id, Name from Account where RecordTypeId = :BrandRecordTypeId]);
							list<Id> accIds = new list<Id>(accountMap.keySet());
							string returnVal = OpportunityTeamMemberSync.syncAccountRecordListPersonnel(accIds);
							system.debug(returnVal);
							
							**** Sample Anonymous Script end ****
							 
************************************************/
global with sharing class OpportunityTeamMemberSync {

	
	// Update Opportunity level fields with OpportunityTeamMember values
	webservice static void syncOpportunityRecordPersonnel(string oppId){
		
		list<OpportunityTeamMember> oppTeam = [select id, OpportunityId from OpportunityTeamMember where OpportunityId =:oppId];	
		
		syncOpportunityPersonnel(oppTeam);
				
	}
	

	// Update OpportunityTeamMembers to reflect changes made at Account team level
	webservice static string syncAccountRecordPersonnel(string accId){
		
		string returnValue = '';
		
		returnValue = syncAccountPersonnel(accId, null);
		
		return returnValue;
				
	}

	// Update OpportunityTeamMembers to reflect changes made at Account team level
	webservice static string syncAccountRecordListPersonnel(list<Id> accIdList){
		
		string returnValue = '';
		
		returnValue = syncAccountPersonnel(null, accIdList);
		
		return returnValue;
				
	}
			
	public static string syncAccountPersonnel(string accId, list<Id> accIdList){
		
		string returnValue = 'All Deals Updated';
		list<string> oppIdList = new list<string>();
			
		try{
			
			if (accidList == null){
				accIdList = new list<string>();
				accIdList.add(accId);
			}
				
			// Retrieve list of roles to synchronise from Custom Settings
			VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
	        string roles = settings.Brand_to_Deal_Role_Sync_Items__c;
	        list<string> rolesList = roles.split(',');			
			list<AccountTeamMember> accTeam = new list<AccountTeamMember>();
			
			// Retrieve account team
			if (!rolesList.isEmpty()){
				accTeam = [select AccountId, UserId, TeamMemberRole from AccountTeamMember 
													where AccountId in :accIdList
													and TeamMemberRole in :rolesList]; 
			}
			
			// OpportunityTeamMember userId field is not writable, therefore have to remove existing record
			// first and then insert new value
			list<OpportunityTeamMember> deleteList = new list<OpportunityTeamMember>();
			list<OpportunityTeamMember> insertList = new list<OpportunityTeamMember>();
			map<string,map<string, string>> accTeamMap = new map<string,map<string, string>>();
			
			if (!accteam.isEmpty()){
				

				for (AccountTeamMember accMember :accTeam){
					map<string, string> accTeamMemberMap = accTeamMap.get(accMember.AccountId);
					if (accTeamMemberMap == null){
						accTeamMemberMap = new map<string, string>();
					}
					accTeamMemberMap.put(accMember.TeamMemberRole, accMember.UserId);
					accTeamMap.put(accMember.AccountId, accTeamMemberMap);
				}
			}		
			// Retrieve all deals associated with account and team member records to process
			list<Opportunity> oppList = [select Id,  Region__c, AccountId,
						(Select Id, UserId, TeamMemberRole, Opportunity.Id, OpportunityAccessLevel, Opportunity.Account.Id
								 From OpportunityTeamMembers where TeamMemberRole in :rolesList) 
							from Opportunity where Account.Id in :accIdList];
			
			map<Id, list<OpportunityTeamMember>> oppTeams = new map<Id, list<OpportunityTeamMember>>();
			
			// create map to store list of deals which have no team defined at all
			map<Id, string> emptyOpps = new map<Id, string>();
				
			// create single list of all OpportunityTeamMembers for all associated deals
			for (Opportunity opp :oppList){
system.debug('@@@@@@@@@@@@@@@@@   opp.OpportunityTeamMembers  ' + opp.OpportunityTeamMembers + ' - ' + opp.OpportunityTeamMembers.size());					
				oppIdList.add(opp.Id);
				if (opp.OpportunityTeamMembers.size() > 0){
					oppTeams.put(opp.Id, opp.OpportunityTeamMembers);						
				} else {
					oppTeams.put(opp.Id, new list<OpportunityTeamMember>());
					emptyOpps.put(opp.Id, opp.AccountId);
				}				
			}
				
			// loop through list of all OpportunityTeamMembers for all associated roles
			for (Id key :oppTeams.keySet()){
				list<OpportunityTeamMember> memberList = oppTeams.get(key);
				string currentAccountId = '';
system.debug(' @@@@@@@@@@  memberList  ' + key + ' - ' + memberList + ' - ' + memberList.size());	
system.debug(' @@@@@   emptyOpps  ' + emptyOpps);
				map<string, string> matchedRoles = new map<string, string>();
				map<string, string> accountTeamMap = new map<string, string>();
					
				if (memberList.isEmpty() || memberList == null || memberList.size() == 0){ //Deal currently has no team defined
					currentAccountId = emptyOpps.get(key);
					accountTeamMap = accTeamMap.get(currentAccountId);
				} else {
						
					for (OpportunityTeamMember oppMember :memberList){
						currentAccountId = oppMember.Opportunity.Account.Id;
						// If deal has role which matches brand role, continue to process
						if (accTeam.isEmpty()){ // No Account teams defined for all accounts passed in
							accountTeamMap = null;
						} else {
							accountTeamMap = accTeamMap.get(currentAccountId);
						}
	system.debug(' @@@@@@@@@@  accountTeamMap  ' + accountTeamMap);
	system.debug(' @@@@@@@@@@  oppMember  ' + oppMember);							
						if (oppMember.Opportunity.Account.Id == currentAccountId){
							if (accountTeamMap != null){
								if (accountTeamMap.containsKey(oppMember.TeamMemberRole)){
									// add to matched roles map for later processing
									matchedRoles.put(oppMember.TeamMemberRole, oppMember.TeamMemberRole);
									// Check is user for matched role is different
									if (oppMember.UserId != accountTeamMap.get(oppMember.TeamMemberRole)){
										deleteList.add(oppMember);
										string accMemberId = accountTeamMap.get(oppMember.TeamMemberRole);
										OpportunityTeamMember memberUpdate = oppMember.clone(false, true);
										memberUpdate.Userid = accMemberId;
										insertList.add(memberUpdate);
									}														
								} else {
									deleteList.add(oppMember);
								}
							} else {
								deleteList.add(oppMember);
							}
						}
					}
					
				}
system.debug(' @@@@@@@@@@@@@@@  currentAccountId  ' + currentAccountId);
				// after processing opp team members, create records for any roles which exist
				// for brand but not on the opportunity
				for (string accountId :accTeamMap.keySet()){
					if (accountId == currentAccountId){
						map<string, string> accTeamItem = accTeamMap.get(accountId);
system.debug(' @@@@@@@@@@@@@@@  accTeamItem  ' + accTeamItem);
						for (string role :accTeamItem.keySet()){
							if (!matchedRoles.containsKey(role)){
								// need to create a new opp team member record for missing role
								OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
								oppTeamMember.OpportunityId = key;
								oppTeamMember.TeamMemberRole = role;
								oppTeamMember.UserId = accTeamItem.get(role);
								insertList.add(oppTeamMember);
							}
						}
					}
				}
			}
			
			Savepoint sp = Database.setSavepoint();
			try {					
system.debug( ' @@@@@@@@@@@@@@@  deleteList  ' + deleteList);					
				delete deleteList; // delete existing matched role records
				insert insertList; // insert new roles
				
				syncOpportunityRecordPersonnel(oppIdList);
				
			} catch (exception e){
				// Log technical error
				returnValue = 'An error has occurred updating Deals, please contact your System Administrator.';
				system.debug(e.getMessage() + ' : ' + e.getStackTraceString());						
				Database.rollback(sp);
				return returnValue;
			}
				

			
		} catch (exception e){

			returnValue = 'An error has occurred updating Deals, please contact your System Administrator.';
			// Log technical error
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());	
			return returnValue;
						
		}	
		
		return returnValue;
	}

	public static void syncOpportunityRecordPersonnel(list<string> oppIdList){
		
		list<OpportunityTeamMember> oppTeam = [select id, OpportunityId from OpportunityTeamMember where OpportunityId in :oppIdList];	
		
		syncOpportunityPersonnel(oppTeam);
				
	}
		
	// Method used to update the Lead Negotiator VR and Brand Captain fields on the 
	// Opportunity record after changes are made to the related Opportunity Team Members.
	public static void syncOpportunityPersonnel(list<OpportunityTeamMember> oppTeamList){

		try{
			
			list<string> userIdList = new list<string>();
			list<string> oppIdList = new list<string>();
			
			// Retrieve list of Opportunity ids associated with incoming team member list
			for (OpportunityTeamMember ot :oppTeamList){
				oppIdList.add(ot.OpportunityId);			
			}
			
			list<Opportunity> oppList = new list<Opportunity>();
			
			// Rerieve opportunity and team member records to process
			oppList = [select Id, Lead_Negotiator_VR__c, Lead_Negotiator_Brand__c, Brand_Captain__c, Region__c, GRS_Captain__c, China_Brand_Captain__c,
						(Select UserId, TeamMemberRole From OpportunityTeamMembers) 
							from Opportunity where id in :oppIdList];
			
			// Retrieve list of user ids associated with each Opportunity team
			for (Opportunity opp :oppList){
				for (OpportunityTeamMember oppTeamMember :opp.OpportunityTeamMembers){		
					userIdList.add(oppTeamMember.UserId);		
				}
			}
							
			// Query User object with user id list to map the full user name with each user id
			map<ID, User> userNameMap = new Map<ID, User>([SELECT Id, Name FROM User where Id in :userIdList]);
			
			// Loop through the Opportunities to process 
			for (Opportunity opp :oppList){
				string leadNegotiator = null;
				string brandCaptain = null;
				string grsCaptain = null;
				string chinabrandCaptain = null;

				for (OpportunityTeamMember oppTeamMember :opp.OpportunityTeamMembers){				
					
					if (oppTeamMember.TeamMemberRole == 'Lead Negotiator' || 
							oppTeamMember.TeamMemberRole == 'EU Brand Captain' || 
							oppTeamMember.TeamMemberRole == 'China Brand Captain' ||
							oppTeamMember.TeamMemberRole == 'GRS Captain'){
						string sUserName = userNameMap.get(oppTeamMember.UserId).Name;
						if (oppTeamMember.TeamMemberRole == 'Lead Negotiator'){
							leadNegotiator = sUserName;
						} else if (oppTeamMember.TeamMemberRole == 'EU Brand Captain' ){
							brandCaptain = sUserName;
						} else if (oppTeamMember.TeamMemberRole == 'China Brand Captain' ){
							chinaBrandCaptain = sUserName;
						} else if (oppTeamMember.TeamMemberRole == 'GRS Captain'){
							grsCaptain = sUserName;
						}							
					}
					
				}
				
				if (reloadNeeded == null)
					reloadNeeded = false;
					
				if (opp.Lead_Negotiator_VR__c != leadNegotiator){
					opp.Lead_Negotiator_VR__c = leadNegotiator;
					reloadNeeded = true;
				}
				if (opp.Brand_Captain__c != brandCaptain){
					opp.Brand_Captain__c = brandCaptain;
					reloadNeeded = true;
				}
				if (opp.China_Brand_Captain__c != chinaBrandCaptain){
					opp.China_Brand_Captain__c = chinaBrandCaptain;
					reloadNeeded = true;
				}
				if (opp.GRS_Captain__c != grsCaptain) {
					opp.GRS_Captain__c = grsCaptain;
					reloadNeeded = true;	
				}
			}
				
			update oppList;
			
		} catch (exception e){
	
			// Log technical error
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());	
			
		}
	}


/***************** Following code is specific to changes made to Opportunity Contact Roles ********/
	
	// Not possible to put a trigger on the OpportunityContactRole object, therefore have
	// to trigger the required code from an invisbible inline VF page on the Opportunity
	// view.

    public static Opportunity opp; // reference to current Opportunity record

	// Retrieve record context from class constructor when invoked from UI
    public OpportunityTeamMemberSync( ApexPages.StandardController stdController ) {
        opp = ( Opportunity )stdController.getRecord(); 
        reloadNeeded = false;       
    }


	// Properties and methods used to refresh the parent Opportunity view if the 
	// primary contact role is changed
	public String pageURL {set;}
    public static string currentLeadNegotiator = '';
	public static Boolean reloadNeeded {get; set;}	
	
	// Returns the URL of the Opportunity record in question
	public String getPageURL() {
		ApexPages.StandardController sc = new ApexPages.StandardController(opp);	
		PageReference pageRef = sc.view();
		return pageRef.getUrl();	
	}
	
	// Method called by action event of inline VF page to mimic trigger logic
	public PageReference triggerUpdateOppBrandLeadNegotiator(){
		OpportunityTeamMemberSync.updateOppBrandLeadNegotiator(opp.Id);
		
		// 04/03/2015 - update the other opportunity team fields 
		// held at opportunity level 
		// this replicates the code behind the Refresh Key Personnel button
		// (monitor performance issue!)
		syncOpportunityRecordPersonnel(opp.Id);
		return null; 
	}
	
	// Method called from inline VF page to trigger the logic required to update
	// the Lead Brand Negotiator on the Opportunity record with the primary 
	// Opportunity Contact role.
	public static void updateOppBrandLeadNegotiator(Id oppId) {

        OpportunityContactRole[] ocrList = [SELECT ContactId, OpportunityId 
        										FROM OpportunityContactRole
                                         	   	WHERE OpportunityId = :oppId];
        
        syncOpportunityContactRole(ocrList);
	
    }
	
	// Method to synchronise Opportunity Lead Brand Negotiator field with the name of the Primary Opportunity
	//  Contact.
	public static void syncOpportunityContactRole(list<OpportunityContactRole> oppContactRoleList){
		
		try{

			list<string> oppIdList = new list<string>();
			
			for (OpportunityContactRole ocr :oppContactRoleList){
				oppIdList.add(ocr.OpportunityId);			
			}
			
			list<Opportunity> oppList = new list<Opportunity>();
			list<string> contactIdList = new list<string>();
				
			// Query Opportunities associated with contact role list, 
			// ensure query is out of loop for bulk trigger handling
			if (!oppContactRoleList.isEmpty()){
				oppList = [select Id, Lead_Negotiator_VR__c, Lead_Negotiator_Brand__c, Brand_Captain__c,
							(Select ContactId, IsPrimary From OpportunityContactRoles where IsPrimary = true) 
								from Opportunity where id in :oppIdList];			
			
				for (Opportunity o :oppList){
					if (o.OpportunityContactRoles != null){				
						if (!o.OpportunityContactRoles.isEmpty()){
							for (OpportunityContactRole ocr :o.OpportunityContactRoles){
								contactIdList.add(ocr.ContactId);
							}	
						}
					}
				}
			} else { // just retrieve opportunity record if no associated contact roles
				oppList = [select Id, Lead_Negotiator_VR__c, Lead_Negotiator_Brand__c, Brand_Captain__c
								from Opportunity where id = :opp.Id];							
			}

			map<ID, Contact> contactNameMap = new Map<ID, Contact>([SELECT Id, Name FROM Contact where Id in :contactIdList]);

			for (Opportunity o :oppList){
				string leadNegotiator = '';
				if (o.OpportunityContactRoles != null){				
					if (!o.OpportunityContactRoles.isEmpty()){
						leadNegotiator = contactNameMap.get(o.OpportunityContactRoles[0].ContactId).Name;
					}
				}
				
				// Determine if primary contact role person is different than Opportunity Brand
				// Lead Negotiator, if so, need to update Opportunity and inform VF page that
				// parent Opportunity detail page should be reloaded (refreshed).
				currentLeadNegotiator = o.Lead_Negotiator_Brand__c;

				if (string.isBlank(leadNegotiator)){
					if (!string.isBlank(currentLeadNegotiator)){
						o.Lead_Negotiator_Brand__c = leadNegotiator;
						reloadNeeded = true;
					}
				} else if (currentLeadNegotiator != leadNegotiator){ 
					o.Lead_Negotiator_Brand__c = leadNegotiator;
					reloadNeeded = true;
				} else {
					reloadNeeded = false;
				}				
			}
							
			update oppList;
			
		} catch (exception e){
			// Log technical error
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());	
		}

	}


	
}