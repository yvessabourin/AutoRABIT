global without sharing class ODSDeleteHelper {


	// Method to create a log entry for a deleted ODS object record
	public static void deleteRecord(set<Id> idList){
				
		// create log list for new records
		list<ODS_Delete_Log__c> logList = new list <ODS_Delete_Log__c>();
		
		for (Id recId :idList){
			
			// determine object API name from record Id
			string objectAPIName = recId.getSObjectType().getDescribe().getName();
			
			// create new log record
			ODS_Delete_Log__c log = new ODS_Delete_Log__c();
			
			log.Deleted_Record_ID__c = recId;
			log.sObject__c =  objectAPIName;
			log.Deleted_By_User_ID__c = UserInfo.getUserId(); // row id of current user
			log.Deleted_Date_Time__c = system.now();
			
			// add to list
			logList.add(log);
						
		}
		
		if (!logList.isEmpty()){			
			insert logList;
		}
		
		
	}

	webservice static String deleteCustomer(Id recordId) {
        return deleteObjectRecord(recordId);
   	}

	private static string deleteObjectRecord(Id recordId){
		
		string returnVal;
		
		Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

system.debug (' @@@@ ' + profileName);		
// to do .. retrieve profile names from custom setting ..hard coded for time-being
		if (profileName != 'CRM' && profileName != 'System Administrator' && profileName != 'Business Systems'){
			returnVal = 'You do not have permission to delete record';
			
		} else {
			
			// determine object API name from record Id
			string objectAPIName = recordId.getSObjectType().getDescribe().getName();
			
			string soql = 'select Id from ' + objectAPIName + ' where Id = :recordId' ;
			
			sobject obj = database.query(soql);
			
			database.delete(obj);
			
			// ensure record is hard deleted to prevent recovery from recycle bin
			database.emptyRecycleBin(obj);
			
			returnVal = 'Record Deleted';
		}

system.debug(returnVal);
		
		return returnVal;
	}


}