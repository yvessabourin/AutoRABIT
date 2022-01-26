/*
 * This class tests the core functionality of the Luggage & Loans Application. This class involves the testing of the main LGL_DashController class
 * but also related functionality classes:
 *  -LGL_DashController ApexClass
 *  -LGL_ManageItemsController ApexClass
 *  -LGL_ServiceItemTriggerHandler ApexClass
 *  -ServiceItemTrigger ApexTrigger
 * 
 *   LastModifiedDate   Author
 *   --------------------------------------
 *   28/10/2020         Oscar Gomez (everis)
 */


@isTest
public class LGL_Base_Functionality_TEST {

    private static String encodedSignature = 'iVBORw0KGgoAAAANSUhEUgAAAPoAAACW';

    @TestSetup
    static void setupData(){

        LGL_Testing_Utils.createServiceOfferingHierarchy();
        
    }

    /*
     * Test for the base getter methods for the LGL_DashController. The base objects are created and
     * the information obtained by the core methods is checked.
     */ 
    static testmethod void baseGettersTest() {
        
        //Create the Accounts
        Account privilegeGuest1 = LGL_Testing_Utils.createPrivilegeAccount('gorwell@test.com');
        Account privilegeGuest2 = LGL_Testing_Utils.createPrivilegeAccount('rdavies@test.com');
        Account vipGuest1 = LGL_Testing_Utils.createVIPAccount('eferrante@test.com');
        insert new List <Account> {privilegeGuest1, privilegeGuest2, vipGuest1};

        User bicesterUser = LGL_Testing_Utils.createUser('Bicester');
        insert bicesterUser;

        Map <String, LGL_Service_Offering__c> serviceOfferingsMap = LGL_Testing_Utils.getServiceOfferingsMap('Bicester');

        //To avoid more queries, we use the already created map to get the BTA Location Id (doesn't really matter which particular service we use)
        LGL_Service__c serviceRequestBTA = LGL_Testing_Utils.createServiceRequest(serviceOfferingsMap.get('Bicester The Apartment_lLugg').LGL_Service_Offering_Location__c);
        insert serviceRequestBTA;

        List <LGL_Service_Item__c> serviceItemsList = new List <LGL_Service_Item__c> ();
        serviceItemsList.add(LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_lLugg').Id,'lLugg1'));
        serviceItemsList.add(LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair1'));
        serviceItemsList.add(LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair2'));
        insert serviceItemsList;
        
        Test.startTest();
        //Service Type getter
        List <LGL_Service_Type__c> serviceTypesList = LGL_DashController.getOfferedServices('Bicester');
        system.assertEquals(5, serviceTypesList.size());

        //---------------------------------

        //Service Location Getter
        List <HFS_Collection_Point__c> serviceLocations = LGL_DashController.getServiceLocations('Bicester');
        system.assertEquals(3, serviceLocations.size());

        //---------------------------------
        
        //Service Offerings Getter
        List <LGL_Service_Offering__c> serviceOfferings = LGL_DashController.getServiceOfferings('Bicester');
        system.assertEquals(15, serviceOfferings.size());
        
        //---------------------------------

        /*****Dash Information Getter
        //The structure of the information rerturned by the method is
        [
            {
                location: 'Bicester Train Station',
                dashCells: {
                    'a2b5E000000YsKYQA0': {DashCell1},
                    'a2b5E000000YsKdQAK': {DashCell2}
                }
            }, {
                location: 'Bicester The Apartment',
                dashCells: {
                    'a2b5E000000YsKYQA0': {DashCell3},
                    'a2b5E000000YsKdQAK': {DashCell4}
                }
            }
        ]
        where the ids are LGL_Service_Type__c Ids
        ******/

        List <LGL_DashController.DashRow> dashRows = LGL_DashController.getDashInformation('Bicester');

        system.assert(!dashRows.isEmpty());

        for (LGL_DashController.DashRow dashRow : dashRows) {
            if (dashRow.location == 'Bicester The Apartment') { //Because the service items that we have created are requested from The Apartment
                LGL_DashController.DashCell lLuggDashCell = dashRow.dashCells.get(serviceOfferingsMap.get('Bicester The Apartment_lLugg').LGL_Service_Type__c);
                LGL_DashController.DashCell pChairDashCell = dashRow.dashCells.get(serviceOfferingsMap.get('Bicester The Apartment_pChair').LGL_Service_Type__c);

                system.assertEquals(1, lLuggDashCell.itemsInUse);
                system.assertEquals(1, lLuggDashCell.totalUsedItemsToday);
                system.assertEquals(2, pChairDashCell.itemsInUse);
                system.assertEquals(2, pChairDashCell.totalUsedItemsToday);
            } else {
                for (LGL_DashController.DashCell dashCell : dashRow.dashCells.values()) {
                    system.assertEquals(0, dashCell.itemsInUse);
                    system.assertEquals(0, dashCell.totalUsedItemsToday);
                }
            }

        }

        //---------------------------------
        
        //Search Guests Method
        Test.setFixedSearchResults(new List <Id> {privilegeGuest1.Id,privilegeGuest2.Id,vipGuest1.Id});

        List <Account> searchedGuests = LGL_DashController.searchGuests('@test.com');
        system.assertEquals(3, searchedGuests.size());

        //---------------------------------

        //Service Requests Getter
        List <LGL_DashController.ServiceRequestRow> serviceRequests = LGL_DashController.getServiceRequests('Bicester');
        system.assertEquals(1, serviceRequests.size());
        LGL_DashController.ServiceRequestRow serviceRequest = serviceRequests[0];
        system.assert(serviceRequest.statusLabel.equals('In Use'));
        system.assert(serviceRequest.status.equals('using'));


        //---------------------------------
        
        List <LGL_Service_Item__c> serviceItems = LGL_DashController.getServiceItems(serviceRequestBTA.Id);
        system.assertEquals(3, serviceItems.size());

        //---------------------------------

        //Privilege Guest Getter
        Account accountNullId = LGL_DashController.getGuestAccount(null);
        system.assert(accountNullId != null);
        Account privilegeAccount = [SELECT Id FROM Account WHERE PersonEmail = 'gorwell@test.com'];
        Account privilegeAccountResult = LGL_DashController.getGuestAccount(privilegeAccount.Id);
        system.assertEquals(privilegeAccount.Id, privilegeAccountResult.Id);

        //Village Urls
        Village_Privacy_Policy_URLs__c villageUrlsCustomSettingEN = new Village_Privacy_Policy_URLs__c(
            Name = 'Bicester-en',
            Village_Privacy_Notice_Link__c = 'https://www.test.com',
            LGL_Terms_And_Conditions__c = 'https://www.test.com'
        );
        Village_Privacy_Policy_URLs__c villageUrlsCustomSettingFR = new Village_Privacy_Policy_URLs__c(
            Name = 'Bicester-fr',
            Village_Privacy_Notice_Link__c = 'https://www.test.com',
            LGL_Terms_And_Conditions__c = 'https://www.test.com'
        );
        
        insert new List <Village_Privacy_Policy_URLs__c> {villageUrlsCustomSettingEN, villageUrlsCustomSettingFR};
        
        system.runAs(bicesterUser) {
            Village_Privacy_Policy_URLs__c returnedVillageUrls = LGL_DashController.getVillageUrls();
            system.assertEquals('Bicester-en', returnedVillageUrls.Name);
        }

        Test.stopTest();
    }


    /*
     * Test for the basic getters used when loading the new Service Request Form
     */
    static testmethod void newServiceRequestFormTest() {


        User bicesterUser = LGL_Testing_Utils.createUser('Bicester');
        insert bicesterUser;
        Map <String, LGL_Service_Offering__c> serviceOfferingsMap = LGL_Testing_Utils.getServiceOfferingsMap('Bicester');
        LGL_Testing_Utils.createServiceRequestFormMetadata();
        Case hfsCase = LGL_Testing_Utils.createHFSCaseWithHierarchy('drobertson@test.com');

        //Test first the basic getters for the form data (picklist values, etc.)
        
        Test.startTest();

        List <Custom_Label__c> salutationLabels = LGL_DashController.getSalutationLabels('en');
        system.assertEquals(1, salutationLabels.size());

        List <Custom_Label__c> methodsTransport = LGL_DashController.getMethodsTransport('en');
        system.assertEquals(1, methodsTransport.size());

        LGL_DashController.CountriesResponse countriesResponse = LGL_DashController.getCountries();
        system.assertEquals(3, countriesResponse.defaultCountries.size());
        system.assertEquals(2, countriesResponse.otherCountries.size());

        List <Guest_Services_Data__c> guestTypes = LGL_DashController.getGuestTypes('Bicester');
        system.assertEquals(2, guestTypes.size());

        List <Guest_Services_Data__c> despositStatuses = LGL_DashController.getDepositStatuses('Bicester');
        system.assertEquals(1, despositStatuses.size());

        //---------------------------------

        //Submit New Service Request Form Actions

        //In order to avoid more queries, we use the already created map to get the BTA Location Id (doesn't really matter which particular service we use)
        LGL_Service__c serviceRequestBTA = LGL_Testing_Utils.createServiceRequest(serviceOfferingsMap.get('Bicester The Apartment_lLugg').LGL_Service_Offering_Location__c);
        LGL_Service__c serviceRequestWithHFS = LGL_Testing_Utils.createServiceRequest(serviceOfferingsMap.get('Bicester Visitor Centre_lLugg').LGL_Service_Offering_Location__c);
        serviceRequestWithHFS.LGL_Email__c = 'drobertson@test.com'; //The HFS Matching is done by email

        List <LGL_Service_Item__c> serviceItemsBTAList = new List <LGL_Service_Item__c> ();
        serviceItemsBTAList.add(LGL_Testing_Utils.createServiceItem(null, serviceOfferingsMap.get('Bicester The Apartment_lLugg').Id,'lLugg1'));
        serviceItemsBTAList.add(LGL_Testing_Utils.createServiceItem(null, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair1'));
        serviceItemsBTAList.add(LGL_Testing_Utils.createServiceItem(null, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair2'));
        
        List <LGL_Service_Item__c> serviceItemsWithHFS = new List <LGL_Service_Item__c> ();
        serviceItemsWithHFS.add(LGL_Testing_Utils.createServiceItem(null, serviceOfferingsMap.get('Bicester The Apartment_lLugg').Id,'lLugg1'));
        serviceItemsWithHFS.add(LGL_Testing_Utils.createServiceItem(null, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair1'));
        serviceItemsWithHFS.add(LGL_Testing_Utils.createServiceItem(null, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair2'));


        system.runAs(bicesterUser) {
            LGL_DashController.saveServiceRequest(serviceRequestBTA, serviceItemsBTAList, encodedSignature, false);
            LGL_DashController.saveServiceRequest(serviceRequestWithHFS, serviceItemsWithHFS, encodedSignature, false);
        }

        Test.stopTest();
        system.runAs(bicesterUser) {

            //NOTE: We can use the Id in the query because the serviceRequestBTA and serviceRequestWithHFS ara used by the method LGL_DashController.saveServiceRequest by reference so the Id is included in the variables theirselves    
            Map <Id, LGL_Service__c> createdServiceRequests = new Map<Id, LGL_Service__c>([SELECT Id, LGL_Guest_Id__c, LGL_Status__c, LGL_HFS_Case__c FROM LGL_Service__c WHERE Id IN (:serviceRequestBTA.Id, :serviceRequestWithHFS.Id)]);  
            List <ContentVersion> signatures = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId IN (:serviceRequestBTA.Id, :serviceRequestWithHFS.Id)];
            
            LGL_Service__c insertedRequestBTA = createdServiceRequests.get(serviceRequestBTA.Id);
            LGL_Service__c insertedRequestWithHFS = createdServiceRequests.get(serviceRequestWithHFS.Id);
            
            system.assertEquals('LL1', insertedRequestBTA.LGL_Guest_Id__c);
            system.assertEquals(null, insertedRequestBTA.LGL_HFS_Case__c);     
            system.assertEquals('using', insertedRequestBTA.LGL_Status__c);     
            
            system.assertEquals('XA1', insertedRequestWithHFS.LGL_Guest_Id__c); //The Guest Number should be the Guest Id for the Case. In the Test Case, the Guest Number is set to XA1
            system.assertEquals(hfsCase.Id, insertedRequestWithHFS.LGL_HFS_Case__c);
            system.assertEquals('using', insertedRequestWithHFS.LGL_Status__c);
            
            system.assertEquals(2, signatures.size());
        }
    }

    /*
     * Test for checkout functionality. By checking out the services, the test is testing also the LGL_ServiceItemTriggerHandler methods related to the checkout.
     * The checkout API Service from the Service_Request_API class is also tested
     */
    static testmethod void checkoutServiceItemsTest() {

        Map <String, LGL_Service_Offering__c> serviceOfferingsMap = LGL_Testing_Utils.getServiceOfferingsMap('Bicester');
        
        LGL_Service__c serviceRequestBTA = LGL_Testing_Utils.createServiceRequest(serviceOfferingsMap.get('Bicester The Apartment_lLugg').LGL_Service_Offering_Location__c);
        insert serviceRequestBTA;

        LGL_Service_Item__c serviceItem1 = LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_lLugg').Id,'lLugg1');
        LGL_Service_Item__c serviceItem2 = LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair1');
        LGL_Service_Item__c serviceItem3 = LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair2');
        insert new List <LGL_Service_Item__c> {serviceItem1, serviceItem2, serviceItem3};

        Test.startTest();

        //Checkout the Push Chairs only first

        LGL_DashController.checkoutServices(new List <LGL_Service_Item__c> {serviceItem2, serviceItem3}, serviceRequestBTA.Id, encodedSignature);
        
        LGL_Service__c serviceRequestPartialCheckout = [SELECT LGL_Status__c FROM LGL_Service__c WHERE Id =: serviceRequestBTA.Id];
        List<LGL_Service_Item__c> checkoutServicesPushChairs = [SELECT LGL_Status__c, LGL_Checkout_Time__c FROM LGL_Service_Item__c WHERE Id IN (:serviceItem2.Id, :serviceItem3.Id)];

        system.assertEquals('using', serviceRequestPartialCheckout.LGL_Status__c); //Because there are service items that are not closed/checkout yet, the Service Request should remain in using Status
        for (LGL_Service_Item__c serviceItem : checkoutServicesPushChairs) {
            system.assertEquals('closed', serviceItem.LGL_Status__c);
            system.assert(serviceItem.LGL_Checkout_Time__c != null);
        }

        //---------------------------------

        //Checkout the rest of the services and test that the service request is also closed by the trigger

        LGL_DashController.checkoutServices(new List <LGL_Service_Item__c> {serviceItem1}, serviceRequestBTA.Id, encodedSignature);
        
        LGL_Service__c fullCheckout = [SELECT LGL_Status__c FROM LGL_Service__c WHERE Id =: serviceRequestBTA.Id];
        system.assertEquals('closed', fullCheckout.LGL_Status__c);

        //Check for the checkAnUpdateCloseServiceRequests method of the LGL_ServiceItemTriggerHandler. Check that, after cheking out,
        //if we add one more Service Item, the Service gets updated to using status

        LGL_Service_Item__c serviceItem4 = LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair3');
        insert serviceItem4;

        LGL_Service__c serviceRequestReactivated = [SELECT LGL_Status__c FROM LGL_Service__c WHERE Id =: serviceRequestBTA.Id];
        system.assertEquals('using', serviceRequestReactivated.LGL_Status__c);

        Test.stopTest();
    }

}