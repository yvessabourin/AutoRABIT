@isTest
private class RedemptionCampaignSearchControllerTest {

    private Static Campaign campaign1 = new Campaign(); 
    private Static Campaign campaign2 = new Campaign(); 
    private static string village = 'Test Village'; 
    private static village__c testvillage = new village__c();
    private static Account TourismAccount1 = new Account();
    private static Account TourismAccount2 = new Account();
    
    private Static b2c_customer__c GuestContact = new b2c_customer__c();
    private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
    private static User usr = new User();
    private static list<Id> fixedSearchResults = new list<Id>();
    
    
    static void setupData()
    {
        
        User u1 = TestData_User.setupAdminUser(false);
        u1.Username = 'vr_u1@test.com';
        u1.Email = 'vr_u1@test.com';
        insert u1;
        
        system.runAs(u1){
            //Setup new test Village
            testvillage.Name = village;
            testvillage.Village_Code__c = 'TV';
			testvillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			testvillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
            insert testvillage;
            
            //Setup Partner
            TourismAccount1 = TestData_Account.setupTourismAccount(1,true);
            
            //setup b2c customer Contact
            //GuestContact.RecordTypeId = GuestRecordTypeId;
            GuestContact.FirstName__c = 'GuestFN';
            guestContact.LastName__c = 'GuestLN';
            guestcontact.Email__c = 'guest@guest.com';
            
            insert guestContact;
                   
            //new redeemable campaign
            Campaign1 = new Campaign();     
            Campaign1.Name = 'The First Test Group Campaign';
            Campaign1.Communication_Channel__c = 'Email';
            Campaign1.Status = 'In Progress' ;
            Campaign1.isActive = true ;
            Campaign1.Village__c = testvillage.id;
            Campaign1.Partner__c = TourismAccount1.id;
            Campaign1.description = 'The first test campaign';
            Campaign1.startdate = Date.today() - 1;
            Campaign1.enddate = Date.today()+3;
            Campaign1.RecordTypeId = RedeemableCampRecordTypeId;
            
            insert Campaign1;
     
             //Setup Partner
            TourismAccount2 = TestData_Account.setupTourismAccount(2,true);
      
            Campaign2 = new Campaign(); 
            Campaign2.Name = 'The Second Test Group Campaign';
            Campaign2.Communication_Channel__c = 'Post';
            Campaign2.Status = 'In Progress' ;
            Campaign2.isActive = true ;
            Campaign2.Village__c = testvillage.id;
            Campaign2.Partner__c = TourismAccount2.id;
            Campaign2.description = 'The second test campaign';
            Campaign2.startdate = Date.today();
            Campaign2.enddate = Date.today()+5;
            Campaign2.RecordTypeId = RedeemableCampRecordTypeId;
            
            insert Campaign2;
        }
        
        usr = TestData_User.setupAdminUser(false);
        usr.Village__c = village;
        insert usr;
    
    }
    static testMethod void singleMatched() {
        
        PageReference pg = new PageReference('Page.RedemptionCampaignSearch');  
        
        test.setCurrentPageReference(pg);
        setupData();
        fixedSearchResults.add(Campaign1.Id); 
        
        
        test.startTest();
            PageReference pgNav = null; 
            
            RedemptionCampaignSearchController controller = new RedemptionCampaignSearchController();
            controller.customerDetails = false;
            controller.redemptionCode = '12345678901234';
            controller.searchString = 'The First';
            controller.visitType = 'Business';
            controller.location = 'TIC';
            controller.transport = 'Coach';
            controller.country = 'France';
            
            list<SelectOption> countries = controller.getCountries();
            list<SelectOption> visits = controller.getVisitTypes();
            list<SelectOption> locations = controller.getLocations();
            list<SelectOption> transport = controller.getTransportModes();
            
            test.setFixedSearchResults(fixedSearchResults); 

            system.runAs(usr){
                pgNav = controller.searchCampaign();
            }
        
            system.assertEquals(controller.navURL, 'home');
            
            Promotion_Redemption__c redemption = [select Redeemable_Campaign__r.Id from Promotion_Redemption__c 
                                                    where Voucher_Code__c = '12345678901234'];
                                                    
            system.assertEquals(redemption.Redeemable_Campaign__r.Id, Campaign1.Id);
            
        test.stopTest();
    }
    
    static testMethod void singleMatchedWithCustomerDetails() {
        PageReference pg = new PageReference('Page.RedemptionCampaignSearch');      
        test.setCurrentPageReference(pg);
        setupData();
        fixedSearchResults.add(Campaign1.Id); 
        
        test.startTest();
            test.setFixedSearchResults(fixedSearchResults); 
            PageReference pgNav = null;     
            RedemptionCampaignSearchController controller = new RedemptionCampaignSearchController();
            controller.customerDetails = true;
            controller.redemptionCode = '12345678901234';
            controller.searchString = 'The First';
            controller.visitType = 'Business';
            controller.location = 'TIC';
            controller.transport = 'Coach';
            controller.country = 'France';
                        
            system.runAs(usr){
                pgNav = controller.searchCampaign();
            }
            
            system.assert(controller.navURL.indexOf('apex/multiaddredemptions') > -1);
            
        test.stopTest();
    }
    

    static testMethod void multiMatched() {
        
        PageReference pg = new PageReference('Page.RedemptionCampaignSearch');  
        
        test.setCurrentPageReference(pg);
        setupData();
        fixedSearchResults.add(Campaign1.Id); 
        fixedSearchResults.add(Campaign2.Id); 
        
        test.startTest();
            PageReference pgNav = null; 
            
            RedemptionCampaignSearchController controller = new RedemptionCampaignSearchController();
            controller.customerDetails = false;
            controller.redemptionCode = '12345678901234';
            controller.searchString = 'The*';
            controller.visitType = 'Business';
            controller.location = 'TIC';
            controller.transport = 'Coach';
            controller.country = 'France';
                        
            test.setFixedSearchResults(fixedSearchResults); 

            system.runAs(usr){
                pgNav = controller.searchCampaign();
            }
            
            system.assertEquals(controller.customerDetails, false);        

            
        test.stopTest();
    } 
    
    
    static testMethod void invalidSearch() {
        
        PageReference pg = new PageReference('Page.RedemptionCampaignSearch');  
        
        test.setCurrentPageReference(pg);
        setupData();
        
        test.startTest();
            PageReference pgNav = null; 
            
            RedemptionCampaignSearchController controller = new RedemptionCampaignSearchController();
            controller.customerDetails = false;
            controller.redemptionCode = '1234567890'; // less than 14 characters
            controller.searchString = 'The*';
            controller.visitType = 'Business';
            controller.location = 'TIC';
            controller.transport = 'Coach';
            controller.country = 'France';
            system.runAs(usr){
                pgNav = controller.searchCampaign();
            }
            
            system.assertEquals(controller.navURL, 'Invalid');

            controller.redemptionCode = null; // null redemption
            system.runAs(usr){
                pgNav = controller.searchCampaign();
            }

            system.assertEquals(controller.navURL, 'Invalid');          
            
        test.stopTest();
    }         
}