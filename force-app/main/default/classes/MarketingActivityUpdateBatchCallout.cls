global class MarketingActivityUpdateBatchCallout implements Database.Batchable<sObject>, Database.AllowsCallouts{

    Set<Id> maUpdateid = new Set<Id>();

    public MarketingActivityUpdateBatchCallout(Set<Id> maUpdateid){
        this.maUpdateid = maUpdateid;
    }

    public class MarketingActivityDetails
    {
        public List<Activity> Activities = new List <Activity> ();
    }

    public class Activity{
        public Id SalesforceId;
        public DateTime SalesforceDateTime;
        public String ActivityName;
        public String MarketingActivityNumber;
        public Date StartDate;
        public Date EndDate;
        public String ActivityStatus;
        public String BusinessFunction;
        public String Channel;
        public String SubChannel;
        public String ExpenditureCategory;
        public String ExpenditureType;
        public Village village ;
        public BusinessUnit[] BusinessUnit;
        public Activity(Id Sid, DateTime aSdateTime, String aName, String aNumber, Date sDate, Date eDate, String aStatus, String aBFunction, String aChannel, String aSubChannel,String ECategory, String EType, Village vlgRecords, BusinessUnit[] bulist){
            this.SalesforceId = Sid;
            this.SalesforceDateTime = aSdateTime;
            this.ActivityName = aName;
            this.MarketingActivityNumber = aNumber;
            this.StartDate = sDate;
            this.EndDate = eDate;
            this.ActivityStatus = aStatus;
            this.BusinessFunction = aBFunction;
            this.Channel = aChannel;
            this.SubChannel = aSubChannel;
            this.ExpenditureCategory = ECategory;
            this.ExpenditureType = EType;
            this.village = vlgRecords;
            this.BusinessUnit = bulist;
        }
    }
    public class Village{
        public String VillageCode;
        public String VillageName;
    }
    public class BusinessUnit{
        public String BusinessUnitCode;
        public String BusinessUnitName;
        public String OraclePrimaryBusinessUnit;
        public String OracleProjectId;
        public String OracleTaskId;

    }

    global List<Marketing_Activity__c> start(Database.BatchableContext BC){
        return [Select Oracle_Project_Id__c, Oracle_Secondary_Project_Id__c, id,Oracle_Task_Id__c, Oracle_Secondary_Task_Id__c,Transfer_To_Oracle__c,LastModifiedBy.Name, Expenditure_Category__c, Expenditure_Type__c, Marketing_Campaign__c, Marketing_Campaign__r.Village__c,Marketing_Campaign__r.Village__r.Name, CreatedDate, LastModifiedDate, Name, Marketing_Activity_Ref__c, Start_Date__c, End_Date__c, Status__c, Business_Function__c, Channel__c, Sub_Channel__c,MA_OracleSessionId__c,Error_Message__c  from Marketing_Activity__c where id IN : maUpdateid ORDER BY Marketing_Campaign__c];
    }

    global void execute(Database.BatchableContext BC, List<Marketing_Activity__c> maList){

        List<Marketing_Activity__c> matemplist = new  List<Marketing_Activity__c>();

        string endPointRequestURL = System.Label.MarketingActivityDIEndPoint;
        string apimkey = System.Label.MarketingFinanceIntegrationAPIMKey;
        MFIntegrationLogger logger = new MFIntegrationLogger ();
        logger.setMarketingActivityAsRelatedObject();

        Map <Id, Village__c> vRcrdMap = new Map <Id, Village__c>([select Id, Name, Village_Code__c from Village__c]);
        Map <Id, List <Business_Unit__c>> buByVillage = new Map <Id, List <Business_Unit__c>> ();

        for(Business_Unit__c bu : [select Village__c, Name, Business_Unit_Code__c, OraclePrimaryBusinessUnit__c, Oracle_Source_Template_Number__c from Business_Unit__c]) {
            if (buByVillage.containsKey(bu.Village__c)) {
                buByVillage.get(bu.Village__c).add(bu);
            } else {
                buByVillage.put(bu.Village__c, new List <Business_Unit__c> {bu});
            }
        }

        MarketingActivityDetails marketingActivitiesWrapper = new MarketingActivityDetails();


        try {
            for (Marketing_Activity__c maActivity : maList){
                id aId = maActivity.id;

                DateTime aCreateDate = maActivity.LastModifiedDate;
                String aName = maActivity.Name;
                String aMAref = maActivity.Marketing_Activity_Ref__c;
                Date aSdate = maActivity.Start_Date__c;
                Date aEdate = maActivity.End_Date__c;
                String aStatus = maActivity.Status__c;
                String aBFuntion = maActivity.Business_Function__c;
                String aChannel = maActivity.Channel__c;
                String aSubChannel = maActivity.Sub_Channel__c;
                String aECategory = maActivity.Expenditure_Category__c;
                String aEType = maActivity.Expenditure_Type__c;

                Village__c village = vRcrdMap.get(maActivity.Marketing_Campaign__r.Village__c);
                Village vlgwrap = new Village();
                vlgwrap.VillageCode = village.Village_Code__c;
                vlgwrap.VillageName = village.Name;

                List<BusinessUnit> tempbu = new List<BusinessUnit>();
                List<Business_Unit__c> bulist = buByVillage.get(village.Id);

                if(!bulist.isEmpty()) {
                    if(bulist.size()>0){
                        BusinessUnit bu1 = new BusinessUnit();
                        bu1.BusinessUnitCode = bulist[0].Business_Unit_Code__c;
                        bu1.BusinessUnitName = bulist[0].Name;
                        bu1.OraclePrimaryBusinessUnit = bulist[0].OraclePrimaryBusinessUnit__c;
                        bu1.OracleProjectId = maActivity.Oracle_Project_Id__c;
                        bu1.OracleTaskId = maActivity.Oracle_Task_Id__c;
                        if(!String.isBlank(maActivity.Oracle_Project_Id__c) && !String.isBlank(maActivity.Oracle_Task_Id__c) ) {
                            tempbu.add(bu1);
                        }
                    }
                    if(bulist.size()>1){
                        BusinessUnit bu2 = new BusinessUnit();
                        bu2.BusinessUnitCode = bulist[1].Business_Unit_Code__c;
                        bu2.BusinessUnitName = bulist[1].Name;
                        bu2.OraclePrimaryBusinessUnit = bulist[1].OraclePrimaryBusinessUnit__c;
                        bu2.OracleProjectId = maActivity.Oracle_Secondary_Project_Id__c;
                        //bu2.OracleTaskId = maActivity.Oracle_Secondary_Task_Id__c;

                        if(!String.isBlank(maActivity.Oracle_Secondary_Task_Id__c) ) {
                            bu2.OracleTaskId = maActivity.Oracle_Secondary_Task_Id__c;
                        }else{
                            bu2.OracleTaskId = maActivity.Oracle_Task_Id__c;
                        }
                        tempbu.add(bu2);
                    }
                }
                if(tempbu.size()>0){
                    Activity activityToSend = new Activity(aId,aCreateDate,aName,aMAref,aSdate,aEdate,aStatus,aBFuntion,aChannel,aSubChannel,aECategory,aEType,vlgwrap,tempbu);
                    marketingActivitiesWrapper.Activities.add(activityToSend);
                    logger.setOutboundRequest(activityToSend, aId);
                }
            }
            String jsonBody = JSON.serialize(marketingActivitiesWrapper);

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
                for (Marketing_Activity__c maActivity : maList) {
                    maActivity.MA_OracleSessionId__c = SessionIdreceive;
                    if(maActivity.Error_Message__c != ''){
                        maActivity.Error_Message__c = '';
                    }
                    matemplist.add(maActivity);
                }
                logger.setSessionId(SessionIdreceive);
            } else{
                logger.setErrorMessage(response.getStatus());
                for (Marketing_Activity__c maActivity : maList) {
                    maActivity.Error_Message__c = response.getStatusCode()+' '+ response.getStatus();
                    maActivity.Integration_Status__c = 'error';
                    matemplist.add(maActivity);
                }
            }

        }catch (Exception e) {
            for (Marketing_Activity__c maActivity : maList) {
                maActivity.Error_Message__c = e.getMessage()+'Issue at Line:'+e.getLineNumber();
                matemplist.add(maActivity);
            }
            logger.setErrorMessage(e.getMessage() + 'LN:' + e.getLineNumber());
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
        } finally {
            for (Marketing_Activity__c ma : matemplist) {
                ma.Re_send_to_Oracle_for_NewActivity__c = false;
            } 
            update matemplist;            
            logger.saveRequests();
        }
    }

    global void finish(Database.BatchableContext BC){}
}