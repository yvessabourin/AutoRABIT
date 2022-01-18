public class SendEmailToCertify {
    
    public static void SendEmailToCertify(Set<Id> vpToSendEmail, Map<Id, Date> villageDeadlineDate){
        
        List<Village_Presence_Contact_Role__c> vpcrToSendEmail = [SELECT Id, Contact__c, Village_Presence__r.Village__c
                                                                  FROM Village_Presence_Contact_Role__c
                                                                  WHERE Village_Presence__c = :vpToSendEmail
                                                                  AND Certification_Active__c = TRUE];
        
        List<Village__c> allVillages = [SELECT Id, CertSales_CertPeriod_Cut_Off_Days__c FROM Village__c];
        Map<Id, Set<Id>> contactMap = new Map<Id, Set<Id>>();
        
        for(Village__c currentVillage : allVillages){
            for(Village_Presence_Contact_Role__c theVPCR : vpcrToSendEmail){
                if(theVPCR.Village_Presence__r.Village__c == currentVillage.Id){
                    if(!contactMap.containsKey(theVPCR.Village_Presence__r.Village__c)){
                        contactMap.put(theVPCR.Village_Presence__r.Village__c, new Set<Id>{theVPCR.Contact__c});
                    } else{
                        Set<Id> tempContactList = contactMap.get(theVPCR.Village_Presence__r.Village__c);
                        tempContactList.add(theVPCR.Contact__c);
                        system.debug(tempContactList);
                        contactMap.put(theVPCR.Village_Presence__r.Village__c, tempContactList);
                        system.debug(contactMap);
                    }
                }
            }
        }
        system.debug(contactMap);
        
        // set the brand portal url.
        List<Site> siteList = [SELECT GuestUserId, Name, MasterLabel, Subdomain, 
                               OptionsRequireHttps, UrlPathPrefix FROM Site WHERE Status = 'Active' Limit 1000];
        
        List<String> siteFullUrlList = new List<String>();
        String theCommunityURL;
        
        // We can get instance of the org from organisation object
        Organization org = [SELECT InstanceName,Name, IsSandbox, OrganizationType FROM Organization];
        if(siteList != null && siteList.size() != 0) {
            for(Site s: siteList) {
                if(s.Subdomain != null) {
                    String httpStr = 'http://';
                    if(s.OptionsRequireHttps == true) {
                        httpStr = 'https://';
                    }
                    
                    String siteFullUrl = httpStr;
                    if(org.IsSandbox == true) {
                        siteFullUrl += UserInfo.getUserName().substringAfterLast('.')+'-';
                    }
                    
                    siteFullUrl += s.Subdomain + '.';
                    siteFullUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
                    if(s.UrlPathPrefix != null) {
                        siteFullUrl += '/'+s.UrlPathPrefix;
                    }
                    
                    siteFullUrlList.add(siteFullUrl);
                }
            }
            
            for(String eachSite : siteFullUrlList){
                if(eachSite.contains('brands')){
                    theCommunityURL = eachSite;
                }
            }
        }
        
        Profile brandPortalProfileWithoutExp = [SELECT Id FROM Profile WHERE Name = 'Brand Community Plus User'];
        Profile brandPortalProfileWithExp = [SELECT Id FROM Profile WHERE Name = 'Brand Community Plus User (with Export)'];
        EmailTemplate emailIdEN = [SELECT Id, Name, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Certify Now Template'];
        EmailTemplate emailIdES = [SELECT Id, Name, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Certify Now Template ES'];
        EmailTemplate emailIdDE = [SELECT Id, Name, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Certify Now Template GE'];
        EmailTemplate emailIdIT = [SELECT Id, Name, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Certify Now Template IT'];
        EmailTemplate emailIdFR = [SELECT Id, Name, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Certify Now Template FR'];
        List<User> brandPortalUsers = [SELECT Id, FirstName, LastName, ContactId, LanguageLocaleKey
                                       FROM User
                                       WHERE (ProfileId = :brandPortalProfileWithoutExp.Id OR ProfileId = :brandPortalProfileWithExp.Id)];
        
        Map<Id, String> userLanguage = new Map<Id, String>();
        Map<Id, String> userName = new Map<Id,String>();
        Map<Id, Id> userId = new Map<Id, Id>();
        
        for(User aUser : brandPortalUsers){
            userLanguage.put(aUser.ContactId, aUser.LanguageLocaleKey);
            if(aUser.FirstName != null){
                userName.put(aUser.ContactId, aUser.FirstName);
            } else{
                userName.put(aUser.ContactId, aUser.LastName);
            }
            userId.put(aUser.ContactId, aUser.Id);
        }
        
        for(Village__c runVill : allVillages){
            Set<Id> setContactIds = new Set<Id>();
            if(contactMap.get(runVill.Id) != null){
                setContactIds = contactMap.get(runVill.Id);
            }
            
            if(!setContactIds.isEmpty()){
                Messaging.SingleEmailMessage[] allMessages = new List<Messaging.SingleEmailMessage> {};
                    for(Id eachContact : setContactIds){
                        String htmlBody;
                        String subject;
                        Id tempId;
                        if(userLanguage.get(eachContact) == 'it'){
                            htmlBody = emailIdIT.HtmlValue;
                            subject = emailIdIT.Subject;
                            tempId = emailIdIT.Id;
                        } else if(userLanguage.get(eachContact) == 'es'){
                            htmlBody = emailIdES.HtmlValue;
                            subject = emailIdES.Subject;
                            tempId = emailIdES.Id;
                        } else if(userLanguage.get(eachContact) == 'fr'){
                            htmlBody = emailIdFR.HtmlValue;
                            subject = emailIdFR.Subject;
                            tempId = emailIdFR.Id;
                        } else if(userLanguage.get(eachContact) == 'de'){
                            htmlBody = emailIdDE.HtmlValue;
                            subject = emailIdDE.Subject;
                            tempId = emailIdDE.Id;
                        } else{
                            htmlBody = emailIdEN.HtmlValue;
                            subject = emailIdEN.Subject;
                            tempId = emailIdEN.Id;
                        }
                        
                        Date dateNow = villageDeadlineDate.get(runVill.Id);
                        String dateForEmail = dateTime.newInstance(dateNow.year(), dateNow.month(), dateNow.day()).format('dd-MM-YYYY');
                        
                        htmlBody = htmlBody.replace('website_here', theCommunityURL);
                        htmlBody = htmlBody.replace('UserName', userName.get(eachContact));
                        htmlBody = htmlBody.replace('certificationDeadline', String.valueOf(dateForEmail));
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setSubject(subject);
                        message.setHtmlBody(htmlBody);
                        message.setTemplateId(tempId);
                        message.setTargetObjectId(userId.get(eachContact));
                        message.setSaveAsActivity(false);
                        message.setUseSignature(false);
                        allMessages.add(message);
                    }
                
                try{
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(allMessages);
                    
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        logFile__c log = new logFile__c();
                        log.Body__c = 'Send email failed on class SendEmailToCertify. With the following mesage: ' + results[0].errors[0].message;
                        log.Type__c = 'Error on send Email to Certify';
                        insert log;
                    }
                } catch (Exception e){
                    logFile__c log = new logFile__c();
                    log.Body__c = 'Error on send Email to Certify on class SendEmailToCertify. With the following mesage: ' + e.getMessage();
                    log.Type__c = 'Error on send Email to Certify';
                    insert log;
                }
            }
        }
    }
}