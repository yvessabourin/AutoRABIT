@RestResource(urlMapping='/MarketingActivities')
global with sharing class MarketingActivityDataReceive{
    @HttpPUT
    global static string taskDetailsReceivedfromOracle(BusinessUnitWrapper activityResponseString){
        MFIntegrationLogger logger = new MFIntegrationLogger (activityResponseString.SessionId);
        try{
            logger.setInboundRequest(activityResponseString, activityResponseString.SalesforceId);
            logger.setResponseStatusCode(activityResponseString.ResponseStatus.Code);
            logger.setErrorMessage(activityResponseString.ResponseStatus.Message);

            Marketing_Activity__c ma = [select id, Name, Marketing_Campaign__c, Marketing_Campaign__r.Village__c, Error_Message__c, Integration_Status__c, Oracle_Project_Id__c, Oracle_Secondary_Project_Id__c from Marketing_Activity__c where id=:activityResponseString.SalesforceId];  


            if (activityResponseString.ResponseStatus.Code != '0') {
                /*
                    Because of DI retry system, it could happen that a Successfully created MA ends up being in Error status. This is why:
                        1-. Marketing Activity creation initially fails in Oracle --> DI enqueues a retry
                        2-. DI Calls back to Salesforce informing the error but, after trying to update the Marketing Activity to reflect the error,
                            Salesforce update fails because, for instance, UNABLE_TO_LOCK_ROWS error --> DI enqueus a retry FOR THE CALLBACK
                        3-. DI performs the retry of the creation of the MA in Oracle and now is successful. DI calls back immediately to Salesforce informing of the success.
                            Salesforce Marketing Activity gets updated to "confirmed"
                        4-. After a few seconds, the failed error callback (point 2) is retried and now it works in Salesforce, changing the MA to error status
                    To avoid this problem, we check that the status hasn't been changed to confirmed already      
                */
                if (ma.Integration_Status__c != 'confirmed') {
                    ma.Error_Message__c = activityResponseString.ResponseStatus.Message.length() > 250 ? activityResponseString.ResponseStatus.Message.subString(0,250) : activityResponseString.ResponseStatus.Message;
                    ma.Integration_Status__c = 'error';
                    update ma;
                }
                logger.saveRequests();
                return null;
            }
            
            Village__c vRcrd = [select Name, Village_Code__c from Village__c where id=:ma.Marketing_Campaign__r.Village__c];
            
            //if(activityResponseString.BusinessUnit.size()>0){
            if(ma.Oracle_Project_Id__c != null){
                ma.Oracle_Task_Id__c = activityResponseString.BusinessUnit[0].OracleTaskId;
                ma.Oracle_Task_Number__c = activityResponseString.BusinessUnit[0].OracleTaskNumber;
            }
            
            //if(activityResponseString.BusinessUnit.size()>1){ 
            if(ma.Oracle_Project_Id__c == null && ma.Oracle_Secondary_Project_Id__c != null ){  
                ma.Oracle_Secondary_Task_Id__c = activityResponseString.BusinessUnit[0].OracleTaskId;
                ma.Oracle_Secondary_Task_Number__c = activityResponseString.BusinessUnit[0].OracleTaskNumber;
            } else if( ma.Oracle_Secondary_Project_Id__c != null ) {
                ma.Oracle_Secondary_Task_Id__c = activityResponseString.BusinessUnit[1].OracleTaskId;
                ma.Oracle_Secondary_Task_Number__c = activityResponseString.BusinessUnit[1].OracleTaskNumber;            
            }

            ma.Integration_Status__c = 'confirmed';

            update ma;
            logger.saveRequests();
            return ''+activityResponseString.ResponseStatus;
 
        }catch (Exception e){         
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber());   
            logger.setErrorMessage(e.getMessage() + 'LN:' + e.getLineNumber());
            logger.saveRequests();
            RestContext.response.statusCode = 500;
            return e.getMessage();
        }  
    }
    global class BusinessUnitWrapper{
        public String SessionId;
        public Id SalesforceId;
        public BusinessUnit[] BusinessUnit;
        public ResponseStatus ResponseStatus;
    }
    global class BusinessUnit{
        public String BusinessUnitCode;
        public String OracleTaskId;
        public String OracleTaskNumber;
    } 
    global class ResponseStatus{
        public String Code;
        public String Message;
    } 
}