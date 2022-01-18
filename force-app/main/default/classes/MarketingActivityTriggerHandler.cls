public class MarketingActivityTriggerHandler 
{
    private static List <String> fieldsToTriggerIntegration = new List <String> {'Re_send_to_Oracle_for_NewActivity__c','Transfer_to_Oracle__c','Name','Start_Date__c','End_Date__c','Status__c','CreatedDate','Business_Function__c','Channel__c','Sub_Channel__c','Expenditure_Category__c','Expenditure_Type__c','Oracle_Project_Id__c'};
    
    public static void beforeUpdateAndInsert(list<Marketing_Activity__c> maList) {
        
        List<Id> mcIdList = new List<Id>();
        
        for(Marketing_Activity__c ma : maList){
        	mcIdList.add(ma.Marketing_Campaign__c);
        }
    	     
		List<Marketing_Campaign__c> mcList = [SELECT Id, Village__r.name FROM Marketing_Campaign__c where Id = :mcIdList];
        Map<Id,Marketing_Campaign__c> mcMap = new Map<Id,Marketing_Campaign__c>();
        
        for(Marketing_Campaign__c mc: mcList){           
            mcMap.put(mc.id,mc);            
        }                     
        
    	for(Marketing_Activity__c ma : maList){
        	Marketing_Campaign__c mc = mcMap.get(ma.Marketing_Campaign__c);
            if( (ma.Market__c=='Belgium' && mc.Village__r.name=='Maasmechelen') || (ma.Market__c=='France' && mc.Village__r.name=='La Vallée') 
              || (ma.Market__c=='Germany' && (mc.Village__r.name=='Ingolstadt' || mc.Village__r.name=='Wertheim')) || (ma.Market__c=='Ireland' && mc.Village__r.name=='Kildare') 
              || (ma.Market__c=='Italy' && mc.Village__r.name=='Fidenza')  || (ma.Market__c=='Netherlands' && mc.Village__r.name=='Maasmechelen') 
              || (ma.Market__c=='Northern Ireland' && mc.Village__r.name=='Kildare')  || (ma.Market__c=='Spain' && (mc.Village__r.name=='La Roca' ||mc.Village__r.name=='Las Rozas')) 
              || (ma.Market__c=='United Kingdom' && mc.Village__r.name=='Bicester') ){
            	ma.Domestic__c=true;
        	} else {
                ma.Domestic__c=false;
            }
    	}
       
        lockCloneFields(maList);
    }

    public static void populateOracleProjectIds (List <Marketing_Activity__c> newMarketingActivities) {

        Set<Id> marketingCampaignIds = new Set <Id> ();

        for (Marketing_Activity__c marketingActivity : newMarketingActivities) {
            marketingCampaignIds.add(marketingActivity.Marketing_Campaign__c);
        }

        Map <Id, Marketing_Campaign__c> marketingCampaignsMap = new Map <Id, Marketing_Campaign__c> ([SELECT Oracle_Project_Id__c, Oracle_Secondary_Project_Id__c FROM Marketing_Campaign__c WHERE Id IN: marketingCampaignIds]);

        for (Marketing_Activity__c marketingActivity : newMarketingActivities) {
            marketingActivity.Oracle_Project_Id__c = marketingCampaignsMap.get(marketingActivity.Marketing_Campaign__c).Oracle_Project_Id__c;
            marketingActivity.Oracle_Secondary_Project_Id__c = marketingCampaignsMap.get(marketingActivity.Marketing_Campaign__c).Oracle_Secondary_Project_Id__c;
        }
    }


    //START ORACLE INTEGRATION METHODS

    public static void handleAfterInsert(Map <Id, Marketing_Activity__c> oldMap, List<Marketing_Activity__c> newMarketingActivities) {
        Set <Id> marketingActivitiesToSend = new Set<Id> ();
        for (Marketing_Activity__c marketingActivity : newMarketingActivities) {
            if (isReadyToSend(marketingActivity)) {
                marketingActivitiesToSend.add(marketingActivity.Id);
            }

        }
        if (!marketingActivitiesToSend.isEmpty()) {
            insertInOracle(marketingActivitiesToSend);
            changeToSendingState(marketingActivitiesToSend);
        }
    }

    public static void handleAfterUpdate (Map <Id, Marketing_Activity__c> oldMap, List<Marketing_Activity__c> updatedMarketingActivities) {
        Set <Id> newOracleActivities = new Set <Id>();
        Set <Id> existingOracleActivities = new Set <Id>();
        Map <Id, Marketing_Activity__c> lastModifiedByMap = new Map <Id, Marketing_Activity__c> ([SELECT LastModifiedBy.Name FROM Marketing_Activity__c WHERE Id IN: updatedMarketingActivities]); 
        if(!System.isBatch()){
            for (Marketing_Activity__c marketingActivity : updatedMarketingActivities) {
                //We check for two things:
                // 1. If we just changed the status to sending, we don't send it again because we have already changed that
                // 2. If the marketing activity is ready to send
                // 3. We check that if the LastModified user is the Integration User, we don't want to resend anything (recursivity) UNLESS that what has been updated is the Project Id
                // 4. Check that either a relevant field has changed and it's being resent
                if (marketingActivity.Integration_Status__c != 'sending' || isResending(oldMap.get(marketingActivity.Id), marketingActivity)) {
                    if (isReadyToSend(marketingActivity) && (lastModifiedByMap.get(marketingActivity.Id).LastModifiedBy.Name != Label.DataIntegrationUser || marketingActivity.Oracle_Project_Id__c != oldMap.get(marketingActivity.Id).Oracle_Project_Id__c)) {
                        if (hasChangedFields(oldMap.get(marketingActivity.Id), marketingActivity)) {
                            if (String.isNotBlank(marketingActivity.Oracle_Task_Id__c) || String.isNotBlank(marketingActivity.Oracle_Secondary_Task_Id__c)) {
                                existingOracleActivities.add(marketingActivity.Id);
                            } else {
                                newOracleActivities.add(marketingActivity.Id);
                            }
                        }
                    }
                }
            }
            
            if (!newOracleActivities.isEmpty()) {
                insertInOracle(newOracleActivities);
            }
            if (!existingOracleActivities.isEmpty()) {
                updateInOracle(existingOracleActivities);
            }
            
            Set <Id> allActivitiesToSend = new Set <Id> ();
            allActivitiesToSend.addAll(newOracleActivities);
            allActivitiesToSend.addAll(existingOracleActivities);
            changeToSendingState(allActivitiesToSend);

        }
    }

    public static Boolean isReadyToSend (Marketing_Activity__c marketingActivity) {
        return  (marketingActivity.Transfer_to_Oracle__c &&
                (String.isNotBlank(marketingActivity.Oracle_Project_Id__c) || String.isNotBlank(marketingActivity.Oracle_Secondary_Project_Id__c)));
    }

    public static void insertInOracle (Set <Id> newOracleActivities) {
        Database.executeBatch(new MarketingActivityBatchCallout(newOracleActivities),30);
    }

    public static void updateInOracle (Set <Id> existingOracleActivities) {
        Database.executeBatch(new MarketingActivityUpdateBatchCallout(existingOracleActivities),30);
    }

    public static void changeToSendingState(Set <Id> marketingActivityIds) {
        List <Marketing_Activity__c> marketingActivitiesUpdate = new List <Marketing_Activity__c> ();
        for (Id marketingActivityId : marketingActivityIds) {
            marketingActivitiesUpdate.add(new Marketing_Activity__c(Id=marketingActivityId, Integration_Status__c='sending'));
        }
        update marketingActivitiesUpdate;
    }

    public static Boolean hasChangedFields (Marketing_Activity__c oldActivity, Marketing_Activity__c newActivity) {
        
        for (String field : fieldsToTriggerIntegration) {
          if (isFieldChanged(oldActivity, newActivity, field)) {
            return true;
          }
        }
        return false;
    }
    
    public static Boolean isFieldChanged (Marketing_Activity__c oldRecord, Marketing_Activity__c newRecord, String fieldName) {
        return oldRecord.get(fieldName) != newRecord.get(fieldName);
    }

    public static Boolean isResending (Marketing_Activity__c oldRecord, Marketing_Activity__c newRecord) {
        return (oldRecord.Re_send_to_Oracle_for_NewActivity__c != newRecord.Re_send_to_Oracle_for_NewActivity__c) && newRecord.Re_send_to_Oracle_for_NewActivity__c;
    }

    public static void lockCloneFields (list<Marketing_Activity__c> markActList) {
        for(Marketing_Activity__c markAct : markActList) {
            if (markAct.isClone()) {
                markAct.Oracle_Task_Id__c = '';
                markAct.Oracle_Task_Number__c = '';

                markAct.Oracle_Secondary_Task_Id__c = '';
                markAct.Oracle_Secondary_Task_Number__c = '';
            }
        }
    }

    //END ORACLE INTEGRATION METHODS
    
}