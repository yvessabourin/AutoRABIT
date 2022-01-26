@isTest
public class DailySalesGraceSchedulerTest {

    private static Account account = new Account();
    private static list<Account> accountList = new list<Account>();
    private static Contact contact = new Contact();
    private static list<Contact> contactList = new list<Contact>();
    private static User usr1 = null;
    private static User usr2 = null;
    private static Village__c village1 = new Village__c();
    private static Village__c village2 = new Village__c();
    private static Village__c village3 = new Village__c();
    private static Unit__c unit1 = new Unit__c();
    private static Unit__c unit2 = new Unit__c();
    private static Unit__c unit3 = new Unit__c();
    private static Village_Presence__c vp1;
    private static Village_Presence__c vp2;
    private static Village_Presence__c vp3;
    private static list<Village_Presence__c> vpList = new list<Village_Presence__c>();
    private static Village_Presence_Contact_Role__c vpcr1;
    private static Village_Presence_Contact_Role__c vpcr2;
    private static Village_Presence_Contact_Role__c vpcr3;
    
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
        usr2.UserRoleId = ur.Id;

        update usr2;
        
        dateString = string.valueOfGmt(system.today());
        dateString = dateString.split(' ')[0].replace('-', '');        
        
        system.runAs(usr2) {
            
            for (integer i = 1; i < 10; i++){
                accountList.add( TestData_Account.setupBrandAccount(i, false));
            }

            insert accountList;

             for (integer i = 1; i < 10 ;i++){
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
            village1.CertSales_Report_Sales_Grace_Period_Days__c= 5;
            village1.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            village1.CertSales_CertPeriod_Open_Days__c = 5;
            villagelist.add(village1);
                
    
            //create village 2
            village2 = new Village__c();
            village2.Name = 'TestVillage2';         
            village2.Village_Code__c = 'BB';
            village2.Default_Daily_Sales_Record_Type__c = 'Net';
            village2.CertSales_Report_Sales_Grace_Period_Days__c= 5;
            village2.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            village2.CertSales_CertPeriod_Open_Days__c = 5;
            villagelist.add(village2);
           

            //create village 3
            village3 = new Village__c();
            village3.Name = 'TestVillage3';         
            village3.Village_Code__c = 'CC';
            village3.Default_Daily_Sales_Record_Type__c = 'Net';
            village3.CertSales_Report_Sales_Grace_Period_Days__c= 5;
            village3.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            village3.CertSales_CertPeriod_Open_Days__c = 5;
            villagelist.add(village3);
            
            insert villagelist;
            village1 = villagelist[0];
            village2 = villagelist[1];
            village3 = villagelist[2];

            // create closed period for village 3
            Village_Closed_Period__c vpc = new Village_Closed_Period__c(Village__c = village3.Id, From__c = system.today(), To__c = system.today());
            insert vpc;
            
            // create unit2
            List<Unit__c> unitlist = new List<Unit__c>();

            unit1 = new Unit__c(Name = 'AAA', Village__c = village1.Id, Phase_Id__c = 'P1', Suite_Id__c = 'S1', Size_GEA__c = 100);
            unitlist.add(unit1);

            unit2 = new Unit__c(Name = 'BBB', Village__c = village2.Id, Phase_Id__c = 'P2', Suite_Id__c = 'S2', Size_GEA__c = 100);
            unitlist.add(unit2);

            unit3 = new Unit__c(Name = 'CCC', Village__c = village3.Id, Phase_Id__c = 'P3', Suite_Id__c = 'S3', Size_GEA__c = 100);
            unitlist.add(unit3);

            insert unitlist;

            List<Unit__c> unitlist2 = [select Name, MRI_Unit_Id__c from Unit__c where Id in :unitlist];
            for(Unit__c u :unitlist2){
                if(u.Name == 'AAA'){
                    unit1 = u;
                }
                if(u.Name == 'BBB'){
                    unit2 = u;
                }
                if(u.Name == 'CCC'){
                    unit3 = u;
                }
            }
            System.debug('UNITS ====== '+ unit1 + unit2 + unit3);
            List<Village_Presence__c> vplistpart1 = new List<Village_Presence__c>();

            vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Id,false);
            vp1.status__c = 'Trading';
            vp1.Daily_Sales_Active__c = true;
            vp1.Brand__c = account.Id;
            vp1.Unit__c = unit1.Id;
            vplistpart1.add(vp1);
           
            
            vp2 = VillagePresenceUtilities.createVillagePresence(account.Id, village2.ID, false);
            vp2.status__c = 'Trading';
            vp2.Daily_Sales_Active__c = true;
            vp2.Brand__c = account.Id;
            vp2.Unit__c = unit2.Id;
             vplistpart1.add(vp2);
          

            vp3 = VillagePresenceUtilities.createVillagePresence(account.Id, village3.ID, false);
            vp3.status__c = 'Trading';
            vp3.Daily_Sales_Active__c = true;
            vp3.Brand__c = account.Id;
            vp3.Unit__c = unit3.Id;
            vplistpart1.add(vp3);

            insert vplistpart1;

            List<Village_Presence_Contact_Role__c> vpcrlist = new List<Village_Presence_Contact_Role__c>();
             vpcrlist.add(new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                            Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vplistpart1[0].id));
            //insert vpcr1;
             vpcrlist.add(new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vplistpart1[1].id));
            //insert vpcr2; 
             vpcrlist.add(new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vplistpart1[2].id));
            //insert vpcr3;  
            insert vpcrlist;

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
            
            Daily_Sales_Certification_Batch__c cert = new Daily_Sales_Certification_Batch__c();
            cert.Name = 'Brand in Village';
            cert.Village_Presence__c = presentBrand.Id;
            cert.Period_Start_Date__c = system.today()- 10;
            cert.Period_End_Date__c = system.today() - 6;
            cert.Status__c = 'Generated';
            insert cert;
              
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
            ds1.Certification_Batch__c = cert.Id;
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
    static testmethod void testDailySalesGrace(){
        
        boolean cut = false;
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        list<Daily_Sale__c> dsList = new list<Daily_Sale__c>();
        list<Village_Presence__c> vpListforAccount1 = null;
        
        setupData();
        
        test.startTest();
        multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village1.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');        
        multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village2.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList2');     
        multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village3.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList3');
        
        system.runAs(usr2){ 
            system.schedule('testschedule', '0 56 11 * * ?', new DailySalesGraceScheduler());
            
        }
        
        test.stopTest();
    } 
}