public with sharing class CreateHFSItemController {

    private string vpId ='';
    
    public HFS_Item__c hfsItem {
        get {
            if (hfsItem == null)
                hfsItem = new HFS_Item__c();
              return hfsItem;
        }
        set;
    }

    public CreateHFSItemController () {
        vpId = ApexPages.currentPage().getParameters().get('brandid');
    }

  
    public PageReference save() {

        try {
            if(String.isnotBlank(vpId)){
                hfsItem.Brand__c = vpId;
                insert hfsItem; 
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new HFS Item. Invalid Brand Id'));
                return null;
            }
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new HFS Item.'));
            return null;
        }
    
        // if successfully inserted new contact, then displays the thank you page.
        return Page.CreateHFSItem_Thankyou;


    }


    public PageReference addAnother() {
        hfsItem = new HFS_Item__c();
        return Page.CreateHFSItem;

    }

}