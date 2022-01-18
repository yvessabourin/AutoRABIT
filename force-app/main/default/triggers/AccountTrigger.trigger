trigger AccountTrigger on Account (after update,  after insert, before update, before insert, after delete) {

    String userName = UserInfo.getUserName();
    system.debug('username = ' + userName); 
    system.debug('label name = ' + label.DeploymentUser);     
    if(userName != label.DeploymentUser){    
    
    set<Id> accountIds = new set<Id>();

    if(trigger.isBefore && trigger.isInsert){
        Id guestId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Guest').getRecordTypeId();
        Id vipGuestId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('VIP Guest').getRecordTypeId();
        List<Account> accsToInsert = new List<Account>();

        for(Account acc : trigger.new){
            if(acc.RecordTypeId == guestId || acc.RecordTypeId == vipGuestId){
                accsToInsert.add(acc);
            }
        }

        if(accsToInsert != null && !accsToInsert.isEmpty()){
            AccountTriggerHelper.checkForPrimaryVillage(trigger.new);
        }
    }
    
    if (trigger.isAfter && trigger.isUpdate){

        for (Account a :trigger.new){
            // check for name update
            if(trigger.oldMap.get(a.id).Name != a.Name){
                accountIds.add(a.Id);
            }                               
        }
        if (!accountIds.isEmpty()){
            // Update any associated Deal and VP names if there is an Account name change
            AccountTriggerHelper.updateDealAndVPNames(accountIds);
        }
        
    }
    
     if (trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
        AccountTriggerHelper.onAfterUpdateOrInsert(trigger.newMap, trigger.oldMap , trigger.new, trigger.old , trigger.isUpdate, trigger.isInsert);
     }

    if (trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){
        
        AccountTriggerHelper.checkName(trigger.new);  
        AccountTriggerHelper.onBeforeUpdateOrInsert(trigger.newMap, trigger.oldMap , trigger.new, trigger.old , trigger.isUpdate, trigger.isInsert);
     }
    
    if (trigger.isAfter && trigger.isDelete){
        AccountTriggerHelper.checkDuplicateRuleRecordType(trigger.old);
    }
    
    }
        
}