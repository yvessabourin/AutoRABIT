public with sharing class CreateConiqPurchaseExtension {

	public static HFS_IntegrationErrorTrackedBag__c integrationError {get;set;}
    public TrackebBag newTrackedBag;
    public List<TrackebBag> listToResend;
    public Id recordId;

    public CreateConiqPurchaseExtension(ApexPages.StandardController stdController) {
        integrationError = (HFS_IntegrationErrorTrackedBag__c)stdController.getRecord();
        newTrackedBag = new TrackebBag();
        listToResend = new List<TrackebBag>();
        recordId = integrationError.Id;
    }

    public PageReference createConiqPurchase() {
        integrationError = [SELECT Id, Name, Brand_Lease_Id__c, Brand_Location_Name__c, DateTime__c, Estimated_Spend__c, Guest_Code__c, List_of_Bags__c, Number_of_Bags__c, Is_Resolved__c
                            FROM HFS_IntegrationErrorTrackedBag__c
                            WHERE Id =: recordId];
        newTrackedBag.lease_id = integrationError.Brand_Lease_Id__c;
        newTrackedBag.brand_location_name = integrationError.Brand_Location_Name__c;
        newTrackedBag.txn_datetime_utc = integrationError.DateTime__c;
        newTrackedBag.estimated_spend = integrationError.Estimated_Spend__c;
        newTrackedBag.guest_barcode = integrationError.Guest_Code__c;
        newTrackedBag.hfsbags_list = integrationError.List_of_Bags__c;
        newTrackedBag.numberofbags = integrationError.Number_of_Bags__c;
        listToResend.add(newTrackedBag);
        if(!integrationError.Is_Resolved__c){
            createPurchase(listToResend);
        }
        PageReference pageRef = new PageReference('/' + integrationError.Id);
        return pageRef;
    }

    public static void createPurchase(List<TrackebBag> newTrackedBags){
        Boolean logging = false;
        try{
            // Custom Setting object
            List<Logging_Enabled__c> loggingEnabled = [SELECT Id FROM Logging_Enabled__c WHERE Name = 'PETrackedBagTriggerHandler'];
            if(!loggingEnabled.isEmpty()){
                logging = true;
            }

        } catch (exception e){
            logging = false;
        }
        
        system.debug(logging);

        LogFile__c logCreatePurchase = new LogFile__c();

        Set<String> caseQRCodes = new Set<String>();
        Set<String> existingVillagePresence = new Set<String>();

        List<String> listExistingBags = new List<String>();
        Set<String> setExistingBags = new Set<String>();

        Map<String, TrackebBag> tbMapByGuest = new Map<String, TrackebBag>();
        Map<String, TrackebBag> tbMapByVillagePresence = new Map<String, TrackebBag>();
        Map<String, TrackebBag> tbMapByBags = new Map<String, TrackebBag>();

        Date today = system.today();

        for(TrackebBag bag : newTrackedBags){
            caseQRCodes.add(bag.guest_barcode);
            existingVillagePresence.add(bag.lease_id);
            tbMapByGuest.put(bag.guest_barcode, bag);
            tbMapByVillagePresence.put(bag.lease_id, bag);

            List<HFS_Bag__c> baglist = (List<HFS_Bag__c>)JSON.deserialize(bag.hfsbags_List, List<HFS_Bag__c>.Class); 
            
            for(HFS_Bag__c aBag : baglist){
                setExistingBags.add(aBag.Barcode__c);
                listExistingBags.add(aBag.Barcode__c);
                tbMapByBags.put(aBag.Barcode__c, bag);
            }
        }
        List<Case> theGuestCase = [SELECT Id, Client_QR_Code__c, Service_Guest_Number__c FROM Case WHERE Client_QR_Code__c IN :caseQRCodes AND Service_Date__c = :TODAY AND Status != 'Closed'];
        Map<String,Id> guestCaseMap = new Map<String,Id>();
        for(Case aCase : theGuestCase){
            guestCaseMap.put(aCase.Client_QR_Code__c,aCase.Id);
        }

        List<Village_Presence__c> theBrand = [SELECT Id, Lease_ID__c FROM Village_Presence__c WHERE Lease_ID__c IN :existingVillagePresence];
        Map<String,Id> brandMap = new Map<String,Id>();
        for(Village_Presence__c aBrand : theBrand){
            brandMap.put(aBrand.Lease_ID__c,aBrand.Id);
        }

        catchErrors(caseQRCodes, existingVillagePresence, theGuestCase, theBrand, tbMapByGuest, tbMapByVillagePresence);
        
        Boolean getResultAlreadyExist;
        String allBags = '';
        
        if(listExistingBags.size() == setExistingBags.size()){
            getResultAlreadyExist = verifyEquals(setExistingBags, tbMapByBags);
        } else {
            getResultAlreadyExist = true;
            logCreatePurchase.Type__c = 'Hands Free Shopping';
            logCreatePurchase.Body__c = 'PETrackedBagTriggerHandler - Errors related to repeated barcodes';
            logCreatePurchase.Body2__c = 'Bags Error - The information of Bags is repeated: ' + listExistingBags + '\n' + '\n';
            logCreatePurchase.Integration_Record__c = integrationError.Id;
            logCreatePurchase.LogFile_From_Resubmitted_Purchase__c = true;
            insert logCreatePurchase;
        }

        List<Case_Item__c> thePurchases = new List<Case_Item__c>();
        Case_Item__c purchase = new Case_Item__c();
        
        if(getResultAlreadyExist == false && theGuestCase.size() != 0){
            for(TrackebBag actualTrackedBag : newTrackedBags){
                    purchase.Case__c = guestCaseMap.get(actualTrackedBag.guest_barcode);
                    purchase.Village_Presence__c = brandMap.get(actualTrackedBag.lease_id);
                    purchase.Estimated_Spend__c = actualTrackedBag.estimated_spend;
                    purchase.Item_Count__c = actualTrackedBag.numberofbags;
                    purchase.Start_Time__c = actualTrackedBag.txn_datetime_utc;
                    purchase.Status__c = 'Awaiting Pick-up from Brand';
                    purchase.Require_a_Runner__c = true;
                    purchase.CurrencyIsoCode = 'GBP';
                    thePurchases.add(purchase);

                    if(logging == true){
                        logCreatePurchase.Type__c = 'Hands Free Shopping';
                        logCreatePurchase.Body__c = 'PETrackedBagTriggerHandler';
                        logCreatePurchase.Body2__c += 'The Purchase: ' + JSON.serialize(purchase);
                        logCreatePurchase.Body4__c += 'Request Body: ' + actualTrackedBag;
                    }
            //  }
            }

            insert thePurchases;

            Map<String,Id> allPurchases = new Map<String,Id>();
            for(Case_Item__c onePurchase : thePurchases){
                allPurchases.put(onePurchase.Case__c, onePurchase.Id);
            }

            List<HFS_Bag__c> allInsertedBags = new List<HFS_Bag__c>();
            String listOfBags = ' ';
            for(TrackebBag actualTrackedBag : newTrackedBags){
                
                List<HFS_Bag__c> baglist = (List<HFS_Bag__c>)JSON.deserialize(actualTrackedBag.hfsbags_List, List<HFS_Bag__c>.Class);    
                
                for(HFS_Bag__c aBag : baglist){
                    if(guestCaseMap.get(actualTrackedBag.guest_barcode) != null){
                        aBag.HFS_Purchase__c = allPurchases.get(guestCaseMap.get(actualTrackedBag.guest_barcode));
                        aBag.Status__c = 'Awaiting Pick-up';
                        allInsertedBags.add(aBag);

                        if(logging == true){
                            listOfBags += 'Bag: ' + aBag;
                            logCreatePurchase.Body3__c = 'The List of Bags: ' + listOfBags;
                        }
                    }
                }
            }

            insert allInsertedBags;

            if(logging == true){
                logCreatePurchase.LogFile_From_Resubmitted_Purchase__c = true;
                logCreatePurchase.Integration_Record__c = integrationError.Id;
                integrationError.Is_Resolved__c = true;
                upsert integrationError;
                insert logCreatePurchase;
            }
        }
    }

    public static void catchErrors(Set<String> caseQRCodes, Set<String> existingVillagePresence,
                                    List<Case> theGuestCase, List<Village_Presence__c> theBrand,
                                    Map<String, TrackebBag> tbMapByGuest, Map<String, TrackebBag> tbMapByVillagePresence){

        String fieldName = 'Client_QR_Code__c';
        Set<String> errorsQRCodes = new Set<String>();

        if(theGuestCase.size() != caseQRCodes.size()){
            Set<String> guestCasesSet = new Set<String>();
            for(Case c : theGuestCase){
                guestCasesSet.add((String)c.get(fieldName));
            }
            for(String qr : caseQRCodes){
                if(!guestCasesSet.contains(qr)){
                    errorsQRCodes.add(qr);
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
        logCatchErrors.Type__c = 'Hands Free Shopping';
        logCatchErrors.Body__c = 'PETrackedBagTriggerHandler - Errors related to Lookups';

        String getErrorsQRCodes = ' ';
        String getErrorsVillagePresence = ' ';

        for(String q : errorsQRCodes){
            getErrorsQRCodes += 'Invalid QR Codes: ' + q + '| From Message: ' + tbMapByGuest.get(q)  + '\n' + '\n';
            logCatchErrors.Body3__c = getErrorsQRCodes;
        }

        for(String vp : errorsVillagePresenceCodes){
            getErrorsVillagePresence += 'Invalid Lease ID for existing Village Presence: ' + vp + '| From Message: ' + tbMapByVillagePresence.get(vp) + '\n' + '\n';
            logCatchErrors.Body4__c = getErrorsVillagePresence;
        }

        if(!errorsQRCodes.isEmpty() || !errorsVillagePresenceCodes.isEmpty()){
            logCatchErrors.Integration_Record__c = integrationError.Id;
            logCatchErrors.LogFile_From_Resubmitted_Purchase__c = true;
            insert logCatchErrors;
        }
    }

    public static Boolean verifyEquals(Set<String> existingBags, Map<String, TrackebBag> mapCurrentBags){
        Boolean isEqual = false;
        
        List<HFS_Bag__c> allHFSBags = [SELECT Id, Barcode__c FROM HFS_Bag__c WHERE HFS_Bag_Active__c = true AND Barcode__c IN :existingBags];

        String fieldName = 'Barcode__c';
        Set<String> repeatedHFSBags = new Set<String>();

        if(!allHFSBags.isEmpty()){
            isEqual = true;
            
            for (HFS_Bag__c b : allHFSBags){
                repeatedHFSBags.add((String)b.get(fieldName)); 
            }

            LogFile__c logCatchErrors = new LogFile__c();
            logCatchErrors.Type__c = 'Hands Free Shopping';
            logCatchErrors.Body__c = 'PETrackedBagTriggerHandler - Errors related to repeated barcodes';

            String getErrorsHFSBags = ' ';
            for (String b : repeatedHFSBags){
                getErrorsHFSBags += 'This HFS Bag is already inserted in the system: ' + b + '| From Message: ' + mapCurrentBags.get(b) + '\n' + '\n';
                logCatchErrors.Body2__c = getErrorsHFSBags;
                // System.debug('Notification: ' + 'Invalid Invalid Lease ID for existing Village Presence: ' + b + '| From Message: ' + tbMapByBags.get(vp));
            }
            if(!repeatedHFSBags.isEmpty()){
                logCatchErrors.Integration_Record__c = integrationError.Id;
                logCatchErrors.LogFile_From_Resubmitted_Purchase__c = true;
                insert logCatchErrors;
            }
        }
        return isEqual;
    }

    private class TrackebBag{
        String lease_id;
        String brand_location_name;
        Datetime txn_datetime_utc;
        Decimal estimated_spend;
        String guest_barcode;
        String hfsbags_list;
        Decimal numberofbags;
    }
}