public with sharing class caseTriggerHandler{



    public static void handleAfterInsert(map<id, case> oldCases, map<id, case> newCases){
        
        set<id> ids=new set<id>();
        if(newcases.size()!=0 && newcases!=NULL){
            for(Case c: newCases.values()){
				if(c.Visit__c != NULL){
					ids.add(c.Visit__c);
				}		   
            }
            
            if(ids.size()!=0 && ids!=null){
            List<Visit__c> visitList = [Select Id, Total_Visit_Spend_HFS__c, CurrencyISOCode FROM Visit__c WHERE Id in :ids];
            System.Debug(' visits === ' + visitList + ' ===' + visitList.size());
            // then also get all the cases
            List<Case> cases = [Select Id, Visit__c, convertCurrency(Total_Spent_Amount__c), CurrencyISOCode FROM Case WHERE Visit__c = :ids];
            System.Debug(' cases === ' + cases + ' ===' + cases.size());
            for(Visit__c vst :visitList){
                Decimal vstTotalHFSSpend = 0.0;
                for(Case cs :cases){
                    if(cs.Visit__c == vst.Id){
                        // then add the case to the list for the Sum
                        vstTotalHFSSpend += cs.Total_Spent_Amount__c;
                        
                        System.Debug(' cs.CurrencyISOCode MODDED === ' + cs.CurrencyISOCode);
                    }
                }
                
                vst.Total_Visit_Spend_HFS__c = vstTotalHFSSpend;
                System.Debug(' vst.Total_Visit_Spend_HFS__c === ' +  vst.Total_Visit_Spend_HFS__c);
            }
            update visitList;
        }
            
        }

        /*
        System.Debug(' oldCases === ' + oldCases);
        System.Debug(' newCases === ' + newCases);
        
        List<Id> visitsForCaseIdList = new List<Id>();
        Map<Id, String> visitSpendMap = new Map<Id, String>();
        
        System.Debug('visitSpendMap' + visitSpendMap);
        
        for(Case cs : newCases.values()){
            if(cs.Total_Spent_Amount__c != oldCases.get(cs.Id).Total_Spent_Amount__c){
                System.Debug('cs.Total_Spent_Amount__c' + cs.Total_Spent_Amount__c);
            	visitsForCaseIdList.add(cs.Visit__c);
                visitSpendMap.put(cs.Visit__c, String.valueOf(cs.Total_Spent_Amount__c));
        	}
        }
        
        List<Visit__c> visitList = [SELECT Id FROM Visit__c WHERE Id IN :visitSpendMap.KeySet()];
        
        for(Visit__c visit : visitList){
            if(visitSpendMap.keySet().contains(visit.Id)){
                visit.Total_Visit_Spend_HFS__c = Decimal.valueOf(visitSpendMap.get(visit.Id));
            }
        }
        
        UPDATE visitList;*/
        

        list<id> collectionPointsChanged = new list<id>();
            for(case c : newCases.values()){
                if(c.HFS_Collection_Location__c != oldCases.get(c.id).HFS_Collection_Location__c){
                       collectionPointsChanged.add(c.id);
                    }
            }
        
        list<Case_Item__c> purchases = [Select id, Name,Case__c  FROM Case_Item__c where Case__c IN: collectionPointsChanged];
        list<HFS_Bag__c> bags = [SELECT id, Name,HFS_Purchase__c,At_InCorrect_Storage_Location__c,In_Storage_Point__c, HFS_Purchase__r.case__r.id,HFS_Storage_Location__r.HFS_Storage_Point__r.Name FROM HFS_Bag__c where HFS_Purchase__c IN: purchases AND In_Storage_Point__c = true];
        list<HFS_Bag__c> bagstoUpdate = new list<HFS_Bag__c>(); 

        map<id, map<id,list<HFS_Bag__c>>> CPBMap = new map<id, map<id,list<HFS_Bag__c>>>();
        
            for(case c : newCases.values()){
                //if(CPBMap.get(c.id) == NULL){
                    CPBMap.put(c.id, new map<id,list<HFS_Bag__c>>{}) ;
                //}
            }
        
        system.debug('CPBMap one :' + CPBMap);
        
            for(Case_Item__c ci : purchases){
                CPBMap.get(ci.Case__c).put(ci.id, new list<HFS_Bag__c>{});    
            }
        
        system.debug('CPBMap two :' + CPBMap);
        
            for(HFS_Bag__c bag : bags){
                CPBMap.get(bag.HFS_Purchase__r.case__r.id).get(bag.HFS_Purchase__c).add(bag);    
            }
        system.debug('CPBMap three :' + CPBMap);


            for(id caseId : CPBMap.keyset()){
                for(id purId : CPBMap.get(caseId).keyset()){
                    for(HFS_Bag__c bag : CPBMap.get(caseId).get(purId)){
                        if(bag.HFS_Storage_Location__r.HFS_Storage_Point__r.Name != newCases.get(bag.HFS_Purchase__r.case__r.id).HFS_Collection_Location__c && bag.In_Storage_Point__c == true){
                            bag.At_InCorrect_Storage_Location__c = true;
                            bagstoUpdate.add(bag);
                        }
                        else if(bag.HFS_Storage_Location__r.HFS_Storage_Point__r.Name == newCases.get(bag.HFS_Purchase__r.case__r.id).HFS_Collection_Location__c && bag.In_Storage_Point__c == true){
                             bag.At_InCorrect_Storage_Location__c = false;
                             bagstoUpdate.add(bag);
                        }
                    }
                }


            }

            update bagstoUpdate;
    
    
    }
    


}