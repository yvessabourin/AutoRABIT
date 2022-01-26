public with sharing class AddMasterBudgetSheetItemController {

    //Values of the Master Budget Sheet select list
    public List<MasterBudgetSheetItem> MasterBudgetSheetItemList {get; set;}
    public Boolean checkMBSI {get; set;}
    public Boolean disableSave {get; set;}
    public Id marketingActivityId {get; set;}
    public List<SelectOption> MBSSelections {get; set;}
    public Boolean renderMBSPicklist {get; set;}
    public Boolean renderTable {get; set;}
    
    //Get the picklist value
    public Id masterBudgetsheetValue {get; set;}
    public Boolean allSelected {get; set;}

    public AddMasterBudgetSheetItemController(){
        
        renderTable = false;
        renderMBSPicklist = true;
        marketingActivityId = ApexPages.currentPage().getParameters().get('Id');
        disableSave = true;

        //Get data from the current Marketing Campaign
        List<Marketing_Activity__c> mktActivityList = [SELECT Id, Name, Marketing_Campaign__r.Village__c FROM Marketing_Activity__c WHERE Id = :marketingActivityId LIMIT 1];

        List<Master_Budget_Sheet__c> masterBudgetSheetList = new List<Master_Budget_Sheet__c>();

        //Check if the Marketing Campaign is associated with a Village
        if(mktActivityList.get(0).Marketing_Campaign__r.Village__c != null){
            masterBudgetSheetList = [SELECT Id, Name FROM Master_Budget_Sheet__c WHERE Budget_Village__c = :mktActivityList.get(0).Marketing_Campaign__r.Village__c];
        }
        else{//Campaign with TBSC record type
            masterBudgetSheetList = [SELECT Id, Name FROM Master_Budget_Sheet__c];
        }
        
        //If there are master budget sheets, add the query results to the picklist options
        if (!masterBudgetSheetList.isEmpty()){

            MBSSelections = new List<SelectOption>{new SelectOption('--SelectValue--', '-- Select a value --')};
        
            for(Master_Budget_Sheet__c msb : masterBudgetSheetList){
                MBSSelections.add(new SelectOption(msb.Id, msb.Name));
            }
        }
        else{
            renderMBSPicklist = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.No_Master_Budget_Sheet));
        }
    }

    public void queryMasterBudgetSheetItems(){

        String MBSSelectionsId = String.valueOf(MBSSelections[0].getValue());
        String masterBudgetsheetValueId = String.valueOf(masterBudgetsheetValue);
        
        //Get the Master Budget Sheet Items related to the Master Budget Sheet Selected
        List<Master_Budget_Sheet_Item__c> mbsiList = new List<Master_Budget_Sheet_Item__c>();
        mbsiList = [SELECT Id, Name, Activity_Name__c, Creative_Name__c, Marketing_Partner__c, Campaign_Name__c, Marketing_Partner__r.Name, Campaign_Name__r.Name 
                    FROM Master_Budget_Sheet_Item__c 
                    WHERE Master_Budget_Sheet__c = :masterBudgetsheetValue AND Activity_Name__c = null]; 

        MasterBudgetSheetItemList = new List<MasterBudgetSheetItem>();

        //Create objects with the wrapper class to associate the checkboxes to the Master Budget Sheet Items
        if (mbsiList.size() > 0){
            for(Master_Budget_Sheet_Item__c mbsi : mbsiList){
                MasterBudgetSheetItem mbsiToAdd = new MasterBudgetSheetItem();
                mbsiToAdd.mbsiId = mbsi.Id;
                mbsiToAdd.itemName = mbsi.Name;
                mbsiToAdd.isSelected = false;
                mbsiToAdd.marketingPartnerId = mbsi.Marketing_Partner__c;
                mbsiToAdd.marketingPartner = mbsi.Marketing_Partner__r.Name;
                mbsiToAdd.campaignId = mbsi.Campaign_Name__c;
                mbsiToAdd.campaignName = mbsi.Campaign_Name__r.Name;
                mbsiToAdd.creativeName = mbsi.Creative_Name__c;
                
                MasterBudgetSheetItemList.add(mbsiToAdd);
            }
            renderTable = true;
        }
        else if (masterBudgetsheetValueId.contains(MBSSelectionsId)){
            renderTable = false;
            disableSave = false;
        }
        else {
            renderTable = false;
            disableSave = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.No_Master_Budget_Sheet));
        }
    }

    //Method for the check all Master Budget Sheet Items List
    public void checkAll(){

        if(allSelected == true){
            for(MasterBudgetSheetItem msbi : MasterBudgetSheetItemList){
                msbi.isSelected = true;
            }
        }
        else{
            for(MasterBudgetSheetItem msbi : MasterBudgetSheetItemList){
                msbi.isSelected = false;
            }
        }
    }

    public PageReference save(){
        if(disableSave == false && MasterBudgetSheetItemList.size() > 0){
            List<Id> listOfIds = new List<Id>();

            for(MasterBudgetSheetItem mbsiToUpdate : MasterBudgetSheetItemList){
                if(mbsiToUpdate.isSelected == true){
                    listOfIds.add(mbsiToUpdate.mbsiId);
                }
            }
            List<Master_Budget_Sheet_Item__c> listToUpdate = [SELECT Id,Campaign_Name__c FROM Master_Budget_Sheet_Item__c  WHERE Id IN :listOfIds];
            for(Master_Budget_Sheet_Item__c mbsiToUpdate : listToUpdate){
                mbsiToUpdate.Activity_Name__c = marketingActivityId;
            }
            if(listToUpdate.size() > 0){
                UPDATE listToUpdate;
                PageReference activitypage = new  PageReference('/' + marketingActivityId );
                activitypage.setRedirect(true);
                return activitypage ;
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Select_Master_Budget_Sheet_Item));
                return null;
            } 
        }
        else {
                renderTable = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Master_Budget_Sheet_items));
                return null;
        }
    }

    public PageReference returnToPage(){
        PageReference activitypage = new  PageReference('/' + marketingActivityId );
        activitypage.setRedirect(true);
        return activitypage;
    }
   
    public void checkSelected(){
        for(MasterBudgetSheetItem msbi : MasterBudgetSheetItemList){
            if(msbi.isSelected){
                disableSave = false;
                return;
            } 
        }
        disableSave = true;
    }

    //Wrapper to help the check box functionality
    public class MasterBudgetSheetItem{
        public Id mbsiId {get; set;}
        public String itemName {get; set;}
        public String creativeName {get; set;}
        public Id marketingPartnerId {get; set;}
        public String marketingPartner {get; set;}
        public Id campaignId {get; set;}
        public String campaignName {get; set;}
        public Id activityId {get; set;}
        public Boolean isSelected {get; set;}
        }
}