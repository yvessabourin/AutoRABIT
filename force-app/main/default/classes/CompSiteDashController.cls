Public Class CompSiteDashController{

    public list<Competitor_Site__c> compsites {get;set;}
      
    Public CompSiteDashController(){
        compsites = [Select id, Name, days_overdue__c, last_on_Site_visit__c,Next_On_site_visit__c,Priority_level__c,Days_Since_Last_Site_Visit__c FROM Competitor_Site__c WHERE Days_Since_Last_Site_Visit__c >= 0 ORDER BY Days_Since_Last_Site_Visit__c ASC ];  
    }

}