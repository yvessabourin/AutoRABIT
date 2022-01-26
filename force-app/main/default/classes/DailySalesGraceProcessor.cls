global class DailySalesGraceProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        Datetime dt = System.now();
        string theDay = dt.format('EEEE');
        System.debug('@@@  the day is .. ' +  dt.format('EEEE'));
        
        string query = 'SELECT Id, Status__c, Grace_Period_Days_Applied__c,Grace_Period_Expired_On_Date__c, Certification_Batch__c';
        query += ' FROM Daily_Sale__c';
        query += ' WHERE (Status__c = ' + '\'Created\'';
        query += ' OR Status__c = '+ '\'Reported Incomplete\'';
        query += ' OR Status__c = '+'\'Reported Confirmed\')';
        query += ' AND Grace_Period_Expired_On_Date__c = NULL';
        query += ' AND (Trading_Date__c = LAST_N_DAYS:100 OR Trading_Date__c = TODAY)';
        System.debug('@@@  query is .. ' +  query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Daily_Sale__c> scope)
    {
        List<Daily_Sale__c> allUpdatedDS = new List<Daily_Sale__c>();
        Set <Daily_Sales_Certification_Batch__c> allUpdatedDSCB = new Set<Daily_Sales_Certification_Batch__c>();

        Map <Id, Decimal> villageMapGracePeriod = new Map <Id,Decimal>();
        Map <Id, Decimal> villageMapOpenDays = new Map <Id, Decimal>();
        
        //Gets Villages
        List <Village__c> getVillages = [SELECT Id, CertSales_Report_Sales_Grace_Period_Days__c, CertSales_CertPeriod_Open_Days__c
                             			 FROM Village__c];
        
        for(Village__c village : getVillages){
            villageMapGracePeriod.put(village.Id, village.CertSales_Report_Sales_Grace_Period_Days__c);
            villageMapOpenDays.put(village.Id, village.CertSales_CertPeriod_Open_Days__c);
        }

        //Gets DSCB
        List <Daily_Sales_Certification_Batch__c> getDSCB = [SELECT Id, Village_Presence__r.Village__c, BP_Validation_Context_Override__c,Period_End_Date__c
                                                 			 FROM Daily_Sales_Certification_Batch__c
                                                             WHERE Status__c != 'Batch Complete'
                                                			 OR Status__c != 'Approved'];
        
        for(Daily_Sale__c ds : scope){
            for(Daily_Sales_Certification_Batch__c dscb : getDSCB){
                if(ds.Certification_Batch__c == dscb.Id){
               		Decimal gracePeriod = villageMapGracePeriod.get(dscb.Village_Presence__r.Village__c); 
                    
                    if(dscb.Period_End_Date__c.addDays(Integer.valueOf(gracePeriod)) == (system.today() -1)){
                  	  dscb.BP_Validation_Context_Override__c = true;
                  	  allUpdatedDSCB.add(dscb);
                        
                      ds.Grace_Period_Expired_On_Date__c = (system.today()-1);
                      ds.Grace_Period_Days_Applied__c = gracePeriod;
                      allUpdatedDS.add(ds);
                	}
                }
     	    }
        }
        
        List <Daily_Sales_Certification_Batch__c> allUpdatedDSCBList = new List<Daily_Sales_Certification_Batch__c>(allUpdatedDSCB);
        
        try{
        	update allUpdatedDSCBList;
        }catch(Exception e){
        	system.debug('Error: ' + e);
            throw new AuraHandledException ('Error on Update DSCB set false');
        }
        
        try{
        	update allUpdatedDS;
        }catch(Exception e){
        	system.debug('Error: ' + e);
            throw new AuraHandledException ('Error on Update DS');
        }        

		for(Daily_Sales_Certification_Batch__c dscbUpdate : allUpdatedDSCBList){
            dscbUpdate.BP_Validation_Context_Override__c = false;
        }
        
        try{
        	update allUpdatedDSCBList;         
        }catch(Exception e){
        	system.debug('Error: ' + e);
            throw new AuraHandledException ('Error on Update DSCB set true');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}