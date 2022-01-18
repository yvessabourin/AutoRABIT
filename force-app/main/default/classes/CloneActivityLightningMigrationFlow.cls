global with sharing class CloneActivityLightningMigrationFlow {
    
   public List<Marketing_Activity__c> selectedActivity {get; set;}
    
     public CloneActivityLightningMigrationFlow(ApexPages.StandardSetController controller){
        selectedActivity = (List<Marketing_Activity__c>)controller.getSelected();
    }
    
 @InvocableMethod(Label='Clone Activity')	
    public static void cloneActivityFlow (List<List<Marketing_Activity__c>> listIdActvi){
               List<String> activityList = new List<String>(); 
           for(List<Marketing_Activity__c> actList: listIdActvi){
            for(Marketing_Activity__c act: actList){
                activityList.add(act.Id);
            }
        }
        CloneActivityHelper.cloneWithId(activityList);
         
    }

}