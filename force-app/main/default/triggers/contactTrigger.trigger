trigger contactTrigger on Contact (before insert, before update) {

    String userName = UserInfo.getUserName();
    system.debug('username = ' + userName); 
    system.debug('label name = ' + label.DeploymentUser);     
    if(userName != label.DeploymentUser){
    
    if (trigger.isBefore && trigger.isInsert){
        contactTriggerHelper.primaryContactCheck(trigger.new);
        contactTriggerHelper.checkDuplicate(trigger.new);
        contactTriggerHelper.populateUniqueKey(trigger.new);
        contactTriggerHelper.updateRelatedAccount(Trigger.new);
    }
    if (trigger.isBefore && trigger.isUpdate){
        //contactTriggerHelper.populateUniqueKey(trigger.new);
        contactTriggerHelper.primaryContactCheck(trigger.new);
    }
  }
}