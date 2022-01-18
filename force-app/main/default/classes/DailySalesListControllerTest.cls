@isTest
public class DailySalesListControllerTest {
    
    private static Account account = new Account();
    private static list<Account> accountList = new list<Account>();
    private static Contact contact = new Contact();
    private static list<Contact> contactList = new list<Contact>();
    private static User usr1 = null;
    private static User usr2 = null;
    private static Village__c village = new Village__c();
    private static Unit__c unit = new Unit__c();
    private static Village_Presence__c vp;
    private static list<Village_Presence__c> vpList = new list<Village_Presence__c>();
    private static Village_Presence_Contact_Role__c vpcr;
    
    private static string dateString = '';
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
        settings.Lease_List__c = '/leaseList';
        
        insert settings;                
    }
    
    
    static void setupData(){    
        
        Profile pf = [select Id from Profile where name = 'Brand Community Plus User'];     
        
        UserRole ur = [select id from UserRole where name = 'CEO'];
        
        // create Admin user
        usr2 = TestData_User.setupAdminUser(true);
        //usr2 = [Select UserRoleId from User where Id = :usr2.id];
        usr2.UserRoleId = ur.Id;
        update usr2;
        
        dateString = string.valueOfGmt(system.today());
        dateString = dateString.split(' ')[0].replace('-', '');        
        
        system.runAs(usr2) {
            
            for (integer i = 1; i < 15; i++){
                accountList.add( TestData_Account.setupBrandAccount(i, false));
            }
            insert accountList;
            
            for (integer i = 1; i < 15; i++){
                Account acc = accountList[(i-1)];
                contactList.add(TestData_Contact.setupBrandContact('A' + i,acc, false));
            }
            insert contactList;
            
            account = accountList[0];
            contact = contactList[0];
            
            // create custom setting for share rules
            Daily_Sales_Status_Map__c dsMap = new Daily_Sales_Status_Map__c(Created__c = 'Edit', Reported_Incomplete__c = 'Edit', 
                                                                            Reported_Confirmed__c = 'Read', SetupOwnerId=UserInfo.getOrganizationId());
            insert dsMap;
            
            Daily_Sales_Status_Map__c dsMap2 = new Daily_Sales_Status_Map__c(Created__c = 'Edit', Reported_Incomplete__c = 'Edit', 
                                                                             Reported_Confirmed__c = 'Read', SetupOwnerId=pf.Id);
            insert dsMap2;
            
            // create custom setting for global validation flag
            Global_Object_Validation__c gv = new Global_Object_Validation__c(SetupOwnerId=UserInfo.getOrganizationId(), Daily_Sales_Validations_Active__c = true);
            insert gv;
            
            List<Village__c> villagelist = new List<Village__c>();
            
            village = new Village__c();
            village.Name = 'TestVillage1';      
            village.Village_Code__c = 'AA';
            village.Default_Daily_Sales_Record_Type__c = 'Net';
            village.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            village.CertSales_CertPeriod_Open_Days__c = 5;
            village.CertSales_Report_Sales_Grace_Period_Days__c = 5;
            insert village;

            List<Unit__c> unitlist = new List<Unit__c>();
            
            unit = new Unit__c(Name = 'AAA', Village__c = village.Id, Phase_Id__c = 'P1', Suite_Id__c = 'S1', Size_GEA__c = 100);
            unitlist.add(unit);
            
            List<Unit__c> unitlist2 = [select Name, MRI_Unit_Id__c from Unit__c where Id in :unitlist];
            for(Unit__c u :unitlist2){
                if(u.Name == 'AAA'){
                    unit = u;
                }
            }
            insert unitlist;
            
            vp = VillagePresenceUtilities.createVillagePresence(account.Id, village.Id,false);
            vp.status__c = 'Trading';
            vp.Daily_Sales_Active__c = true;
            vp.Brand__c = account.Id;
            vp.Unit__c = unit.Id;
            insert vp;
            vpcr = new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vp.id);
            insert vpcr;
            
            for (Account a :accountList){
                if(a.Id != account.Id){
                    Village_Presence__c vp = new Village_Presence__c(Brand__c = a.Id, Village__c = village.Id, Status__c = 'Trading', 
                                                                     Daily_Sales_Active__c = true, Unit__c = unit.Id);
                    vpList.add(vp);
                }
                
            }
            insert vpList;

            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
            
            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Unit__c = unit.Id;
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = village.Id;
            presentBRand.Daily_Sales_Active__c = true;
            presentBrand.Status__c = 'Trading';
            presentBrand.Lease_ID__c = 'ABC123';
            presentBrand.Expected_Unit__c = unit.Id;
            insert presentBrand;
            
            RecordType dsRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Current'];
            
            Daily_Sale__c ds1 = new Daily_Sale__c();
            ds1.RecordTypeId = dsRecordType.Id;
            ds1.Trading_Date__c = system.today();
            ds1.Store__c = presentBrand.Id;
            ds1.Lease_ID__c = '1234';
            ds1.Total_NET_SALES__c = 100.00;
            ds1.Units_Sold__c = 10;
            ds1.Full_Price_Sales__c = 10.00;
            ds1.Full_Price_Units__c = 1;
            ds1.Status__c = 'Created';
            insert ds1;

            setupCustomSettings();
            
        }

        // create community user
        
        system.runAs(usr2){
            usr1 = new User(LastName = 'Testu1',
                            Alias = 'Testu2',
                            Email = 'Testu2@valueretail.com',
                            Username = 'Testu2@valueretail.com',
                            Communitynickname = 'Testu2' + 'Nickname',
                            profileId = pf.Id,
                            PortalRole = 'Manager',
                            timezonesidkey = 'Europe/London',
                            emailencodingkey = 'UTF-8',
                            languagelocalekey = 'en_US',
                            localesidkey = 'en_GB',
                            isActive = true,
                            contactId = contact.Id);
            
            insert usr1;
        }
    }
    
    //testmethod
    static testmethod void testDailySalesListControllerConfirmList(){
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        list<Daily_Sale__c> dsList = new list<Daily_Sale__c>();
        list<Village_Presence__c> vpListforAccount1 = null;
        setupData();

        multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');
        
        system.runAs(usr2){     
            list<Village_Presence_Contact_Role__c> vpcrList = new list<Village_Presence_Contact_Role__c>();
            vpListforAccount1 = [select Id, Name, Brand__c from Village_Presence__c where Brand__c = :account.Id];
            id recTypeId =  Schema.SObjectType.Daily_Sale__c.getRecordTypeInfosByDeveloperName().get('Current').getRecordTypeId();
            test.startTest();
            for (Village_Presence__c vp :vpListforAccount1){
                
                Daily_Sale__c ds = new Daily_Sale__c (Store__c = vp.Id, Number_Of_Transactions__c = 100, 
                                                      Brand_Reported_Amount__c = 1000, 
                                                      Trading_Date__c = system.today(), 
                                                      Status__c = 'Created',
                                                      Units_Sold__c = 150,
                                                      Footfall__c  = 200,
                                                      VIP_Cards__c = 10,
                                                      Tax_Free_Sales_Amount__c = 0,
                                                      Tax_Free_Transactions__c  = 0,
                                                      Total_NET_SALES__c = 1000,
                                                      NET_Value_of_Discounts__c = 0,
                                                      RecordTypeId = recTypeId
                                                     );
                dsList.add(ds);
            }
            insert dsList;
            
            // force one of the records to fail when confirming
            dsList[0].status__c = 'Reported Confirmed';
            update dsList[0];
            test.stopTest(); 
        }

        list<DailySalesListController.dailySale> dsList2 = DailySalesListController.getDailySalesList('Community_Confirm_List', 'All', true, 'DESKTOP');
        
        system.assertEquals(dsList2.size(), 0);
        
        system.runAs(usr2){
            
            dsList2 = DailySalesListController.getDailySalesList('Community_Confirm_List', 'All', true, 'DESKTOP');
            system.debug(' @@@@@@@@@@@@@@@@@@@@@         dsList2   a   ' + dsList2);
            system.assertEquals(dsList2.size(), vpListforAccount1.size() - 1);
            
            string dsIds = '[';
            for (DailySalesListController.dailySale ds : dsList2){
                ds.selected = true;
                dsIds += '\"' + ds.Id  + '\"' + ',';
            }
            // add bad record to list to force error
            dsIds += '\"' + dsList[0].Id  + '\"'; 
            dsIds += ']';
            
            string s = DailySalesListController.confirmList(dsIds);
            system.debug(' @@@@@@@@@@@@@@@@@@@@@         s   ' + s);
            
            dsList2 = DailySalesListController.getDailySalesList('Community_Confirm_List', 'All', true, 'DESKTOP');
            system.debug(' @@@@@@@@@@@@@@@@@@@@@         dsList2   b   ' + dsList2);
            system.assertEquals(dsList2.size(), 0);
            
            dsList2 = DailySalesListController.getDailySalesList('Community_Confirm_List', 'All', false, 'DESKTOP');
            system.debug(' @@@@@@@@@@@@@@@@@@@@@         dsList2   b   ' + dsList2);
            system.assertEquals(dsList2.size(), 2);
        }
        
        system.runAs(usr1){
            DailySalesListController.getConfirmUser();
        }
    }
}