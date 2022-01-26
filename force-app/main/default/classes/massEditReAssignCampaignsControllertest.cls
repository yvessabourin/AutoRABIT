@IsTest
Public Class massEditReAssignCampaignsControllertest{

    Public Static Marketing_Campaign__c MC1 {get;set;}
    Public Static Marketing_Campaign__c MC2 {get;set;}
    static final id GROUP_RECTYPE = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByDeveloperName.get('TBVSC_Brand_Campaign').RecordTypeId;
    static final id VILLAGE_RECTYPE = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByDeveloperName.get('Village_Campaign').RecordTypeId;

    @testsetup
    static void setupData(){
       
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'userTest', Email='testuser@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='testUser@test.com.SMP');

        insert u;

        list<Marketing_Campaign__c> mcToAdd = new list<Marketing_Campaign__c>();
        MC1 = new Marketing_Campaign__c(Name='Test Group Campaign', Campaign_Level__c = 'Theme',RecordTypeId = GROUP_RECTYPE,Campaign_Focus__c = 'Theme',Start_date__c = system.today(), end_date__c = system.today()+365, status__c = 'Approved', Responsible__c = u.Id , Accountable_Person__c = u.Id , CurrencyIsoCode = 'GBP');
        insert MC1;
        system.debug('MC1.id' + MC1.id);
        Marketing_Campaign__c MC2 = new Marketing_Campaign__c(Name='Test Village1 Campaign',Parent_Marketing_Campaign__c = MC1.id, Campaign_Level__c = 'Lead Moment',RecordTypeId = VILLAGE_RECTYPE,Campaign_Focus__c = 'Theme',Start_date__c = system.today(), end_date__c = system.today()+365, status__c = 'To be Approved', Responsible__c = u.Id , Accountable_Person__c = u.Id , CurrencyIsoCode = 'GBP');
        Marketing_Campaign__c MC3 = new Marketing_Campaign__c(Name='Test Village2 Campaign',Parent_Marketing_Campaign__c = MC1.id, Campaign_Level__c = 'Lead Moment',RecordTypeId = VILLAGE_RECTYPE,Campaign_Focus__c = 'Theme',Start_date__c = system.today(), end_date__c = system.today()+365, status__c = 'To be Approved', Responsible__c = u.Id , Accountable_Person__c = u.Id , CurrencyIsoCode = 'GBP');
        
        mcToAdd.add(MC2);
        mcToAdd.add(MC3);
        insert mcToAdd;

        
    }

    @isTest
    static void successTest() {
        
        Marketing_Campaign__c MC = [SELECT Name FROM Marketing_Campaign__c WHERE NAME = 'Test Group Campaign'];
        list<Marketing_Campaign__c> testMCs = [SELECT id, name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c =: MC.id ];
        system.debug('testMCs ' + testMCs);

        list<massEditReAssignCampaignsController.Wrapper> wraps = new list<massEditReAssignCampaignsController.Wrapper>();
        for(Marketing_Campaign__c mark : testMCs){
            wraps.add(new massEditReAssignCampaignsController.Wrapper(mark));
        }

        ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(testMCs);
        massEditReAssignCampaignsController controller = new massEditReAssignCampaignsController(StdSetCon);   
        PageReference pageRef = Page.massEditReAssignCampaigns;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', MC.id);
        
        test.startTest();
        controller.wMCstoEdit = wraps;
        controller.selectOption.status__c = 'Approved';
        Controller.setAllStatus();
        controller.selectAll();
        controller.deselectAll();
        controller.selectAll();
        Controller.saveSelected();
        test.stopTest();

        list<Marketing_Campaign__c> checkMCs = [SELECT id, name,Status__c FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c =: MC.id ];
        system.assert(checkMCs[0].status__c == 'Approved');

    }

    @isTest
    static void cancelTest() {
        
        Marketing_Campaign__c MC = [SELECT Name FROM Marketing_Campaign__c WHERE NAME = 'Test Group Campaign'];
        list<Marketing_Campaign__c> testMCs = [SELECT id, name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c =: MC.id ];
        system.debug('testMCs ' + testMCs);

        list<massEditReAssignCampaignsController.Wrapper> wraps = new list<massEditReAssignCampaignsController.Wrapper>();
        for(Marketing_Campaign__c Mark : testMCs){
            wraps.add(new massEditReAssignCampaignsController.Wrapper(mark));
        }
 
        ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(testMCs);
        massEditReAssignCampaignsController controller = new massEditReAssignCampaignsController(StdSetCon);   
        PageReference pageRef = Page.massEditReAssignCampaigns;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', MC.id);

        
        test.startTest();
        controller.wMCstoEdit = wraps;
        controller.selectOption.status__c = 'Cancelled';
        controller.Cancel();
        test.stopTest();

        list<Marketing_Campaign__c> checkMCs = [SELECT id, name,Status__c FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c =: MC.id ];
        system.debug('checkMCs ' + checkMCs);
        system.assert(checkMCs[0].status__c != 'Cancelled');

    }



    @isTest
    static void errorHandlingTest() {

        User usr = TestData_User.setupAdminUser(true);

        Marketing_Campaign__c VMC = [SELECT Name FROM Marketing_Campaign__c WHERE NAME = 'Test Village1 Campaign'];
      //  recordtype rectype = [SELECT id, Name FROM RecordType WHERE sObjectType = 'Marketing_Activity__c' AND Name = 'General Activity'];
        recordtype rectype = [SELECT id, Name FROM RecordType WHERE sObjectType = 'Marketing_Activity__c' AND DeveloperName = 'General_Activity'];
        Marketing_Activity__c MA1 = new Marketing_Activity__c(recordtypeid = rectype.id, name = 'TA1',  Business_function__c = 'Local PR', Channel__c = 'CRM',Sub_Channel__c = 'Printed Survey', Start_date__c = system.today(), end_date__c = system.today()+365, Status__c = 'Approved', Objective__c = 'test', Response_Description__c = 'test', Measurement_Description__c = 'test', Communication_Plan__c = 'test', Message__c = 'test', Marketing_Campaign__c = VMC.id  );
        insert MA1;

        Marketing_Campaign__c MC = [SELECT Name FROM Marketing_Campaign__c WHERE NAME = 'Test Group Campaign'];
        list<Marketing_Campaign__c> testMCs = [SELECT id, name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c =: MC.id ];
        system.debug('testMCs ' + testMCs);

        list<massEditReAssignCampaignsController.Wrapper> wraps = new list<massEditReAssignCampaignsController.Wrapper>();
        for(Marketing_Campaign__c mark : testMCs){
            wraps.add(new massEditReAssignCampaignsController.Wrapper(mark));
        }


        ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(testMCs);
        massEditReAssignCampaignsController controller = new massEditReAssignCampaignsController(StdSetCon);   
        PageReference pageRef = Page.massEditReAssignCampaigns;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', MC.id);

        
        test.startTest();
        system.runAs(usr){
            controller.MCs = testMCs;
            controller.wMCstoEdit = wraps;
            controller.selectOption.status__c = 'Cancelled';
            Controller.setAllStatus();
            controller.selectAll();
            controller.saveSelected();
        }
        test.stopTest();


        list<Marketing_Campaign__c> checkMCs = [SELECT id, name,Status__c FROM Marketing_Campaign__c WHERE name =: 'Test Village1 Campaign' ];
        system.assert(checkMCs[0].Status__c != 'Cancelled');

    }
    





}