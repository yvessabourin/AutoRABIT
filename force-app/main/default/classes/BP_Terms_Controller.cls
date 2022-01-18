public class BP_Terms_Controller {    
    
    @AuraEnabled
    public static String getTerms(){ //Get Terms
        
    	String userLanguage = '';
        String terms = 'Terms not Found';
  		BP_Brand_Term__c terms_Obj; 
        
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
        userLanguage = u.LanguageLocaleKey;
        
        System.debug('Language ' + userLanguage);
        terms_Obj = [SELECT Brand_Terms__c FROM BP_Brand_Term__c WHERE BP_terms_Language__c =: userLanguage];
        terms = (terms_Obj.Brand_terms__c);        
		System.debug(terms);

               
		return terms;
    }
    
    @AuraEnabled
    public static String getTermsUser(){ //Get Submiter
        
        String tUser = null;
        String tUserDate = '';

        Village_Presence_Contact_Role__c vp = getVillagePrContact();      
             
        if(vp.BP_HFS_Brand_TeC_Conf_Date__c != null){ 
            
            Contact contact = [	SELECT id, Name FROM CONTACT 
                          		WHERE id =: vp.Contact__c                       
                           		LIMIT 1];      
            
            tUserDate = string.valueofGmt(vp.BP_HFS_Brand_TeC_Conf_Date__c);
			tUser = ' ' + System.Label.DAILY_SALE_TERMS_APPROVED_BY + ' ' +  contact.Name + '  ' + tUserDate;
        }      
                  
		return tUser;
    }
    
    @AuraEnabled
    public static void getSubmit(){ //Submit approver        
      
        Village_Presence_Contact_Role__c vpx = getVillagePrContact(); 
        vpx.BP_HFS_Brand_TeC_Conf_Date__c = system.NOW();
        update vpx;         
		
    }
    
    private static Village_Presence_Contact_Role__c getVillagePrContact(){ //Get Village Presence Contact
        
        string userId = UserInfo.getUserId();
        
        User user = [SELECT Email, Name, id FROM USER 
                             WHERE id = :userId
                             LIMIT 1]; 
        
        string email = user.Email;
        
        Contact contact = [SELECT id FROM CONTACT 
                           WHERE Email =: email                       
                           LIMIT 1];            
        
        Village_Presence_Contact_Role__c vpr = [SELECT Contact__c, id, BP_HFS_Brand_TeC_Conf_Date__c FROM Village_Presence_Contact_Role__c WHERE Contact__c =: contact.Id LIMIT 1];                       
         
               
		return vpr;              
		
    }
    
    
}