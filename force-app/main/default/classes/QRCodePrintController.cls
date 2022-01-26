public without sharing class QRCodePrintController {
    public String cmid {get; private set;}
    public String objId {get; private set;}
    public String redirectUrl {get; private set;}
    public Boolean noBarcodeNumber { get; private set; }
    
    public QRCodePrintController(){
        cmid = ApexPages.currentPage().getParameters().get('cmid');
        objId = ApexPages.currentPage().getParameters().get('id');
        
        noBarcodeNumber = false;
        
        if(cmid == null){ 
            noBarcodeNumber = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This Customer has no barcode'));
            return;
        } 
        
        String objectType = ((Id)objId).getSObjectType().getDescribe().getName();
        if(objectType == 'Account'){
            Account acc = [SELECT Id, BarcodeNumber__c FROM Account WHERE Id = :objId];
            if(String.isBlank(acc.BarcodeNumber__c)){
                noBarcodeNumber = true;
            }
        }
        else if (objectType == 'b2c_customer__c'){
            b2c_customer__c b2cCust = [SELECT Id, currentMotherCode__c FROM b2c_customer__c WHERE Id = :objId];
            if(String.isBlank(b2cCust.currentMotherCode__c)){
                noBarcodeNumber = true;
            }
        }
        
        if(noBarcodeNumber){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This Customer has no barcode'));
        }
        
    }
    
    public PageReference redirectToRecord(){
        PageReference pg = new PageReference('/' + objId);
        pg.setRedirect(true);
        return pg;  
    }
}