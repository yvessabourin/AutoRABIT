global with sharing class calculateRatingsForVillageButtonFlow {
    @InvocableMethod(Label='Ratings Villages')	
    
    public static void calculateRatingsForVillage (List<Id> villageId){
        
        try{  
            
            for (list<Opportunity> oppList : [select Id, Name, Village__c, Projected_Income_Yield__c,
                                              Projected_Yield__c, Sales_Rating__c, Income_Rating__c
                                              from Opportunity where Village__r.Id = :villageId]){
                                                  
                                                  OpportunityRatingCalculator.calculateRating(oppList);
                                                  update oppList;
                                              }
            
        } catch (exception e){
            system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
        }
        
    }
}