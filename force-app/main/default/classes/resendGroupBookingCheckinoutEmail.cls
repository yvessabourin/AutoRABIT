public class resendGroupBookingCheckinoutEmail {
    // we need 2 methods, that will send either the checkin or checkout emails.
    
     public void sendCheckinEmail(Visit__c vist){
         emailUtils checkinmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_In');
         Group_Booking__c GB = [SELECT Id,Contact__r.Secondary_Email_Address__c,Organisation__r.Account_Email__c ,contact__c,contact__r.email,Secondary_MICE_Contact_Email__c,status__c FROM Group_Booking__c where id = :vist.Group_Booking__c];
           if(GB != null){
                LIST<string> toaddress = New List<String>();
                IF(GB.contact__c!= null && GB.contact__r.email != NULL){
                toaddress.add(GB.contact__r.email);
                }
                
                IF(GB.contact__c!= null && GB.contact__r.Secondary_Email_Address__c != NULL){
                toaddress.add(GB.contact__r.Secondary_Email_Address__c);
                }
                
                IF(GB.Secondary_MICE_Contact_Email__c != NULL){
                toaddress.add(GB.Secondary_MICE_Contact_Email__c);
                }
                 IF(GB.Organisation__c != null && GB.Organisation__r.Account_Email__c  != NULL){
                toaddress.add(GB.Organisation__r.Account_Email__c );
                }
                System.Debug('About to call SEND EMail == == ' + toaddress);
                 emailUtils.emailSendResponse emailResponse = checkinmailUtils.sendEmail(toaddress,null,vist.Id,null,null,null);
                // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                    System.Debug('emailResponse == == ' + emailResponse);
                if(emailResponse.emailSendResult){
                    // only update the visits for the emails that suceeded.
                    if(emailResponse.emailSendResult){
                       return;
                    }  
                    else{
                        // need to surface an error if possible 
                    }           
                }
            }
            else
            {
                // surface error that the visit is orphan (could be a VIP visit?)
            }
     }
     
         
     public void sendCheckoutEmail(Visit__c vist){
        emailUtils checkoutmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_Out');
          emailUtils checkinmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_In');
         Group_Booking__c GB = [SELECT Id,Contact__r.Secondary_Email_Address__c,Organisation__r.Account_Email__c ,contact__c,contact__r.email,Secondary_MICE_Contact_Email__c,status__c FROM Group_Booking__c where id = :vist.Group_Booking__c];
           if(GB != null){
                LIST<string> toaddress = New List<String>();
                IF(GB.contact__c!= null && GB.contact__r.email != NULL){
                toaddress.add(GB.contact__r.email);
                }
                
                IF(GB.contact__c!= null && GB.contact__r.Secondary_Email_Address__c != NULL){
                toaddress.add(GB.contact__r.Secondary_Email_Address__c);
                }
                
                IF(GB.Secondary_MICE_Contact_Email__c != NULL){
                toaddress.add(GB.Secondary_MICE_Contact_Email__c);
                }
                 IF(GB.Organisation__c != null && GB.Organisation__r.Account_Email__c  != NULL){
                toaddress.add(GB.Organisation__r.Account_Email__c );
                }
                System.Debug('About to call SEND EMail == == ' + toaddress);
                 emailUtils.emailSendResponse emailResponse = checkinmailUtils.sendEmail(toaddress,null,vist.Id,null,null,null);
                // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                    System.Debug('emailResponse == == ' + emailResponse);
                if(emailResponse.emailSendResult){
                    // only update the visits for the emails that suceeded.
                    if(emailResponse.emailSendResult){
                       return;
                    }  
                    else{
                        // need to surface an error if possible 
                    }           
                }
            }
            else
            {
                // surface error that the visit is orphan (could be a VIP visit?)
            }
     }
    
}