Public Class massEditBrandActivitiesController{

    public id recordId {get;set;}
    public list<Brand_Activity__c> BAs {get;set;}
    public list<Wrapper> wBAstoEdit {get;set;}
    public Brand_Activity__c selectOption {get;set;}
    public String selectedStatus {get;set;}
    public String objName {get;set;}


    Public massEditBrandActivitiesController(ApexPages.StandardController standardController){
    }


    Public massEditBrandActivitiesController(ApexPages.StandardSetController stdcontroller){

        selectedStatus = '';
        recordId = ApexPages.currentPage().getParameters().get('id');
        objName = recordId.getSObjectType().getDescribe().getName();

        selectOption = new Brand_Activity__c();
        wBAstoEdit = new list<Wrapper>();

        if(objName == 'Marketing_Campaign__c'){
            BAs = [SELECT ID, Name, Status__c, Brand__c,CurrencyIsoCode,Expected_Average_Spend__c,Expected_Sales__c,Marketing_Activity_Cost__c,Expected_New_Members__c,Reach__c,Expected_Footfall__c,Marketing_Activity_Budget__c,Marketing_Campaign__c,Brand_Activity_Type__c,Approved_Villages__c,Details__c  FROM Brand_Activity__c WHERE Marketing_Campaign__c =:recordId ];
        }
        else if (objName == 'Account'){
            BAs = [SELECT ID, Name, Status__c, Brand__c,CurrencyIsoCode,Expected_Average_Spend__c,Expected_Sales__c,Marketing_Activity_Cost__c,Expected_New_Members__c,Reach__c,Expected_Footfall__c,Marketing_Activity_Budget__c,Marketing_Campaign__c,Brand_Activity_Type__c,Approved_Villages__c,Details__c  FROM Brand_Activity__c WHERE Brand__c =:recordId ];
        }


        for(Brand_Activity__c BA : BAs){
            wBAstoEdit.add(new Wrapper(BA));
        }
        system.debug('wBAstoEdit' + wBAstoEdit);

    }


    Public Pagereference selectAll() {
        for(Wrapper wrapper : wBAstoEdit){
            wrapper.selected = true;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }


    Public Pagereference deselectAll() {
      for(Wrapper wrapper : wBAstoEdit){
            wrapper.selected = false;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }


    Public Pagereference saveSelected() {

      try{
        list<Brand_Activity__c> Updates = new List<Brand_Activity__c>();
            for(Wrapper wrapper : wBAstoEdit) {
                    if(wrapper.selected == true) {
                        Updates.add(wrapper.theBA); 
                    }
            }        
        update Updates;        
        PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;}
        catch (exception e){
          return null;
        }
    }


    Public Pagereference Cancel() {
    PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }


    Public Pagereference setAllStatus() {
        for(Wrapper wrapper : wBAstoEdit){
            wrapper.theBA.Status__c = selectOption.Status__c;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }


    Public Pagereference setAllStatus2() {
        for(Wrapper wrapper : wBAstoEdit){
            wrapper.theBA.Status__c = selectedStatus;
        }
     
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }



    public class Wrapper{
        public Brand_Activity__c theBA {get; set;}
        public Boolean selected {get; set;}

        public Wrapper(Brand_Activity__c ba) {
            theBA = ba;
            selected = false;
        }

        public Wrapper(Brand_Activity__c ba, boolean bool) {
            theBA = ba;
            selected = bool;

        }
    }


    public class reassignmentException extends Exception {}

    
}