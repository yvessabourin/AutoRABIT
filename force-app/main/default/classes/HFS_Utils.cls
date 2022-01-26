/*
	Author: Oscar Gomez (everis)
	Generic Utils Class for the HFS application.
*/

public without sharing class HFS_Utils {

	public static final String GUEST_RT = 'Guest';
	public static final String VIP_GUEST_RT = 'VIP_Guest';

	public static HFSSpentLevelCalculator getCurrencyLevelCalculator(String villageCode) {
		HFSSpentLevelCalculator currencyLevelCalculator;
		if (villageCode == 'BV') {
			currencyLevelCalculator = new HFSSpentLevelCalculatorBV ();
		} else {
			currencyLevelCalculator = new HFSSpentLevelCalculatorGeneric(villageCode);
		}
		return currencyLevelCalculator;
	}

	public static Map <String, List <Account>> searchGuests (String param) {
		
		Map <String, List <Account>> guestsMap = new Map <String, List<Account>> {'Guests' => new List <Account> (), 'VIP_Guests' => new List <Account> ()};
		Id guestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get(GUEST_RT).RecordTypeId;
		Id vipGuestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get(VIP_GUEST_RT).RecordTypeId;
		
		List<List<SObject>> searchList = [FIND :param IN ALL FIELDS 
											RETURNING 
												Account (Id, Name, FirstName, LastName, Customer_GUID__c,Salutation,
															PersonEmail, PersonMailingPostalCode, Country_of_Residence__c,
															PersonMobilePhone, RecordTypeId, BarcodeNumber__c, RecordType.Name
															WHERE recordtypeid IN (:guestRtId, :vipGuestRtId)
															order by PersonEmail ASC
															limit 50
												)];
		for (Account guest : (Account[])searchList[0]) {
			if (guest.RecordTypeId == vipGuestRtId) {
				guestsMap.get('VIP_Guests').add(guest);
			} else {
				guestsMap.get('Guests').add(guest);
			}
		}

		return guestsMap;
	}

	public static Account searchPrivilegeGuest (String email, String firstName, String lastName) {

		Id guestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get(GUEST_RT).RecordTypeId;
		List <Account> privilegeGuest = [SELECT BarcodeNumber__c FROM Account WHERE PersonEmail =: email AND FirstName =: firstName AND LastName =: lastName AND RecordTypeId =: guestRtId];
		if (!privilegeGuest.isEmpty()) {
			return privilegeGuest[0];
		} else {
			return null;
		}
	}

    public static void sendEmailWithoutContact (OrgWideEmailAddress OWA, List<String> toaddresses, EmailTemplate template, Case targetCase) {
        
        //Select a random contact
        Contact c = [select id, Email from Contact where email <> null AND email LIKE '%@valueretail.com%' limit 1];

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();

        try{
            msg.setTemplateID(template.Id); 
            msg.setTargetObjectId(c.id);
            msg.setWhatId(targetCase.id);
            msg.setToAddresses(toaddresses);
            
            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new List <Messaging.SingleEmailMessage> {msg});
            Database.rollback(sp); // Email will not send as it is rolled Back
                     
            // Send Actual email
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(toaddresses);
            emailToSend.setPlainTextBody(msg.getPlainTextBody());
            emailToSend.setHTMLBody(msg.getHTMLBody());
            emailToSend.setSubject(msg.getSubject());
            emailToSend.setOrgWideEmailAddressId(OWA.id);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailToSend});
            
        } 
        catch (Exception e){
            //message = 'A general exception occured, please contact you administrator\nMessage detail: ' +e.getmessage();  
        }        

    }
	public static List<Account> searchVIPGuestByEmail (String email) {
		
		Id vipGuestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get(VIP_GUEST_RT).RecordTypeId;
		List <Account> vipGuests = [SELECT Id FROM Account WHERE RecordTypeId =: vipGuestRtId AND PersonEmail =: email];
		return vipGuests;
	}
}