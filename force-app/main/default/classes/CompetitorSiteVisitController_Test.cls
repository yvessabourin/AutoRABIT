@IsTest
public class CompetitorSiteVisitController_Test {

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
        String result = CompetitorSiteVisitController.doUploadAttachment(compVisit.Id, bodyTest, 'ExampleTestContentVersion', null);
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
        String result = CompetitorSiteVisitController.doUploadAttachment(compVisit.Id, bodyTest, 'ExampleTestContentVersion', null);
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
        String result = CompetitorSiteVisitController.doUploadAttachment(null, bodyTest, 'ExampleTestContentVersion', null);
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
        String result = CompetitorSiteVisitController.doUploadAttachment('error', bodyTest, 'ExampleTestContentVersion', null);
        Test.stopTest();
        
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :result];
        system.assert(contVersList.isEmpty());
    } 
    
    static testmethod void testGo_Success(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c WHERE Competitor_Site__c = :compSite.Id LIMIT 1];

        Test.startTest();     
        ApexPages.StandardController stdController = new ApexPages.StandardController(compSite);
        CompetitorSiteVisitController ctrller = new CompetitorSiteVisitController(stdController);
        ctrller.fn = 'ExampleTest';
        ctrller.file = EncodingUtil.base64Decode('This is a test');
        ctrller.cv = compVisit;
        ctrller.go();
        Test.stopTest();
        
        List<ContentVersion> contVersList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE FirstPublishLocationId = :compVisit.Id];
        system.assert(!contVersList.isEmpty());
    } 
    
    static testmethod void testPicklist(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        
        Test.startTest();     
        ApexPages.StandardController stdController = new ApexPages.StandardController(compSite);
        CompetitorSiteVisitController ctrller = new CompetitorSiteVisitController(stdController);
        
        List<SelectOption> overalls = ctrller.getOveralls();
        List<SelectOption> foods = ctrller.getFoodBeverage();
        List<SelectOption> extras = ctrller.getExtras();
        List<SelectOption> items = ctrller.getItems();
        List<SelectOption> presentations = ctrller.getPresentations();
        List<SelectOption> services = ctrller.getServices();
        
        Test.stopTest();
        
        system.assert(!overalls.isEmpty());
        system.assert(!foods.isEmpty());
        system.assert(!extras.isEmpty());
        system.assert(!items.isEmpty());
        system.assert(!presentations.isEmpty());
        system.assert(!services.isEmpty());
        
    }
    
    static testmethod void testAddAttachments(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        
        Test.startTest();     
        ApexPages.StandardController stdController = new ApexPages.StandardController(compSite);
        CompetitorSiteVisitController ctrller = new CompetitorSiteVisitController(stdController);
        ctrller.recType = 'Intel';
        ctrller.addAttachements();
        Test.stopTest();
    }
    
    static testmethod void testRedirects(){
        Village__c village = [SELECT Id FROM Village__c LIMIT 1];
        Competitor_Site__c compSite = [SELECT Id FROM Competitor_Site__c WHERE competitor_to_village__c = :village.Id LIMIT 1];
        Date today = system.today();
        
        Test.startTest();     
        ApexPages.StandardController stdController = new ApexPages.StandardController(compSite);
        CompetitorSiteVisitController ctrller = new CompetitorSiteVisitController(stdController);
        
        ctrller.startdate(today);
        PageReference nextPage = ctrller.toNextPage();
        PageReference finish = ctrller.finishUp();
        Test.stopTest();
        
        system.assertNotEquals(null,nextPage);
        system.assertNotEquals(null,finish);
        system.assertEquals(ctrller.startDate, today);
    }
    
}