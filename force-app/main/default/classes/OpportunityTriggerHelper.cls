public with sharing class OpportunityTriggerHelper {

	// This method updates the Opportunity name with the format, <<Brand in Village, Unit (if applicable)>>
	// When called from trigger after insert, the second input argument oppList will be null.
	// When called from OpportunityProjectionYieldCalculator class as a result of an update, the first input
	// argument oppMap will be null and the oppList will already be populated.
	// This method also sets/creates a village presence reference for the opportunity. 
	public static boolean hasRun = false;
	
	public static list<Opportunity> updateOpportunityName(map<Id, Opportunity> oppMap, list<Opportunity> oppList){
		
		if (hasRun){
			return null;
		} else {
			hasRun = true;
		}

		
		list<Opportunity> returnList = new list<Opportunity>();
		
		if (oppList == null){	
			oppList = [select  Name, RecordType.Name, Account.Name, village__r.Name, unit__r.Name, village_presence__c 
										from Opportunity
										where Id in:oppMap.keySet()
										and IsWon = false];
		}								
		if (oppList != null){
			
			map<string, list<string>> oppVillageMap = new map<string, list<string>>();
			for (Opportunity opp :oppList){
				string recType = opp.RecordType.Name;
				string typeName = '';
				if (String.isnotBlank(recType)){
					typeName = recType.split(' ')[0]; //take first word of record type
				}
				string name = opp.Account.Name + ' in ' + opp.village__r.Name ;
				if (string.isnotBlank(opp.unit__r.name)){
					name += ' (' + opp.unit__r.name + ')';				
				}
				opp.Name = name + ' - ' + typeName;
				// prepare search parameters for village presence search
				list<string> villageList = oppVillageMap.get(opp.Account.Name);
				if (villageList == null){
					villageList = new list<string>();
				}
				villageList.add(opp.Village__r.name);
				if (!opp.IsWon)
				oppVillageMap.put(opp.Account.Name, villageList);				
			}
	
			if (!oppVillageMap.isEmpty()){
				// search for associated village presence records
				map<string, map<string,Village_Presence__c>> vpMap = VillagePresenceUtilities.getVillagePresence(oppVillageMap);

				if (vpMap != null){
					for (Opportunity opp :oppList){
						map<string, Village_Presence__c> oppVpMap = vpMap.get(opp.Account.Name);
					
						Village_Presence__c vp = null;
						if (oppVpMap != null){
							vp = oppVpMap.get(opp.Village__r.name);
							// set opportunity village presence reference
							if (vp != null){
								opp.Village_Presence__c = vp.Id;
								id RecId = [SELECT id from RecordType where name = 'Exit'].id;
								if(opp.RecordTypeid == RecId){
									opp.Unit__c = vp.Unit__c;
								}
							} else {
								// CC - 06/08/2014 - Need to Fix!! - causes too many soql statements governor limit error when bulk update to opps
								// and new VP is needed.
system.debug(' @@@ vp ... ' + opp.Account.Id + ' ---  ' +  opp.Village__r.name);	

								vp = villagePresenceUtilities.createVillagePresence(opp.Account.Id, opp.Village__r.name);	
								opp.Village_Presence__c = vp.Id;
								
								map<string,Village_Presence__c> newVPMap = new map<string, Village_Presence__c>();
								newVPMap = vpMap.get(opp.Account.Name);
								if (newVPMap == null){
									newVPMap = new map<string, Village_Presence__c>();
								}
								newVPMap.put(opp.Village__r.name, vp);
								
								vpMap.put(opp.Account.Name, newVPMap);
							}	
						}
						
						
					}
				}
			}
			if (oppMap != null && oppList != null){
				update oppList;			
			} else {
				returnList = oppList;
			}
		}										
		
		return returnList;	


	}


}