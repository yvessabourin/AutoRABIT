public with sharing class massCloneInVillageBrandActivities{

    ApexPages.StandardSetController setCon;
    Public List<In_Village_Brand_Activity__c> brandActs {get;set;}
    public string errorMessage {get;set;}
    public map<In_Village_Brand_Activity__c,In_Village_Brand_Activity__c> BAMap {get;set;}
    public string returl {get;set;}

    // system.debug('AutoRABIT test1');
    
    public massCloneInVillageBrandActivities(ApexPages.StandardSetController controller) {
        setCon = controller;
        brandActs = [SELECT Id,Name,Brand_Activity__c,End_Date__c,Marketing_Activity__c,Marketing_Activity_Budget__c,Marketing_Activity_Cost__c,Start_Date__c,Status__c,Village_Presence__c FROM In_Village_Brand_Activity__c WHERE Id IN : (In_Village_Brand_Activity__c[])controller.getSelected()];
        BAMap = new map<In_Village_Brand_Activity__c,In_Village_Brand_Activity__c>();
        returl = ApexPages.currentPage().getParameters().get('id');
    }

    public void cloneInVillageBrandActs(){

        if(brandActs.size() > 5){   
            errorMessage = 'You cannot clone more than 5 records at once';
        }
        else if(brandActs.size() > 0){
        List<In_Village_Brand_Activity__c> newBAs = new List<In_Village_Brand_Activity__c>();
        for (In_Village_Brand_Activity__c ba : brandActs){
            In_Village_Brand_Activity__c baclone = ba.clone();
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
        return pageRef ;
    }

}