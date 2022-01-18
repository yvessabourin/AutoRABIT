@IsTest
public class CompetitorVisitImagesController_Test {

    @testSetup
    public static void setupData(){
        
        Village__c village = TestDataGenerator.setupVillage(true);
        
        Competitor_Site__c compSite = new Competitor_Site__c(competitor_to_village__c = village.id);
        insert compSite;
        
        Competitor_Visit__c compVisit = new Competitor_Visit__c(Competitor_Site__c = compSite.id, Date_of_Visit__c = system.today(), Number_of_Empty_Units__c = 2, Announced_New_Arrivals__c = 3 );
        insert compVisit;
        
        ContentVersion contVers = new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', FirstPublishLocationId = compVisit.Id, ContentLocation = 'S', VersionData = Blob.valueOf('Test'));
        insert contVers;
    }
    
    
    static testmethod void testConstructor(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__r.competitor_to_village__c = :village.Id LIMIT 1];
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(compVisit);
        CompetitorVisitImagesController ctrller = new CompetitorVisitImagesController(stdController);
        ContentVersion cv = ctrller.contentversion;
        Test.stopTest();
        system.assert(!ctrller.fileIdsLtg.isEmpty());
    } 
    
}