@isTest
public Class marketingCampaignActionsCtrExtTEST{

    public static Marketing_Campaign__c MC = new Marketing_Campaign__c();
    private static Account account2 = new Account();
    private static Village_Presence__c vp = new Village_Presence__c();
    private static Village__c village = new Village__c();

    @isTest
    static void editCampaignLeveltest() {
    
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(Alias = 'userTest', Email='testuser@test.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='testUser@test.com.SMP');
    insert u;                    

    MC.Name = 'TEST MC';    
    MC.Short_Description__c = 'test';
    MC.Campaign_Level__c = 'Theme';
    MC.Status__c = 'Approved';
    MC.Start_Date__c = system.today();
    MC.End_Date__c = system.today() + 1;
    MC.Responsible__c = u.Id; 
    MC.Accountable_Person__c = u.Id;
    insert MC;


    test.startTest();

    PageReference pageRef = Page.EditCampaignLevel;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', MC.id);

    
    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(MC);
    marketingCampaignActionsControllerExt stndcontroller = new marketingCampaignActionsControllerExt(stdController);
    stndcontroller.EditCampaignLevel();
    stndcontroller.option = 'test';
    stndcontroller.cancel();
    //stndcontroller.redirectURL = 'www.google.com';
    stndcontroller.save();

    stndcontroller.generateCSV();
        stndcontroller.generateCSVprojections();

    test.stopTest();





    }

}