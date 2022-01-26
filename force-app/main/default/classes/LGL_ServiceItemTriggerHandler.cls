public inherited sharing class LGL_ServiceItemTriggerHandler {

	public static void updateCheckoutDate (Map <Id, LGL_Service_Item__c> oldServiceItems, List <LGL_Service_Item__c> newServiceItems) {

		for (LGL_Service_Item__c serviceItem : newServiceItems) {
			if (hasBeenClosed(oldServiceItems.get(serviceItem.Id), serviceItem)) {
				serviceItem.LGL_Checkout_Time__c = system.now();
			}
		}

	}

	/*
	 * Method that checks for all the Service Items that have been closed. Then, if all the Service Items for a certain Service Request
	 * have been closed, closes the Service Request itself
	 */

	public static void closeServiceRequests (Map <Id, LGL_Service_Item__c> oldServiceItems, List <LGL_Service_Item__c> newServiceItems) {

		Set <Id> serviceRequestIdsList = new Set <Id> ();

		for (LGL_Service_Item__c serviceItem : newServiceItems) {
			if (hasBeenClosed(oldServiceItems.get(serviceItem.Id), serviceItem)) {
				serviceRequestIdsList.add(serviceItem.LGL_Service_Request__c);
			}
		}

		List <LGL_Service__c> serviceRequests = [SELECT (SELECT Id, LGL_Status__c FROM Service_Items__r) FROM LGL_Service__c WHERE Id IN: serviceRequestIdsList];
		List <LGL_Service__c> serviceRequestsToUpdate = new List <LGL_Service__c> ();

		for (LGL_Service__c serviceRequest : serviceRequests) {
			Boolean allClosed = true;
			for (LGL_Service_Item__c serviceItem : serviceRequest.Service_Items__r) {
				if (serviceItem.LGL_Status__c != 'closed') {
					allClosed = false;
				}
			}
			if (allClosed) {
				serviceRequest.LGL_Status__c = 'closed';
				serviceRequestsToUpdate.add(serviceRequest);
			}
		}

		update serviceRequestsToUpdate;

	}

	/*
	 * When inserting new Service Items, check the status of the Service Request and, in case that is already Closed, update to Using
	 * because a new item has been requested for the Service Request
	 */

	public static void checkAnUpdateCloseServiceRequests (List <LGL_Service_Item__c> newServiceItems) {

		Set <Id> serviceRequestsToCheck = new Set <Id> ();

		for (LGL_Service_Item__c newServiceItem : newServiceItems) {
			if (newServiceItem.LGL_Status__c != 'closed') {
				serviceRequestsToCheck.add(newServiceItem.LGL_Service_Request__c);
			}
		}

		if (!serviceRequestsToCheck.isEmpty()) {

			List <LGL_Service__c> serviceRequestsToUpdate = new List<LGL_Service__c> ();

			for (LGL_Service__c serviceRequest : [SELECT Id, LGL_Status__c FROM LGL_Service__c WHERE Id IN: serviceRequestsToCheck]) {
				if (serviceRequest.LGL_Status__c == 'closed') {
					serviceRequest.LGL_Status__c = 'using';
					serviceRequestsToUpdate.add(serviceRequest);
				}
			}

			update serviceRequestsToUpdate;
		}
	}

	public static Boolean hasBeenClosed (LGL_Service_Item__c oldServiceItem, LGL_Service_Item__c newServiceItem) {

		return (newServiceItem.LGL_Status__c == 'closed' && oldServiceItem.LGL_Status__c != 'closed');

	}

}