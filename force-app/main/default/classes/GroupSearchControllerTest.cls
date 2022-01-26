@isTest
private class GroupSearchControllerTest {
    
//  private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('Partnership Promotion').RecordTypeId;
    private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('Partnership_Promotion').RecordTypeId;
    private static final id grpsPartnershipRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByDeveloperName.get('Groups_Partnership').RecordTypeId;
    private static final id grpBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByDeveloperName.get('Group_Booking').RecordTypeId;
    private static final id guestRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Guest').RecordTypeId;
    private static final id VILLAGE_RECTYPE = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByDeveloperName.get('Village_Campaign').RecordTypeId;

  
  private static Account account = new Account();
  private static Account account2 = new Account();
  private static Village__c village = new Village__c();
  private static User usr = new User();
  private static User usr2 = new User();
    private static Marketing_Activity__c partnerPromo = null;
    private static Marketing_Campaign__c marketingCampaign = null;
    private static Group_Booking__c regularBooking = null;
    private static Group_Booking__c oneOffBooking = null;    
    private static Group_Booking__c individualsPartnership = null;

  private static API_Configuration__c settings = new API_Configuration__c();
  private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

  static void setupCustomSettings(){

    settings.name = 'API Config LIVE';
      settings.Api_host__c = 'https://test.apiCustomer.com';
      settings.Api_key__c = '123456';
      settings.Customer_create__c = '/createCustomer';
      settings.Customer_read_GUID__c = '/readCustomer';
      settings.Debug_mode__c = true;
      settings.Enum_read__c = '/enumRead';
      settings.Lookup_read__c = '/lookupRead';
      settings.Preference_create__c = '/prefCreate';
      settings.Preference_read__c = '/prefRead';
      settings.Email_Change__c = '/emailChange';

      insert settings;        
  }
  
  static void setupMessages(){
    
    multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Villages', 'TestAPI_Villages');
    multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Languages', 'TestAPI_Languages');
    multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Genders', 'TestAPI_Genders');
    multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Countries', 'TestAPI_Countries');
    multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c, 'TestAPI_GoodGuest');
    
  }

     static void setupData(){

     // Create user
    usr = TestData_User.setupUser('BillyBones', null, 'System Administrator', true, true);
          
    system.runAs(usr){

      usr2 = TestData_User.setupUser('BarryBones', null, 'System Administrator', true, true);
      usr2 = [select Id, Name from User where Id =:usr.Id];
      
      account = TestData_Account.setupTourismAccount(1, true);
      account.logo_Id__c = 'http://www.google.com';
      account.Account_Email__c = 'accountA@valueretail.com';
      update account;
      account2 = TestData_Account.setupTourismAccount(2, true);
      account2.Account_Email__c = 'accountB@valueretail.com';
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.AllowSave = true;
        Database.update(account2, dmlOptions); 

      contact con = TestData_Contact.setupTourismContact('A',account,true);    
      contact conB = TestData_Contact.setupTourismContact('B',account2,true);     

      Document d = new Document(); 
      d.Name = 'Default'; 
      string myContent = 'text file text contents';      
      blob body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(blob.valueOf(myContent)));  
      d.Body =  body;
      d.ContentType = 'text/plain';
      d.Type = 'txt';
      d.FolderId = UserInfo.getUserId();
      insert d;
              
       village = new Village__c();
       village.Name = 'TestVillage';
       village.Village_Code__c = 'OO';
	   village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
	   village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
       insert village;
      village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'OO' LIMIT 1];      
          
          marketingCampaign = new Marketing_Campaign__c();
          marketingCampaign.Start_Date__c = system.today();
          marketingCampaign.End_Date__c = system.today().addDays(30);
          marketingCampaign.Name = 'Test Campaign';
          marketingCampaign.RecordTypeId = VILLAGE_RECTYPE;
          marketingCampaign.Village__c = village.Id;
          marketingCampaign.Campaign_Level__c = 'Theme';
          insert marketingCampaign;

          partnerPromo = new Marketing_Activity__c();
          partnerPromo.Start_Date__c = system.today();
          partnerPromo.End_Date__c = system.today().addDays(10);
          partnerPromo.Name = 'Test Village promo';
          partnerPromo.Marketing_Campaign__c = marketingCampaign.Id;
          partnerPromo.Partner__c = account.Id;
          //partnerPromo.Creative_Agency_Access_To_Salesforce__c = usr2.id;
         
          partnerPromo.recordTypeId = promoRecordTypeId;
          insert partnerPromo; 
          
          regularBooking = new Group_Booking__c();
          regularBooking.Name_of_Event__c= 'Test regular booking';
          regularBooking.recordTypeId = grpsPartnershipRecordTypeId;
          regularBooking.Status__c = 'Confirmed';
          regularBooking.Village__c = village.Id;
          regularBooking.Valid_from__c = system.today();
          regularBooking.Valid_to__c = system.today().addDays(50);
          regularBooking.visitors_country_of_origin__c = 'China';
          regularBooking.expected_mode_of_transport__c = 'Train';
          regularBooking.group_type__c  ='Leisure';
          regularBooking.Organisation__c = account.Id;
          insert regularBooking;  

          oneOffBooking = new Group_Booking__c();
          oneOffBooking.Name_of_Event__c= 'Test one off booking';
          oneOffBooking.recordTypeId = grpBookingRecordTypeId;
          oneOffBooking.Status__c = 'Confirmed';
          oneOffBooking.Village__c = village.Id;
          oneOffBooking.Expected_Arrival__c = system.today();
          oneOffBooking.Expected_Departure__c = system.now();
          oneOffBooking.visitors_country_of_origin__c = 'China';
          oneOffBooking.expected_mode_of_transport__c = 'Train';
          oneOffBooking.group_type__c  ='Leisure';
          oneOffBooking.Organisation__c = account.Id;
          insert oneOffBooking;


      setupCustomSettings();
    }

    setupMessages();
    
    usr = [select Id, Name, Village__c from User where Id =:usr.Id];
    usr.Village__c = village.Name;
    update usr;

  }


    static testMethod void testSearch() {
        
    setUpData();

    Id [] fixedSearchResults= new Id[4];
      fixedSearchResults[0] = partnerPromo.Id;
      fixedSearchResults[1] = regularBooking.Id;
      fixedSearchResults[2] = oneOffBooking.Id;

        Test.setFixedSearchResults(fixedSearchResults);        
        
        system.runAs(usr){

          test.startTest();
          list<GroupSearchController.groupKey> pList = GroupSearchController.searchActivities('Test');
          test.stopTest();
          // only Group Bookings now. Group bookings have moved to separate controller
          system.assertEquals(pList.size() ,2,'Expected to find 2 search results');
        
        }
        
        
    }


    static testMethod void testclone() {
          setUpData();
          // once all the data is set up, we need to check that its going to clone a booking
           String clonedBookingID = '';
          system.runAs(usr){

             clonedBookingID = GroupSearchController.clonebooking(String.valueOf(oneOffBooking.Id));
          }
          if(clonedBookingID != ''){
            // now lets get that new booking
            System.debug(clonedBookingID);
            Group_Booking__c clonedBooking = [Select ID, Name, Name_of_Event__c, Status__c FROM Group_Booking__c WHERe ID = :clonedBookingID][0];
            Group_Booking__c originalBooking =  [Select ID, Name, Name_of_Event__c, Status__c FROM Group_Booking__c WHERe ID = :oneOffBooking.Id][0];
            // now we can check that the old booking is now cancelled
            System.assertEquals(originalBooking.Status__c, 'Cancelled', 'This old booking should be cancelled');
            // Also, lets make sure the new booking was created, and is confirmed
            System.assertEquals(clonedBooking.Status__c, 'Confirmed', 'This new cloned booking should be confirmed');
          }
          else
          { 
            System.assert(false,'Booking could not be cloned');
          }
    }
    
    
}