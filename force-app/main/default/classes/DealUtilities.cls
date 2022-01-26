public with sharing class DealUtilities {
	
	public static string ReassignDealOwnertoLeadNegotiator(string currentOwner){
		
		string returnValue = '';		
		
		try {		

			string soql = '';
			User u = null;
			string userId = '';
			DateTime lastModified = system.now().addSeconds(-1200);
			
			soql = 'Select Id, OwnerId, Lead_Negotiator_for_VR__c,' ;
			soql += 'Village_Presence__r.Brand__r.EU_Brand_Captain__c,';
			soql += 'Lead_Negotiator_for_VR__r.IsActive,';
			soql += 'Village_Presence__r.Brand__r.EU_Brand_Captain__r.IsActive';
			soql +=	' from Opportunity';									
			soql += ' where (Lead_Negotiator_for_VR__r.IsActive = true';										 
			soql += ' or Village_Presence__r.Brand__r.EU_Brand_Captain__r.IsActive = true)';							
			if (string.isnotBlank(currentOwner)){
				u = [Select Id from User where UserName = :currentOwner limit 1];
				
				if (u != null){
					userId = u.Id;
					soql += ' and OwnerId = :userId';
				} else {
					returnValue = 'User not found, no records processed';
				}		 
			}
			if (!test.isRunningTest())
				soql += ' and SystemModStamp < :lastModified';
            
            soql += ' limit 400';
            
			if (string.isBlank(returnValue)){
				
				list<Opportunity> dealList = database.query(soql);
				
				if (!dealList.isEmpty()){
					for (Opportunity deal :dealList){
system.debug('@@@ deal  - ' + deal);
						if(string.isnotBlank(deal.Lead_Negotiator_for_VR__c)){
							if (deal.Lead_Negotiator_for_VR__r.IsActive)
								deal.OwnerId =  deal.Lead_Negotiator_for_VR__c;
						} else if (string.isnotBlank(deal.Village_Presence__r.Brand__r.EU_Brand_Captain__c)){
							if(deal.Village_Presence__r.Brand__r.EU_Brand_Captain__r.IsActive)
								deal.OwnerId = deal.Village_Presence__r.Brand__r.EU_Brand_Captain__c;
						}															
					}
					
					update dealList;
					returnValue = dealList.size() + ' Processed.';
				}
			}
		} catch(exception e){
			
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());			
			returnValue = 'ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString();
		}		
		
		return returnvalue;
		
	}
	    
}