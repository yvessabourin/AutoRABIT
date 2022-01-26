@IsTest
public class CompetitorVisitAddAttachmentsExt_Test {

    @testSetup
    public static void setupData(){
        
        Village__c village = TestDataGenerator.setupVillage(true);
        
        Competitor_Site__c compSite = new Competitor_Site__c(competitor_to_village__c = village.id);
        insert compSite;
        
        insert new Competitor_Visit__c(Competitor_Site__c = compSite.id, Date_of_Visit__c = system.today(), Number_of_Empty_Units__c = 2, Announced_New_Arrivals__c = 3 );
        
    }
    
    static testmethod void testDoUploadAttachment_Success(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__c = :compSite.Id LIMIT 1];

        Test.startTest();
        String bodyTest = 'This is a test';
        String result = CompetitorVisitAddAttachmentsExt.doUploadAttachment(compVisit.Id, bodyTest, 'ExampleTestContentVersion', null);
        Test.stopTest();
        
        system.assertEquals(String.valueOf(((Id)result).getSObjectType()), 'ContentVersion');
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :result];
        system.assert(!contVersList.isEmpty());
    } 
    
    static testmethod void testDoUploadAttachment_Error1(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__c = :compSite.Id LIMIT 1];

        Test.startTest();
        String bodyTest = null;
        String result = CompetitorVisitAddAttachmentsExt.doUploadAttachment(compVisit.Id, bodyTest, 'ExampleTestContentVersion', null);
        Test.stopTest();
        
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :result];
        system.assert(contVersList.isEmpty());
    } 
    
    static testmethod void testDoUploadAttachment_Error2(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__c = :compSite.Id LIMIT 1];

        Test.startTest();
        String bodyTest = 'This is a test';
        String result = CompetitorVisitAddAttachmentsExt.doUploadAttachment(null, bodyTest, 'ExampleTestContentVersion', null);
        Test.stopTest();
        
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :result];
        system.assert(contVersList.isEmpty());
    } 
    
    static testmethod void testDoUploadAttachment_Error3(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__c = :compSite.Id LIMIT 1];

        Test.startTest();
        String bodyTest = 'This is a test';
        String result = CompetitorVisitAddAttachmentsExt.doUploadAttachment('error', bodyTest, 'ExampleTestContentVersion', null);
        Test.stopTest();
        
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :result];
        system.assert(contVersList.isEmpty());
    } 
    
    static testmethod void testGo_Success(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__c = :compSite.Id LIMIT 1];

        Test.startTest();
       
        ApexPages.StandardController stdController = new ApexPages.StandardController(compVisit);
        CompetitorVisitAddAttachmentsExt ctrller = new CompetitorVisitAddAttachmentsExt(stdController);
        ctrller.fn = 'ExampleTest';
        ctrller.file = EncodingUtil.base64Decode('This is a test');
        ctrller.visit = compVisit;
        ctrller.visitId = compVisit.Id;
        ctrller.go();
        Test.stopTest();
        
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE FirstPublishLocationId = :compVisit.Id];
        system.assert(!contVersList.isEmpty());
    } 
    
}