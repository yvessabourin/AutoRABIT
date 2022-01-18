trigger TaskTriggers on Task (after insert, after update) {

    if (trigger.isAfter && trigger.isInsert){
        string exeTime = system.now().addSeconds(30).format('ss mm HH dd MM ? yyyy');
        string guid = guidGenerator.NewGuid();
        System.schedule('taskTrigger' + exeTime + guid, exeTime , new scheduleTaskUpdate(trigger.newMap.keySet()));
        TaskTriggerHelper.updateRelatedAccount(Trigger.new);
    }
}