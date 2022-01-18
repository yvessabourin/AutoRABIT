//Trigger: TravelTradeMeetingTrigger 
//Purpose: To post a chatter message against the record that @Mentions chatter groups
//DAte Created: 15/01/2014
//By: Ian Womack
//
//
//
/////////////////////////////////

trigger TravelTradeMeetingTrigger on Travel_Trade_Meeting__c (after update, after insert) {

      
     //create a set for all the meetings that need to be stored
     List<Travel_Trade_Meeting__c> shareMeetings = new List<Travel_Trade_Meeting__c>();
 
 if(Trigger.Isupdate)
 {             
    for(Travel_Trade_Meeting__c ttm : Trigger.new)
    {    
          //Compare it against the old setting and if it's updated then process it (i.e. only add it to the list if share__c has been updated.
          if(Trigger.oldMap.get(ttm.id).Share__c != ttm.Share__c && ttm.Share__c == true)
          {
            shareMeetings.add(ttm);
            system.debug('Meetings in set to be shared: ' + shareMeetings );
          }
          else //don't bother, just log it
          {
              system.debug('this meeting was not set to share so not processing: ' + ttm.id);
          }
    }
 }   
    if(Trigger.IsInsert)
     {             
        for(Travel_Trade_Meeting__c ttm : Trigger.new)
        {    
              if(ttm.Share__c == true)
              {
                shareMeetings.add(ttm);
                system.debug('Meetings in set to be shared: ' + shareMeetings );
              }
        }
        TravelTradeMeetingTriggerHelper.updateRelatedAccount(Trigger.new);
      }
  

        //send all the ttms that need to be shared to the helper class
        IF(shareMeetings.size() > 0 )
            TravelTradeMeetingTriggerHelper.ProcessShares(shareMeetings);


}