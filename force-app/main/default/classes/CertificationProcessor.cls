public class CertificationProcessor{
    
    public static Id createCertification(String villagePresenceId){
        
        Village_Presence__c theVillagePresence = [SELECT Id, CertSales_CertPeriod_Type__c, Name, Village__r.Village_Code__c, Village__r.Currency__c
                                                  FROM Village_Presence__c
                                                  WHERE Id =: villagePresenceId];
        
        Date todayDate = system.today();
        Integer numberOfDays = Date.daysInMonth(todayDate.year(),todayDate.month());
        Date lastDayOfMonth = Date.newInstance(todayDate.year(), todayDate.month(), numberOfDays);

        Daily_Sales_Certification_Batch__c certification = new Daily_Sales_Certification_Batch__c();
        certification.Period_Start_Date__c = todayDate;
        certification.Certification_Batch_Village_Code__c = theVillagePresence.Village__r.Village_Code__c;
        certification.Status__c = 'Generated';
        certification.Village_Presence__c = theVillagePresence.Id;
        certification.CurrencyIsoCode = theVillagePresence.Village__r.Currency__c;

        if(theVillagePresence.CertSales_CertPeriod_Type__c == 'Monthly'){
            certification.Name = theVillagePresence.Name + ' - ' + todayDate.month() + '/' + todayDate.year();
            certification.Period_End_Date__c = lastDayOfMonth;
            certification.Period_Name__c = todayDate.month() + '/' + todayDate.year();
            certification.Certification_Period_Type__c = String.valueOf(theVillagePresence.CertSales_CertPeriod_Type__c);
            try{
                insert certification;
            } catch(Exception e){
                logFile__c log = new logFile__c();
                log.Body__c = 'Error on insert a new certification in CertificationProcessor class. It is related with VP Name: ' + theVillagePresence.Name + '. With the following mesage: ' + e.getMessage();
                log.Type__c = 'Insert of a new certification on the VP: ' + theVillagePresence.Name;
                insert log;
                system.debug('Exist an error on insert a new certification in CertificationProcessor class. with the following mesage: ' + e.getMessage());
            }
            return certification.Id;
        } else if (theVillagePresence.CertSales_CertPeriod_Type__c == 'Quarterly'){
            if(todayDate.month() == 1 || todayDate.month() == 2 || todayDate.month() == 3){
                certification.Name = theVillagePresence.Name + ' - Q1 - ' + todayDate.year();
                certification.Period_End_Date__c = Date.newInstance(todayDate.year(), 3, 31);
                certification.Period_Name__c = 'Q1 - ' + todayDate.year();
                certification.Certification_Period_Type__c = String.valueOf(theVillagePresence.CertSales_CertPeriod_Type__c);
                try{
                    insert certification;
                } catch(Exception e){
                    logFile__c log = new logFile__c();
                    log.Body__c = 'Error on insert a new certification in CertificationProcessor class. It is related with VP Name: ' + theVillagePresence.Name + '. With the following mesage: ' + e.getMessage();
                    log.Type__c = 'Insert of a new certification on the VP: ' + theVillagePresence.Name;
                    insert log;
                    system.debug('Exist an error on insert a new certification in CertificationProcessor class. with the following mesage: ' + e.getMessage());
                }
                return certification.Id;
            } else if (todayDate.month() == 4 || todayDate.month() == 5 || todayDate.month() == 6){
                certification.Name = theVillagePresence.Name + ' - Q2 - ' + todayDate.year();
                certification.Period_End_Date__c = Date.newInstance(todayDate.year(), 6, 30);
                certification.Period_Name__c = 'Q2 - ' + todayDate.year();
                certification.Certification_Period_Type__c = String.valueOf(theVillagePresence.CertSales_CertPeriod_Type__c);
                try{
                    insert certification;
                } catch(Exception e){
                    logFile__c log = new logFile__c();
                    log.Body__c = 'Error on insert a new certification in CertificationProcessor class. It is related with VP Name: ' + theVillagePresence.Name + '. With the following mesage: ' + e.getMessage();
                    log.Type__c = 'Insert of a new certification on the VP: ' + theVillagePresence.Name;
                    insert log;
                    system.debug('Exist an error on insert a new certification in CertificationProcessor class. with the following mesage: ' + e.getMessage());
                }
                return certification.Id;
            } else if(todayDate.month() == 7 || todayDate.month() == 8 || todayDate.month() == 9){
                certification.Name = theVillagePresence.Name + ' - Q3 - ' + todayDate.year();
                certification.Period_End_Date__c = Date.newInstance(todayDate.year(), 9, 30);
                certification.Period_Name__c = 'Q3 - ' + todayDate.year();
                certification.Certification_Period_Type__c = String.valueOf(theVillagePresence.CertSales_CertPeriod_Type__c);
                try{
                    insert certification;
                } catch(Exception e){
                    logFile__c log = new logFile__c();
                    log.Body__c = 'Error on insert a new certification in CertificationProcessor class. It is related with VP Name: ' + theVillagePresence.Name + '. With the following mesage: ' + e.getMessage();
                    log.Type__c = 'Insert of a new certification on the VP: ' + theVillagePresence.Name;
                    insert log;
                    system.debug('Exist an error on insert a new certification in CertificationProcessor class. with the following mesage: ' + e.getMessage());
                }
                return certification.Id;
            } else if(todayDate.month() == 10 || todayDate.month() == 11 || todayDate.month() == 12){
                certification.Name = theVillagePresence.Name + ' - Q4 - ' + todayDate.year();
                certification.Period_End_Date__c = Date.newInstance(todayDate.year(), 12, 31);
                certification.Period_Name__c  = 'Q4 - ' + todayDate.year();
                certification.Certification_Period_Type__c = String.valueOf(theVillagePresence.CertSales_CertPeriod_Type__c);
                try{
                    insert certification;
                } catch(Exception e){
                    logFile__c log = new logFile__c();
                    log.Body__c = 'Error on insert a new certification in CertificationProcessor class. It is related with VP Name: ' + theVillagePresence.Name + '. With the following mesage: ' + e.getMessage();
                    log.Type__c = 'Insert of a new certification on the VP: ' + theVillagePresence.Name;
                    insert log;
                    system.debug('Exist an error on insert a new certification in CertificationProcessor class. with the following mesage: ' + e.getMessage());
                }
                return certification.Id;
            }
        }
        return null;
    }
}