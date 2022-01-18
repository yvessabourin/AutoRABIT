/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CompetitorSitesGeoControllerTest {


	private static Village__c village1 = new Village__c();
    private static Competitor_Site__c competitorSite = new Competitor_Site__c();  
    
    static void setupData(){
					
 		//create village 1
 		village1 = new Village__c();
 		village1.Name = 'TestVillage1'; 		
 		village1.Village_Code__c = 'AA';
 		village1.Village_GeoLocation__Latitude__s = 50.500;
 		village1.Village_GeoLocation__Longitude__s = -1.5;
		village1.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village1.CertSales_Report_Sales_Grace_Period_Days__c = 1;
 		insert village1;
		village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];   	

    	
    	competitorSite.Competitor_to_Village__c = village1.Id;
    	competitorSite.Site_Coordinates__Latitude__s = 50.100;
    	competitorSite.Site_Coordinates__Longitude__s = -1;
    	insert competitorSite;
    
    }

    static testMethod void unitTest() {

    	setUpData();
    	
    	PageReference pg = new PageReference('Page.CompetitorSitesGeo');
		list<Competitor_Site__c> siteList= new list<Competitor_Site__c>();
		test.setCurrentPageReference(pg);

 		test.startTest();	
			ApexPages.StandardSetController setController = new ApexPages.StandardSetController(siteList);
			
			CompetitorSitesGeoController controller = new CompetitorSitesGeoController(setController);
			
			system.assertEquals(controller.siteList.size(), [select Id from Competitor_Site__c].size());
			
		test.stopTest();
		

    }
}