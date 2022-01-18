public with sharing class massCloneBrandActivities{

    ApexPages.StandardSetController setCon;
    Public List<Brand_Activity__c> brandActs {get;set;}
    public string errorMessage {get;set;}
    public map<Brand_Activity__c,Brand_Activity__c> BAMap {get;set;}
    public string returl {get;set;}

    public massCloneBrandActivities(ApexPages.StandardSetController controller) {
        setCon = controller;
        brandActs = [SELECT Id,Name,Brand__c,Marketing_Campaign__c,Brand_Activity_Type__c,Approved_Villages__c,Details__c,Start_Date__c,End_Date__c,Asset_Links__c,Status__c,Brand_Activity_Owner__c FROM Brand_Activity__c WHERE Id IN : (Brand_Activity__c[])controller.getSelected()];
        BAMap = new map<Brand_Activity__c,Brand_Activity__c>();
        returl = ApexPages.currentPage().getParameters().get('id'); //ApexPages.currentPage().getParameters().get('retURL');
        system.debug('returl' + returl);
        system.debug(ApexPages.currentPage().getParameters());
    }

    public void cloneBrandActs(){

        if(brandActs.size() > 5){   
            errorMessage = 'You cannot clone more than 5 records at once';
        }
        else if(brandActs.size() > 0){
        List<Brand_Activity__c> newBAs = new List<Brand_Activity__c>();
        for (Brand_Activity__c ba : brandActs){
            Brand_Activity__c baclone = ba.clone();
            baclone.name = '[CLONE] - ' + baclone.name;
            baclone.id = null;
            newBAs.add(baclone);
            BAMap.put(ba,baclone);
        }
        try{
            insert newBAs;
        }
        Catch (exception e){
            system.debug('Error @@@@@ :' + e);
            errorMessage = 'Error @@@@@ :' + e;
        }
        
        }
    }

    public pagereference returntoOrigin(){
        PageReference pageRef = new PageReference('/' + returl);
        pageRef.setRedirect(true);
        return pageRef;
    }


}