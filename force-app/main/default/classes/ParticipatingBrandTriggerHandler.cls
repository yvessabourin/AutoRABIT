public with sharing class ParticipatingBrandTriggerHandler{

	public static void handleBeforeInsert(List<Participating_Brand__c> newBrandList){
		List<Participating_Brand__c> brandList = new List<Participating_Brand__c>();

		for(Participating_Brand__c brand : newBrandList){
			if(brand.Marketing_Campaign__c == null && brand.Marketing_Activity__c != null){
				brandList.add(brand);
			}
		}

		if(brandList != null && !brandList.isEmpty()){
			getMarketingCampaign(brandList);
		}
	}

	public static void handleBeforeUpdate(Map<Id, Participating_Brand__c> oldBrandMap, Map<Id, Participating_Brand__c> newBrandMap){
		List<Participating_Brand__c> brandList = new List<Participating_Brand__c>();

		for(Participating_Brand__c brand : newBrandMap.values()){
			if(brand.Marketing_Campaign__c == null && brand.Marketing_Activity__c != null){
				brandList.add(brand);
			}
		}

		if(brandList != null && !brandList.isEmpty()){
			getMarketingCampaign(brandList);
		}
	}

	public static void getMarketingCampaign(List<Participating_Brand__c> brandsToUpdate){
		Map<Id, Id> campaignmap = new Map<Id, Id>();
		List<Marketing_Activity__c> actList = new List<Marketing_Activity__c>();

		for(Participating_Brand__c brand : brandsToUpdate){
			campaignmap.put(brand.Marketing_Activity__c, null);
		}

		actList = [SELECT Id, Marketing_Campaign__c 
					FROM Marketing_Activity__c 
					WHERE Id IN :campaignmap.keySet()];

		if(actList != null && !actList.isEmpty()){
			for(Marketing_Activity__c act : actList){
				if(act.Marketing_Campaign__c != null){
					campaignmap.put(act.Id, act.Marketing_Campaign__c);
				}
			}
		}

		for(Participating_Brand__c brand : brandsToUpdate){
			if(campaignmap.keySet().contains(brand.Marketing_Activity__c)){
				brand.Marketing_Campaign__c = campaignmap.get(brand.Marketing_Activity__c);
			}
		}
	}
}