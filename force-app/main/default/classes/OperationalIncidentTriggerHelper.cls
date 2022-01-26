public with sharing class OperationalIncidentTriggerHelper {

	public static void updateDepartment(list<Operational_Incident__c> incidentList){
		
		//retrieve department list
		list<Operations_Department__c> OpDepts = [SELECT id, Department__c, Village__c FROM Operations_Department__c];
		
		// retrieve village from the running user
		list<user> userVillage = [SELECT Village__c FROM user where id = :UserInfo.getUserId() LIMIT 1];
		
		// retrieve default operations department id from custom setting
		VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
	    string defaultDeptId = settings.Default_Operations_Department__c;
	    
	    // loop through each incident record	        	
    	for (Operational_Incident__c incident: incidentList)
 		{
        	string deptId = '';
        	// find a department match for the incident category and operations department and village
        	for (Operations_Department__c od : OpDepts)
        	{
         		if(incident.Category__c == od.Department__c && userVillage[0].village__c == od.Village__c)
            	{
                	// set department to matching value
                	deptId = od.Id;
                	break;
            	}   
        	}
     	   
     		// if no match, set the department to the default value
     		if(string.isBlank(deptId))
	     	{
 	        	deptId = defaultDeptId; 	        	
 			}  		
			
			incident.Operations_Department__c = deptId;
		}
	
	}

}