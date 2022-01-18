public class DailySalesCertificationBatchComplete {


    @InvocableMethod
    public static void changesAmounts(List <Daily_Sale__c> UpdatedDS){
        
        Id certId = UpdatedDS[0].Certification_Batch__c;        
        boolean complete = true;
        List<Daily_Sale__c> allDailySale = [SELECT Id, Certification_Batch__c, Status__c FROM Daily_Sale__c WHERE Certification_Batch__c = :certId];
                       
        for(Daily_Sale__c ds : allDailySale){
            if(ds.Status__c != 'Certified Complete'){
                complete = false;
                break;
            }            
        }
        
        if(complete){
       		List <Daily_Sales_Certification_Batch__c> certificationBatch = [SELECT Id, Status__c FROM Daily_Sales_Certification_Batch__c WHERE Id = :certId];
          	certificationBatch[0].Status__c = 'Batch Complete';
            try{
                update certificationBatch;
            } catch (Exception e){
                logFile__c log = new logFile__c();
                log.Body__c = 'Error on update a certification in DailySalesCertificationBatchComplete class. It is related with Certification Id: ' + certificationBatch[0].Id + '. With the following mesage: ' + e.getMessage();
                log.Type__c = 'Update a certification to be Batch Complete';
                insert log;
                system.debug('Exist an error on update a certification in DailySalesCertificationBatchComplete class. With the following mesage: ' + e.getMessage());
            }
        }
        
    }
}