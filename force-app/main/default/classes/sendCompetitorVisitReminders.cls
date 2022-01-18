Global Class sendCompetitorVisitReminders implements Schedulable {

    global void execute(SchedulableContext sch) {
    
       //Get the competitor Site Visits that are overdue by 1 or 7 days
       list<competitor_site__c> compSites = [SELECT Id,Name,Next_On_Site_Visit__c,Ownerid,Last_On_Site_Visit__c,Site_Captain__r.email,Site_Captain__r.FirstName, Site_Captain__r.LastName, Additional_Site_Captain__r.FirstName,Additional_Site_Captain__r.LastName,Additional_Site_Captain__r.email,Additional_Site_Captain2__r.email,Additional_Site_Captain3__r.email, Visit_Status__c,Days_Overdue__c,Competitor_to_Village__r.Business_Director__r.email FROM competitor_site__c WHERE (Next_On_Site_Visit__c = : SYSTEM.TODAY()-1 OR Next_On_Site_Visit__c = : SYSTEM.TODAY()-7) ];
       
       if(compSites.size() > 0){

       list<LogFile__c> errorLogs = new list<LogFile__c>();

       //select template id
       EmailTemplate templateId = [Select id from EmailTemplate where developername = 'Competitor_Site_Visit_Overdue_template'];
       OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address = 'traveltrade@thebicestervillageshoppingcollection.com' limit 1];
       
           //loop through the overdue Competitor Sites
           //Emails are sent 1 at a time so any errors can be handled and an errorlog created and added to a list if there is
           for(competitor_site__c cv : compSites){
           
               List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
               list<string> toAddresses = new List<string>();
               
                 if(cv.Site_Captain__r.email != NULL){
                     toAddresses.add(cv.Site_Captain__r.email);
                 }
                 if(cv.Additional_Site_Captain__r.email != NULL){
                     toAddresses.add(cv.Additional_Site_Captain__r.email);
                 }
                 if(cv.Competitor_to_Village__r.Business_Director__r.email != NULL){
                  toAddresses.add(cv.Competitor_to_Village__r.Business_Director__r.email);
                 }
                 if(cv.Additional_Site_Captain2__r.email != NULL){
                     toAddresses.add(cv.Additional_Site_Captain2__r.email);
                 }
                 if(cv.Additional_Site_Captain3__r.email != NULL){
                     toAddresses.add(cv.Additional_Site_Captain3__r.email);
                 }
               
                        
               Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();           
               msg.setTemplateID(templateId.Id); 
               msg.setTargetObjectId(cv.Ownerid);
               msg.setWhatId(cv.id);
               msg.setToAddresses(toAddresses);
               msg.setOrgWideEmailAddressId(OWA.id);
               msg.saveAsActivity = false;
               lstMsgs.add(msg);

               try{
                   Messaging.sendEmail(lstMsgs);
               }
               catch (Exception e){
                   System.debug('error message e:' + e.getMessage() );                                
                   LogFile__c lf = new LogFile__c();
                   lf.Date_Time_Created__c = system.now();
                   lf.date__c = system.today();
                   lf.body__c = e.getMessage();
                   lf.Type__c = 'Competitor Site Visit Email Error';
                   errorLogs.add(lf);
               
               }
                     
           }
           
           //insert any errors
           if(errorLogs != null && errorLogs.size() != 0){
               insert errorlogs;
           }
       }  
   }
}