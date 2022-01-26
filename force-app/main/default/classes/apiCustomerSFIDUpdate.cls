global without sharing class apiCustomerSFIDUpdate{
    
    private static map<Id, Account> updateAccountMap = new map<Id, Account>();
    private static boolean retry = false;
        	
	public static void updateIntegrationSFIDs() {
        
        list<Integration_Salesforce_Id_Queue__c> qList = [select Salesforce_Id__c, Customer_GUID__c from Integration_Salesforce_Id_Queue__c limit 10];
        
        if (!qList.isEmpty()){
        	processQueue(qList);        		
        }

    	if (retry){

   			string exeTime = system.now().addSeconds(300).format('ss mm HH dd MM ? yyyy');
   			string guid = guidGenerator.newGuid();
    		System.schedule('apiCustomerSFIDUpdateBatch__' + guid, exeTime , new apiCustomerSFIDUpdateBatch());  
    	
			system.debug(' @@@@@ qList ...  ' + qList);			
			           		
    	}
    	                
    }

	public static void updateBatchIntegrationSFIDs(list<Integration_Salesforce_Id_Queue__c> qList){

		if (!qList.isEmpty()){
        	processQueue(qList);        		
        }

    	if (retry){

   			string exeTime = system.now().addSeconds(300).format('ss mm HH dd MM ? yyyy');
    		string guid = guidGenerator.newGuid();
    		System.schedule('apiCustomerSFIDUpdateBatch__' + guid, exeTime , new apiCustomerSFIDUpdateBatch());
    		
			system.debug(' @@@@@ qList ...  ' + qList);			
			           		
    	}		
		
	}
	            
    private static void processQueue(list<Integration_Salesforce_Id_Queue__c> qList){
    	
    	list<Integration_Salesforce_Id_Queue__c> deleteList = new list<Integration_Salesforce_Id_Queue__c>();

    	set<string> accountIdList = new set<string>();
    	
    	for(Integration_Salesforce_Id_Queue__c qItem :qList){
    		accountIdList.add(qItem.Salesforce_Id__c);    		
    	}
    	updateAccountMap = new map<Id, Account>([select Id, Integration_Salesforce_Id__c from Account where Id in :accountIdList]);
    	
        for(Integration_Salesforce_Id_Queue__c qItem :qList){
        	boolean success = sendId(qItem);
        	if (success){
        		deleteList.add(qItem);
        	} 
        }
		
		if (updateAccountMap.size() != deleteList.size()){
			retry = true;
			update qList; 
			
		} 
    	
    	if (!deleteList.isEmpty()){
    		delete deleteList;
    		update updateAccountMap.values();
    	}
    	


    }    
	
	private static boolean sendId(Integration_Salesforce_Id_Queue__c qItem){
		
		boolean success = false;
		
		try {		
			
	
			apiCustomer.cls_Customer customer = new apiCustomer.cls_Customer();		
			string guid = qItem.Customer_GUID__c;
	               
	        string apiCall = apiService.readByGUID(guid);            
	
	        if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
	            customer = apiCustomer.parseXML(apiCall);
				apiCustomer.cls_references customerReferences = customer.References;
				if (customerReferences == null){
			        customerReferences = new apiCustomer.cls_references();
			        apiCustomer.cls_item REFitem = new apiCustomer.cls_item();
			        apiCustomer.cls_item[] REFitems = new apiCustomer.cls_item[]{};
			            
			        REFitem.x_type = 'SALESFORCEID';
			        REFitem.y_text = qItem.Salesforce_Id__c;
			        
			        REFitems.add(REFitem);
					customerReferences.item = REFitems;
		        
				} else {
					boolean sfExists = false;
					for (apiCustomer.cls_item ref :customerReferences.item){
						if (ref.x_type == 'SALESFORCEID'){
							ref.y_text = qItem.Salesforce_Id__c;
							sfExists = true;
							break;
						}
					}
					
					if (!sfExists){
						apiCustomer.cls_item REFitem2 = new apiCustomer.cls_item();
				            
				        REFitem2.x_type = 'SALESFORCEID';
				        REFitem2.y_text = qItem.Salesforce_Id__c;						
						customerReferences.item.add(REFItem2);
					}
				}

		        customer.References = customerReferences;
		
		        string xmlCustomer = apiCustomer.convertToXML(customer);
		        
		        string apiCallResponse = apiService.updateCustomer(xmlCustomer);
		        //string apiCallResponse = apiService.postNewCustomer(xmlCustomer);
system.debug(' @@@ Queued apiCallResponse...  ' + apiCallResponse);		              
				if (apiCallResponse.contains('ERROR')){
					if (apiCallResponse.length() > 255){
        				apiCallResponse = apiCallResponse.left(254);
        			}
        			qItem.Error_Details__c = apiCallResponse;
        			success = false;
				} else {
					success = true;
					Account a = updateAccountMap.get(qItem.Salesforce_Id__c);
					a.Integration_Salesforce_Id__c = qItem.Salesforce_Id__c;
				}           	
	        } else {
	        	if (apiCall.length() > 255){
	        		apiCall = apiCall.left(254);
	        	}
	        	qItem.Error_Details__c = apiCall;
	        	success = false;
	        }		
		
		} catch (exception e){
			
			success = false;
		}
		
		return success;
	}    

}