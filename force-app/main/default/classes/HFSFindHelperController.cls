public with sharing class HFSFindHelperController{

    public String storageLocationQR { get; set; }
    public String bagBarcode { get; set; }
    public String bagId { get; set; }
    public String qrCodeStorageLocation { get; set; }
    public String purchaseCode { get ; set; }

    public PageReference autoRun(){
        storageLocationQR = ApexPages.CurrentPage().getParameters().get('qrCodeLocation');
        bagBarcode = ApexPages.CurrentPage().getParameters().get('bagBarcode');
        bagId = ApexPages.CurrentPage().getParameters().get('bagId');
        qrCodeStorageLocation = ApexPages.CurrentPage().getParameters().get('qrCodeStorageLocation');
        system.debug(bagBarcode);
        PageReference goToRecord = null;

        // REASSIGN A NEW STORAGE LOCATION TO EACH BAG
        if(qrCodeStorageLocation != null && bagId != null){

            List<HFS_Storage_Location__c> theStorage = [SELECT Id FROM HFS_Storage_Location__c WHERE QR_Code_hidden__c = :qrCodeStorageLocation LIMIT 1];
            List<HFS_Bag__c> theBag = [SELECT Id, HFS_Storage_Location__c FROM HFS_Bag__c WHERE ID =: bagId];
            if (!theBag.isEmpty() && !theStorage.isEmpty()) {
                theBag.get(0).HFS_Storage_Location__c = theStorage.get(0).Id;
                update theBag.get(0);

                goToRecord = new PageReference('/' + theBag.get(0).Id);
            }
            system.debug(goToRecord);
        }

        // IT IS FOR STORAGE LOCATION FIND
        System.debug('storageLocationQR ' + storageLocationQR);
        if(storageLocationQR != null){
            List<HFS_Storage_Location__c> theStorage = [SELECT Id FROM HFS_Storage_Location__c WHERE QR_Code_hidden__c = :storageLocationQR];
            if (!theStorage.isEmpty()) {
                goToRecord = new PageReference ('/' + theStorage.get(0).Id);
            }
        }

        // IT IS FOR BAG FIND
        if(bagBarcode != null){
            List<HFS_Bag__c> theBag = [SELECT Id FROM HFS_Bag__c WHERE Barcode__c = :bagBarcode AND HFS_Bag_Active__c = true];
            if (!theBag.isEmpty()) {
                goToRecord = new PageReference ('/' + theBag.get(0).Id);
            }
        }

        // IT IS FOR PURCHASE FIND
        if(purchaseCode != null){
            List<Case_Item__c> thePurchase = [SELECT Id FROM Case_Item__c WHERE Name = :purchaseCode];
            if (!thePurchase.isEmpty()) {
                goToRecord = new PageReference ('/' + thePurchase.get(0).Id);
            }
        }

        return goToRecord;
    }
}