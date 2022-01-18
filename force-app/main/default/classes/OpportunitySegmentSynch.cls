/************************************************
Author : Constantine Chimonides
Purpose : Class created to update Deal segementation data with values from parent Brand record.
Version History:
================
Created  : 16/12/2014
Modifications : 
							 
************************************************/

global with sharing class OpportunitySegmentSynch {

	
	// Update Opportunity segmentation fields with brand data
	webservice static string syncSegmentationData(list<id> oppIdList, boolean overwriteIfNotBlank){
		
		string returnValue;
		
		try {
			list<Opportunity> oppList = [select Department__c, Segment__c, Price_Point__c, 
									Account.Id, Account.Brand_Segment__c, Account.Brand_VR_Positioning__c, Account.Brand_Subsegment__c
									from Opportunity where id in:oppIdList];
			
			if (!oppList.isEmpty()){
				
				for (Opportunity opp :oppList){
					
					if (overwriteIfNotBlank){
						opp.Department__c = opp.Account.Brand_Segment__c;
						opp.Price_Point__c = opp.Account.Brand_VR_Positioning__c;
						opp.Segment__c = opp.Account.Brand_Subsegment__c;
					} else {
						if(string.isBlank(opp.Department__c)) opp.Department__c = opp.Account.Brand_Segment__c;
						if(string.isBlank(opp.Price_Point__c)) opp.Price_Point__c = opp.Account.Brand_VR_Positioning__c;
						if(string.isBlank(opp.Segment__c)) opp.Segment__c = opp.Account.Brand_Subsegment__c;	
					}
					
				}
				
				update oppList;
				
				
			}
		} catch (exception e){
			returnValue = 'A technical error has occurred : ' + e.getMessage() + ' - ' + e.getStackTraceString();
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString());	
		}
		return returnvalue;
				
	}	
	

}