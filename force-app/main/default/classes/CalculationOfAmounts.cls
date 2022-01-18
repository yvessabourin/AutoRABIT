public class CalculationOfAmounts {

    @InvocableMethod
    public static void changesAmounts(List<Daily_Sale__c> allUpdatedDS){
        Set<Id> dsId = new Set<Id>();
        for(Daily_Sale__c ds : allUpdatedDS){
            if(ds.Certification_Batch__c != null){
                dsId.add(ds.Certification_Batch__c);
            }
        }
        
        if(!dsId.isEmpty()){
        	List<Daily_Sale__c> allDailySale = [SELECT Id, Certification_Batch__c, Brand_Reported_Amount__c, Certified_Amount__c, Certified_Amount_NetTotal__c, Certified_Amount_Discount__c FROM Daily_Sale__c WHERE Certification_Batch__c = :dsId];
            List<Daily_Sales_Certification_Batch__c> allCertification = [SELECT Id, Total_Brand_Reported_Amount__c, Total_Certified_Amount__c, Total_Certified_Net_Sales_Amount__c, Total_Certified_Discount_Amount__c FROM Daily_Sales_Certification_Batch__c WHERE Id = :dsId];
            List<Daily_Sales_Certification_Batch__c> updatedCertification = new List<Daily_Sales_Certification_Batch__c>();
            
            for(Daily_Sales_Certification_Batch__c cert : allCertification){
                cert.Total_Brand_Reported_Amount__c = 0;
                cert.Total_Certified_Amount__c = 0;
                cert.Total_Certified_Net_Sales_Amount__c = 0;
                cert.Total_Certified_Discount_Amount__c = 0;
                for(Daily_Sale__c ds : allDailySale){
                    if(cert.Id == ds.Certification_Batch__c){
                        
                        if(ds.Brand_Reported_Amount__c != null){
                            cert.Total_Brand_Reported_Amount__c = cert.Total_Brand_Reported_Amount__c + ds.Brand_Reported_Amount__c;
                        } else {
                            cert.Total_Brand_Reported_Amount__c = cert.Total_Brand_Reported_Amount__c + 0;
                        }
                        
                        if(ds.Certified_Amount__c != null){
                            cert.Total_Certified_Amount__c = cert.Total_Certified_Amount__c + ds.Certified_Amount__c;
                        } else {
                            cert.Total_Certified_Amount__c = cert.Total_Certified_Amount__c + 0;
                        }
						
						cert.Total_Certified_Net_Sales_Amount__c = cert.Total_Certified_Net_Sales_Amount__c + ds.Certified_Amount_NetTotal__c;
                        cert.Total_Certified_Discount_Amount__c = cert.Total_Certified_Discount_Amount__c + ds.Certified_Amount_Discount__c;
                    }
                }
                updatedCertification.add(cert);
            }
            try{
                update updatedCertification;
            } catch (Exception e){
                logFile__c log = new logFile__c();
                log.Body__c = 'Error on update certification in CalculationOfAmounts class. The update list: ' + updatedCertification + '. With the following mesage: ' + e.getMessage();
                log.Type__c = 'Calculation of Amounts of the certification';
                insert log;
                system.debug('Exist an error on update of CalculationOfAmounts class with the following mesage: ' + e.getMessage());
            }
        }
    }
}