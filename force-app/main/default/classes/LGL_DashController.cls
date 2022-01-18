public with sharing class LGL_DashController {

	public static final String SAVE_REQUEST_SIGNATURE_NAME = 'Service Request Signature';
	public static final String CHECKOUT_SIGNATURE_NAME = 'Service Checkout Signature';

	@AuraEnabled(cacheable=true)
	public static List<LGL_Service_Type__c> getOfferedServices(String village) {
		return [SELECT Id, Name, LGL_Type__c, LGL_Service_Id__c FROM LGL_Service_Type__c WHERE Id IN (SELECT LGL_Service_Type__c FROM LGL_Service_Offering__c WHERE LGL_Service_Offering_Location__r.Village__c =: village) ORDER BY LGL_Type__c, Name];
	}

	@AuraEnabled(cacheable=true)
	public static List<HFS_Collection_Point__c> getServiceLocations(String village) {
		return [SELECT Id, Name FROM HFS_Collection_Point__c WHERE Village__c =: village AND Id IN (SELECT LGL_Service_Offering_Location__c FROM LGL_Service_Offering__c)];
	}

	@AuraEnabled(cacheable=true)
	public static List <DashRow> getDashInformation(String village) {

		List <DashRow> dashRows = new List <DashRow> ();

		List <LGL_Service_Offering__c> sOfferingList = [SELECT Id, LGL_Service_Offering_Location__r.Name, LGL_Service_Type__c, LGL_Service_Type__r.LGL_Service_Id__c, LGL_Quantity__c, LGL_Manually_Lock__c,
		(SELECT Id, LGL_Status__c FROM Service_Items__r WHERE CreatedDate = TODAY)
		FROM LGL_Service_Offering__c
		WHERE LGL_Service_Offering_Location__r.Village__c =: village
		ORDER BY LGL_Service_Type__r.LGL_Type__c DESC];

		Map <String, Map <Id, DashCell>> offeringsByLocation = new Map <String, Map <Id, DashCell>> ();

		for (LGL_Service_Offering__c sOffering : sOfferingList)  {
			if (offeringsByLocation.containsKey(sOffering.LGL_Service_Offering_Location__r.Name)) {
				offeringsByLocation.get(sOffering.LGL_Service_Offering_Location__r.Name).put(sOffering.LGL_Service_Type__c, new DashCell(sOffering));
			} else {
				offeringsByLocation.put(sOffering.LGL_Service_Offering_Location__r.Name, new Map <Id, DashCell> {sOffering.LGL_Service_Type__c => new DashCell(sOffering)});
			}
		}

		for (String location : offeringsByLocation.keySet()) {
			dashRows.add(new DashRow(location, offeringsByLocation.get(location)));
		}

		return dashRows;


	}

	@AuraEnabled(cacheable=true)
	public static List<ServiceRequestRow> getServiceRequests(String village){

		List <LGL_Service__c> serviceRequests = [SELECT Id, LGL_Guest_Id__c, LGL_Name__c, LGL_HFS_Case__c, toLabel(LGL_Status__c) statusLabel, LGL_Status__c, LGL_Request_Location__r.Name,
		LGL_Luggage_Items__c, LGL_Loan_Items__c, LGL_HFS_Case__r.Guest_Arrive_at_Collection_Point__c
		FROM LGL_Service__c WHERE CreatedDate = TODAY AND LGL_Request_Location__r.Village__c =: village];

		List <ServiceRequestRow> serviceRows = new List <ServiceRequestRow> ();

		for (LGL_Service__c service : serviceRequests) {
			serviceRows.add(new ServiceRequestRow(service));
		}

		return serviceRows;
	}

	@AuraEnabled(cacheable=true)
	public static List<LGL_Service_Offering__c> getServiceOfferings(String village) {
		List<LGL_Service_Offering__c> serviceOfferingList = [SELECT Id, LGL_Service_Type__c, LGL_Service_Type__r.Name, LGL_Service_Type__r.LGL_Service_Id__c, LGL_Quantity__c, LGL_Service_Offering_Location__c, LGL_Service_Offering_Location__r.Name, LGL_Manually_Lock__c,
		(SELECT LGL_Service_Item_Identifier__c FROM Service_Items__r WHERE LGL_Service_Request__r.LGL_Service_Start_Date__c = TODAY AND LGL_Status__c = 'using'),
		(SELECT LGL_Item_Number__c FROM Service_Offering_Items__r ORDER BY LGL_Item_Number__c) 
		FROM LGL_Service_Offering__c WHERE LGL_Service_Offering_Location__r.Village__c =: village 
		ORDER BY LGL_Service_Type__r.LGL_Type__c, LGL_Service_Type__r.Name, LGL_Service_Offering_Location__r.Name];
		return serviceOfferingList;
	}

	@AuraEnabled(cacheable=true)
	public static List<Account> searchGuests (String searchTerm) {

		List <Account> foundGuests =  new List <Account> ();

		if (String.isNotBlank(searchTerm)) {
			Map <String, List<Account>> guestsByTypeMap = HFS_Utils.searchGuests(searchTerm);
			foundGuests.addAll(guestsByTypeMap.get('Guests'));
			foundGuests.addAll(guestsByTypeMap.get('VIP_Guests'));
		}

		return foundGuests;

	}

	@AuraEnabled(cacheable=true)
	public static Account getGuestAccount(String guestId) {

		List<Account> accList = [SELECT Id, Salutation, FirstName, LastName, PersonEmail, PersonMobilePhone, Country_of_Residence__c FROM Account WHERE Id = :guestId];
		if (!accList.isEmpty()) {
			return accList[0];
		}
		return new Account();
	}

	@AuraEnabled(cacheable=true)
	public static List<LGL_Service_Item__c> getServiceItems(String serviceRequestId) {

		List <LGL_Service_Item__c> serviceItemsList = new List <LGL_Service_Item__c> ();
		if (String.isNotBlank(serviceRequestId)) {
			serviceItemsList = [SELECT Id, LGL_Service_Type__c, LGL_Service_Item_Identifier__c, toLabel(LGL_Deposit_Status__c), toLabel(LGL_Status__c), LGL_Service_Name__c, toLabel(LGL_Type__c), LGL_Service_Type_Identifier__c, LGL_Checkout_Time__c, LGL_Service_Offering__r.LGL_Manually_Lock__c, LGL_Service_Offering__c FROM LGL_Service_Item__c WHERE LGL_Service_Request__c =: serviceRequestId];
		}
		return serviceItemsList;
	}

	@AuraEnabled
	public static LGL_Service__c saveServiceRequest (LGL_Service__c serviceRequest, List<LGL_Service_Item__c> serviceItems, String signature, Boolean createPrivilegeAccount) {

		User currentUser = [SELECT Village__c FROM User WHERE Id =: UserInfo.getUserId()];
		Village__c villageRecord = [SELECT Village_Code__c FROM Village__c WHERE Name =: currentUser.Village__c];

		if (createPrivilegeAccount) {
			try {
				HFS_CountryController countriesController = HFS_CountryController.getInstance();
				String privilegeGuestId = apiCustomerController.saveGuest('', serviceRequest.LGL_Title__c, serviceRequest.LGL_First_Name__c, serviceRequest.LGL_Last_Name__c, '0', '',serviceRequest.LGL_Phone__c,serviceRequest.LGL_Email__c, villageRecord.Village_Code__c, 'en-gb','','', '',  '', '',countriesController.getCountryCode(serviceRequest.LGL_Country_Residence__c), 'Hands Free Shopping','NO', 'NO', 'NO');
				serviceRequest.LGL_Guest__c = privilegeGuestId;
			} catch (Exception e) {
				system.debug(e.getMessage());
				system.debug(e.getStackTraceString());
			}
		}

		if (serviceRequest != null && serviceItems != null && signature != null) {


			List<Case> hfsCasesToday = [SELECT Id, Service_Guest_Number__c FROM Case WHERE CreatedDate = TODAY AND SuppliedEmail =: serviceRequest.LGL_Email__c AND Village__r.Name =: currentUser.Village__c];

			if(!hfsCasesToday.isEmpty()) {
				serviceRequest.LGL_HFS_Case__c = hfsCasesToday[0].Id;
				serviceRequest.LGL_Guest_Id__c = hfsCasesToday[0].Service_Guest_Number__c;
			} else {
				List<AggregateResult> maxGuestNumber = [SELECT MAX(LGL_Guest_Id_Number_Part__c) maxValue FROM LGL_Service__c WHERE LGL_Service_Start_Date__c = TODAY];
				serviceRequest.LGL_Guest_Id_Number_Part__c = maxGuestNumber[0].get('maxValue') != null ? (Integer.valueOf(maxGuestNumber[0].get('maxValue')) + 1) : 1;
				serviceRequest.LGL_Guest_Id__c = 'LL' + serviceRequest.LGL_Guest_Id_Number_Part__c;
			}

			serviceRequest.LGL_Service_Start_Date__c = system.now();
			serviceRequest.LGL_Status__c = 'using';
			insert serviceRequest;

			for (LGL_Service_Item__c serviceItem : serviceItems) {
				serviceItem.LGL_Service_Request__c = serviceRequest.Id;
			}

			createServiceItems(serviceItems);

			insertSignature(serviceRequest.Id, signature, SAVE_REQUEST_SIGNATURE_NAME);

			return serviceRequest;

		} else {
			return null;
		}


	}

	@AuraEnabled
	public static void checkoutServices (List <LGL_Service_Item__c> serviceItemsList, String serviceRequestId, String signature) {

		if (!serviceItemsList.isEmpty()) {
			Service_Request_API.checkoutServiceItems(serviceItemsList);
			insertSignature(serviceRequestId, signature, CHECKOUT_SIGNATURE_NAME);
		}
	}

	public static void insertSignature (Id serviceRequestId, String signature, String signatureName) {
        ContentVersion contVers = new ContentVersion();
        contVers.FirstPublishLocationId = serviceRequestId;
        contVers.VersionData = EncodingUtil.base64Decode(signature);
        contVers.Title = signatureName;
        contVers.PathOnClient = signatureName + '.png';
        contVers.OwnerId = UserInfo.getUserId();
        insert contVers;
	}

	@AuraEnabled(cacheable=true)
	public static List<Custom_Label__c> getSalutationLabels(String language){

		List<Custom_Label__c> salutations = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c
											   WHERE Language__c = :language AND Used_in_App__c = 'LGL' AND Used_on_page__c = 'LGLNewServiceForm'
											   AND Name LIKE '%Salutation%' ORDER BY Order__c];

		return salutations;
	}

	@AuraEnabled(cacheable=true)
	public static List<Custom_Label__c> getMethodsTransport(String language){

		List<Custom_Label__c> methodsOfTransport = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c
											   WHERE Language__c = :language AND Used_in_App__c = 'LGL' AND Used_on_page__c = 'LGLNewServiceForm'
											   AND Name LIKE 'Transport%' ORDER BY Order__c];

		return methodsOfTransport;
	}

	@AuraEnabled(cacheable=true)
	public static CountriesResponse getCountries(){

		HFS_CountryController countriesController = HFS_CountryController.getInstance();
		CountriesResponse response = new CountriesResponse();
		response.defaultCountries = countriesController.getDefaultCountries();
		response.otherCountries = countriesController.getOtherCountries();
		return response;
	}

	public class CountriesResponse  {
		@AuraEnabled
		public List <HFS_Country_Data__c> defaultCountries, otherCountries;
	}

	@AuraEnabled(cacheable=true)
	public static List<Guest_Services_Data__c> getGuestTypes(String village){

		return [SELECT Data_Code__c, Data_Label__c FROM Guest_Services_Data__c WHERE Village__c =: village AND Used_In_Application__c = 'LGL' AND Service_Data_Type__c = 'LGL Guest Type'];
	}

	@AuraEnabled(cacheable=true)
	public static List<Guest_Services_Data__c> getDepositStatuses(String village){

		return [SELECT Data_Code__c, Data_Label__c FROM Guest_Services_Data__c WHERE Village__c =: village AND Used_In_Application__c = 'LGL' AND Service_Data_Type__c = 'LGL Deposit Status'];
	}

	@AuraEnabled
	public static void createServiceItems (List <LGL_Service_Item__c> serviceItems) {
		Service_Request_API.createServiceItems(serviceItems);
	}

	@AuraEnabled(cacheable=true)
	public static Village_Privacy_Policy_URLs__c getVillageUrls () {

		User currentUser = [SELECT Village__c FROM User WHERE Id =: UserInfo.getUserId()];
		String customSettingName = currentUser.Village__c + '-' + 'en';
		return [SELECT Name, Village_Privacy_Notice_Link__c, LGL_Terms_And_Conditions__c FROM Village_Privacy_Policy_URLs__c WHERE Name =: customSettingName];
	}

	public class ServiceRequestRow {

		@AuraEnabled
		public String guestID, name, status, statusLabel, lglLocation, hasHFS, arriveCollectionPoint;
		@AuraEnabled
		public Decimal luggageItems, loanItems;
		@AuraEnabled
		public Id serviceId, caseId;

		public ServiceRequestRow (LGL_Service__c service) {

			this.guestID = service.LGL_Guest_Id__c;
			this.name = service.LGL_Name__c;
			this.statusLabel = (String) service.get('statusLabel');
			this.status =  service.LGL_Status__c;
			this.lglLocation = service.LGL_Request_Location__r.Name;
			this.hasHFS = service.LGL_HFS_Case__c != null ? 'YES' : 'NO';
			this.luggageItems = service.LGL_Luggage_Items__c;
			this.loanItems = service.LGL_Loan_Items__c;
			this.serviceId = service.Id;
			this.caseId = service.LGL_HFS_Case__c;
			this.arriveCollectionPoint = service.LGL_HFS_Case__r.Guest_Arrive_at_Collection_Point__c != null ? service.LGL_HFS_Case__r.Guest_Arrive_at_Collection_Point__c.format('h:mm a') : '';

		}
	}

	public class DashRow {

		@AuraEnabled
		public String location;
		@AuraEnabled
		public Map <Id, DashCell> dashCells;

		public DashRow (String location, Map <Id, DashCell> dashCells)  {
			this.location = location;
			this.dashCells = dashCells;
		}

	}

	public class DashCell {

		@AuraEnabled
		public Decimal totalItems, totalUsedItemsToday, itemsInUse;
		@AuraEnabled
		public String serviceTypeIdentifier;
		@AuraEnabled
		public Id serviceOfferingId;
		@AuraEnabled
		public Boolean lockedServiceOffering;

		public DashCell (LGL_Service_Offering__c sOffering)  {
			this.serviceOfferingId = sOffering.Id;
			this.lockedServiceOffering = sOffering.LGL_Manually_Lock__c;
			this.totalUsedItemsToday = sOffering.Service_Items__r.size();
			this.totalItems = sOffering.LGL_Quantity__c != null ? sOffering.LGL_Quantity__c : 0;
			this.serviceTypeIdentifier = sOffering.LGL_Service_Type__r.LGL_Service_Id__c;
			this.itemsInUse = 0;
			for (LGL_Service_Item__c si : sOffering.Service_Items__r) {
				if (si.LGL_Status__c == 'using') {
					this.itemsInUse++;
				}
			}
		}
	}

}