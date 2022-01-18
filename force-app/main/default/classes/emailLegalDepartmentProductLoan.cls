//Dan Childs 12-11-2018
//https://hub.appirio.com/tech-blog/sending-emails-without-a-targetobject-id-in-apex

Public Class emailLegalDepartmentProductLoan{

public static void sendEmail(Product_Loan__c pl){
            
            LIST<string> toaddresses = New List<String>();
            EmailTemplate templateId = [Select id from EmailTemplate where  developername = 'Product_Loan_Notification'];
            user u = [SELECT id, name, email from User where UserName LIKE 'legalteam@valueretail.com%'];
            string toaddress = u.email;
            toaddresses.add(toaddress);
            
                 
            //randon contact selected to dummy set it as the TargetId Messaging.SingleEmailMessage                  
            Contact c = [select id, Email from Contact where email <> null AND email LIKE '%@valueretail.com%' limit 1];
            system.debug('the contact email ' + c.email);
            
            try{
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            msg.setTemplateID(templateId.Id); 
            //msg.setsaveAsActivity(true);
            msg.setTargetObjectId(c.id);
            msg.setWhatId(pl.id);
            msg.setToAddresses(toaddresses);
            lstMsgs.add(msg);
            
            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(lstMsgs);
            Database.rollback(sp); // Email will not send as it is rolled Back
            
            //Get the id for the senders "FROM" address
            ///////////-------
            OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address = 'traveltrade@thebicestervillageshoppingcollection.com' limit 1];
            //System.Debug('OrgWideAddress = ' + OWA);
            // Send Actual email
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
            
                 List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                 List<emailMessage > msgsToInsert = new List<emailMessage>();
                 for (Messaging.SingleEmailMessage email : lstMsgs) {
                 Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                 emailToSend.setToAddresses(email.getToAddresses());
                 emailToSend.setPlainTextBody(email.getPlainTextBody());
                 emailToSend.setHTMLBody(email.getHTMLBody());
                 emailToSend.setWhatId(pl.id);
                 emailToSend.setSubject(email.getSubject());
                 emailToSend.setSaveAsActivity(true);
                 emailToSend.setOrgWideEmailAddressId(OWA.id);
                 lstMsgsToSend.add(emailToSend);                 
                 
                 }
                 system.debug('List of maessage' +lstMsgsToSend);
                 Messaging.sendEmail(lstMsgsToSend);
            
            }
            catch (System.EmailException e){
            
            system.debug('system exception caught :' + e.getmessage());
              //  message = 'Email Error, please make sure there is a valid email address on the "Booking/Partnership Contact" to send to.';  
                //showbutton = false;
                //showSuccessMessage = true;
                //system.assertequals(1,0,e.getmessage());
            }  
            catch (Exception e){
            system.debug('general exception caught :' + e.getmessage());
                //message = 'A general exception occured, please contact you administrator\nMessage detail: ' +e.getmessage();  
                //showbutton = false;
                //showSuccessMessage = true;
                //system.assertequals(1,0,e.getmessage());
            }
    }





}