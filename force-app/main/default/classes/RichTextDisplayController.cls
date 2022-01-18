public class RichTextDisplayController {

    @AuraEnabled
    public static userVillage getCurrentUserDetails() {
		
        userVillage uv = new userVillage();
        string message = '';
        
        User u = [SELECT Id, FirstName, LastName, Village__c, LanguageLocaleKey, ContactId 
                  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        uv.user = u;
        
        Village__c v = null;
        map<string, string> villages = new map<string, string>();
        
        try {
            list<Village_Presence_Contact_Role__c> vpcrList = [select Id, Village_Presence__r.Village__r.Daily_Sales_Message__c,
            													Village_Presence__r.Village__r.Name
                                                              from Village_Presence_Contact_Role__c where Contact__c = :u.ContactId];
            if (!vpcrList.isEmpty()){
                for (Village_Presence_Contact_Role__c vpcr :vpcrList){
                	string vlg = vpcr.Village_Presence__r.Village__r.Name;
                	if(!villages.containsKey(vlg)){
                    	if (string.isnotBlank(vpcr.Village_Presence__r.Village__r.Daily_Sales_Message__c)) {
                    		message += vpcr.Village_Presence__r.Village__r.Daily_Sales_Message__c + '&#13;';
                    		
                    		villages.put(vlg, vlg);	
                    	}
                	}
                }
                
            }
            
        	v = [select Id, Name, Village_Code__c, Daily_Sales_Message__c 
                    	from Village__c where Name =:u.Village__c limit 1];
        } catch (exception e){
            v = null;
        }
        uv.village = v;
        
        if (string.isnotBlank(message)) {
        	uv.message = message;
        } else {
            uv.message = '';
        }

        system.debug(' @@@@ uv.message ... ' + uv.message);
        
        return uv;
  	
    }    

    @AuraEnabled
    public static string  getLabel(string labelReference, string language) {
        system.debug('@@@@ labelReference  ' + labelReference);
		
        if (string.isBlank(language)){
            User u = [SELECT Id, FirstName, LastName, Village__c, LanguageLocaleKey, ContactId 
                      FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        	language = u.LanguageLocaleKey;
        
        }
        map<string, string> labelValues = new map<string, string>();
        
		list<string> labelList = labelReference.split(',');
        system.debug('@@@@ labelList  ' + labelList);
        for (string l :labelList){
			ZLabelTranslator t = new ZLabelTranslator();
            system.debug('@@@@ l  ' + l);
            string lbl_text = '';
            integer pos = l.indexOf('.');
            system.debug('@@@@ pos  ' + pos);
            if (pos > -1){
                string lblName = l.substring(pos + 1);
                lblName = lblName.substring(0, lblName.length() - 1);
                system.debug('@@@@ lblName  ' + lblName);
                try {
                    lbl_text = t.translate(lblName,language);
                } catch (exception e){
                    try {
                        lbl_text = t.translate(lblName,'en');
                    } catch (exception ex){
                        lbl_text = '';
                    }
                }
                labelValues.put(l, lbl_text);
            }
        }
        
        return json.serialize(labelValues);    
    }
    
    public class userVillage{

       	@AuraEnabled
        public User user{get; set;}
        @AuraEnabled
        public Village__c village{get; set;}        
        @AuraEnabled
        public string message{get; set;}                 
        
    }
    
}