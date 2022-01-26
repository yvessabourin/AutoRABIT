public with sharing class BP_Certification_SCert_Controller {
    
    @AuraEnabled
    public static List<Daily_Sale__c> getDalySales(Id certId, String sortField, boolean isAsc){
        
        String sSoql = 'SELECT Id, Trading_Date__c, Trading_Day_with_date__c, Total_NET_SALES__c, NET_Value_of_Discounts__c, Store_Closed__c, Brand_Reported_Amount__c, Certified_Amount_NetTotal_Input__c, ';
        sSoql += 'Certified_Amount_Discount_Input__c, Certified_Amount__c, Variance_Amount__c, Certification_Comment__c, MRI_Suite_Id__c ';
        
        sSoql += 'FROM Daily_Sale__c ';
        sSoql += 'WHERE Certification_Batch__c =: certId ';
        
        if(sortField != null){
            if(sortField == 'Variance_Amount__c'){
                sSoql += 'ORDER BY Auxiliar_Variance_Amount__c';
                if (isAsc) {
                    sSoql += ' ASC';
                } else {
                    sSoql += ' DESC';
                }
            } else {
                sSoql += 'ORDER BY ' + sortField;        
                if (isAsc) {
                    sSoql += ' ASC';
                } else {
                    sSoql += ' DESC';
                }
            }
        }
        
        sSoql += ' NULLS LAST';
        
        system.debug('The query is' + sSoql);
        
        List<Daily_Sale__c> allRelatedDailySales = Database.query(sSoql);
        system.debug(allRelatedDailySales);
        return allRelatedDailySales;
    }
    
    @AuraEnabled
    public static Daily_Sales_Certification_Batch__c getCertification(Id certId){
        
        Daily_Sales_Certification_Batch__c theCert = [SELECT Name, Status__c, Total_Brand_Reported_Amount__c, Total_Certified_Amount__c, Total_Variance_Amount__c FROM Daily_Sales_Certification_Batch__c WHERE Id =:certId];
        
        system.debug(theCert);
        return theCert;
    }
    
    @AuraEnabled
    public static String getCertificationName(Id certId){
        
        Daily_Sales_Certification_Batch__c certName = [SELECT Id, Name FROM Daily_Sales_Certification_Batch__c WHERE Id = :certId];
        
        system.debug(certName.Name);
        return certName.Name;
    }
    
    @AuraEnabled
    public static String getCertificationRG(Id certId){
        
        Daily_Sales_Certification_Batch__c certRange = [SELECT Id, Period_Start_Date__c, Period_End_Date__c FROM Daily_Sales_Certification_Batch__c WHERE Id = :certId];
        
        system.debug(certRange.Period_Start_Date__c.format() + ' - ' + certRange.Period_End_Date__c.format());
        return certRange.Period_Start_Date__c.format() + ' - ' + certRange.Period_End_Date__c.format();
    }
    
    @AuraEnabled
    public static String getCertificationComm(Id certId){
        
        Daily_Sales_Certification_Batch__c certComment = [SELECT Id, Overall_Comment__c FROM Daily_Sales_Certification_Batch__c WHERE Id = :certId];
        
        system.debug(certComment.Overall_Comment__c);
        return certComment.Overall_Comment__c;
    }
    
    @AuraEnabled
    public static String getCurrenCode(Id certId){
        
        Daily_Sales_Certification_Batch__c cerrCurrency = [SELECT Id, CurrencyIsoCode FROM Daily_Sales_Certification_Batch__c WHERE Id = :certId];
        
        system.debug(cerrCurrency.CurrencyIsoCode);
        return cerrCurrency.CurrencyIsoCode;
    }
    
    @AuraEnabled
    public static void submitCertification(Id certId, String overallComment, Boolean isToSubmit){
        
        List<Daily_Sale__c> allUpdatedDS = new List<Daily_Sale__c>();
        List<Daily_Sale__c> allDS = [SELECT Id, Status__c, Certified_Amount__c, Store_Closed__c
                                     FROM Daily_Sale__c
                                     WHERE Certification_Batch__c = :certId]; 
        
        //Certified amount cannot be blank unless store close is true. This works together with Process builder "Set Brand Reported Amount"
        for(Daily_Sale__c ds : allDS){
            if((ds.Certified_Amount__c == null ) && (ds.Store_Closed__c == false)){
                throw new AuraHandledException ('Certified Amount must not be empty');                
            }                   
        }
        
        Daily_Sales_Certification_Batch__c certToSubmit = [SELECT Id, Variance_percentage_out_of_limits__c, Overall_Comment__c, Status__c, BP_Validation_Context_Override__c, Brand_Must_Edit_Before_Submission__c
                                                           FROM Daily_Sales_Certification_Batch__c
                                                           WHERE Id = :certId];
        
        String userFirstName = UserInfo.getFirstName();
        String userLastName = UserInfo.getLastName();
        
        if (certToSubmit.Brand_Must_Edit_Before_Submission__c == true && certToSubmit.Overall_Comment__c == overallComment){
            throw new AuraHandledException ('Please edit a field');
            
        } else if((certToSubmit.Variance_percentage_out_of_limits__c == true && (certToSubmit.Overall_Comment__c == null || String.isBlank(certToSubmit.Overall_Comment__c))) 
                  && (certToSubmit.Variance_percentage_out_of_limits__c == true && (overallComment == null || String.isBlank(overallComment)))){
                      throw new AuraHandledException ('Please add a Comment to the Certification');
                  } else {
                      if(isToSubmit == true){
                          certToSubmit.BP_Validation_Context_Override__c = true;
                          
                          try{
                              update certToSubmit;
                          } catch (Exception e){
                              throw new AuraHandledException ('Error on Submit Update');
                          }
                          
                          certToSubmit.Overall_Comment__c = overallComment;
                          certToSubmit.Certified_Date_Time__c = system.now();
                          certToSubmit.Certified_by__c = userFirstName + ' ' + userLastName;
                          certToSubmit.Status__c = 'Pending Approval';
                          for(Daily_Sale__c ds : allDS){
                              ds.Status__c = 'Certified Pending';
                              allUpdatedDS.add(ds);
                          }
                          try{
                              update allUpdatedDS;
                              
                              certToSubmit.BP_Validation_Context_Override__c = false;
                              update certToSubmit;
                              
                              sendEmailToVRFinance(certId);
                              
                          } catch(Exception e){
                              system.debug('Error: ' + e);
                              throw new AuraHandledException ('Error on Submit Update');
                          }
                      }
                  }
    }
    
    @AuraEnabled
    public static List <Daily_Sale__c> saveDaily(List<Daily_Sale__c> lstDaily, Id certId, String overallComment){
        
        Daily_Sales_Certification_Batch__c certValidOverride = [SELECT Id, BP_Validation_Context_Override__c, Brand_Must_Edit_Before_Submission__c, Status__c, Overall_Comment__c
                                                                FROM Daily_Sales_Certification_Batch__c
                                                                WHERE Id = :certId];
        
        system.debug(certValidOverride);
        
        try{
            
            certValidOverride.BP_Validation_Context_Override__c = true;
            if(certValidOverride.Status__c != 'Being Prepared'){
                certValidOverride.Status__c = 'Being Prepared';
            }
            certValidOverride.Overall_Comment__c = overallComment;
            
            if(certValidOverride.Brand_Must_Edit_Before_Submission__c == true){
                certValidOverride.Brand_Must_Edit_Before_Submission__c = false;
            }
            
            update certValidOverride;
            
            update lstDaily;
            
            certValidOverride.BP_Validation_Context_Override__c = false;
            update certValidOverride;
            
            return lstDaily;
            
        } catch(Exception e){
            String error = '' + e;
            Integer start = error.indexOf(':');
            Integer ennd = error.indexOf(',');
            
            if(ennd < 0){
                ennd = error.length();
            }
            if(start < 0){
                start = 0;
            }
            
            system.debug('Error: ' + error + ' e' + e + ' s '+start + ' e ' + ennd);
            throw new AuraHandledException ( error.substring(start, ennd) );
        }
    }
    
    @AuraEnabled
    public static void sendEmailToVRFinance(Id certId){
        
        Daily_Sales_Certification_Batch__c certToSubmit = [SELECT Id, Name, Village_Presence__r.Village__c, Village_Presence__r.Brand__c, Certified_by__c, Period_Start_Date__c, Period_End_Date__c
                                                           FROM Daily_Sales_Certification_Batch__c
                                                           WHERE Id = :certId];
        Village__c theDSCBVillage = [SELECT Name, VR_Finance_Email__c FROM Village__c WHERE Id = :certToSubmit.Village_Presence__r.Village__c];
        if(theDSCBVillage.VR_Finance_Email__c != null){
            Account brandName = [SELECT Name FROM Account WHERE Id = :certToSubmit.Village_Presence__r.Brand__c];
            
            EmailTemplate emailToVR = [SELECT Id, Name, HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Submit Certification Template'];
            
            String pageURL = System.URL.getOrgDomainUrl().toExternalForm() + '/apex/DSCBDashboardFinance?id=' + certToSubmit.Id;
            
            String htmlBody;
            String subject;
            Id tempId;
            
            htmlBody = emailToVR.HtmlValue;
            subject = emailToVR.Subject;
            tempId = emailToVR.Id;
            subject = subject.replace('certificationBatchName', certToSubmit.Name);
            htmlBody = htmlBody.replace('website_here', pageURL);
            htmlBody = htmlBody.replace('certificationPeriodFrom', certToSubmit.Period_Start_Date__c.format());
            htmlBody = htmlBody.replace('certificationPeriodTo', certToSubmit.Period_End_Date__c.format());
            htmlBody = htmlBody.replace('certificationBatchName', certToSubmit.Name);
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject(subject);
            message.setHtmlBody(htmlBody);
            message.setTemplateId(tempId);
            message.setSaveAsActivity(false);
            message.setUseSignature(false);
            message.toAddresses = new String[] {theDSCBVillage.VR_Finance_Email__c};
                
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                logFile__c log = new logFile__c();
                log.Body__c = 'The certification submit email failed to send on class BP_Certification_SCert_Controller: ' + results[0].errors[0].message + ' for Village: ' + theDSCBVillage.Name;
                log.Type__c = 'Error on send email after certification submit';
                insert log;
            }
        }    
    }
}