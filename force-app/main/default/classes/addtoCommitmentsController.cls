public with sharing class addtoCommitmentsController {

    Public Opportunity oppVP {get;set;}
    ApexPages.StandardController stdController;
    ApexPages.StandardSetController setCon;
    Public List<Opportunity> deals {get;set;}
    Public Opportunity opp {get;set;}
    Public Opportunity commitmentOpp{get;set;}
    Public List<Opportunity> dupeCountList {get;set;}
    Public string returl {get;set;}
    Public string returlcommit {get;set;}
    Public Id commitrecordId {get;set;}
    Public list<opportunity> filteredOpps {get;set;}
  
    public addtoCommitmentsController(ApexPages.StandardController stdcontroller) {
    oppVP = new opportunity();
    commitmentOpp = new Opportunity();
    returlcommit = stdController.view().getUrl();
    commitrecordId = stdController.getid();
    Commitment_Letter__c commitObject = [SELECT Id,Name,Brand__c FROM Commitment_Letter__c WHERE Id =:commitrecordId ];
    filteredOpps = [SELECT Id, Name FROM Opportunity WHERE AccountId =:commitObject.Brand__c];
    }  


    public addtoCommitmentsController(ApexPages.StandardSetController controller) {
    setCon = controller;
    opp = new Opportunity();
    deals = [SELECT Id,Name FROM Opportunity WHERE Id IN : (Opportunity[])setCon.getSelected()];
    dupeCountList = new List<Opportunity>();
    returl = '';

    string orgURL = URL.getSalesforceBaseUrl().toExternalForm();
        if(orgURL.contains('vrdev2')){
           returl = CreateCommitmentURLs__c.getvalues('https://valueretail--vrdev2').Value__c;
        }
        else if(orgURL.contains('vr1uat')){
             returl = CreateCommitmentURLs__c.getvalues('https://valueretail--vr1uat').Value__c;
        }
        else if(orgURL.contains('valueretail')){
             returl = CreateCommitmentURLs__c.getvalues('https://valueretail.my.salesforce.com').Value__c;
        }
        else{
        }

    }

    Public Pagereference Save() {

    List<Opportunity> oppsToAdd = new List<Opportunity>();
    List<Opportunity> duplicateList = [SELECT id FROM Opportunity WHERE Commitment_Letter__c =:opp.Commitment_Letter__c ];
           
    try{
    for (opportunity oppy : deals){
    
        boolean oppisDuplicate = false;
        
            IF(duplicateList.size() > 0){
                for(Opportunity dupe : duplicateList){
                    If(oppy.id == dupe.id){
                    dupeCountList.add(oppy);
                    oppisDuplicate = true;
                    }
                }
            }
   
        If(!oppisDuplicate){
        oppy.Commitment_Letter__c = opp.Commitment_Letter__c;
        oppsToAdd.add(oppy);
        }
    }
        update oppsToAdd;
        
        return new PageReference('/'+opp.Commitment_Letter__c);      
    }
    Catch (Exception e){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getmessage()));
    }
    
    return null;
    }
    
    
    Public Pagereference CreateNewCommitment() {
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));  
    }


    Public Pagereference Cancel() {
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));  
    }

    
    public pagereference addDealtoCommitment(){
    system.debug('commitmentOpp.Village_Chain_Deal_Link__c === @@@ '+ commitmentOpp.Village_Chain_Deal_Link__c);
        Opportunity oppToUpdate = [SELECT ID, name FROM Opportunity Where id =:commitmentOpp.Village_Chain_Deal_Link__c];
        system.debug('oppToUpdate @@@' + oppToUpdate);
        system.debug('commitrecordId @@@' + commitrecordId );
        List<Commitment_Letter__c> commitToAdd = [SELECT Id, Name FROM Commitment_Letter__c WHERE id =:commitrecordId ];
        oppToUpdate.Commitment_Letter__c = commitToAdd[0].id;
        update oppToUpdate;
        pagereference backtoCommit = new Pagereference(returlcommit);
        return backtoCommit;
    }
    
      
    
    public pagereference redirectToVP(){
        String VPId = [SELECT ID, name FROM Village_Presence__c Where id =:oppVP.Village_Presence__c].id;
        pagereference selectVPPage = new PageReference('/'+VPId);
        return selectVPPage;    
    }



    Public Class thisexception extends exception{

    }

}