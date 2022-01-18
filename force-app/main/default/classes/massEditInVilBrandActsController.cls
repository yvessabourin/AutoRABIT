Public Class massEditInVilBrandActsController{

    public id recordId {get;set;}
    public list<In_Village_Brand_Activity__c> inVilBAs {get;set;}
    public list<Wrapper> wBAstoEdit {get;set;}
    public In_Village_Brand_Activity__c selectOption {get;set;}
    //public list<SelectOption> options {get;set;}
    public String selectedStatus {get;set;}
    public String objName {get;set;}


    Public massEditInVilBrandActsController(ApexPages.StandardController standardController){
    }


    Public massEditInVilBrandActsController(ApexPages.StandardSetController stdcontroller){

    selectedStatus = '';
    selectOption = new In_Village_Brand_Activity__c();
    wBAstoEdit = new list<Wrapper>();
    recordId = ApexPages.currentPage().getParameters().get('id');
    objName = recordId.getSObjectType().getDescribe().getName();

    if(objName == 'Brand_Activity__c'){
       inVilBAs = [SELECT ID, Name, Status__c,Marketing_Activity_Budget__c,Expected_Footfall__c,Reach__c,Expected_New_Members__c,Marketing_Activity_Cost__c,Expected_Sales__c,Expected_Average_Spend__c,Split_Type__c FROM In_Village_Brand_Activity__c WHERE Brand_Activity__c =:recordId ]; 
    }
    else if (objName == 'Marketing_Activity__c'){
        inVilBAs = [SELECT ID, Name, Status__c,Marketing_Activity_Budget__c,Expected_Footfall__c,Reach__c,Expected_New_Members__c,Marketing_Activity_Cost__c,Expected_Sales__c,Expected_Average_Spend__c,Split_Type__c FROM In_Village_Brand_Activity__c WHERE Marketing_Activity__c =:recordId ]; 
    }
    system.debug('BAs' + inVIlBAs);

      for(In_Village_Brand_Activity__c BA : inVilBAs){
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
        list<In_Village_Brand_Activity__c> Updates = new List<In_Village_Brand_Activity__c>();
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
        public In_Village_Brand_Activity__c theBA {get; set;}
        public Boolean selected {get; set;}

        public Wrapper(In_Village_Brand_Activity__c ba) {
            theBA = ba;
            selected = false;
        }

        public Wrapper(In_Village_Brand_Activity__c ba, boolean bool) {
            theBA = ba;
            selected = bool;

        }
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('US','US'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO','Mexico'));
        return options;
    }

    public class reassignmentException extends Exception {}
}