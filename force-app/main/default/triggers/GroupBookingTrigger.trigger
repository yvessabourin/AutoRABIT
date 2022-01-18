trigger GroupBookingTrigger on Group_Booking__c (after update, after insert, before update) {

     list<string> MigratedataforActivityIdsList = new list<string>();
    //migration trigger logic
     if (trigger.isUpdate && trigger.isAfter){
        
        
         for(Group_Booking__c cBooking : trigger.newMap.values()){
             if(cBooking.Transfer_Redemptions_Now__c != trigger.oldMap.get(cBooking.Id).Transfer_Redemptions_Now__c
                                                    && cBooking.Transfer_Redemptions_Now__c == true ){
                 MigratedataforActivityIdsList.add(cBooking.Id);
                 system.debug('added ' + cBooking.Id + ' to list for processing');                                           
             }
         } 
        GroupBookingTriggerHandler.GroupBookingAfterUpdate(trigger.oldMap,trigger.newMap);
     }
     
     if (trigger.isInsert && trigger.isAfter){
         for(Group_Booking__c cBooking : trigger.newMap.values()){
             if(cBooking.Transfer_Redemptions_Now__c){
                 MigratedataforActivityIdsList.add(cBooking.Id);             
             }
         
         }
		GroupBookingTriggerHandler.updateRelatedAccount(trigger.new);
     }

     if(trigger.isUpdate && trigger.isBefore){

            System.debug('About to call before update');
         GroupBookingTriggerHandler.GroupBookingBeforUpdate(trigger.oldMap,trigger.newMap);
     }

     //02-10-2018 - Dan Childs
     //This feature has been removed
     //if(!MigratedataforActivityIdsList.isEmpty())
     //           RememptionMigrationHandler.MigrateRedemptions(MigratedataforActivityIdsList); 
                
}