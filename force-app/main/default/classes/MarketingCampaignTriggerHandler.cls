public class MarketingCampaignTriggerHandler{

  private static Map<String, Schema.RecordTypeInfo> marketingCampaignRecordTypeMap = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByDeveloperName();
  private static Village__c groupVillage;
  private static List <String> fieldsToTriggerIntegration = new List <String> {'Re_send_to_Oracle__c','Transfer_to_Oracle__c','Name','Start_Date__c','End_Date__c','RecordTypeId','Status__c','CreatedDate','Village__c'};

  public static void handlBeforeUpdate(Map<Id, Marketing_Campaign__c> oldMCs, List<Marketing_Campaign__c > newMCs){
      
    Integer psacount = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Edit_Marketing_Campaign_Level_Themes_Lead_Group_Tactical'];

    list<Marketing_Campaign__c> statusChangeMCs = new list<Marketing_Campaign__c>();
    for(Marketing_Campaign__c newMC : newMCs){
      if(oldMCs.get(newMC.Id).Status__c != newMC.Status__c && newMC.Status__c != 'Approved' && newMC.Status__c != 'To Be Approved' ){
        statusChangeMCs.add(newMC);
      }
      validateCampaignStatusOnUpdate(oldMCs.get(newMC.Id), newMC);
    }


    list<Marketing_Activity__c> MAs = [SELECT id, name, status__c,Marketing_Campaign__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c in:statusChangeMCs AND status__c != 'Cancelled'];
    map<id,list<Marketing_Activity__c>> campaignActivityMap = new map<id,list<Marketing_Activity__c>>();
      for(Marketing_Activity__c MA : MAs){
        if(!campaignActivityMap.containsKey(MA.Marketing_Campaign__c)){
          campaignActivityMap.put(MA.Marketing_Campaign__c, new List<Marketing_Activity__c>{MA});
        }
        else
        {
          campaignActivityMap.get(MA.Marketing_Campaign__c).add(MA);
        }
    }


    boolean old_MC_Theme_LeadGroupCampaign = False;
    boolean fieldhaschanged = False;
      
    for(Marketing_Campaign__c newMC : newMCs){
        Marketing_Campaign__c oldMC = (Marketing_Campaign__c)oldMCs.get(newMC.id);

        if(oldMC.Campaign_Level__c == 'Theme' || oldMC.Campaign_Level__c == 'Lead Group Campaign'){
            old_MC_Theme_LeadGroupCampaign = True;
        }

        if(oldMC.Campaign_Level__c != newMC.Campaign_Level__c){
            fieldhaschanged = True;
        }  

        if(old_MC_Theme_LeadGroupCampaign && fieldhaschanged && psacount == 0 ){
        newMC.addError('You are not permitted to edit the Campaign Level field on "Themes" or "Lead Group Campaigns"');
        }

        if(campaignActivityMap != NULL && !campaignActivityMap.isEmpty() && campaignActivityMap.get(newMC.id) != NULL && campaignActivityMap.get(newMC.id).size() > 0 ){
        
          newMC.addError('<span><b>You cannot set the Status as "Cancelled" before you reassign all its associated "Live" Marketing activities or set them to "cancelled"</b></br><b>Please use the "Reassign Activites" button below which will allow you to reassign or change Status\'</b></span>',false); 
        //newMC.addError('You cannot set the Status as "Cancelled" before you reassign all its associated "Live" Marketing activities or set them to "cancelled".Please use the "Reassign Activites" button below');                
        }
        

    }
  }

  public static void validateCampaignStatusOnUpdate(Marketing_Campaign__c oldMaCampaign, Marketing_Campaign__c newMaCampaign) {
    System.debug('old status**:'+oldMaCampaign.status__c);
    if(oldMaCampaign.status__c != newMaCampaign.status__c){
        if(oldMaCampaign.status__c =='To be Approved'){
            System.debug('New Status$$:'+newMaCampaign.status__c);  
            if(newMaCampaign.status__c !='Approved' && newMaCampaign.status__c !='Cancelled'){
              newMaCampaign.addError('Cannot select Status as On Hold for this record');
            }
        }else if(oldMaCampaign.status__c =='Approved'){
            if(newMaCampaign.status__c !='On Hold' && newMaCampaign.status__c !='Cancelled'){
              newMaCampaign.addError('Cannot select Status as To be Approved for this record');
            }  
        }else if(oldMaCampaign.status__c =='On Hold'){
            if(newMaCampaign.status__c !='Approved' && newMaCampaign.status__c !='Cancelled'){
              newMaCampaign.addError('Cannot select Status as To be Approved for this record');
            }    
        }else if(oldMaCampaign.status__c =='Cancelled'){
            if(newMaCampaign.status__c !='On Hold' && newMaCampaign.status__c !='Approved'){
              newMaCampaign.addError('Cannot select Status as To be Approved for this record');
            }                     
        } 
    }
  }

  //General handler for beforeInsert actions
  public static void handleBeforeInsert(List <Marketing_Campaign__c> newCampaigns) {
    for (Marketing_Campaign__c newCampaign : newCampaigns) {
      validateCampaignStatusOnCreate(newCampaign);
      asignGroupVillage(newCampaign);
      BusinessUnitCodeUpdateHandler.updateBusinessUnitCode(newCampaign);
    }
  }
  
  //added logic for status value selection on insert record
  public static void validateCampaignStatusOnCreate (Marketing_Campaign__c newCampaign) {
      if(newCampaign.status__c =='On Hold'){
        newCampaign.addError('Cannot select Status as On Hold for new Marketing Campaign Record');
      }else if(newCampaign.status__c =='Cancelled'){
        newCampaign.addError('Cannot select Status as Cancelled for new Marketing Campaign Record');    
      }
  }

  public static void asignGroupVillage (Marketing_Campaign__c newCampaign) {
    
    if (groupVillage == null) {
      List<Village__c> groupVillageList = [Select id , Name from Village__c where name='Group'];
      //Avoid errors and multiple queries in the same execution by initializing the value only once
      groupVillage = groupVillageList.isEmpty() ? new Village__c() : groupVillageList[0];
    }

    if(newCampaign.RecordTypeId == marketingCampaignRecordTypeMap.get('TBVSC_Brand_Campaign').getRecordTypeId()){
      newCampaign.Village__c= groupVillage.Id;
    }
  }

  //ORACLE INTEGRATION METHODS

  public static void handleAfterInsert(List <Marketing_Campaign__c> insertedCampaigns) {
    Set <Id> campaignsToSend = new Set <Id>();

    for (Marketing_Campaign__c mCampaign : insertedCampaigns) {
      if (mCampaign.Transfer_to_Oracle__c) {
        campaignsToSend.add(mCampaign.Id);
      }
    }

    if (!campaignsToSend.isEmpty()) {
      Database.executeBatch(new MarketingCampaignBatchCallout(trigger.newMap.keySet()), 30);
      changeToSendingState(campaignsToSend);
    }
  }

  public static void handleAfterUpdate(Map<Id, Marketing_Campaign__c> oldMap, List <Marketing_Campaign__c> updatedCampaigns) {
    Set <Id> newOracleCampaigns = new Set <Id>();
    Set <Id> existingOracleCampaigns = new Set <Id>();

    for(Marketing_Campaign__c mCampaign : updatedCampaigns) {
      if (mCampaign.Integration_Status__c != 'sending' || isResending(oldMap.get(mCampaign.Id), mCampaign)) {
        if (mCampaign.Transfer_to_Oracle__c) {
          if ((hasChangedFields(oldMap.get(mCampaign.Id), mCampaign) && mCampaign.Integration_Status__c != 'sending') || isResending(oldMap.get(mCampaign.Id), mCampaign)) { //We check is the Campaign is ready to be sent and if it's already being sent to avoid recurrence
            if (mCampaign.Oracle_Project_Id__c != null) {
              existingOracleCampaigns.add(mCampaign.Id);
            } else {
              newOracleCampaigns.add(mCampaign.Id);
            }
          }
        }
      }
    }

    if (!newOracleCampaigns.isEmpty()) {
      Database.executeBatch(new MarketingCampaignBatchCallout(newOracleCampaigns),30);
    }
    if (!existingOracleCampaigns.isEmpty()) {
      Database.executeBatch(new MarketingCampaignUpdateBatchCallout(existingOracleCampaigns),30);
    }

    Set <Id> allCampaignsToSend = new Set <Id> ();
    allCampaignsToSend.addAll(newOracleCampaigns);
    allCampaignsToSend.addAll(existingOracleCampaigns);
    changeToSendingState(allCampaignsToSend);    

  }

  public static void changeToSendingState(Set <Id> marketingCampaignIds) {
    List <Marketing_Campaign__c> marketingCampaignsUpdate = new List <Marketing_Campaign__c> ();
    for (Id marketingCampaignId : marketingCampaignIds) {
      marketingCampaignsUpdate.add(new Marketing_Campaign__c(Id=marketingCampaignId, Integration_Status__c='sending'));
    }
    update marketingCampaignsUpdate;
  }

  public static Boolean hasChangedFields (Marketing_Campaign__c oldCampaign, Marketing_Campaign__c newCampaign) {
        
    for (String field : fieldsToTriggerIntegration) {
      if (isFieldChanged(oldCampaign, newCampaign, field)) {
        return true;
      }
    }
    return false;
  }

  public static Boolean isFieldChanged (Marketing_Campaign__c oldRecord, Marketing_Campaign__c newRecord, String fieldName) {
    return oldRecord.get(fieldName) != newRecord.get(fieldName);
  }

  public static Boolean isResending (Marketing_Campaign__c oldRecord, Marketing_Campaign__c newRecord) {
    return (oldRecord.Re_send_to_Oracle__c != newRecord.Re_send_to_Oracle__c) && newRecord.Re_send_to_Oracle__c;
  }

  //END ORACLE INTEGRATION METHODS
  
}