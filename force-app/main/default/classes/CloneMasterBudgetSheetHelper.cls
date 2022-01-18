global class CloneMasterBudgetSheetHelper {

    webservice static void clone(List<String> idList){
        List<Master_Budget_Sheet__c> clonedMasterBudgetList = new List<Master_Budget_Sheet__c>();
        Master_Budget_Sheet__c clonedSheet;
        List<Master_Budget_Sheet__c> masterBudgetList = [SELECT Id, Name, Month__c, Comments__c, Budget_Village__c, 
                                        Creative_Agency_1__c, Creative_Agency_2__c, Creative_Agency_3__c, Creative_Agency_4__c, 
                                        Creative_Agency_5__c, Creative_Agency_6__c, Creative_Agency_7__c, Creative_Agency_8__c                                          
                                        FROM Master_Budget_Sheet__c
                                        WHERE Id IN :idList];
        for(Master_Budget_Sheet__c sheet : masterBudgetList){
            clonedSheet = sheet.clone(false, true, false, false);
            clonedMasterBudgetList.add(clonedSheet);
        }
        upsert clonedMasterBudgetList;
    }
}