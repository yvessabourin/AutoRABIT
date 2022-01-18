public with sharing class CompetitorSitesGeoController {


	public list<Competitor_Site__c> siteList {get; set;}
	public list<Village__c> villageList {get; set;}  
	
	
	// Extract all VR villages and Competitor Sites to display on global page
    public CompetitorSitesGeoController(ApexPages.StandardSetController controller) {
		
		siteList = new list<Competitor_Site__c>();
		villageList = new list<Village__c>();
		
		siteList = [select Id, Name, Site_coordinates_Text__c, Distance_From_Village__c, Type__c,
						Competitor_to_Village__r.Name from Competitor_Site__c];
						
		villageList = [select Id, Name, Village_GeoLocation_Text__c from Village__c];				
						
		if (!siteList.isEmpty()){
			controller.setPageSize(siteList.size());
		}
		
    }


}