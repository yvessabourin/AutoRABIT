public class IntegrationErrorTrackedBagTriggerHandler{
    public static List<HFS_IntegrationErrorTrackedBag__c> recordstoDelete;

    public static void checkIfResolved(List<HFS_IntegrationErrorTrackedBag__c> integrationErroList){
        recordstoDelete = new List<HFS_IntegrationErrorTrackedBag__c>();
        for(HFS_IntegrationErrorTrackedBag__c record : integrationErroList){
            if(!record.Is_Resolved__c){
                record.addError('This record can not be deleted because it is not resolved.');
            } else {
                recordstoDelete.add(record);
            }
        }
        delete recordstoDelete;
    }

    public static void checkBagList(List<HFS_IntegrationErrorTrackedBag__c> integrationErroList){
        for(HFS_IntegrationErrorTrackedBag__c errorBag : integrationErroList){
            try{
                List<HFS_Bag__c> baglist = (List<HFS_Bag__c>)JSON.deserialize(errorBag.List_of_Bags__c, List<HFS_Bag__c>.Class);
                if(baglist.size() != errorBag.Number_of_Bags__c){
                    errorBag.addError('The bags in the Bag List do not match the number of total bags.');
                }
            }catch(Exception e){
                errorBag.addError('There is an issue with the Bag List');
            }
        }
    }
}