global with sharing class HNW_HFSPageController{
    
    public Visit__c visitRecordInfo ;
    public Visit__c getvisitRecordInfo()
    {
        return visitRecordInfo;
    }
    public void setVisit(Visit__c visitRecordInfo)
    {
        this.visitRecordInfo = visitRecordInfo;
    }
    public String visitId {get;set;}
    
    public list<SelectOption> villages {get; set;}
    public list<SelectOption> languages  {get; set;}
    public list<SelectOption> genders  {get; set;}
    public static String userVillage {get; set;}
    public static String userVillageCode {get; set;}
    public static String guesttypes {get; set;}
    public static string paymentstatuses { get; set; }
    public static String pickuplocations {get; set;}
    public static String salutations {get; set;}
    public static String marketingcampaign {get; set;}
    public static Boolean needsPromoCode {get;set;}
    public static Boolean needsRegistrationLocation {get; set;}
    public static Boolean needsPersonRegistering {get; set;}
    private map<string, map<string, string>> enumMap = new map<string, map<string, string>>();
    public static String lang {get; set;}
    public static String languagelabels {get;set;}
    public static Id accountId {get;set;}
    public static String guestTitle {get;set;}
    public static String guestFirstName {get;set;}
    public static String guestLastName {get;set;}
    public static String guestEmail {get;set;}
    public static String guestMobileNumber {get;set;}
    public static String guestCountry {get;set;}
    public static HFS_CountryController countriesController = HFS_CountryController.getInstance();
    public static String firstCountriesListStr {get;set;}
    public static String otherCountriesListStr {get;set;}
    public static String privilegeGuestCode  {get;set;}
    
    public static String[] labelsonpage = new String[]{'PleaseHandThisBack','RefuseToAnswer','ShoppingExpress','PublicBus','PrivateHire','Taxi','SmallCoach','LargeCoach','Train','Car','Paid',
        'PayOnCollect','FreeofChargeValet','FreeofChargeVIP','PaymentStatus','SaveHFSRegistration','HandsFreeShoppingRegistration',
        'TermsConditions','Iagreewiththe','SaveGuestDetails','CancelRegistration','VillagePrivacyNotice','PrivacyStatement','LastName','FirstName','ClearSignatureButton',
        'NewGuestRegistration','HFSTitle','Email','MobileNumber','Tel','CountryOfResidence','MethodOfTransport','PriviligeOptionalSelect','VIPCardGuest','ScanOrManuallyEnter','VIPCardRegistration','CancelRegistration',
        'ScanVIPCard','Close','PleaseComplete','PickupLocation','MarketingCampaign','NoAssociatedMarketingActivity','LeafletDMCode','PrivilegeQRCode','ScanQRGuestCode','DetectedQRCode','AssociateVIPGuest','RegistrationLocation','RegistrationGuest',
        'Yes','No','Finish','AddAnotherService','LeafletQRCode'};
            
            public static Boolean isHFShost { get;  set;}
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public HNW_HFSPageController(ApexPages.StandardController stdController) {
        
        Account guestAccount;
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        
        if (accountId != null){
            guestAccount = [SELECT ID, Salutation, FirstName, LastName, PersonEmail, PersonMobilePhone, Country_of_Residence__c FROM Account WHERE Id = :accountId];
            guestTitle = guestAccount.Salutation;
            guestFirstName = guestAccount.FirstName;
            guestLastName = guestAccount.LastName;
            guestEmail = guestAccount.PersonEmail;
            guestMobileNumber = guestAccount.PersonMobilePhone;
            guestCountry = countriesController.getCountryCode(guestAccount.Country_of_Residence__c);
            Account privilegeAccount = HFS_Utils.searchPrivilegeGuest(guestEmail, guestFirstName, guestLastName);
            privilegeGuestCode = privilegeAccount != null ? privilegeAccount.BarcodeNumber__c : '';
        }
        userVillage = getUsersVillage();
        System.debug('Language Test: '+lang);
        List<HFS_Features__mdt> villageFeatures = getVillageHFSFeatures(userVillage); //Get the default language for the village
        lang = villageFeatures.isEmpty() ? 'en' : villageFeatures.get(0).Default_Lang__c;
        needsPromoCode = villageFeatures.isEmpty() ? false : villageFeatures.get(0).Promo_Code__c;
        needsPersonRegistering = villageFeatures.isEmpty() ? false : villageFeatures.get(0).Person_Registering__c;
        needsRegistrationLocation = villageFeatures.isEmpty() ? false : villageFeatures.get(0).Registration_Location__c;
        languagelabels = getLanguageLabels(lang);
        salutations = getSalutations(lang);
        
        getGuestServicesData();
        getCountriesData();
        
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
        List<Guest_Services_Data__c> guestServiceData = [SELECT ID, Data_Code__c, Data_Label__c, Service_Data_Type__c, Village__c FROM Guest_Services_Data__c WHERE Village__c = :userVillage];
        // get all the marketing campaigns data for this particular village
        Village__c village = [SELECT ID FROM Village__c WHERE Name =: userVillage LIMIT 1];
        List<Marketing_Campaign__c> marketingCampaignData = [SELECT ID, Name, Short_Description__c, Village__c FROM Marketing_Campaign__c WHERE Village__c =: village.Id];
        
        // now based on what type is on the data, we give that to the select lists
        list<DropdownOption> guestTypereturnList = new list<DropdownOption>();
        list<DropdownOption> pickupLocationreturnList = new list<DropdownOption>();
        list<DropdownOption> salutationsreturnList = new list<DropdownOption>();
        list<DropdownOption> paymentstatusreturnList = new list<DropdownOption>();
        // now based on what type is on the data, we give that to the select lists
        list<DropdownOption> marketingCampaignreturnList = new list<DropdownOption>();
        
        for(Guest_Services_Data__c guestdataitem :guestServiceData){
            if(guestdataitem.Service_Data_Type__c == 'Guest Type' ){
                guestTypereturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
            }
            else if(guestdataitem.Service_Data_Type__c == 'HFS Collection Location' ){
                pickupLocationreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
            } 
            else if(guestdataitem.Service_Data_Type__c == 'HFS Payment Status' ){
                paymentstatusreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));
            } 
        }
        
        //DEV TEAM L
        if(!marketingCampaignData.isEmpty()){
            for(Marketing_Campaign__c marketingcampaigndataitem : marketingCampaignData){
                marketingCampaignreturnList.add(new DropdownOption(marketingcampaigndataitem.Short_Description__c,marketingcampaigndataitem.Name));
            }
            
            marketingcampaign = JSON.serialize(marketingCampaignreturnList);
        }else{
            //marketingcampaign = '[{"val":"_No campaigns available_","notAnOption":false,"name":"_No campaigns available_}]';
        }
        
        paymentstatuses = JSON.serialize(paymentstatusreturnList);
        guesttypes = JSON.serialize(guestTypereturnList);
        pickuplocations = JSON.serialize(pickupLocationreturnList);
    }
    
    {
        visitRecordInfo = new Visit__c();
    } 
    
    List<String> ServicesUsedSelection= new List<String>();
    
    public List<String> getServicesUsedSelection()
    {
        return ServicesUsedSelection;
    }
    
    public void setServicesUsedSelection(List<String> servicesSelected)
    {
        
        this.ServicesUsedSelection =  servicesSelected   ;
    }
    
    public List<SelectOPtion> getServicesUsed()
    {
        List<SelectOption> options = new List<SelectOPtion>();
        for(Schema.PickListEntry pl : Visit__c.Services_Used__c.getDescribe().getPicklistValues())
        {
            options.add(new SelectOption(pl.getLabel(),pl.getValue())) ;
        }
        return options;
        
    } 
    
    @RemoteAction
    global static List<Village_Presence__c> searchBrand(String brandName, String village){
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
        
        String query = 'SELECT Id, Name FROM Village_Presence__c '+ 
            ' WHERE Village__c = :villageID AND Name LIKE \'%'+brandName+'%\' AND Status__c = \'Trading\' LIMIT 20';
        List<Village_Presence__c> VPs = Database.query(query);
        System.debug('VPs: ' + VPs );
        return VPs;
        
    }
    
    
    @RemoteAction
    global static String getSalutations(String thislang){
        List<LabelValue> Salutationlblvals = new List<LabelValue>();
        
        Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            LabelValue lval = new LabelValue();
            lval.LabelName = pickListVal.Label;
            Lval.LabelValue = pickListVal.Value;
            Salutationlblvals.add(lval);
        }
        
        return JSON.serialize(Salutationlblvals);      
    }
    
    @RemoteAction
    global static string getLanguageLabels(String thislang){
        // gets the labels for this page, for display by angular
        List<Custom_Label__c> custlabels = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c WHERE (Language__c = :thislang AND Name IN :labelsonpage AND Used_in_App__c = 'HFS' AND Used_on_page__c LIKE '%HNW_HFSPage%') OR (Language__c = :thislang AND Used_in_App__c = 'HFS' AND Used_on_page__c LIKE '%HNW_HFSPage%' AND NAME LIKE '%Salutation%') ];
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
        
        if(villageURL.size() == 0 || villageURL == NULL ){
            return 'https://www.tbvsc.com/bicester-village/en/legal/private-client-privacy-notice';
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
        
        if(villageURL.size() == 0 || villageURL == NULL ){
            return 'https://www.tbvsc.com/bicester-village/en/legal/hands-free-shopping-terms-and-conditions';
        }
        else{
            return villageURL[0].Village_Terms_and_Conditions__c;
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
    global static String saveSignature(String imageUrl, String objId, String signatureName) {
        
        try {
            /*
Attachment accSign = new Attachment();
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
        //return null; 
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
    global static String saveHFSShopping(String accountId, String email, String firstname, String lastname, 
                                         String mobilenum, String collectlocationname, String collectlocationcode,
                                         String guesttypename, String guesttypecode, String villagename,
                                         String signatureURL, String paymentStatus, String hfsprivileged,
                                         String qrCode, String servicetypename, String servicetype, String salutation, 
                                         String marktCamp, String visitId, String countryCode, String regLanguage, String promoCode,
                                         String registrationLocation, String personRegistering) {
                                             
                                             
                                             SYSTEM.debug('FIRST NAME: '+firstname+' - LAST NAME: '+lastname);
                                             if(accountId!=null && accountId!='' && accountId.length() >= 15){
                                                 accountId = accountId.subString(0, 15);
                                             }
                                             
                                             // use this data to create a new case
                                             // get village ID from village name
                                             ID villageID;
                                             String VillageCode;
                                             Village__c v = [select Id, Village_Code__c from Village__c where Name = :villagename limit 1];
                                             
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
                                                             WHERE Service_Guest_ID__c like :GuestIDcalculatedwildcard ORDER BY Guest_ID_Number_Part__c DESC LIMIT 1];
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
                                             
                                             if(accountId != null && accountId != ''){
                                                 hfsrecord.AccountId = Id.valueOf(accountId);
                                                 Account guestAccount = [SELECT Id, Country_of_residence__c FROM Account WHERE Id =: accountId];
                                                 if (guestAccount.Country_of_residence__c != countriesController.getCountryLabel(countryCode)) {
                                                     guestAccount.Country_of_residence__c = countriesController.getCountryLabel(countryCode);
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
                                             hfsrecord.Language_on_Registration__c = regLanguage;
                                             hfsrecord.Visit__c = visitId;
                                             hfsrecord.Country_of_Residence__c = countriesController.getCountryLabel(countryCode);
                                             hfsrecord.HFS_Promo_Code__c = promoCode;
                                             hfsrecord.HFS_Registration_Location__c = registrationLocation;
                                             hfsrecord.HFS_Person_Registering__c = personRegistering;
                                             system.debug('=====> insert');
                                             insert hfsrecord;
                                             
                                             if(hfsrecord.Id != null){
                                                 // now we can save the signature        
                                                 saveSignature(signatureURL,hfsrecord.Id , 'Signup Signature');
                                                 // and we can send the user an email
                                                 sendEmail(hfsrecord);
                                             }
                                             system.debug('=====> '+hfsrecord.Service_Guest_Number__c);
                                             return hfsrecord.Service_Guest_Number__c;
                                         }
    
    
    public static void sendEmail(Case caseRecord){
        EmailTemplate templateId = [Select id from EmailTemplate where  developername = 'HFS_Registration'];
        
        LIST<string> toaddress = New List<String>();
        toaddress.add(caseRecord.SuppliedEmail);
        
        //randon contact selected to dummy set it as the TargetId Messaging.SingleEmailMessage                  
        Contact c = [select id, Email from Contact where email <> null AND email LIKE '%@valueretail.com%' limit 1];
        system.debug(c.email);
        
        //Retrive the village Name to decide which Org Wide Address we need to use
        Village__c village = [SELECT Name FROM Village__c WHERE Id =: caseRecord.Village__c];
        HFS_Features__mdt villageMetadata = getVillageHFSFeatures(village.Name)[0];
        OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address =: villageMetadata.Registration_Email_Sender__c limit 1];
        
        try{
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            msg.setTemplateID(templateId.Id); 
            msg.setTargetObjectId(c.id);
            msg.setWhatId(caseRecord.id);
            msg.setToAddresses(toaddress);
            lstMsgs.add(msg);
            
            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(lstMsgs);
            Database.rollback(sp); // Email will not send as it is rolled Back
            
            //Get the id for the senders "FROM" address
            
            // Send Actual email
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
            for (Messaging.SingleEmailMessage email : lstMsgs) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(toaddress);
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                emailToSend.setOrgWideEmailAddressId(OWA.id);
                lstMsgsToSend.add(emailToSend);
            }
            system.debug('List of maessage' +lstMsgsToSend);
            Messaging.sendEmail(lstMsgsToSend);
            
        } 
        catch (Exception e){
            //message = 'A general exception occured, please contact you administrator\nMessage detail: ' +e.getmessage();  
        }
    }
    
    @RemoteAction
    public static void createAndAssociateVIPCard(String accountId, String visitId, String vipCardNumber){
        //accountId = String.valueOf(accountId).subString(0,15);
        
        VIP_Card_Exchange__c newVIPCard = new VIP_Card_Exchange__c();
        newVIPCard.VIP_Card_Code__c = vipCardNumber;
        newVIPCard.Visit__c = visitId;
        if(accountId!=null && accountId!=''){
            accountId = accountId.subString(0,15);
            System.debug('AccountID '+accountId+'; VisitID '+visitId + '; vipCardNumber '+vipCardNumber);
            newVIPCard.Guest__c = accountId;    
        }
        
        
        try{
            INSERT newVIPCard;
            System.debug('VIP ID' + newVIPCard.Id);
        }
        catch(DMLException ex){
            System.debug('VIP Card Error!!');
        }
    }
    
    public static List<HFS_Features__mdt> getVillageHFSFeatures(String villageName){
        return [SELECT Id, Brand_Capture__c, MasterLabel, Privilege_Terms_Condition__c, Default_Lang__c, Registration_Email_Sender__c, Promo_Code__c, Registration_Location__c, Person_Registering__c FROM HFS_Features__mdt WHERE MasterLabel =:villageName];
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
    
    // an object to use to serialise (SelectOption)
    public class DropdownOption{
        public DropdownOption(String itemvalue, String itemname){
            val = itemvalue;
            name = itemname;
            notAnOption = false;
        }
        
        public String val {get;set;}
        public String name {get;set;}
        public Boolean notAnOption {get;set;}
    }
    
    
    global void getVisitInfo(){
        System.debug('>>> visitId'+visitId);
        
        List<Visit__c>  visits = [Select id, Name, Services_Used__c,Number_of_Guests__c,Number_of_Children__c,    Virtual_Visit__c,Walk_in_Booked__c,Visit_Source__c,Visit_Notes__c,
                                  Partnership__c,Visit_Source_Notes__c,Domestic_or_International_Partner__c,Brand_Event__c, Personal_Shopper__c,Brand_Referral__c,Private_Client_Team__c,Marketing_Activity__c,Village_Specific__c From Visit__c
                                  where Id = :visitId];
        visitRecordInfo = visits.isEmpty() ? new Visit__c():visits[0];
        System.debug('>>> visitId'+ visitRecordInfo);
    }
    
    global PageReference saveVisitInfo()
    {
        visitRecordInfo.Id = visitId;
        visitRecordInfo.Services_Used__c = ServicesUsedSelection.isEmpty() ? '':String.join(ServicesUsedSelection,';');
        SYstem.debug('VIDSIT**************'+JSON.serialize(visitRecordInfo));
        update visitRecordInfo;
        return null;
    }
}