public without sharing class VIPBrandPreferenceUtilities{


 // Method to default village presence name after insert or update
  public static void defaultName(List<VIP_Brand_Preference__c> newMap){
  
  Set<Id> newValueUpdatedVP = new Set<Id>();
    for(VIP_Brand_Preference__c VBPID : newMap){
      newValueUpdatedVP.add(VBPID.Village_Presence__c);
    }
    if (!newValueUpdatedVP.isEmpty()){
      
      Map<ID, Village_Presence__c> villagePresenceList = new Map<ID, Village_Presence__c>([select Id, name, brand__r.name from Village_Presence__c where id in:newValueUpdatedVP]);
      if (!villagePresenceList.isEmpty()){
          for (VIP_Brand_Preference__c BrandPreference : newMap){
             BrandPreference.name = villagePresenceList.get(BrandPreference.Village_Presence__c).brand__r.name;
             
            }
     
      }
    }  
  }
  
    public static void defaultNameOnUpdate(List<VIP_Brand_Preference__c> oldMap, List<VIP_Brand_Preference__c> newMap){

    Set<Id> oldValueUpdatedVP = new Set<Id>();
    for(VIP_Brand_Preference__c oldValue : oldMap){
      oldValueUpdatedVP.add(oldValue.Id);
    }


    List<VIP_Brand_Preference__c> oldBrandPreferenceList = [SELECT Name, Village_Presence__r.Brand__r.Name FROM VIP_Brand_Preference__c WHERE Id IN:oldValueUpdatedVP];


    for(VIP_Brand_Preference__c theOldVBP : oldBrandPreferenceList){
      for (VIP_Brand_Preference__c BrandPreference : newMap){
        if(theOldVBP.Id == BrandPreference.Id){
       // System.AssertEquals(1,2,'-------' + theOldVBP.Village_Presence__r.Brand__r.Name);
          string brand = theOldVBP.Village_Presence__r.Brand__r.Name;
        
          BrandPreference.name = brand;
        }
      }
    }
  }
  
}