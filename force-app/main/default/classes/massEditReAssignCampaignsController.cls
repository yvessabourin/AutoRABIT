Public Class massEditReAssignCampaignsController{

    public id recordId {get;set;}
    public list<Marketing_Campaign__c> MCs {get;set;}
    public list<Wrapper> wMCstoEdit {get;set;}
    public Marketing_Campaign__c selectOption {get;set;}
    public Integer errorcount {get;set;}
    public string errormessage {get;set;}

    
    Public massEditReAssignCampaignsController(ApexPages.StandardSetController stdsetcontroller){
        
        selectOption = new Marketing_Campaign__c();
        wMCstoEdit = new list<Wrapper>();
        errorcount = 0;
        errormessage = '';
        recordId = ApexPages.currentPage().getParameters().get('theid');
        system.debug('recordId' + recordId);
        MCs = [SELECT ID, Name,CurrencyIsoCode,Campaign_Marketing_Budget__c,Campaign_Level__c,
               Campaign_Focus__c, Parent_Marketing_Campaign__c,Status__c,RecordTypeid, Start_Date__c,
               End_Date__c, Transfer_To_Oracle__c, Re_send_to_Oracle__c
            FROM
               marketing_campaign__c 
            WHERE 
                Parent_Marketing_Campaign__c =:recordId ];
        system.debug('MCs' + MCs);

            for(Marketing_Campaign__c MC : MCs){
                wMCstoEdit.add(new Wrapper(MC));
            }

    }


    Public Pagereference saveSelected() {

        try{
        list<Marketing_Campaign__c> Updates = new List<Marketing_Campaign__c>();
            for(Wrapper wrapper : wMCstoEdit) {
                    if(wrapper.selected == true) {
                        Updates.add(wrapper.theMC); 
                    }
            }   
        system.debug('updates :' + updates);     
        update Updates;        
        PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
        }

        catch (exception e){
            errorcount ++ ;
            system.debug('error mercc : ' + e);
            if (e.getmessage().contains('You cannot set the Status as "Cancelled" before you reassign all its associated "Live" Marketing activities')){       
                errormessage = 'There are open Marketing Activites on one or more of the Campaigns you are trying to update, please close them before proceeding.';
            }
            else {
                errormessage = 'An Error has occurred, please contact your System Administrator'; 
            }
            
            return null;   
        }
    }





    Public Pagereference selectAll() {
        for(Wrapper wrapper : wMCstoEdit){
            wrapper.selected = true;
        }
        return null;
    }

    Public Pagereference deselectAll() {
      for(Wrapper wrapper : wMCstoEdit){
            wrapper.selected = false;
        }
        return null;
    }

    Public Pagereference Cancel() {
    PageReference pageRef = new PageReference('/'+recordId);
        return pageRef;
    }

    Public Pagereference setAllStatus() {
        for(Wrapper wrapper : wMCstoEdit){
            wrapper.theMC.Status__c = selectOption.Status__c;
        }
     
        return null;
    }

    public class Wrapper{
        public Marketing_Campaign__c theMC {get; set;}
        public Boolean selected {get; set;}

        public Wrapper(Marketing_Campaign__c mc) {
            theMC = mc;
            selected = false;
        }
    }

}