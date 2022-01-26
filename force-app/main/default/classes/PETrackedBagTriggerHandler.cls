public with sharing class PETrackedBagTriggerHandler{

	public String villageCode { get; set; }
	public String brandLocationCode { get; set; }
	public Decimal numberOfBags { get; set; }
	public Decimal estimatedSpend { get; set; }
	public Datetime requestTime { get; set; }
	public static HFS_IntegrationErrorTrackedBag__c logErrBag;
	public static List<Tracked_Bag__e> currentTrackedBags;
	public static LogFile__c rawMessageLog;
    public static list<case> HFSExperiences {get;set;}
	public static map<string, case> casemap {get;set;}
    
    
	public static void createPurchase(List<Tracked_Bag__e> newTrackedBags){
        	
        casemap = new map<string,case>(); 
        list<string> caseIds = new list<string>();	      
        for(Tracked_Bag__e tb : newTrackedBags ){
            caseIds.add(tb.guest_barcode__c);        
        }
     
        HFSExperiences = [SELECT id,Service_Guest_Number__c,Service_Guest_ID__c,Client_QR_Code__c FROM Case WHERE Client_QR_Code__c IN:caseIds AND CreatedDate = TODAY];
        for(case c : HFSExperiences){
            casemap.put(c.Client_QR_Code__c, c);
        }
            
		system.debug('newTrackedBags ' + newTrackedBags);
		Boolean logging = false;
		logErrBag = new HFS_IntegrationErrorTrackedBag__c();
		rawMessageLog = new LogFile__c();
		currentTrackedBags = new List<Tracked_Bag__e>();
		currentTrackedBags.addAll(newTrackedBags);
		system.debug('currentTrackedBags ' + currentTrackedBags);

		try{
			TrackedBag_Raw__c logRaw = [SELECT Id, Log_Raw__c FROM TrackedBag_Raw__c];
			if(logRaw.Log_Raw__c){
				for(Tracked_Bag__e bag : currentTrackedBags){
					rawMessageLog.Body__c += String.valueOf(bag);
				}
			}
		} catch (Exception e){
            system.debug('error 1 ' + e.getMessage());

		}

		try{
			List<Logging_Enabled__c> loggingEnabled = [SELECT Id FROM Logging_Enabled__c WHERE Name = 'PETrackedBagTriggerHandler'];
			system.debug(loggingEnabled);
			if(!loggingEnabled.isEmpty()){
				logging = true;
			}

		} catch (exception e){
			logging = false;
            system.debug('error 2 ' + e.getMessage());
		}
		
		system.debug('logging - ' + logging);

		LogFile__c logCreatePurchase = new LogFile__c();

		Set<String> caseQRCodes = new Set<String>();
		Set<String> existingVillagePresence = new Set<String>();

		List<String> listExistingBags = new List<String>();
		Set<String> setExistingBags = new Set<String>();

		Map<String, Tracked_Bag__e> tbMapByGuest = new Map<String, Tracked_Bag__e>();
		Map<String, Tracked_Bag__e> tbMapByVillagePresence = new Map<String, Tracked_Bag__e>();
		Map<String, Tracked_Bag__e> tbMapByBags = new Map<String, Tracked_Bag__e>();

		Date today = system.today();

		for(Tracked_Bag__e bag : newTrackedBags){
			caseQRCodes.add(bag.guest_barcode__c);
			existingVillagePresence.add(bag.lease_id__c);
		    tbMapByGuest.put(bag.guest_barcode__c, bag);
    		tbMapByVillagePresence.put(bag.lease_id__c, bag);

			List<HFS_Bag__c> baglist = (List<HFS_Bag__c>)JSON.deserialize(bag.hfsbags_List__c, List<HFS_Bag__c>.Class);
			system.debug('baglist ' + baglist);
			
			for(HFS_Bag__c aBag : baglist){
				setExistingBags.add(aBag.Barcode__c);
				system.debug('setExistingBags ' + setExistingBags);
				listExistingBags.add(aBag.Barcode__c);
				system.debug('listExistingBags ' + listExistingBags);
				tbMapByBags.put(aBag.Barcode__c, bag);
				system.debug('tbMapByBags ' + tbMapByBags);
			}
		}

		List<Case> theGuestCase = [SELECT Id, Status, Client_QR_Code__c, Service_Guest_Number__c FROM Case WHERE Client_QR_Code__c IN :caseQRCodes AND Service_Date__c = :TODAY AND Status != 'Closed'];
		Map<String,Id> guestCaseMap = new Map<String,Id>();
		for(Case aCase : theGuestCase){
			guestCaseMap.put(aCase.Client_QR_Code__c,aCase.Id);
			system.debug('guestCaseMap ' + guestCaseMap);
		}

		List<Village_Presence__c> theBrand = [SELECT Id, Lease_ID__c,HFS_Bags_Used__c,Village__r.Currency__c FROM Village_Presence__c WHERE Lease_ID__c IN :existingVillagePresence];
		Map<String,Id> brandMap = new Map<String,Id>();
        
        //	if(theBrand.size() > 0){ 
                for(Village_Presence__c aBrand : theBrand){
                    brandMap.put(aBrand.Lease_ID__c,aBrand.Id);
                    system.debug('brandMap ' + brandMap);
                }
            
        
                map<string, string> villageCurrencyMap = new map<string, string>();
                for(Village_Presence__c v : theBrand ){
                        villageCurrencyMap.put(v.id,v.Village__r.Currency__c);                  
                }
                
        
                Map<String,Village_Presence__c> brandUpdateMap = new Map<String,Village_Presence__c>();
                for(Village_Presence__c aBrand : theBrand){
                    brandUpdateMap.put(aBrand.Lease_ID__c,aBrand);
                    system.debug('brandUpdateMap ' + brandUpdateMap);
                }
        
                list<Village_Presence__c> vpsToUpdate = new list<Village_Presence__c>();
                for(Tracked_Bag__e tb : newTrackedBags){
                    
                    if(theBrand.size() > 0){ 
                    Village_Presence__c vp = brandUpdateMap.get(tb.lease_id__c);
        
                    if(vp.HFS_Bags_Used__c == NULL){
                        vp.HFS_Bags_Used__c = 0;
                    }
        
                    vp.HFS_Bags_Used__c = vp.HFS_Bags_Used__c + tb.numberofbags__c;
                    vpsToUpdate.add(vp);
                    }
                }
            



				//first error check
		catchErrors(caseQRCodes, existingVillagePresence, theGuestCase, theBrand, tbMapByGuest, tbMapByVillagePresence);
		system.debug('brandMap ' + brandMap);
		Boolean getResultAlreadyExist;
		String allBags = '';
		//second error check
		system.debug('listExistingBags.size() ' + listExistingBags.size());
		system.debug('setExistingBags.size() ' + setExistingBags.size());
		if(listExistingBags.size() == setExistingBags.size()){
			//third error check
			getResultAlreadyExist = verifyEquals(setExistingBags, tbMapByBags);
			system.debug('getResultAlreadyExist ' + getResultAlreadyExist);
		} else {
			if(logErrBag.Id == null){
				for(Tracked_Bag__e bag : currentTrackedBags){
					logErrBag.Brand_Lease_Id__c = bag.lease_id__c;
					logErrBag.Brand_Location_Name__c = bag.brand_location_name__c;
					logErrBag.DateTime__c = bag.txn_datetime_utc__c;
					logErrBag.Estimated_Spend__c = bag.estimated_spend__c;
					logErrBag.Guest_Code__c = bag.guest_barcode__c;
					logErrBag.List_of_Bags__c = bag.hfsbags_List__c;
					logErrBag.Number_of_Bags__c = bag.numberofbags__c;
                    
                    if(casemap.get(bag.guest_barcode__c) != NULL){
                         logErrBag.HFS_Case__c = casemap.get(bag.guest_barcode__c).id;
                    }
                   
				}
                try{
                    insert logErrBag;
                        if(!String.isBlank(rawMessageLog.Body__c)){
                            rawMessageLog.Integration_Record__c = logErrBag.Id;
                            upsert rawMessageLog;
                        }
                }catch (exception e){
                    system.debug(' ' + e.getMessage());
                }
				
				
			}
			getResultAlreadyExist = true;
			logCreatePurchase.Type__c = 'Hands Free Shopping';
			logCreatePurchase.Body__c = 'PETrackedBagTriggerHandler - Errors related to repeated barcodes';
			logCreatePurchase.Body2__c = 'Bags Error - The information of Bags is repeated: ' + listExistingBags + '\n' + '\n';
			logCreatePurchase.Integration_Record__c = logErrBag.Id;
			insert logCreatePurchase;
            logErrBag.Error_Category__c =   logErrBag.Error_Category__c + 'Errors related to repeated barcodes';
            update logErrBag;

		}

		List<Case_Item__c> thePurchases = new List<Case_Item__c>();
		Case_Item__c purchase = new Case_Item__c();
		
		if(getResultAlreadyExist == false){
			for(Tracked_Bag__e actualTrackedBag : newTrackedBags){
					system.debug('actualTrackedBag ' + actualTrackedBag);
					purchase.Case__c = guestCaseMap.get(actualTrackedBag.guest_barcode__c);
					purchase.Village_Presence__c = brandMap.get(actualTrackedBag.lease_id__c);
					purchase.Estimated_Spend__c = actualTrackedBag.estimated_spend__c;
					purchase.Item_Count__c = actualTrackedBag.numberofbags__c;
					purchase.Start_Time__c = actualTrackedBag.txn_datetime_utc__c;
					purchase.Status__c = 'Awaiting Pick-up from Brand';
					purchase.Require_a_Runner__c = true;
                    purchase.CurrencyIsoCode = villageCurrencyMap.get(brandMap.get(actualTrackedBag.lease_id__c));
					//purchase.CurrencyIsoCode = 'GBP';
					thePurchases.add(purchase);

					if(logging == true){
						logCreatePurchase.Type__c = 'Hands Free Shopping';
						logCreatePurchase.Body__c = 'PETrackedBagTriggerHandler';
						logCreatePurchase.Body2__c += 'The Purchase: ' + JSON.serialize(purchase);
		    			logCreatePurchase.Body4__c += 'Request Body: ' + actualTrackedBag;
					}
			//	}
			}
			system.debug('thePurchases ' + thePurchases);
            
            Savepoint sp = Database.setSavepoint();
            try{              
                insert thePurchases;
				update vpsToUpdate;
            }
            catch (Exception e){   
                system.debug('pre roll back');
                Database.rollback(sp);
                list<HFS_IntegrationErrorTrackedBag__c> IntErrorList = new list<HFS_IntegrationErrorTrackedBag__c>();
                list<LogFile__c> LogFileList = new list<LogFile__c>();
                for(Tracked_Bag__e bag : currentTrackedBags){                
					logErrBag.Brand_Lease_Id__c = bag.lease_id__c;
					logErrBag.Brand_Location_Name__c = bag.brand_location_name__c;
					logErrBag.DateTime__c = bag.txn_datetime_utc__c;
					logErrBag.Estimated_Spend__c = bag.estimated_spend__c;
                    logErrBag.Guest_Code__c = bag.guest_barcode__c;
					logErrBag.List_of_Bags__c = bag.hfsbags_List__c;
					logErrBag.Number_of_Bags__c = bag.numberofbags__c;
                    logErrBag.Error_Category__c = 'System Error';
                    if(casemap.get(bag.guest_barcode__c) != NULL){
                         logErrBag.HFS_Case__c = casemap.get(bag.guest_barcode__c).id;
                    }
                    insert logErrBag;
                    
                    list<LogFile__c> logs = new list<LogFile__c>();
                    LogFile__c logfile1 = new LogFile__c();
                    logfile1.Body__c += String.valueOf(bag);
                    logfile1.Integration_Record__c = logErrBag.id;
                    logs.add(logfile1);
                    
                    LogFile__c logfile2 = new LogFile__c();
                    logfile2.Type__c = 'Hands Free Shopping';
                    logfile2.Body__c = 'PETrackedBagTriggerHandler - System Error';
                    logfile2.Body2__c = 'System validation error222 - : ' + e.getMessage() + '\n' + '\n';
                    logfile2.Integration_Record__c = logErrBag.id;
                    logs.add(logfile2);
                          
                    insert logs;  
        	
                                                   
				}

            }

			Map<String,Id> allPurchases = new Map<String,Id>();
			for(Case_Item__c onePurchase : thePurchases){
				allPurchases.put(onePurchase.Case__c, onePurchase.Id);
				system.debug('allPurchases ' + allPurchases);
			}

			List<HFS_Bag__c> allInsertedBags = new List<HFS_Bag__c>();
			String listOfBags = ' ';
			for(Tracked_Bag__e actualTrackedBag : newTrackedBags){
				system.debug('actualTrackedBag ' + actualTrackedBag);
				
				List<HFS_Bag__c> baglist = (List<HFS_Bag__c>)JSON.deserialize(actualTrackedBag.hfsbags_List__c, List<HFS_Bag__c>.Class);
				system.debug('baglist ' + baglist);	
				
				for(HFS_Bag__c aBag : baglist){
					system.debug('aBag ' + aBag);
					if(guestCaseMap.get(actualTrackedBag.guest_barcode__c) != null){
						aBag.HFS_Purchase__c = allPurchases.get(guestCaseMap.get(actualTrackedBag.guest_barcode__c));
						aBag.Status__c = 'Awaiting Pick-up';
						allInsertedBags.add(aBag);
						system.debug('allInsertedBags ' + allInsertedBags);

						if(logging == true){
							listOfBags += 'Bag: ' + aBag;
							logCreatePurchase.Body3__c = 'The List of Bags: ' + listOfBags;
						}
					}
				}
			}
			system.debug('allInsertedBags ' + allInsertedBags);
			insert allInsertedBags;
			
			if(theGuestCase[0].Status == 'New'){
				theGuestCase[0].Status = 'Shopping';
				update theGuestCase;
			}
			
			if(logging == true){
				//create integration error here
				insert logCreatePurchase;
			}
		}
          //  }
	}
    
    
    
    
    

	public static void catchErrors(Set<String> caseQRCodes, Set<String> existingVillagePresence,
									List<Case> theGuestCase, List<Village_Presence__c> theBrand,
									Map<String, Tracked_Bag__e> tbMapByGuest, Map<String, Tracked_Bag__e> tbMapByVillagePresence){


		String fieldName = 'Client_QR_Code__c';
		Set<String> errorsQRCodes = new Set<String>();
		system.debug('theGuestCase ' + theGuestCase);
		if(theGuestCase.size() != caseQRCodes.size()){
            Set<String> guestCasesSet = new Set<String>();
		    for(Case c : theGuestCase){
		        guestCasesSet.add((String)c.get(fieldName));
				system.debug('guestCasesSet ' + guestCasesSet);
		    }
		    for(String qr : caseQRCodes){
		        if(!guestCasesSet.contains(qr)){
		            errorsQRCodes.add(qr);
					system.debug('errorsQRCodes ' + errorsQRCodes);
		        }
		    }
		}

		fieldName = 'Lease_ID__c';
		Set<String> errorsVillagePresenceCodes = new Set<String>();

		if(theBrand.size() != existingVillagePresence.size()){
            Set<String> villagePresenceSet = new Set<String>();
		    for(Village_Presence__c vp : theBrand){
		        villagePresenceSet.add((String)vp.get(fieldName)); 
		    }
		    for(String vpcode : existingVillagePresence){
		        if(!villagePresenceSet.contains(vpcode)){
		            errorsVillagePresenceCodes.add(vpcode);
		        }
		    }
		}

		LogFile__c logCatchErrors = new LogFile__c();
        String theErrors = '';
		logCatchErrors.Type__c = 'Hands Free Shopping';
		logCatchErrors.Body__c = 'PETrackedBagTriggerHandler - Errors related to Lookups';       

		String getErrorsQRCodes = ' ';
		String getErrorsVillagePresence = ' ';

		for(String q : errorsQRCodes){
			getErrorsQRCodes += 'Invalid QR Codes: ' + q + '| From Message: ' + tbMapByGuest.get(q)  + '\n' + '\n';
			logCatchErrors.Body3__c = getErrorsQRCodes;
            theErrors =  theErrors + 'Invalid QR Codes';
        	
		}

		for(String vp : errorsVillagePresenceCodes){
			getErrorsVillagePresence += 'Invalid Lease ID for existing Village Presence: ' + vp + '| From Message: ' + tbMapByVillagePresence.get(vp) + '\n' + '\n';
			logCatchErrors.Body4__c = getErrorsVillagePresence;
            theErrors = theErrors + 'Invalid Lease ID for existing Village Presence';
        	
		}

		if(!errorsQRCodes.isEmpty() || !errorsVillagePresenceCodes.isEmpty()){
			for(Tracked_Bag__e bag : currentTrackedBags){
					logErrBag.Brand_Lease_Id__c = bag.lease_id__c;
					logErrBag.Brand_Location_Name__c = bag.brand_location_name__c;
					logErrBag.DateTime__c = bag.txn_datetime_utc__c;
					logErrBag.Estimated_Spend__c = bag.estimated_spend__c;
					logErrBag.Guest_Code__c = bag.guest_barcode__c;
					logErrBag.List_of_Bags__c = bag.hfsbags_List__c;
					logErrBag.Number_of_Bags__c = bag.numberofbags__c;
                    if(casemap.get(bag.guest_barcode__c) != NULL){
                         logErrBag.HFS_Case__c = casemap.get(bag.guest_barcode__c).id;
                    }
                
				}
			insert logErrBag;
			if(!String.isBlank(rawMessageLog.Body__c)){
					rawMessageLog.Integration_Record__c = logErrBag.Id;
					upsert rawMessageLog;
				}
			logCatchErrors.Integration_Record__c = logErrBag.Id;
			insert logCatchErrors;
            
            logErrBag.Error_Category__c = theErrors;
            update  logErrBag;
            
		}
	}
    
    
    
    

	public static Boolean verifyEquals(Set<String> existingBags, Map<String, Tracked_Bag__e> mapCurrentBags){
        Boolean isEqual = false;
        
        String theErrors = '';
        
		List<HFS_Bag__c> allHFSBags = [SELECT Id, Barcode__c FROM HFS_Bag__c WHERE HFS_Bag_Active__c = true AND Barcode__c IN :existingBags];
		system.debug('allHFSBags ' + allHFSBags);

		String fieldName = 'Barcode__c';
		Set<String> repeatedHFSBags = new Set<String>();

		if(!allHFSBags.isEmpty()){
			isEqual = true;
			
		    for (HFS_Bag__c b : allHFSBags){
		        repeatedHFSBags.add((String)b.get(fieldName));
				system.debug('repeatedHFSBags ' + repeatedHFSBags);
		    }

			LogFile__c logCatchErrors = new LogFile__c();
			logCatchErrors.Type__c = 'Hands Free Shopping';
			logCatchErrors.Body__c = 'PETrackedBagTriggerHandler - Errors related to repeated barcodes';
           
		    String getErrorsHFSBags = ' ';
		    for (String b : repeatedHFSBags){
				getErrorsHFSBags += 'This HFS Bag is already inserted in the system: ' + b + '| From Message: ' + mapCurrentBags.get(b) + '\n' + '\n';
                theErrors = theErrors + 'Bag(s) already inserted in the system';
				logCatchErrors.Body2__c = getErrorsHFSBags;
				system.debug('logCatchErrors.Body2__c ' + logCatchErrors.Body2__c);
			}
			if(!repeatedHFSBags.isEmpty()){
				if(logErrBag.Id == null){
					for(Tracked_Bag__e bag : currentTrackedBags){
						logErrBag.Brand_Lease_Id__c = bag.lease_id__c;
						logErrBag.Brand_Location_Name__c = bag.brand_location_name__c;
						logErrBag.DateTime__c = bag.txn_datetime_utc__c;
						logErrBag.Estimated_Spend__c = bag.estimated_spend__c;
						logErrBag.Guest_Code__c = bag.guest_barcode__c;
						logErrBag.List_of_Bags__c = bag.hfsbags_List__c;
						logErrBag.Number_of_Bags__c = bag.numberofbags__c;
                        
                        if(casemap.get(bag.guest_barcode__c) != NULL){
                         logErrBag.HFS_Case__c = casemap.get(bag.guest_barcode__c).id;
                    	}
					}
                    
					insert logErrBag;
					if(!String.isBlank(rawMessageLog.Body__c)){
						rawMessageLog.Integration_Record__c = logErrBag.Id;
					upsert rawMessageLog;
					}
				}
				logCatchErrors.Integration_Record__c = logErrBag.Id;
				insert logCatchErrors;
                logErrBag.Error_Category__c = theErrors;
            	update  logErrBag;
			}
        }
        system.debug('isEqual ' + isEqual);
        return isEqual;
    }
}