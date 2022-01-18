@isTest
private class VisitRedemptionsHelperTest {

 //   private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('Partnership Promotion').RecordTypeId;
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
      Contact con = TestData_Contact.setupTourismContact('A',account,true); 

      update account;
      account2 = TestData_Account.setupTourismAccount(2, true);
      
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
  
    static testMethod void testTrendingCampaigns() {
        
    setUpData();
        
        system.runAs(usr){
  
          Visit__c visit = new Visit__c(Visit_Date_Time__c = system.now(),
                          Partnership_Promotion__c = partnerPromo.Id,
                          Number_of_guests__c = 1,
                          Village__c = village.Id);
      insert visit;
      
          Visit__c visit2 = new Visit__c(Visit_Date_Time__c = system.now(),
                          Group_Booking__c = regularBooking.Id,
                          Number_of_guests__c = 1,
                          Village__c = village.Id);
                                  
          insert visit2;


                   
          test.startTest();
          list<VisitRedemptionsHelper.PromotionKey> pList = visitRedemptionsHelper.getTrendingCampaigns();
          test.stopTest();
          
          system.assert(pList[0].Id.indexOf(partnerPromo.Id) > -1);
        
        }
        
        
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
          list<VisitRedemptionsHelper.PromotionKey> pList = visitRedemptionsHelper.searchActivities('Test');
          test.stopTest();
          // only Promotions now. Group bookings have moved to separate controller
          system.assertEquals(pList.size() ,1,'Expected to find 1 search result');
        
        }
        
        
    }

    static testMethod void testAnonymousRedemption() {
        
    setUpData();      
        
        system.runAs(usr){

          test.startTest();
          /*string s1 = visitRedemptionsHelper.saveVisit('12345678901234', (String) partnerPromo.Id, '', 
                                        'TIC', 'Train', 'Leisure', 'Spain', 
                                        '', 'some notes','REG123', '01/01/2016 12:00','01/01/2016 14:00' , '1','1');*/
                                        
          string s1 = visitRedemptionsHelper.saveVisit('12345678901234', (String) partnerPromo.Id, '', 
                                        'TIC', 'Train', 'Leisure', 'Spain', 
                                        '', 'some notes','REG123', '01/01/2025 12:00','01/01/2025 14:00' , '1','1');                          

          
          Visit__c visit = [select Id from Visit__c where Group_Booking__c = :oneOffBooking.Id];
          
          /*string s2 = visitRedemptionsHelper.saveVisit('12345678901111;12345678902222', (String) oneOffBooking.Id, '', 
                            'TIC', 'Train', 'Leisure', 'Spain', 
                            visit.Id, 'some notes','REG123', '01/01/2016 12:00','01/01/2016 14:00' , '1','1');*/
                            
          string s2 = visitRedemptionsHelper.saveVisit('12345678901111;12345678902222', (String) oneOffBooking.Id, '', 
                            'TIC', 'Train', 'Leisure', 'Spain', 
                            visit.Id, 'some notes','REG123', '01/01/2025 12:00','01/01/2025 14:00' , '1','1');                 
          
          test.stopTest();
          
      list<Visit__c> v1 = [select Id from Visit__c where Partnership_Promotion__c = :partnerPromo.Id and Visit_Notes__c = 'some notes'];
      system.assert(v1.size() == 1);
      
      list<Visit__c> v2 = [select Id from Visit__c where Group_Booking__c = :oneOffBooking.Id and Visit_Notes__c = 'some notes'];
      system.assert(v2.size() == 1);      
        
        }
        
        
    }      

    static testMethod void testGuestRedemption() {
        
    setUpData();
     multimock.setStatusCode(200);
    multimock.setHeader('Content-Type', 'application/xml');
       
       // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);     
      multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/123456-7890-1234-1234-123456789012' , 'TestAPI_GoodGuest');
        multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c +  '/123456-7890-1234-1234-123456789012' , 'TestAPI_Preferences');
      multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c + '/123456-7890-1234-1234-123456789012|contactmodes|email', 'TestAPI_Preferences');
     multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c + '/123456-7890-1234-1234-123456789012|contactmodes|mobile', 'TestAPI_Preferences');
     multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c , 'TestAPI_Preferences');
               
        system.runAs(usr2){

          test.startTest();
          
          string guestId = VisitRedemptionsHelper.quickCreateGuest('jay@tee.com', '04444444444', 'Jay', 'Tee', 'United Kingdom', partnerPromo.Id, '0', '0', '0');
         
          string s1 = visitRedemptionsHelper.saveVisit('12345678901234',(String) partnerPromo.Id, guestId, 
                                        'TIC', 'Train', 'Leisure', 'Spain', 
                                        '', 'some notes','REG123' ,'01/01/2016 12:00','01/01/2016 14:00' , '1','1');

          
        
          test.stopTest();
          
      list<Visit__c> v = [select Id from Visit__c where Partnership_Promotion__c = :partnerPromo.Id and Visit_Notes__c = 'some notes'];
      system.assert(v.size() == 1);
      
      list<VIP_Card_Exchange__c> c = [select Id from VIP_Card_Exchange__c where Visit__c = :v[0].Id and Guest__c = :guestId];
      System.debug('c: ' + c);
      system.assert(c.size() == 1);
        
        }
        
        
    }      

    static testMethod void testInvalidRedemption() {
        
    setUpData();      
        
        system.runAs(usr){

          test.startTest();
          string s = visitRedemptionsHelper.saveVisit('1234',(String) partnerPromo.Id, '', 
                                        'TIC', 'Train', 'Leisure', 'Spain', 
                                        '', 'code is bad','REG123', '01/01/2016 12:00','01/01/2016 14:00' , '1','1');

          
          test.stopTest();
      
      system.assert(s.indexOf('Visit has been recorded, with no associated card redemptions') > -1);
      
      Visit__c visit = [select Id from Visit__c where Visit_Notes__c = 'code is bad'];          
      list<Vip_Card_Exchange__c> c = [select Id from VIP_Card_Exchange__c where Visit__c = :visit.Id];

      system.assert(c.isEmpty() == true);
          
        
        }
        
        
    }
    static testMethod void testDropdowns() {
        
    setUpData();
    multimock.setStatusCode(200);
    multimock.setHeader('Content-Type', 'application/xml');
       
       // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);  
              
        system.runAs(usr){
        
          test.startTest();
          
          string dropdowns = VisitRedemptionsHelper.getVisitDropdowns();          
          string countries = VisitRedemptionsHelper.getCountryDropdown();
        
          test.stopTest();
          
          system.assert(dropdowns.indexOf('TIC') > -1);
      system.assert(countries.indexOf('China') > -1);
        
        }

    }            

    static testMethod void testCleardown() {
        
    setUpData();

              
        system.runAs(usr){
        
          test.startTest();
           
           Visit__c visit = [select Id from Visit__c where Group_Booking__c = :oneOffBooking.Id];
          
          /*string s = visitRedemptionsHelper.saveVisit('12345678901111;12345678902222', (String) oneOffBooking.Id, '', 
                            'TIC', 'Train', 'Leisure', 'Spain', 
                            visit.Id, 'some notes','REG123', '01/01/2016 12:00','' , '1','1');*/
          
          string s = visitRedemptionsHelper.saveVisit('12345678901111;12345678902222', (String) oneOffBooking.Id, '', 
                            'TIC', 'Train', 'Leisure', 'Spain', 
                            visit.Id, 'some notes','REG123', '01/01/2025 12:00','' , '1','1');
                            
          
          string c = visitRedemptionsHelper.getVIPCards(visit.Id);
          system.assert(c.indexOf('12345678901111') > -1);
          system.assert(c.indexOf('12345678902222') > -1);
          
          s = visitRedemptionsHelper.clearCards('12345678901111;12345678902222');
 
           c = visitRedemptionsHelper.getVIPCards(visit.Id);
          system.assert(c.indexOf('12345678901111') == -1);
          system.assert(c.indexOf('12345678902222') == -1);
                   
          test.stopTest();

        
        }

    }
  
  static testMethod void testVisitListandNoShow(){

    setUpData();

              
        system.runAs(usr){
          
          visitRedemptionsHelper controller = new visitRedemptionsHelper();
        PageReference pg = new PageReference('/apex/PreBookedVisitList');
        pg.getParameters().put('promoId', oneOffBooking.Id);
        Test.setCurrentPage(pg);
                
          test.startTest();
           
           Visit__c visit = [select Id, No_Show__c from Visit__c where Group_Booking__c = :oneOffBooking.Id];
           
           system.assertEquals(visit.No_Show__c, false);
               
      PageReference pgReturn = controller.getVisitList();
          
          system.assert(controller.visitList.indexOf(visit.id) > -1);

      string s = visitRedemptionsHelper.saveVisit('12345678901111;12345678902222', (String) oneOffBooking.Id, '', 
                                        'TIC', 'Train', 'Leisure', 'Spain', 
                                        visit.Id, 'some notes','REG123', '','' , '2','1');
                                                  
          pgReturn = controller.getGroupCleardownList();
          
          system.assert(controller.cleardownList.indexOf(visit.Id) > -1);
          

          
          string noShow = visitRedemptionsHelper.noShow(visit.Id);

      visit = [select Id, No_Show__c from Visit__c where Group_Booking__c = :oneOffBooking.Id];
           
           system.assertEquals(visit.No_Show__c, true);          
          
          
          test.stopTest();
        
        }
  }
  
  // IB 7/3/2017 INC0305300
    static testMethod void testGuestRedemptionBadCode() {
        
    setUpData();
     multimock.setStatusCode(200);
    multimock.setHeader('Content-Type', 'application/xml');
       
       // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);     
      multimock.setStaticResource(settings.Api_Host__c + settings.Customer_read_GUID__c + '/123456-7890-1234-1234-123456789012' , 'TestAPI_GoodGuest');
        multimock.setStaticResource(settings.Api_Host__c + settings.Preference_read__c +  '/123456-7890-1234-1234-123456789012' , 'TestAPI_Preferences');
      multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c + '/123456-7890-1234-1234-123456789012|contactmodes|email', 'TestAPI_Preferences');
     multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c + '/123456-7890-1234-1234-123456789012|contactmodes|mobile', 'TestAPI_Preferences');
     multimock.setStaticResource(settings.Api_Host__c + settings.Preference_create__c , 'TestAPI_Preferences');
               
        system.runAs(usr2){

          test.startTest();
          
          string guestId = VisitRedemptionsHelper.quickCreateGuest('jay@tee.com', '04444444444', 'Jay', 'Tee', 'United Kingdom', partnerPromo.Id, '0', '0', '0');
         
          string s1 = visitRedemptionsHelper.saveVisit('12345678901111' + '\u00A0' + ';12345678902222;', (String) partnerPromo.Id, guestId, 
                                        'TIC', 'Train', 'Leisure', 'Spain', 
                                        '', 'some notes','REG123', '01/01/2016 12:00','01/01/2016 14:00' , '1','1');
          
        
          test.stopTest();
          
      list<Visit__c> v = [select Id from Visit__c where Partnership_Promotion__c = :partnerPromo.Id and Visit_Notes__c = 'some notes'];
      system.assert(v.size() == 1);
      
      list<VIP_Card_Exchange__c> c = [select Id from VIP_Card_Exchange__c where Visit__c = :v[0].Id and Guest__c = :guestId];
      system.assertEquals(c.size(), 2, 'there should be 2 codes. found: ' + c.size());
        
        }
        
        
    }       
  
}