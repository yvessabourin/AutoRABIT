@isTest
public class HandsFreeShoppingExtentionTest {

    private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
    private static string dateString = '';

    static void setupData(){
        
        String dateString = string.valueOfGmt(system.today());
        dateString = dateString.split(' ')[0].replace('-', '');

        RecordType guestRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];

        Profile profileRunner = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Runner'];
        Profile profileCoordinator = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Co-ordinator'];

        UserRole runnerRole = new UserRole();
        runnerRole.DeveloperName = 'CustomRole'; 
        runnerRole.Name = 'Custom Role';
        insert runnerRole;

        User runner = new User();
        runner.LastName = 'John';
        runner.Alias = 'jhn';
        runner.Email = 'john@valueretai.com';
        runner.Username = 'john@valueretai.com';
        runner.CommunityNickname = 'johnvr';
        runner.UserRoleId = runnerRole.Id;
        runner.ProfileId = profileRunner.Id;
        runner.Village__c = 'Bicester';
        runner.TimeZoneSidKey = 'GMT';
        runner.LocaleSidKey = 'en_GB';
        runner.EmailEncodingKey = 'ISO-8859-1';
        runner.LanguageLocaleKey = 'en_US';
        insert runner;

        User coordinator = new User();
        coordinator.LastName = 'Paul';
        coordinator.Alias = 'pal';
        coordinator.Email = 'paul@valueretai.com';
        coordinator.Username = 'paul@valueretai.com';
        coordinator.CommunityNickname = 'paulas';
        coordinator.UserRoleId = runnerRole.Id;
        coordinator.ProfileId = profileCoordinator.Id;
        coordinator.Village__c = 'Bicester';
        coordinator.TimeZoneSidKey = 'GMT';
        coordinator.LocaleSidKey = 'en_GB';
        coordinator.EmailEncodingKey = 'ISO-8859-1';
        coordinator.LanguageLocaleKey = 'en_US';
        insert coordinator;

        system.runAs(coordinator){

            API_Configuration__c settings = new API_Configuration__c();
            settings.Name = 'API Config LIVE';
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
            settings.Lease_List__c = '/leaseList';
            insert settings;

            list<API_Customer_Read_Items__c> readSettingsList = new list<API_Customer_Read_Items__c>();

            API_Customer_Read_Items__c readSettings = new API_Customer_Read_Items__c();
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '05 Item';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = false;
            readSettings.Item_Label__c = 'Opt In Status';
            readSettings.Property_Items__c = 'OPTOUTEMAIL,OPTOUTMOBILE,OPTOUTPOSTAL';
            readSettingsList.add(readSettings);
            
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '10 CustomerStatus';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Customer Status';
            readSettingsList.add(readSettings);
            
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '20 Village';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Village Summary';
            readSettingsList.add(readSettings);

            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '30 Visit';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Visits';
            readSettingsList.add(readSettings);
            
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '40 Brand';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Brands';
            readSettingsList.add(readSettings);
            
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '50 OfferRedemption';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Redemptions';
            readSettingsList.add(readSettings);
            
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '60 EmailEvent';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Email Events';
            readSettingsList.add(readSettings);
            
            readSettings = new API_Customer_Read_Items__c();
            readSettings.Name = '70 CustomerPreference';
            readSettings.Active__c = true;
            readSettings.Display_as_Table__c = true;
            readSettings.Item_Label__c = 'Preferences';
            readSettingsList.add(readSettings);

            insert readSettingsList;

            // first create a village
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
            vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
            vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert vill;

            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            RecordType guestRType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];

            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;

            
            Account userAccount = new Account();
            userAccount.FirstName = 'Tom';
            userAccount.LastName = 'Tommy';
            userAccount.RecordTypeId = guestRType.Id;
            userAccount.Customer_GUID__c = '12345';
            insert userAccount;
            
            
            RecordType contactRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand Contact'];

            Contact contactDummy = new Contact();
            contactDummy.RecordTypeId = contactRecordType.Id;
            contactDummy.LastName = 'dummy';
            contactDummy.AccountId = brand.Id;
            contactDummy.Email = 'dummy@valueretail.com';
            insert contactDummy;

            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            presentBrand.Status__c = 'Trading';
            insert presentBrand;

            Case guestCase = new Case();
            guestCase.Village__c = vill.Id;
            guestCase.Service_Guest_ID__c = '123456789';
            guestCase.Service_Guest_Number__c = 'XA1';
            guestCase.Guest_ID_Number_Part__c = 12;
            guestCase.Payment_Status__c = 'Paid';
            guestCase.Client_QR_Code__c = '123456789';
            guestCase.Status = 'New';
            guestCase.Origin = 'Email';
            guestCase.Service_Date__c = system.today();
            insert guestCase;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.Village__c = 'Bicester';
            newRunner.User__c = runner.Id;
            insert newRunner;
            
            List<Guest_Services_Data__c> lstgsd = new List<Guest_Services_Data__c>();
            Guest_Services_Data__c gsd = new Guest_Services_Data__c();
            gsd.Data_Code__c = 'TA';
            gsd.Data_Label__c = 'testA';
            gsd.Default_Value__c = true;
            gsd.Service_Data_Type__c = 'Guest Type';
            gsd.Village__c = 'Bicester';
            lstgsd.add(gsd);
            
            Guest_Services_Data__c gsd1 = new Guest_Services_Data__c();
            gsd1.Data_Code__c = 'TB';
            gsd1.Data_Label__c = 'testB';
            gsd1.Default_Value__c = true;
            gsd1.Service_Data_Type__c = 'HFS Collection Location';
            gsd1.Village__c = 'Bicester';
            lstgsd.add(gsd1);
            
            Guest_Services_Data__c gsd2 = new Guest_Services_Data__c();
            gsd2.Data_Code__c = 'TC';
            gsd2.Data_Label__c = 'testC';
            gsd2.Default_Value__c = true;
            gsd2.Service_Data_Type__c = 'HFS Payment Status';
            gsd2.Village__c = 'Bicester';
            lstgsd.add(gsd2);
            
            Guest_Services_Data__c gsd3 = new Guest_Services_Data__c();
            gsd3.Data_Code__c = 'TD';
            gsd3.Data_Label__c = 'testD';
            gsd3.Default_Value__c = false;
            gsd3.Service_Data_Type__c = 'Guest Type';
            gsd3.Village__c = 'Bicester';
            lstgsd.add(gsd3);
            
            Guest_Services_Data__c gsd4 = new Guest_Services_Data__c();
            gsd4.Data_Code__c = 'TE';
            gsd4.Data_Label__c = 'testE';
            gsd4.Default_Value__c = false;
            gsd4.Service_Data_Type__c = 'HFS Collection Location';
            gsd4.Village__c = 'Bicester';
            lstgsd.add(gsd4);
            
            Guest_Services_Data__c gsd5 = new Guest_Services_Data__c();
            gsd5.Data_Code__c = 'TF';
            gsd5.Data_Label__c = 'testF';
            gsd5.Default_Value__c = false;
            gsd5.Service_Data_Type__c = 'HFS Payment Status';
            gsd5.Village__c = 'Bicester';
            lstgsd.add(gsd5);
            
			insert lstgsd;
			
			HFS_Country_Data__c cd1 = new HFS_Country_Data__c (Name='001',HFS_Country_Code__c='ES', HFS_Country_Name__c='Spain', HFS_Default_Option__c=true);
			HFS_Country_Data__c cd2 = new HFS_Country_Data__c (Name='002',HFS_Country_Code__c='UK', HFS_Country_Name__c='United Kingdom', HFS_Default_Option__c=true);
			HFS_Country_Data__c cd3 = new HFS_Country_Data__c (Name='003',HFS_Country_Code__c='DE', HFS_Country_Name__c='Germany', HFS_Default_Option__c=true);
			HFS_Country_Data__c cd4 = new HFS_Country_Data__c (Name='004',HFS_Country_Code__c='RU', HFS_Country_Name__c='United Kingdom', HFS_Default_Option__c=false);
			HFS_Country_Data__c cd5 = new HFS_Country_Data__c (Name='005',HFS_Country_Code__c='AO', HFS_Country_Name__c='Angola', HFS_Default_Option__c=false);
			
			List <HFS_Country_Data__c> cdList = new List <HFS_Country_Data__c> {cd1,cd2,cd3,cd4,cd5};
			insert cdList;
		}
    }


    static testMethod void extensionTestN1(){
        setupData();

        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];

            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);

        Test.stopTest();

        System.assertEquals(theUser.Village__c, HandsFreeShoppingExtention.userVillage);
        }
    }

    static testMethod void extensionTestN2(){
        setupData();

        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');

        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        API_Configuration__c settings = [SELECT Api_Host__c, Customer_create__c, Lookup_Read__c FROM API_Configuration__c];

        Test.startTest();
        system.runAs(us){
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);

            multimock.setStaticResource(settings.Api_Host__c + settings.Customer_create__c, 'TestAPI_GoodGuest');
            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Countries', 'TestAPI_Countries');
            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Villages', 'TestAPI_Villages');
            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Languages', 'TestAPI_Languages');
            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Genders', 'TestAPI_Genders');

            Map <String, List<Account>> guestSearch = HandsFreeShoppingExtention.searchGuests('Tom'); // Name present on static resource
        Test.stopTest();

        RecordType guestRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];
        Account guestAccount = [SELECT Id, Name, PersonEmail, RecordTypeId FROM Account WHERE RecordTypeId = :guestRecordType.Id AND FirstName = 'Tom'];
        List<Account> theAccount = [SELECT Id, Name, FirstName, LastName, Customer_GUID__c, PersonEmail,
                                    PersonMailingPostalCode, Country_of_Residence__c, PersonMobilePhone
                                    FROM Account
                                    WHERE Name = 'Tom']; // All elements on static resource

        System.assertEquals(theAccount, guestSearch.get('Guests'));
        }
    }

    static testMethod void extensionTestN3(){
        setupData();
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);

            String savingSignature = HandsFreeShoppingExtention.saveSignature('apex/image.jpg', '46ASZX565', 'John Smith');

        Test.stopTest();
            system.assertNotEquals(null, savingSignature);
        }
    }

    static testMethod void extensionTestN4(){
        setupData();
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);

            String aHFS = HandsFreeShoppingExtention.saveHFSShopping('', 'as@valueretail.com', 'Silva', 'Silva', 
                                                                     '98989898', 'Train', 'T',
                                                                     'VIP', 'Std', 'Bicester',
                                                                     'car', 'apex/image.jpg', 'paid', 'Privilege Guest',
                                                                     '13321323', 'HandsFreeshopping', 'Hands Free shoping', 'Mr.', 'Refuse to Answer', NULL, 'en', '', 'PROMO_CODE', 'Registration Location', 'A REGISTERING PERSON', null, null);

        Test.stopTest();
            Case theHFSCase = [SELECT Id FROM Case WHERE Client_QR_Code__c = '13321323'];
            system.assertEquals(theHFSCase.Id , aHFS); 
        }
    }

    static testMethod void extensionTestN5(){
        setupData();

        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
    
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        API_Configuration__c settings = [SELECT Api_Host__c, Lookup_read__c FROM API_Configuration__c];

        Test.startTest();
        system.runAs(us){
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);

            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Countries', 'TestAPI_Countries');
            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Villages', 'TestAPI_Villages');

            String getDropDown = HandsFreeShoppingExtention.getDropdownValues();

        Test.stopTest();
            system.assertNotEquals(null , getDropDown);
        }
    }

    static testMethod void extensionTestN6(){
        setupData();
        
        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        Account brand = [SELECT ID, Name FROM Account WHERE Name = 'Brand 1'];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);
            List<Village_Presence__c> lstVPresult = HandsFreeShoppingExtention.searchBrand(brand.Name, village.Name);
            
            Test.stopTest();
            
            System.assert(!lstVPresult.isEmpty());
        }
    }

    
    static testMethod void extensionTestN7(){
        setupData();
        
        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        Account brand = [SELECT ID, Name FROM Account WHERE Name = 'Brand 1'];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);
            String s = HandsFreeShoppingExtention.getPrivacyNoticeURLforVillage(village.Name, 'en');
            
            Test.stopTest();
            
            System.assert(s!=null);
        }
    }
    
    static testMethod void extensionTestN8(){
        setupData();
        
        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        Account brand = [SELECT ID, Name FROM Account WHERE Name = 'Brand 1'];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);
            String s = HandsFreeShoppingExtention.getTermsandConditionsforVillage(village.Name, 'en');
            
            Test.stopTest();
            
            System.assert(s!=null);
        }
    }
    
    static testMethod void extensionTestN9(){
        setupData();
        
        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        Account brand = [SELECT ID, Name FROM Account WHERE Name = 'Brand 1'];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingExtention hFSGext = new HandsFreeShoppingExtention(sc);
            String s = HandsFreeShoppingExtention.getPrivilegeTermsandConditions(village.Name, 'en');
            
            Test.stopTest();
            
            System.assert(s!=null);
        }
	}
	
    static testMethod void testCountriesData(){
        setupData();
        
        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        Account brand = [SELECT ID, Name FROM Account WHERE Name = 'Brand 1'];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
			HandsFreeShoppingExtention hfsExt = new HandsFreeShoppingExtention(sc);
			List<HandsFreeShoppingExtention.DropdownOption> defaultCountries = (List<HandsFreeShoppingExtention.DropdownOption>)JSON.deserialize(HandsFreeShoppingExtention.firstCountriesListStr,List<HandsFreeShoppingExtention.DropdownOption>.class);
			List<HandsFreeShoppingExtention.DropdownOption> otherCountries = (List<HandsFreeShoppingExtention.DropdownOption>)JSON.deserialize(HandsFreeShoppingExtention.otherCountriesListStr, List<HandsFreeShoppingExtention.DropdownOption>.class);
			system.assertEquals(3,defaultCountries.size());
			system.assertEquals(2,otherCountries.size());

            Test.stopTest();
            
        }
    }
    
/*  public static void getCountriesTest2(){

        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
              
        
        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;
        insert compesite;
        
        map<string, string> enumValues = new map<string, string>();
        

        
        ApexPages.StandardController sc = new ApexPages.StandardController(compesite);  
        HandsFreeShoppingExtention cse = new HandsFreeShoppingExtention(sc);

        
        HandsFreeShoppingExtention.SaveGuest('John', 'Smith', 'as@gmail.com', '935658566', 'Mr.', 'Portugal', 'Bicester');
        HandsFreeShoppingExtention.searchGuests('John');
    }

*/

}