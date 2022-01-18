@RestResource(urlMapping='/v.1.0/tradeevents/*') 


/* Examples

Test using  .. https://workbench.developerforce.com/restExplorer.php
			   or .. https://apigee.com/console/salesforce

GET
 .. /services/apexrest/v.1.0/tradeevents       //just return a list of all Trade Events
 .. /services/apexrest/v.1.0/tradeevents/today // Return a list of Trade Events happening today
 .. /services/apexrest/v.1.0/tradeevents/accounts //Return a list of all Tourism Accounts


POST

 ../services/apexrest/v.1.0/tradeevents/attendee
 
 sample request body
 ..
  {
  	"tradeeventid": "a0Ag00000063S9vEAE" ,
  	"accountname":"A New Account", 
  	"email":"test@test.com",
  	"firstname": "John",
  	"lastname": "Smith",
  	"title": "Director",
  	"mobile": "0777888999",
  	"phone": "0200123222",
  	"notes": "Could be a good contact"
  }


*/


global with sharing class TradeEventRestSvc {


	@HttpGet
  	global static List<Sobject> doGet() {

      	RestRequest req = RestContext.request;
     	RestResponse res = RestContext.response; 
     	boolean bValid = false;
     	list<Sobject> returnList = new list<Sobject>();   
    	
    	string reqType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
   		
   		if (reqType == 'tradeevents'){
   			bValid = true;
   			returnList = getTradeEvents('');
   		}
   		
   		if (reqType == 'today'){
   			bValid = true;
   			returnList = getTradeEvents('today');
   			
   		}
   		
   		if (reqType == 'accounts'){
   			bValid = true;
   			returnList = getAccounts();
   		}
   		
		if (!bValid){
			res.addHeader('ERROR', 'Invalid Operation');
		}
		
		return returnList;

  	}
	

  	@HttpPost
  	global static Sobject doPost() {

      	try {
	      	RestRequest req = RestContext.request;
	      	RestResponse res = RestContext.response; 
	            
	      	// see if a username was part of the uri
	      	string name = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
	   
	      	if (name == 'attendee') {
	        	return createAttendee(req, res);
	        	
	      	} else {  
	        	res.addHeader('ERROR', 'Invalid Operation');
	        	return null;
	      	}
      	} catch (exception e){
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
			return null;
		}
      
  	}
	
	private static list<Sobject> getTradeEvents(string filter){
		
		list<Sobject> returnList = null;
		
		string soql = 'select Id, Name, Description__c, Event_Date__c, Location__c from Trade_Event__c ';
		if (filter == 'today'){
			soql += ' where Event_Date__c = TODAY ';						
		}
		soql += ' order by Event_Date__c ';
		returnList = Database.query(soql);
		
		return returnList;
		
		
	}

	private static list<Sobject> getAccounts(){
		
		list<Sobject> returnList = null;
		Id recTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId;
		
		string soql = 'select Id, Name from Account where RecordTypeId =: recTypeId order by name';
		
		returnList = Database.query(soql);
		
		return returnList;
		
		
	}
	
	private static Sobject createAttendee(RestRequest req, RestResponse res){
		
		boolean newAccount = false;
		Account account = null;
		
		Sobject returnObj = null;
		JSONToken token = null;
		
		
		string tradeEventId = '';
		string accountName = '';
		string email = '';
		string firstName = '';
		string lastName = '';
		string title = '';
		string mobile = '';
		string phone = '';
		
 // Parse JSON request body to extract all values.
 		blob body = req.requestBody;
    	string bodyString = body.toString();

system.debug (' @@@@@@@@@  ' + bodyString);        
		
		attendeePerson attendee = (attendeePerson)JSON.deserialize(
                bodyString ,attendeePerson.class );
		
		if (string.isnotBlank(attendee.accountname)){
			try{
				string accountId = findAccount(attendee.accountname);
				if (string.isBlank(accountId)){
					// create account
					account = new Account(Name=attendee.accountname);
					insert account;
					accountid = account.Id;
					newAccount = true;
				}
				
				string contactId = findContact(email);	
				if (string.isBlank(contactId)){
					Id recTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Tourism Contact').RecordTypeId;
					Contact c = new contact(AccountId = accountId,
											FirstName = attendee.firstname,
											LastName = attendee.lastname,
											Title = attendee.title,
											Email = attendee.email,
											Phone = attendee.phone,
											MobilePhone = attendee.mobile,
											RecordTypeId = recTypeId);
					try {
						insert c;
						contactId = c.Id;						
					} catch(Exception e){
						system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
						if (newAccount){
							delete account;
						}
					}
													
						
				}
				Trade_Event_Attendee__c eventAttendee = new Trade_Event_Attendee__c(Trade_Event__c = attendee.tradeeventid,
																					Contact__c = contactId
																					,Attendee_Notes__c = attendee.notes
																					);
				insert eventAttendee;
				
			} catch (exception e){
				returnObj = null;
				res.addHeader('Error', e.getMessage());
				system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
			}
			
		}
		
		return returnObj;
		
	}


	private static string findAccount(string accountName){
		
		string returnId = '';
		Id recTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId;
		try{
			Account a = [select Id from Account where Name =:accountName and RecordTypeId =:recTypeId];
			returnId = a.id;
			
		} catch (exception e){
			returnId = '';
		}
			
		return returnId;
	}
	
	private static string findContact (string email){
		
		string returnId = '';
		
		if (string.isnotBlank(email)){
			try{
				Contact c = [select Id,Name from Contact where email = :email];
				returnId = c.Id;
			
			} catch (exception e){
				system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
				returnId = '';
			}
		}
		
		return returnId;
		
	}
	
	private class AttendeePerson{
		
		public string tradeeventid {get; set;}
		public string accountname {get; set;}
		public string email {get; set;}
		public string firstname {get; set;}
		public string lastname{get; set;}
		public string title{get; set;}
		public string mobile {get; set;}
		public string phone {get; set;}
		public string notes {get; set;}
		
		
	}
	
}