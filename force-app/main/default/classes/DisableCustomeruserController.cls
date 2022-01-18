public class DisableCustomeruserController {

    @AuraEnabled
    public static string updateCustomerUser(string contactId, boolean activeFlg){
        
        string returnValue = '';
        User usr = null;
        
        try {
        	usr = [select Id, IsActive from User where ContactId = :contactId];
            usr.IsActive = activeFlg;
            update usr;
            if (!activeFlg) {
            	returnValue = System.Label.DAILY_SALE_USER_DISABLED; // Contact User has been successfully disabled
            } else {
                returnValue = System.Label.DAILY_SALE_USER_ENABLED; // Contact User has been successfully enabled
            }    
        } catch (exception e){
            usr = null;
            returnValue = System.Label.DAILY_SALE_INVALID_USER; // Contact is not a valid user
        }    
        
        return returnValue;        
        
    } 

    @AuraEnabled
    public static string getCustomerStatus(string contactId){
        
        string returnValue = '';
        User usr = null;
        
        try {
        	usr = [select Id, IsActive from User where ContactId = :contactId];
            if (usr.IsActive){
                returnValue = 'Active';
            } else {
                returnValue = 'InActive';
            }
        } catch (exception e){
            usr = null;
        }    
        if (usr == null){
            returnValue = 'Null';
        }
        
        return returnValue;        
        
    } 
    
}