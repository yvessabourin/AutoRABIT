global class MarketingCampaignBatchCallout implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    Set <Id> insertedMarketingCampaignIds;

    public MarketingCampaignBatchCallout(Set <Id> insertedMarketingCampaignIds){
        this.insertedMarketingCampaignIds = insertedMarketingCampaignIds;
    }

    public class MarketingCampaignsDetails {
        public List<Campaign> Campaigns = new List <Campaign> ();
    }

    public class Campaign{
        public String SalesforceId;
        public DateTime SalesforceDateTime;
        public String CampaignName;
        public String MarketingCampaignRef;
        public Date StartDate;
        public Date EndDate;
        public String CampaignType;
        public String CampaignStatus;
        public Village Village;
        public List<BusinessUnit> BusinessUnit;
        
        public Campaign(String id, String cName, String mcref, Date sDate, Date eDate, String cType, String cStatus, Datetime cSDateTime,Village vlgRecords, List<BusinessUnit> BUnit){
            this.SalesforceId =id;
            this.CampaignName =cName;
            this.MarketingCampaignRef =mcref;
            this.StartDate =sDate;
            this.EndDate =eDate;
            this.CampaignType =cType;
            this.CampaignStatus =cStatus;
            this.SalesforceDateTime =cSDateTime;
            this.Village =vlgRecords;
            this.BusinessUnit =BUnit;
            
        }
    }    
    
    public class Village{
        public String VillageCode;
        public String VillageName;
    }

    public class BusinessUnit {
        public String BusinessUnitCode;
        public String BusinessUnitName;
        public String OraclePrimaryBusinessUnit;
        public String OracleSourceTemplateName;
    }
    
    
    global List <Marketing_Campaign__c> start(Database.BatchableContext BC){
        return [SELECT Name, Marketing_Campaign_Ref__c, Start_Date__c, End_Date__c, RecordTypeId, Status__c, CreatedDate, Village__c, Error_Message__c FROM Marketing_Campaign__c WHERE Id IN: this.insertedMarketingCampaignIds];
    }
    
    global void execute(Database.BatchableContext BC, List<Marketing_Campaign__c> mcList){    

        List<Marketing_Campaign__c> mctemplist = new  List<Marketing_Campaign__c>();
       
        String endPointRequestURL = System.Label.MarketingCampaignDIEndPoint;
        String apimkey = System.Label.MarketingFinanceIntegrationAPIMKey;
        MFIntegrationLogger logger = new MFIntegrationLogger ();
        logger.setMarketingCampaignAsRelatedObject();

        Map <Id, Village__c> vRcrdMap = new Map <Id, Village__c>([select Id, Name, Village_Code__c from Village__c]);
        
        List<Business_Unit__c> bulist = [select Name, Business_Unit_Code__c, OraclePrimaryBusinessUnit__c, Oracle_Source_Template_Number__c,Village__r.Name from Business_Unit__c];
        
        MarketingCampaignsDetails marketingCampaignsWrapper = new MarketingCampaignsDetails();
        
        
        try {
            for (Marketing_Campaign__c maCamp : mcList){
                Id mId = maCamp.id;
                system.debug('mId'+mId); 
                String mName= maCamp.Name;
                String mCRef= maCamp.Marketing_Campaign_Ref__c;
                Date mStartDate = maCamp.Start_Date__c;
                Date mEndDate = maCamp.End_Date__c;
                string mCtype = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosById().get(maCamp.recordtypeid).getname();
                String mCstatus = maCamp.Status__c;
                Datetime mCreateDate = maCamp.CreatedDate;
                
                maCamp.NumberOfCampaigns__c = mcList.size();
                System.debug('***Number of Campaigns send  :'+ maCamp.NumberOfCampaigns__c);
          
                Village vlgwrap = new Village();
                vlgwrap.VillageCode =  vRcrdMap.get(maCamp.Village__c).Village_Code__c;
                vlgwrap.VillageName = vRcrdMap.get(maCamp.Village__c).Name;  
                
                List<BusinessUnit>  businessUnitlist  = new List<BusinessUnit>();
                for(Business_Unit__c bu : bulist){
                    if(bu.Village__r.Name == vlgwrap.VillageName){ 
                        BusinessUnit tempbu = new BusinessUnit();
                        tempbu.BusinessUnitCode = bu.Business_Unit_Code__c;
                        tempbu.BusinessUnitName = bu.Name;
                        tempbu.OraclePrimaryBusinessUnit = bu.OraclePrimaryBusinessUnit__c;
                        tempbu.OracleSourceTemplateName = bu.Oracle_Source_Template_Number__c;
                        businessUnitlist.add(tempbu);
                    }
                } 

                Campaign campaignToSend = new Campaign(mId,mName,mCRef,mStartDate,mEndDate,mCtype,mCstatus,mCreateDate,vlgwrap,businessUnitlist);
                marketingCampaignsWrapper.Campaigns.add(campaignToSend);
                logger.setOutboundRequest(campaignToSend, mId);
            }
            String jsonBody = JSON.serialize(marketingCampaignsWrapper);   
            system.debug('json response :'+jsonBody); 
            
            Http http =new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPointRequestURL);
            request.setMethod('POST'); 
            request.setHeader('Ocp-Apim-Subscription-Key', apimkey);
            request.setHeader('content-type', 'application/json');
            request.setHeader('Content-Length', '0'); 
            request.setBody(jsonBody);
            request.setTimeout(20000);
            
            HttpResponse response = http.send(request); 
            system.debug('ResponseReceived$$$ : '+ response);
            logger.setResponseStatusCode(response.getStatusCode());
            
            if(response.getStatusCode()==202){
                system.debug('Successfull Response'+ response.getBody());  
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String SessionIdreceive = (String)results.get('SessionId');
                Decimal numofcamp = (Decimal)results.get('NumberOfCampaigns');
                System.debug('&&& Number of Campaigns received :'+ numofcamp);
                for (Marketing_Campaign__c maCamp : mcList) {
                    maCamp.OracleSessionId__c = SessionIdreceive;
                    Decimal numofCampSalesforce = maCamp.NumberOfCampaigns__c;
                    if( numofCampSalesforce != numofcamp) {
                        maCamp.Error_Message__c = 'Mis-match in number of campaigns processed from Salesforce and Oracle';
                    }
                    if(maCamp.Error_Message__c != ''){
                        maCamp.Error_Message__c = '';
                    }
                    mctemplist.add(maCamp);
                }
                logger.setSessionId(SessionIdreceive);
            } else {
                for (Marketing_Campaign__c maCamp : mcList) {
                    maCamp.Error_Message__c = response.getStatusCode()+' '+ response.getStatus();
                    maCamp.Integration_Status__c = 'error';
                    maCamp.Re_send_to_Oracle__c = True;  
                    mctemplist.add(maCamp);
                }      
                logger.setErrorMessage(response.getStatus());
            }
        } catch (Exception e){ 
            for (Marketing_Campaign__c maCamp : mcList) {
                maCamp.Error_Message__c = e.getMessage() + 'LN:' + e.getLineNumber();                                
                maCamp.Integration_Status__c = 'error';
                maCamp.Re_send_to_Oracle__c = True;  
                mctemplist.add(maCamp);   
            }
            logger.setErrorMessage(e.getMessage() + 'LN:' + e.getLineNumber());
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber());           
        } finally {
            for (Marketing_Campaign__c mc : mctemplist) {
                mc.Re_send_to_Oracle__c = false;
            } 
            update mctemplist;        
            logger.saveRequests(); 
        }
    }

    global void finish(Database.BatchableContext BC){}
}