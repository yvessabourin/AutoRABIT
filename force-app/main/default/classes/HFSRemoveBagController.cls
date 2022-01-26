public with sharing class HFSRemoveBagController {
    
    public ID purchaseId {get;set;}
    public List<Case_Item__c> allJobBags { get; set; }
    public String idName {get;set;}
    public String guestId {get;set;}
    public HFS_Bag__c aBag { get; set; }
    
    public List<SelectOption> categories {get;set;}
    public String selectedBag{get;set;}
    
    
    public HFSRemoveBagController(ApexPages.StandardSetController stdController){
        this.aBag = (HFS_Bag__c)stdController.getRecord();
        purchaseId = ApexPages.CurrentPage().getParameters().get('Id'); 
        getPurchase(purchaseId); 
        getBags();
        
    }
    
    public void getPurchase(Id pId){
        allJobBags = [SELECT Name, Service_Guest_Number__c FROM Case_Item__c WHERE Id= :pId];
        idName = allJobBags[0].Name;
        guestId = allJobBags[0].Service_Guest_Number__c;
        
    }
    
    
    public void getBags(){    	
        
        List <HFS_Bag__c>  bags= [SELECT Barcode__c,HFS_Bag_Active__c,HFS_Purchase__c FROM HFS_Bag__c WHERE HFS_Purchase__r.Name= :idName AND HFS_Bag_Active__c = true];
        
        categories = new List<SelectOption>();
        categories.add(new SelectOption('', '--None--'));
        
        for(HFS_Bag__c c :bags){
            categories.add(new SelectOption(c.Barcode__c, c.Barcode__c));
        }
        
    }
    
    
    public PageReference RemoveBag(){
        
        System.debug(' Mala ' + selectedBag);
        
        try{
            
            HFS_Bag__c  bag =  [SELECT Barcode__c,HFS_Bag_Active__c,HFS_Purchase__c FROM HFS_Bag__c WHERE HFS_Purchase__c= :purchaseId AND Barcode__c= :selectedBag AND HFS_Bag_Active__c = true];
            
            bag.HFS_Bag_Active__c = false;
            bag.HFS_Remove_Reason__c = aBag.HFS_Remove_Reason__c;
            update bag;
            
            System.debug(' Mala ' + selectedBag);
            PageReference purchasePage = new PageReference('/' + purchaseId);
            return purchasePage;
            
            
        }
        catch(Exception ex){
            Apexpages.Message informNotProceed = new Apexpages.Message(Apexpages.Severity.Error, 'Not able to remove, duplicated barcode');
            ApexPages.addMessage(informNotProceed);
            return null;
        }
        
        
    }
    
    
    
    public PageReference cancel(){
        PageReference purchasePage = new PageReference('/' + purchaseId);    
        return purchasePage;
    }
    
    
}