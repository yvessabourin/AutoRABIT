global class DailySalesBatchProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    private static final id defaultRecordTypeID = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByDeveloperName.get('Current').RecordTypeId;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {     
        
        Datetime dt = System.now(); 
        string theDay = dt.format('EEEE'); 
        System.debug('@@@  the day is .. ' +  dt.format('EEEE'));
        
        string query = 'select Id, Name, Unit__c, Village__c, Brand__c, Daily_Sale_Record_Type_Override__c,Brand_Event_Active__c, Pop_Up_Boutique_Active__c, ';
        query += ' Village__r.Village_Code__c, Village__r.Currency__c, Village__r.CurrencyISOCode, Village__r.Default_Daily_Sales_Record_Type__c, ';
        query += ' Unit__r.Name, Unit__r.MRI_Unit_Id__c,';
        query += ' Daily_Sale_Active_Date__c,';
        // ----- START LIS DEV Team @Hugo
        query += ' CertSales_Active__c, Village__r.CertSales_Report_Sales_Grace_Period_Days__c,';
        // ----- END LIS DEV Team @Hugo
        query += ' F_B_Covers_Active__c, Current_Season_Bestsellers_Active__c, Special_Curated_Selection_Active__c, Brand_Remote_Sales_Active__c, Brand_Private_Appointment_Active__c ';
        query += ' from Village_Presence__c';
        query += ' where Daily_Sales_Active__c = true and Status__c = ' + '\'Trading\'';
        query += ' and (Daily_Sale_Active_Date__c = null or Daily_Sale_Active_Date__c <= TODAY)';
        query += ' order by Village__c';
        System.debug('@@@  query is .. ' +  query);            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Sobject> scope)
    {
        
        Map <String, String> valueToLabelMap = new Map <String, String> ();
        for (PicklistEntry pEntry : Village_Presence__c.Daily_Sale_Record_Type_Override__c.getDescribe().getPicklistValues()) {
            valueToLabelMap.put(pEntry.getValue(), pEntry.getLabel());
        }
        
        list<Daily_Sale__c> dsList = new list<Daily_Sale__c>();
        integer currentYear = system.today().year();
        
        // retrieve closed periods for each village
        list<Village_Closed_Period__c> villageCloseDatesList = [select From__c, To__c, Village_Days_Closed__c, village__c from Village_Closed_Period__c 
                                                                where Current_Year__c = :currentYear
                                                                and (from__c >= :system.today() or To__c >= :system.today())
                                                                and active__c = true  
                                                                order by From__c ];
        // create map of village closed periods
        map<Id, list<date>> villageClosedMap = new map<Id, list<date>>();
        for (Village_Closed_Period__c vcp :villageCloseDatesList){
            list<date> closedDates = villageClosedMap.get(vcp.village__c);
            if (closedDates == null)
                closedDates = new list<date>();
            integer daysClosed = vcp.from__c.daysBetween(vcp.To__c); //retrieve number of days covered by closed period
            while(daysClosed >= 0){ 
                Date dt = vcp.from__c.addDays(daysClosed); 
                closedDates.add(dt); // add each closed date to a list
                daysClosed--;
            }
            villageClosedMap.put(vcp.Village__c, closedDates);
            
        }
        
        // ----- START LIS DEV Team @Hugo
        List<Daily_Sales_Certification_Batch__c> allCertifications = [SELECT Id, Period_Start_Date__c, Period_End_Date__c, Village_Presence__c FROM Daily_Sales_Certification_Batch__c
                                                    WHERE Period_Start_Date__c <= :system.today()
                                                    AND Period_End_Date__c >= :system.today()];

        Map<String, Id> mapCertifications = new Map<String, Id>();
        Map<String, Date> mapCertDate = new Map<String, Date>();
        for(Daily_Sales_Certification_Batch__c theCertification : allCertifications){
            mapCertifications.put(theCertification.Village_Presence__c, theCertification.Id);
            mapCertDate.put(theCertification.Village_Presence__c, theCertification.Period_End_Date__c);
        }
        // ----- END LIS DEV Team @Hugo
        
        if (!scope.isEmpty()){
            
            map<string, string> closedVillages = new map<string, string>();
            
            for (Sobject vp :scope){
                string vpId = string.valueOf(vp.get('Id'));
                string brandId = string.valueOf(vp.get('Brand__c'));
                //string vpRecType = valueToLabelMap.get(string.valueOf(vp.get('Daily_Sale_Record_Type_Override__c')));
                String FBCoversActive = string.valueOf(vp.get('F_B_Covers_Active__c'));
                String CurrentSeasonBestsellersActive = string.valueOf(vp.get('Current_Season_Bestsellers_Active__c'));
                String SpecialCuratedSelectionActive = string.valueOf(vp.get('Special_Curated_Selection_Active__c'));
                String BrandRemoteSalesActive = string.valueOf(vp.get('Brand_Remote_Sales_Active__c'));
                String BrandPrivateAppointmentActive = string.valueOf(vp.get('Brand_Private_Appointment_Active__c'));
                string currencyCode = string.valueOf(vp.getSobject('Village__r').get('Currency__c'));
                string villageCode = string.valueOf(vp.getSobject('Village__r').get('Village_Code__c'));
                string villageId = string.valueOf(vp.getSobject('Village__r').get('Id'));
                string villageRecType = string.valueOf(vp.getSobject('Village__r').get('Default_Daily_Sales_Record_Type__c'));
                // Start LIS DEV Team @Hugo
                String PopUpBoutiqueActive = string.valueOf(vp.get('Pop_Up_Boutique_Active__c'));
                String BrandEventActive = string.valueOf(vp.get('Brand_Event_Active__c'));
                boolean certificationActive = Boolean.valueOf(string.valueOf(vp.get('CertSales_Active__c')));
                Id certificationId;
                if(certificationActive == true){
                    if(mapCertifications.get(vpId) != null){
                        certificationId = mapCertifications.get(vpId);
                    } else {
                        certificationId = CertificationProcessor.createCertification(vpId);
                    }
                }
                Id getCertification = certificationId;
                // End LIS DEV Team @Hugo
                
                Boolean isPopUpBoutiqueActive = False;
                IF(PopUpBoutiqueActive == 'True'){
                    isPopUpBoutiqueActive = True;
                }
                
                Boolean isBrandEventActive = False;
                 IF(BrandEventActive == 'True'){
                    isBrandEventActive = True;
                }
                
                Boolean FBCoversActiveFlag = FALSE;
                Boolean CurrentSeasonBestsellersActiveFlag = FALSE;
                Boolean SpecialCuratedSelectionActiveFlag = FALSE;
                Boolean BrandRemoteSalesActiveFlag = FALSE;
                Boolean BrandPrivateAppointmentActiveFlag = FALSE;
                System.debug('CurrentSeasonBestsellersActiveFlag: ' +  CurrentSeasonBestsellersActiveFlag);
                System.debug('SpecialCuratedSelectionActiveFlag: ' +  SpecialCuratedSelectionActiveFlag);
                if (FBCoversActive == 'true') {
                    FBCoversActiveFlag = TRUE;
                } if (CurrentSeasonBestsellersActive == 'true') {
                    CurrentSeasonBestsellersActiveFlag = TRUE;
                    System.debug('CurrentSeasonBestsellersActiveFlag: ' +  CurrentSeasonBestsellersActiveFlag);
                } if (SpecialCuratedSelectionActive == 'true') {
                    SpecialCuratedSelectionActiveFlag = TRUE;
                    System.debug('SpecialCuratedSelectionActiveFlag: ' +  SpecialCuratedSelectionActiveFlag);
                } if (BrandRemoteSalesActive == 'true') {
                    BrandRemoteSalesActiveFlag = TRUE;
                } if (BrandPrivateAppointmentActive == 'true') {
                    BrandPrivateAppointmentActiveFlag = TRUE;
                }


                /*string recType = '';
                if (string.isNotBlank(vpRecType)){
                    recType = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get(vpRecType).RecordTypeId;
                } else if (string.isnotBlank(villageRecType)){
                    recType = Schema.SObjectType.Daily_Sale__c.RecordTypeInfosByName.get(villageRecType).RecordTypeId;
                } else {
                    recType = defaultRecordTypeID;
                }
                
                if (string.isBlank(recType)){
                    recType = defaultRecordTypeID;
                }*/
                
                if(test.isRunningTest()){
                    brandId = 'SF_TEST';
                }
                // check if village closed
                if (!closedVillages.containsKey(villageId)){
                    list<date> villageClosedDates = villageClosedMap.get(villageId);
                    boolean villageClosed = false;
                    if (villageClosedDates != null){
                        for (Date dt :villageClosedDates){
                            if (dt == system.today()){
                                villageClosed = true;
                                closedVillages.put(villageId, villageId);
                                break;
                            }
                        }
                    }
                    
                    // Start LIS DEV Team @Hugo - added the Certification lookup on Daily Sales (getCertification)
                    // create Daily sale record if village not closed - set currency to be the same as defined on village record
                    if (!villageClosed){
                        dsList.add (new Daily_Sale__c(Trading_Date__c = system.today(), Store__c = vpId, 
                                                      F_B_Covers_Active__c = FBCoversActiveFlag, 
                                                      Is_Pop_Up_Boutique_Active__c = isPopUpBoutiqueActive  ,
                                                      Is_Brand_Event_Active__c = isBrandEventActive,
                                                      Current_Season_Bestsellers_Active__c = CurrentSeasonBestsellersActiveFlag,
                                                      Special_Curated_Selection_Active__c = SpecialCuratedSelectionActiveFlag,
                                                      Brand_Remote_Sales_Active__c = BrandRemoteSalesActiveFlag,
                                                      Brand_Private_Appointment_Active__c = BrandPrivateAppointmentActiveFlag,
                                                      RecordTypeId = defaultRecordTypeID, CurrencyIsoCode = currencyCode,
                                                      Certification_Batch__c = getCertification));
                    }
                    // End LIS DEV Team @Hugo
                }
            }
        }
        if (!dsList.isEmpty()){
            
            try{
                
                Database.SaveResult[] resultList = Database.insert(dsList, false);
                
                for (Database.SaveResult r : resultList){  // Examine DML errors
                    if (!r.isSuccess()){  
                        for (Database.Error e : r.getErrors()){  
                            // errors here
                            StatusCode status = e.getStatusCode();
                            string errMsg = e.getMessage();
                            
                            system.debug('ERROR creating Daily Sales Record .. ' + status + ' : ' + errMsg );
                            
                        }
                    }
                    
                }
                
            } catch (exception e){
                system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
            }
            
            
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
    
}