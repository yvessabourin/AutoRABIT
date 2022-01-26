Global class getCompetitorVisits{

    public Id compSiteId {get;set;}
    public string theURL {get;set;}


    public List<Competitor_Visit__c> getvisits(){
        
        theuRL = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('test');
        
        List<Competitor_Visit__c> visits ;
        visits = [select id,Name,Date_of_Visit__c,BVSC_Employees_Name__c, recordType.Name from Competitor_Visit__c where Competitor_Site__c =: compSiteId ORDER BY Date_of_Visit__c DESC LIMIT 10  ];
        return visits  ;
    }
    
    
}