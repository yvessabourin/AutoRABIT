@RestResource(urlMapping='/MarketingCampaigns')
global with sharing class MarketingCampaignDataReceive{
    @HttpPUT
    global static string projectDetailsReceivedfromOracle(BusinessUnitWrapper responseString){
        System.debug('&&RequestMessage :'+responseString);
        MFIntegrationLogger logger = new MFIntegrationLogger (responseString.SessionId);
        try{
            logger.setInboundRequest(responseString, responseString.SalesforceId);
            logger.setResponseStatusCode(responseString.ResponseStatus.Code);
            logger.setErrorMessage(responseString.ResponseStatus.Message);
            
            Marketing_Campaign__c mc = [select id, Name, Village__c, Oracle_Project_Id__c, Oracle_Secondary_Project_Id__c from Marketing_Campaign__c where id=:responseString.SalesforceId];

            if (responseString.ResponseStatus.Code != '0') {
                mc.Error_Message__c = responseString.ResponseStatus.Message.length() > 250 ? responseString.ResponseStatus.Message.subString(0,250) : responseString.ResponseStatus.Message;
                mc.Integration_Status__c = 'error';
                update mc;
                logger.saveRequests();
                return null;
            }

            Village__c vRcrd = [select Name, Village_Code__c from Village__c where id=:mc.Village__c];

            if(responseString.BusinessUnit.size()>0){
                mc.Oracle_Project_Id__c = responseString.BusinessUnit[0].OracleProjectId;
                mc.Oracle_Project_Number__c = responseString.BusinessUnit[0].OracleProjectNumber;
            }
            
            if(responseString.BusinessUnit.size()>1){
                mc.Oracle_Secondary_Project_Id__c = responseString.BusinessUnit[1].OracleProjectId;
                mc.Oracle_Secondary_Project_Number__c = responseString.BusinessUnit[1].OracleProjectNumber;
            }
            mc.Integration_Status__c = 'confirmed';

            update mc;
            updateMarketingActiviesProjectNumber(mc);
            System.debug('@@@CampaignStatus:'+responseString.ResponseStatus);
            logger.saveRequests();
            return ''+responseString.ResponseStatus;

        } catch (Exception e){
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber());
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
   //   public Decimal OracleProjectId;
        public String OracleProjectId;
        public String OracleProjectNumber;
    }
    global class ResponseStatus{
        public String Code;
        public String Message;
    }

    public static void updateMarketingActiviesProjectNumber (Marketing_Campaign__c mCampaign) {

        List <Marketing_Activity__c> marketingActivitiesToUpdate = [SELECT Id FROM Marketing_Activity__c WHERE Marketing_Campaign__c =: mCampaign.Id];

        for (Marketing_Activity__c mActivity : marketingActivitiesToUpdate) {
            mActivity.Oracle_Project_Id__c = mCampaign.Oracle_Project_Id__c;
            mActivity.Oracle_Secondary_Project_Id__c = mCampaign.Oracle_Secondary_Project_Id__c;
        }

        update marketingActivitiesToUpdate;

    }
}