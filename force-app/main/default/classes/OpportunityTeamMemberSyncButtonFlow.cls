global with sharing class OpportunityTeamMemberSyncButtonFlow {
@InvocableMethod(Label='Sync Opportunity')		
    public static List<String>  syncUpadateOpportunityTeamMember(list<Id> accIdList){
        List<String> SyncAccountString = New List<String>();  
         string returnValue = '';
        returnValue = OpportunityTeamMemberSync.syncAccountRecordListPersonnel(accIdList);
        SyncAccountString.add(returnValue);

        return SyncAccountString;        
    }
}