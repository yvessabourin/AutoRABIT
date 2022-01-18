global without sharing class RetailLivePost {
    
    private static Village_Presence__c villagePresence = null;
    public static sf1Data sf1DataValues {get; set;}
    
    // Constructor method to retrieve Village presence record in focus
    // and set default values for initial display
    public RetailLivePost (ApexPages.StandardController controller) {
    
        villagePresence = (Village_Presence__c)controller.getRecord();
        populatef1Data();
    
    }
    
    // Create data structure and populate with default values to initially
    // display in UI
    private void populatef1Data(){
        
        sf1DataValues = new sf1Data();
    
    
        sf1DataValues.toListString = getRecipients();
        sf1DataValues.ccListString  = getVillageExecs();        
        sf1DataValues.villagePresenceId = villagePresence.Id;
                
        
    }
   
  
  // Retrieves email addresses of contacts with a 'Retail LIVE Recipient' role for
	  // the Village Presence record in focus
	  private string getRecipients(){
	    
	    string returnList = '';
	    string emailListString = '';
	    
	    set<string> emailList = new set<string>();
	    list<Village_Presence_Contact_Role__c> contactList = new list<Village_Presence_Contact_Role__c>();
	    
	    // Perform query to retrieve email addresses fro the contacts who have a 'Retail LIVE Recipient' role
	    contactList = [select Contact__r.Email from Village_Presence_Contact_Role__c
	            where Village_Presence__r.Id = :villagePresence.Id 
	            and Receive_Retail_LIVE__c = true];
	                               
	    if (!contactList.isEmpty()){
	      for (Village_Presence_Contact_Role__c c :contactList){
	        if (string.isnotBlank(c.Contact__r.Email)){
	          emailList.add(c.Contact__r.Email);
	          returnList += c.Contact__r.Email + ',';
	          emailListString += c.Contact__r.Email + ';';
	        }
	      }
	    }
	    
	
	    if (string.isnotBlank(returnList)){
	      returnList = returnList.substring(0, returnList.length() - 1);
	      sf1DataValues.toListEmail = emailListString;
	    }
	                           
	    return returnList;
	  }

  	// Retrieves email addresses of VR Execs defined at Village level to receive 
  	// Retail LIVE communications
	private string getVillageExecs(){
    
		string returnList = '';
	    string emailListString = '';
	    
	    set<string> emailList = new set<string>();
	    
	    Village__c village = [select Retail_Live_Execs__c from Village__c where Id =: villagePresence.Village__c];
	    
	    if (string.isnotBlank(village.Retail_Live_Execs__c)){
	    	returnList = village.Retail_Live_Execs__c;
	    	emailListString = returnList.replace(',',';');
	    	sf1DataValues.ccListEmail = emailListString;
	    }                           
	    return returnList;
	}

        
    public List<SelectOption> AccountContacts {
        get {
            if (AccountContacts == null) {
                AccountContacts = new List<SelectOption>();
                // create map of uniques email addresses mapped to contact name
                map<string, string> emailMap = new map<string, string>();
                
                // first extract any contacts with associated village presence role and an email address
                list<Village_Presence_Contact_Role__c> roleList = new list<Village_Presence_Contact_Role__c>();
    			roleList = [select Contact__r.Email, Contact__r.Id, Contact__r.Name from Village_Presence_Contact_Role__c
            		where Village_Presence__r.Id = :villagePresence.Id and Contact__r.Email != null 
            		order by Contact__r.Name asc];

                for (Village_Presence_Contact_Role__c c : roleList) {
                    emailMap.put(c.Contact__r.Email, c.Contact__r.Name);
                }
                            
		        // now extract all contacts associated with brand who have an email address
		        list<Contact> contactList = new list<Contact>();
		        contactList = [select name, email from Contact where AccountId = :villagePresence.Brand__c and email != null];
		        
		        for(Contact c :contactList){
		          emailMap.put(c.Email, c.Name);
		        }
        
        // Now add combined collection to options list to return to UI
                for (string s : emailMap.keySet()) {
                    AccountContacts.add(new SelectOption(s, emailMap.get(s)));
                }
            }
            return AccountContacts;
        }
        private set;
    }
 

    // Method called by Submit button to post new Retail LIVE message
    @RemoteAction
    global static string postRetailLive(sf1Data data) {
        
        
        string returnValue = 'Success';
        
        try {
    
	      // Ensure subject entered is unique for this Village Presence, otherwise return validation
	      // error message to user
	      boolean valid = validateSubject(data);
	      if (!valid){
	        returnValue = 'Duplicate Subject';  
	      }
	      else {
	        // Retrieve Retail LIVE Email service email setting which will receive the Retail LIVE post
	        VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
	        string retailLiveEmail = orgSettings.Retail_Live_Email__c;
	        string subjectPrefix = orgSettings.Retail_Live_Subject_Prefix__c;
	        
	        if(test.isRunningTest()){
	          retailLiveEmail = 'testing@test.com';
	        }
	              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	  
	              String emailAddr = UserInfo.getUserEmail();
	
	        // Add any attachments included by user. The attachment is stored in the 
	        // user's personal folder before being sent in the SingleEmailMessage class via the 
	        // document id reference.
	        if(data.attachmentIdList != null){
	          if(!data.attachmentIdList.isEmpty()){
	//            mail.DocumentAttachments = data.attachmentIdList;
	
	            system.debug (' @@@@@ data.attachmentIdList   ' + data.attachmentIdList);
	            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
	            for (Document a : [select Name, Body, BodyLength from Document  where id in :data.attachmentIdList])
	            {
	              Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
	                efa.setFileName(a.Name);
	                efa.setBody(a.Body);
	                fileAttachments.add(efa);
	            }
	            mail.setFileAttachments(fileAttachments);
	            system.debug(' @@@@ fileAttachments.size()   ' + fileAttachments.size());
	
	          }
	          
	        }
	        
	
	
	
	      
	        if(data.publicReplies){
	          data.toList.add(retailLiveEmail);
	        } else {
	          data.bccList.add(retailLiveEmail);
	        }
	        
	              if (!data.toList.isEmpty())
	                  mail.setToAddresses(data.toList);
	                   
	              if (!data.ccList.isEmpty())
	                  mail.setccAddresses(data.ccList);
	              
	              if (!data.bccList.isEmpty())
	                  mail.setbccAddresses(data.bccList);
	         
	              mail.setSubject(subjectPrefix + ' ' + data.subjectText);
	              
	        string msg = '<font color=white>' + '#' + data.villageCode + ' ' +  '#' + data.brandName + '\n'+ '----------------------------------------';
	        string guid = guidGenerator.NewGuid();
	        //msg += '^'+guid + '</font>';
	        msg += '</font>';
	        msg += '<input type=hidden value = ~'+guid + '~</input>';
	        
	        mail.setHtmlBody(msg);
	        
	              //mail.setPlainTextBody('#' + data.villageCode + ' ' +  '#' + data.brandName + '\n'+ '----------------------------------------');
	              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	              
	              //call function to update VP Roles with latest distribution To list
	              updateVPRoles(data.villagePresenceId, data.toList);
	      }

        } catch (exception e) {
            returnValue = 'A technical error has occurred .. ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
            return returnValue;
            
        }
        return returnValue; 
    }


    @RemoteAction
    global static String uploadAttachment(String attachmentBody, String attachmentName, String docId) {

        if(attachmentBody != null) {
            
            Document doc = new Document();
            if (string.isNotBlank(docId)){
              doc = getDocument(docId);
            }
            
            string newBody = '';
            if(doc.Body != null) {
                newBody = EncodingUtil.base64Encode(doc.Body);
            }
            newBody += attachmentBody;
            doc.Body = EncodingUtil.base64Decode(newBody);
            if(docId == null) {
                doc.Name = attachmentName;
                doc.FolderId = UserInfo.getUserId();
            }
            upsert doc;
            return doc.Id;
        } else {
            return 'Body was null';
        }

    }

  private static Document getDocument(String docId) {
        list<Document> documents = [SELECT Id, Body
                                        FROM Document 
                                        WHERE Id =: docId];
        if(documents.isEmpty()) {
            Document doc = new Document();
            return doc;
        } else {
            return documents[0];
        }
    }
    
    public static boolean validateSubject(sf1Data data){


    VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
    string subjectPrefix = orgSettings.Retail_Live_Subject_Prefix__c;
             
      boolean returnValue = true;
      string subject = subjectPrefix + ' ' + data.subjectText;
      list<Retail_Live_Email__c> retailLiveList = new list<Retail_Live_Email__c>();
system.debug(' @@@@ data.subjectText  ' + data.subjectText);      
      retailLiveList = [select Id from Retail_Live_Email__c 
                where(CreatedDate = LAST_N_DAYS:14
                and Subject_Unique__c = :subject)];
                            
      if (!retailLiveList.isEmpty()){
        returnValue = false;
      }
      
      return returnValue;
      
    }
 
    
    //Data structure wrapper class to transport data back and forward between controller and UI
    global class sf1Data {

        global list<string> toList { get; set; }
        global list<string> ccList { get; set; }
        global list<string> bccList { get; set; }
        global string toListString { get; set; }
        global string ccListString { get; set; }
        global string bccListString { get; set; }
        global string villageCode { get; set;}
        global string brandName { get; set;}
        global string villagePresenceId {get; set;}
    	global string toListEmail{get; set;} //only required when running from desktop, to format list with semi-colon separator
    	global string ccListEmail{get; set;} //only required when running from desktop, to format list with semi-colon separator
    
        global boolean publicReplies { get; set; }
        global string subjectText { get; set; }
        
    	global list<string> attachmentNameList {get; set;}
    	global list<string> attachmentIdList {get; set;}
           
        public sf1Data(){
           toList = new list<string>();
           ccList = new list<string>();
           bccList = new list<string>();
           attachmentNameList = new list<string>();
           attachmentIdList = new list<string>();
           ccListString = '';
           bccListString = '';
           publicReplies = true; 

        
        }
                

    }
    
    
    // This function takes the VP record id and the 'To'  distribution list configured by the user
    // to adjust the VP roles accordingly and ensure that any subsequent Retail LIVE messages 
    // for the same Village presence default the 'To' contact list to the values last used.
    //@future
    public static void updateVPRoles(string vpId, list<string> emailList){
      
      list<Village_Presence_Contact_Role__c> vpRoleList = [select Receive_Retail_LIVE__c, Village_Presence__r.Brand__c, 
                                  contact__r.Id, contact__r.email, Village_Presence__c                             
                                  from Village_Presence_Contact_Role__c where Village_Presence__c =:vpId];
      // this variable will hold a map of the emails contained in the vp roles
      // and is populated by a loop below
      map<string, string> vpEmailMap = new map<string, string>();
      
      // put incoming email list into a map for easier processing
      map<string, string> emailMap = new map<string, string>();
      for (string email :emailList){
        emailMap.put(email, email);
      }
      

      // Loop through existing roles and update Receive_Retail_LIVE__c flag to reflect whether email is 
      // in the incoming list or not.
      for(Village_Presence_Contact_Role__c vpRole  :vpRoleList){
        string email = vpRole.contact__r.email;
        // populate vpEmailMap for later processing..
        vpEmailMap.put(email, email);
        
        
        if (emailMap.containsKey(email)){
          vpRole.Receive_Retail_LIVE__c = true;
        } else {
          vpRole.Receive_Retail_LIVE__c = false;
        }
        
      }  
system.debug('@@@ UPDATED VP Contact Roles .. ' + vpRoleList);      
      // update existing roles to synchronise with email list provided
      update vpRoleList;
        
      // determine if any new contact emails have been added which don't have a vp role at all.
        // first,retrieve contact records which have the same email as the incoming list
	  id brandContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Brand Contact').RecordTypeId;
      list<Contact> contactList = [select id, email from Contact where email in :emailList and RecordTypeId = :brandContactRecordTypeId];
      vpRoleList = new list<Village_Presence_Contact_Role__c>();
      
      for (Contact c :contactList){
        // If email does not reflect an existing VP role email, create a new VP Contact role
        if (!vpEmailMap.containsKey(c.Email)){
          Village_Presence_Contact_Role__c vpRole = new Village_Presence_Contact_Role__c();
          vpRole.Contact__c = c.Id;
          vpRole.Receive_Retail_LIVE__c = true;
          vpRole.Village_Presence__c = vpId;
          vpRole.Retail_Role__c = 'Retail';
          vpRoleList.add(vpRole);
        }
        
      }
system.debug('@@@ NEW VP Contact Roles .. ' + vpRoleList);      
      //insert new VP role for any email addresses not reflected by existing roles
      if(!vpRoleList.isEmpty()){
        insert vpRoleList;
      }
    }
}