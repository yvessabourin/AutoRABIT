trigger MarketingActivityTriggers on Marketing_Activity__c (after insert, before insert, after update, before update) {
    public static boolean isExecuteUpdate = True;
 
    
     id userId = userinfo.getUserId();
     Global_Object_Validation__c setting = Global_Object_Validation__c.getInstance(userId);

    //migration trigger logic
     list<string> MigratedataforActivityIdsList = new list<string>();
     if (trigger.isUpdate && trigger.isAfter){

         for(Marketing_Activity__c cActivity : trigger.newMap.values()){
             if(cActivity.Transfer_Redemptions_Now__c != trigger.oldMap.get(cActivity.Id).Transfer_Redemptions_Now__c
                                                    && cActivity.Transfer_Redemptions_Now__c == true ){
                 MigratedataforActivityIdsList.add(cActivity.Id);
                 system.debug('added ' + cActivity.Id + ' to list for processing');
             }
         }  
     }

     if (trigger.isInsert && trigger.isAfter){
         for(Marketing_Activity__c cActivity : trigger.newMap.values()){
             if(cActivity.Transfer_Redemptions_Now__c){
                 MigratedataforActivityIdsList.add(cActivity.Id);             
             }
         
         }

     }
     
     if(trigger.isInsert && trigger.isBefore){
       MarketingDefaultVillage.VillageDefault(trigger.new);
       MarketingActivityTriggerHandler.populateOracleProjectIds(Trigger.new);
     }
     
       if(trigger.isBefore){
       EmptyFieldStatus.EmptyStatus(trigger.new);
           MarketingActivityTriggerHandler.beforeUpdateAndInsert(trigger.new);
       }
     
     if(trigger.isAfter){
         if(setting.Marketing_Activity_Validations_Active__c){
             EmailMarketingActivity.sendEmailMarketingActivity(trigger.new);
         }
       }

     if(!MigratedataforActivityIdsList.isEmpty())
            RememptionMigrationHandler.MigrateRedemptions(MigratedataforActivityIdsList);
                    
    //SPLIT logic 
    if (trigger.isInsert && trigger.isAfter){
        MarketingSplitUtilities.splitPeriods(trigger.newMap.keySet());

    }

    if (trigger.isUpdate && trigger.isAfter){
    
        MarketingActivityUtilities.setCurrencyOnActivityBudgetSplits(trigger.new);
        MarketingActivityUtilities.checkAssociatedRecords(trigger.new);
        // check whether dates, expected or tracked values or split type have been updated ..
        set<Id> updateList = new set<Id>();
        for (Marketing_Activity__c mNew : trigger.newMap.values()){
            boolean updated = false;
            Marketing_Activity__c mOld = trigger.oldMap.get(mNew.Id);
            
            if (mNew.Start_Date__c != mOld.Start_Date__c)
                updated = true;
            
            if (mNew.End_Date__c != mOld.End_Date__c)
                updated = true;
            
            if (mNew.Split_Type__c != mOld.Split_Type__c)
                updated = true;
            
            if (mNew.Expected_Average_Spend__c != mOld.Expected_Average_Spend__c)
                updated = true; 
            
            if (mNew.Expected_Footfall__c != mOld.Expected_Footfall__c)
                updated = true;
                
            if (mNew.Expected_New_Members__c != mOld.Expected_New_Members__c)
                updated = true;
                
            if (mNew.Expected_Sales__c != mOld.Expected_Sales__c)
                updated = true;
                
            if (mNew.Tracked_Average_Spend__c != mOld.Tracked_Average_Spend__c)
                updated = true;     
                
            if (mNew.Tracked_Footfall__c != mOld.Tracked_Footfall__c)
                updated = true;
            
            if (mNew.Tracked_New_Members__c != mOld.Tracked_New_Members__c)
                updated  = true;
            
            if (mNew.Tracked_Sales__c != mOld.Tracked_Sales__c)
                updated = true;

            if (mNew.Reach__c != mOld.Reach__c)
                updated = true;
                                
            if (updated)
                updateList.add(mNew.Id);                        
        }
        if (!updateList.isEmpty())
            MarketingSplitUtilities.splitPeriods(trigger.newMap.keySet());
            
    }
    
   
    
 
    
    //Added logic for Marketing Activity - Finance integration batch apex callout.
    
    if(trigger.isAfter && trigger.isInsert){
        MarketingActivityTriggerHandler.handleAfterInsert(Trigger.oldMap, Trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        MarketingActivityTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.new);
    }
    

     //added logic for status value selection  
    if(trigger.isBefore && trigger.isUpdate){
        for(Marketing_Activity__c mAct : trigger.new){
            System.debug('old status**:'+Trigger.oldMap.get(mAct.id).status__c);
            if(Trigger.oldMap.get(mAct.id).status__c != Trigger.newMap.get(mAct.id).status__c){
                if(Trigger.oldMap.get(mAct.id).status__c =='To be Approved'){
                    System.debug('New Status$$:'+Trigger.newMap.get(mAct.id).status__c);  
                    if(Trigger.newMap.get(mAct.id).status__c !='Approved' && Trigger.newMap.get(mAct.id).status__c !='Cancelled'){
                        mAct.addError('Cannot select Status as On Hold or Completed for this record');
                    }
                }else if(Trigger.oldMap.get(mAct.id).status__c =='Approved'){
                    if(Trigger.newMap.get(mAct.id).status__c !='On Hold' && Trigger.newMap.get(mAct.id).status__c !='Cancelled' && Trigger.newMap.get(mAct.id).status__c !='Completed'){
                        mAct.addError('Cannot select Status as To be Approved for this record');
                    }  
                }else if(Trigger.oldMap.get(mAct.id).status__c =='On Hold'){
                    if(Trigger.newMap.get(mAct.id).status__c !='Approved' && Trigger.newMap.get(mAct.id).status__c !='Cancelled'){
                        mAct.addError('Cannot select Status as To be Approved or Completed for this record');
                    }    
                }else if(Trigger.oldMap.get(mAct.id).status__c =='Cancelled'){
                    if(Trigger.newMap.get(mAct.id).status__c !='On Hold' && Trigger.newMap.get(mAct.id).status__c !='Approved'){
                        mAct.addError('Cannot select Status as To be Approved or Completed for this record');
                    }                     
                } 
            } 
        }    
    }
    
    //added logic for status value selection on insert record
    if(trigger.isBefore && trigger.isInsert){
        for(Marketing_Activity__c mAct : trigger.new){
            if(mAct.status__c =='On Hold'){
                mAct.addError('Cannot select Status as On Hold for new Marketing Activity Record');
            }else if(mAct.status__c =='Cancelled'){
                mAct.addError('Cannot select Status as Cancelled for new Marketing Activity Record');    
            }else if(mAct.status__c =='Completed'){
                mAct.addError('Cannot select Status as Completed for new Marketing Activity Record');
            }
        }
    }
        
    
}