public class AdbuilderTriggerHandler {
    
    public static void AdbuilderInsert(List<Adbuilder__c> AdbuilderList ){
        
        List<Adbuilder__c> adList = new List<Adbuilder__c>();
        
        for (Adbuilder__c orderAdbuilderList : AdbuilderList){
            adList.add(orderAdbuilderList);
        }
        
        
        if(adList != null && !adList.isEmpty()){
            getMarketingCampa(adList);
        }
    }
    
    public static void dbuilderBeforeInsert(Map<Id, Adbuilder__c> oldADMap, Map<Id, Adbuilder__c> newADMap){
        List<Adbuilder__c> adList = new List<Adbuilder__c>();
        
        for(Adbuilder__c orderAdbuilderList : newADMap.values()){
            if(orderAdbuilderList.Marketing_Campaign__c == null && orderAdbuilderList.Marketing_Activity__c != null){
                adList.add(orderAdbuilderList);
            }
        }
        
        if(adList != null && !adList.isEmpty()){
            getMarketingCampa(adList);
        }
    }
    
    
    public static void getMarketingCampa(List<Adbuilder__c> AdUpdate){
        Map<Id, Id> campaigmmAP = new Map<Id, Id>();
        List<Marketing_Activity__c> actList = new List<Marketing_Activity__c>();
        
        for(Adbuilder__c orderAdbuilderList : AdUpdate){
            campaigmmAP.put(orderAdbuilderList.Marketing_Activity__c, null);
        }
        
        actList = [SELECT Id, Marketing_Campaign__c 
                   FROM Marketing_Activity__c 
                   WHERE Id IN :campaigmmAP.keySet()];
        
        if(actList != null && !actList.isEmpty()){
            for(Marketing_Activity__c act : actList){
                if(act.Marketing_Campaign__c != null){
                    campaigmmAP.put(act.Id, act.Marketing_Campaign__c);
                }
            }
        }
        
        for(Adbuilder__c orderAdbuilderList : AdUpdate){
            if(campaigmmAP.keySet().contains(orderAdbuilderList.Marketing_Activity__c)){
                orderAdbuilderList.Marketing_Campaign__c = campaigmmAP.get(orderAdbuilderList.Marketing_Activity__c);
                
            }
        }
    }
}