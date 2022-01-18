@isTest
private class AddMasterBudgetSheetItemControllerTest {

   @TestSetup static void makeData(){

       //Initialize Village, Marketing Campaign, Marketing Activity, Master Budget Sheet and Master Budget Sheet Item Lists
        List<Village__c> listVillages = new List<Village__c>(); 
        List<Marketing_Campaign__c> listMktCampaign = new List<Marketing_Campaign__c>();
        List<Marketing_Activity__c> listMktActivity = new List<Marketing_Activity__c>();
        List<Master_Budget_Sheet__c> listMBS = new List<Master_Budget_Sheet__c>();
        List<Master_Budget_Sheet_Item__c> listMBSI = new List<Master_Budget_Sheet_Item__c>();


        //Create a Villages
        Village__c newVillage1 = new Village__c (Name = 'Village 1', Village_Code__c = '09', CertSales_CertPeriod_Open_Days__c = 4, CertSales_Report_Sales_Grace_Period_Days__c = 6);
        listVillages.add(newVillage1);
        Village__c newVillage2 = new Village__c (Name = 'Village 2', Village_Code__c = '07', CertSales_CertPeriod_Open_Days__c = 4, CertSales_Report_Sales_Grace_Period_Days__c = 6);
        listVillages.add(newVillage2);

        //Insert Villages
        INSERT listVillages;
       
        //Create Marketing Campaigns
        Date todayDate = Date.today();
        for(Integer i = 1; i <= 4; i++){
            if(i <= 2){
                Marketing_Campaign__c newMktCampaign = new Marketing_Campaign__c (Name = 'MktCamp ' + i, Village__c = newVillage1.ID, Campaign_Level__c='Theme', Start_Date__c = todayDate, End_Date__c = todayDate);
                listMktCampaign.add(newMktCampaign);
            }
            else if(i == 3){
                Marketing_Campaign__c newMktCampaign = new Marketing_Campaign__c (Name = 'MktCamp ' + i, Village__c = newVillage2.ID, Campaign_Level__c='Theme', Start_Date__c = todayDate, End_Date__c = todayDate);
                listMktCampaign.add(newMktCampaign);
            }
            else{
                Marketing_Campaign__c newMktCampaign = new Marketing_Campaign__c (Name = 'MktCamp ' + i, Campaign_Level__c='Theme', Start_Date__c = todayDate, End_Date__c = todayDate);
                listMktCampaign.add(newMktCampaign);
            }
        }

        //Insert Marketing Campaigns
        INSERT listMktCampaign;
        
        Id mktActivityRecType = Schema.SObjectType.Marketing_Activity__c.getRecordTypeInfosByDeveloperName().get('General_Activity').getRecordTypeId();

        // Create Marketing Activities
        Marketing_Activity__c newMktActivity1 = new Marketing_Activity__c(RecordTypeId = mktActivityRecType, Name = 'MktAct 1', Marketing_Campaign__c = listMktCampaign[0].Id, Start_Date__c = todayDate, End_Date__c = todayDate);
        listMktActivity.add(newMktActivity1);
        Marketing_Activity__c newMktActivity2 = new Marketing_Activity__c(RecordTypeId = mktActivityRecType, Name = 'MktAct 2', Marketing_Campaign__c = listMktCampaign[3].Id, Start_Date__c = todayDate, End_Date__c = todayDate);
        listMktActivity.add(newMktActivity2);

        //Insert Marketing Marketing Activities
        INSERT listMktActivity;

        //Create Master Budget Sheets
        Master_Budget_Sheet__c newMbs1 = new Master_Budget_Sheet__c(Name = 'MBS 1', Month__c='June', Budget_Village__c = newVillage1.ID);
        listMBS.add(newMbs1);
         Master_Budget_Sheet__c newMbs2 = new Master_Budget_Sheet__c(Name = 'MBS 2', Month__c='June', Budget_Village__c = newVillage2.ID);
        listMBS.add(newMbs2);
         Master_Budget_Sheet__c newMbs3 = new Master_Budget_Sheet__c(Name = 'MBS 3', Month__c='June', Budget_Village__c = newVillage1.ID);
        listMBS.add(newMbs3);
         Master_Budget_Sheet__c newMbs4 = new Master_Budget_Sheet__c(Name = 'MBS 4', Month__c='June', Budget_Village__c = newVillage1.ID);
        listMBS.add(newMbs4);

        //Insert Master Budget Sheets
        INSERT listMBS;

        // Create Master Budget Sheet Items
        for(Integer j = 1; j <= 6; j++){
            if(j<=3){
                Master_Budget_Sheet_Item__c newMBSI = new Master_Budget_Sheet_Item__c(Name = 'MBSI ' + j, Master_Budget_Sheet__c = listMBS[0].Id);
                listMBSI.add(newMBSI);
            }
            else if(j == 4){
                Master_Budget_Sheet_Item__c newMBSI = new Master_Budget_Sheet_Item__c(Name = 'MBSI ' + j, Master_Budget_Sheet__c = listMBS[2].Id);
                listMBSI.add(newMBSI);
            }
            else{
                Master_Budget_Sheet_Item__c newMBSI = new Master_Budget_Sheet_Item__c(Name = 'MBSI ' + j, Master_Budget_Sheet__c = listMBS[3].Id);
                listMBSI.add(newMBSI);
            }
        }

        //Insert the Master Budget Sheet Items
        INSERT listMBSI;
   } 

    @IsTest
    static void queryMasterBudgetSheetItemsTest(){//

        //Query Data 
        Marketing_Activity__c marketingActivity = [SELECT Id, Name FROM Marketing_Activity__c WHERE Name = 'MktAct 2'];
        PageReference pg = new PageReference('/apex/AddMasterBudgetSheetItem');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);

        Test.startTest();
        AddMasterBudgetSheetItemController controller = new AddMasterBudgetSheetItemController();

        //Check if all Master Budget Sheets are queried, since there is no Village
        Integer masterBudgetSheetNumber = controller.MBSSelections.size() - 1;
        System.assertEquals(4, masterBudgetSheetNumber);

        //Select the second Item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[2].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check the number of returned Master Budget Sheet Items
        System.assertEquals(0, controller.MasterBudgetSheetItemList.size());

        //Select the third Item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[3].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check the number of returned Master Budget Sheet Items
        System.assertEquals(1, controller.MasterBudgetSheetItemList.size());

        //Select the forth Item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[4].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check the number of returned Master Budget Sheet Items
        System.assertEquals(2, controller.MasterBudgetSheetItemList.size());

        //Select the first item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[1].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check the number of returned Master Budget Sheet Items
        System.assertEquals(3, controller.MasterBudgetSheetItemList.size());

        Test.stopTest();
    }

    @IsTest
    static void checkAllTest(){

        //Query Data 
        Marketing_Activity__c marketingActivity = [SELECT Id, Name FROM Marketing_Activity__c WHERE Name = 'MktAct 1'];
        PageReference pg = new PageReference('/apex/AddMasterBudgetSheetItem');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);
        
        Test.startTest();
        AddMasterBudgetSheetItemController controller = new AddMasterBudgetSheetItemController();

        //Check if all Master Budget Sheets are queried, since there is a Village
        Integer masterBudgetSheetNumber = controller.MBSSelections.size() - 1;
        System.assertEquals(3, masterBudgetSheetNumber);

        //Select the first item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[1].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check the number of returned Master Budget Sheet Items
        System.assertEquals(3, controller.MasterBudgetSheetItemList.size());

        //Test the select all functionality
        controller.allSelected = true;
        controller.checkAll();

        controller.allSelected = false;
        controller.checkAll();
   
        Test.stopTest();
    }
    @IsTest
    static void saveTest(){
        
       //Query Data 
        Marketing_Activity__c marketingActivity = [SELECT Id, Name FROM Marketing_Activity__c WHERE Name = 'MktAct 1'];
        PageReference pg = new PageReference('/apex/AddMasterBudgetSheetItem');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);
        
        Test.startTest();
        AddMasterBudgetSheetItemController controller = new AddMasterBudgetSheetItemController();

        //Check if all Master Budget Sheets are queried, since there is a Village
        Integer masterBudgetSheetNumber = controller.MBSSelections.size() - 1;
        System.assertEquals(3, masterBudgetSheetNumber);

        //Test the save without MBS
        controller.save();

        controller = new AddMasterBudgetSheetItemController();

        //Check if all Master Budget Sheets are queried, since there is a Village
        masterBudgetSheetNumber = controller.MBSSelections.size() - 1;
        System.assertEquals(3, masterBudgetSheetNumber);

        //Select the first item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[1].getValue());
        controller.queryMasterBudgetSheetItems();

        //Test the save without MBSI
        controller.disableSave = false;
        controller.allSelected = false;
        controller.checkAll();
        controller.save();

        controller = new AddMasterBudgetSheetItemController();

        //Select the first item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[1].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check all
        controller.disableSave = false;
        controller.allSelected = true;
        controller.checkAll();

        //Test the save functionality
        controller.save();

        Test.stopTest();
    }
    @IsTest
    static void returnToPageTest(){
        //Query Data 
        Marketing_Activity__c marketingActivity = [SELECT Id, Name FROM Marketing_Activity__c WHERE Name = 'MktAct 1'];
        PageReference pg = new PageReference('/apex/AddMasterBudgetSheetItem');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);
        
        Test.startTest();
        AddMasterBudgetSheetItemController controller = new AddMasterBudgetSheetItemController();
        controller.returnToPage();

        Test.stopTest();
        
    }
    
    @IsTest
    static void checkSelectedTest(){

        //Query Data 
        Marketing_Activity__c marketingActivity = [SELECT Id, Name FROM Marketing_Activity__c WHERE Name = 'MktAct 1'];
        PageReference pg = new PageReference('/apex/AddMasterBudgetSheetItem');
        pg.getParameters().put('Id', marketingActivity.Id);
        test.setCurrentPageReference(pg);
        
        Test.startTest();
        AddMasterBudgetSheetItemController controller = new AddMasterBudgetSheetItemController();

        //Check if all Master Budget Sheets are queried, since there is a Village
        Integer masterBudgetSheetNumber = controller.MBSSelections.size() - 1;
        System.assertEquals(3, masterBudgetSheetNumber);

        //Select the first item
        controller.masterBudgetsheetValue = String.valueOf(controller.MBSSelections[1].getValue());
        controller.queryMasterBudgetSheetItems();

        //Check the number of returned Master Budget Sheet Items
        System.assertEquals(3, controller.MasterBudgetSheetItemList.size());

        //Test the checkSelected functionality with none selected
        controller.checkSelected();
        System.assertEquals(true, controller.disableSave);
        
        controller.allSelected = true;
        controller.checkAll();
        
        //Test the checkSelected functionality with all selected
        controller.checkSelected();
        System.assertEquals(false, controller.disableSave);
        
        Test.stopTest();
    }


}