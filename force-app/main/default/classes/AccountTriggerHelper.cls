public with sharing class AccountTriggerHelper {

    private static final id guestRecordType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Guest').RecordTypeId;
    private static Boolean isAfterUpdate = true;
    
    // update associated Deal and Village Presence names if account name is updated
    public static void updateDealAndVPNames(set<Id> accountIdList){     
            
        // Update Village Presence records first
        map<Id, Village_Presence__c> vpMap = new map<Id, Village_Presence__c>([select Id, Name 
                                                                            from Village_Presence__c
                                                                            where Brand__c in :accountIdList]);
                                                                                                            
        if (vpMap != null){
            if (!vpMap.isEmpty()){
                VillagePresenceUtilities.defaultName(vpMap.keySet());       
            }
        }                                       
        
        // Now update Opportunity (Deal) records
        map<Id, Opportunity> dealMap = new map<Id,Opportunity>([select Id, Name from Opportunity 
                                        where AccountId in :accountIdList
                                        and StageName != 'Closed']);
        
        if (dealMap != null){
            if (!dealMap.isEmpty()){
                OpportunityTriggerHelper.updateOpportunityName(dealMap, null);
            }
        }

        
    }

    // Called by BeforeInsert/Update trigger to ensure name is populated
    public static void checkName(list<Account> accountList){
        
        for (Account a :accountList){
            
            if (a.RecordTypeId == guestRecordType){
               
                if (string.isBlank(a.LastName)){
                    if (!string.isBlank(a.PersonEmail)){
                        a.LastName = a.PersonEmail;
                    } else {
                        a.LastName = a.Customer_GUID__c;
                    } 
                }
                
                if (!string.isBlank(a.PersonEmail)){
                    a.Account_Name_unique__c = a.PersonEmail;
                } else if (!string.isBlank(a.Customer_GUID__c)){
                	a.Account_Name_unique__c = a.Customer_GUID__c;
                }  else{
                	a.Account_Name_unique__c = '';
                }              
            }
        }
        
        
    }


    public static void onBeforeUpdateOrInsert(Map<Id,Account> accountNew,Map<Id,Account> accountOld,List<Account> accountNewList, List<Account> accountOldList, boolean isUpdate, boolean isInsert){

        system.debug('onBeforeUpdateOrInsert FIRED');
        // for Brand accounts, we need to copy the values from the old segmentation fields to the new ones.
        // NOTE!! this code needs to be removed in the next release, or else it might cause issues.
        Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();        

        for (Account acc : accountNewList) {

           // Account acc = accountNew.get(key);    

            if(acc.RecordTypeID == brandRecordTypeId){
                // then its a Brand, and we need to copy the segmentation details over.
             
                acc.Gender_Classification__c = acc.Brand_Gender__c;
                acc.VR_Category__c= acc.Brand_Guest_Relevance__c;
                acc.Department__c= acc.Brand_Segment__c;
                acc.Segment__c= acc.Brand_Subsegment__c;
                acc.Market_Position__c= acc.Brand_VR_Positioning__c;
            
            }
        }
        
        // assignment type needs to be calculated but also can be overridden by someone with the right creds
        //acc.Assignment_Type__c= '';
        if(isInsert){
            for (Account acc : accountNewList) {
                // means its a new record, so we can just calculate the value                
                if(acc.RecordTypeID == brandRecordTypeId){
                    if(acc.GRS_Captain__c != null){
                        acc.Assignment_Type__c = 'Group Retail';
                    }
                    else
                    {
                        acc.Assignment_Type__c = 'No Village';
                    }
                }
            }
        }
        if(isUpdate){
          
            // means its an update, and we need to see if the value was over-ridden, or if it needs calculating as-is
            // the village presence change will be handled by the village presence trigger
            List<ID> accForVPUpdate = new List<ID>();
            for(ID key :accountNew.keyset()){
                Account newacc = accountNew.get(key);    
                // lets get the old account values
                Account oldacc = accountOld.get(key);    
                if(newacc.RecordTypeID == brandRecordTypeId){
                    if(oldacc.GRS_Captain__c == null && newacc.GRS_Captain__c != null){
                        // if the GRS brand captain field has gone from blank to something
                        // this means its a GRS type brand
                         newacc.Assignment_Type__c = 'Group Retail';

                    }
                    if( newacc.GRS_Captain__c == null){
                        // if the GRS brand captain has now become blank
                        // this means we need to count the villag presences
                        accForVPUpdate.add(key);
                    }              
                    System.debug('CHECK GRS STATUS === oldGRS: ' + oldacc.GRS_Captain__c + ' === New GRS: ' + newacc.GRS_Captain__c);
                }
            }
            // now if there are records in the accForVPUpdate list, it means we need to get all the village presence records for those brands
            if(accForVPUpdate.size() > 0){
                // lets get all the VPs for the brands
                List<Village_Presence__c> VPs = [Select Id, Brand__c , Name FROM Village_Presence__c WHERE Brand__c in :accForVPUpdate AND Status__c = 'Trading'];
                Map<Id,List<Village_Presence__c>> VPsByBrand = new map<Id,List<Village_Presence__c>>();
                for(Village_Presence__c vp :VPs){
                     if(!VPsByBrand.containsKey(vp.Brand__c)){
                        VPsByBrand.put(vp.Brand__c, new List<Village_Presence__c>{vp});
                     }
                     else
                     {
                          VPsByBrand.get(vp.Brand__c).add(vp);
                     }

                }
                System.debug('About to loop new accoutn keyset: ' + VPsByBrand);
                // now we have a nice map of all the brands and their village presences
                for(ID key :accountNew.keyset()){
                    Account newacc = accountNew.get(key);    
                      System.debug('VPsByBrand: ' + VPsByBrand);
                    if(VPsByBrand.get(key) == NULL || VPsByBrand.get(key).size() == 0 ){
                          newacc.Assignment_Type__c =  'No Village';
                    }  
                    else
                    {
                        if(VPsByBrand != null && VPsByBrand.get(key) != null && VPsByBrand.get(key).size() == 1){
                            newacc.Assignment_Type__c = 'Local Village';
                        }
                        else
                        {
                            // if its more than 1, then its a multi Village
                            newacc.Assignment_Type__c =  'Multi-Village';
                        }
                    }
                }

            }

        }

    }

    public static void onAfterUpdateOrInsert(Map<Id,Account> accountNew,Map<Id,Account> accountOld,List<Account> accountNewList, List<Account> accountOldList, boolean isUpdate, boolean isInsert){
        Id brandRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();        

        if(isInsert){
            List<Account> accList = new List<Account>();
            for(Account acc :accountNewList){
                System.debug('New Account RT === '+ acc.RecordTypeID + ' ==== ' + brandRecordTypeId);
                if(acc.RecordTypeID == brandRecordTypeId){
                    accList.add(acc);   
                     System.debug('Adding account to be checked for BSAs === ' + acc);                
                }
            }
             System.debug('Processing accounts for BSAs === ' + accList);
            createNewSegmentationRecords(accList);
        }

        if(isUpdate && isAfterUpdate){
             List<Account> AccountsThatNeedBSArecords = new List<Account>();
             for (Account acc : accountNewList) {      
                if(acc.RecordTypeID == brandRecordTypeId){
                    // if the brand account was updated, then we need to see if anything vital changed... which could mean we need to re-evaluate the segmentation details.
                    if(acc.Assignment_Type__c != accountOld.get(acc.Id).Assignment_Type__c){
                        // means the assignment type has changed, and we need to create a new record....
                        // but... if there already is a record for that brand, we might not need to...
                        AccountsThatNeedBSArecords.add(acc);
                        System.debug('Adding account to be checked for BSAs === ' + acc);
                    }
                }
            }

            // now that we have the accounts that have changed.. we need to exclude the accounts that might already have a 'New' segmentation approval record           
            // only create BSAs if NO new,pending,awaiting records exist.
            List<Brand_Segmentation_Approval__c> segapprovalList = [select id,Brand__c, Status__c from Brand_Segmentation_Approval__c where Brand__c in :AccountsThatNeedBSArecords AND (Status__c = 'New' OR Status__c = 'Pending' OR Status__c ='Requesting Approval')];
            // now we have a list of the brands, that we DONT want to create records for.... so we need to get the inverse of these brands.

            List<Account> brandsToGetBSAs = new List<Account>();
            for(Account brand :AccountsThatNeedBSArecords){
                boolean AccFound = false;
                for(Brand_Segmentation_Approval__c bsa :segapprovalList){
                    // lets see if this brand, has a bsa
                    if(bsa.Brand__c == brand.Id){
                        AccFound = true;
                    }
                }
                if(!AccFound){
                    // means there is no 'in progress' bsa for this brand, so we can create one.
                    brandsToGetBSAs.add(brand);
                }
            }

            isAfterUpdate = false;
            // now that we have a good list of brands that need BSAs, we can get them created
            createNewSegmentationRecords(brandsToGetBSAs);        

        }

    }

    private static void createNewSegmentationRecords(List<Account> accountNewList){
         List<Brand_Segmentation_Approval__c> BSAlist = new List<Brand_Segmentation_Approval__c>();
            for (Account acc : accountNewList) {
                // means its a new record               
                    // its a brand account
                    // we need to add a new segmentation approval record for this new brand
                    Brand_Segmentation_Approval__c bsegApproval = new Brand_Segmentation_Approval__c();
                    bsegApproval.Brand__c = acc.Id;
                    bsegApproval.Status__c = 'New';
                    BSAlist.add(bsegApproval);                
            }
            System.debug('Inserting new Segmentation records ==== ' +  BSAlist +  ' for accounts: ' + accountNewList);
            if(BSAlist.size() > 0){
                System.debug('Inserting new Segmentation records');
                insert BSAlist;
            }
    }
    
    public static void checkForPrimaryVillage(List<Account> accountList){
        List<Account> accountsForVillage = new List<Account>();

        for(Account acc : accountList){
            if(acc.Primary_Village_of_Interest__pc == null){
                accountsForVillage.add(acc);
            }
        }

        if(accountsForVillage != null && !accountsForVillage.isEmpty()){
            Id userId = UserInfo.getUserId();
            User currentUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];

            if(currentUser.Village__c != null){
                for(Account acc : accountsForVillage){
                    acc.Primary_Village_of_Interest__pc = currentUser.Village__c;
                }
            }
        }
    }
    
    public static void checkDuplicateRuleRecordType(List<Account> accountList){
        Set<Id> masterRecordIds = new Set<Id>();
        for(Account acc: accountList){
            if(acc.MasterRecordId != null){
                masterRecordIds.add(acc.MasterRecordId);
            }
        }
        if(masterRecordIds.isEmpty()) return;
        
        Map<Id, Account> masterRecordAccounts = new Map<Id, Account>([SELECT Id, RecordTypeId FROM Account WHERE Id IN :masterRecordIds]);
        for(Account acc: accountList){
            if(acc.MasterRecordId != null && masterRecordAccounts.get(acc.MasterRecordId).RecordTypeId != acc.RecordTypeId){
                throw new CustomDuplicateRuleException('The selected Accounts cannot be merged because do not have same Record Type.');
            }
        }

    }
    
    public class CustomDuplicateRuleException extends Exception {}
}