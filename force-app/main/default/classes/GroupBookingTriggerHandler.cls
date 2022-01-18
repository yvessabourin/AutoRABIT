public with sharing class GroupBookingTriggerHandler{
    
    public static void updateRelatedAccount(List<Group_Booking__c> bookingList){
        List<Id> accIdList = new List<Id>();
        
        for(Group_Booking__c book : bookingList){
            accIdList.add(book.Organisation__c);
        }
        if(!accIdList.isEmpty()){
        	UpdateRelatedAccountSchedulable schedulable = new UpdateRelatedAccountSchedulable(accIdList, 'Group Booking');
            
            Datetime dt = Datetime.now().addMinutes(1);
   			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

            System.schedule('Schedule Account Update '+System.currentTimeMillis(), timeForScheduler , schedulable);
        }
    }

    public static void GroupBookingAfterUpdate(Map<Id, Group_Booking__c> oldBookingMap, Map<Id, Group_Booking__c> newBookingMap ){
        List<Id> noshowGBIds = new List<ID>();
        for(Group_Booking__c newGB :newBookingMap.values()){
            Group_Booking__c  oldGB = oldBookingMap.get(newGB.Id);
            if(oldGB.Status__c != newGB.Status__c ){
                // means the status has changed
                // lets check if the status has changed to 'No Show' 
                if(newGB.Status__c == 'No Show'){
                    // means we need to mark all this bookings visits as 'No Show'
                    noshowGBIds.add(newGB.Id);
                }
            }
        }
        
        // now that we have all the group bookings that we think are no shows, lets make sure all the visits are marked as no show too (but lets not mark the ones that are already marked)
        List<Visit__c> noShowVisits = [SELECT ID, No_Show__c FROM Visit__c WHERE No_Show__c = false AND Group_Booking__c in :noshowGBIds];
    
        for(Visit__c vst :noShowVisits){
            vst.No_Show__c = true;
        }
        update noShowVisits;
        // this should only update the visits that arent already marked as no-show
    }

     public static void GroupBookingBeforUpdate(Map<Id, Group_Booking__c> oldBookingMap, Map<Id, Group_Booking__c> newBookingMap ){

            System.debug('Checking bookings for no-show');
        // lets check if the 'send no show email' flag is set, so we can send the email
        List<Group_Booking__c> noShowEmailBookings = new List<Group_Booking__c>();
        for(Group_Booking__c newGB :newBookingMap.values()){
            Group_Booking__c  oldGB = oldBookingMap.get(newGB.Id);
  System.debug('old booking: ' + oldGB);
    System.debug('new booking: ' + newGB);
            if(oldGB.Send_No_Show_Email__c == false && newGB.Send_No_Show_Email__c == true){
                // then the user wants to send the no-show email
                // but lets make sure that the status is correct and all that.
                if(newGB.Status__c == 'No Show'){
                    noShowEmailBookings.add(newGB);
                }
            }

        }


        // now that we have the group bookings that need to send no show emails, lets send them

          emailUtils checkinmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_No_Show_Email');
         //Group_Booking__c GB = [SELECT Id,Contact__r.Secondary_Email_Address__c,Organisation__r.Account_Email__c ,contact__c,contact__r.email,Secondary_MICE_Contact_Email__c,status__c FROM Group_Booking__c where id = :vist.Group_Booking__c];
        for(Group_Booking__c GB :noShowEmailBookings) {
           if(GB != null){
                System.debug('GB Contact: ' + GB.contact__c);
                LIST<string> toaddress = New List<String>();
                IF(GB.contact__c!= null){
                    Contact cont = [SELECT ID,Secondary_Email_Address__c, email FROM Contact WHERE ID =:GB.contact__c];
                    IF( cont.email != NULL){
                        toaddress.add(cont.email);
                    }
                       
                    IF( cont.Secondary_Email_Address__c != NULL){
                        toaddress.add(cont.Secondary_Email_Address__c);
                    }
                
                }
                
                IF(GB.Secondary_MICE_Contact_Email__c != NULL){
                        toaddress.add(GB.Secondary_MICE_Contact_Email__c);
                }
                 IF(GB.Organisation__c != null ){
                    Account acc = [SELECT ID, Name,Account_Email__c FROM Account WHERE ID =:GB.Organisation__c ];
                    if(acc.Account_Email__c  != NULL){
                        toaddress.add(acc.Account_Email__c );
                    }
                }
                System.Debug('About to call SEND EMail == == ' + toaddress);
                if(toaddress.size() == 0 ){
                     GB.Notes_and_Additional_Comments__c += 'No Show Email send fail: No Email addresses to send to. ';
                 }
                 emailUtils.emailSendResponse emailResponse = checkinmailUtils.sendEmail(toaddress,null,GB.Id,null,null,null);
                
                // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                    System.Debug('emailResponse == == ' + emailResponse);
                if(emailResponse.emailSendResult){
                    // only update the visits for the emails that suceeded.
                    if(emailResponse.emailSendResult){
                        GB.No_Show_Email_Send_Date__c = Datetime.now();
                       //return;
                    }  
                    else{
                        // need to surface an error if possible 
                        GB.Notes_and_Additional_Comments__c += 'No Show Email send fail: ' + emailResponse.emailResultMessage;
                    }           

                }
                else{
                        // need to surface an error if possible 
                        GB.Notes_and_Additional_Comments__c += 'No Show Email send fail: ' + emailResponse;
                    } 
            }
        }
     }

}