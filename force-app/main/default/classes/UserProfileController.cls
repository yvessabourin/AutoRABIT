public with sharing class UserProfileController {
	
    @AuraEnabled
    public static User getCurrentUser() {
      	User u = [SELECT Id, FirstName, LastName, ContactId, Last_Portal_Login__c, Last_Portal_Login_Device__c
      				 FROM User 
      				 WHERE Id = :UserInfo.getUserId() LIMIT 1];
      	return u;
    }
    
}