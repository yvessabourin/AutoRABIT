public inherited sharing class Service_Request_API {

	public static String NEW_SERVICE_ITEM_STATUS = 'using';
	public static String CLOSED_SERVICE_ITEM_STATUS = 'closed';

	public static List<LGL_Service_Item__c> checkoutServiceItems (List <LGL_Service_Item__c> serviceItems) {

		if (serviceItems != null) {
			for (LGL_Service_Item__c serviceItem : serviceItems) {
				serviceItem.LGL_Status__c = CLOSED_SERVICE_ITEM_STATUS;
				serviceItem.LGL_Checkout_Time__c = system.now();
			}
		}
		update serviceItems;
		return serviceItems;
	}

	public static List <LGL_Service_Item__c> createServiceItems (List <LGL_Service_Item__c> serviceItems) {

		for (LGL_Service_Item__c serviceItem : serviceItems) {
			serviceItem.LGL_Status__c = NEW_SERVICE_ITEM_STATUS;
		}

		insert serviceItems;
		return serviceItems;
	}

}