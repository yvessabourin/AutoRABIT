@isTest
private class addtotradeEventControllertest{

  private static Village__c village = new Village__c();
  public static Trade_Event__c theEvent = new Trade_Event__c();
  public static Account testAccount = new Account();
  public static Contact contact1 = new Contact();
  public static Contact contact2 = new Contact();
  public static list <contact> contactList1 = new list <contact>();
  public static list <Trade_Event_Attendee__c> attendeelist2 = new list <Trade_Event_Attendee__c>();
  public static Trade_Event_Attendee__c Attendee1 = new Trade_Event_Attendee__c();
  public static Trade_Event_Attendee__c Attendee2 = new Trade_Event_Attendee__c();


  static void setupData1(){

  recordtype rt = [SELECT id FROM recordtype where sObjectType = 'contact' AND Name = 'Brand Contact' LIMIT 1];
   
  testAccount = TestData_Account.setupBrandAccount(1, true);   
               
  village.Name = 'TestVillage1';     
  village.Village_Code__c = 'AA';
  village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
  village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
  insert village;
  village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];        
   
  contact1.FirstName = 'Firstname';   
  contact1.LastName = 'Surname';   
  contact1.phone = '123456789';   
  contact1.recordtypeid = rt.id;
  contact1.account = testAccount;  
  insert contact1; 
  
  contact2.FirstName = 'Firstname';   
  contact2.LastName = 'Surname';   
  contact2.phone = '123456789';   
  contact2.recordtypeid = rt.id;
  contact2.account = testAccount;  
  insert contact2; 
  
  theEvent.Name = 'test trade event';
  theEvent.Start_Time__c = system.now(); 
  theEvent.End_Time__c = system.now();
  theEvent.Category_Specification__c = 'Conference';
  insert theEvent;
                      
  }

    
    @isTest static void selectandProcessAccountandAttendees() {

      setupData1();
        
      test.startTest();
      Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(theEvent);
      addtotradeEventController controller = new addtotradeEventController(stdController );
      PageReference pageRef = Page.MassAddTradeEventAttendees;
      Test.setCurrentPage(pageRef);
      controller.initMem.Accountid = testAccount.id;
      controller.AddSelectedAttendees();

      list<addtotradeEventController.cContact> cCons = new list<addtotradeEventController.cContact>();
      contactList1 = [SELECT Id, Name FROM Contact where id =:contact1.id or id=:contact2.id];
      for(contact cta : contactList1 ){
            cCons.add(new addtotradeEventController.cContact(cta, true));
          }
      controller.consToSelect = cCons;

      controller.processSelected();
      controller.cancel();
      controller.finished();
      test.stopTest();
      list<Trade_Event_Attendee__c> TEA = [SELECT Id, name FROM Trade_Event_Attendee__c where Trade_Event__c =:theEvent.id];
      system.assert(TEA.size() == 2);
      
    }


  static void setupData2(){
   
  testAccount = TestData_Account.setupBrandAccount(1, true);   
  recordtype conrt = [SELECT id FROM recordtype where sObjectType = 'contact' AND Name = 'Brand Contact' LIMIT 1];
  recordtype teart = [SELECT id FROM recordtype where sObjectType = 'Trade_Event_Attendee__c' AND Name = 'Leasing Contact' LIMIT 1];
               
  village.Name = 'TestVillage1';     
  village.Village_Code__c = 'AA';
  village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
  village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
  insert village;
  village = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];        
   
  contact1.FirstName = 'Firstname';   
  contact1.LastName = 'Surname';   
  contact1.phone = '123456789';   
  contact1.recordtypeid = conrt.id;
  contact1.account = testAccount;  
  insert contact1; 
  
  contact2.FirstName = 'Firstname';   
  contact2.LastName = 'Surname';   
  contact2.recordtypeid = conrt.id;
  contact2.phone = '123456789';   
  contact2.account = testAccount;  
  insert contact2; 
  
  theEvent.Name = 'test trade event';
  theEvent.Start_Time__c = system.now(); 
  theEvent.End_Time__c = system.now();
  theEvent.Category_Specification__c = 'Conference';
  insert theEvent;
  
  Attendee1.contact__c = contact1.id;
  Attendee1.Trade_Event__c = theEvent.id;
  Attendee1.Invite_Status__c = 'Not invited';
  Attendee1.recordtypeid = teart.id;
  insert Attendee1;
  
  Attendee2.contact__c = contact2.id;
  Attendee2.Trade_Event__c = theEvent.id;
  Attendee2.Invite_Status__c = 'Not invited';
  Attendee2.recordtypeid = teart.id;
  insert Attendee2;
                     
  }


  @isTest static void selectandEditAttendees() {

      setupData2();
        
      test.startTest();

      Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(theEvent);
      MassEditTradeEventAttendees controller = new MassEditTradeEventAttendees(stdController );
      PageReference pageRef = Page.MassEditAttendees;
      Test.setCurrentPage(pageRef);

      list<MassEditTradeEventAttendees.cTradeAttendee> cAttendees = new list<MassEditTradeEventAttendees.cTradeAttendee>();
      MassEditTradeEventAttendees.cTradeAttendee cTEA1 = new MassEditTradeEventAttendees.cTradeAttendee(Attendee1);
      MassEditTradeEventAttendees.cTradeAttendee cTEA2 = new MassEditTradeEventAttendees.cTradeAttendee(Attendee2);
      cAttendees.add(cTEA1);
      cAttendees.add(cTEA2);
      controller.attendeesToEdit = cAttendees;
      controller.attendeesToEdit[0].selected = true;
      controller.attendeesToEdit[1].selected = true;

      controller.selectOptions.Invite_Status__c = 'Invited';
      controller.setAllStatus();
      controller.saveSelected();

      test.stopTest();

      list<Trade_Event_Attendee__c> TEAnonInvites = [SELECT Id, name FROM Trade_Event_Attendee__c where Trade_Event__c =:theEvent.id AND invite_status__c = 'Not Invited'];
      list<Trade_Event_Attendee__c> TEAinvites = [SELECT Id, name FROM Trade_Event_Attendee__c where Trade_Event__c =:theEvent.id AND invite_status__c = 'Invited'];
      system.assert(TEAinvites.size() == 2);
      system.assert(TEAinvites.size() > TEAnonInvites.size());
      
    }


     @isTest static void executeRemainingMethods() {

      setupData2();

      Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(theEvent);
      MassEditTradeEventAttendees controller = new MassEditTradeEventAttendees(stdController );
      PageReference pageRef = Page.MassEditAttendees;
      Test.setCurrentPage(pageRef);

      test.startTest();

      controller.cancel();
      controller.selectAll();
      controller.deselectAll();
      controller.setAllFollowUps();

      test.stopTest();


     }

    
    

    
    
}