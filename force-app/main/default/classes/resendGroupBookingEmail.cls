//Dan Childs 15-06-2017
//https://appirio.com/tech-blog/sending-emails-without-targetobject-id-apex

public class resendGroupBookingEmail {
    
    public id theGB {get;set;}
    private final Group_Booking__c GB {get;set;}
    public string village {get;set;}
    public LIST<Group_Booking__c> recipient {get;set;}
    public LIST<Contact> cont {get;set;}
    public string recipientemail {get;set;}
    public boolean showbutton {get; set;}
    public boolean showSuccessMessage {get; set;}
    public Integer myint {get;set;}
    public boolean hidebuttonaftersave {get;set;}
    public string message {get;set;}
    

    public resendGroupBookingEmail(ApexPages.StandardController sc) {
        theGB = sc.getid();
        GB = [SELECT Id, contact__c,contact__r.email,Secondary_MICE_Contact_Email__c,status__c FROM Group_Booking__c where id=:theGB];   
        cont = [SELECT id,email,Secondary_Email_Address__c from Contact where id=:GB.Contact__c LIMIT 1];
        message = '';
    
            IF(GB.contact__c != NULL && GB.Status__c == 'Confirmed'){
                showbutton = true;
                }else{
                showbutton = false;
                }
                
        showSuccessMessage = false;
    }   
     
     
    public void sendEmail(){
            EmailTemplate templateId = [Select id from EmailTemplate where  developername = 'Group_Booking_Confirmed_v1'];
            
            LIST<string> toaddress = New List<String>();
                IF(cont.size() > 0 && cont[0].email != NULL){
                toaddress.add(cont[0].email);
                }
                
                IF(cont.size() > 0 && cont[0].Secondary_Email_Address__c != NULL){
                toaddress.add(cont[0].Secondary_Email_Address__c);
                }
                
                IF(GB.Secondary_MICE_Contact_Email__c != NULL){
                toaddress.add(GB.Secondary_MICE_Contact_Email__c);
                }
                 
            //randon contact selected to dummy set it as the TargetId Messaging.SingleEmailMessage                  
            //Contact c = [select id, Email from Contact where email <> null AND email LIKE '%@valueretail.com%' limit 1];
        	Savepoint sp = Database.setSavepoint();
        	Contact c = new Contact(LastName = 'dummy', Email = 'dummyContact@valueretail.com');
        	insert c;
        	system.debug(c.email);
        
            try{
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            msg.setTemplateID(templateId.Id); 
            msg.setTargetObjectId(c.id);
            msg.setToAddresses(toaddress);
            msg.setWhatId(GB.id);
            lstMsgs.add(msg);
            
            // Send the emails in a transaction, then roll it back
            //Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(lstMsgs);
            Database.rollback(sp); // Email will not send as it is rolled Back
            
            //Get the id for the senders "FROM" address
            OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address = 'traveltrade@thebicestervillageshoppingcollection.com' limit 1];
            System.Debug('OrgWideAddress = ' + OWA);
            // Send Actual email
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
                 List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                 for (Messaging.SingleEmailMessage email : lstMsgs) {
                 Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                 emailToSend.setToAddresses(email.getToAddresses());
                 emailToSend.setPlainTextBody(email.getPlainTextBody());
                 emailToSend.setHTMLBody(email.getHTMLBody());
                 emailToSend.setSubject(email.getSubject());
                 emailToSend.setOrgWideEmailAddressId(OWA.id);
                 lstMsgsToSend.add(emailToSend);
                 }
                 system.debug('List of maessage' +lstMsgsToSend);
                 Messaging.sendEmail(lstMsgsToSend);
            
            showbutton = false;
            showSuccessMessage = true;
            message = 'Message sent successfully';
            datetime myDate = datetime.now();
            GB.Confirmation_Email_Resent__c = mydate;
            update GB;
            }
            catch (System.EmailException e){
                message = 'Email Error, please make sure there is a valid email address on the "Booking/Partnership Contact" to send to.';  
                showbutton = false;
                showSuccessMessage = true;
                //system.assertequals(1,0,e.getmessage());
            }  
            catch (Exception e){
                message = 'A general exception occured, please contact you administrator\nMessage detail: ' +e.getmessage();  
                showbutton = false;
                showSuccessMessage = true;
                //system.assertequals(1,0,e.getmessage());
            }
    }
}