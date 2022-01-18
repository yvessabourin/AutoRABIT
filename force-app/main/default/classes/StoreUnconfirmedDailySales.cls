// Used by Visualforce Component - Unconfirmed_Daily_Sales in construction of reminder email
// sent to brand contacts where a daily sale record has not been confirmed within a day
public class StoreUnconfirmedDailySales {

	//capture the user id
    public Id userId {get; set;}
    public string language {get; set;}
    public map<Id, Daily_Sale__c> unconfirmedList = new map<Id, Daily_Sale__c>();
    private static final string fieldSetName = 'Reminder_Email';
    
    public list<Daily_Sale__c> getUnconfirmedList() {
		
		try{		
			if (string.isnotBlank(userId)){
				// Retrieve user record language to be used on Visualforce component.
				// This ensures field labels on email appear in correct language
				User u = [select Id, Email, ContactId, LanguageLocaleKey from User where Id = :userId];
				
				if (string.isnotBlank(u.ContactId)){
					this.language = u.LanguageLocaleKey; // set language
					
					// Retrieve Village presence contact roles associated with user
					list<Village_Presence_Contact_Role__c> vpcrList = [select Village_Presence__c, Daily_Sales_Active_From__c,
																		Daily_Sales_Active_To__c
																		from Village_Presence_Contact_Role__c 
																		where Village_Presence__r.Daily_Sales_Active__c = true
																		and Daily_Sales_Active_From__c != null
																		and Contact__c = :u.ContactId];
					
					if (!vpcrList.isEmpty()){
						
						set<Id> vpIds = new set<Id>();
						for (Village_Presence_Contact_Role__c vpcr :vpcrList){
							vpIds.add(vpcr.Village_Presence__c);
							
						}
						
						// Retrieve unconfirmed Daily sale records associated with the user's village presence contact
						// roles.
						// Construct query using fields defined on Daily_Sale__c 'Reminder_Email' fieldset. 
						date thisDay = system.today();						
						string query = 'select Id, Name, Store__r.Name,  ';					
						List<DailySalesListController.FieldSetMember> fsFlds = DailySalesListController.getFields(fieldSetName);
				        for (DailySalesListController.FieldSetMember fm :fsFlds){
				            string fldName = fm.fieldPath;
				            if (fldName != 'Id' && fldName != 'Name'){
				                query = query + fldName + ',';
				            }            
				        }
				        query = query.subString(0,query.length() - 1);
				        query = query + ' from ';
				        query = query + ' Daily_Sale__c';
				        query = query + ' where Brand_Status__c = \'Not Confirmed\' ';
				        query = query + ' and Trading_Date__c < :thisDay';
				        query = query + ' and Trading_Date__c = LAST_N_DAYS:7';
				        query = query + ' and Store__c in :vpIds';
        				
        				list<Daily_Sale__c> dsList = Database.query(query);

        				/*		
						list<Daily_Sale__c> dsList = [select Id, Name, Trading_Date__c, Store__c, Store_Formula__c, 
														Brand_Reported_Amount__c, Store_Closed__c, Trading_Day_with_date__c,
														Valid_for_Confirmation__c
											from Daily_Sale__c
											where Brand_Status__c = 'Not Confirmed'
											and Trading_Date__c < :system.today()
											and Store__c in :vpIds];
						*/
						
						if (!dsList.isEmpty()){
							for (Village_Presence_Contact_Role__c vpcr :vpcrList){
								Date startDt = vpcr.Daily_Sales_Active_From__c;
								Date endDt = vpcr.Daily_Sales_Active_To__c;
								// Ensure that only records which are within the village presence contact role Daily sale
								// date boundaries appear on the email
								for (Daily_Sale__c ds :dsList){
									if (vpcr.Village_Presence__c == ds.Store__c
											&& ds.Trading_Date__c >= startDt
											&& (endDt == null || endDt >= system.today())){
												
										unconfirmedList.put(ds.Id, ds);			
									}
								}
							}
							
						}					
						
					}																	
																		
					
				}
				
				
				
			}
		} catch (exception e){
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());			
		}
		return unconfirmedList.values();
        
    }
    
	
    
}