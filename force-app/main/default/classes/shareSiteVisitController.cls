public class shareSiteVisitController{


    @AuraEnabled
    public static string share(id theid){
    
    Competitor_Visit__c cv = [SELECT id, name,Share_Site_Visit_Info__c FROM Competitor_Visit__c WHERE id =:theid];
    
        if(cv.Share_Site_Visit_Info__c == false){
            cv.Share_Site_Visit_Info__c = true;
            try{
            update cv;
            return 'Success';
            }
            catch (Exception e){
                return e.getmessage();
            }
        }
        else{
            return 'This Visit has already been shared';
        }
    }
    
  

}