trigger CustomerTriggers on b2c_customer__c (after delete) {
	
	if (trigger.isDelete && trigger.isAfter){

system.debug(' about to delete ...  ');
		try{
			ODSDeleteHelper.deleteRecord(trigger.oldMap.KeySet());
			
system.debug('deleted !!');
		} catch (exception e){
			system.debug( ' @@@@@    '   + e.getMessage() + ' : ' + e.getStackTraceString());	
		}	
	}
	
}