public class MarketingDefaultVillage {
    
    public static void VillageDefault(List<Marketing_Activity__c> listMarketing) {
    User us = [select Id, Village__c from User where id =:UserInfo.getUserId()];
     for (Marketing_Activity__c marc : listMarketing) {
        marc.Picklist_Multi_Select__c = us.Village__c;
        }
}
    }