@isTest
public class DailySalesLeaseIdSchedulerTest {
    
    private static Account account = new Account();
    private static list<Account> accountList = new list<Account>();
    private static Contact contact = new Contact();
    private static list<Contact> contactList = new list<Contact>();
    private static User usr1 = null;
    private static User usr2 = null;
    private static Village__c village1 = new Village__c();
    private static Village__c village2 = new Village__c();
    private static Unit__c unit1 = new Unit__c();
    private static Unit__c unit2 = new Unit__c();
    private static Village_Presence__c vp1;
    private static Village_Presence__c vp2;
    private static list<Village_Presence__c> vpList = new list<Village_Presence__c>();
    private static Village_Presence_Contact_Role__c vpcr1;
    private static Village_Presence_Contact_Role__c vpcr2;
    
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
                
                // this is an example of some pretty shocking code. please dont ever do this!  
                // this is an insert, inside a loop... it causes very many SOQL queries to run             
                /*   account = TestData_Account.setupBrandAccount(i, true);
contact = TestData_Contact.setupBrandContact('A' + i,account, true);
accountList.add(account);
contactList.add(contact); */
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
            
            //create village 1
            village1 = new Village__c();
            village1.Name = 'TestVillage1'; 		
            village1.Village_Code__c = 'AA';
            village1.Default_Daily_Sales_Record_Type__c = 'Net';
            village1.CertSales_Report_Sales_Grace_Period_Days__c = 5;
            village1.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            village1.CertSales_CertPeriod_Open_Days__c = 5; 
            villagelist.add(village1);
            //insert village1;
            
            
            //create village 2
            village2 = new Village__c();
            village2.Name = 'TestVillage2'; 		
            village2.Village_Code__c = 'BB';
            village2.Default_Daily_Sales_Record_Type__c = 'Net';
            village2.CertSales_Report_Sales_Grace_Period_Days__c = 5;
            village2.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            village2.CertSales_CertPeriod_Open_Days__c = 5; 
            villagelist.add(village2);
            //insert village2;            
            
            insert villagelist;
            village1 = villagelist[0];
            village2 = villagelist[1];
            
            // village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];  
            // village2 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1];  
            
            // create unit2
            List<Unit__c> unitlist = new List<Unit__c>();
            
            unit1 = new Unit__c(Name = 'AAA', Village__c = village1.Id, Phase_Id__c = 'P1', Suite_Id__c = 'S1', Size_GEA__c = 100);
            unitlist.add(unit1);
            //insert unit1;
            // unit1 = [select Name, MRI_Unit_Id__c from Unit__c where Id = :unit1.Id];
            
            unit2 = new Unit__c(Name = 'BBB', Village__c = village2.Id, Phase_Id__c = 'P2', Suite_Id__c = 'S2', Size_GEA__c = 100);
            unitlist.add(unit2);
            //insert unit2;
            // unit2 = [select Name, MRI_Unit_Id__c from Unit__c where Id = :unit2.Id];
            insert unitlist;
            
            List<Unit__c> unitlist2 = [select Name, MRI_Unit_Id__c from Unit__c where Id in :unitlist];
            for(Unit__c u :unitlist2){
                if(u.Name == 'AAA'){
                    unit1 = u;
                }
                if(u.Name == 'BBB'){
                    unit2 = u;
                }
            }
            System.debug('UNITS ====== '+ unit1 + unit2);
            
            vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Id,false);
            // vp1 = [select Id, name, Status__c, Daily_Sales_Active__c, Brand__c, Unit__c from Village_Presence__c where Id = :vp1.Id];
            vp1.status__c = 'Trading';
            vp1.Daily_Sales_Active__c = true;
            vp1.Brand__c = account.Id;
            vp1.Unit__c = unit1.Id;
            insert vp1;
            vpcr1 = new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vp1.id);
            insert vpcr1;
            
            vp2 = VillagePresenceUtilities.createVillagePresence(account.Id, village2.ID, false);
            //vp2 = [select Id, name, Status__c, Daily_Sales_Active__c, Brand__c, Unit__c from Village_Presence__c where Id = :vp2.Id];
            vp2.status__c = 'Trading';
            vp2.Daily_Sales_Active__c = true;
            vp2.Brand__c = account.Id;
            vp2.Unit__c = unit2.Id;
            insert vp2;
            vpcr2 = new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vp2.id);
            insert vpcr2;      
            
            for (Account a :accountList){
                if(a.Id != account.Id){
                    Village_Presence__c vp = new Village_Presence__c(Brand__c = a.Id, Village__c = village1.Id, Status__c = 'Trading', 
                                                                     Daily_Sales_Active__c = true, Unit__c = unit1.Id);
                    vpList.add(vp);
                }
                
            }
            insert vpList;

            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
            
            Unit__c unit = new Unit__c();
            unit.Village__c = village1.Id;
            unit.Name = 'BIC1';
            unit.Size_GEA__c = 120;
            unit.Suite_ID__c = 'S1';
            unit.Phase_Id__c = 'P1';
            insert unit;
            
            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Unit__c = unit.Id;
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = village1.Id;
            presentBRand.Daily_Sales_Active__c = true;
            presentBrand.Status__c = 'Trading';
            presentBrand.Lease_ID__c = 'ABC123';
            presentBrand.Expected_Unit__c = unit1.Id;
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
    }
    
    //testmethod
    static testmethod void unitTestLeaseIdSchedule(){
        
        // CRON expression: midnight on Jan 1 a year from now.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        integer year = system.today().addYears(1).year();
        string CRON_EXP = '0 0 0 1 1 ? ' + year;
        
        setupData();
        
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        
        list<Daily_Sale__c> dsList = new list<Daily_Sale__c>();
        list<Id> vpIds = new list<Id>();
        
        system.runAs(usr2){
            vpList.add(vp1);    
            for (Village_Presence__c vp :vpList){
                Daily_Sale__c ds = new  Daily_Sale__c(store__c = vp.Id, Status__c = 'Created', Trading_Date__c = system.today());
                dsList.add(ds);
                vpIds.add(vp.Id);
            }
            insert dsList;
            
            multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village1.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');        
            multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village2.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList2'); 	
            string jobId = System.schedule('ScheduleApexClassTest2',
                                           CRON_EXP, 
                                           new DailySalesLeaseIdScheduler());
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);
            
            // Verify the job has  run
            System.assertEquals(0, ct.TimesTriggered);
            
            dsList = [select Id, Integration_Message__c, Lease_Id__c from Daily_Sale__c where store__c in :vpIds];
            
            test.startTest();
            for(Daily_Sale__c ds :dsList){
                ds.Integration_Message__c = '';
                ds.Lease_Id__c = ''; 
            }
            system.runAs(usr2){
                update dsList;     
            }             
        }	
        test.stopTest();
    }
}