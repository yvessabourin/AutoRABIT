global class MarketingCampaignUpdateBatchCallout implements Database.Batchable<sObject>, Database.AllowsCallouts{
     
    Set<Id> mcUpdateid = new Set<Id>();
    
    public MarketingCampaignUpdateBatchCallout(Set<id> mcUpdateid){
        this.mcUpdateid = mcUpdateid;
    }
       
    public class MarketingCampaignsDetails
    {
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
        public BusinessUnit[] BusinessUnit;
        
        public Campaign(String id, String cName, String mcref, Date sDate, Date eDate, String cType, String cStatus, Datetime cSDateTime,Village vlgRecords, BusinessUnit[] BUnit){
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
        public String OracleProjectId;
        public String OracleProjectNumber;
        
    } 
    
    global List <Marketing_Campaign__c> start(Database.BatchableContext BC){
        return [select id,Oracle_Project_Id__c, Oracle_Project_Number__c,Oracle_Secondary_Project_Id__c,Oracle_Secondary_Project_Number__c,LastModifiedBy.Name, Transfer_To_Oracle__c, Name, Start_Date__c, End_Date__c, RecordTypeId, Marketing_Campaign_Ref__c, Status__c, CreatedDate, LastModifiedDate, Village__c,Village__r.Name, OracleSessionId__c,Error_Message__c  from Marketing_Campaign__c where id IN : mcUpdateid];
    } 
    
    global void execute(Database.BatchableContext BC, List<Marketing_Campaign__c> mcList){   

        List<Marketing_Campaign__c> mctemplist = new  List<Marketing_Campaign__c>();

        String vname;
        String mcid;
        string endPointRequestURL = System.Label.MarketingCampaignDIEndPoint;
        string apimkey = System.Label.MarketingFinanceIntegrationAPIMKey;
        MFIntegrationLogger logger = new MFIntegrationLogger ();
        logger.setMarketingCampaignAsRelatedObject();
      
        Map <Id, Village__c> vRcrdMap = new Map <Id, Village__c>([select Id, Name, Village_Code__c from Village__c]);
        Map <Id, List <Business_Unit__c>> buByVillage = new Map <Id, List <Business_Unit__c>> ();

        for(Business_Unit__c bu : [select Village__c, Name, Business_Unit_Code__c, OraclePrimaryBusinessUnit__c, Oracle_Source_Template_Number__c from Business_Unit__c]) {
            if (buByVillage.containsKey(bu.Village__c)) {
                buByVillage.get(bu.Village__c).add(bu);
            } else {
                buByVillage.put(bu.Village__c, new List <Business_Unit__c> {bu});
            }
        }
        
        
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
                Datetime mCreateDate = maCamp.LastModifiedDate;
                Id vid = maCamp.Village__c;
                system.debug('date**'+mCreateDate);
                
                Village__c village = vRcrdMap.get(maCamp.Village__c);
                Village vlgwrap = new Village();
                vlgwrap.VillageCode =  village.Village_Code__c;
                vlgwrap.VillageName = village.Name;

                if(maCamp.LastModifiedBy.Name != System.Label.DataIntegrationUser){
                    System.debug('Record inserted');
                    List<BusinessUnit> tempbu = new List<BusinessUnit>();
                    List<Business_Unit__c> bulist = buByVillage.get(village.Id);
                    if(!bulist.isEmpty()) {
                        if(bulist.size()>0){
                            BusinessUnit bu1 = new BusinessUnit();
                            bu1.BusinessUnitCode = bulist[0].Business_Unit_Code__c;
                            System.debug('BUCODE***'+bu1.BusinessUnitCode);
                            bu1.BusinessUnitName = bulist[0].Name;
                            bu1.OraclePrimaryBusinessUnit = bulist[0].OraclePrimaryBusinessUnit__c;
                            bu1.OracleSourceTemplateName = bulist[0].Oracle_Source_Template_Number__c;
                            bu1.OracleProjectNumber = maCamp.Oracle_Project_Number__c;
                            bu1.OracleProjectId = maCamp.Oracle_Project_Id__c;
                            tempbu.add(bu1);            
                        } 
                        if(bulist.size()>1){
                            BusinessUnit bu2 = new BusinessUnit();
                            bu2.BusinessUnitCode = bulist[1].Business_Unit_Code__c;
                            System.debug('BUCODE 2***'+bu2.BusinessUnitCode);
                            bu2.BusinessUnitName = bulist[1].Name;
                            bu2.OraclePrimaryBusinessUnit = bulist[1].OraclePrimaryBusinessUnit__c;
                            bu2.OracleSourceTemplateName = bulist[1].Oracle_Source_Template_Number__c;
                            bu2.OracleProjectNumber = maCamp.Oracle_Secondary_Project_Number__c;
                            bu2.OracleProjectId = maCamp.Oracle_Secondary_Project_Id__c;
                            tempbu.add(bu2);
                        }
                    }
                    
                    Campaign campaignToSend = new Campaign(mId,mName,mCRef,mStartDate,mEndDate,mCtype,mCstatus,mCreateDate,vlgwrap,tempbu);
                    marketingCampaignsWrapper.Campaigns.add(campaignToSend);
                    logger.setOutboundRequest(campaignToSend, mId);

                }
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
                for (Marketing_Campaign__c maCamp : mcList) {
                    maCamp.OracleSessionId__c = SessionIdreceive; 

                    If(maCamp.Error_Message__c != ''){
                        maCamp.Error_Message__c = '';
                    }
                    mctemplist.add(maCamp);
                }
                logger.setSessionId(SessionIdreceive);
            } else{
                for (Marketing_Campaign__c maCamp : mcList) {
                    maCamp.Error_Message__c = response.getStatusCode()+' '+ response.getStatus();                                
                    maCamp.Integration_Status__c = 'error';
                    mctemplist.add(maCamp);
                }
                logger.setErrorMessage(response.getStatus());
                system.debug('There is an error occur in integration');    
            }
        }catch (Exception e) {         
            for (Marketing_Campaign__c maCamp : mcList) {
                maCamp.Error_Message__c = e.getMessage() + 'LN:' + e.getLineNumber();                                
                maCamp.Integration_Status__c = 'error';
                mctemplist.add(maCamp);
            }     
            logger.setErrorMessage(e.getMessage() + 'LN:' + e.getLineNumber());
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );           
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