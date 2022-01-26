public class EmailMarketingActivity {
    
    public Static void SendEmailMarketingActivity(List<Marketing_Activity__c> listMarketing){

        List<Messaging.SingleEmailMessage> allMessag = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();

        for(Marketing_Activity__c marck : listMarketing){

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            
            if(marck.Creative_Agency_Access_To_Salesforce__c != null){ 
                sendTo.add(marck.Creative_Agency_Access_To_Salesforce__c);  
            }

            if(marck.Creative_Agency_2__c != null){ 
                sendTo.add(marck.Creative_Agency_2__c);  
            }

            if(marck.Creative_Agency_3__c != null){ 
                sendTo.add(marck.Creative_Agency_3__c);  
            }

            if(marck.Creative_Agency_4__c != null){ 
                sendTo.add(marck.Creative_Agency_4__c);  
            }

            if(sendTo.size() != 0 && sendTo != NULL){
                
                mail.setToAddresses(sendTo);
                
                mail.setSubject('Email Marketing Activity');
                String body = '<br/>';
                       body +='Marketing Activity Name :   '  + marck.Name +  '<br/>';
                       body +='<br/>';
                       body += System.Url.getSalesforceBaseUrl().toExternalForm()
                    +'/'+marck.Id +'';
                
                mail.setHtmlBody(body);
                mail.setSaveAsActivity(false); 
                allMessag.add(mail);
            }
                    
        }

        Messaging.sendEmail(allMessag);
        System.debug('user mail id '+allMessag);
        
    }
    
}