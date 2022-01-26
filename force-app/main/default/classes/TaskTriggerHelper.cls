public with sharing class TaskTriggerHelper {

    public static void updateRelatedAccount(List<Task> taskList){
        List<Id> accIdList = new List<Id>();
        
        for(Task task : taskList){
            accIdList.add(task.AccountId);
        }
        if(!accIdList.isEmpty()){
            UpdateRelatedAccountSchedulable schedulable = new UpdateRelatedAccountSchedulable(accIdList, 'Task');
            
            Datetime dt = Datetime.now().addMinutes(1);
   			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

            System.schedule('Schedule Account Update '+System.currentTimeMillis(), timeForScheduler , schedulable);
        }
    }

    public static void RetailLiveCheck(set<Id> taskIds){
        
        try {
        Id brandRecType = Schema.SobjectType.Task.RecordTypeInfosByName.get('Brand Task').RecordTypeId;
        string retailLiveUser = '005b0000001W7xD';
        
        map<Id, Task> taskMap = new map <Id, Task>([select Id, RecordTypeId, WhoId, WhatId, Subject,  
                                                        Retail_Live__c, Retail_Live_From__c,Retail_Live_Reply__c                                                         
                                from Task 
                                where id in:taskIds
                                and createdbyid != :retailLiveUser                                
                                ]);
        map<Id, task> whatMap = new map<Id, task>();
        
        if (!taskMap.isEmpty()){
            
            map<string, string> subjectMap = new map<string, string>();
            list<Retail_Live_Email__c> retailLiveList = new list<Retail_Live_Email__c>();
            
            for (Task t :taskMap.values()){
                string subjectUnique = '';
                string emailSubject = t.Subject;
                                
                emailSubject = emailSubject.replace('RE: ', '');
                emailSubject = emailSubject.replace('RE:', '');
                emailSubject = emailSubject.replace('Re: ', '');
                emailSubject = emailSubject.replace('Re:', '');
                emailSubject = emailSubject.replace('FW: ', '');
                emailSubject = emailSubject.replace('FW:', '');            
                emailSubject = emailSubject.replace('Fw: ', '');
                emailSubject = emailSubject.replace('Fw:', ''); 
                emailSubject = emailSubject.replace('FWD: ', '');
                emailSubject = emailSubject.replace('FWD:', '');
                emailSubject = emailSubject.replace('fwd: ', '');
                emailSubject = emailSubject.replace('fwd:', '');
                emailSubject = emailSubject.replace('Email:', ''); // Maybe from Outlook app
                
                if (emailSubject.length() > 255){                               
                    subjectUnique = emailSubject.substring(0 , 255).trim();
                } else {                
                    subjectUnique =  emailSubject.trim();
                }
                
                subjectMap.put(t.Id, subjectUnique);            
                whatMap.put(t.whatId, t);
            }
system.debug('@@@@ SubjectMap .. ' + subjectMap);
system.debug('@@@@ whatMap .. ' + whatMap);
            
            
            
            retailLiveList = [select id, Reply_Count__c, chatter_post_id__c, village__c, brand__c, Subject_Unique__c,
                                OwnerId
                                 from Retail_Live_Email__c where (CreatedDate = LAST_N_DAYS:14                                 
                                 and Subject_Unique__c in :subjectMap.values()) 
                                 or (CreatedDate = LAST_N_DAYS:14 and Id in :whatMap.keySet())];
            
            if (!retailLiveList.isEmpty()){
                for (Retail_Live_Email__c r :retailLiveList){
                    decimal replyCount = r.Reply_Count__c;
system.debug('@@@@@  Retail Live Id ....  ' + r.Id + ' and subject is ...' + r.Subject_Unique__c);
                    if (whatMap.containsKey(r.Id)){ //Task created from retail live screen
                        Task taskrl = whatMap.get(r.Id);
                        taskrl.RecordTypeId = brandRecType;
system.debug('@@@@@  1 .. Setting what id to ....  ' + r.Id);                        
                        taskrl.WhatId = r.Id;
                        taskrl.OwnerId = r.OwnerId;
                        taskrl.Retail_Live__c = true;
                        taskrl.Status = 'Completed';
                        taskrl.ActivityDate = system.today();
                        r.Reply_Count__c = replyCount + 1;
                    } else {
                        for (string key :subjectMap.keySet()){
                            string s = subjectMap.get(key);
                            if (s == r.Subject_Unique__c){
                             
                                Task task = taskMap.get(key);
system.debug('@@@@@  2 .. Current what id is ....  ' + task.WhatId); 
                                task.RecordTypeId = brandRecType;
system.debug('@@@@@  2 .. Setting what id to ....  ' + r.Id);                                 
                                task.WhatId = r.Id;
 system.debug('@@@@@  3 .. what id set to ....  ' +  task.WhatId); 
                                task.OwnerId = r.OwnerId;
                                task.Retail_Live__c = true;
                                //task.Status = 'Completed';
                                //task.description = 'Im here' + task.WhatId;
                                task.ActivityDate = system.today();
                                r.Reply_Count__c = replyCount + 1;
                                break;
                            }
                        }
                    }
                }
                Savepoint sp = Database.setSavepoint();

                try {
                    ProcessorControl.inFutureContext = true;
                    Database.update (taskMap.values(),true);
                    Database.update (retailLiveList, true);
                    ProcessorControl.inFutureContext = false;
taskMap = new map <Id, Task>([select Id, RecordTypeId, WhoId, WhatId, Subject,  
                                                        Retail_Live__c, Retail_Live_From__c,Retail_Live_Reply__c                                                         
                                from Task 
                                where id in:taskIds                                 
                                ]); 
   for(Task t :taskMap.values()){                                                
    system.debug('@@@@@  4 .. what id is set to ....  ' +  t.WhatId);
    }
                } catch (exception e){
                    Database.rollback(sp);
                    system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());   
                } 
            }
        }
        
        
        } catch (exception e){
            system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());           
        }
        
    }

}