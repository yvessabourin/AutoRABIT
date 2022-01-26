public class BusinessUnitCodeUpdateHandler {

    public static Map <Id, List<Business_Unit__c>> bUnitsMap;

    public static void updateBusinessUnitCode(Marketing_Campaign__c mCamp){

        if (bUnitsMap == null) {
            getBusinessUnits();
        }

        List <Business_Unit__c> villageBusinessUnits = bUnitsMap.get(mCamp.Village__c);
        
        if (villageBusinessUnits != null) {
            if(villageBusinessUnits.size()>0){
                mcamp.Business_Unit_Code1__c = villageBusinessUnits[0].Business_Unit_Code__c;
            }
            if(villageBusinessUnits.size()>1){
                mcamp.Business_Unit_Code2__c = villageBusinessUnits[1].Business_Unit_Code__c;
            }
        }
    }

    public static void getBusinessUnits () {
        Business_Unit__c[] bUnits = [Select id, Business_Unit_Code__c,OraclePrimaryBusinessUnit__c, Village__c from Business_Unit__c];
        bUnitsMap = new Map <Id, List <Business_Unit__c>> ();
        for (Business_Unit__c bUnit : bUnits) {
            if(bUnitsMap.containsKey(bUnit.Village__c)) {
                bUnitsMap.get(bUnit.Village__c).add(bUnit);
            } else {
                bUnitsMap.put(bUnit.Village__c, new List <Business_Unit__c> {bUnit});
            }
        }
    }
}