public without sharing class VillagePresenceUtilities {
	
	public static boolean updateProcessed = false;

	//send and return a single instance of a Village Presence record
	public static Village_Presence__c getVillagePresence(string village, string brand){
	
		Village_Presence__c villagePresence = null;
		try{
			villagePresence	= [SELECT id, name, village__r.name, village__r.Village_code__c, 
								Brand__r.name 
								FROM Village_Presence__c 
								WHERE (Village__r.Name = :village OR Village__r.Village_Code__c = :village)
								AND (Brand__r.Name = :brand) 								
								LIMIT 1];
		} catch (Exception e){
			villagePresence = null;	
		}	
							 
		return villagePresence;
	}//end method


	//[overload]send and return a map of village presence records given an account and list of villages
	public static map<string, map<string,Village_Presence__c>> getVillagePresence(map<string, list<string>> brandsVillages){
		
		//extract all the brands
		set<string> brandset = brandsVillages.keyset();
			system.debug('brandset: ' + brandset);
		
		set<string> villageset = new set<string>();
		
		//extract all the villages and put them in the set
		for (string brand : brandset) {
				
		 	list<string> villages =  brandsVillages.get(brand);
			
			for (string village : villages){
				villageset.add(village);
			}
				
		}

		//Get all possible village presences given all villages from all brands (OR) from above variables
		//This enables us to run just one SOQL call.
		list<Village_Presence__c> villagePresences = [SELECT id, name, unit__c, village__r.name, village__r.Village_code__c, brand__r.name
														 FROM Village_Presence__c WHERE (Village__r.Name in :villageset OR Village__r.Village_Code__c in :villageset) AND brand__r.Name in :brandset];
		
		//create a map that matches the return type of the method
		map<string, map<string,Village_Presence__c>> brandVillagePresences = new map<string, map<string,Village_Presence__c>>();
			
			
		//loop through all the unique brands sent through
		for (string brand: brandset){
						
			//create the village-->village presence map which is embedded into the brandVillagePresences map
			map<string ,Village_Presence__c> villagePresence = new map<string ,Village_Presence__c>();
			
			//now loop through the village presence records that were returned from our 1 x soql
			for (Village_Presence__c vp : villagePresences ) {	
				//if the brand we are looping through matches the brand on the village presence then add the record
				//details to the village-->village presence map 
				if(brand == vp.brand__r.name){					
					villagePresence.put(vp.village__r.name, vp);
				}
			}
			//add to brandVillageTenancies MAP here
			brandVillagePresences.put(brand, villagePresence);
		
		}//end loop. Go and fetch the next brand and go through the returned village presences again.
	
		
		return brandVillagePresences;
	}//close method


	// method to create a village presence
	public static Village_Presence__c createVillagePresence(Id brandId, string village){
		
		string defaultStatus = 'Open';
		
		VR1_Configuration_Settings__c profileSettings = VR1_Configuration_Settings__c.getInstance();
		string defaultVPStatus = profileSettings.Default_VP_Status__c;
		
		if (string.isNotBlank(defaultVPStatus)){
			defaultStatus = defaultVPStatus;
		} else {
			VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
			defaultVPStatus = orgSettings.Default_VP_Status__c;
			if (string.isnotblank(defaultVPStatus)){
				defaultStatus = defaultVPStatus;
			}			
		}
		
		Village_Presence__c villagePresence = null;

		Id villageId = [select Id from village__c where name=:village or village_code__c =:village].Id;

		villagePresence = new Village_Presence__c(village__c = villageId, 
														Brand__c = brandId, 
														Name = '<Blank>',
														Status__c = defaultStatus
														);


		insert villagePresence;
		
		
		return villagePresence;
	}
	
	// method to create a village presence
	// overloaded, to be able to accept villageID instead of querying all the time
	public static Village_Presence__c createVillagePresence(Id brandId, Id villageId, boolean insertObject){
		
		string defaultStatus = 'Open';
		
		VR1_Configuration_Settings__c profileSettings = VR1_Configuration_Settings__c.getInstance();
		string defaultVPStatus = profileSettings.Default_VP_Status__c;
		
		if (string.isNotBlank(defaultVPStatus)){
			defaultStatus = defaultVPStatus;
		} else {
			VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
			defaultVPStatus = orgSettings.Default_VP_Status__c;
			if (string.isnotblank(defaultVPStatus)){
				defaultStatus = defaultVPStatus;
			}			
		}
		
		Village_Presence__c villagePresence = null;

		//Id villageId = [select Id from village__c where name=:village or village_code__c =:village].Id;

		villagePresence = new Village_Presence__c(village__c = villageId, 
														Brand__c = brandId, 
														Name = '<Blank>',
														Status__c = defaultStatus
														);

		if(insertObject){
			insert villagePresence;
		}
		
		return villagePresence;
	}

	// Method to default village presence name after insert or update
	public static void defaultName(Set<Id> villagePresenceIds){
	
		if (!villagePresenceIds.isEmpty()){
			
			list<Village_Presence__c> villagePresenceList = [select name, brand__r.name, village__r.name from Village_Presence__c where id in:villagePresenceIds];
			if (!villagePresenceList.isEmpty()){
					for (Village_Presence__c villagePresence : villagePresenceList){
							string brand = villagePresence.brand__r.name;
							string village = villagePresence.village__r.name;
							
							string name = brand + ' in ' + village;
							villagePresence.name = name;
						}
				update villagePresenceList;
			}
		}	
	}


	// Method to check if duplicate village presence record already exists
	public static list<Village_Presence__c> checkDuplicate(list<Village_Presence__c> vpList){
	
		set<string> brandIds = new set <string>();
		set<string> villageIds = new set<string>();
		
		for (Village_Presence__c vp :vpList){
			brandIds.add(vp.brand__c);
			villageIds.add(vp.village__c);
		}
		
		if (!vpList.isEmpty()){
			map<Id, Village_presence__c> vpQueryMap = new map<Id, Village_Presence__c>([select id, brand__c, village__c,
																						brand__r.name, village__r.name 
																						from Village_Presence__c
								 														where brand__c in :brandIds and village__c in :villageIds]); 
			
			for (Village_Presence__c villagePresence :vpList){
				string brand = villagePresence.brand__c;
				string village = villagePresence.village__c;
				for (Village_Presence__c vpChk : vpQueryMap.values()) {				
					if (brand == vpChk.brand__c && village == vpChk.village__c){
	        			VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
	        			string url = settings.Salesforce_Instance_URL__c;
	        			url += '/' + vpChk.Id;						  
						string msg = vpChk.brand__r.name +' already exists in ' + vpChk.village__r.name;
						villagePresence.addError(msg, false);
					
					}
				}
				
			}

		}	
		
		return vpList;
		
	}

	
	// Method to keep in sync the village presence list held at contact level with any village roles 
	// created for the contact
	//@future
	public static void refreshContactVillagePresence(list<string> contactIdList){
		
		// retrieve map of contacts for later update
		map<Id, Contact> contactMap = new map<Id, Contact>([select id, village_presence__c from contact where id in :contactIdList]);
		
		// create a map to store the contact village data 
		map <Id, set<string>> contactVillageMap = new map<Id, set<string>>();
		
		if (!contactMap.isEmpty()){
			// retrieve village contact roles for the contacts required
			list<Village_Presence_Contact_Role__c> contactRoleList = new list <Village_Presence_Contact_Role__c>();
			contactRoleList = [select Village_Presence__r.village__r.name, contact__r.Id
								from Village_Presence_Contact_Role__c
								where contact__r.Id in:contactIdList];
		
			// loop through village contact roles to populate contact village mapping
			for (Village_Presence_Contact_Role__c contactRole :contactRoleList){
				set<string> villageList = contactVillageMap.get(contactRole.contact__r.Id);
				if (villageList == null){
					villageList = new set<string>();
				}
				villageList.add(contactRole.Village_Presence__r.village__r.name);
				contactVillageMap.put(contactRole.Contact__r.Id, villageList);		
			}
			
			// loop through contact list to update village presence field with villages
			// identified for the contact
			for (Contact c :contactMap.values()){
				string contactVillages = '';
				set<string> villages = new set<string>();
				villages = contactVillageMap.get(c.Id);
				if (villages != null){
					if (!villages.isEmpty()){
						for(string village :villages){
							contactVillages += village + ';';
						}
					}
				}
								
				c.Village_Presence__c = contactVillages;
				
			}
			update contactMap.values();
		
		}	
		
		
	}
	
	public static void recalculateBrandAssignmentType(List<Village_Presence__c> newlist){
		// now we serialize this data, and hand it to the future method
		List<String> newlistJSON = new List<String>();

		for(Village_Presence__c VP : newlist){
			newlistJSON.add(JSON.serialize(VP));
		}

		recalculateBrandAssignmentType(newlistJSON);

	}

	@future
	private static void recalculateBrandAssignmentType(List<String> newlistJSON){
		// this is just to trigger the 'tickle' of the brand, so that the assignment type gets recalculated.
		Set<ID> VPIds = new Set<ID>();
		Village_Presence__c VP = null;
   		for (String ser : newlistJSON)
     	{
       		VP = (Village_Presence__c)JSON.deserialize(ser, Village_Presence__c.class);
       		if(!VPIds.contains(VP.Brand__c)){
				VPIds.add(VP.Brand__c);
			}
     	}

/*
		for(Village_Presence__c VP :newlist){
			if(!VIPIds.contains(VP.Brand__c)){
				VIPIds.add(VP.Brand__c);
			}
		}*/

		List<Account> accs = [Select ID, Assignment_Type__c FROM Account WHERE ID in :VPIds];

		for(Account ac :accs){
			// just blanking the assignment type. this will force the brand account trigger.
			ac.Assignment_Type__c = '';
		}
		update accs;
	}

	// Method to link any existing competitor stores with village presence when VP upserted
	//@future
	public static void linkCompetitorStores(set<Id> vpIdList){
		
		set<Id> brandList = new set<Id>();
		set<Id> villageList = new set<Id>();
		
		list<Village_Presence__c> vpList = [select Id, Brand__c, Village__c from Village_Presence__c where Id in:vpIdList];
		map<string, Id> vpMap = new map<string, Id>();
		
		for (Village_presence__c vp :vpList){
			string brand = vp.Brand__c;
			string village = vp.Village__c;
			brandList.add(brand);
			villageList.add(village);
			vpMap.put(brand + village, vp.Id);			
		}
		
		list<Competitor_Store__c> storeUpdateList = new list<Competitor_Store__c>();
		
		storeUpdateList = [select Id, Brand__c, Village_Presence__c, Competitor_Site__r.Competitor_to_Village__c
							from Competitor_Store__c 
							where 
							Brand__c in :brandList and  
							Competitor_Site__r.Competitor_to_Village__c in :villageList];
		
		if (!storeUpdateList.isEmpty()){
			for (Competitor_store__c store :storeUpdateList){
				string brand = store.Brand__c;
				string village = store.Competitor_Site__r.Competitor_to_Village__c;
				string vpId = vpMap.get(brand + village);
				if (!string.isBlank(vpId)){
					store.Village_Presence__c = vpId;
				}
			}
			update storeUpdateList;
		}					
		
		
	}

	public static void defaultNameOnUpdate(List<Village_Presence__c> oldMap, List<Village_Presence__c> newMap){

		Set<Id> oldValueUpdatedVP = new Set<Id>();
		for(Village_Presence__c oldValue : oldMap){
			oldValueUpdatedVP.add(oldValue.Id);
		}

		List<Village_Presence__c> oldVillagePresenceList = [SELECT Name, Brand__r.Name, Village__r.Name FROM Village_Presence__c WHERE Id IN:oldValueUpdatedVP];

		for(Village_Presence__c theOldVP : oldVillagePresenceList){
			for (Village_Presence__c villagePresence : newMap){
				if(theOldVP.Id == villagePresence.Id && theOldVP.Name != villagePresence.Name){
					string brand = theOldVP.Brand__r.Name;
					string village = theOldVP.village__r.name;
					
					string name = brand + ' in ' + village;
					villagePresence.name = name;
				}
			}
		}
	}

	public static void changeCertificationType(List<Village_Presence__c> oldMap, List<Village_Presence__c> newMap){
		
		Map<Id, String> newValuesMap = new Map<Id, String>();
		Map<Id, Boolean> newCheckboxMap = new Map<Id,Boolean>();
		Map<Id, String> newVCMap = new Map<Id, String>();
		Set<Id> setIds = new Set<Id>();

		for(Village_Presence__c newValue : newMap){
			newCheckboxMap.put(newValue.Id, newValue.CertSales_Active__c);
			newValuesMap.put(newValue.Id, newValue.CertSales_CertPeriod_Type__c);
			newVCMap.put(newValue.Id, newValue.Village__r.Village_Code__c);
		}

		for(Village_Presence__c oldValue : oldMap){
			if(oldValue.CertSales_Active__c == true && newCheckboxMap.get(oldValue.Id) == true){
				if(oldValue.CertSales_CertPeriod_Type__c != newValuesMap.get(oldValue.Id)){
                    setIds.add(oldValue.Id);
				}
			}
		}

		if(!setIds.isEmpty()){
			List<Daily_Sales_Certification_Batch__c> updDSCB = new List<Daily_Sales_Certification_Batch__c>();
			List<Daily_Sales_Certification_Batch__c> newDSCB = new List<Daily_Sales_Certification_Batch__c>();
			List<Daily_Sales_Certification_Batch__c> allActiveDSCB = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Village_Presence__c, Village_Presence__r.Name
																	FROM Daily_Sales_Certification_Batch__c
																	WHERE Village_Presence__c = :setIds
																	AND Period_Start_Date__c <= :system.today()
                                                    				AND Period_End_Date__c >= :system.today()];

	        Date todayDate = system.today();
        	Integer numberOfDays = Date.daysInMonth(todayDate.year(),todayDate.month());
        	Date lastDayOfMonth = Date.newInstance(todayDate.year(), todayDate.month(), numberOfDays);

			for(Daily_Sales_Certification_Batch__c theDSCB : allActiveDSCB){
				if(newValuesMap.get(theDSCB.Village_Presence__c) == 'Monthly'){
					theDSCB.Period_End_Date__c = lastDayOfMonth;
					updDSCB.add(theDSCB);
				} else if(newValuesMap.get(theDSCB.Village_Presence__c) == 'Quarterly'){
					if(todayDate.month() == 1 || todayDate.month() == 4 || todayDate.month() == 7 || todayDate.month() == 10){
				        
				        Daily_Sales_Certification_Batch__c firstCertification = new Daily_Sales_Certification_Batch__c();
					    firstCertification.Certification_Batch_Village_Code__c = newVCMap.get(theDSCB.Village_Presence__c);
					    firstCertification.Status__c = 'Generated';
					    firstCertification.Village_Presence__c = theDSCB.Village_Presence__c;
					    firstCertification.Certification_Period_Type__c = 'Monthly';
						firstCertification.Period_Start_Date__c = Date.newInstance(todayDate.year(), todayDate.month()+1, 1);
			            firstCertification.Name = theDSCB.Village_Presence__r.Name + ' - ' + Integer.valueOf(todayDate.month()+1) + '/' + todayDate.year();
			            Integer firstNumbDays = Date.daysInMonth(todayDate.year(),todayDate.month()+1);
			            firstCertification.Period_End_Date__c = Date.newInstance(todayDate.year(), todayDate.month()+1, firstNumbDays);
			            firstCertification.Period_Name__c = Integer.valueOf(todayDate.month()+1) + '/' + todayDate.year();
			            newDSCB.add(firstCertification);

						Daily_Sales_Certification_Batch__c secondCertification = new Daily_Sales_Certification_Batch__c();
					    secondCertification.Certification_Batch_Village_Code__c = newVCMap.get(theDSCB.Village_Presence__c);
					    secondCertification.Status__c = 'Generated';
					    secondCertification.Village_Presence__c = theDSCB.Village_Presence__c;
					    secondCertification.Certification_Period_Type__c = 'Monthly';
						secondCertification.Period_Start_Date__c = Date.newInstance(todayDate.year(), todayDate.month()+2, 1);
			            secondCertification.Name = theDSCB.Village_Presence__r.Name + ' - ' + Integer.valueOf(todayDate.month()+2) + '/' + todayDate.year();
			            Integer secondNumbDays = Date.daysInMonth(todayDate.year(),todayDate.month()+2);
			            secondCertification.Period_End_Date__c = Date.newInstance(todayDate.year(), todayDate.month()+2, secondNumbDays);
			            secondCertification.Period_Name__c = Integer.valueOf(todayDate.month()+2) + '/' + todayDate.year();
			            newDSCB.add(secondCertification);

					} else if(todayDate.month() == 2 || todayDate.month() == 5 || todayDate.month() == 8 || todayDate.month() == 11){

				        Daily_Sales_Certification_Batch__c firstCertification = new Daily_Sales_Certification_Batch__c();
					    firstCertification.Certification_Batch_Village_Code__c = newVCMap.get(theDSCB.Village_Presence__c);
					    firstCertification.Status__c = 'Generated';
					    firstCertification.Village_Presence__c = theDSCB.Village_Presence__c;
					    firstCertification.Certification_Period_Type__c = 'Monthly';
						firstCertification.Period_Start_Date__c = Date.newInstance(todayDate.year(), todayDate.month()+1, 1);
			            firstCertification.Name = theDSCB.Village_Presence__r.Name + ' - ' + Integer.valueOf(todayDate.month()+1) + '/' + todayDate.year();
			            Integer firstNumbDays = Date.daysInMonth(todayDate.year(),todayDate.month()+1);
			            firstCertification.Period_End_Date__c = Date.newInstance(todayDate.year(), todayDate.month()+1, firstNumbDays);
			            firstCertification.Period_Name__c = Integer.valueOf(todayDate.month()+1) + '/' + todayDate.year();
			            newDSCB.add(firstCertification);
					}
				}
			}

			try{
				insert newDSCB;
				update updDSCB;
	        } catch (Exception e){
	            logFile__c log = new logFile__c();
	            log.Body__c = 'Error on update or insert certifications on VillagePresenceUtilities class on changeCertificationType method. With the following mesage: ' + e.getMessage();
	            log.Type__c = 'Update/Insert a list of remaing/news Certification Batches on VP trigger';
	            insert log;
	            system.debug('Exist an error on update or insert certifications on VillagePresenceUtilities class on changeCertificationType method. With the following mesage: ' + e.getMessage());
        	}
		}
	}

	public static void avoidBlankCertification(List<Village_Presence__c> newMap){

		Set<Id> existedVP = new Set<Id>();

		for(Village_Presence__c vp : newMap){
			if(vp.Status__c == 'Exited'){
				existedVP.add(vp.Id);
			}
		}

		if(!existedVP.isEmpty()){
			// Get Certification Batch where start date is superior of todays date
			List<Daily_Sales_Certification_Batch__c> allActiveDSCB = [SELECT Id, Period_Start_Date__c, Village_Presence__c, Village_Presence__r.Name
																	FROM Daily_Sales_Certification_Batch__c
																	WHERE Village_Presence__c = :existedVP
																	AND Period_Start_Date__c >= :system.today()];

			if(!allActiveDSCB.isEmpty()){
				try{
					delete allActiveDSCB;
				} catch (Exception e){
		            logFile__c log = new logFile__c();
		            log.Body__c = 'Error on delete certifications on VillagePresenceUtilities class on avoidBlankCertification method. With the following mesage: ' + e.getMessage();
		            log.Type__c = 'Delete a list of empty Certification Batches on VP trigger when they aren\'t necessary';
		            insert log;
		            system.debug('Exist an error on delete certifications on VillagePresenceUtilities class on avoidBlankCertification method. With the following mesage: ' + e.getMessage());
				}
			}
		}
	}
}