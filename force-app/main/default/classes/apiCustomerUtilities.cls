global with sharing class apiCustomerUtilities {
	
	public static list<SelectOption> getEnumOptions(string typeName){
		
		list<SelectOption> returnList = new list<SelectOption>();
        string returnXML = apiService.readLookup(typeName);
        
        if (string.isnotBlank(returnXML) && !returnXML.contains('Error')){
            returnList = apiLookup.parseXML(returnXML); 		
        } else {		        	
			returnList = null;		        	
        }
        
        return(returnList);
	}   
	
	public static map<string, string> getEnumValueMap (string typeName){

		list<SelectOption> optionsList = new list<SelectOption>();
        map<string, string> enumValues = new map<string, string>();

        optionsList = getEnumOptions(typeName);
        
		if (optionsList != null){
            optionsList = PicklistUtilities.selectOptionSortByLabel(optionsList);
            for (SelectOption o :optionsList){
            	if (string.isnotBlank(o.getValue())){
            		enumValues.put(o.getValue(), o.getLabel());
            	}
            } 		
        } else {
        	enumValues = null;
        }	 	

	 	return enumValues;
	}   
   
	// called on save, if primary village is not populated, to default the user's village
	public static string getDefaultVillage(){
		
		string code = '';		
		
		try{
			string userId = UserInfo.getUserId();
	        list<user> users = [SELECT id, Village__c FROM USER 
	                            WHERE id = :userId
	                            LIMIT 1];
	                            
	        string village = users[0].Village__c;
	
	
			string integrationVillage = '';
			
			if (string.isnotBlank(village)){
	        	list<Village__c> theVillage = [select Id, Integration_Village_Name__c from Village__c
	        									where Name = :village
	        									LIMIT 1];
	
	        	if(!theVillage.isEmpty())
	        		integrationVillage = theVillage[0].Integration_Village_Name__c;								
				
				if (string.isnotBlank(integrationVillage)){
					map<string, string> theValues =  getEnumValueMap('Villages');
					
					for (string key : theValues.keySet()){
						string v = theValues.get(key);
						if (v == integrationVillage){
							code = key;
							break;
						}
					}
				}
			}
	system.debug('@@@@ getDefaultVillage returning ...   ' + code);
		} catch (exception e){
			code = '';
			system.debug(' @@@ ERROR ... ' + e.getMessage() + ' : ' + e.getStackTraceString());
		}
		return code; 
	}   

	// called on save, if preferred language is not populated, to default the village language- based on user's village
	public static string getDefaultLanguage(){
		
		string code = '';		
		
		try {
			string userId = UserInfo.getUserId();
	        list<user> users = [SELECT id, Village__c FROM USER 
	                            WHERE id = :userId
	                            LIMIT 1];
	                            
	        string village = users[0].Village__c;
	
	
			string integrationLanguage = '';
			
			if (string.isnotBlank(village)){
	        	list<Village__c> theVillage = [select Id, Integration_Language_Name__c from Village__c
	        									where Name = :village
	        									LIMIT 1];
	
	        	if(!theVillage.isEmpty())
	        		integrationLanguage = theVillage[0].Integration_Language_Name__c;								
				
				if (string.isnotBlank(integrationLanguage)){
					map<string, string> theValues =  getEnumValueMap('Languages');
					
					for (string key : theValues.keySet()){
						string v = theValues.get(key);
						if (v == integrationLanguage){
							code = key;
							break;
						}
					}
				}
			}
	system.debug('@@@@ getDefaultLanguage returning ...   ' + code);
		} catch (exception e){
			system.debug(' @@@ ERROR ... ' + e.getMessage() + ' : ' + e.getStackTraceString());
			code = '';
			
		}
		return code; 
		
	} 
	
	// returns comma separated list of lead source text values from custom settings
	public static string getLeadSourceTextValues(){
		
		VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
		string leadSourceText = orgSettings.Lead_Source_Text_Values__c;
		system.debug(leadSourceText);
		
		return leadSourceText;
		
	}
		  	
	webservice static string deleteGuest(string guid){

		string deleteResult = '';
		
		Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

		if (profileName == 'xxxxx' ){ // logic to restrict who can delete ... to be added later if required ?
			deleteResult = 'You do not have permission to delete Guest record';			
		} else {
						
			try{		
				string apiCall = apiService.deleteCustomer(guid);
	
				if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
					
					deleteResult = 'Request to delete guest has been successfully received and will be processed shortly.';
	
				} else{
		            string errMsg = 'Guest could not be deleted at this present time - please report to system administrator if error persists.';
		            errMsg += '\r\n' + apiCall;                
				    system.debug(errMsg); 
				    deleteResult = errMsg;                               
				}          				
			} catch (exception e){
	
				string errMsg = 'ERROR - Internal technical error - Guest could not be deleted at this present time - please report to system administrator if error persists.';
	            errMsg += '\r\n' + e.getMessage() + ' : ' + e.getStackTraceString();                
			    system.debug(errMsg); 
			    deleteResult = errMsg;                               
				    			
			}
		
		}
		return deleteResult;		
		
	}   

	 
}