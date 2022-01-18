global with sharing class HFSDeliverToGuestController{

    public List<HFS_Bag__c> allJobBags { get; set; }
    public integer allJobBagsSize {get;set;}
    public Decimal currentScanCount {get;set;}
    public Id jobId { get; set; }
    public String barcodeBag { get; set; }
    public String barcodeBagQH { get; set; }
    public Boolean stopLoopBags { get; set; }
    public Boolean alreadyExist { get; set; }
    public Boolean assignedJob {get;set;}
    public Boolean allJobBagsScanned {get;set;}
    Static Boolean VarConfPutaway {get;set;}
    public Boolean isBagDropJob {get;set;}
   
    public HFSDeliverToGuestController(ApexPages.StandardController stdController) {
        
        VarConfPutaway = false;
        allJobBagsSize = 0;
        assignedJob = true;
        Id profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: profileId];
        jobId = ApexPages.CurrentPage().getParameters().get('Id');
        barcodeBagQH = ApexPages.CurrentPage().getParameters().get('barcodeBagQH');
        HFS_Job__c currenctJob = [SELECT Id,HFS_Purchase__r.Scanned_for_Quick_Handover_Count__c, Assigned_to_me__c,Job_Type__c FROM HFS_Job__c WHERE Id =: jobId];
        
        if(currenctJob.Job_Type__c == 'Bag Drop'){
            isBagDropJob = true;
        }
        
        currentScanCount = currenctJob.HFS_Purchase__r.Scanned_for_Quick_Handover_Count__c;
        if(currenctJob.Assigned_to_me__c == false && profile.Name == 'HFS Runner'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This job is already assigned to another runner'));
            assignedJob = false;
            }else{
                getBags(jobId);
            }
    }

    public List<HFS_Bag__c> getBags (Id jobId){
        HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, Job_Status__c, Guest_ID_Code__c,Pickup_Location__c FROM HFS_Job__c WHERE Id= :jobId];
        system.debug(getCurrentJob.Id);
        Case_Item__c getRelatedPurchase = [SELECT Id, HFS_Bag_Transfer__c, Service_Guest_Number__c FROM Case_Item__c WHERE Id = :getCurrentJob.HFS_Purchase__c];
        if(getRelatedPurchase.HFS_Bag_Transfer__c == TRUE){
            List<Case_Item__c> getAllGuestPurchases = [SELECT Id FROM Case_Item__c WHERE Service_Guest_Number__c = :getRelatedPurchase.Service_Guest_Number__c AND Case__r.Service_Date__c = TODAY];
            string str = '%'+getCurrentJob.Pickup_Location__c+'%';
            allJobBags = [SELECT Id, Name, Scanned_for_Quick_Handover__c,Scanned__c, Barcode__c,HFS_Storage_Location__c, HFS_Runner__c, HFS_Job__c FROM HFS_Bag__c WHERE HFS_Purchase__c = :getAllGuestPurchases AND (HFS_Job__r.Job_Type__c != 'Bag Transfer' OR HFS_Job__c =: getCurrentJob.Id OR HFS_Job__r.Job_Type__c = 'Bag Transfer' ) AND HFS_Bag_Active__c = true AND HFS_Storage_Location__r.HFS_Storage_Point__r.For_Collection_Point__c LIKE : str AND Status__c = 'In Transit'  ORDER BY Name];
            allJobBagsSize = allJobBags.size();
        }else{
            allJobBags = [SELECT Id, Name, Scanned_for_Quick_Handover__c,Scanned__c, Barcode__c,HFS_Storage_Location__c, HFS_Runner__c, HFS_Job__c, HFS_Bag_Active__c FROM HFS_Bag__c WHERE HFS_Purchase__c =: getCurrentJob.HFS_Purchase__c AND (HFS_Job__c = NULL OR HFS_Job__c =: getCurrentJob.Id) AND HFS_Bag_Active__c = true  AND Status__c = 'In Transit' ORDER BY Name];
            allJobBagsSize = allJobBags.size();
        }

        return allJobBags;
    }

    public PageReference scanBag(){
        PageReference goToBarcodeScan = new PageReference('/apex/HFSDisplayBagsScanQH');

        if (UserInfo.getUiThemeDisplayed().equals('Theme4d') || UserInfo.getUiThemeDisplayed().equals('Theme4t') || UserInfo.getUiThemeDisplayed().equals('Theme4u')) {
            aura.redirect(goToBarcodeScan);
        }

        return goToBarcodeScan;
    }

    public void updateBags(){
        
        stopLoopBags = true;
        Apexpages.Message informBagNotMatch = new Apexpages.Message(Apexpages.Severity.Error, 'This bag: ' + barcodeBagQH + ' does not correspond to this Purchase or it is already in use. Please scan another one.');
        Apexpages.Message informBagAlreadyScanned = new Apexpages.Message(Apexpages.Severity.Info, 'This bag: ' + barcodeBagQH + ' was already scanned.');
        String userId = UserInfo.getUserId();
        //HFS_Runner__c runners = [SELECT Id, User__c FROM HFS_Runner__c WHERE User__c = :userId];
        List<HFS_Bag__c> currentUpdatedBag = new List<HFS_Bag__c>();
       

        if(barcodeBagQH != null){
           // alreadyExist = verifyEquals(barcodeBagQH);
            for(HFS_Bag__c currentBag : allJobBags){
                if(stopLoopBags){
                    if(currentBag.Barcode__c == barcodeBagQH && currentBag.Scanned_for_Quick_Handover__c == false){
                        currentBag.Scanned_for_Quick_Handover__c = true;
                //        currentBag.Status__c = 'In Transit';
                //        currentBag.HFS_Runner__c = runners.Id;
                //        currentBag.HFS_Job__c = jobId;
                //        currentBag.In_Storage_Point__c = false;
                 //       currentBag.HFS_Storage_Location__c = null;
                        currentUpdatedBag.add(currentBag);
                        stopLoopBags = false;
                    } else if (currentBag.Barcode__c == barcodeBagQH && currentBag.Scanned_for_Quick_Handover__c == true){
                        ApexPages.addMessage(informBagAlreadyScanned);
                        stopLoopBags = false;
                    }
                }
            }

            update currentUpdatedBag;
            
            HFS_Job__c theCurrentJob = [SELECT Id,HFS_Purchase__r.Scanned_for_Quick_Handover_Count__c,  HFS_Purchase__c, Job_Status__c, Guest_ID_Code__c,Pickup_Location__c FROM HFS_Job__c WHERE Id= :jobId];
            
            currentScanCount = theCurrentJob.HFS_Purchase__r.Scanned_for_Quick_Handover_Count__c;

            // If the Bag does not correspond to a Bag's purchase.
            if(stopLoopBags == true){
                ApexPages.addMessage(informBagNotMatch);
            }
        }
    }

    public Boolean verifyEquals(String currentBarcode){
        Boolean getValue = false;
        List<HFS_Bag__c> listHFSBags = [SELECT Barcode__c FROM HFS_Bag__c WHERE HFS_Bag_Active__c = true];
        for(HFS_Bag__c theBag : listHFSBags){
            if(theBag.Barcode__c == barcodeBagQH){
                getValue = true;
            }
        }
        return getValue;
    }
    
    @RemoteAction
    global static String handOvertoGuest(id jobId){
        system.debug('handOvertoGuest called 1');
        HFS_Job__c theCurrentJob = [SELECT Id,HFS_Purchase__r.Status__c,  HFS_Purchase__c, Job_Status__c, Guest_ID_Code__c,Pickup_Location__c FROM HFS_Job__c WHERE Id= :jobId];
        list<HFS_Bag__c> bags = [SELECT id,Status__c,In_Storage_Point__c,Scanned_for_collection__c FROM HFS_Bag__c WHERE HFS_Purchase__c =: theCurrentJob.HFS_Purchase__c AND Scanned_for_Quick_Handover__c = TRUE];
            for(HFS_Bag__c bag : bags){
                bag.Status__c = 'Bag with GSA';
                bag.In_Storage_Point__c = true;
                bag.Scanned_for_collection__c = true;
            }
        
        theCurrentJob.Job_Status__c = 'Bags with GSA';
        
        try{
            update theCurrentJob;
            update bags;
            VarConfPutaway = false;
            return 'Success - You have successfully updated this job';
        }
        catch (exception e){
            return 'Error - an error has occurred, please contact your Administrator with this error code - ' + e.getmessage();            
        }      
    }
    
    public PageReference CurrentJob(){       
        ListView currentList = [SELECT Id FROM ListView WHERE DeveloperName = 'My_Current_Jobs' AND SobjectType = 'HFS_Job__c'];    
        string listViewId = currentList.Id;
        PageReference goToCurrentJob = new PageReference('/a1L?fcf=' + listViewId.left(15));
        return goToCurrentJob;
    }

    public PageReference AssignedJob(){    
        ListView assignedList = [SELECT Id FROM ListView WHERE DeveloperName = 'Assigned_Jobs' AND SobjectType = 'HFS_Job__c'];  
        string listViewId = assignedList.Id;
        PageReference goToAssignedJob = new PageReference('/a1L?fcf=' + listViewId.left(15));
        return goToAssignedJob;
   }


     public PageReference AvailableJob(){
        ListView availableList = [SELECT Id FROM ListView WHERE DeveloperName = 'Available_Jobs' AND SobjectType = 'HFS_Job__c'];    
        string listViewId = availableList.Id;
        PageReference goToAvailableJob = new PageReference('/a1L?fcf=' + listViewId.left(15));
        return goToAvailableJob;
    }
    
}