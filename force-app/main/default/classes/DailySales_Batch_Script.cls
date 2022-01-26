/* Script to update TOR Records permissions, Change record types to Not Editable and for Certification Calculation on old records.
*/

global class DailySales_Batch_Script implements Database.Batchable<sObject>{
    
    /*private static final id dsNetRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('Net').RecordTypeId;
    private static final id dsFullPriceRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Full_Price').RecordTypeId;
    private static final id dsGrossRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('Gross').RecordTypeId;
    private static final id dsFBCoversRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('F & B Covers').RecordTypeId;
    private static final id dsNetNERecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('Net NOT Editable').RecordTypeId;
    private static final id dsFullPriceNERecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Full_Price_NOT_Editable').RecordTypeId;
    private static final id dsGrossNERecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('Gross NOT Editable').RecordTypeId;
    private static final id dsFBCoversNERecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get('F & B Covers NOT Editable').RecordTypeId;*/
    
    private static final id dsCurrentRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Current').RecordTypeId;
    private static final id dsHistoricalRecordTypeId = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Historical').RecordTypeId;
    
    private List<string> brandList {get;set;}
    private string village {get;set;}
    private string initialDateValue {get;set;}
    private string endDateValue {get;set;}
    
    global DailySales_Batch_Script(List<string> brandQuery, String villageQuery, String initialDate, String endDate) {
        brandList = brandQuery;
        village = villageQuery;
        initialDateValue = initialDate;
        endDateValue = endDate;
    }  
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        if(brandList.isEmpty() || village == null || initialDateValue == null || endDateValue == null){
            logFile__c log = new logFile__c();
            log.Body__c = 'Brand List size: ' + brandList.size()+ ' Village: ' + village;
            log.Type__c = 'DailySales UAT Script ' + village;
            insert log;
            system.debug('Empty List');
            return NULL;
        }else{ 
            String query = 'SELECT ID, Name, RecordTypeId, Status__c, Trading_Date__c, Certified_Amount__c, Total_NET_SALES__c,';
            query += ' NET_Value_of_Discounts__c, Certified_Amount_NetTotal__c, Store__c, Store__r.Brand__c, Store__r.Village__c, Store__r.Name,';
            query += ' Certified_Amount_Discount__c, Certification_Batch__c, Certification_Batch__r.Name,';
            query += ' Certification_Batch__r.Period_Start_Date__c, Certification_Batch__r.Period_End_Date__c';
            query += ' FROM Daily_Sale__c';
            query += ' WHERE (Store__r.Village__r.Name = \'' + village + '\' )';
            query += ' AND (';
            for(string brand : brandList){
                query +=  ' Store__r.Brand__r.Name =\'' + brand + '\' OR';
            }
            query = query.removeEnd('OR');
            query += ')';
            query += ' AND (Trading_Date__c >= ' + initialDateValue + ' AND Trading_Date__c <=' + endDateValue + ')';
            system.debug(query);
            return Database.getQueryLocator(query);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Daily_Sale__c> scope){
        Set<Id> setIdDS = new Set<Id>();
        Map<Id, Map<Date, Id>> dscbByVPStartDate = new Map<Id, Map<Date, Id>>();
        Map<Id, Map<Date, Id>> dscbByVPCloseDate = new Map<Id, Map<Date, Id>>();
        Map<Id, String> certPeriod = new Map<Id, String>();
        List<Village_Presence__c> theVPs = new List<Village_Presence__c>();
        List<Daily_Sales_Certification_Batch__c> allDSCB = new List<Daily_Sales_Certification_Batch__c>();

        String queryVillagePresence = 'SELECT Id, CertSales_CertPeriod_Type__c FROM Village_Presence__c WHERE (';
        for(string brand : brandList){
                queryVillagePresence +=  ' Brand__r.Name =\'' + brand + '\' OR';
            }
        queryVillagePresence = queryVillagePresence.removeEnd('OR');
        queryVillagePresence += ') AND Village__r.Name = \'' + village + '\'';
            system.debug(queryVillagePresence);
        try{
            theVPs = Database.query(queryVillagePresence);
        } catch (QueryException e){
            system.debug('No Village Presence return with the brandList and village variables informed');
        }

        try{
            allDSCB = [SELECT Id, Period_Start_Date__c, Period_End_Date__c, Village_Presence__c, Name
                                                    FROM Daily_Sales_Certification_Batch__c
                                                    WHERE Village_Presence__c = :theVPs];
                                                    system.debug(allDSCB);
        } catch (QueryException e){
            system.debug('No Daily Sales Certification Batch exists for the brandList and village variables informed');
        }
        
        for(Village_Presence__c vp : theVPs){
            certPeriod.put(vp.Id, vp.CertSales_CertPeriod_Type__c);
        }
        
        // Set the Start Date in the beggining of the month - It should only be utilised once (first time in production)
        if(!allDSCB.isEmpty()){
            for(Daily_Sales_Certification_Batch__c dscb : allDSCB){
                if(certPeriod.get(dscb.Village_Presence__c) == 'Monthly'){
                    if(!((dscb.Period_Start_Date__c.toStartOfMonth()).isSameDay(dscb.Period_Start_Date__c))){
                        dscb.Period_Start_Date__c = dscb.Period_Start_Date__c.toStartOfMonth();
                    }
                } else if (certPeriod.get(dscb.Village_Presence__c) == 'Quarterly'){
                    Integer month = dscb.Period_Start_Date__c.month();
                    Integer year = dscb.Period_Start_Date__c.year();
                    if(month == 1 || month == 2 || month == 3){
                        dscb.Period_Start_Date__c = Date.newInstance(year, 1, 1);
                    } else if(month == 4 || month == 5 || month == 6){
                        dscb.Period_Start_Date__c = Date.newInstance(year, 4, 1);
                    } else if(month == 7 || month == 8 || month == 9){
                        dscb.Period_Start_Date__c = Date.newInstance(year, 7, 1);
                    } else if(month == 10 || month == 11 || month == 12){
                        dscb.Period_Start_Date__c = Date.newInstance(year, 10, 1);
                    }
                }
            }

            try{
                update allDSCB;
            } catch (Exception e){
                LogFile__c log = new LogFile__c();
                log.Body__c = e.getMessage();
                log.Type__c = 'Error when try to update DSCB: ' + brandList;
                insert log;
            }
            
            for(Daily_Sales_Certification_Batch__c dscb : allDSCB){
                if(dscb.Period_Start_Date__c != NULL && dscb.Period_End_Date__c != NULL){
                    if(!dscbByVPStartDate.containsKey(dscb.Village_Presence__c) || !dscbByVPCloseDate.containsKey(dscb.Village_Presence__c)){
                        dscbByVPStartDate.put(dscb.Village_Presence__c, new Map<Date, Id>());
                        dscbByVPCloseDate.put(dscb.Village_Presence__c, new Map<Date, Id>());
                    }
                    dscbByVPStartDate.get(dscb.Village_Presence__c).put(dscb.Period_Start_Date__c, dscb.Id);
                    dscbByVPCloseDate.get(dscb.Village_Presence__c).put(dscb.Period_End_Date__c, dscb.Id);
                }
            }
        } else {
            LogFile__c log = new LogFile__c();
            log.Body__c = 'No Daily Sales Certification Batch exists for the brandList:' + brandList;
            log.Type__c = 'Batch Script error';
            insert log;
        }
        
        for(Daily_Sale__c sc : scope){
            if(sc.Status__c == 'TOR' || sc.Status__c == 'Certified Pending' || sc.Status__c == 'Certified Approved' ||
               sc.Status__c == 'Certified Complete' || sc.Status__c == 'Certified Re-opened'){
                   /*if(sc.RecordTypeId == dsNetRecordTypeId){
                       sc.RecordTypeId = dsNetNERecordTypeId;
                   } else if(sc.RecordTypeId == dsFullPriceRecordTypeId){
                       sc.RecordTypeId = dsFullPriceNERecordTypeId;
                   } else if(sc.RecordTypeId == dsGrossRecordTypeId){
                       sc.RecordTypeId = dsGrossNERecordTypeId;
                   } else if(sc.RecordTypeId == dsFBCoversRecordTypeId){
                       sc.RecordTypeId = dsFBCoversNERecordTypeId;
                   }*/
                   if (sc.RecordTypeId == dsCurrentRecordTypeId) {
                       sc.RecordTypeId = dsHistoricalRecordTypeId;
                   }
                   setIdDS.add(sc.Id);    
               }
            
            if(sc.Certified_Amount__c == NULL){
                if(sc.Total_NET_SALES__c != NULL && sc.NET_Value_of_Discounts__c != NULL){
                    sc.Certified_Amount__c = sc.Certified_Amount_NetTotal__c + sc.Certified_Amount_Discount__c;
                }
            }
            
            if(sc.Certification_Batch__c == NULL && !dscbByVPStartDate.isEmpty() && !dscbByVPCloseDate.isEmpty()){
                for(Date mapValueStart : dscbByVPStartDate.get(sc.Store__c).keySet()){
                    for(Date mapValueClose : dscbByVPCloseDate.get(sc.Store__c).keySet()){
                        if(sc.Trading_Date__c >= mapValueStart && sc.Trading_Date__c <= mapValueClose &&
                           dscbByVPStartDate.get(sc.Store__c).get(mapValueStart) == dscbByVPCloseDate.get(sc.Store__c).get(mapValueClose)){
                               sc.Certification_Batch__c = dscbByVPStartDate.get(sc.Store__c).get(mapValueStart);
                           }
                    }
                }
            }
        }
        
        update scope;
        
        CalculationOfAmounts.changesAmounts(scope);
        
        if(!setIdDS.isEmpty()){
            try{
                DailySaleTriggerHelper.ProcessShares(scope, setIdDS);   
            }catch(Exception e){
                logFile__c log = new logFile__c();
                log.Body__c = e.getMessage();
                log.Type__c = 'DailySales UAT Script ' + village;
                insert log;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}