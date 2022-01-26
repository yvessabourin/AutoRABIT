public class competitorSiteVisitTriggerHandler{


    public static void handleBeforeInsert(){
    
    }
    
    
    public static void handleAfterInsert(){
    
    }
    
    
    public static void handleBeforeUpdate(){
    
    }
    
    
    public static void handleAfterUpdate(map<id, Competitor_Visit__c> oldVisitMap, map<id,Competitor_Visit__c> newVisitMap){
    
        list<id> sharedCompSiteVisits = new list<id>();
    
        for(Id id : newVisitMap.keyset()){
            if(newVisitmap.get(id).Share_Site_Visit_Info__c == true){
                if(newVisitmap.get(id).Share_Site_Visit_Info__c != oldVisitmap.get(id).Share_Site_Visit_Info__c){
                    sharedCompSiteVisits.add(newVisitmap.get(id).id);
                }
            }
        }
    
        if(sharedCompSiteVisits.size() > 0 && sharedCompSiteVisits != null){
             compSiteVisitEmailHandler.sendEmails(sharedCompSiteVisits);
        }
         
    }

}