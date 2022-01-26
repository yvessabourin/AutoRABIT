global with sharing class HandsFreeShoppingGuestExtension {
    
    private final sObject mysObject;
    
    public static ID caseID {get;set;}
    public static String CaseInfo {get;set;}
    public static String CaseItems {get;set;}
    public static String GuestBags {get;set;}
    public static string HFSIncidents {get;set;}
    public static boolean viewIncidents {get;set;}
    public static Decimal caseBagCount {get;set;}
    
    public static String GuestBagsCollection {get;set;}
    public static String GuestBagsPendingCollection {get;set;}
    
    public static String userVillage {get; set;}
    public static String userVillageCode;
    public static String bagBarcode {get; set;}
    public static String pickuplocations {get; set;}
    public static Boolean stopLoopBags { get; set; }
    
    public static final Integer BRAND_LIST_LIMIT = 20;
    
    public static Integer totalBagForCollection {get; set;}
    public static Boolean isHFSHistoric { get;  set;}
    public static String collectionLocationCode { get;  set;}
    public Boolean isRunner{get;set;}
    public Id userId;
    public String userName{get;set;}

    public static Boolean isLostQRcode { get;  set;}
    public static Boolean isCheckoutBags { get;  set;}
    public static Boolean isClosed { get;  set;}    
    public static Boolean isVIP { get;  set;}    
    public static String privilegeType { get;  set;}    

    public static Boolean isNewItem { get;  set;}
    public static Boolean isAgedItem { get;  set;}
    
    public static String lang {get; set;}
    public static String languagelabels {get;set;}
    public static String[] labelsonpage = new String[]{'WhatcouldweImprove','Verylikely','Notlikelyatall','Howlikelyareyoutorecommendtheservice','Highlysatisfied',
        'Highlydissatisfied','Whatisyourlevelofsatisfactionwiththeservice','Considerablymorethanplanned','Spentasmuchasexpected','Lessthanplanned','Morethanplanned',
        'Whatwasthevalueofyourspendtoday','CancelButton','BackButton','CompleteHandoverButton','ClearSignatureButton',
        'HFSFinishedConfirmation','BagCollectionConfirmation','TotalBagsforCollection',
		'NoBagsYet','Brand','Barcode','SummaryScannedGuestBag','GuestHandover'};
	public static String defaultLang {get; set;}
	public static HFSSpentLevelCalculator currencyLevelCalculator;
	private static final String TEXT_VIP = 'VIP Guest';
	private static final String TEXT_PRIVILEGE = 'Privilege Guest';
    private static final String TEXT_NON_PRIVILEGE = 'Non-Privilege Guest';
	public static Boolean hasClickCollect {get; set;}
    public static Boolean isClickCollect {get; set;}
    
    //jsonData = JSON.serialize(MyWrapperClass)
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public HandsFreeShoppingGuestExtension(ApexPages.StandardController stdController) {
        
		viewIncidents = false;
		isVIP = false;
        
        lang = 'en'; // default to english if the language isnt set
        languagelabels = getLanguageLabels(lang);
        

        
        this.mysObject = (Case)stdController.getRecord();
        caseID = this.mysObject.Id;
        userId = Userinfo.getUserId();
        List<HFS_Runner__c> runners = [SELECT Id, User__c FROM HFS_Runner__c WHERE User__c =: userId];
        if(!runners.isEmpty()){
            isRunner = true;
        } else {
            isRunner = false;
            User currentUser = [SELECT Id, Name FROM User WHERE Id =: userId];
            userName = currentUser.Name;
        }
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        Case hfsCase = [Select Status,Service_Date__c,Total_Bags_of_the_Guest__c, HFS_Click_And_Collect__c FROM Case WHERE ID =: caseID];
        
        caseBagCount = hfsCase.Total_Bags_of_the_Guest__c;
        isClickCollect = hfsCase.HFS_Click_And_Collect__c;
        
        userVillage = getUsersVillage();
        
        HFS_Features__mdt villageMetadata = getVillageHFSFeatures(userVillage)[0];
        hasClickCollect = villageMetadata.Click_And_Collect__c;

		currencyLevelCalculator = HFS_Utils.getCurrencyLevelCalculator(userVillageCode);
		getCaseData();
        getCaseItemsData();
        getGuestBagsData();
        getGuestBagsCollection(caseID);
        getGuestBagsPendingCollection(caseID);
        System.debug(CaseInfo);
        getGuestServicesData();
		getHFSIncidentData();
        getDefaultLanguage(userVillage);

        isHFSHistoric = true;
        isLostQRcode = true;
        isCheckoutBags = true;
        isNewItem = true;
        isClosed = false;

        System.debug('ProfileName: ' + profileName);    

        if(profileName == 'HFS Co-ordinator'){
            //isLostQRcode = false;
            //isCheckoutBags = false;
            viewIncidents = true;
        } 
        if(profileName == 'System Administrator'){
            //isLostQRcode = false;
            //isCheckoutBags = false;
            viewIncidents = true;
        } 
        if(profileName == 'HFS Host'){
            isHFSHistoric = false;
        }
        
        /* US-43703: Temporarely exclude Bicester to allow the GSA to add new Shopping Items*/ 
        if(profileName == 'HFS VR Assistant' && !hasClickCollect){
            isNewItem = false;
        }

        if(hfscase.Status == 'Closed' || hfscase.Status == 'Did Not Participate'){
             isClosed = true;
        }
        
        if(hfscase.Service_Date__c < SYSTEM.today()){
            isAgedItem = true;    
        }else{
            isAgedItem = false;  
        }
       
    }
    
    @RemoteAction
    global static string getLanguageLabels(String thislang){
        // gets the labels for this page, for display by angular
        List<Custom_Label__c> custlabels = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c WHERE Language__c = :thislang AND Name IN :labelsonpage AND  Used_in_App__c = 'HFS' AND Used_on_page__c LIKE '%HFSGuestCheckOutPage%' ];
        List<LabelValue> lblvals = new List<LabelValue>();
        for(Custom_Label__c cl :custlabels){
            LabelValue lval = new LabelValue();
            lval.LabelName = cl.Name;
            Lval.LabelValue = cl.Custom_Label_Value__c;
            lblvals.add(lval);
        }

        return JSON.serialize(lblvals);
    }
    
     private class LabelValue{
        String LabelName {get; set;}
        String LabelValue {get; set;}
     }
    
    private static string getUsersVillage(){
        
        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c  FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
        Village__c uservillage  = [SELECT Name, Village_Code__c FROM Village__c WHERE Name =:users[0].Village__c LIMIT 1];        
        string village = users[0].Village__c;
		userVillageCode = uservillage.Village_Code__c;
        
        return village; 
        
	}
	
	public static void getDefaultLanguage(String villageName) {
		List<HFS_Features__mdt> features = [SELECT Id, Brand_Capture__c, MasterLabel, Privilege_Terms_Condition__c, Default_Lang__c FROM HFS_Features__mdt WHERE MasterLabel =:villageName];
		if (!features.isEmpty()) {
			defaultLang = features[0].Default_Lang__c;
		} else {
			defaultLang = 'en';
		}
	}

    global static String getcollectionLocation() {
        
        List<Case> collectionL = [SELECT HFS_Collection_Location__c FROM Case WHERE ID = :caseID];
        return collectionL[0].HFS_Collection_Location__c;
        
    }
    
    global static void getCaseData() {
        
        Case guestCase = [SELECT SuppliedName, SuppliedPhone, SuppliedEmail, Type, Village__c, Mode_of_Transport__c, 
                                   HFS_Collection_Location__c, Service_Guest_ID__c, Service_Guest_Number__c, 
                                   Guest_ID_Number_Part__c , Status,Historic_Close_Reason__c, Account.RecordType.DeveloperName, Account.PersonEmail,
								   Client_QR_Code__c, HFS_Code_Changed__c, toLabel(HFS_Leaflet_Type__c), HFS_Click_And_Collect__c, HFS_Collection_Date__c
								   FROM Case WHERE ID = :caseID];
		getPrivilegeSettings(guestCase);			
		CaseInfo = JSON.serialize(guestCase);

	}
	
	public static void getPrivilegeSettings (Case hfsCase) {
		if (hfsCase.Account.RecordType.DeveloperName == 'VIP_Guest') {
			isVIP = true;
			privilegeType = TEXT_VIP;	
		} else if (hfsCase.Account.RecordType.DeveloperName == 'Guest')  {
			List<Account> existingVIPGuests = HFS_Utils.searchVIPGuestByEmail(hfsCase.Account.PersonEmail);
			isVIP = existingVIPGuests.isEmpty() ? false : true;
			privilegeType = existingVIPGuests.isEmpty() ? TEXT_PRIVILEGE : TEXT_VIP;
		} else {
			privilegeType = TEXT_NON_PRIVILEGE;
		}
	}
    
    global static void getCaseItemsData() {
		
		List <Case_Item__c> ciList = [SELECT ID, Name, Village_Presence__r.Name, Status__c , Item_Count__c ,Start_Time__c, Estimated_Spend__c FROM Case_Item__c WHERE Case__c = :caseID];
		for (Case_Item__c ci : ciList) {
			//Using the field Bag_Barcodes_Manual__c to put the currency formatted to get it into the page
			ci.Bag_Barcodes_Manual__c = currencyLevelCalculator.getFormattedCurrency(ci.Estimated_Spend__c);
		}
		CaseItems = JSON.serialize(ciList);
		
    }
    
    
    //All the HFS Incidents related to the Case
    global static void getHFSIncidentData() {
        
        
        System.debug('caseDEBUG ' + caseID);
        
        List<HFS_Incident__c> allGuestHFSIncidents = [SELECT ID,Name, Bag_s_returned_to_guest__c,Brand_Involved__c,Date_of_Incident__c,Impact__c,Incident_Description__c,Incident_Reason__c,Incident_Reason_Other__c,Is_Resolved__c,Is_Retail_Manager_Aware__c,
                                                      RecordType.Name,Resolution_Notes__c,Status__c                                                  
                                                      FROM HFS_Incident__c
                                                      WHERE HFS_Case__c = :caseID];   
        HFSIncidents = JSON.serialize(allGuestHFSIncidents);
        
        System.debug('DEBUGx GuestBags: ' + HFSIncidents);
        
    }
    
    //All the bags related to the Case
    global static void getGuestBagsData() {
        
        
        System.debug('caseDEBUG ' + caseID);
        
        List<HFS_Bag__c> allGuestBags = [SELECT ID, Name, Brand__c, HFS_Purchase__c,Barcode__c,Scanned__c,Scanned_for_collection__c,Status__c,
                                         HFS_Storage_Location__c,HFS_Storage_Location__r.Name,  HFS_Purchase__r.Village_Presence__r.Brand__r.Name,
                                         Delivered_to_Guest__c,Oversized__c, HFS_Purchase__r.Village_Presence__r.Name,Storage_Matches_Guest_Collection_Point__c
                                         FROM HFS_Bag__c
                                         WHERE HFS_Purchase__r.Case__c = :caseID];
        
        
        
        
        GuestBags = JSON.serialize(allGuestBags);
        
        System.debug('DEBUGx GuestBags: ' + GuestBags);
        
    }
    
    global static void getGuestServicesData(){
        
        /*
        // get all the guest services data for this particular village
        List<Guest_Services_Data__c> guestServiceData = [SELECT ID, Data_Code__c, Data_Label__c, Service_Data_Type__c, Village__c FROM Guest_Services_Data__c WHERE Village__c = :userVillage];
        // get all the marketing campaigns data for this particular village
        Village__c village = [SELECT ID FROM Village__c WHERE Name =: userVillage LIMIT 1];
        
        // now based on what type is on the data, we give that to the select lists
        list<DropdownOption> pickupLocationreturnList = new list<DropdownOption>();
        
        // guestTypereturnList.add(new DropdownOption('placeholder','Guest Type',true));
        //  pickupLocationreturnList.add(new DropdownOption('placeholder','Pickup Location',true));
        for(Guest_Services_Data__c guestdataitem :guestServiceData){
            if(guestdataitem.Service_Data_Type__c == 'HFS Collection Location' ){
                pickupLocationreturnList.add(new DropdownOption(guestdataitem.Data_Code__c,guestdataitem.Data_Label__c));                
                if( guestdataitem.Data_Label__c == getcollectionLocation() ){ //To set pre-defined bag drop pick-up location
                    collectionLocationCode = guestdataitem.Data_Code__c;
                }               
            } 
        }
        */
        // get all the guest services data for this particular village
        string str = '%'+userVillage+'%';
        List<HFS_Collection_Point__c> collectionPoint = [SELECT Name FROM HFS_Collection_Point__c WHERE name LIKE: str ];
        // get all the marketing campaigns data for this particular village
        //Village__c village = [SELECT ID FROM Village__c WHERE Name =: userVillage LIMIT 1];
        
        // now based on what type is on the data, we give that to the select lists
        list<DropdownOption> pickupLocationreturnList = new list<DropdownOption>();
        
        // guestTypereturnList.add(new DropdownOption('placeholder','Guest Type',true));
        //  pickupLocationreturnList.add(new DropdownOption('placeholder','Pickup Location',true));
        for(HFS_Collection_Point__c guestdataitem :collectionPoint){           
                pickupLocationreturnList.add(new DropdownOption(guestdataitem.Name,guestdataitem.Name));                
                if( guestdataitem.Name == getcollectionLocation() ){ //To set pre-defined bag drop pick-up location
                    collectionLocationCode = guestdataitem.Name;
                } 
        }

        pickuplocations = JSON.serialize(pickupLocationreturnList);
    }
    
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
    
    @RemoteAction
    global static List<Village_Presence__c> searchBrand(String brandName, String village){
        
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
        
        String query = 'SELECT Id, Name FROM Village_Presence__c '+ 
            ' WHERE Village__c = :villageID AND Name LIKE \'%'+brandName+'%\' AND Status__c = \'Trading\' LIMIT '+ BRAND_LIST_LIMIT;
        List<Village_Presence__c> VPs = Database.query(query);
        System.debug('VPs: ' + VPs );
        return VPs;
    }
    
    
     @RemoteAction
    global static String checkOutNoBags(string caseId){
        
        case theCase = [select id, status FROM Case where id =: caseId];
        thecase.Status = 'Did Not Participate';
        
        try{
            update thecase;
            return 'Success';
        }
        catch (exception e){
            return e.getMessage();            
        }       
    }
    
    
    @RemoteAction
    global static String saveHFSIncident(string CaseID, String theDate, String IncidentType, String IncidentReason, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){
     //   theDate,Incident_Type__c,Incident_Reason__c,Incident_Reason_Other__c,status__c,Incident_Description__c,BagsReturned,IssueResolved,RetailManagerAware,Impact__c,Resolution_Notes__c,Brand_Involved__c
        
        string varDate1 = theDate + ' 00:00:00';        
        date incidentDate = Date.valueOf(varDate1);
        
        RecordType RT = [SELECT Id, Name FROM RecordType WHERE Name =:IncidentType AND SobjectType = 'HFS_Incident__c' ];
        HFS_Incident__c HFSI = new HFS_Incident__c();
        HFSI.RecordTypeId = RT.Id;
        HFSI.HFS_Case__c = caseID;
        HFSI.Date_of_Incident__c = incidentDate;
        HFSI.Brand_Involved__c = Brand;
        
        if(BagsReturned == '<-- Please Select an Option -->'){
            HFSI.Bag_s_returned_to_guest__c = '';
        }else{
            HFSI.Bag_s_returned_to_guest__c = BagsReturned;
        }

        HFSI.Impact__c = Impact;
        HFSI.Incident_Description__c = Description;
        
        if(IncidentReason == '<-- Please Select an Option -->'){
            HFSI.Incident_Reason__c = '';
        }else{
            HFSI.Incident_Reason__c = IncidentReason;
        }
        
        HFSI.Incident_Reason_Other__c = IncidentReasonOther;
        
        if(Resolved == '<-- Please Select an Option -->'){
            HFSI.Is_Resolved__c = '';
        }else{
            HFSI.Is_Resolved__c = Resolved;
        }
        
        if(RetailMgrAware == '<-- Please Select an Option -->'){
            HFSI.Is_Retail_Manager_Aware__c = '';
        }else{
            HFSI.Is_Retail_Manager_Aware__c = RetailMgrAware;
        }
               
        HFSI.Resolution_Notes__c = ResNotes;
        
        if(Status == '<-- Please Select an Option -->'){
            HFSI.Status__c = '';
        }else{
            HFSI.Status__c = Status;
        }
        
        try{
            insert HFSI;
            return 'Success';
        }catch (exception e){
            return 'An error has occurred, please forward the below message to your administrator : ' + e.getMessage() + ' ---- ' + e.getCause() + ' ---- ' + e.getLineNumber();
        }
     }
    
    @RemoteAction
    global static String updateHFSIncident(string theIncidentId, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){
     //   theDate,Incident_Type__c,Incident_Reason__c,Incident_Reason_Other__c,status__c,Incident_Description__c,BagsReturned,IssueResolved,RetailManagerAware,Impact__c,Resolution_Notes__c,Brand_Involved__c
        
        //RecordType RT = [SELECT Id, Name FROM RecordType WHERE Name =:IncidentType AND SobjectType = 'HFS_Incident__c' ];
        HFS_Incident__c HFSI = [SELECT ID,Status__c, Resolution_Notes__c, Is_Retail_Manager_Aware__c, Is_Resolved__c, Incident_Reason_Other__c, Incident_Description__c, Impact__c, Bag_s_returned_to_guest__c, Brand_Involved__c FROM HFS_Incident__c WHERE ID =:theIncidentId ];
        HFSI.Brand_Involved__c = Brand;
        
        if(BagsReturned == '<-- Please Select an Option -->'){
            HFSI.Bag_s_returned_to_guest__c = '';
        }else{
            HFSI.Bag_s_returned_to_guest__c = BagsReturned;
        }

        HFSI.Impact__c = Impact;
        HFSI.Incident_Description__c = Description;
                
        HFSI.Incident_Reason_Other__c = IncidentReasonOther;
        
        if(Resolved == '<-- Please Select an Option -->'){
            HFSI.Is_Resolved__c = '';
        }else{
            HFSI.Is_Resolved__c = Resolved;
        }
        
        if(RetailMgrAware == '<-- Please Select an Option -->'){
            HFSI.Is_Retail_Manager_Aware__c = '';
        }else{
            HFSI.Is_Retail_Manager_Aware__c = RetailMgrAware;
        }
               
        HFSI.Resolution_Notes__c = ResNotes;
        
        if(Status == '<-- Please Select an Option -->'){
            HFSI.Status__c = '';
        }else{
            HFSI.Status__c = Status;
        }
        
        try{
            update HFSI;
             system.debug('successfully update');
            return 'Success';
            
        }catch (exception e){
         system.debug('exception caught');
            return 'An error has occurred, please forward the below message to your administrator : ' + e.getMessage() + ' ---- ' + e.getCause() + ' ---- ' + e.getLineNumber();
        }
     }
        
    @RemoteAction
    global static String clearoutHistoricItems(String ClosingAgent, String HistoricCloseReason, string caseID ){
        
        case thecase = [SELECT id,Status FROM case WHERE id =: caseID];
        
        list<case_item__c> purchases = [SELECT id, name from case_item__c where case__c =: caseID ];
        
        list<HFS_Bag__c> bags = [SELECT Id, Name FROM HFS_Bag__c where HFS_Purchase__c IN: purchases ];
        
        list<HFS_Job__c> jobs = [SELECT Id, Name,Job_Status__c FROM HFS_Job__c where HFS_Purchase__c IN: purchases ];
        
        for(HFS_Job__c job : jobs){
                   job.Job_Status__c = 'Bags Putaway';
        }
        
        for(HFS_Bag__c bag : bags){
                   bag.Status__c = 'Collected';
        }
        
        for(case_item__c purch : purchases){
                   purch.Status__c = 'Guest Collected';
        }
        
        thecase.Status = 'Closed';
        //mark as historically closed
        thecase.Was_Historically_Closed__c = true;
        thecase.Historic_Close_Reason__c = ClosingAgent + ' - ' + system.now() + ' - ' + HistoricCloseReason;
        
        string error = '';
        try{      
            update jobs;
            update bags;
            update purchases;
            update thecase;
        }
        catch(exception e){
             error = e.getmessage();
        }
        
        if(error != ''){
            return error;
        }  
        else{
            return caseID;
        }        
    }


    //
    @RemoteAction
    global static String saveBagTransfer(String brandID, String caseID , String sourceTransf,String destTransf ){

        List <HFS_Relation_Collection_Storage__c> origininatingLocation =  [SELECT HFS_Collection_Point__c, HFS_Collection_Point__r.Name, HFS_Storage_Point__r.Name FROM HFS_Relation_Collection_Storage__c WHERE HFS_Collection_Point__r.Name=: sourceTransf];
        List <HFS_Relation_Collection_Storage__c> destinationLocation =  [SELECT HFS_Collection_Point__c, HFS_Collection_Point__r.Name, HFS_Storage_Point__r.Name FROM HFS_Relation_Collection_Storage__c WHERE HFS_Collection_Point__r.Name=: destTransf];
 
        list<Case_Item__c> hfsitems = new list<Case_Item__c>();

        Case theCase = [SELECT ID, Status,HFS_Collection_Location__c,Service_Guest_Number__c, Village__c FROM Case WHERE ID =: caseID];
        list<Case_Item__c> purchases = [Select id, Name, Village_Presence__c,Pickup_Location__c,Status__c,Bag_Barcodes_Manual__c FROM Case_Item__c WHERE Case__c =: caseID];


        list<HFS_Bag__c> bags = [SELECT id, Name,HFS_Runner__c,HFS_Storage_Location__c,HFS_Purchase__c,HFS_Runner__r.user__c,Status__c,HFS_Purchase__r.Status__c,HFS_Purchase__r.Pickup_Location__c FROM HFS_Bag__c where HFS_Purchase__c IN: purchases];
        map<id, list<HFS_Bag__c>> bagMap = new map<id, list<HFS_Bag__c>>();

            if(bags != NULL || bags.size() > 0){
                for(HFS_Bag__c bag : bags ){
                    if(bagMap.get(bag.HFS_Runner__c) == NULL){
                        bagMap.put(bag.HFS_Runner__c, new list<HFS_Bag__c>{bag});
                    }
                    else{
                        bagMap.get(bag.HFS_Runner__c).add(bag);
                    }
                }
            }

        list<HFS_Job__c> jobs = [SELECT id, Name,HFS_Runner__c,HFS_Purchase__c,HFS_Runner__r.user__c,Job_Status__c FROM HFS_Job__c WHERE HFS_Purchase__c IN: purchases];
        map<id, list<HFS_Job__c>> jobMap = new map<id, list<HFS_Job__c>>();

            if(jobs != NULL || jobs.size() > 0){
                for(HFS_Job__c job : jobs ){
                    if(jobMap.get(job.HFS_Runner__c) == NULL){
                        jobMap.put(job.HFS_Runner__c, new list<HFS_Job__c>{job});
                    }
                    else{
                        jobMap.get(job.HFS_Runner__c).add(job);
                    }
                }
            }


            try{

                    if(purchases == NULL || purchases.size() == 0){ //No Bags
                        theCase.HFS_Collection_Location__c = destTransf;
                        theCase.Guest_Collection_Point_has_changed__c = true;
                        update theCase;
                        return theCase.id;
                    }

                    else{

                        theCase.HFS_Collection_Location__c = destTransf;
                        theCase.Guest_Collection_Point_has_changed__c = true;
                        update theCase;
                 

                        for(id i : jobMap.keyset()){
                            for(HFS_Job__c job : jobMap.get(i)){

                                if(job.HFS_Runner__c != NULL && job.Job_Status__c != 'Bags Putaway'){

                                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                                    mentionSegmentInput.id =  job.HFS_Runner__r.user__c;
                                    messageBodyInput.messageSegments.add(mentionSegmentInput);

                                    textSegmentInput.text = ' - The Guest Collection Point for This job has been updated to ' + destTransf;
                                    messageBodyInput.messageSegments.add(textSegmentInput);

                                    feedItemInput.body = messageBodyInput;
                                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                                    feedItemInput.subjectId = job.id;
                                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);

                                }

                            }
                        }

                        boolean createTransferJob = false;

                        for(Case_Item__c purchase : purchases){

                            if(purchase.Status__c == 'Ready for Guest Collection' && purchase.Pickup_Location__c != destTransf){
                                createTransferJob = true;
                            }

                        }


                        if(createTransferJob){

                                Case_Item__c hfsitem = new Case_Item__c();
                                hfsitem.Case__c = caseID;
                                hfsitem.Estimated_Spend__c = 0;
                                hfsitem.Item_Count__c = 0;
                                //hfsitem.Village_Presence__c = purchase.Village_Presence__c;
                                hfsitem.Start_Time__c = System.now();
                                hfsitem.Status__c = 'Awaiting Pick-up from ' + sourceTransf;
                                //hfsitem.Bag_Barcodes_Manual__c = purchase.Bag_Barcodes_Manual__c;
                                hfsitem.Pickup_Location__c  = sourceTransf;
                                hfsitem.Require_a_Runner__c = true;
                                hfsitem.HFS_Bag_Transfer__c = true;
                                //hfsitem.HFS_Bag_Drop__c = bagdrop;
                                hfsitems.add(hfsitem);

                        }

                        insert hfsitems;
                        return theCase.id;
                    }

            }
            catch(exception e){
                 return 'ERROR - ' + e.getmessage();
            }

     }   


    
    @RemoteAction
    global static String saveShoppingItem(String brandID, String estimatedSpend, String bagCount, String stringTables, String caseID , String brandshopName,String bagPickUpLocation, boolean requireRunner, boolean bagdrop ){
        
        String userId = UserInfo.getUserId();
        User theUser = [SELECT Id, Village__c FROM User WHERE ID = :userId];

        Case hfsCase = [SELECT ID, Status,HFS_Collection_Location__c,Service_Guest_Number__c,Service_Date__c, Village__c FROM Case WHERE ID =: caseID];

		Village_Presence__c theBrand = [SELECT Id, name,HFS_Bags_Used__c FROM Village_Presence__c WHERE id =: brandID];
		
		//US-41897: When bagdrop is performed, the HFS_Bags_Used__c shouldn't be increased
		if (!bagdrop) {
			theBrand.HFS_Bags_Used__c = theBrand.HFS_Bags_Used__c + Integer.valueof(bagCount);
		}

        List <HFS_Relation_Collection_Storage__c> oRigin =  [SELECT HFS_Collection_Point__c, HFS_Collection_Point__r.Name, HFS_Storage_Point__r.Name FROM HFS_Relation_Collection_Storage__c WHERE HFS_Collection_Point__r.Name=: bagPickUpLocation];
        List <HFS_Relation_Collection_Storage__c> dEstination =  [SELECT HFS_Collection_Point__c, HFS_Collection_Point__r.Name, HFS_Storage_Point__r.Name FROM HFS_Relation_Collection_Storage__c WHERE HFS_Collection_Point__r.Name=: brandshopName];
        //List <HFS_Bag__c> bags = [SELECT Barcode__c FROM HFS_Bag__c WHERE CreatedDate = TODAY AND HFS_Purchase__r.Village_Name__c = :theUser.Village__c];
        List <HFS_Bag__c> bags = [SELECT Barcode__c, HFS_Bag_Active__c  FROM HFS_Bag__c WHERE HFS_Purchase__r.Village_Name__c = :theUser.Village__c AND HFS_Bag_Active__c = :true AND CreatedDate = THIS_WEEK];
        list<HFS_Job__c> jobs = [SELECT id, Name, HFS_Runner__r.user__c,Job_Status__c FROM HFS_Job__c WHERE HFS_Purchase__r.Case__c =: caseID ];

        if(bagCount == ''){
            // if the bag cound wasnt supplied, assume 1
            bagCount = '1';
        }

        
        if(!(bagCount == '0' && estimatedSpend == '0')) { // !Bag transfer

            if(stringTables.indexOf(',,') != -1){
              return 'ERROR - ' + 'Barcode missing!';
            }

            List <String> listBarcodeBags = stringTables.split(',');


            if(bagCount == '1'){
                String aux1 = listBarcodeBags[0];
                if( (!aux1.isNumeric()) && (aux1 != 'TBC') ){
                            return 'ERROR - ' + 'The Bag ' + aux1 +' is not numeric, please try again.';
                }
            }else{
                //System.debug('Lista de bags ' + bags);
                //*2 because every bag needs to run twice
                for(Integer i = 0; (i+2) < (integer.valueof(bagCount))*2; i=i+2){
                    String aux1 = listBarcodeBags[i];
                    for(Integer j = i + 2; j < (integer.valueof(bagCount))*2; j=j+2){
                        String aux2 = listBarcodeBags[j];
                        if( (aux1 == aux2) && (aux1 != 'TBC') ){
                            return 'ERROR - ' + 'The Bag ' + aux1 +' is repeated, please try again.';
                        }
                        if( (!aux1.isNumeric()) && (aux1 != 'TBC')){
                            return 'ERROR - ' + 'The Bag ' + aux1 +' is not numeric, please try again.';
                        }
                         if((!aux2.isNumeric()) && (aux2 != 'TBC')){
                            return 'ERROR - ' + 'The Bag ' + aux2 +' is not numeric, please try again.';
                        }

                    }
                }
            }

            for(Integer i = 0; i < (integer.valueof(bagCount))*2; i=i+2){
                String aux3 = listBarcodeBags[i];
                system.debug(aux3);
                for(HFS_Bag__c bag : bags){
                    if(aux3.equals(bag.Barcode__c) && (aux3 != 'TBC') ){
                        return 'ERROR - ' + 'Bag ' + aux3 +' already exists';
                    }
                }
            }
        }
        
        try{
            
            Case_Item__c hfsitem = new Case_Item__c();
            hfsitem.Case__c = caseID;
            hfsitem.Estimated_Spend__c = Decimal.valueOf(estimatedSpend);
            system.debug('hfsitem.Estimated_Spend__c: ' + hfsitem.Estimated_Spend__c);
            hfsitem.Item_Count__c = Integer.valueOf(bagCount);
            hfsitem.Village_Presence__c = (ID)brandID;
            hfsitem.Start_Time__c = System.now();
            
            system.debug('hfsitem: ' + hfsitem);
            
            if(bagdrop){
                 hfsitem.Status__c = 'Guest Bag(s) Dropped';
            }
            else
            {
                 hfsitem.Status__c = 'Awaiting Pick-up from Brand';
            }
           
            hfsitem.Bag_Barcodes_Manual__c = stringTables;
            hfsitem.Pickup_Location__c  = bagPickUpLocation;
            hfsitem.Require_a_Runner__c = requireRunner;
            hfsitem.HFS_Bag_Transfer__c = false;
            hfsitem.HFS_Bag_Drop__c = bagdrop;
            
            if( bagCount == '0' && estimatedSpend == '0'){ // Bag transfer                
            
                hfsCase.HFS_Collection_Location__c = dEstination[0].HFS_Collection_Point__r.Name;
                hfsCase.Guest_Collection_Point_has_changed__c = true;
                update hfsCase;                
                
                if(oRigin[0].HFS_Storage_Point__r.Name == dEstination[0].HFS_Storage_Point__r.Name || bags.isEmpty() ){
                    return hfsCase.Id;
                }else{
                    hfsitem.HFS_Bag_Transfer__c = true;          
                         //send in_app notification to assigned job owners if one existed for the job
                        if(jobs != NULL || jobs.size() != 0 ){

                            for(HFS_Job__c job : jobs){

                                if(job.Job_Status__c != 'Bags Putaway'){

                                    if(job.HFS_Runner__r.user__c != NULL){

                                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                                        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                                        mentionSegmentInput.id =  job.HFS_Runner__r.user__c;
                                        messageBodyInput.messageSegments.add(mentionSegmentInput);

                                        textSegmentInput.text = ' - The Guest Collection Point for This job has been updated to ' + dEstination[0].HFS_Collection_Point__r.Name;
                                        messageBodyInput.messageSegments.add(textSegmentInput);

                                        feedItemInput.body = messageBodyInput;
                                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                                        feedItemInput.subjectId = job.id;
                                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);

                                    }
                                }
                            }
                }             

                }
            }           
            
            system.debug('Here 1');
            insert hfsitem;
            
            //hfsitem = [SELECT Id, Case__c, convertCurrency(Estimated_Spend__c), Item_Count__c, Village_Presence__c, Start_Time__c  FROM Case_Item__c WHERE Case__c = :caseID];
            //system.debug('hfsitem 2: ' + hfsitem);
            //update hfsitem;
            
            update theBrand;
            
            // now we should also update the Case to be 'in progress' (Shopping)
            if(hfsCase != null && hfsCase.Status != 'Shopping'){
                hfsCase.Status = 'Shopping';
                update hfsCase;
            }
            system.debug('Here 2');
            return hfsCase.Id;
        }
        catch(Exception ex){
            return 'ERROR - ' + ex.getMessage();
        }
        
    }


    
    @RemoteAction
    global static String checkoutGuest(ID caseID, String imageURL, boolean endCase, list<string> feedBackItems, string HistoricCloseReason,string ClosingAgent){
 
        boolean totalcheck = false;

        Guest_Feedback_Survey__c GFS = new Guest_Feedback_Survey__c();
        
        if(feedBackItems != NULL && !feedBackItems.isEmpty()){

                system.debug('feedBackItems = ' + feedBackItems);
                system.debug('feedBackItems is empty = ' + feedBackItems.isEmpty());
                system.debug('feedBackItems size = ' + feedBackItems.size());

                for(string str : feedBackItems){
                    system.debug('feedBackItem  ' + feedBackItems.indexOf(str) +' -- ' + str);
                }

                GFS.HFS_Experience__c = caseID;
                GFS.Value_of_spend_today__c = feedBackItems[0];
                GFS.Satisfaction_level__c = feedBackItems[1].right(feedBackItems[1].length() - 3);
                GFS.Likely_to_recommend__c = feedBackItems[2].right(feedBackItems[2].length() - 3);
                GFS.What_could_we_improve__c = feedBackItems[3].trim();        

        }

        Case hfsCase = [Select ClosedDate,Service_Date__c,Historic_Close_Reason__c, Village__r.Name, HFS_Click_And_Collect__c, SuppliedEmail FROM Case WHERE ID =: caseID];
        List <Case_Item__c> allCaseItems = [SELECT ID, Name, Village_Presence__r.Name, Status__c , Item_Count__c ,Start_Time__c FROM Case_Item__c WHERE Case__c = :caseID];
        
        System.debug('Case Items: ' + allCaseItems);
        
        List<HFS_Bag__c> allGuestBags = [SELECT ID, Name, Brand__c, HFS_Purchase__c,Barcode__c,Scanned__c,Scanned_for_collection__c,Status__c,
                                         HFS_Storage_Location__c,HFS_Storage_Location__r.Name,  HFS_Purchase__r.Village_Presence__r.Brand__r.Name,
                                         Delivered_to_Guest__c
                                         FROM HFS_Bag__c
                                         WHERE HFS_Purchase__r.Case__c = :caseID];
        
        System.debug('All Bags: ' + allGuestBags);    
        
        
        HandsFreeShoppingExtention.saveSignature(imageURL,caseID , 'Signout Signature');
        
        List<HFS_Bag__c> updatedBags = new List<HFS_Bag__c>();
        List<Case_Item__c> updatedCaseItem = new List<Case_Item__c>();

        for(HFS_Bag__c bag : allGuestBags){
            if(bag.Scanned_for_collection__c == true){
                bag.Delivered_to_Guest__c = true;
                bag.Status__c = 'Collected';
                bag.Scanned__c = false;
                bag.In_Storage_Point__c = false;
                bag.HFS_Storage_Location__c = null;
                bag.Scanned_for_collection__c = false;
                updatedBags.add(bag);
            }
        }
        update updatedBags;

        if(!updatedBags.isEmpty()){
            update updatedBags;
        }
        
        for(Case_Item__c items : allCaseItems){
            
            totalcheck = true;  
            
            for(HFS_Bag__c bag : allGuestBags){
                
                if(bag.HFS_Purchase__c == items.Id){
                    
                    if(bag.Delivered_to_Guest__c == true){

                    }else{
                        totalcheck = false;
                    }
                }
            }
            
            if(totalcheck == true){ 
                items.Status__c = 'Guest Collected';
                updatedCaseItem.add(items);
            }else{
                
            }           
        }

        if(!updatedCaseItem.isEmpty()){
            update updatedCaseItem;
        }
        
        if(endCase){
            hfscase.Status = 'Closed';
            hfsCase.Experience_Close__c = system.now(); 
            if(HistoricCloseReason != null && HistoricCloseReason != ''){
                hfsCase.Historic_Close_Reason__c = ClosingAgent + ' - ' + system.now() + ' - ' + HistoricCloseReason;
                hfsCase.Was_Historically_Closed__c = true;
            }
        }
        
        try{
            update hfscase;

            if(feedBackItems != NULL && !feedBackItems.isEmpty()){
                insert GFS;
            }

            if (hfscase.HFS_Click_And_Collect__c) {
                sendClickCollectCheckoutEmail(hfscase);
            }
                   
            return 'success';
        }
        catch(Exception ex){
            return 'ERROR - ' + ex.getMessage();
        }
        
    }

    private static void sendClickCollectCheckoutEmail(Case clickCollectCase) {
        
        HFS_Features__mdt villageMetadata = getVillageHFSFeatures(clickCollectCase.Village__r.Name)[0];
 
        //Prepare the email. Get the correct template, OWA and toAdresses

        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'HFS_Collect_Checkout'];

        OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address =: villageMetadata.Registration_Email_Sender__c limit 1];
        
        List<String> toaddresses = String.isNotBlank(villageMetadata.Collect_Email_Recipients__c) ? villageMetadata.Collect_Email_Recipients__c.split(',') : new List <String> ();
        if (String.isNotBlank(clickCollectCase.SuppliedEmail)) {
            toaddresses.add(clickCollectCase.SuppliedEmail);
        }

        HFS_Utils.sendEmailWithoutContact(OWA, toaddresses, template, clickCollectCase);

    }
      
    @RemoteAction
    global static String updateShoppingItem(String itemID, String statusUpdate ){
        
        Case_Item__c hfsitem = new Case_Item__c();
        hfsitem.Id = (Id)itemID;
        hfsitem.Status__c = statusUpdate;
        try{
            update hfsitem;
            return 'success';
        }
        catch(Exception ex){
            return 'ERROR - ' + ex.getMessage();
        }
        
    }

    @RemoteAction
    global static List<String> autoGenerate(Integer bagCount){

        String [] listOfBags = new List<String>();
        String genCode, auxGen;

        for(Integer i = 1; i<= (bagCount) ; i++){
            auxGen = ('00'+i).right(2);
            genCode = DateTime.now().format('yyyyMMddHHmmss');
            listOfBags.add(genCode + auxGen);
        }
        return listOfBags;
    }   
    
    @RemoteAction
    global static String updateCase30Minutes(Id caseID){
        Case onGoingCase = [SELECT ID, Guest_30_minutes__c,Guest_Arrive_at_Collection_Point__c FROM Case WHERE ID = :caseID];
        try{
            onGoingCase.Guest_30_minutes__c = true;
            onGoingCase.Guest_Arrive_at_Collection_Point__c = System.now().addminutes(30);
            update onGoingCase;
            return 'success';
        
        } catch(Exception e) {
            return 'ERROR';
        }
    }
    
    @RemoteAction
    global static String updateCaseXXMinutes(Id caseID, String collectiontime){
        DateTime myDateTime = System.now();
       // System.assertEquals(1,2, 'collectiontime' + collectiontime);
       String Hour = collectiontime.Split(':')[0];
       String Min = collectiontime.Split(':')[1].Split(' ')[0];
       String TOD = collectiontime.Split(':')[1].Split(' ')[1];
        
       Integer intHour = Integer.valueof(Hour);
       Integer intMin = Integer.valueof(Min);
        if(TOD == 'PM'){
            intHour += 12;
        }
        DateTime collectionDT = DateTime.newInstance(myDateTime.year(), myDateTime.month(),myDateTime.day(),intHour,intMin, 00);
        
        Case onGoingCase = [SELECT ID, Guest_30_minutes__c, Guest_Arrive_at_Collection_Point__c  FROM Case WHERE ID = :caseID];
        
        onGoingCase.Guest_Arrive_at_Collection_Point__c = collectionDT;
             update onGoingCase;
         return 'success';
        /*
        if(onGoingCase.Guest_30_minutes__c == false){
            onGoingCase.Guest_30_minutes__c = true;
            update onGoingCase;
            return 'success';
        } else {
            return 'ERROR';
        }*/
        }
    
    //Update the field Scanned at Collection point for the scanned Bag
    @RemoteAction
    global static boolean updateCaseScanBagCollection(String barcodeBag, Id caseID){
        
        system.debug('barcodeBag - ' + barcodeBag);
        system.debug('caseID - ' + caseID);
        
        stopLoopBags = true;
        boolean result = false;
        
        List<HFS_Bag__c> allGuestBags = [SELECT ID, Name, Brand__c, HFS_Purchase__c,Barcode__c,Scanned__c,Scanned_for_collection__c,Status__c,
                                         HFS_Storage_Location__c,HFS_Storage_Location__r.Name,  HFS_Purchase__r.Village_Presence__r.Brand__r.Name,
                                         Delivered_to_Guest__c
                                         FROM HFS_Bag__c
                                         WHERE HFS_Purchase__r.Case__c = :caseID];
        
        system.debug('allGuestBags - ' + allGuestBags);
        
        List<HFS_Bag__c> updatedBags = new List<HFS_Bag__c>();

        if(barcodeBag != null){    
            for(HFS_Bag__c bag : allGuestBags){          
                if(stopLoopBags){
                    if(bag.Barcode__c == barcodeBag){
                        bag.Scanned_for_collection__c = true;
                        bag.Status__c = 'Checked Out';
                        bag.Scanned__c = false;
                        bag.In_Storage_Point__c = false;
                        bag.HFS_Storage_Location__c = null;
                        stopLoopBags = false;
                        result = true;
                        updatedBags.add(bag);
                    }
                }
            }
            if(!updatedBags.isEmpty()){
                update updatedBags;
            }
        }
        
        return result;
    }
    
    
    //All the bags pending from delivering
    @RemoteAction
    global static void getGuestBagsPendingCollection(Id caseID) {
        
        
        List<HFS_Bag__c> allGuestBags = [SELECT ID, Name, Brand__c, HFS_Purchase__c,Barcode__c,Scanned__c,Scanned_for_collection__c,Status__c,
                                         HFS_Storage_Location__c,HFS_Storage_Location__r.Name,  HFS_Purchase__r.Village_Presence__r.Brand__r.Name,
                                         Delivered_to_Guest__c
                                         FROM HFS_Bag__c
                                         WHERE HFS_Purchase__r.Case__c = :caseID AND Delivered_to_Guest__c!= :true ];
                                         
                                         system.debug('allGuestBags : ' + allGuestBags);
        
        
        
        
        GuestBagsPendingCollection = JSON.serialize(allGuestBags);
        
        
    }
    
    //Bags scanned at collection point
    @RemoteAction
    global static void updateQRcode(Id caseID,String qRcode) {
        
        Date nowDate = system.today();
        Case qrchange = [SELECT Client_QR_Code__c FROM Case WHERE Case.Id = :caseID AND Service_Date__c = :nowDate];
        system.debug(qrchange);
		qrchange.Client_QR_Code__c = qRcode;
		qrchange.HFS_Code_Changed__c = true;
        system.debug('AQUI!');
        update qrchange;
        system.debug(qrchange);
        
    }
    
    
    
    
    
    //Bags scanned at collection point
    @RemoteAction
    global static void getGuestBagsCollection(Id caseID) {
        
        
        List<HFS_Bag__c> allGuestBags = [SELECT ID, Name, Brand__c, HFS_Purchase__c,Barcode__c,Scanned__c,Scanned_for_collection__c,Status__c,
                                         HFS_Storage_Location__c,HFS_Storage_Location__r.Name,  HFS_Purchase__r.Village_Presence__r.Brand__r.Name,
                                         Delivered_to_Guest__c
                                         FROM HFS_Bag__c
                                         WHERE HFS_Purchase__r.Case__c = :caseID AND Delivered_to_Guest__c!= :true AND Scanned_for_collection__c= :true ];
        
        
        
        totalBagForCollection = allGuestBags.size();
        
        System.debug('totalBagForCollection: ' + totalBagForCollection);
        GuestBagsCollection = JSON.serialize(allGuestBags);
        
        
    }
    
    
    @RemoteAction
    global static String goToGuestPage(String message){
        Date nowDate = system.today();
        Case guestCase = [SELECT Id FROM Case WHERE Service_Guest_Number__c = :message AND Service_Date__c = :nowDate];
        system.debug(guestCase.Id);
        return guestCase.Id;
    }
    
    @RemoteAction
    global static boolean getStorageLocationBool(String cP1, String cP2){ //Checks if collection point share the same storage point
        
        list <HFS_Relation_Collection_Storage__c> oRigin =  [Select HFS_Collection_Point__c, HFS_Collection_Point__r.Name, HFS_Storage_Point__r.Name FROM HFS_Relation_Collection_Storage__c WHERE HFS_Collection_Point__r.Name=: cP1];
        list <HFS_Relation_Collection_Storage__c> dEstination =  [Select HFS_Collection_Point__c, HFS_Collection_Point__r.Name, HFS_Storage_Point__r.Name FROM HFS_Relation_Collection_Storage__c WHERE HFS_Collection_Point__r.Name=: cP2];

        system.debug('Origem ' + oRigin+ ' Destino ' + dEstination);

        if(oRigin[0].HFS_Storage_Point__r.Name == dEstination[0].HFS_Storage_Point__r.Name ){
            return true;   
        }else{
            return false;   
        }         
    }
    
    @RemoteAction
    global static List<String> searchGuestID(String guestID, String village){        
        
        List <String> id_Guest = new List <String>();
        
        String j= guestID+'%';     
        List <Case> searchID = new List <Case>();
        Date nowDate = system.today();
        
        
        if( guestID.length() < 4){
            searchID = [SELECT Service_Guest_Number__c FROM Case WHERE village__r.Name = :village AND  Service_Guest_Number__c LIKE :j AND Service_Date__c = :nowDate ];
            
        }
        
        for (Integer i = 0; i <  searchID.size() ; i++) {
            id_Guest.add(searchID[i].Service_Guest_Number__c);
        }
        
        System.debug('VillageX: ' + id_Guest);        
        
        return id_Guest;
    }
    
    //Cancel action will undo the scanned Bag
    @RemoteAction
    global static String GuestBagsCancel(ID caseID){
        List<HFS_Bag__c> bagsToUpdate = new List<HFS_Bag__c>();
        
        
        List<HFS_Bag__c> allGuestBags = [SELECT ID, Name, Brand__c, HFS_Purchase__c,Barcode__c,Scanned__c,Scanned_for_collection__c,Status__c,
                                         HFS_Storage_Location__c,HFS_Storage_Location__r.Name,  HFS_Purchase__r.Village_Presence__r.Brand__r.Name,
                                         Delivered_to_Guest__c
                                         FROM HFS_Bag__c
                                         WHERE HFS_Purchase__r.Case__c = :caseID AND Scanned_for_collection__c= :true ];
        
        for(HFS_Bag__c bag : allGuestBags){          
            
            if(bag.Scanned_for_collection__c == true){
                bag.Scanned_for_collection__c = false;
                bagsToUpdate.add(bag);                                      
            }
            
        }
        update bagsToUpdate;
        
        try{
            //update hfscase;
            return 'success';
        }
        catch(Exception ex){
            return 'ERROR - ' + ex.getMessage();
        }        
    }

    public static List<HFS_Features__mdt> getVillageHFSFeatures(String villageName){
        return [SELECT Click_And_Collect__c, Collect_Email_Recipients__c, Registration_Email_Sender__c FROM HFS_Features__mdt WHERE MasterLabel =:villageName];
    }
    
}