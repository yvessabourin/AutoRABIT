public with sharing class HFSBagTriggerHandler {

    public static void insertedBagsUpdate(List<HFS_Bag__c> newInsertedBags){
		// List<HFS_Bag__c> updatedBags = new List<HFS_Bag__c>();
		// The list of inserted Bags are always related with a unique purchase
		String purchaseId = newInsertedBags[0].HFS_Purchase__c;

		Case_Item__c thePurchase = [SELECT Id, Require_a_Runner__c FROM Case_Item__c WHERE Id = :purchaseId];
		if(thePurchase.Require_a_Runner__c == FALSE){
			HFS_Job__c theJob = [SELECT Id FROM HFS_Job__c WHERE HFS_Purchase__c = :purchaseId];
			for(HFS_Bag__c theBag : newInsertedBags){
				theBag.HFS_Job__c = theJob.Id;
			}
		}
    }
}