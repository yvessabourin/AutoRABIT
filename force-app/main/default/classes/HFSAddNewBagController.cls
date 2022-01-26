public with sharing class HFSAddNewBagController {
    
    public ID purchaseId { get; set; }
    public Case_Item__c thePurchase { get; set; }
    public String idName { get; set; }
    public String guestId { get; set; }
    public HFS_Bag__c aBag { get; set; }
    
    public HFSAddNewBagController(ApexPages.StandardSetController stdController){
      this.aBag = (HFS_Bag__c)stdController.getRecord();
      purchaseId = ApexPages.CurrentPage().getParameters().get('Id'); 
      getPurchase(purchaseId); 
    }
    
    public void getPurchase(Id pId){
        thePurchase = [SELECT Name, Service_Guest_Number__c FROM Case_Item__c WHERE Id = :pId];
        idName = thePurchase.Name;
        guestId = thePurchase.Service_Guest_Number__c;
    }
    
    public PageReference saveNewBag(){
        //Tests if bag Bar code already exists on the same purchase
        List<HFS_Bag__c> bags= [SELECT Barcode__c, HFS_Purchase__c FROM HFS_Bag__c WHERE Barcode__c = :aBag.Barcode__c];

        if(bags.isEmpty()){
            try{
                HFS_Bag__c bag = new HFS_Bag__c();
                bag.HFS_Purchase__c = purchaseId;
                bag.HFS_Add_Reason__c = aBag.HFS_Add_Reason__c;
                bag.Barcode__c = aBag.Barcode__c;
                bag.Oversized__c = aBag.Oversized__c;
                
                insert bag;
                PageReference purchasePage = new PageReference('/' + purchaseId);
                return purchasePage;
            }
            catch(Exception ex){
                return null;
                // System.debug(' guardar mala ' + aBag.HFS_Add_Reason__c + ' ' + aBag.Oversized__c + ' ' + aBag.Barcode__c);
            }

        }else{
            Apexpages.Message informNotProceed = new Apexpages.Message(Apexpages.Severity.Error, 'This Barcode is already in use');
            ApexPages.addMessage(informNotProceed);
            return null;
        }
    }

    public PageReference cancel(){
      PageReference purchasePage = new PageReference('/' + purchaseId);
      return purchasePage;
    }
}