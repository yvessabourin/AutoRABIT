global with sharing class OpportunitySegmentSynchButtonFlow {
        
    @InvocableMethod(Label='Sync Segmentation Data')	
    public static List<String> syncSegmentationData(list<Id> oppIdList){
        List<String> syncSegmentationResult = New List<String>();  
        string returnValue = '';
        
        returnValue = OpportunitySegmentSynch.syncSegmentationData(oppIdList, true);
        syncSegmentationResult.add(returnValue);

        return syncSegmentationResult;        
    }
}