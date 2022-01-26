Public Class addtoInitiativiesController{

    ApexPages.StandardSetController setCon;
    
    Public List<Opportunity> deals {get;set;}

    Public Initiative_Member__c initMem {get;set;}

    public addtoInitiativiesController(ApexPages.StandardSetController controller) {
    
    setCon = controller;
    initMem = new Initiative_Member__c();
    deals = [SELECT Id,Name FROM Opportunity WHERE Id IN : (Opportunity[])setCon.getSelected()];


    }
    
    Public Pagereference Save() {
    
    List<Initiative_Member__c> initList = new List<Initiative_Member__c>();
    
    List<Initiative_Member__c> duplicateList = [SELECT id,Opportunity__c FROM Initiative_Member__c WHERE Initiative__c =:initMem.Initiative__c AND Opportunity__c IN :Deals ];
           
    system.debug('Dupe List '+duplicateList);
    try{
    for (opportunity opp : deals){
    
        boolean oppisDuplicate = false;
        
        IF(DuplicateList.size() > 0){
            for(Initiative_Member__c IM : duplicateList){
                If(IM.opportunity__c == opp.id){
                oppisDuplicate = true;
                }
            }
        }
   
       If(!oppisDuplicate){
        Initiative_Member__c initMember = new Initiative_Member__c();
        initMember.Initiative__c = initMem.Initiative__c;
        initMember.Opportunity__c = opp.id;
        
        initList.add(initMember);
        }
    }
        system.debug('init List '+initList);
        insert initList;
        
        return new PageReference('/'+initMem.Initiative__c);      
    }
    Catch (Exception e){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getmessage()));
    }
    return null;
    }
    
    
    Public Pagereference Cancel() {
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));  
    }

    
Public Class thisexception extends exception{

}


}