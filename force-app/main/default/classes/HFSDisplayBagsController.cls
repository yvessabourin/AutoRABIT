public with sharing class HFSDisplayBagsController{

    public List<HFS_Bag__c> allJobBags { get; set; }
    public Id jobId { get; set; }
    public String barcodeBag { get; set; }
    public Boolean stopLoopBags { get; set; }
    public Boolean alreadyExist { get; set; }
    public Boolean assignedJob {get;set;}

    public HFSDisplayBagsController(ApexPages.StandardController stdController) {
        assignedJob = true;
        Id profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: profileId];
        jobId = ApexPages.CurrentPage().getParameters().get('Id');
        barcodeBag = ApexPages.CurrentPage().getParameters().get('barcodeBag');
        HFS_Job__c currenctJob = [SELECT Id, Assigned_to_me__c FROM HFS_Job__c WHERE Id =: jobId];
        if(currenctJob.Assigned_to_me__c == false && profile.Name == 'HFS Runner'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This job is already assigned to another runner'));
            assignedJob = false;
            }else{
                getBags(jobId);
            }
    }

    public List<HFS_Bag__c> getBags (Id jobId){
        HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, Job_Status__c, Guest_ID_Code__c,Pickup_Location__c  FROM HFS_Job__c WHERE Id= :jobId];
        system.debug(getCurrentJob.Id);
        Case_Item__c getRelatedPurchase = [SELECT Id, HFS_Bag_Transfer__c, Service_Guest_Number__c FROM Case_Item__c WHERE Id = :getCurrentJob.HFS_Purchase__c];
        if(getRelatedPurchase.HFS_Bag_Transfer__c == TRUE){
            List<Case_Item__c> getAllGuestPurchases = [SELECT Id FROM Case_Item__c WHERE Service_Guest_Number__c = :getRelatedPurchase.Service_Guest_Number__c AND Case__r.Service_Date__c = TODAY];
            string str = '%'+getCurrentJob.Pickup_Location__c+'%';
            allJobBags = [SELECT Id, Name, Scanned__c, Barcode__c,HFS_Storage_Location__c, HFS_Runner__c, HFS_Job__c FROM HFS_Bag__c WHERE HFS_Purchase__c = :getAllGuestPurchases AND (HFS_Job__r.Job_Type__c != 'Bag Transfer' OR HFS_Job__c =: getCurrentJob.Id OR HFS_Job__r.Job_Type__c = 'Bag Transfer' ) AND HFS_Bag_Active__c = true AND HFS_Storage_Location__r.HFS_Storage_Point__r.For_Collection_Point__c LIKE : str ORDER BY Name];
        }else{
            allJobBags = [SELECT Id, Name, Scanned__c, Barcode__c,HFS_Storage_Location__c, HFS_Runner__c, HFS_Job__c, HFS_Bag_Active__c FROM HFS_Bag__c WHERE HFS_Purchase__c =: getCurrentJob.HFS_Purchase__c AND (HFS_Job__c = NULL OR HFS_Job__c =: getCurrentJob.Id) AND HFS_Bag_Active__c = true ORDER BY Name];
        }

        return allJobBags;
    }

    public PageReference finishJob(){
        
        Apexpages.Message informNotProceed = new Apexpages.Message(Apexpages.Severity.Error, 'You need to scan a minimum of one bag prior to clicking the Deliver button.');
        Integer countingScanned = 0;
        for(HFS_Bag__c theBag : allJobBags){
            if(theBag.Scanned__c == true){
                countingScanned ++;
            }
        }

        if(countingScanned >= 1){
            HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, Job_Status__c, Total_Bags__c, Bags_collected__c, Job_Type__c FROM HFS_Job__c WHERE Id= :jobId];
            Case_Item__c getPurchaseRollUps = [SELECT Id, Total_Bags__c, Scanned_Bags__c FROM Case_Item__c WHERE ID =: getCurrentJob.HFS_Purchase__c];
            system.debug(getPurchaseRollUps.Id);
            List<HFS_Job__c> updatedJobs = new List<HFS_Job__c>();

            RecordType recordTypeNewJob = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Job__c cloneJob = new HFS_Job__c(
                RecordTypeId = recordTypeNewJob.Id,
                HFS_Purchase__c = getCurrentJob.HFS_Purchase__c,
                Job_Status__c = 'New',
                Job_Type__c = 'Leftover Pick-up Request'
            );

                // re insert Bag transfer job types once Bag count issue is resolved
                if(getCurrentJob.Total_Bags__c != getCurrentJob.Bags_collected__c && getCurrentJob.Job_Type__c != 'Bag Transfer'){

                    List<HFS_Job__c> getAllRelatedRNAJobs = [SELECT Id, Name, HFS_Purchase__c, Job_Status__c FROM HFS_Job__c
                                                            WHERE HFS_Purchase__c =: getPurchaseRollUps.Id
                                                            AND (Job_Status__c = 'Accepted'
                                                            OR Job_Status__c = 'Rejected'
                                                            OR Job_Status__c = 'New')
                                                            AND Id != :getCurrentJob.Id];

                    system.debug('JOBS: ' + getAllRelatedRNAJobs);

                    if(!getAllRelatedRNAJobs.isEmpty()){
                        for(HFS_Job__c jobToChange : getAllRelatedRNAJobs){
                            if(jobToChange.Job_Status__c != 'Accepted'){
                                if(getCurrentJob.Job_Type__c == 'Bag Transfer'){
                                    jobToChange.Job_Type__c = 'Bag Transfer';
                                } else if(getCurrentJob.Job_Type__c == 'Bag Drop'){
                                    jobToChange.Job_Type__c = 'Bag Drop';
                                } else {
                                    jobToChange.Job_Type__c = 'Leftover Pick-up Request';
                                }
                                updatedJobs.add(jobToChange);
                            }
                        }
                        getCurrentJob.Job_Status__c = 'Delivering';
                        update getCurrentJob;
                        system.debug('theJob: ' + getCurrentJob);
                        update updatedJobs;
                    } else{
                        if(getCurrentJob.Job_Type__c == 'Bag Transfer'){
                            cloneJob.Job_Type__c = 'Bag Transfer';
                        } else if(getCurrentJob.Job_Type__c == 'Bag Drop'){
                            cloneJob.Job_Type__c = 'Bag Drop';    
                        } else {
                            getCurrentJob.Job_Type__c = 'Shared Pick-up Request';
                        }
                        getCurrentJob.Job_Status__c = 'Delivering';
                        system.debug('theJob: ' + getCurrentJob);
                        update getCurrentJob;
                        insert cloneJob;
                        system.debug(getCurrentJob.Job_Status__c);
                        system.debug(getCurrentJob.RecordTypeId);
                    }

                } else {
                    getCurrentJob.Job_Status__c = 'Delivering';
                    update getCurrentJob;
                }

            PageReference goToRecord = new PageReference('/' + jobId);
            return goToRecord;

        } else {
            ApexPages.addMessage(informNotProceed);
            return null;
        }
    }

    public PageReference scanBag(){

        PageReference goToBarcodeScan = new PageReference('/apex/HFSDisplayBagsScan');
        return goToBarcodeScan;
    }

    public void updateBags(){
        stopLoopBags = true;
        Apexpages.Message informBagNotMatch = new Apexpages.Message(Apexpages.Severity.Error, 'This bag: ' + barcodeBag + ' does not correspond to this Purchase or it is already in use. Please scan another one.');
        Apexpages.Message informBagAlreadyScanned = new Apexpages.Message(Apexpages.Severity.Info, 'This bag: ' + barcodeBag + ' was already scanned.');
        String userId = UserInfo.getUserId();
        HFS_Runner__c runners = [SELECT Id, User__c FROM HFS_Runner__c WHERE User__c = :userId];
        List<HFS_Bag__c> currentUpdatedBag = new List<HFS_Bag__c>();

        if(barcodeBag != null){
            alreadyExist = verifyEquals(barcodeBag);
            for(HFS_Bag__c currentBag : allJobBags){
                if(stopLoopBags){
                    if(currentBag.Barcode__c == barcodeBag && currentBag.Scanned__c == false){
                        currentBag.Scanned__c = true;
                        currentBag.Status__c = 'In Transit';
                        currentBag.HFS_Runner__c = runners.Id;
                        currentBag.HFS_Job__c = jobId;
                        currentBag.In_Storage_Point__c = false;
                        currentBag.HFS_Storage_Location__c = null;
                        currentUpdatedBag.add(currentBag);
                        stopLoopBags = false;
                    } else if (currentBag.Barcode__c == barcodeBag && currentBag.Scanned__c == true){
                        ApexPages.addMessage(informBagAlreadyScanned);
                        stopLoopBags = false;
                    }
                }
            }

            if(currentUpdatedBag.isEmpty() && alreadyExist == false){
                for(HFS_Bag__c currentBag : allJobBags){
                    if(stopLoopBags){
                        if(currentBag.Barcode__c == 'TBC'){
                            currentBag.Scanned__c = true;
                            currentBag.Status__c = 'In Transit';
                            currentBag.HFS_Runner__c = runners.Id;
                            currentBag.HFS_Job__c = jobId;
                            currentBag.In_Storage_Point__c = false;
                            currentBag.HFS_Storage_Location__c = null;
                            currentBag.Barcode__c = barcodeBag;
                            currentUpdatedBag.add(currentBag);
                            stopLoopBags = false;
                        }
                    }
                }
            }

            update currentUpdatedBag;

            // If the Bag does not correspond to a Bag's purchase.
            if(stopLoopBags == true){
                ApexPages.addMessage(informBagNotMatch);
            }
        }
    }

    public Boolean verifyEquals(String currentBarcode){
        Boolean getValue = false;
        //List<HFS_Bag__c> listHFSBags = [SELECT Barcode__c FROM HFS_Bag__c WHERE HFS_Bag_Active__c = true];     
        List<HFS_Bag__c> listHFSBags = [SELECT Barcode__c FROM HFS_Bag__c WHERE HFS_Bag_Active__c = true and Barcode__c =: currentBarcode ];
        
        IF(listHFSBags.size() > 0 || listHFSBags != NULL ){
        
            for(HFS_Bag__c theBag : listHFSBags){
                if(theBag.Barcode__c == barcodeBag){
                    getValue = true;
                }
            }
            
        }    
        return getValue;
    }
}