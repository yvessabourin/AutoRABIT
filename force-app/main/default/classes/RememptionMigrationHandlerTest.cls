@isTest
private class RememptionMigrationHandlerTest {

//  private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('Partnership Promotion').RecordTypeId;
    private static final id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('Partnership_Promotion').RecordTypeId;
    private static final id grpBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByDeveloperName.get('Group_Booking').RecordTypeId;
    private static final id VILLAGE_RECTYPE = Schema.SObjectType.Marketing_Campaign__c.RecordTypeInfosByDeveloperName.get('Village_Campaign').RecordTypeId;
    private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Redeemable_Campaign').getRecordTypeId();

    private Static Campaign multiChannelCampaign = new Campaign();
    private static Promotion_Redemption__c  firstPromoRedemption;
    private static Promotion_Redemption__c  secondPromoRedemption;    
    
    private static Account account = new Account();
    private static Account account2 = new Account();
    private static Village__c village = new Village__c();
    private static User usr = new User();
    private static User usr2 = new User();
    private static Marketing_Activity__c partnerPromo = null;
    private static Marketing_Campaign__c marketingCampaign = null;
    private static Group_Booking__c oneOffBooking = null;


    static void setupData(){
        Profile pr = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator'];
		UserRole regularRole = [Select Id From UserRole WHERE PortalType != 'CustomerPortal' Limit 1];
        
        // get sys admin user
        //usr = [select id from User where Profile.Name = 'System Administrator' AND isActive = true LIMIT 1][0]; 
        usr = new User();
        usr.LastName = 'Paul';
        usr.Alias = 'pal';
        usr.Email = 'paul@valueretai.com';
        usr.Username = 'paul@valueretai.com';
        usr.CommunityNickname = 'paulas';
        usr.UserRoleId = regularRole.Id;
        usr.ProfileId = pr.Id;
        usr.Village__c = 'Bicester';
        usr.TimeZoneSidKey = 'GMT';
        usr.LocaleSidKey = 'en_GB';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
        
        system.runAs(usr){
        
        //Account account = TestData_Account.setupTourismAccount(1, true);
        
        Profile pf = [select Id from Profile where name = 'Tourism'];
            
        RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
        
            RecordType brandContactRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Brand_Contact'];
        
            Contact communityContact = new Contact();
            communityContact.RecordTypeId = brandContactRecordType.Id;
            communityContact.LastName = 'John';
            communityContact.AccountId = brand.Id;
            communityContact.Village_Presence__c = 'Bicester';
            communityContact.Email = 'testcommunity.contact@brand.com';
            insert communityContact;
            
            Profile profileCommunity = [SELECT ID, Name FROM Profile WHERE Name = 'Third Party Community User'];
                
            User communityUser = new User();
            communityUser.LastName = communityContact.LastName;
            communityUser.Alias = 'jhn';
            communityUser.Email = communityContact.Email;
            communityUser.Username = 'john@valueretai.com';
            communityUser.CommunityNickname = 'johnvr';
            communityUser.ProfileId = profileCommunity.Id;
            communityUser.Village__c = 'Bicester';
            communityUser.TimeZoneSidKey = 'GMT';
            communityUser.LocaleSidKey = 'en_GB';
            communityUser.EmailEncodingKey = 'ISO-8859-1';
            communityUser.LanguageLocaleKey = 'en_US';
            communityUser.ContactId = communityContact.Id;
            communityUser.PortalRole = 'Manager';
            insert communityUser;
        
            village = new Village__c();
            village.Name = 'TestVillage';
            village.Village_Code__c = 'OO';
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
            insert village;
            village = [select name, id, B2B_Chatter_Group_Name__c, Village_Code__c from Village__c where Village_Code__c = 'OO' LIMIT 1];           
                            
            usr2 = TestData_User.setupUser('BarryBones', null, 'System Administrator', true, true);
            usr2 = [select Id, Name, Village__c from User where Id =:usr2.Id];
            usr2.Village__c = village.Name;
            update usr2;


            Document d = new Document(); 
            d.Name = 'Default'; 
            string myContent = 'text file text contents';           
            blob body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(blob.valueOf(myContent)));  
            d.Body =  body;
            d.ContentType = 'text/plain';
            d.Type = 'txt';
            d.FolderId = usr2.id;
            insert d;
                        
            account = TestData_Account.setupTourismAccount(1, true);
            account2 = TestData_Account.setupTourismAccount(2, true);

            contact con = TestData_Contact.setupTourismContact('A',account,true);   
            contact con2 = TestData_Contact.setupTourismContact('B',account2,true);   
                
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
            partnerPromo.Creative_Agency_Access_To_Salesforce__c = communityUser.id;
            partnerPromo.Marketing_Campaign__c = marketingCampaign.Id;
            partnerPromo.Partner__c = account.Id;
           
            partnerPromo.recordTypeId = promoRecordTypeId;
            insert partnerPromo; 


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
    
            //new redeemable campaign    
            multiChannelCampaign.Name = 'My Test Group Campaign';
            multiChannelCampaign.Communication_Channel__c = 'Email';
            multiChannelCampaign.Status = 'In Progress' ;
            multiChannelCampaign.isActive = true ;
            multiChannelCampaign.Village__c = village.id;
            multiChannelCampaign.description = 'This is my test campaign';
            multiChannelCampaign.startdate = Date.today();
            multiChannelCampaign.enddate = Date.today()+3;
            multiChannelCampaign.RecordTypeId = RedeemableCampRecordTypeId;
            
            insert multiChannelCampaign;
     
            firstPromoRedemption = new Promotion_Redemption__c(
                                                            voucher_code__c = '01xxxxxxxxxxxx',
                                                            redeem_date__c = date.today(),
                                                            Redeemable_Campaign__c = multiChannelCampaign.Id,
                                                            Location__c = 'TIC',
                                                            Mode_Of_Transport__c = 'Car',
                                                            Country_Of_Origin__c= 'China');
            insert firstPromoRedemption;
            
            secondPromoRedemption = new Promotion_Redemption__c(
                                                            voucher_code__c = '02xxxxxxxxxxxx',
                                                            redeem_date__c = date.today(),
                                                            Redeemable_Campaign__c = multiChannelCampaign.Id,
                                                            Location__c = 'Train Station',
                                                            Mode_Of_Transport__c = 'Car',
                                                            Country_Of_Origin__c = 'China');
            insert secondPromoRedemption;                                                       
        }
    }
                
    static testMethod void testUpdateGroupBooking() {

        setupData();
              
        system.runAs(usr2){
            test.startTest();           
            oneOffBooking.Old_Redemption_Campaign_ID__c = multiChannelCampaign.Id;
            oneOffBooking.Transfer_Redemptions_Now__c = true;
            
            update oneOffBooking;
            test.stopTest();
        }   
        
        
        list<Visit__c> visitList = [select Id, Name from Visit__c where Group_Booking__c = :oneOffBooking.Id];
        system.assert(visitList.size() > 0);
    }
    
    
    static testMethod void testUpdateMarketingActivity() {

        setupData();
        
        
        system.runAs(usr2){
            test.startTest();           
            partnerPromo.Old_Redemption_Campaign_ID__c = multiChannelCampaign.Id;
            partnerPromo.Transfer_Redemptions_Now__c = true;
            
            update partnerPromo;
            test.stopTest();
        }   
        
        
        list<Visit__c> visitList = [select Id, Name from Visit__c where Partnership_Promotion__c = :partnerPromo.Id];
        system.assert(visitList.size() == 2);

    }
    
    static testMethod void testInsertGroupBooking() {

        setupData();
        
        
        system.runAs(usr2){
            test.startTest();           
            
            oneOffBooking = new Group_Booking__c();
            oneOffBooking.Name_of_Event__c= 'Test one off booking1';
            oneOffBooking.recordTypeId = grpBookingRecordTypeId;
            oneOffBooking.Status__c = 'Confirmed';
            oneOffBooking.Village__c = village.Id;
            oneOffBooking.Expected_Arrival__c = system.today();
            oneOffBooking.Expected_Departure__c = system.now();
            oneOffBooking.visitors_country_of_origin__c = 'China';
            oneOffBooking.expected_mode_of_transport__c = 'Train';
            oneOffBooking.group_type__c  ='Leisure';
            oneOffBooking.Organisation__c = account.Id;
            oneOffBooking.Old_Redemption_Campaign_ID__c = multiChannelCampaign.Id;
            oneOffBooking.Transfer_Redemptions_Now__c = true;           
            insert oneOffBooking;
            
            test.stopTest();
        }   
        
        
        list<Visit__c> visitList = [select Id, Name from Visit__c where Group_Booking__c = :oneOffBooking.Id];
        system.assert(visitList.size() > 0);
    }
    
   static testMethod void testInsertMarketingActivity() {

        setupData();
        
        user comUser = [SELECT id,name FROM User WHERE UserName = 'john@valueretai.com'];
        
        
        system.runAs(usr2){
            test.startTest();           
            partnerPromo = new Marketing_Activity__c();
            partnerPromo.Start_Date__c = system.today();
            partnerPromo.End_Date__c = system.today().addDays(10);
            partnerPromo.Name = 'Test Village promo1';
            partnerPromo.Marketing_Campaign__c = marketingCampaign.Id;
            partnerPromo.Partner__c = account.Id;          
            partnerPromo.recordTypeId = promoRecordTypeId;
            partnerPromo.Old_Redemption_Campaign_ID__c = multiChannelCampaign.Id;
            partnerPromo.Creative_Agency_Access_To_Salesforce__c = comUser.id;
            partnerPromo.Transfer_Redemptions_Now__c = true;
            
            insert partnerPromo;
            test.stopTest();
        }   
        
        
        list<Visit__c> visitList = [select Id, Name from Visit__c where Partnership_Promotion__c = :partnerPromo.Id];
        system.assert(visitList.size() == 2);

    }
            
}