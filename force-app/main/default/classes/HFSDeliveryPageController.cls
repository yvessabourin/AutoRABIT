public with sharing class HFSDeliveryPageController {

	public List<HFS_Bag__c> allJobBags { get; set; }
	public Map<String, Integer> allBagStorage { get; set; }
	public Id jobId { get; set; }
	public String qrCodeLocation { get; set; }
	public String getLocationName { get; set; }
	public String getLocationId { get; set; }
	public String barcodeBag { get; set; }
	public Boolean stopLoopBags { get; set; }
	public Boolean displayPopUp { get; set; }
	public Boolean differentLocations{get;set;}
    public Integer countAllJobBagsInStorage { get; set; }
    public Integer count { get; set; }
    public HFS_Job__c getCurrentJob;
    public String currentStoragePoint{get;set;}
    public String guestCollectionPoint{get;set;}
    public Boolean assignedJob {get;set;}
    public Boolean VarConfPutaway {get;set;}
    public HFS_Job__c getAssignedJob;
    public HFS_Job__c getAvailableJob;

	public HFSDeliveryPageController(ApexPages.StandardController stdController) {
		assignedJob = true;
		Id profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: profileId];
		differentLocations = false;
		jobId = ApexPages.CurrentPage().getParameters().get('id');
        HFS_Job__c currenctJob = [SELECT Id, Assigned_to_me__c FROM HFS_Job__c WHERE Id =: jobId];
		qrCodeLocation = ApexPages.CurrentPage().getParameters().get('qrCodeLocation');
		getLocationId = ApexPages.CurrentPage().getParameters().get('StorageLocation');
        if(currenctJob.Assigned_to_me__c == false && profile.Name == 'HFS Runner'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This job is already assigned to another runner'));
            assignedJob = false;
            }else{
                if(getLocationId == ''){
                	getLocationId = null;
				}
				barcodeBag = ApexPages.CurrentPage().getParameters().get('barcodeBag');
				displayPopUp = true;
				getCurrentBags(jobId);
				initialActionStorageLocation();
            }
		
    }

	public void initialActionStorageLocation(){
    	List<HFS_Storage_Location__c> storageLocation = [SELECT Id, Name, QR_Code_hidden__c, HFS_Storage_Point__r.Name FROM HFS_Storage_Location__c];
    	//Apexpages.Message informAssignStorageLocation = new Apexpages.Message(Apexpages.Severity.Error, 'You need to Assign a Storage Location');

    	system.debug(getLocationId);
		if(jobId != null && qrCodeLocation != null){
    		for(HFS_Storage_Location__c correspondentSL : storageLocation){
    			if(correspondentSL.QR_Code_hidden__c == qrCodeLocation){
    				getLocationName = correspondentSL.Name;
    				Apexpages.Message informLocation = new Apexpages.Message(Apexpages.Severity.Info, 'At this point you can put the bags on: ' + getLocationName + ' without scanning Storage Location.');
					Apexpages.addMessage(informLocation);
    				currentStoragePoint = correspondentSL.HFS_Storage_Point__r.Name;
    				guestCollectionPoint = getCurrentJob.HFS_Guest_Collection_Point__c;
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

    public List<HFS_Bag__c> getCurrentBags (Id jobId){
    	if(String.isEmpty(qrCodeLocation)){
    		Apexpages.Message informNewLocation = new Apexpages.Message(Apexpages.Severity.Info, 'Assign a Storage Location');
			Apexpages.addMessage(informNewLocation);
    	}

		Id userId = UserInfo.getUserId();
		User currentUser = [SELECT Profile.Name FROM User WHERE Id =: userId];
		String profileName = currentUser.Profile.Name;

    	HFS_Runner__c hfsRunnerId = [SELECT Id, Name, User__c FROM HFS_Runner__c WHERE User__c =: userId];

    	getCurrentJob = [SELECT Id, Name, HFS_Purchase__c, Job_Status__c, HFS_Guest_Collection_Point__c, Guest_ID_Code__c FROM HFS_Job__c WHERE Id=: jobId];

		if (profileName == 'HFS Runner') {
			allJobBags = [SELECT Id, Name, In_Storage_Point__c, HFS_Runner__c, Barcode__c FROM HFS_Bag__c WHERE HFS_Runner__c =: hfsRunnerId.Id AND HFS_Job__c =: getCurrentJob.Id];
		} else {	
			allJobBags = [SELECT Id, Name, In_Storage_Point__c, HFS_Runner__c, Barcode__c FROM HFS_Bag__c WHERE HFS_Job__c =: getCurrentJob.Id];
		}
		List<HFS_Bag__c> allPurchaseBags = [SELECT Id, Guest_ID_Code__c, HFS_Storage_Location__c, HFS_Storage_Location__r.Name FROM HFS_Bag__c WHERE Guest_ID_Code__c =: getCurrentJob.Guest_ID_Code__c AND HFS_Purchase__r.Start_Time__c = TODAY];
		
		if(qrCodeLocation == null && getLocationId == null){
			for(HFS_Bag__c eachBag : allPurchaseBags){
				if(eachBag.HFS_Storage_Location__c != null){
					getLocationName = eachBag.HFS_Storage_Location__r.Name;
					getLocationId = eachBag.HFS_Storage_Location__c;
				}
			}
		}

    	return allJobBags;
    }

    public PageReference scanLocationCode(){
    	
    	PageReference goToBQrcodeScan = new PageReference('/apex/HFSDeliveryPageScanStorage?Id=' + jobId);
        return goToBQrcodeScan;
    }

    public PageReference scanBagsCode(){
    	
    	PageReference goToBarcodeScan = new PageReference('/apex/HFSDeliveryPageScanBags?Id=' + jobId + '&StorageLocation=' + getLocationId);
        return goToBarcodeScan;
    }

	public PageReference updateRecords(){
		Apexpages.Message informBagNotMatch = new Apexpages.Message(Apexpages.Severity.Error, 'This is bag ' + barcodeBag + ' does not correspond to this Job.');
		stopLoopBags = true;
		countAllJobBagsInStorage = 0;
		List<HFS_Bag__c> updatedBag = new List<HFS_Bag__c>();

		if(barcodeBag != null && getLocationId != null){
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

			if(allJobBags.size() == countAllJobBagsInStorage){
				HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, HFS_Purchase__r.Status__c, Job_Status__c, HFS_Guest_Collection_Point__c FROM HFS_Job__c WHERE Id=: jobId];
				getCurrentJob.Job_Status__c = 'Bags Putaway';
				getCurrentJob.HFS_Purchase__r.Status__c = 'Ready for Guest Collection';
				update getCurrentJob.HFS_Purchase__r;
				update getCurrentJob;
                VarConfPutaway = true;
				return null;
				 /*
				PageReference goToRecord = new PageReference('/' + getCurrentJob.Id);
        		return goToRecord;
        		*/
			}
		}

		allBagStorage = getAllStorage(jobId);

		return null;
	}

	public Map<String, Integer> getAllStorage(ID jobId){
		allBagStorage = new Map<String, Integer>();
		HFS_Job__c getCurrentJob = [SELECT Id, HFS_Purchase__c, Job_Status__c, HFS_Guest_Collection_Point__c, Guest_ID_Code__c FROM HFS_Job__c WHERE Id=: jobId];

		set<HFS_Bag__c> allstorage = new Set<HFS_Bag__c>([SELECT Id, HFS_Storage_Location__c, HFS_Storage_Location__r.Name FROM HFS_Bag__c WHERE Guest_ID_Code__c =: getCurrentJob.Guest_ID_Code__c AND HFS_Purchase__r.Start_Time__c = TODAY AND HFS_Storage_Location__c != NULL AND Storage_Matches_Guest_Collection_Point__c = true ]);

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
		PageReference detailPage = new PageReference('/' + getCurrentJob.Id);
		return detailPage;
	}


	public PageReference CurrentJob(){   	 
        ListView currentList = [SELECT Id FROM ListView WHERE DeveloperName = 'My_Current_Jobs' AND SobjectType = 'HFS_Job__c'];	 
        PageReference goToCurrentJob = new PageReference('/a1L?fcf=' + currentList.Id);
        return goToCurrentJob;
    }

    public PageReference AssignedJob(){    
	ListView assignedList = [SELECT Id FROM ListView WHERE DeveloperName = 'Assigned_Jobs' AND SobjectType = 'HFS_Job__c'];	 
    PageReference goToAssignedJob = new PageReference('/a1L?fcf=' + assignedList.Id);
      return goToAssignedJob;
   }


     public PageReference AvailableJob(){
    	ListView availableList = [SELECT Id FROM ListView WHERE DeveloperName = 'Available_Jobs' AND SobjectType = 'HFS_Job__c'];	 
    	PageReference goToAvailableJob = new PageReference('/a1L?fcf=' + availableList.Id);
        return goToAvailableJob;
    }



}