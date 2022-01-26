trigger VillagePresenceTriggers on Village_Presence__c (after insert, after update, before insert, before update) {

    if(trigger.isAfter && trigger.isInsert){
        VillagePresenceUtilities.defaultName(trigger.newMap.keySet());
        VillagePresenceUtilities.linkCompetitorStores(trigger.newMap.keySet());
        VillagePresenceUtilities.recalculateBrandAssignmentType(trigger.new);

    }
    
    if (trigger.isAfter && trigger.isUpdate){

        set<Id> vpIds = new set<Id>();
        for (string key :trigger.newMap.keySet()){
            decimal projectedSalesYield = trigger.oldMap.get(key).Projected_Sales_Yield_Local__c;
            decimal projectedReturn = trigger.oldMap.get(key).Projected_Return_Local__c;
            string unit = trigger.oldMap.get(key).Unit__c;
                       
            if (projectedSalesYield != trigger.newMap.get(key).Projected_Sales_Yield_Local__c || 
                        projectedReturn != trigger.newMap.get(key).Projected_Return_Local__c ||
                        unit != trigger.newMap.get(key).Unit__c){
                vpIds.add(key);
            }   
        }
        if (!vpIds.isEmpty()){
            OpportunityRatingCalculator.calculateVPRating(vpIds);
        }

        VillagePresenceUtilities.changeCertificationType(trigger.old, trigger.new);
        VillagePresenceUtilities.avoidBlankCertification(trigger.new);
    }

    if (trigger.isBefore && trigger.isUpdate){
        VillagePresenceUtilities.defaultNameOnUpdate(trigger.old, trigger.new);
    }
    
    if (trigger.isBefore && trigger.isInsert){
        VillagePresenceUtilities.checkDuplicate(trigger.new);
    }
}