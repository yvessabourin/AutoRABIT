@isTest
Private Class reAssignMarketingActivitiesTest{

    private static Village__c village = new Village__c();
    public static Trade_Event__c theEvent = new Trade_Event__c();
    public static Account testAccount = new Account();
    public static Marketing_Campaign__c MC = new Marketing_Campaign__c();
    public static Marketing_Activity__c MA = new Marketing_Activity__c();
    public static Marketing_Activity__c MA2 = new Marketing_Activity__c();
    public static list <Marketing_Activity__c> MAList = new list <Marketing_Activity__c>();
    public static User usr1 = new User();

    public static list <contact> contactList1 = new list <contact>();
    public static list <Trade_Event_Attendee__c> attendeelist2 = new list <Trade_Event_Attendee__c>();


    @isTest static void test_method_one() {

      setupData();
        
    ApexPages.StandardSetController StdSetCon = new ApexPages.StandardSetController(MAList);
    reAssignMarketingActivities controller = new reAssignMarketingActivities(StdSetCon);    

      //Apexpages.StandardSetcontroller stdsetController = new Apexpages.StandardSetcontroller();  
      list<reAssignMarketingActivities.wrapper> cMAs = new list<reAssignMarketingActivities.wrapper>();
      MAList = [SELECT Id, Name, Status__c FROM Marketing_Activity__c where id =:MA.id or id=:MA2.id];
      for(Marketing_Activity__c MA : MAList ){
           cMAs.add(new reAssignMarketingActivities.wrapper(MA, true));
          }

      controller.wMAstoEdit = cMAs;

      test.startTest();
      Controller.saveSelected();
      controller.selectAll();
      controller.deselectAll();
      controller.Cancel();
      controller.setAllStatus();
      test.stopTest();

    }   


  static void setupData(){

  recordtype rt = [SELECT id FROM recordtype where sObjectType = 'contact' AND DeveloperName = 'Brand_Contact' LIMIT 1];

 // recordtype mart = [SELECT id FROM recordtype where sObjectType = 'Marketing_Activity__c' AND Name = 'General Activity' LIMIT 1];
  
  recordtype mart = [SELECT id FROM recordtype where sObjectType = 'Marketing_Activity__c' AND DeveloperName = 'General_Activity' LIMIT 1];
      
  testAccount = TestData_Account.setupBrandAccount(1, true);   
               
  village.Name = 'TestVillage1';     
  village.Village_Code__c = 'AA';
  village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
  village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
  insert village;
  village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];        
    
  
  theEvent.Name = 'test trade event';
  theEvent.Start_Time__c = system.now(); 
  theEvent.End_Time__c = system.now();
  theEvent.Category_Specification__c = 'Conference';
  insert theEvent;

    Profile pf = [select Id from Profile where name = 'Tourism'];
    usr1.LastName = 'myTestu1';
    usr1.Alias = 'myTestu2';
    usr1.Email = 'myTestu2@valueretail.com';
    usr1.Username = 'controllertest123456789@valueretail.com';
    usr1.Communitynickname = 'myTestu2' + 'Nickname';
    usr1.profileId = pf.Id;
    usr1.PortalRole = 'Manager';
    usr1.timezonesidkey = 'Europe/London';
    usr1.emailencodingkey = 'UTF-8';
    usr1.languagelocalekey = 'en_US';
    usr1.localesidkey = 'en_GB';
    usr1.isActive = true;   
    insert usr1;
    
    MC.Name = 'LGC 1';
    MC.Short_Description__c = 'TEST';
    //MC.status__c = 'Confirmed';
    MC.status__c = 'Approved';
    MC.Campaign_Level__c = 'Theme';
    MC.Start_Date__c = system.today();
    MC.End_Date__c = system.today() + 10;
    //MC.Responsible_Person__c = 'test';
    MC.Responsible__c = usr1.id;
    //MC.Accountable__c = 'test';
    MC.Accountable_Person__c = usr1.id;
    insert MC;

    MA.name = 'Test MA1';
    MA.business_Function__c = 'Local Tourism';
    //MA.Partner__c = testAccount.id;
    MA.channel__c = 'BAU';
    MA.Sub_channel__c = 'Agency Fee';
    MA.Marketing_Campaign__c = MC.id;
    MA.recordtypeid = mart.id;
    //MA.status__c = 'Confirmed';
    MA.status__c = 'Approved';
    MA.Start_Date__c = system.today();
    MA.End_Date__c = system.today() + 10;
    MA.objective__c = 'test';
    MA.Response_Description__c = 'test';
    MA.Measurement_Description__c = 'test';
    MA.Communication_Plan__c = 'test';
    MA.Message__c = 'test';
    //MA.Accountable__c = 'test';
    MA.Accountable1__c = usr1.id;
    MA.Responsible_Person__c = usr1.id;
    //MA.Creative_Agency_Access_To_Salesforce__c = usr1.id;
    insert MA;

    MA2.name = 'Test MA2';
    MA2.business_Function__c = 'Local Tourism';
    MA2.channel__c = 'BAU';
    MA2.Sub_channel__c = 'Agency Fee';
    MA2.recordtypeid = mart.id;
    //MA2.Partner__c = testAccount.id;
    MA2.Marketing_Campaign__c = MC.id;
    //MA2.status__c = 'Confirmed';
    MA2.status__c = 'Approved';
    MA2.Start_Date__c = system.today();
    MA2.End_Date__c = system.today() + 10;
    MA2.objective__c = 'test';
    MA2.Response_Description__c = 'test';
    MA2.Measurement_Description__c = 'test';
    MA2.Communication_Plan__c = 'test';
    MA2.Message__c = 'test';
    //MA2.Accountable__c = 'test';
    MA2.Accountable1__c = usr1.id;
    MA2.Responsible_Person__c = usr1.id;
    //MA2.Creative_Agency_Access_To_Salesforce__c = usr1.id;
    insert MA2;
                      
  }


}