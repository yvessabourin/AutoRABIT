public class CloneMasterBudgetSheetController {
        
    public List<Master_Budget_Sheet__c> selectedItems {get; set;}
    
    public CloneMasterBudgetSheetController(ApexPages.StandardSetController controller){
        selectedItems = (List<Master_Budget_Sheet__c>)controller.getSelected();
    }
    
    @InvocableMethod
    public static void CloneMasterBudgetSheet(List<List<Master_Budget_Sheet__c>> masterBudgedSheets){
        List<String> mdSheetsIds = new List<String>();
        for(List<Master_Budget_Sheet__c> mbsList: masterBudgedSheets){
            for(Master_Budget_Sheet__c mbs: mbsList){
                mdSheetsIds.add(mbs.Id);
            }
        }
        CloneMasterBudgetSheetHelper.clone(mdSheetsIds);
    }

}