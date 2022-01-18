Global Class HFSReplenishmentDailyJob implements Schedulable, Database.Batchable<sObject> {

    /*BATCH EXECUTION*/
    
    global List<Village_Presence__c> start (Database.BatchableContext BC) {
        return [SELECT id, Name,HFS_Bags_Left__c ,HFS_Bags_Received__c,HFS_Bags_Used__c,HFS_Threshold__c, Replenish__c FROM Village_Presence__c WHERE Is_HFS_Active__c = true ORDER BY Village__c];
    }

    global void execute (Database.BatchableContext BC, List<Village_Presence__c> vps) {
        
        for(Village_Presence__c vp : vps){
            vp.HFS_Bags_Received__c = vp.HFS_Bags_Left__c;
            vp.HFS_Bags_Used__c = 0;          
        }
        update vps;        
    }

    global void finish (Database.BatchableContext BC) {

    }

    /*SCHEDULABLE EXECUTION*/
    global void execute(SchedulableContext sch) {

 	    Database.executebatch(new HFSReplenishmentDailyJob(),Integer.valueOf(Global_Properties__c.getInstance('REPLENISHMENT_BAG_JOB_SIZE').Value__c));
       
   }
}