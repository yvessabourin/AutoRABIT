public with sharing class CaseItemTriggerHandler {

    public static void createNewJobandBags(List<Case_Item__c> newHFSPurchase){
        List<HFS_Job__c> insertedJobs = new List<HFS_Job__c>();
        List<HFS_Bag__c> allNewBags = new List<HFS_Bag__c>();
        RecordType recordTypeNewJob = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];
        Map<String, String> mapGSARunnerLoc = new Map<String, String>();
        Decimal numberOfBags;
        Id userId = UserInfo.getUserId();
        Id runnerId;
        List<HFS_Runner__c> aRunner = [SELECT Id, user__c, user__r.Village__c, user__r.HFS_Role_and_Location__c FROM HFS_Runner__c WHERE User__c = :userId];

        
        if(!aRunner.isEmpty()){
            if(aRunner[0].user__c!=null){
                if(aRunner[0].user__r.HFS_Role_and_Location__c!=null && aRunner[0].user__r.HFS_Role_and_Location__c!=''){
                    
                    String village =  aRunner[0].user__r.Village__c;
                    String gsaLocation = '';
                    String runnerLocation = '';
                    if(aRunner[0].user__r.HFS_Role_and_Location__c.substring(aRunner[0].user__r.HFS_Role_and_Location__c.length()-1).isNumeric()){
                        gsaLocation = aRunner[0].user__r.HFS_Role_and_Location__c.remove(aRunner[0].user__r.HFS_Role_and_Location__c.substring(aRunner[0].user__r.HFS_Role_and_Location__c.length()-2));
                    }else{
                        gsaLocation = aRunner[0].user__r.HFS_Role_and_Location__c;
                    }
                    
                    System.debug('gsaLocation ' + gsaLocation);
                    List<HFS_User_Role_and_Location__mdt> lstUserLocation = [SELECT Id, GSA_Role_and_Location__c, Runner_Role_and_Location__c FROM HFS_User_Role_and_Location__mdt
                                                                             WHERE GSA_Role_and_Location__c =:gsaLocation AND Village__c =:village];
                    System.debug('lstUserLocation ' + lstUserLocation);
                    if(!lstUserLocation.isEmpty()){
                        List<HFS_Runner__c> lstRunner = [SELECT Id, user__r.HFS_Role_and_Location__c FROM HFS_Runner__c WHERE user__r.HFS_Role_and_Location__c =:lstUserLocation[0].Runner_Role_and_Location__c];
                        if(!lstRunner.isEmpty()){
                            mapGSARunnerLoc.put(aRunner[0].user__r.HFS_Role_and_Location__c, lstRunner[0].Id);
                        }
                    }
                    
                }
            }
        }
            
        for(Case_Item__c theNewPurchase : newHFSPurchase){

            HFS_Job__c newJob = new HFS_Job__c(
                HFS_Purchase__c = theNewPurchase.Id,
                RecordTypeId = recordTypeNewJob.Id,
                Job_Status__c = 'New',
                Job_Type__c = 'Original Pick-up Request'
            );

            if(theNewPurchase.Require_a_Runner__c == true){
                if(theNewPurchase.Item_Count__c != 0 && theNewPurchase.HFS_Bag_Transfer__c == false){
                    List<String> listBarcodeBags = new List<String>();
                    numberOfBags = theNewPurchase.Item_Count__c;

                    if(theNewPurchase.HFS_Bag_Drop__c == true){
                        newJob.Job_Type__c = 'Bag Drop';
                    }
                    
                    if(theNewPurchase.Bag_Barcodes_Manual__c != NULL){
                        String barcodeBags = theNewPurchase.Bag_Barcodes_Manual__c;
                        listBarcodeBags = barcodeBags.split(',');

                        //*2 because every bag needs to run twice
                        for(Integer i = 0; i < (numberOfBags*2); i=i+2){
                            HFS_Bag__c newBag = new HFS_Bag__c(
                                HFS_Purchase__c = theNewPurchase.ID,
                                Barcode__c = listBarcodeBags[i],
                                Oversized__c = Boolean.valueOf(listBarcodeBags[i+1]),
                                Status__c = 'Awaiting Pick-up'
                            );
                            if(theNewPurchase.HFS_Bag_Drop__c == true){
                                newBag.Status__c = 'Bag Dropped';
                            }
                            allNewBags.add(newBag);
                        }
                    }

                    insertedJobs.add(newJob);

                } else if(theNewPurchase.HFS_Bag_Transfer__c == true){
                    newJob.Job_Type__c = 'Bag Transfer';
                    insertedJobs.add(newJob);
                }
            } else {
                if(theNewPurchase.Item_Count__c != 0 && theNewPurchase.HFS_Bag_Transfer__c == false){
                    List<String> listBarcodeBags = new List<String>();
                    numberOfBags = theNewPurchase.Item_Count__c;

                    if(theNewPurchase.HFS_Bag_Drop__c == true){
                        newJob.Job_Type__c = 'Bag Drop';
                    }

                    if(!aRunner.isEmpty()){
                        for(HFS_Runner__c theRunner : aRunner){
                            
                            if(mapGSARunnerLoc.containsKey(theRunner.user__r.HFS_Role_and_Location__c)){
                                newJob.HFS_Runner__c = mapGSARunnerLoc.get(theRunner.user__r.HFS_Role_and_Location__c);
                                runnerId = mapGSARunnerLoc.get(theRunner.user__r.HFS_Role_and_Location__c);
                            }else{
                                newJob.HFS_Runner__c = theRunner.Id;
                                runnerId = theRunner.Id;
                            }
                            
                            newJob.Job_Status__c = 'Delivered';
                            insertedJobs.add(newJob);
                            
                        }
                    }
                    
                    if(theNewPurchase.Bag_Barcodes_Manual__c != null){
                        String barcodeBags = theNewPurchase.Bag_Barcodes_Manual__c;
                        listBarcodeBags = barcodeBags.split(',');
                    
                        //*2 because every bag needs to run twice
                        for(Integer i = 0; i < (numberOfBags*2); i=i+2){
                            HFS_Bag__c newBag = new HFS_Bag__c(
                                HFS_Purchase__c = theNewPurchase.ID,
                                Barcode__c = listBarcodeBags[i],
                                Oversized__c = Boolean.valueOf(listBarcodeBags[i+1]),
                                HFS_Runner__c = runnerId,
                                Status__c = 'Putaway'
                            );
                            allNewBags.add(newBag);
                        }
                    }
                }
            }
        }
        
        insert insertedJobs;
        insert allNewBags;

    }
}