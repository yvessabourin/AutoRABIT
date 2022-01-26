public with sharing class HFSQuickBagPutawayController {

  public List<HFS_Bag__c> allJobBags { get; set; }
  public List<HFS_Bag__c> theBag { get; set; }
  public Map<String, Integer> allBagStorage { get; set; }
  public Id jobId { get; set; }
  public string bagId { get; set; }
  public String qrCodeLocation { get; set; }
  public String getLocationName { get; set; }
  public String getLocationId { get; set; }
  public String barcodeBag { get; set; }
  public Boolean stopLoopBags { get; set; }
  public Boolean displayPopUp { get; set; }
  public Boolean differentLocations{get;set;}
  public Integer countAllJobBagsInStorage { get; set; }
  public Integer count { get; set; }
  public HFS_Job__c CurrentJob {get;set;}
  public String currentStoragePoint{get;set;}
  public String guestCollectionPoint{get;set;}
  public Boolean VarConfPutaway {get;set;}
  public HFS_Job__c getAvailableJob;
    
    
  public HFSQuickBagPutawayController() {

    bagId = ApexPages.CurrentPage().getParameters().get('bagId');
    qrCodeLocation = ApexPages.CurrentPage().getParameters().get('qrCodeLocation');
    getLocationId = ApexPages.CurrentPage().getParameters().get('StorageLocation');
    barcodeBag = ApexPages.CurrentPage().getParameters().get('barcodeBag');
    system.debug('getLocationId cont ' + getLocationId );
    
    theBag = [SELECT id, name,HFS_Job__c,HFS_Runner__c FROM HFS_Bag__c WHERE Barcode__c =: bagId AND In_Storage_Point__c = false AND HFS_Purchase__r.Start_Time__c = TODAY];
    system.debug('theBag cont ' + theBag );
      if(theBag.size() > 0 && theBag != NULL){
        
        if(theBag[0].HFS_Runner__c == NULL){
          Apexpages.Message errorMessage = new Apexpages.Message(Apexpages.Severity.Error, 'This bag\'s Job needs to be assigned to a runner before it can be \"Quick Putaway\" ');
          Apexpages.addMessage(errorMessage);        
        }
        else{  
          CurrentJob = [SELECT Id,name,HFS_Guest_Collection_Point__c,Guest_ID_Code__c, Assigned_to_me__c FROM HFS_Job__c WHERE Id =: theBag[0].HFS_Job__c];
          system.debug('CurrentJob ' + CurrentJob );
          if(CurrentJob != NULL){
            
          jobId = theBag[0].HFS_Job__c;    
          system.debug('jobId ' + jobId );
        
          allBagStorage = getAllStorage(jobId);
        
          allJobBags = [SELECT Id, Name, In_Storage_Point__c, HFS_Runner__c, Barcode__c FROM HFS_Bag__c WHERE HFS_Job__c =: jobId AND Barcode__c =: bagId ];
          system.debug('alljobBags construcotr --- ' + alljobBags);
          
          List<HFS_Bag__c> allPurchaseBags = [SELECT Id, Guest_ID_Code__c, HFS_Storage_Location__c, HFS_Storage_Location__r.Name FROM HFS_Bag__c WHERE Guest_ID_Code__c =: CurrentJob.Guest_ID_Code__c AND HFS_Purchase__r.Start_Time__c = TODAY];
      
            if(qrCodeLocation == null && getLocationId == null){
              for(HFS_Bag__c eachBag : allPurchaseBags){
                if(eachBag.HFS_Storage_Location__c != null){
                  getLocationName = eachBag.HFS_Storage_Location__r.Name;
                  getLocationId = eachBag.HFS_Storage_Location__c;
                }
              }
            }
          
          initialActionStorageLocation();
            
          }
        }
  
      }
      else{
        Apexpages.Message errorMessage = new Apexpages.Message(Apexpages.Severity.Error, 'This bag is either already checked in or is not valid for todays experiences');
        Apexpages.addMessage(errorMessage);      
      }
    
    }

  public void initialActionStorageLocation(){
      List<HFS_Storage_Location__c> storageLocation = [SELECT Id, Name, QR_Code_hidden__c, HFS_Storage_Point__r.Name FROM HFS_Storage_Location__c];
      system.debug('storageLocation ' + storageLocation );
      //Apexpages.Message informAssignStorageLocation = new Apexpages.Message(Apexpages.Severity.Error, 'You need to Assign a Storage Location');

      system.debug(getLocationId);
    if(jobId != null && qrCodeLocation != null){
        for(HFS_Storage_Location__c correspondentSL : storageLocation){
          if(correspondentSL.QR_Code_hidden__c == qrCodeLocation){
            getLocationName = correspondentSL.Name;
            Apexpages.Message informLocation = new Apexpages.Message(Apexpages.Severity.Info, 'At this point you can put the bags on: ' + getLocationName + ' without scanning Storage Location. Now Scan the Bag');
          Apexpages.addMessage(informLocation);
            currentStoragePoint = correspondentSL.HFS_Storage_Point__r.Name;
            guestCollectionPoint = CurrentJob.HFS_Guest_Collection_Point__c;
            if(!currentStoragePoint.equals(guestCollectionPoint)){
              differentLocations = true;
          }
            getLocationId = correspondentSL.Id;
          }
        }
      } else if(getLocationId != null){
        for(HFS_Storage_Location__c correspondentSL : storageLocation){
          if(correspondentSL.Id == getLocationId){
            getLocationName = correspondentSL.Name;
          }
        }
      }
  }



    public PageReference scanLocationCode(){    
      PageReference goToBQrcodeScan = new PageReference('/apex/HFSQuickDeliveryPageScanStorage?Id=' + jobId + '&bagId=' + bagId);
        return goToBQrcodeScan;
    }

    public PageReference scanBagsCode(){
      PageReference goToBarcodeScan = new PageReference('/apex/HFSQuickDeliveryPageScanBags?Id=' + jobId + '&StorageLocation=' + getLocationId);
      return goToBarcodeScan;
    }


 //-----------------------------------------------------------------------

  public PageReference updateRecords(){
    Apexpages.Message informBagNotMatch = new Apexpages.Message(Apexpages.Severity.Error, 'This is bag ' + barcodeBag + ' does not correspond to this Job.');
    stopLoopBags = true;
    countAllJobBagsInStorage = 0;
    List<HFS_Bag__c> updatedBag = new List<HFS_Bag__c>();

    if(barcodeBag != null && getLocationId != null){
      system.debug('barcode & locationid -- ' + barcodeBag + ' ---- ' + getLocationId + ' ---- ' + allJobBags );
      for(HFS_Bag__c bag : allJobBags){
        if(stopLoopBags){
          if(bag.Barcode__c == barcodeBag){
            bag.In_Storage_Point__c = true;
            bag.HFS_Storage_Location__c = getLocationId;
            bag.Scanned__c = false;
            bag.Status__c = 'Putaway';
            updatedBag.add(bag);
            stopLoopBags = false;
          }
        }
        if(bag.In_Storage_Point__c == true){
          countAllJobBagsInStorage ++;
        }
      }
      update updatedBag;

      if(stopLoopBags == true){
        ApexPages.addMessage(informBagNotMatch);
      }
      
      
      list<HFS_Bag__c> alltheJobBags = [SELECT Id, Name, In_Storage_Point__c, HFS_Runner__c, Barcode__c FROM HFS_Bag__c WHERE HFS_Job__c =: jobId];
      list<HFS_Bag__c> BagsinStorage = new list<HFS_Bag__c>();
      for(HFS_Bag__c bag : alltheJobBags ){
        if(bag.In_Storage_Point__c){
          BagsinStorage.add(bag);
        }
      }
      
      if(alltheJobBags.size() == BagsinStorage.size()){
        HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, HFS_Purchase__r.Status__c, Job_Status__c, HFS_Guest_Collection_Point__c FROM HFS_Job__c WHERE Id=: jobId];
        RecordType Delivered_JobsRT = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'HFS_Job__c' AND Name = 'Delivered Jobs' ];
        getCurrentJob.Job_Status__c = 'Bags Putaway';
        getCurrentJob.HFS_Purchase__r.Status__c = 'Ready for Guest Collection';
        getCurrentJob.recordtypeid = Delivered_JobsRT.id;  
        update getCurrentJob.HFS_Purchase__r;
        update getCurrentJob;
                VarConfPutaway = true;
        //return null;
         
        PageReference goToScan = new PageReference('/apex/QuickBagPutawayScan');
        return goToScan;
            
      }
      
      PageReference goToScan = new PageReference('/apex/QuickBagPutawayScan');
    return goToScan;   
      
    }

    //allBagStorage = getAllStorage(jobId);  
    return null;
  }


 //-----------------------------------------------------------------------


  public Map<String, Integer> getAllStorage(ID jobId){
    allBagStorage = new Map<String, Integer>();
    HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, Job_Status__c, HFS_Guest_Collection_Point__c, Guest_ID_Code__c FROM HFS_Job__c WHERE Id=: jobId];

    set<HFS_Bag__c> allstorage = new Set<HFS_Bag__c>([SELECT Id, HFS_Storage_Location__c, HFS_Storage_Location__r.Name FROM HFS_Bag__c WHERE Guest_ID_Code__c =: CurrentJob.Guest_ID_Code__c AND HFS_Purchase__r.Start_Time__c = TODAY AND HFS_Storage_Location__c != NULL AND Storage_Matches_Guest_Collection_Point__c = true ]);
    system.debug('all storage ' + allstorage );

    Map<String, Integer> storageLocationName = new Map<String, Integer>();

    count = 0;

    if(!allstorage.isEmpty()){
      for(HFS_Bag__c aBag : allstorage){
        if(storageLocationName.containsKey(aBag.HFS_Storage_Location__r.Name)){
          count = storageLocationName.get(aBag.HFS_Storage_Location__r.Name) + 1;
          storageLocationName.put(aBag.HFS_Storage_Location__r.Name, count);
        } else {
        storageLocationName.put(aBag.HFS_Storage_Location__r.Name,1);
        }
      }
    }
    
    return storageLocationName;
  }

  public PageReference resetLocation(){
   // PageReference detailPage = new PageReference('/' + getCurrentJob.Id);
    return null;
  }


  public PageReference CurrentJob(){      
        ListView currentList = [SELECT Id FROM ListView WHERE DeveloperName = 'My_Current_Jobs' AND SobjectType = 'HFS_Job__c'];   
        PageReference goToCurrentJob = new PageReference('/a1L?fcf=' + currentList.Id);
        return goToCurrentJob;
    }
}