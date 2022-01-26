global class apiCustomerPreferenceController {
	
	public apiCustomer.cls_Customer customer {get; set;}
	public string preference {get; set;}
	public string preferenceValue {get;set;}
	public string preferenceJSON {get;set;}
	private map<string, string> currentPreferenceMap = new map<string, string>();
	private map<string, string> preferenceMap = new map<string, string>();
	private ApexPages.StandardController theController;
	
	global apiCustomerPreferenceController(ApexPages.StandardController controller){

         try {        
                theController = controller;
                customer = new apiCustomer.cls_Customer();
                    
                string recId = controller.getId();
 system.debug(' @@@@ Global controller recId  ' + recId);
                Account a = [select Id, Customer_GUID__c from Account where Id = :recId];
				string guid = a.Customer_GUID__C;
				string apiCall = apiService.readPreferences(guid);
				customer.x_CustomerId = guid;
system.debug(' @@@@ apiCall  ' + apiCall);				
				if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
                	this.customer = apiCustomer.parsePreferenceXML(apiCall, this.customer);
                	
                	preferenceMap = new map<string, string>(this.customer.preferenceMap);
                	preferenceJSON = json.serialize(preferenceMap);
                	currentPreferenceMap = new map<String, string>(this.customer.preferenceMap);
system.debug(' @@@@  Preference Map ..  ' + preferenceMap);
                	
            	} else {
            		
	                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
	                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
	                system.debug(errMsg);             		
            	}
            	             
         } catch (exception e){
            string errMsg = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
            system.debug(errMsg);             
         }
        
    }
    
	public list<SelectOption> getPreferenceOptions(){
    	
    	list<SelectOption> returnList = new list<SelectOption>();
    	returnList.add(new SelectOption('-', '-- Not Specified --'));
	    returnList.add(new SelectOption('true', 'Yes'));
	    returnList.add(new SelectOption('false', 'No'));
    	
    	return returnList;
	}
	
    public PageReference savePreference(){

		boolean preferenceUpdate = true;
		boolean continueCreate = true;
		
		string errMsg = '';
		PageReference pgReturn = null;
		
		try {
	        // retrieve preferences required from custom setting
	        map<String, API_Preference_Map__c> preferenceSettings = API_Preference_Map__c.getAll();
system.debug(' @@@@  Current Preference Map ..  ' + currentPreferenceMap);
system.debug(' @@@@  Preference Map ..  ' + preferenceMap);	 		
        	string value = '';
        	if (preferenceMap.containsKey(preference)){
        		value = preferenceMap.get(preference);
        		if (string.isnotBlank(currentPreferenceMap.get(preference))){
        			string deleteKey = '/' + customer.x_CustomerId + '|' + 'contactmodes' + '|' + preferenceSettings.get(preference).API_Name__c;
        			string apiDeletePreferenceCallResponse = apiService.deletePreference(deleteKey);
					if (string.isnotBlank(apiDeletePreferenceCallResponse) && !apiDeletePreferenceCallResponse.contains('Error')){
	                	//this.customer = apiCustomer.parsePreferenceXML(apiCall, this.customer);
	                	preferenceMap = new map<string, string>(this.customer.preferenceMap);
	                	preferenceJSON = json.serialize(preferenceMap);
	system.debug(' @@@@  Preference Map ..  ' + preferenceMap);
						removeMapNulls();
						continueCreate = true;
	                	
	            	} else{ 
		                continueCreate = false;
		                errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
		                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
		                system.debug(errMsg);                                
	            	}        			
        			
        		}
        	}
        				        	
        	//<CustomerPreference CustomerId="00000000-0000-0000-0000-000000000000" Group="contactmodes" Key="email" Value="true"  />
        	string newValue = customer.preferenceMap.get(preference);
        	if (string.isBlank(newValue)){
        		newValue = '';
        	}
system.debug(' @@@@ newValue = ' + newValue + ' - ' + continueCreate);			        	
        	if (newValue != value && string.isnotBlank(newValue) && continueCreate){ // value updated
				string msg = '<CustomerPreference CustomerId="' + this.customer.x_CustomerId +'"';
				msg += ' Group="contactmodes" Key="' + preferenceSettings.get(preference).API_Name__c;
				msg += '" Value ="' + customer.preferenceMap.get(preference) + '"/>';
				string apiPreferenceCallResponse = apiService.postPreference(msg);
				
				if (apiPreferenceCallResponse.contains('ERROR')){
					preferenceUpdate = false;
					errMsg = 'There was an error updating the customer ' + preference + ' preference. ' + apiPreferenceCallResponse + '\r\n';
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
					customer.preferenceMap.put(preference, value);
					preferenceMap = new map<string, string>(this.customer.preferenceMap);
					preferenceJSON = json.serialize(preferenceMap);
					removeMapNulls();
	system.debug(' @@@@  Customer Preference Map ..  ' + this.customer.preferenceMap);					
				} else {
					// Retrieve preferences
	            	string apiCall = apiService.readPreferences(customer.x_CustomerId);
					
					if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
	                	//this.customer = apiCustomer.parsePreferenceXML(apiCall, this.customer);
	                	preferenceMap = new map<string, string>(this.customer.preferenceMap);
	                	preferenceJSON = json.serialize(preferenceMap);
	system.debug(' @@@@  Preference Map ..  ' + preferenceMap);
						removeMapNulls();
	                	
	            	} else{ 
		                errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
		                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
		                system.debug(errMsg);                                
	            	}
				}			        	
        	
        	}        	

  			        			
		} catch (exception e){
			preferenceUpdate = false;
			
		}
    	
    	
    	return pgReturn;
    	
    }
    
    public PageReference savePreferenceMobile(){

system.debug('@@@@ setting .. ' + preference + ' = ' + preferenceValue);    	
    	//preferenceMap.put(preference, preferenceValue);
    	customer.preferenceMap.put(preference, preferenceValue);
    	return savePreference();
    	
    }
	private void removeMapNulls(){
		
		for (string key :customer.preferenceMap.keySet()){
			if (string.isBlank(customer.PreferenceMap.get(key))){
				customer.preferenceMap.put(key, '-');
			}
		}
		
	}


/*
    // Preferences call when in read-only mode
    @RemoteAction
    public static string getMarketingPreferences(string guid){
        
        map<string, string> marketingPrefMap = new map<string, string>();
    
        // Retrieve preferences
        string apiCall = apiService.readPreferences(guid);

        // Check for error
        if (!apiCall.contains('ERROR')){
            apiCustomer.cls_Customer c = new apiCustomer.cls_Customer();
            c = apiCustomer.parsePreferenceXML(apiCall, c);
            
            marketingPrefMap = new map<string, string>(c.preferenceMap);
system.debug(' @@@@  marketingPrefMap  ..  ' + marketingPrefMap);           
            
            json.serialize(marketingPrefMap);
        } else {
            marketingPrefMap.put('Error', apiCall);
        }  
            
        return json.serialize(marketingPrefMap);
        
    }
*/
	    
}