global with sharing class SyncOpportunityRecordPersonnelButtonFlow {
        
    @InvocableMethod(Label='Sync Opportunity Record Personnel')	
    public static void syncOpportunityRecordPersonnel(List<String> oppIdList){
        OpportunityTeamMemberSync.syncOpportunityRecordPersonnel(oppIdList);
    }
}