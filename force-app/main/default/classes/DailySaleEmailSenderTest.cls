@isTest
// Covers Apex classes - EmailSender, StoreUnconfirmedDailySales, DailySaleEmailSenderScheduler
private class DailySaleEmailSenderTest {

	private static Account account;
	private static Contact contact;
	private static Village__c village;
	private static Village_Presence__c vp1;
	private static User usr1;
	private static User usr2;
	private static Daily_Sale__c ds;
	private static string dateString;
	private static API_Configuration__c settings = new API_Configuration__c();
    private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
    private static id recTypeId =  Schema.SObjectType.Daily_Sale__c.getRecordTypeInfosByDeveloperName().get('Current').getRecordTypeId();

	private static void setupData() {

        Profile pf = [select Id from Profile where name = 'Brand Community Plus User'];
		Profile pf2 = [select Id from Profile where name = 'System Administrator'];
        UserRole ur = [select id from UserRole where name = 'CEO'];
        
        // create Admin user
        usr2 = TestData_User.setupAdminUser(true);
		usr2 = [Select UserRoleId from User where Id = :usr2.id];
        usr2.UserRoleId = ur.Id;
        update usr2;
		
		dateString = string.valueOfGmt(system.today()) ;
        dateString = dateString.split(' ')[0].replace('-', '');        
        
        system.runAs(usr2) {          	          
            
            list<Account> accountList = new list<Account>();
            list<Contact> contactList = new list<Contact>();
            
            for (integer i = 1; i < 2; i++){
                account = TestData_Account.setupBrandAccount(i, true);
                contact = TestData_Contact.setupBrandContact('A' + i,account, true);
            	accountList.add(account);
                contactList.add(contact);
            }
            account = accountList[0];
            contact = contactList[0];

            // create custom setting for share rules
            Daily_Sales_Status_Map__c dsMap = new Daily_Sales_Status_Map__c(Created__c = 'Edit', Reported_Incomplete__c = 'Edit', 
                                                                            	Reported_Confirmed__c = 'Read', SetupOwnerId=UserInfo.getOrganizationId());
            insert dsMap;

            Daily_Sales_Status_Map__c dsMap2 = new Daily_Sales_Status_Map__c(Created__c = 'Edit', Reported_Incomplete__c = 'Edit', 
                                                                             	Reported_Confirmed__c = 'Read', SetupOwnerId=pf.Id);
            insert dsMap2;
            
            // create region
            Region__c region = new Region__c(Name='UK & Ireland');
            insert region;
            region = [select Id,Name from Region__c where Name = 'UK & Ireland'];
system.debug('@@@@@ region ....  ' + region);            
            //create village 1
            village = new Village__c();
            village.Name = 'TestVillage1'; 		
            village.Village_Code__c = 'AA';
            village.Default_Daily_Sales_Record_Type__c = 'Net';
            village.region__c = region.id;
			village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert village;
            village = [select name, id, Village_Code__c, Region__c, Region__r.name from Village__c where Village_Code__c = 'AA' LIMIT 1];   	                        
system.debug('@@@@@ village ....  ' + village.Region__r.name + ' - ' + village); 

            Unit__c unit1 = new Unit__c(Name = 'AAA', Village__c = village.Id, Phase_Id__c = 'P1', Suite_Id__c = 'S1', Size_GEA__c = 100);
            insert unit1;
            unit1 = [select Name, MRI_Unit_Id__c from Unit__c where Id = :unit1.Id];
            
            vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village.Name);
            vp1 = [select Id, name, Status__c, Daily_Sales_Active__c, Brand__c, Unit__c, Village__r.Region__r.Name 
            			from Village_Presence__c where Id = :vp1.Id];
            			
system.debug('@@@@@ vp1 ....  ' + vp1);             			
            vp1.status__c = 'Trading';
            vp1.Daily_Sales_Active__c = true;
            vp1.Brand__c = account.Id;
            vp1.Unit__c = unit1.Id;
            update vp1;
            Village_Presence_Contact_Role__c vpcr1 = new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         	Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vp1.id);
            insert vpcr1;
			
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
    
    static testMethod void unitTestSchedule() {
		
		setupData();
		
        // CRON expression: midnight on Jan 1 a year from now.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        integer year = system.today().addYears(1).year();
        string CRON_EXP = '0 0 0 1 1 ? ' + year;


		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);        

        test.startTest();
       
      	multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + village.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1'); 
			
			system.runAs(usr2){
				ds = new Daily_Sale__c (Store__c = vp1.Id, Number_Of_Transactions__c = 100, 
	                    										Brand_Reported_Amount__c = 1000, 
	                    										Trading_Date__c = system.today() - 1, 
	                    										Status__c = 'Reported Incomplete',
	                    										Brand_Status__c = 'Not Confirmed',
	                    										Units_Sold__c = 150,
	                    										Footfall__c  = 200,
	                    										VIP_Cards__c = 10,
	                    										Tax_Free_Sales_Amount__c = 0,
	                    										Tax_Free_Transactions__c  = 0,
	                    										Total_NET_SALES__c = 1000,
	                    										NET_Value_of_Discounts__c = 0,
	                    										RecordTypeId = recTypeId
	                    										);                       
	             insert ds;           
			}
        string jobId = System.schedule('ScheduleApexClassTest1',
                        CRON_EXP, 
                        new DailySaleEmailSenderScheduler('UK'));

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);
            
            // Verify the job has  run
            System.assertEquals(0, ct.TimesTriggered);
     		
			// test batch class for coverage
			list<string> idList = new list<string>();
			idList.add(usr1.Id);
			Database.executeBatch(new EmailSenderBatch(idList));
     		
        test.stopTest();

        ct = [SELECT Id, CronExpression, TimesTriggered, 
                              NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
        
        system.debug('@@@@@ ct ' + ct);
        

        StoreUnconfirmedDailySales comp = new StoreUnconfirmedDailySales();
        comp.userId = usr1.Id;
        list<Daily_Sale__c> dsList = comp.getUnconfirmedList();
        
        system.assertEquals(dsList.size(), 1);
        
    }

}