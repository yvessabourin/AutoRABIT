trigger VillagePresenceContactTriggers on Village_Presence_Contact_Role__c (before insert,before update, after insert, after update, after delete) {

        list<string> contactIdList = new list<Id>();
        list<Village_Presence_Contact_Role__c> updateList = new list<Village_Presence_Contact_Role__c>();
        //DC
        list<Village_Presence_Contact_Role__c> primaryVPCRList = new list<Village_Presence_Contact_Role__c>();        
        list<id> VillagePresenceIds = new list<id>();   
         
        
        
         
         //Dan Childs
         if (trigger.isbefore && trigger.isupdate || trigger.isbefore && trigger.isinsert){
         
         for(Village_Presence_Contact_Role__c vpcr : trigger.new){
            VillagePresenceIds.add(vpcr.Village_Presence__c);
        }     

        list<Village_Presence_Contact_Role__c> ExistingVPCRs = [SELECT id,name,Village_Presence__c FROM Village_Presence_Contact_Role__c WHERE Village_Presence__c IN:VillagePresenceIds AND id NOT IN: trigger.new]; 
        system.debug('ExistingVPCRs - ' + ExistingVPCRs);         
        map<id,integer> vpcrCountMap = new map<id,integer>(); 
        
    
        for(Village_Presence_Contact_Role__c vpcr : ExistingVPCRs ){
            if(vpcrCountMap.get(vpcr.Village_Presence__c) == null){
                vpcrCountMap.put(vpcr.Village_Presence__c, 1);          
            }
            else{
                integer count = vpcrCountMap.get(vpcr.Village_Presence__c);
                vpcrCountMap.put(vpcr.Village_Presence__c, count + 1);           
            }  
        }
        
            for (Village_Presence_Contact_Role__c vpcrs :trigger.new){         
                if(vpcrCountMap.get(vpcrs.Village_Presence__c) >= 10){
                     vpcrs.addError('This Village Presence already has ' + vpcrCountMap.get(vpcrs.Village_Presence__c) + ' Contact Roles associated with it,the maximum is 10, please perform some housekeeping');
                }
                else{            
                    if(vpcrs.Primary_Contact_Role__c == TRUE){
                         primaryVPCRList.add(vpcrs);
                    }
                PrimaryVPCRCheck.vpcrCheck(primaryVPCRList); 
                }          
            }
         }
         
         
         
        if (trigger.isDelete){
            updateList = trigger.old;
        } else {
            updateList = trigger.new;
        }
        
        
        for (Village_Presence_Contact_Role__c vpRole :updateList){
            contactIdList.add(vpRole.Contact__c);
        }   
        
        if (!contactIdList.isEmpty()){
            VillagePresenceUtilities.refreshContactVillagePresence(contactIdList);
        }
        
        
    
        
        // ***  Check whether Daily Sale share trigger needs to run *** //
        list<Village_Presence_Contact_Role__c> vpcrList = new list<Village_Presence_Contact_Role__c>();
        if (trigger.isAfter && trigger.isInsert){
            for (Village_Presence_Contact_Role__c vpcr :trigger.new){
                if (vpcr.Daily_Sales_Active_From__c != null || vpcr.Certification_Active__c == true){ //If new record has Daily Sales Active from date populated, add to list for Daily Sale share trigger
                    vpcrList.add(vpcr);
                }
                
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate){ // check whether update is to Daily Dales Active From/To fields
    
            for (Village_Presence_Contact_Role__c vpcr :trigger.new){
                if (trigger.oldMap.get(vpcr.Id).Daily_Sales_Active_From__c != vpcr.Daily_Sales_Active_From__c){ //Daily Sales Active from updated, add to list for Daily Sale share trigger
                    vpcrList.add(vpcr);
                } else if (trigger.oldMap.get(vpcr.Id).Daily_Sales_Active_To__c != vpcr.Daily_Sales_Active_To__c){ //Daily Sales Active to updated, add to list for Daily Sale share trigger
                    vpcrList.add(vpcr);
                } else if (trigger.oldMap.get(vpcr.Id).Certification_Active__c != vpcr.Certification_Active__c){
                    vpcrList.add(vpcr);
                }
            }
        } 
    
        if(trigger.isAfter && trigger.isDelete){ // check whether deleted record(s) have daily sales date fields populated
    
            for (Village_Presence_Contact_Role__c vpcr :trigger.old){
                if (trigger.oldMap.get(vpcr.Id).Daily_Sales_Active_From__c != null || trigger.oldMap.get(vpcr.Id).Daily_Sales_Active_To__c != null){ //Record with Daily Sales Active deleted, add to list for Daily Sale share trigger
                    vpcrList.add(vpcr);
                }
            }
            
        }
        
       
        
        if (!vpcrList.isEmpty()){ //There are records to invoke Daily Sales share logic
            DailySaleTriggerHelper.ProcessShares(vpcrList);
            DSCertificationBatchTriggerHelper.ProcessShares(vpcrList);
        }
        // *** End of Check whether Daily Sale share trigger needs to run ***//
   
     
}