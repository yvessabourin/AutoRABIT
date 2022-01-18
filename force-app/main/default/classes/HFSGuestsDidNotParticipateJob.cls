Global Class HFSGuestsDidNotParticipateJob implements Schedulable {

    global void execute(SchedulableContext sch) {
          
        list<case> HFSCases = [SELECT id, status FROM Case WHERE Status = 'New' AND Service_Date__c = TODAY];
          
        for(case HFS  : HFSCases ){
                HFS.Status = 'Did Not Participate';       
        }
        
        try{
            update HFSCases ; 
            system.debug('HFSGuestsDidNotParticipateJob Success' + HFSCases);
            
        }
        catch (exception e){
        system.debug(' HFSGuestsDidNotParticipateJob failed --- ' +  e.getmessage());
       
      }     
       
   }
}