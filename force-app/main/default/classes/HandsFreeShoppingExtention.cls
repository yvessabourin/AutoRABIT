global with sharing class HandsFreeShoppingExtention {
    
    private final sObject mysObject;
    
    public static Boolean brandCapture {get; set;}
	public static Boolean privilegeTerms {get; set;}
	public static String defaultLang {get; set;}
	public static Boolean needsPromoCode {get; set;}
	public static Boolean needsRegistrationLocation {get; set;}
	public static Boolean needsPersonRegistering {get; set;}
	public static Boolean hasClickCollect {get; set;}
    
    public static Boolean defaultGuestType {get; set;}
    public static Boolean defaultPayStatus {get; set;}
    public static Boolean defaultLocation {get; set;}
    public static String defaultguesttypes {get; set;}
    public static string defaultpaymentstatuses {get; set;}
    public static String defaultpickuplocations {get; set;}
    
    public list<SelectOption> villages {get; set;}
    public String countries {get; set;}
    public list<SelectOption> languages  {get; set;} 
    public list<SelectOption> genders  {get; set;}
    public static String userVillage {get; set;}
    public static String userVillageCode {get; set;}
    public static String guesttypes {get; set;}
    public static string paymentstatuses { get; set; }
    public static String pickuplocations {get; set;}
    public static String salutations {get; set;}
    public static String marketingcampaign {get; set;}
    public static String marketingActivities {get; set;}
    public static String PartnermarketingActivities {get; set;}
    private map<string, map<string, string>> enumMap = new map<string, map<string, string>>();
    public static String lang {get; set;}
    public static String languagelabels {get;set;}
    //public static String[] labelsonpage = new String[]{'DeclineButton', 'Email', 'FirstName', 'LastName', 'PleaseComplete', 'SaveNextButton', 'Tel', 'WelcomeVIPHeading','VIPConsentTopHeading'};
    public List<String> lstVillageRegBrands{ get; set; }
    public static String[] labelsonpage = new String[]{'PleaseHandThisBack','RefuseToAnswer','ShoppingExpress','PublicBus','PrivateHire','Taxi','SmallCoach','LargeCoach','Train','Car','Paid',
        'PayOnCollect','FreeofChargeValet','FreeofChargeVIP','PaymentStatus','SaveHFSRegistration','HandsFreeShoppingRegistration',
        'TermsConditions','Iagreewiththe','SaveGuestDetails','CancelRegistration','VillagePrivacyNotice','PrivacyStatement','LastName','FirstName','ClearSignatureButton',
        'NewGuestRegistration','HFSTitle','Email','MobileNumber','CountryOfResidence','MethodOfTransport','PriviligeOptionalSelect','PrivilegeTermsCondition' };
     
	public static Boolean isHFShost { get;  set;}
	public static String firstCountriesListStr {get;set;}
	public static String otherCountriesListStr {get;set;}
	public static HFS_CountryController countriesController = HFS_CountryController.getInstance();
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public HandsFreeShoppingExtention(ApexPages.StandardController stdController) {
        //
        lang = 'en'; // default to english if the language isnt set
        languagelabels = getLanguageLabels(lang);
        lstVillageRegBrands = new List<String>{'Fidenza','Kildare'};
        salutations = getSalutations(lang);
        
        this.mysObject = (sObject)stdController.getRecord();
        userVillage = getUsersVillage();
        system.debug(userVillage);
        getGuestServicesData();
		getMarketingCampaigns();
		getCountriesData();

        List<HFS_Features__mdt> villageFeatures = getVillageHFSFeatures(userVillage);
        system.debug('villageFeatures ' + villageFeatures);
        if(!villageFeatures.isEmpty()){
			brandCapture = villageFeatures[0].Brand_Capture__c;
			privilegeTerms = villageFeatures[0].Privilege_Terms_Condition__c;
			defaultLang = villageFeatures[0].Default_Lang__c;
			needsPromoCode = villageFeatures[0].Promo_Code__c;
			needsPersonRegistering = villageFeatures[0].Person_Registering__c;
			needsRegistrationLocation = villageFeatures[0].Registration_Location__c;
			hasClickCollect = villageFeatures[0].Click_And_Collect__c;
        }else{
            brandCapture = false;
			privilegeTerms = false;
			defaultLang = 'en';
			needsPromoCode = false;
			needsPersonRegistering = false;
			needsRegistrationLocation = false;
			hasClickCollect = false;
        }
        isHFShost = false;
        List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if(perm.PermissionSet.Name == 'Host_Hands_Free_Shopping_Enabled'){
                isHFShost = true;
            }          
        }           
    }
    

    private static void getGuestServicesData(){
        
        // get all the guest services data for this particular village
        List<Guest_Services_Data__c> guestServiceData = [SELECT ID, Data_Code__c, Data_Label__c, Service_Data_Type__c, Village__c, Default_value__c FROM Guest_Services_Data__c WHERE Village__c = :userVillage];
        // get all the marketing campaigns data for this particular village
        Village__c village = [SELECT ID FROM Village__c WHERE Name =: userVillage LIMIT 1];
        List<Marketing_Campaign__c> marketingCampaignData = [SELECT ID, Name, Short_Description__c, Village__c FROM Marketing_Campaign__c WHERE Village__c =: village.Id];
        List<Marketing_Activity__c> marketingActivityData = [SELECT ID, Name,Partner__r.Name FROM Marketing_Activity__c WHERE Marketing_Campaign__r.Village__c =: village.Id 
                                                             AND RecordType.Name = 'Village Partnership Promotion' AND HFS_Entitled__c = TRUE AND Is_Live__c = TRUE AND Status__c = 'Approved'
                                                            ORDER BY NAME ASC];
        
        // now based on what type is on the data, we give that to the select lists
        list<DropdownOption> guestTypereturnList = new list<DropdownOption>();
        list<DropdownOption> pickupLocationreturnList = new list<DropdownOption>();
        list<DropdownOption> salutationsreturnList = new list<DropdownOption>();
        list<DropdownOption> paymentstatusreturnList = new list<DropdownOption>();
        // now based on what type is on the data, we give that to the select lists
        list<DropdownOption> marketingCampaignreturnList = new list<DropdownOption>();
        list<DropdownOption> marketingActivityreturnList = new list<DropdownOption>();
        list<DropdownOption> partnermarketingActivityreturnList = new list<DropdownOption>();
        // for default values
        list<DropdownOption> defaultguestTypereturnList = new list<DropdownOption>();
        list<DropdownOption> defaultpickupLocationreturnList = new list<DropdownOption>();
        list<DropdownOption> defaultpaymentstatusreturnList = new list<DropdownOption>();
        // guestTypereturnList.add(new DropdownOption('placeholder','Guest Type',true));
        //  pickupLocationreturnList.add(new DropdownOption('placeholder','Pickup Location',true));
        for(Guest_Services_Data__c guestdataitem :guestServiceData){
            if(guestdataitem.Service_Data_Type__c == 'Guest Type' ){
                if(guestdataitem.Default_Value__c){
                    defaultGuestType = true;
                    defaultguestTypereturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
                }else{
                    guestTypereturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
                }
                
            }else if(guestdataitem.Service_Data_Type__c == 'HFS Collection Location' ){
                if(guestdataitem.Default_Value__c){
                    defaultLocation = true;
                    defaultpickupLocationreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
                }else{
                    pickupLocationreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
                }
                
            }else if(guestdataitem.Service_Data_Type__c == 'HFS Payment Status' ){
                if(guestdataitem.Default_Value__c){
                    defaultPayStatus = true;
                    defaultpaymentstatusreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
                }else{
                    paymentstatusreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
                }
                
            } 
        }
        
        //DEV TEAM L
        // marketingCampaignreturnList.add(new DropdownOption('placeholder','Guest Type',true));
        if(!marketingCampaignData.isEmpty()){
            for(Marketing_Campaign__c marketingcampaigndataitem : marketingCampaignData){
                marketingCampaignreturnList.add(new DropdownOption(marketingcampaigndataitem.Short_Description__c,marketingcampaigndataitem.Name));
            }
                   
            marketingcampaign = JSON.serialize(marketingCampaignreturnList);
            
        }else{
            
            //marketingcampaign = '[{"val":"_No campaigns available_","notAnOption":false,"name":"_No campaigns available_}]';
            
        }
        
        
        
        if(!marketingActivityData.isEmpty()){
            for(Marketing_Activity__c marketingActivitydataitem : marketingActivityData){
                marketingActivityreturnList.add(new DropdownOption(marketingActivitydataitem.id,marketingActivitydataitem.Name));
                partnermarketingActivityreturnList.add(new DropdownOption(marketingActivitydataitem.id,marketingActivitydataitem.Partner__r.Name + ' - ' + marketingActivitydataitem.Name));
            }
                   
            marketingActivities = JSON.serialize(marketingActivityreturnList);
            PartnermarketingActivities = JSON.serialize(partnermarketingActivityreturnList);
            
        }else{
            
            //marketingcampaign = '[{"val":"_No campaigns available_","notAnOption":false,"name":"_No campaigns available_}]';
            
        }
        /*
        // get all the guest services data for this particular village
        List<HFS_Collection_Point__c> collectionPoint = [SELECT Name FROM HFS_Collection_Point__c];
        for(HFS_Collection_Point__c guestdataitem :collectionPoint){           
        pickupLocationreturnList.add(new DropdownOption(guestdataitem.Name,guestdataitem.Name));                
        }
        */
        paymentstatuses = JSON.serialize(paymentstatusreturnList);
        guesttypes = JSON.serialize(guestTypereturnList);
        pickuplocations = JSON.serialize(pickupLocationreturnList);    
               
      	// SETTING THE DEFAULT VALUES IF ITS REQUIRED
        defaultpaymentstatuses = JSON.serialize(defaultpaymentstatusreturnList);
        defaultguesttypes = JSON.serialize(defaultguestTypereturnList);
        defaultpickuplocations = JSON.serialize(defaultpickupLocationreturnList); 
        system.debug(marketingcampaign);
        
        
    }
       
	private static void getCountriesData(){
		
		List <DropdownOption> firstCountriesList = new List <DropdownOption> ();
		List <DropdownOption> otherCountriesList = new List <DropdownOption> ();
		for (HFS_Country_Data__c country : countriesController.getDefaultCountries()) {
			firstCountriesList.add(new DropdownOption(country.HFS_Country_Code__c, country.HFS_Country_Name__c));
		}
		for (HFS_Country_Data__c country : countriesController.getOtherCountries()){
			otherCountriesList.add(new DropdownOption(country.HFS_Country_Code__c, country.HFS_Country_Name__c));
		}
		firstCountriesListStr = JSON.serialize(firstCountriesList);
		otherCountriesListStr = JSON.serialize(otherCountriesList);
	}	
	
    @RemoteAction
    global static List<Village_Presence__c> searchBrand(String brandName, String village){
        
        system.debug('it worked');       
        
        /////
        System.debug('brandName: ' + brandName + ' - ' + village);
        brandName = String.escapeSingleQuotes( brandName );
        System.debug('brandName: ' + brandName + ' - ' + village);
        // im not keen on a double query each time, but this will do for now
        ID villageID;
        Village__c v = [select Id from Village__c where Name = :village limit 1];
        System.debug('Village: ' + v);
        if (v != null){
            villageID = v.Id;
        }
        
        String query = 'SELECT Id, Name, Brand__r.name FROM Village_Presence__c '+ 
            ' WHERE Village__c = :villageID AND Name LIKE \'%'+brandName+'%\' AND Status__c = \'Trading\' LIMIT 20';
        List<Village_Presence__c> VPs = Database.query(query);
        System.debug('VPs: ' + VPs );
        return VPs;
              
    }
    
    
    @RemoteAction
    global static string getSalutations(String thislang){
        
        List<Custom_Label__c> salutationsCL = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c 
                                               WHERE Language__c = :thislang AND Used_in_App__c = 'HFS' AND Used_on_page__c 
                                               LIKE '%HFSAddService%' AND NAME LIKE '%Salutation%'];
        system.debug('salutationsCL -- ' + salutationsCL);
        List<LabelValue> Salutationlblvals = new List<LabelValue>();
        for(Custom_Label__c cl :salutationsCL){
            LabelValue lval = new LabelValue();
            lval.LabelName = cl.Name;
            Lval.LabelValue = cl.Custom_Label_Value__c;
            Salutationlblvals.add(lval);
        }
        system.debug('Salutationlblvals -- ' + Salutationlblvals);
        return JSON.serialize(Salutationlblvals);      
    }
    
    @RemoteAction
    global static string getLanguageLabels(String thislang){
        // gets the labels for this page, for display by angular
        List<Custom_Label__c> custlabels = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c WHERE (Language__c = :thislang AND Used_in_App__c = 'HFS' AND Used_on_page__c LIKE '%HFSAddService%') OR (Language__c = :thislang AND Used_in_App__c = 'HFS' AND Used_on_page__c LIKE '%HFSAddService%' AND NAME LIKE '%Salutation%') ];
        List<LabelValue> lblvals = new List<LabelValue>();
        for(Custom_Label__c cl :custlabels){
            LabelValue lval = new LabelValue();
            lval.LabelName = cl.Name;
            Lval.LabelValue = cl.Custom_Label_Value__c;
            lblvals.add(lval);
        }         
        
        return JSON.serialize(lblvals);
    }
    
    @RemoteAction
    global static string getPrivacyNoticeURLforVillage(String thisvillage, string thislang  ){
        system.debug('Parametres --- '  + thisvillage + ' ------- ' + thislang  );
        
        string thequery = thisvillage + '-' + thislang;
         system.debug(thequery);
        
        list<Village_Privacy_Policy_URLs__c> villageURL = [SELECT id, Name,VillageLink__c FROM Village_Privacy_Policy_URLs__c WHERE name =: thequery LIMIT 1 ];
        
      //  system.debug('villageURL.VillageLink__c - ' + villageURL.VillageLink__c);
        
        if(villageURL.size() == 0 || villageURL == NULL ){
            return 'https://www.tbvsc.com/bicester-village/en/legal/village-privacy-notice';
        }
        else{
            return villageURL[0].VillageLink__c;
        }
      
    }
    
    @RemoteAction
    global static string getTermsandConditionsforVillage(String thisvillage, string thislang  ){
        system.debug('Parametres --- '  + thisvillage + ' ------- ' + thislang  );
        
        string thequery = thisvillage + '-' + thislang;
        system.debug(thequery);
        
        list<Village_Privacy_Policy_URLs__c> villageURL = [SELECT id, Name,Village_Terms_and_Conditions__c FROM Village_Privacy_Policy_URLs__c WHERE name =: thequery LIMIT 1 ];
        //system.debug('villageURL[0].Village_Terms_and_Conditions__c - ' + villageURL[0].Village_Terms_and_Conditions__c );
        
        if(villageURL.size() == 0 || villageURL == NULL ){
            return 'https://www.tbvsc.com/bicester-village/en/legal/hands-free-shopping-terms-and-conditions';
        }
        else{
            return villageURL[0].Village_Terms_and_Conditions__c;
        }
        
    }

    @RemoteAction
    global static string getPrivilegeTermsandConditions(String thisvillage, string thislang  ){
        system.debug('Parametres --- '  + thisvillage + ' ------- ' + thislang  );
        
        string thequery = thisvillage + '-' + thislang;
        system.debug(thequery);
        
        list<Village_Privacy_Policy_URLs__c> villageURL = [SELECT id, Name,Privilege_Terms_Condition__c FROM Village_Privacy_Policy_URLs__c WHERE name =: thequery LIMIT 1 ];
        
        if(villageURL.size() == 0 || villageURL == NULL ){
            return 'https://www.tbvsc.com/bicester-village/en/legal/privilege-terms-and-conditions';
        }
        else{
            return villageURL[0].Privilege_Terms_Condition__c; 
        }
        
    }
    
    
     private class LabelValue{
        String LabelName {get; set;}
        String LabelValue {get; set;}
     }
     
     
    
    private static string getUsersVillage(){
        
        
        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
        Village__c uservillage  = [SELECT Name, Village_Code__c FROM Village__c WHERE Name =:users[0].Village__c LIMIT 1];
        
        string village = users[0].Village__c;
        userVillageCode = uservillage.Village_Code__c;
        
        return village; 
        
    }
    

    

    @RemoteAction
    global static Map<String,List<Account>> searchGuests(string param){
		//To facilitate the use of the Country, temporaly setting the country code in the Country__c field to use it in the page
		Map <String, List<Account>> guestsMap = HFS_Utils.searchGuests(param);
		for (List<Account> guestList : guestsMap.values()) {
			for (Account guest : guestList) {
				guest.Country__c = countriesController.getCountryCode(guest.Country_of_Residence__c);
			}
		}
        return guestsMap;
    }
    
    @RemoteAction
    global static string SaveGuest(string fname, string lname, string email, string mobile, string title, string country, string village){
        
        /*    string accID = apiCustomerController.saveGuest(null, '', fname, lname,
'gender', '',mobile,email, string village, string language,
'','', '',  county, '',country, string leadsourcetext,
string optoutEmail, string optoutMobile, string optoutPostal
);*/
        
        string accID = apiCustomerController.saveGuest('', title, fname, lname, '0', '',mobile,email, village, 'en-gb','','', '',  '', '',country, 'Hands Free Shopping','NO', 'NO', 'NO');
        
        return accID;
        
    }
    
    
    @RemoteAction
    global static String saveSignature(String imageUrl, String objId, String signatureName) {
        
        try {
            /* Attachment accSign = new Attachment();
            accSign.ParentID = objId;
            accSign.Body = EncodingUtil.base64Decode(imageUrl);
            accSign.contentType = 'image/png';
            accSign.Name = signatureName;
            accSign.OwnerId = UserInfo.getUserId();
            insert accSign; */
            
            ContentVersion[] contentVersions = new List<ContentVersion>();
            ContentVersion contentVersion = createContentVersion(signatureName, imageUrl, objId);
            contentVersions.add(contentVersion);
            insert contentVersions;
            
            return 'success';
            
        }catch(Exception e){
            system.debug('---------- ' + e.getMessage());
            return JSON.serialize(e.getMessage()); 
        }
        return null; 
    }
    private static ContentVersion createContentVersion(String name, String body, Id parentId){
   		ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = name + '.png';
        contentVersion.FirstPublishLocationId = parentId; // replace ContentDocumentLink
        contentVersion.Title = name;
        contentVersion.VersionData = EncodingUtil.base64Decode(body);
        return contentVersion;
    }
    
    // method used on mobile guest creation screen to retrive enum dropdowns
    @RemoteAction
    global static string getDropdownValues(){
        
        map <string, map<string, string>> returnList = new map<string, map<string, string>>();
        list<string> enumList = new list<string>();
        enumList.add('Countries');
        enumList.add('Villages');
        //enumList.add('Genders');
        //enumList.add('Languages');
        JSONGenerator gen;
        
        gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        for(string s :enumList){
            map<string, string> theValues =  apiCustomerUtilities.getEnumValueMap(s);     

            returnList.put(s, theValues);
            
            
            gen.writeFieldname(s);
            gen.writeStartArray();
            for (string key :theValues.keySet()){
                gen.writeStartObject();
                gen.writestringfield(key, theValues.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
            
            
            
        }
        gen.writeEndObject();
        gen.close();
        return gen.getAsString();
        //return json.serialize(returnList); //?? Reverse sorts the values map for some reason, therefore using JSON Generator      
        
    }
    
    @RemoteAction
    global static String saveHFSShopping(String accountId, string email, string firstname, string lastname, 
                                         string mobilenum, string collectlocationname, string collectlocationcode,
                                         string guesttypename, string guesttypecode, string villagename,
                                         string modeoftransport, string signatureURL, string paymentStatus, String hfsprivileged,
										 string qrCode, string servicetypename, string servicetype, string salutation, string marktCamp, string activatingBrandid, string RegLanguage, String CountryOfOriginCode, String promoCode,
										 String registrationLocation, String personRegistering, String collectBrandName, String selectedCollectionDate) {
                                             
                                           //  map<string, string> countryMap = getCountryMapValues();
                                       
                                             system.debug('activatingBrandid --- ' + activatingBrandid);
                                             // use this data to create a new case
                                             // get village ID from village name
                                             ID villageID;
                                             String VillageCode;
                                             Village__c v = [select Id, Village_Code__c, Name from Village__c where Name = :villagename limit 1];
                                             
                                             if (v != null){
                                                 villageID = v.Id;
                                                 VillageCode = v.Village_Code__c;
                                             }
                                            
                                             List<Case> allQRCodes = [SELECT Id, Client_QR_Code__c FROM Case WHERE Service_Date__c = TODAY];
                                             for(Case theCase : allQRCodes){
                                                 if(theCase.Client_QR_Code__c == qrCode){
                                                     return 'ERROR - ' + 'The QRCode inserted ' + qrCode +' is already assigned to another Guest. Please try again.';
                                                 }
                                             }                                             
                                             
                                             DateTime daT = System.now();
                                             string GuestIDcalculated = VillageCode + String.valueOf(daT.year()) + String.valueOf(daT.month()).leftPad(2, '0') + String.valueOf(daT.day()).leftPad(2, '0') + guesttypecode + collectlocationcode;
                                             string GuestIDcalculatedwildcard = GuestIDcalculated + '%' ;
                                             
                                             System.debug(GuestIDcalculated);
                                             //String soql = 'Select ID, Service_Guest_Number__c,Guest_ID_Number_Part__c, Service_Guest_ID__c FROM Case WHERE Service_Guest_ID__c like \'' + GuestIDcalculated + '%\' ';
                                             Case prevcase;
                                             try{
                                                 prevcase = [Select ID, Service_Guest_Number__c,Guest_ID_Number_Part__c, Service_Guest_ID__c FROM Case 
                                                             WHERE Service_Guest_ID__c like :GuestIDcalculatedwildcard AND Service_Date__c = TODAY ORDER BY Guest_ID_Number_Part__c DESC LIMIT 1];
                                             }
                                             catch( Exception ex){
                                                 // means there are no rows, so it will be null
                                                 
                                             }    
                                             Integer currentNumber = 1;
                                             
                                             if(prevcase != null)
                                             {           
                                                 currentNumber = Integer.valueOf(prevcase.Guest_ID_Number_Part__c + 1);
                                             }
                                             
                                             Case hfsrecord = new Case();
                                             System.debug(' ACCOUNT ID ======= ' + accountId);
                                             if(accountId != null && accountId != ''){
												hfsrecord.AccountId = Id.valueOf(accountId);
												//Additional code for updating the realated account in case that the Country has been changed
												Account guestAccount = [SELECT Id, Country_of_residence__c FROM Account WHERE Id =: accountId];
												if (guestAccount.Country_of_residence__c != countriesController.getCountryLabel(CountryOfOriginCode)) {
													guestAccount.Country_of_residence__c = countriesController.getCountryLabel(CountryOfOriginCode);
													update guestAccount;
												}                                         
                                             }
                                             hfsrecord.SuppliedName = salutation + ' ' + firstname + ' ' + lastname;
                                             hfsrecord.HFS_First_Name__c = firstname;
                                             hfsrecord.HFS_Last_Name__c = lastname;
                                             hfsrecord.SuppliedPhone = mobilenum;
                                             hfsrecord.SuppliedEmail = email;
                                             hfsrecord.Type = servicetype;
                                             hfsrecord.Village__c = villageID;
                                             hfsrecord.Mode_of_Transport__c = modeoftransport;
                                             hfsrecord.HFS_Collection_Location__c = collectlocationname;
                                             // we need to also generate the ID from the data gathered
                                             hfsrecord.Service_Guest_ID__c = GuestIDcalculated + String.valueOf(currentNumber);
                                             hfsrecord.Service_Guest_Number__c = guesttypecode + collectlocationcode + String.valueOf(currentNumber);
                                             hfsrecord.Guest_ID_Number_Part__c = currentNumber;
                                             hfsrecord.Service_Date__c = Date.valueOf(daT);
                                             hfsrecord.Experience_Start__c = system.now();
                                             hfsrecord.Payment_Status__c = paymentStatus;
                                             hfsrecord.HFS_Leaflet_Type__c = hfsprivileged;
                                             hfsrecord.Client_QR_Code__c = qrCode;
                                             hfsrecord.HFS_Marketing_Campaign__c = marktCamp;
                                             hfsrecord.Guest_Type__c = guesttypename;
                                             hfsrecord.Language_on_Registration__c = RegLanguage;
                                             hfsrecord.Country_of_Residence__c = countriesController.getCountryLabel(CountryOfOriginCode);
											 hfsrecord.HFS_Promo_Code__c = promoCode;
											 hfsrecord.HFS_Registration_Location__c = registrationLocation;
											 hfsrecord.HFS_Person_Registering__c = personRegistering;
                                             
                                             if(activatingBrandid != NULL && activatingBrandid != ''){
                                                 hfsrecord.Activating_Brand__c = activatingBrandid;
                                             }
                                             
                                             if (String.isNotBlank(collectBrandName)) {
                                                hfsrecord.HFS_Click_And_Collect__c = true;
                                                hfsrecord.HFS_Call_Collect_Brand_Name__c = collectBrandName;
                                                hfsrecord.HFS_Collection_Date__c = String.isNotBlank(selectedCollectionDate) ? Date.valueOf(selectedCollectionDate) : null;
                                             }
											 
                        
                                             
                                             insert hfsrecord;
                                             
                                             if(hfsrecord.Id != null){
                                                 // now we can save the signature        
                                                 saveSignature(signatureURL,hfsrecord.Id , 'Signup Signature');
                                                 // and we can send the user an email
                                                 if (hfsrecord.HFS_Click_And_Collect__c == true) {
                                                     sendClickCollectEmail(hfsrecord, v);
                                                 } else {
                                                    sendEmail(hfsrecord, v);
                                                 }
                                             }
                                             
                                             return hfsrecord.Id;
    }  
    
    public static void sendEmail(Case caseRecord, Village__c village){

        EmailTemplate template = [Select id from EmailTemplate where  developername = 'HFS_Registration'];
        
        LIST<string> toaddress = New List<String>();
        toaddress.add(caseRecord.SuppliedEmail);
        
		HFS_Features__mdt villageMetadata = getVillageHFSFeatures(village.Name)[0];
        OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address =: villageMetadata.Registration_Email_Sender__c limit 1];
        
        HFS_Utils.sendEmailWithoutContact(OWA, toaddress, template, caseRecord);

    }

    private static void sendClickCollectEmail(Case clickCollectCase, Village__c village) {
        
        HFS_Features__mdt villageMetadata = getVillageHFSFeatures(village.Name)[0];
 
        //Prepare the email. Get the correct template, OWA and toAdresses

        String templateName = 'HFS_Registration_Collect_' + village.Village_Code__c;
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName =: templateName];

        OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address =: villageMetadata.Registration_Email_Sender__c limit 1];
        
        List<String> toaddresses = String.isNotBlank(villageMetadata.Collect_Email_Recipients__c) ? villageMetadata.Collect_Email_Recipients__c.split(',') : new List <String> ();
        toaddresses.add(clickCollectCase.SuppliedEmail);

        HFS_Utils.sendEmailWithoutContact(OWA, toaddresses, template, clickCollectCase);

    }

    public static List<HFS_Features__mdt> getVillageHFSFeatures(String villageName){
        return [SELECT Id, Brand_Capture__c, MasterLabel, Privilege_Terms_Condition__c, Default_Lang__c, Registration_Email_Sender__c, Promo_Code__c, Registration_Location__c, Person_Registering__c, Click_And_Collect__c, Collect_Email_Recipients__c FROM HFS_Features__mdt WHERE MasterLabel =:villageName];
    }
    
    // an object to use to serialise (SelectOption)
    public class DropdownOption{
        public DropdownOption(String itemvalue, String itemname){
            val = itemvalue;
            name = itemname;
            notAnOption = false;
        }
        public DropdownOption(String itemvalue, String itemname, Boolean notAnOptionvalue){ 
            val = itemvalue;
            name = itemname;
            notAnOption = notAnOptionvalue;
        }
        public String val {get;set;}
        public String name {get;set;}
        public Boolean notAnOption {get;set;}
    }
    
    private static void getMarketingCampaigns(){
        
        
    }
}