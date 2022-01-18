@isTest
public class HNW_HFSPageControllerTest {
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
            
            Guest_Services_Data__c gsd1 = new Guest_Services_Data__c (Village__c='Bicester', Data_Code__c='C1', Data_Label__c='Label1', Service_Data_Type__c='Guest Type');
            Guest_Services_Data__c gsd2 = new Guest_Services_Data__c (Village__c='Bicester', Data_Code__c='C2', Data_Label__c='Label2', Service_Data_Type__c='HFS Collection Location');
            Guest_Services_Data__c gsd3 = new Guest_Services_Data__c (Village__c='Bicester', Data_Code__c='C3', Data_Label__c='Label3', Service_Data_Type__c='HFS Payment Status');
            insert new List <Guest_Services_Data__c> {gsd1, gsd2, gsd3};
        }
    }


    static testMethod void extensionTestN1(){
        setupData();

        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        Account guestAcc = [SELECT Id FROM Account where Customer_GUID__c = '12345' LIMIT 1];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            String userId = UserInfo.getUserId();
            User theUser = [SELECT Id, Village__c FROM User WHERE Id = :userId];
            PageReference pageContext = Page.HNW_HFSPage;
            Test.setCurrentPage(pageContext);
            
            ApexPages.currentPage().getParameters().put('accountId',guestAcc.Id);         

            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HNW_HFSPageController hFSGext = new HNW_HFSPageController(sc);

        Test.stopTest();

        System.assertEquals(theUser.Village__c, HNW_HFSPageController.userVillage);
        }
    }

    static testMethod void extensionTestN3(){
        setupData();
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HNW_HFSPageController hFSGext = new HNW_HFSPageController(sc);

            String savingSignature = HNW_HFSPageController.saveSignature('apex/image.jpg', '46ASZX565', 'John Smith');

        Test.stopTest();
            system.assertNotEquals(null, savingSignature);
        }
    }

    static testMethod void extensionTestN4(){
        setupData();
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];
        Account guestAcc = [SELECT Id FROM Account where Customer_GUID__c = '12345' LIMIT 1];

        Test.startTest();
        system.runAs(us){
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HNW_HFSPageController hFSGext = new HNW_HFSPageController(sc);

            String aHFS = HNW_HFSPageController.saveHFSShopping(guestAcc.Id, 'as@valueretail.com', 'Silva', 'Silva', 
                                                                     '98989898', 'Train', 'T',
                                                                     'VIP', 'Std', 'Bicester',
                                                                     'apex/image.jpg', 'paid', 'Privilege Guest',
                                                                     '13321323', 'HandsFreeshopping', 'Hands Free shoping', 'Mr.', NULL, NULL, 'ES','en', 'PROMO CODE', 'Registration Location', 'A REGISTERING PERSON');

        Test.stopTest();
            Case theHFSCase = [SELECT Id, Service_Guest_Number__c FROM Case WHERE Client_QR_Code__c = '13321323'];
            system.debug('ID IS  - - - - - - ' + theHFSCase.Id);
            system.assertEquals(theHFSCase.Service_Guest_Number__c , aHFS);
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
            HNW_HFSPageController hFSGext = new HNW_HFSPageController(sc);

            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Countries', 'TestAPI_Countries');
            multimock.setStaticResource(settings.Api_Host__c + settings.Lookup_Read__c + '/Villages', 'TestAPI_Villages');

            String getDropDown = HNW_HFSPageController.getDropdownValues();

        Test.stopTest();
            system.assertNotEquals(null , getDropDown);
        }
    }
}