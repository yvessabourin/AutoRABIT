global class apiCustomerViewController {

    global map<string, string> readOnlyMap {get; set;}
    global list<string> sortedReadOnlyList {get;set;}


    global apiCustomerViewController(ApexPages.StandardController controller) {
                
    }
    

    @RemoteAction
    global static string  callReadOnlyService(string guid){
        
    
        string apiCall = apiService.readReadOnlyItem(guid);
system.debug('@@@@  apiCall return from Remote Call .. ' + apiCall);
		apiCall = apiCall.trim(); 
        list<apiCustomerRead.cls_CustomerReadItem> itemList = new list <apiCustomerRead.cls_CustomerReadItem>();
        map<string, list<apiCustomerRead.cls_CustomerReadItem>> readOnlyItems = new map<string, list<apiCustomerRead.cls_CustomerReadItem>>();
        
        
        // Check for error
        if (!apiCall.contains('ERROR')){

		// retrieve read only items required to be displayed from custom setting
	    	map<String, API_Customer_Read_Items__c> readOnlySettings = API_Customer_Read_Items__c.getAll();    	
	    	
	    	for (API_Customer_Read_Items__c itemDef :readOnlySettings.values()){            
	            	list<string> sectionId = itemDef.Name.split(' ');
	            	string sectionName;

	            	if (sectionId.size() > 1){
	            		sectionName = sectionId[1];	
	            	}
	            	
		            itemList = apiCustomerRead.parseXML(apiCall, sectionName);
		    
system.debug('@@@@  itemList .. ' + itemList);          
 
		            
		            readOnlyItems.put(sectionName, itemList);
		            //return readOnlyItems;

        	}
	        return json.serialize(readOnlyItems);
        } else {
            map<string, string> errorMap = new map<string, string>();
            errorMap.put('Error', apiCall);
            return json.serialize(errorMap);
        }
    
    }       
    


    global void getReadOnlyItems(){
        
        // retrieve read only items required to be displayed from custom setting
        map<String, API_Customer_Read_Items__c> readOnlySettings = API_Customer_Read_Items__c.getAll();
        readOnlyMap = new map<string, string>();
        list<string> readOnlyList = new list<string>();
        sortedReadOnlyList = new List<String>();
        readOnlyList.addAll(readOnlySettings.keySet());
system.debug(' @@@ readOnlyList 1 ' + readOnlyList) ;   
        readOnlyList.sort();
system.debug(' @@@ readOnlyList 2 ' + readOnlyList) ;   
        
        for(string key :readOnlyList){
            API_Customer_Read_Items__c item = readOnlySettings.get(key);
            if (item.Active__c){
                string label = item.item_label__c;
                string ref = item.name;
                //if (item.section_item__c){
                	readOnlyMap.put(label, ref);
                	sortedReadOnlyList.add(label);
                //}  
            }   
        }
    
system.debug(' @@@ sortedReadOnlyList ' + sortedReadOnlyList) ;             
        
    }
        
    
}