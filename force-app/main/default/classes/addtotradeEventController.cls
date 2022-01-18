Public Class addtotradeEventController{

    //test
    private ApexPages.StandardController standardController;
    public id recordId {get;set;}
    Public Contact initMem {get;set;}
    Public list<Trade_Event_Attendee__c> alreadyAttendingList {get;set;}
    Public Map<id, Id> alreadyAttendingMap = new Map<id, Id>();
    Public List<Contact> ConsToAdd = new list<Contact>();
    Public List<cContact> consToSelect {get;set;}
    Public Boolean hideErrorandButton {get;set;}
    Public Boolean VIPEvent {get;set;}
   	private static id VIPEventRecordTypeID = Schema.SObjectType.Trade_Event__c.RecordTypeInfosByName.get('HNW Event').RecordTypeId;
    private static Id VIPGuestRecordTypeID = Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId;
	Public VIP_Brand_Preference__c brandSelection {get;set;}
    public Account segmentSelection {get;set;}

    public addtotradeEventController(ApexPages.StandardController standardController) {
        try{
    this.standardController = standardController;   
    consToSelect = new list<cContact>();
    initMem = new Contact();
   // brandSelection = new Village_Presence__c();
    brandSelection = new VIP_Brand_Preference__c();
    segmentSelection = new Account();
  // brandSelection = [SELECT ID, Name FROM Village_Presence__c LIMIT 1];
    hideErrorandButton = false;
    recordId = standardController.getId();
     VIPEvent = false; 
    Trade_Event__c tradeEvent = [SELECT Id, RecordTypeID FROM Trade_Event__c WHERE Id =:recordId Limit 1];
        System.Debug('VIPEventRecordTypeID ========= ' + VIPEventRecordTypeID);
        if(VIPEventRecordTypeID == tradeEvent.RecordTypeID){
        // means its a VIP event, and we need to display different search options
           System.Debug('VIPEvent ========= ' + VIPEvent);
            VIPEvent = true;
        }  
        else
        {
            System.Debug('VIPEvent ========= ' + VIPEvent);
			VIPEvent = false;
        }
    alreadyAttendingList = [SELECT Id, Contact__c FROM Trade_Event_Attendee__c WHERE Trade_Event__c =:recordId ORDER BY Name ASC ];
    system.debug('alreadyAttendingList ' +alreadyAttendingList );
        if(alreadyAttendingList.size() > 0){
            for(Trade_Event_Attendee__c TeA : alreadyAttendingList ){
                    alreadyAttendingMap.put(TeA.Contact__c,TeA.id);
            }
            system.debug('alreadyAttendingMap' +alreadyAttendingMap);
        }    
    
        }
        catch(Exception e){
            System.debug('EXCEPTION === ' + e);
        }
    }


    public pagereference AddSelectedAttendees(){

        Account selectedAcc = [Select ID, Name, RecordType.DeveloperName, IsPersonAccount FROM Account WHERE ID = :initMem.Accountid];

System.debug('---------selectedAcc' + selectedAcc);
System.debug('---------selectedAcc.RecordType.DeveloperName ' + selectedAcc.RecordType.DeveloperName);
        if(selectedAcc.RecordType.DeveloperName == 'VIP_Guest' && selectedAcc.IsPersonAccount == true){
            Contact selectedContact = [Select ID, Name, RecordType.DeveloperName, IsPersonAccount FROM Contact WHERE AccountID = :selectedAcc.Id];
             id EAviprecordtypeid = [SELECT id from recordtype WHERE Name = 'HNW Event Attendee' AND Sobjecttype = 'Trade_Event_Attendee__c'].id;
        
            // means we have selected a VIP, and we dont need to continue, we can just add them to the attendee list
                Trade_Event_Attendee__c EA = new Trade_Event_Attendee__c();
                EA.recordtypeid = EAviprecordtypeid;
                EA.Contact__c = selectedContact.id;
                EA.Invite_Status__c = 'Added';
                EA.Trade_Event__c = recordId ;
                insert EA;

                PageReference pageRef = new PageReference('/'+recordId);
                return pageRef;
        }

       

        recordtype rt = [Select id,name from RecordType Where Name = 'Brand Contact' AND Sobjecttype = 'Contact'];

        consToAdd = [SELECT ID, FirstName,LastName,Title,RecordType.Name FROM Contact WHERE Accountid=:initMem.Accountid AND id NOT IN :alreadyAttendingMap.keyset() AND recordtypeid =:rt.id];
        IF(consToAdd.isEmpty()){
            hideErrorandButton = true;
        }
        for(contact cta : consToAdd ){
            consToSelect.add(new cContact(cta));
        }
        PageReference pageRef = Page.SelectContactstoAddTradeEvent;
        return pageRef;
    }

    
    public pagereference AddSelectedAttendeesVIP(){

       // 3 options here....
       // either searching on brand pref only
       // or searching on segment only
       // or searching on both
        List<VIP_Brand_Preference__c> VIPBPs = new List<VIP_Brand_Preference__c>();
        boolean brand = false;
        boolean segment = false;
        List<Contact> consfound = new List<Contact>();
        System.Debug('brand and segment: ==== ' + brandSelection + segmentSelection);
        if(brandSelection.Village_Presence__c != null){
			VIPBPs = [Select ID, Name, VIP_Guest__c FROM VIP_Brand_Preference__c WHERE Village_Presence__c = :brandSelection.Village_Presence__c];
            brand = true;
        }
        if(segmentSelection.Guest_Segment__c != null){
            segment = true;
        }
        List<Id> vipIds = new List<ID>();
        if(brand == true){                          
        	System.debug('---------alreadyAttendingMap' + alreadyAttendingMap);
        	for(VIP_Brand_Preference__c v :VIPBPs){
            	vipIds.add(v.VIP_Guest__c);
        	}        
        }
        
        if(segment == false && brand == true){                    
			        
        	System.debug('---------vipIds' + vipIds);
        	consfound = [SELECT ID, FirstName,LastName,Title,RecordType.Name FROM Contact WHERE IsPersonAccount = true AND Account.RecordTypeID = :VIPGuestRecordTypeID AND (ID IN :vipIds OR AccountId IN :vipIds) AND (id NOT IN :alreadyAttendingMap.keyset() OR AccountId NOT IN :alreadyAttendingMap.keyset()) ];
        }
        if(segment == true && brand == false){            
        consfound = [SELECT ID, FirstName,LastName,Title,RecordType.Name FROM Contact WHERE IsPersonAccount = true AND Account.RecordTypeID = :VIPGuestRecordTypeID AND Account.Guest_Segment__c = :segmentSelection.Guest_Segment__c AND AccountId NOT IN :alreadyAttendingMap.keyset() ];
        }
        if(segment == true && brand == true){
            consfound = [SELECT ID, FirstName,LastName,Title,RecordType.Name FROM Contact WHERE IsPersonAccount = true AND Account.RecordTypeID = :VIPGuestRecordTypeID AND (((ID IN :vipIds OR AccountId IN :vipIds) AND (id NOT IN :alreadyAttendingMap.keyset() OR AccountId NOT IN :alreadyAttendingMap.keyset())) OR (Account.Guest_Segment__c = :segmentSelection.Guest_Segment__c AND AccountId NOT IN :alreadyAttendingMap.keyset()))];
        }
                
        System.debug('---------consToAdd' + consToAdd);
        for(Contact c :consfound){
            if(!alreadyAttendingMap.containsKey(c.Id)){
                consToAdd.add(c);
            }
        }
        
        IF(consToAdd.isEmpty()){
            hideErrorandButton = true;
        }
        for(contact cta : consToAdd ){
            consToSelect.add(new cContact(cta));
        }
        PageReference pageRef = Page.SelectContactstoAddTradeEvent;
        return pageRef;
    }
    public PageReference processSelected() {
        list<Trade_Event_Attendee__c> TEA = new List<Trade_Event_Attendee__c>();
         List<Contact> selectedContacts = new List<Contact>();
        
        if(VIPEvent){
            id EAviprecordtypeid = [SELECT id from recordtype WHERE Name = 'HNW Event Attendee' AND Sobjecttype = 'Trade_Event_Attendee__c'].id;
  			for(cContact cCon: consToSelect) {
            if(cCon.selected == true) {

                Trade_Event_Attendee__c EA = new Trade_Event_Attendee__c();
                EA.recordtypeid = EAviprecordtypeid;
                EA.Contact__c = cCon.Con.id;
                EA.Invite_Status__c = 'Added';
                EA.Trade_Event__c = recordId ;
                TEA.add(EA);
            }

        }            
        }
        else
        {
       
        id EArecordtypeid = [SELECT id from recordtype WHERE Name = 'Leasing Contact' AND Sobjecttype = 'Trade_Event_Attendee__c'].id;
        
        for(cContact cCon: consToSelect) {
            if(cCon.selected == true) {

                Trade_Event_Attendee__c EA = new Trade_Event_Attendee__c();
                EA.recordtypeid = EArecordtypeid;
                EA.Contact__c = cCon.Con.id;
                EA.Invite_Status__c = 'Invited';
                EA.Trade_Event__c = recordId ;
                TEA.add(EA);
            }

        }
        }
        insert TEA;
        PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }


    Public Pagereference finished() {
    PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }



    
    Public Pagereference Cancel() {
    PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }

    public class cContact{
        public contact con {get; set;}
        public Boolean selected {get; set;}

        public cContact(contact thecon) {
            con = thecon;
            selected = false;

        }

        public cContact(contact thecon, boolean bool) {
            con = thecon;
            selected = bool;

        }
    }
    

    


}