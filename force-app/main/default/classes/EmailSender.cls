public class EmailSender {
	
    public static void  sendDailySaleReminder(list<string> userIdList) {

		Id etId = [select id from EmailTemplate where developername = 'Confirm_Record_Reminder'].Id;                
		
		OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress 
									where DisplayName = 'VR1 Notifications']; 
system.debug(' @@@@ userIdList  ' + userIdList);
		// have to send mail using single email message class one at a time because
		// content will vary between users
		for (string userId :userIdList){
	  		//New instance of a single email message
	
	 		Messaging.SingleEmailMessage mail =
	        new Messaging.SingleEmailMessage();
	
			//Who you are sending the email to
	   		mail.setTargetObjectId(userId);
	   		
	   		// The email template ID used for the email
	   		mail.setTemplateId(etId);
		    mail.setWhatId(userId);   
			mail.setOrgWideEmailAddressId(owa.Id);
			
			mail.setBccSender(false);		
		    mail.setUseSignature(false);
			mail.setSaveAsActivity(false);
			mail.emailPriority = 'High';
					
system.debug(' @@@ reminder email .. ' + mail);	
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}
        
    }
}