trigger Operational_Incident_Trigger on Operational_Incident__c (before insert, before update) {

	if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
		OperationalIncidentTriggerHelper.updateDepartment(trigger.new);
	}
}