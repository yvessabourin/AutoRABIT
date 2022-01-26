@isTest
private class resendGroupBookingEmailtest {

  public static Account account = new Account();
  private static Account account2 = new Account();
  private static Village_Presence__c vp = new Village_Presence__c();
  private static Village__c village = new Village__c();
  public static Contact contact = new Contact();
  public static Contact contact2 = new Contact();

  @testSetup static void setupdata(){
  
    
    LIST<recordtype> actrtid = [SELECT id from Recordtype WHERE DeveloperName = 'Tourism' AND SobjectType = 'Account'];
    LIST<recordtype> conrtid = [SELECT id from Recordtype WHERE Name = 'Tourism Contact' AND SobjectType = 'Contact'];
    List<Lead> Leadstoadd = new List<lead>();
      
      //create village 1
      village = new Village__c();
      village.Name = 'TestVillage1';     
      village.Village_Code__c = 'AA';
	  village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
	  village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
      insert village;
      
      //create accounts
      account.name = 'LeadActionsControllerTest';
      account.recordtypeid = actrtid[0].id;
      account.country__c = 'Albania';
      account.Type_of_Business__c = 'Airline';
      insert account;
         
      contact.FirstName = 'Paul';
      contact.LastName = 'Smith';
      contact.Email = 'dchilds@valueretail.com';
      contact.Secondary_Email_Address__c = 'dmoirc@hotmail.com';
      contact.Phone = '098786745333';
      insert contact;
      system.debug('contact1'+contact);
      
      contact2.FirstName = 'Paul';
      contact2.LastName = 'Smith';
      //contact2.Email = '';
      //contact2.Secondary_Email_Address__c = '';
      contact2.Phone = '098786745334';
      insert contact2;
      
  }

  static testmethod void ConfirmationEmailResent(){
  
        datetime myDate = datetime.now();
        Contact testcont = [SELECT ID FROM Contact WHERE email = 'dchilds@valueretail.com' LIMIT 1];
        system.assert(testcont != NULL, 'contact was not created');
        Account acnt = [SELECT Id FROM Account WHERE Name = 'LeadActionsControllerTest' LIMIT 1];
        system.assert(acnt != NULL, 'account was not created');
        Village__c Vilg = [SELECT Id FROM Village__c WHERE Name = 'TestVillage1'];
        system.assert(vilg != NULL, 'village was not created');
          
        Group_Booking__c GB = new Group_Booking__c();
        GB.Organisation__c = acnt.id;
        GB.Contact__c = testcont.id;
        GB.village__c = vilg.id;
        GB.Name_of_Event__c = 'Test';
        GB.status__c = 'Proposed';
        GB.Group_Type__c = 'MICE';
        GB.Secondary_MICE_Contact_Email__c = 'dmoirc@gmail.com';
        GB.Group_Booking_Source__c = 'Salesforce Front End';
        GB.Expected_Arrival__c = myDate;
        GB.Expected_Departure__c = myDate + 1;
        GB.Number_of_Visitors_Expected__c = 5;
        GB.Visitors_Country_of_Origin__c = 'Belgium';
        GB.Search_Keywords__c = '';
        system.debug(GB);
        
      insert GB;
      test.startTest();
      Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(GB);
      resendGroupBookingEmail controller = new resendGroupBookingEmail(stdController);
      controller.sendEmail();
      test.stopTest();
      Group_Booking__c thisGB = [Select id,Confirmation_Email_Resent__c FROM Group_Booking__c WHERE id =:GB.id];
      system.assert(thisGB.Confirmation_Email_Resent__c != NULL, 'Confirmation_Email_Resent NULL'+thisGB);
      
            
  }
  
  static testmethod void noEmailAddresses(){
  
        datetime myDate = datetime.now();
        Contact testcont2 = [SELECT ID FROM Contact WHERE phone = '098786745334' LIMIT 1];
        Account acnt = [SELECT Id FROM Account WHERE Name = 'LeadActionsControllerTest' LIMIT 1];
        Village__c Vilg = [SELECT Id FROM Village__c WHERE Name = 'TestVillage1'];
          
        Group_Booking__c GB = new Group_Booking__c();
        GB.Organisation__c = acnt.id;
        GB.Contact__c = testcont2.id;
        GB.village__c = vilg.id;
        GB.Name_of_Event__c = 'Test';
        GB.status__c = 'Proposed';
        GB.Group_Type__c = 'MICE';
        //GB.Secondary_MICE_Contact_Email__c = 'dmoirc@gmail.com';
        GB.Group_Booking_Source__c = 'Salesforce Front End';
        GB.Expected_Arrival__c = myDate;
        GB.Expected_Departure__c = myDate + 1;
        GB.Number_of_Visitors_Expected__c = 5;
        GB.Visitors_Country_of_Origin__c = 'Belgium';
        GB.Search_Keywords__c = '';
        
       insert GB;
      test.startTest();
      Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(GB);
      resendGroupBookingEmail controller = new resendGroupBookingEmail(stdController);
      controller.sendEmail();
      test.stopTest();
      system.debug('controller error'+ controller.message);
      System.assertEquals('Email Error, please make sure there is a valid email address on the "Booking/Partnership Contact" to send to.',controller.message,'Should be a "No email" error'); 
      
      
            
  }
  
  
  
    
    
}