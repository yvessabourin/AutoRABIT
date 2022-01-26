@isTest
private class GenerateLeaseIdExtractTest {

    private static Account account = new Account();
    private static list<Account> accountList = new list<Account>();
    private static Contact contact = new Contact();
    private static list<Contact> contactList = new list<Contact>();
    private static User usr1 = null;
    private static User usr2 = null;
    private static Village__c village1 = new Village__c();
    private static Village_Presence__c vp1 = new Village_Presence__c();
    private static Unit__c unit1 = new Unit__c();
    
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
        Profile pf2 = [select Id from Profile where name = 'System Administrator'];
        UserRole ur = [select id from UserRole where name = 'CEO'];
        
        // create Admin user
        usr2 = TestData_User.setupAdminUser(true);
        usr2 = [Select UserRoleId from User where Id = :usr2.id];
        usr2.UserRoleId = ur.Id;
        update usr2;
        
        dateString = string.valueOfGmt(system.today());
        dateString = dateString.split(' ')[0].replace('-', '');        
        
        system.runAs(usr2) {
            
            for (integer i = 1; i < 3; i++){
                account = TestData_Account.setupBrandAccount(i, true);
                contact = TestData_Contact.setupBrandContact('A' + i,account, true);
                accountList.add(account);
                contactList.add(contact);
            }
            account = accountList[0];
            contact = contactList[0];
            
          //create village 1
            village1 = new Village__c();
            village1.Name = 'TestVillage1';         
            village1.Village_Code__c = 'AA';
			village1.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village1.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert village1;
            village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];             

            vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);
            vp1 = [select Id, name, Status__c, Daily_Sales_Active__c, Brand__c, Unit__c from Village_Presence__c where Id = :vp1.Id];
            vp1.status__c = 'Trading';
            vp1.Daily_Sales_Active__c = true;
            vp1.Brand__c = account.Id;
            vp1.Unit__c = unit1.Id;
            update vp1;
            
            setupCustomSettings();
            
        }
       
        
    
   }
    
    static testMethod void unitTest(){

        setupData();

        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        test.startTest();

            multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village1.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');
            string q = 'select Id, Name, Brand__r.Id, Brand__r.Name, Status__c, Village__r.Village_Code__c from Village_Presence__c ';
            q += ' where Village__r.Name = \'TestVillage1\' ';
            q += ' order by Name';
        
            Database.executeBatch(new GenerateLeaseIdExtract(q), 5);
                
        test.stopTest();        
        
    }
    
}