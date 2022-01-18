trigger DailySaleTrigger on Daily_Sale__c (after insert, after update, before update) {
    
    id jobID;
    integer chunkSize = 60; // max set size to pass to queueable job to make read lease id callouts
    
    ///list to use for apex validation method calls
    list<Daily_Sale__c> validationList = new list<Daily_Sale__c>();
    
    
    // ***    After Insert ... ***//
    if (trigger.isInsert && trigger.isAfter){
        DailySaleTriggerHelper.ProcessShares(trigger.new, trigger.newMap.keySet());
        
        if (test.isRunningTest())
            chunkSize = 5;
         
        //Invoke async queuable job to retrieve Lease Id from api service
        if (trigger.newMap.keySet().size() < chunkSize){
             jobID = System.enqueueJob(new DailySaleTriggerHelper(trigger.newMap.keySet()));
        } else { //if more than 60 (chunkSize) inserts, split all inserts into smaller lists(of max size 60 (chunkSize)) and invoke job for each list
                 // This is to ensure callout governor limit is not breached
            list<set<Id>> batchList = new list<set<id>>();
            list<Id> keysetList = new list<Id>();
            keysetList.addAll(trigger.newMap.keySet());
            for(Integer i = 0 ; i < (keysetList.size()  / chunkSize)+1 ; i++){
                set<Id> chunkSet = new set<Id>();
                for(Integer j=(i*chunkSize);(j<(i*chunkSize)+chunkSize) && j< keysetList.size() ; j++){
                    chunkSet.add(keysetList.get(j));
                }
                batchList.add(chunkSet);
            }
            if (batchList.size() > 0){
                for(set<Id> dsIds :batchList){
                    if (!test.isRunningTest()) //(more than one queued job, doesn't work when called from test class)
                        jobID = System.enqueueJob(new DailySaleTriggerHelper(dsIds));
                }
            }
        }
    }
    
    /*******************************/
    
    // ***    Before Update ... ***//

    if (trigger.isUpdate && trigger.isBefore){
        for(Daily_Sale__c ds : trigger.new) {
            if(trigger.oldMap.get(ds.Id).Brand_Status__c != ds.Brand_Status__c) {//brand status update
                if (ds.Brand_Status__c == 'Confirmed'){
                    validationList.add(ds);
                }
            }
        }
        
        if (!validationList.isEmpty()){
            DailySalesValidations.checkConfirmUser(validationList);
            
        }
    }    
    
    
     /*******************************/
    
    // ***    After Update ... ***//
    if (trigger.isUpdate && trigger.isAfter){
        map<Id, Daily_sale__c> dsStatusUpdateMap = new map<Id, Daily_Sale__c>();
        map<Id, Daily_sale__c> dsLeaseIdUpdateMap = new map<Id, Daily_Sale__c>();
        List<Daily_Sale__c> dsCertificationBatchUpdateList = new List<Daily_Sale__c>();
        
        // check if update is changing the daily sales status
        for(Daily_Sale__c ds : trigger.new)
        {
            if(trigger.oldMap.get(ds.Id).Status__c != ds.Status__c) {//status update
                dsStatusUpdateMap.put(ds.Id, ds);
            }
            if(string.isBlank(ds.Integration_Message__c) && string.isBlank(ds.Lease_ID__c) ) {//blank lease Id
                dsLeaseIdUpdateMap.put(ds.Id, ds);
            }

            if(trigger.oldMap.get(ds.Id).Certification_Batch__c != ds.Certification_Batch__c){
                if(ds.Certification_Batch__c == null){
                    dsCertificationBatchUpdateList.add(trigger.oldMap.get(ds.Id));
                } else {
                    dsCertificationBatchUpdateList.add(ds);
                }
            }
        }
        if (!dsStatusUpdateMap.isEmpty()){
            DailySaleTriggerHelper.ProcessShares(dsStatusUpdateMap.values(), dsStatusUpdateMap.keySet());
        }
        
        if (!dsLeaseIdUpdateMap.isEmpty()){
            system.debug('@@@@ dsLeaseIdUpdateMap.size ... ' + dsLeaseIdUpdateMap.size());
            
            if (test.isRunningTest())
                chunkSize = 5;
            
            //Invoke async queuable job to retrieve Lease Id from api service
            if (dsLeaseIdUpdateMap.keySet().size() < chunkSize){
                 jobID = System.enqueueJob(new DailySaleTriggerHelper(dsLeaseIdUpdateMap.keySet()));
            } else { //if more than 60 (chunkSize) updates, split all updates into smaller lists(of max size 60 (chunkSize)) and invoke job for each list
                     // This is to ensure callout governor limit is not breached
                list<set<Id>> batchList = new list<set<id>>();
                list<Id> keysetList = new list<Id>();
                keysetList.addAll(dsLeaseIdUpdateMap.keySet());
                for(Integer i = 0 ; i < (keysetList.size()  / chunkSize)+1 ; i++){
                    set<Id> chunkSet = new set<Id>();
                    for(Integer j=(i*chunkSize);(j<(i*chunkSize)+chunkSize) && j< keysetList.size() ; j++){
                        chunkSet.add(keysetList.get(j));
                    }
                    batchList.add(chunkSet);
                }
                if (batchList.size() > 0){
                    for(set<Id> dsIds :batchList){
                        system.debug('@@@@ chunk .. dsIds.size ... ' + dsIds.size());
                        if (!test.isRunningTest()) //(more than one queued job, doesn't work when called from test class)
                            jobID = System.enqueueJob(new DailySaleTriggerHelper(dsIds));
                    }
                }
            }
        }

        if(!dsCertificationBatchUpdateList.isEmpty()){
            CalculationOfAmounts.changesAmounts(dsCertificationBatchUpdateList);
        }
    }
    /*******************************/
}