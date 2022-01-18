// Ian Burton
// email utilities
//https://appirio.com/tech-blog/sending-emails-without-targetobject-id-apex
public with sharing class emailUtils {

	public OrgWideEmailAddress OWA = null;
	public Contact dummyContact = null;
	public EmailTemplate templateId = null;

	public emailUtils(String OrgWideEmailAddressText, String templateDeveloperName) {
		OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address = :OrgWideEmailAddressText limit 1];
		if(templateDeveloperName != ''){
			templateId = [Select id from EmailTemplate where  developername = :templateDeveloperName];
		}
        //dummyContact = [select id, Email from Contact where email <> null AND email LIKE '%@valueretail.com%' limit 1];
	}

	 public emailSendResponse sendEmail( LIST<string> toaddresses,List<String> ccAddresses, ID whatID,String subject, String htmlContent, String plainContent){
                     
            try{
	            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
	            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
	            if(templateId != null){
	            	msg.setTemplateID(templateId.Id); 
	        	}
	        	else{
	        		// means its a template less email, so we need to set the content and the subject
	        		msg.setSubject(subject);
	        		msg.setHTMLBody(htmlContent);
	        		msg.setPlainTextBody(plainContent);

	        	}
                
                Savepoint sp = Database.setSavepoint();
                dummyContact = new Contact(LastName = 'dummy', Email = 'dummyContact@valueretail.com');
                insert dummyContact;
                
	            msg.setTargetObjectId(dummyContact.id);
	            msg.setToAddresses(toaddresses);
	            msg.setccAddresses(ccAddresses);
	            msg.setWhatId(whatID);
	            lstMsgs.add(msg);
	            
	            // Send the emails in a transaction, then roll it back
	            //Savepoint sp = Database.setSavepoint();
	            Messaging.sendEmail(lstMsgs);
	            Database.rollback(sp); // Email will not send as it is rolled Back

	            // Send Actual email
	            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
	            // contents to a new SingleEmailMessage. Then send those new messages.
				List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
				for (Messaging.SingleEmailMessage email : lstMsgs) {
					Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
					emailToSend.setToAddresses(email.getToAddresses());
					emailToSend.setccAddresses(email.getccAddresses());
					emailToSend.setPlainTextBody(email.getPlainTextBody());
					emailToSend.setHTMLBody(email.getHTMLBody());
					emailToSend.setSubject(email.getSubject());
					emailToSend.setOrgWideEmailAddressId(OWA.id);
					lstMsgsToSend.add(emailToSend);
				}
				system.debug('List of message' +lstMsgsToSend);
				Messaging.sendEmail(lstMsgsToSend);
            	return new emailSendResponse(true,'');            
            }
            catch (System.EmailException e){
               String message = 'Email Error, please make sure there is a valid email address on the "Booking/Partnership Contact" to send to.';  
                return new emailSendResponse(false,message + ' Details:' + e.getmessage());
            }  
            catch (Exception e){
               String message = 'A general exception occured, please contact you administrator\nMessage detail: ' +e.getmessage();  
               return new emailSendResponse(false,message );
            }
    }

    public class emailSendResponse {
    	public boolean emailSendResult;
    	public String emailResultMessage;

    	public emailSendResponse(Boolean success, String message){
    		emailSendResult = success;
    		emailResultMessage = message;
    	}
    }
}