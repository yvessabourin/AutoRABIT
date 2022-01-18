@isTest
public class LGL_Testing_Utils {

    public static void createServiceOfferingHierarchy () {

        Test.loadData(LGL_Service_Type__c.sObjectType,'LGL_Service_Type_Mock_Data');
        Test.loadData(HFS_Collection_Point__c.sObjectType,'LGL_Collection_Point_Mock_Data');
        Test.loadData(LGL_Service_Offering__c.sObjectType,'LGL_Service_Offering_Mock_Data');

    }

    public static User createUser (String village) {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User newUser = new User();
        newUser.LastName = 'Orwell';
        newUser.Alias = 'gorw';
        newUser.Email = 'gorwell@test.com';
        newUser.Username = 'gorwell@test.com';
        newUser.CommunityNickname = 'gorw';
        newUser.ProfileId = adminProfile.Id;
        newUser.Village__c = village;
        newUser.TimeZoneSidKey = 'GMT';
        newUser.LocaleSidKey = 'en_GB';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LanguageLocaleKey = 'en_US';
        return newUser;
    }

    public static Account createPrivilegeAccount (String email) {

        Id privilegeGuestRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Guest').getRecordTypeId();
        return createAccount(email, privilegeGuestRecordType);
    }

    public static Account createVIPAccount (String email) {

        Id vipGuestRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('VIP_Guest').getRecordTypeId();
        return createAccount(email, vipGuestRecordType);
    }

    public static Account createAccount (String email, Id recordType) {

        Account userAccount = new Account(
            Salutation              = 'Mr',
            FirstName               = email,
            LastName                = email,
            PersonEmail             = email,
            PersonMobilePhone       = '0741 123 455',
            Country_of_Residence__c = 'United Kingdom',
            RecordTypeId            = recordType,
            Customer_GUID__c        = email
        );
        return userAccount;
    }

    public static LGL_Service__c createServiceRequest (Id serviceLocation) {
        
        LGL_Service__c serviceRequest = new LGL_Service__c (
            LGL_Country_Residence__c    = 'United Kingdom',
            LGL_Email__c                = 'gorwell@test.com',
            LGL_First_Name__c           = 'George',
            LGL_Last_Name__c            = 'Orwell',
            LGL_Guest_Id__c             = 'LL1',
            LGL_Guest_Id_Number_Part__c = 1,
            LGL_Guest_Type__c           = 'Standard Guest',
            LGL_Phone__c                = '0741 123 455',
            LGL_Service_Start_Date__c   = System.now(),
            LGL_Status__c               = 'using',
            LGL_Title__c                = 'Mr',
            LGL_Request_Location__c     = serviceLocation
        );

        return serviceRequest;

    }

    public static LGL_Service_Item__c createServiceItem (Id serviceRequestId, Id serviceOfferingId, String serviceItemIdentifier) {
        
        LGL_Service_Item__c serviceItem = new LGL_Service_Item__c (
            LGL_Status__c = 'using',
            LGL_Service_Item_Identifier__c = serviceItemIdentifier,
            LGL_Deposit_Status__c = 'DT',
            LGL_Service_Request__c = serviceRequestId,
            LGL_Service_Offering__c = serviceOfferingId
        );

        return serviceItem;

    }

    /*
     * Returns a map that allows for Test comprobations easily related to Service Offerings. The structure of the map is:
     * 
     *  <Collecction Location Name> + '_' + <Service_Type_Identifier>
     * 
     *  Ex:  'Bicester Train Station_lLugg' => 'a2c5E000000hvBxQAI'  <-- a service offering Id
     * 
     */

    public static Map <String, LGL_Service_Offering__c> getServiceOfferingsMap (String village) {

        Map <String, LGL_Service_Offering__c> serviceOfferingsMap = new Map <String, LGL_Service_Offering__c> ();

        for (LGL_Service_Offering__c sOffering : [SELECT LGL_Service_Offering_Location__c, LGL_Service_Offering_Location__r.Name, LGL_Service_Type__r.LGL_Service_Id__c, LGL_Service_Type__c FROM LGL_Service_Offering__c WHERE LGL_Service_Offering_Location__r.Village__c =: village]) {
            serviceOfferingsMap.put(sOffering.LGL_Service_Offering_Location__r.Name + '_' + sOffering.LGL_Service_Type__r.LGL_Service_Id__c, sOffering);
        }

        return serviceOfferingsMap;
    }

    public static void createServiceRequestFormMetadata () {
        createLabels();
        createCountries();
        createGuestServicesData();
    }

    public static void createLabels() {
        Custom_Label__c salutationLabel = createLabel('MrSalutationLabel');
        Custom_Label__c transportLabel = createLabel('TransportTrain');
        Custom_Label__c otherLabel = createLabel('AnotherLabel');
        insert new List <Custom_Label__c> {salutationLabel, transportLabel, otherLabel};
    }

    public static void createCountries() {
		HFS_Country_Data__c cd1 = new HFS_Country_Data__c (Name='001',HFS_Country_Code__c='ES', HFS_Country_Name__c='Spain', HFS_Default_Option__c=true);
		HFS_Country_Data__c cd2 = new HFS_Country_Data__c (Name='002',HFS_Country_Code__c='UK', HFS_Country_Name__c='United Kingdom', HFS_Default_Option__c=true);
		HFS_Country_Data__c cd3 = new HFS_Country_Data__c (Name='003',HFS_Country_Code__c='DE', HFS_Country_Name__c='Germany', HFS_Default_Option__c=true);
		HFS_Country_Data__c cd4 = new HFS_Country_Data__c (Name='004',HFS_Country_Code__c='RU', HFS_Country_Name__c='United Kingdom', HFS_Default_Option__c=false);
		HFS_Country_Data__c cd5 = new HFS_Country_Data__c (Name='005',HFS_Country_Code__c='AO', HFS_Country_Name__c='Angola', HFS_Default_Option__c=false);        

        insert new List <HFS_Country_Data__c> {cd1,cd2,cd3,cd4,cd5};

    }

    public static void createGuestServicesData() {
        Guest_Services_Data__c gds1 = createGuestServiceData('LGL Guest Type');
        Guest_Services_Data__c gds2 = createGuestServiceData('LGL Guest Type');
        Guest_Services_Data__c gds3 = createGuestServiceData('Guest Type');
        Guest_Services_Data__c gds4 = createGuestServiceData('LGL Deposit Status');
        Guest_Services_Data__c gds5 = createGuestServiceData('HFS Payment Status');
        Guest_Services_Data__c gds6 = createGuestServiceData('HFS Collection Location');

        insert new List <Guest_Services_Data__c> {gds1, gds2, gds3, gds4, gds5, gds6};
    }

    public static Custom_Label__c createLabel(String name) {
        return new Custom_Label__c(
            Used_in_App__c          = 'LGL',
            Used_on_page__c         = 'LGLNewServiceForm',
            Language__c             = 'en',
            Custom_Label_Value__c   = name,
            Name                    = name
        );    
    }

    public static Guest_Services_Data__c createGuestServiceData (String dataType) {

        return new Guest_Services_Data__c (
            Used_In_Application__c  = 'LGL',
            Village__c              = 'Bicester',
            Service_Data_Type__c    = dataType,
            Data_Code__c            = 'T',
            Data_Label__c           = 'Test'
        );

    }

    public static Case createHFSCaseWithHierarchy (String email) {
        Village__c bicesterVillage = createVillage();
        insert bicesterVillage;
        Case hfsCase = createHFSCase(email, bicesterVillage.Id);
        insert hfsCase;
        return hfsCase;
    }

    public static Village__c createVillage() {
    	return new Village__c(
            Village_Code__c = 'BV',
            Name = 'Bicester',
            Village_Local_Language__c = 'English',
            CertSales_CertPeriod_Cut_Off_Days__c = 1,
            CertSales_Report_Sales_Grace_Period_Days__c = 1,
            Oracle_Source_Template_Number__c = '123456',
            Oracle_Organisation__c = 'SourceOrg');     
    }

    public static Case createHFSCase (String email, Id villageId) {
        return new Case (
            Village__c = villageId,
            Service_Guest_ID__c = '123456789',
            Service_Guest_Number__c = 'XA1',
            Guest_ID_Number_Part__c = 12,
            Payment_Status__c = 'Paid',
            Client_QR_Code__c = '123456789',
            HFS_Collection_Location__c = 'Apartment',
            Status = 'New',
            Origin = 'Email',
            Type = 'Hands Free Shopping',
            Service_Date__c = system.today(),
            SuppliedEmail = email
        );
    }
}