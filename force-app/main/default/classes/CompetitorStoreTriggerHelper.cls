public with sharing class CompetitorStoreTriggerHelper {

	public static boolean hasUpdated = false;
	
	//Method to associate village presence with competitor store if brand has a village presence 
	public static void LinkVillagePresence(map<Id, Competitor_Store__c> storeMap){
		
		//extract brand and village from upserted competitor stores
		list<Competitor_Store__c> storeList = [select Brand__c, Competitor_Site__r.Competitor_to_Village__c 
												from Competitor_Store__c
												where id in :storeMap.keySet()];
												
		set<string> brandList = new set<string>();
		set<string> villageList = new set<string>();
		set<string> storebrandVillageList = new set<string>();
		map<string, string> storeBrandVillageMap = new map<string, string>();
		for (Competitor_Store__c store :storeList){
			string brand = store.Brand__c;
			string village = store.Competitor_Site__r.Competitor_to_Village__c;
			if (string.isnotBlank(brand) && string.isnotBlank(village)){
				brandList.add(brand);
				villageList.add(village);
				storeBrandVillageMap.put (brand+village, store.Id);
			}						
		}
		// query village presences to see if store brand and village exist										
		list<Village_Presence__c> vpList = new list<Village_Presence__c>();
		if (!brandList.isEmpty() && (!villageList.isEmpty())){
			vpList = [select Id, Brand__c, Village__c from Village_Presence__c where
						Brand__c in :brandList and Village__c in :villageList];
			map<Id, Id> storeUpdateMap = new map<Id, Id>();			
			if (!vpList.isEmpty()){
				for(Village_presence__c vp :vpList){
					string brand = vp.Brand__c;
					string village = vp.Village__c;
					string storeId = storeBrandVillageMap.get(brand+village);
					storeUpdateMap.put(storeId, vp.Id);				
				}
				// update stores village presence reference if brand has a village presence
				list<Competitor_Store__c> storeUpdateList = new list<Competitor_Store__c>();
				storeUpdateList = [select Id, Village_Presence__c from Competitor_Store__c where Id in :storeUpdateMap.keySet()];
				for (Competitor_Store__c store :storeUpdateList){
					store.Village_Presence__c = storeUpdateMap.get(store.Id);
				}
				hasUpdated = true;
				update storeUpdateList;
				
			}			
			
		}
		
		
		
	}


}