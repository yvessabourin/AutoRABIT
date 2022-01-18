trigger TourismPartnerProjectionTrigger on Tourism_Partner_Projection__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {
/*
	 map<Id, Tourism_Partner_Projection__c> mapTPPNew;

		if (Trigger.isBefore && Trigger.isInsert) {
	    	//call your handler.before method
	    	System.debug('Trigger.newMap ==== ' + Trigger.newMap);
	    	 mapTPPNew = new map<Id, Tourism_Partner_Projection__c>();
            for(Tourism_Partner_Projection__c tpp : trigger.new)
                mapTPPNew.put(tpp.Id, tpp);
		
		System.debug('Trigger.newMap ==== ' + mapTPPNew);
	    
	    TourismPartnerProjectionsTriggerHandler.processBeforeInsert( mapTPPNew);

		} else if (Trigger.isAfter) {
	    	//call handler.after method
	    
		}
*/
}