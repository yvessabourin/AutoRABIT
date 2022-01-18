@isTest
public with sharing class TestData_Contact {

	/**
	 * Setup Contact
	 */
    public static Contact setupContact(string identifier, Account acc, Boolean insertToDatabase) {
        
        string testAccountId = '';
        if(acc != null){
        	testAccountId = acc.Id;        	
        }
        
        Contact testContact = new Contact(LastName = 'Test' + identifier,
                                          FirstName = 'John',
                                          Salutation = 'Mr',
                                          Email = 'test' + identifier + '@vr1.com',
                                          LeadSource = 'Village Registration Card');
		
		if (!string.isBlank(testAccountId)){
			testContact.AccountId = testAccountId;
		}
		                                          
	    if (insertToDatabase) {
			insert testContact;
	    }
        return testContact;
    }


	/**
	 * Setup Brand Contact
	 */
    public static Contact setupBrandContact(string identifier, Account acc, Boolean insertToDatabase) {
        
        id brandRecordTypeID = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Brand Contact').RecordTypeId;
        
        string testAccountId = '';
        if(acc != null){
        	testAccountId = acc.Id;        	
        }
        
        
        Contact testContact = new Contact(LastName = 'Test' + identifier,
                                          FirstName = 'John',
                                          Salutation = 'Mr',
                                          Email = 'test' + identifier + '@vr1.com',
                                          LeadSource = 'Village Registration Card',
                                          RecordTypeId = brandRecordTypeID);
		
		if (!string.isBlank(testAccountId)){
			testContact.AccountId = testAccountId;
		}
		                                          
	    if (insertToDatabase) {
			insert testContact;
	    }
        return testContact;
    }

	/**
	 * Setup Brand Contact
	 */
    public static Contact setupTourismContact(string identifier, Account acc, Boolean insertToDatabase) {
        
        id tourismRecordTypeID = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Tourism Contact').RecordTypeId;
        
        string testAccountId = '';
        if(acc != null){
        	testAccountId = acc.Id;        	
        }
        
        
        Contact testContact = new Contact(LastName = 'Test' + identifier,
                                          FirstName = 'John',
                                          Salutation = 'Mr',
                                          Email = 'test' + identifier + '@valueretail.com',
                                          LeadSource = 'Village Registration Card',
                                          RecordTypeId = tourismRecordTypeID);
		
		if (!string.isBlank(testAccountId)){
			testContact.AccountId = testAccountId;
		}
		                                          
	    if (insertToDatabase) {
			insert testContact;
	    }
        return testContact;
    }

}