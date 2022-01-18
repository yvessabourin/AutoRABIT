public class BP_Home_Landing_Controller {

    
    @AuraEnabled
    public static Boolean getDailySalesPermission(){ //Get PDaile Active Dates

        Id userId = UserInfo.getUserId();
        User theUser = [SELECT Id, ContactId, ProfileId FROM User WHERE ID = : userId];
        Profile profileName = [SELECT Name FROM Profile WHERE Id = :theUser.ProfileId];
        List <Village_Presence_Contact_Role__c> vprList = [SELECT Id, Certification_Active__c,Daily_Sales_Active_From__c,Daily_Sales_Active_To__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: theUser.ContactId];                
        
        for(Village_Presence_Contact_Role__c vpr : vprList){
            if(vpr.Certification_Active__c == true && profileName.Name == 'Brand Community Plus User'){
                return false;
            } else if(vpr.Certification_Active__c == true && profileName.Name != 'Brand Community Plus User'){
                return true;
            }
        }
        Date myDate = Date.today();
        for(Village_Presence_Contact_Role__c vpr : vprList){
            if(vpr.Certification_Active__c != true){
                if( myDate >= vpr.Daily_Sales_Active_From__c ){            
                    if( vpr.Daily_Sales_Active_To__c == null ||  myDate <= vpr.Daily_Sales_Active_To__c ){
                        return true;
                    }            
                }
            }
        }
		return false;  
    }
    
    @AuraEnabled
    public static Boolean getHFSPermission(){ //Get HFS Active
        
        Id contact = getContact();  
        Village_Presence_Contact_Role__c vpr = [SELECT Contact__c, Id, Village_Presence__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: contact LIMIT 1];  
        Village_Presence__c villa = [SELECT BP_HFS_Active__c, Id FROM Village_Presence__c WHERE Id =: vpr.Village_Presence__c LIMIT 1];  
		return villa.BP_HFS_Active__c; 
    }
    
    @AuraEnabled
    public static Boolean getCertPermission(){ //Get Certification Active
        
        Id contact = getContact(); 
        List <Village_Presence_Contact_Role__c> vpr = [SELECT Contact__c, Id, Certification_Active__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: contact AND Certification_Active__c= true];                
               
        if(!vpr.isEmpty()){  
        	return true;                   
        }  
        
		return false;  
    }
    
    private static Id getContact(){ //Get Village

        string userId = UserInfo.getUserId();
        
        User user = [SELECT Id, contactId FROM USER 
                             WHERE Id = :userId
                             LIMIT 1]; 
                
		return user.ContactId;             
		
    }
    
    
}