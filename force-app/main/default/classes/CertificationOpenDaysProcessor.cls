global class CertificationOpenDaysProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        
        String query = 'SELECT Id, Village_Presence__c, Village_Presence__r.Village__c, Period_End_Date__c, Certification_Submission_Deadline__c';
        query += ' FROM Daily_Sales_Certification_Batch__c';
        query += ' WHERE Status__c = ' + '\'Generated\'';

        System.debug('@@@  query is .. ' +  query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Daily_Sales_Certification_Batch__c> scope) {
        Map<Id, Decimal> villageMapOpenDays = new Map<Id, Decimal>();
        Set<Id> vpToSendEmail = new Set<Id>();
        Map<Id, Decimal> villageMapCutOffDays = new Map<Id, Decimal>();
        Map<Id, Date> villageDeadlineDate = new Map<Id, Date>();

        //Gets Villages
        List<Village__c> getVillages = [SELECT Id, CertSales_CertPeriod_Cut_Off_Days__c, CertSales_CertPeriod_Open_Days__c
                                         FROM Village__c];
        
        for(Village__c village : getVillages){
            villageMapOpenDays.put(village.Id, village.CertSales_CertPeriod_Open_Days__c);
            villageMapCutOffDays.put(village.Id, village.CertSales_CertPeriod_Cut_Off_Days__c);
        }

        List<Daily_Sales_Certification_Batch__c> updatedDSCB = new List<Daily_Sales_Certification_Batch__c>();

        for (Daily_Sales_Certification_Batch__c oneDSCB : scope){
            Decimal openDays = villageMapOpenDays.get(oneDSCB.Village_Presence__r.Village__c);
            Decimal cutOffDays = villageMapCutOffDays.get(oneDSCB.Village_Presence__r.Village__c);

            // At the time 
            if(oneDSCB.Period_End_Date__c.addDays(Integer.valueof(openDays)) == system.today()-1){
                oneDSCB.Status__c = 'Open';
                updatedDSCB.add(oneDSCB);
                vpToSendEmail.add(oneDSCB.Village_Presence__c);
                villageDeadlineDate.put(oneDSCB.Village_Presence__r.Village__c, oneDSCB.Period_End_Date__c.addDays(Integer.valueof(cutOffDays)));
            }
        }

        if(!updatedDSCB.isEmpty()){
            
            try{
                update updatedDSCB;
            	SendEmailToCertify.SendEmailToCertify(vpToSendEmail, villageDeadlineDate);   
            }catch(Exception e) {
                logFile__c log = new logFile__c();
                log.Body__c = 'Error trying to update Daily Sales Certification Batch. Message ' + e.getMessage();
                log.Type__c = 'Certification Open Days Processor, Certification Batch update';
                insert log;
                system.debug('Error trying to update Daily Sales Certification Batch. Message ' + e.getMessage());
            }

            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}