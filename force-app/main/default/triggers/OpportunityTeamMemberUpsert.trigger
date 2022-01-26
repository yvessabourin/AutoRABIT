trigger OpportunityTeamMemberUpsert on OpportunityTeamMember (after insert, after update, after delete) {

	if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
		OpportunityTeamMemberSync.syncOpportunityPersonnel(trigger.new);
	} 

	if (trigger.isAfter && (trigger.isDelete)){
		OpportunityTeamMemberSync.syncOpportunityPersonnel(trigger.old);
	}	

}