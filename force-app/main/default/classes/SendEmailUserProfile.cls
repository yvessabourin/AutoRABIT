public class SendEmailUserProfile {

    @future
    public static void sendEmail(List<Id> userIdList){
       
        List<User> userList = [SELECT Id, Email FROM User WHERE Id IN :userIdList];
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Brand_Marketing_SP_Email' LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(User us : userList){
            if(us.Email != NULL && template != null){
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
    
                singleMail.setToAddresses(new List<String>{us.email});
                singleMail.setTemplateId(template.Id);
                singleMail.setTargetObjectId(us.Id);
                singleMail.setSaveAsActivity(false);
                emails.add(singleMail);
            }
        }

        if(emails != null && !emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}