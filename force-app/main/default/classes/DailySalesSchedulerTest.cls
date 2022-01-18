@isTest
// This test class covers the following code modules:
// DailySalesScheduler - Apex class
// DailySalesBatchProcessor - Apex class
// DailySalesTriggerHelper - Apex class
// DailySalesValidations  -Apex class
// DailySaleTrigger - Trigger

private class DailySalesSchedulerTest {
    
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
            village2.CertSales_Report_Sales_Grace_Period_Days__c = 7;
            village2.CertSales_CertPeriod_Cut_Off_Days__c = 7;
            village2.CertSales_CertPeriod_Open_Days__c = 7;
            villagelist.add(village2);
            //insert village2;
            
            insert villagelist;
            village1 = villagelist[0];
            village2 = villagelist[1];
            
            // village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];  
            // village2 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1]; 
            // village3 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'CC' LIMIT 1]; 
          
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
                                                                     Daily_Sales_Active__c = true, Unit__c = unit1.Id, CertSales_Active__c = true, CertSales_CertPeriod_Type__c = 'Monthly');
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
            presentBrand.CertSales_Active__c = true;
            presentBrand.CertSales_CertPeriod_Type__c = 'Monthly';
            insert presentBrand;
            
            RecordType dsRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current'];
            
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
    static testmethod void unitTestScheduler(){
        
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
        
        multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village1.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');        
        multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village2.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList2'); 	
        string jobId = System.schedule('ScheduleApexClassTest1',
                                       CRON_EXP, 
                                       new DailySalesScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        test.startTest();
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has  run
        System.assertEquals(0, ct.TimesTriggered);
        
        usr1.IsActive = false;
        update usr1;
        
        test.stopTest();
        
        ct = [SELECT Id, CronExpression, TimesTriggered, 
              NextFireTime
              FROM CronTrigger WHERE id = :jobId];
        
        list<Daily_Sale__Share> dsShareList = [select Id from Daily_Sale__Share where UserOrGroupId = :usr1.Id];
        system.assert(dsShareList.isEmpty());
        
        system.debug('@@@@@ ct ' + ct);
    }
    
    /*	
static testmethod void unitTestBatchWithValidations(){

setupData();
multimock.setStatusCode(200);
multimock.setHeader('Content-Type', 'application/xml');

// Set the mock callout mode
Test.setMock(HttpCalloutMock.class, multimock);

test.startTest();
multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village1.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');        
multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village2.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList2');         
DailySalesBatchProcessor batchProcessor = new DailySalesBatchProcessor();
Database.executeBatch(batchProcessor);        

test.stopTest();

list<Daily_Sale__c> dsList = [select Id, Name, Status__c, Trading_date__c, brand_status__c,
store__c from Daily_Sale__c where Store__c =:vp1.Id or Store__c = :vp2.id];

system.debug('@@@@ dsList ...  ' + dsList);

list <Daily_Sale__Share> dsShareList = [Select AccessLevel, ParentId, UserOrGroupId, RowCause from Daily_Sale__Share where ParentId = :dsList[0].Id];

system.debug('@@@@ dsShareList ...  1  ' + dsShareList);
system.assert(dsShareList.size() == 1);
system.assertEquals(dsShareList[0].AccessLevel, 'Edit');

system.runAs(usr2){

// test validation for confirming record - No Authority
for (Daily_Sale__c ds :dsList){
if (ds.Store__c == vp1.Id){
ds.Status__c = 'Reported Confirmed';
ds.Brand_Status__c = 'Confirmed';            
}

}
try {            
update dsList;
} catch (exception e){
system.assert(e.getMessage().contains('authority'));    
}

// Test sharing rule update on status change
for (Daily_Sale__c ds :dsList){
if (ds.Store__c == vp1.Id){
ds.Status__c = 'Reported Confirmed';
ds.Brand_Status__c = 'Not Confirmed';
update ds;
}

}
//update dsList;

dsShareList = [Select AccessLevel, ParentId, UserOrGroupId, RowCause from Daily_Sale__Share where ParentId = :dsList[0].Id];        
system.debug('@@@@ dsShareList ...  2  ' + dsShareList);
system.assert(dsShareList.size() == 1);
system.assertEquals(dsShareList[0].AccessLevel, 'Read');

vpcr1 = [select Daily_Sales_Active_From__c, Daily_Sales_Active_To__c, Confirm_Daily_Sales_Records__c from Village_Presence_Contact_Role__c where Id = :vpcr1.id];
vpcr1.Daily_Sales_Active_From__c = system.today().addDays(-5);
vpcr1.Daily_Sales_Active_To__c = system.today().addDays(-2);
vpcr1.Confirm_Daily_Sales_Records__c = true;
update vpcr1;

vpcr2 = [select Daily_Sales_Active_From__c, Daily_Sales_Active_To__c, Confirm_Daily_Sales_Records__c from Village_Presence_Contact_Role__c where Id = :vpcr2.id];
vpcr2.Confirm_Daily_Sales_Records__c = true;
update vpcr2;
/*
// test validation for confirming record - With Authority
system.runAs(usr1){
Daily_Sale__c ds2 = [select Status__c, Number_of_Transactions__c , Brand_Status__c,Brand_Reported_Amount__c from Daily_Sale__c where store__c = :vp2.Id];                    
ds2.Status__c = 'Reported Confirmed';
ds2.Brand_Status__c = 'Confirmed';
ds2.Brand_Reported_Amount__c = 100;
ds2.Number_of_Transactions__c = 10;
update ds2;
}    




dsShareList = [Select AccessLevel, ParentId, UserOrGroupId, RowCause from Daily_Sale__Share where ParentId = :dsList[0].Id];        
system.debug('@@@@ dsShareList ...  3  ' + dsShareList);            
system.assert(dsShareList.isEmpty());            

*/
    
    //        }    
    
    //    }
}