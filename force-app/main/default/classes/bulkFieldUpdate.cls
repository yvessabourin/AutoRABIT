/*
-----How to Call this batchable Class from Dev Console-------

bulkFieldUpdate myBatchObject = new bulkFieldUpdate(string LIST of Fields,string ObjectType,string Suffix); 
Id batchId = Database.executeBatch(myBatchObject, 150);  
*/


global class bulkFieldUpdate implements Database.Batchable<sObject> {
	
	String query;
	
	Private List<string> fieldNames {get;set;}
	Private string myobjectName {get;set;}
	Private string fieldSuffix {get;set;}
	private boolean fieldbooleanchange {get; set;}


	global bulkFieldUpdate(List<string> fields, string objectName, string suffix) {
		
			fieldNames = fields;
			myobjectName = objectName;
			fieldSuffix = suffix;

	}
	    
	global bulkFieldUpdate(List<string> fields, string objectName, boolean boolchange) {
		
			fieldNames = fields;
			myobjectName = objectName;
			fieldbooleanchange = boolchange;

	}

	global Database.QueryLocator start(Database.BatchableContext bc) {

      String sql = 'SELECT ';

      		for(string field : fieldNames){
      			sql += field + ',';
      		}
      		sql = sql.removeEnd(',');
      		sql += ' FROM ' + myobjectName;

			System.debug('This SQL = ' + sql);	
            return Database.getQueryLocator(sql);
        }

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		string batchResults = '';
		for(sObject item : scope){
			for(string field : fieldNames){
				System.debug(item.get(field));			
				
				if(item.get(field) != NULL && item.get(field) != ''){
					if(fieldSuffix != null && fieldbooleanchange == null){
						item.put(field,item.get(field) + fieldSuffix);
					}
				}
				if(fieldSuffix == null && fieldbooleanchange != null)
				{
					System.debug('about to change value ' + fieldSuffix + fieldbooleanchange);
					item.put(field,fieldbooleanchange);
				}
				try{
					System.debug('about to update records======' + item);
					update item;
				}
				catch (exception e){
					batchResults += '@@@@@@ bulkupdate failed ' + e + ' ------ ' + item;
								
				}
			}
		}
		
		if(batchResults != ''){
			logFile__c log = new logFile__c();
			log.Body__c = batchResults;
			insert log;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}