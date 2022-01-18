Public Class reAssignMarketingActivities{

    public id recordId {get;set;}
    public list<Marketing_Activity__c> MAs {get;set;}
    public list<Wrapper> wMAstoEdit {get;set;}
    public Marketing_Activity__c selectOption {get;set;}
    public Integer errorcount {get;set;}
    public string errormessage {get;set;}
    public boolean showRemovedColumn {get;set;}


    Public reAssignMarketingActivities(ApexPages.StandardController standardController){
    }


    Public reAssignMarketingActivities(ApexPages.StandardSetController stdcontroller){
    showRemovedColumn = false;
    selectOption = new Marketing_Activity__c();
    wMAstoEdit = new list<Wrapper>();
    errorcount = 0;
    errormessage = '';
    recordId = ApexPages.currentPage().getParameters().get('theid');
    system.debug('recordId' + recordId);
    MAs = [SELECT ID, Name, Status__c, marketing_campaign__c,Budget__c, 
              Reason_for_Removal_or_Cancellation__c ,CurrencyIsoCode, Start_Date__c,
              End_Date__c, Transfer_To_Oracle__c, Re_send_to_Oracle_for_NewActivity__c
           FROM 
              Marketing_Activity__c 
           WHERE 
              marketing_campaign__c =:recordId ];
    system.debug('MAs' + MAs);
    
    for(Marketing_Activity__c MA : MAs){
            wMAstoEdit.add(new Wrapper(MA));
    }
    system.debug('wMAstoEdit' + wMAstoEdit);
    }


    Public Pagereference selectAll() {
        for(Wrapper wrapper : wMAstoEdit){
            wrapper.selected = true;
        }
        return null;
    }

    Public Pagereference deselectAll() {
      for(Wrapper wrapper : wMAstoEdit){
            wrapper.selected = false;
        }
        return null;
    }



    Public Pagereference saveSelected() {

        try{
        list<Marketing_Activity__c> Updates = new List<Marketing_Activity__c>();
            for(Wrapper wrapper : wMAstoEdit) {
                    if(wrapper.selected == true) {
                        Updates.add(wrapper.theMA); 
                    }
            }    

            if(Updates == NULL || Updates.size() == 0){
                errormessage = 'Please select some records to update or use \"Cancel\" to exit!';
            }
            else{ 
                update Updates;        
                PageReference pageRef = new PageReference('/'+recordId);
                return pageRef;
            }
        }

        catch (exception e){
            errorcount ++ ;
            system.debug('this error message : ' + e.getMessage());
            system.debug('this error type : ' + e.getTypeName());
            system.debug('this error cause : ' + e.getCause());
            if (e.getmessage().contains('This record cannot be closed as there are open related records')){
        
                errormessage = e.getmessage().replaceAll('Update failed. First exception on row 0 with id', '');   
                errormessage = errormessage.stripHtmlTags();

                string maID = errormessage.left(18).trim();
                system.debug('maID : ' + maID);
                Marketing_Activity__c MA1 = [SELECT ID, Name from Marketing_Activity__c WHERE ID = : maID];
                errormessage = errormessage.replaceAll(maID,'');
                errormessage = errormessage.left(errormessage.length()-4);
                errormessage = 'Error on Marketing Activity: \'' + MA1.name + '\':' + ' This record cannot be closed as there are open related records';
     
            }
            else if(e.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errormessage = 'please correct the below errors'; 
            }
            else {
                errormessage = 'An Error has occurred, please contact your System Administrator'; 
            }
            return null;        
        }
        return null;
    }



    Public Pagereference Cancel() {
    PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }

    Public Pagereference setAllStatus() {
        for(Wrapper wrapper : wMAstoEdit){
            wrapper.theMA.Status__c = selectOption.Status__c;          
        }
        return null;
    }
    
    public void checkIfCancelledorRemoved(list<Wrapper> wraps){
    integer i = 0;
        for(Wrapper wrap : wraps){
            //if(wrap.theMA.Status__c == 'Cancelled' || wrap.theMA.Status__c == 'Removed'){
              if(wrap.theMA.Status__c == 'Cancelled'){
                    i ++ ;
            }
           
        }
        if(i > 0){
            showRemovedColumn = true;
        }
        else{
            showRemovedColumn = false;
        }
    }


    public class Wrapper{
        public Marketing_Activity__c theMA {get; set;}
        public Boolean selected {get; set;}

        public Wrapper(Marketing_Activity__c ma) {
            theMA = ma;
            selected = false;
        }

        public Wrapper(Marketing_Activity__c ma, boolean bool) {
            theMA = ma;
            selected = bool;

        }
    }
    
   
    public class reassignmentException extends Exception {}
}