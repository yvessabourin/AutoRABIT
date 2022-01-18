@isTest
public class BP_Certification_SCert_ControllerTest {
    
    static void setupData(){
        
        Profile profileSysAdmin = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator'];

        UserRole adminRole = new UserRole();
        adminRole.DeveloperName = 'CustomRole';
        adminRole.Name = 'Custom Role';
        insert adminRole;

        User admin = new User();
        admin.LastName = 'AdministratorForTestingHere';
        admin.Alias = 'admin';
        admin.Email = 'adminFortests@valueretai.com';
        admin.Username = 'adminFortests@valueretai.com';
        admin.CommunityNickname = 'admin';
        admin.UserRoleId = adminRole.Id;
        admin.ProfileId = profileSysAdmin.Id;
        admin.Village__c = 'Bicester';
        admin.TimeZoneSidKey = 'GMT';
        admin.LocaleSidKey = 'en_GB';
        admin.EmailEncodingKey = 'ISO-8859-1';
        admin.LanguageLocaleKey = 'en_US';
        insert admin;

        system.runAs(admin){
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
            vill.Village_Code__c = 'BC';
            vill.CertSales_Tot_Variance_Max_Percent__c = 5;
            vill.CertSales_Report_Sales_Grace_Period_Days__c= 5;
            vill.CertSales_CertPeriod_Cut_Off_Days__c = 5;
            vill.VR_Finance_Email__c = 'test@valueretai.com';
            insert vill;
            
            Unit__c unit = new Unit__c();
            unit.Village__c = vill.Id;
            unit.Name = 'BIC1';
            unit.Size_GEA__c = 120;
            unit.Suite_ID__c = 'S1';
            unit.Phase_Id__c = 'P1';
            insert unit;
            
            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
            
            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Unit__c = unit.Id;
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            presentBRand.Daily_Sales_Active__c = true;
            presentBrand.Status__c = 'Trading';
            presentBrand.Lease_ID__c = 'ABC123';
            presentBrand.Expected_Unit__c = unit.Id;
            insert presentBrand;
            
            RecordType brandContactRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand Contact'];
            
            Contact communityContact = new Contact();
            communityContact.RecordTypeId = brandContactRecordType.Id;
            communityContact.LastName = 'John';
            communityContact.AccountId = brand.Id;
            communityContact.Village_Presence__c = 'Bicester';
            communityContact.Email = 'testcommunity.contact@brand.com';
            insert communityContact;

            Village_Presence_Contact_Role__c communityContactRole = new Village_Presence_Contact_Role__c();
            communityContactRole.Contact__c = communityContact.Id;
            communityContactRole.Retail_Role__c = 'Retail';
            communityContactRole.Village_Presence__c = presentBrand.Id;
            communityContactRole.Daily_Sales_Active_From__c = Date.newInstance(2018, 10, 1);
            communityContactRole.Daily_Sales_Active_To__c = Date.newInstance(2025, 10, 1);
            communityContactRole.Confirm_Daily_Sales_Records__c = true;
            communityContactRole.BP_HFS_Brand_TeC_Conf_Date__c = Date.newInstance(2025, 10, 1);
            communityContactRole.Certification_Active__c = true;
            insert communityContactRole;

            UserRole communityRole = new UserRole();
            communityRole.DeveloperName = 'NewBalanceCustomerUser5';
            communityRole.Name = 'NewBalanceCustomerUser1';
            insert communityRole;
            
            Profile profileCommunity = [SELECT ID, Name FROM Profile WHERE Name = 'Brand Community Plus User (with Export)'];
            
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
            
            Daily_Sales_Certification_Batch__c cert = new Daily_Sales_Certification_Batch__c();
            cert.Name = 'Brand in Village';
            cert.Village_Presence__c = presentBrand.Id;
            cert.Period_Start_Date__c = system.today()-1;
            cert.Period_End_Date__c = system.today()+1;
            insert cert;
            
            RecordType dsRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Current'];
            
            Daily_Sale__c ds1 = new Daily_Sale__c();
            ds1.RecordTypeId = dsRecordType.Id;
            ds1.Trading_Date__c = system.today();
            ds1.Store__c = presentBrand.Id;
            ds1.Lease_ID__c = '1234';
            insert ds1;
            
            Daily_Sale__c ds2 = new Daily_Sale__c();
            ds2.RecordTypeId = dsRecordType.Id;
            ds2.Trading_Date__c = system.today();
            ds2.Store__c = presentBrand.Id;
            ds2.Lease_ID__c = '4321';
            insert ds2;
            
            API_Configuration__c settings = new API_Configuration__c();
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
    }
    
    static testMethod void CertificationTable(){
        setupData();
        
        User us = [SELECT Id, ContactId FROM User WHERE Alias = 'jhn'];
        
        system.runAs(us){
            
            Test.startTest();
                MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
                multimock.setStatusCode(200);
                multimock.setHeader('Content-Type', 'application/xml');
                
                // Set the mock callout mode
                Test.setMock(HttpCalloutMock.class, multimock);
            
                Village__c village = [SELECT Village_Code__c FROM Village__c];
                API_Configuration__c settings = [SELECT Api_Host__c, Lease_List__c FROM API_Configuration__c];
                String dateString = string.valueOfGmt(system.today()) ;
                dateString = dateString.split(' ')[0].replace('-', '');
            
                multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + village.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1'); 
            
                Daily_Sales_Certification_Batch__c certificationId = [SELECT Id, Overall_Comment__c, Variance_percentage_out_of_limits__c, Brand_Must_Edit_Before_Submission__c, Status__c
                                                                    FROM Daily_Sales_Certification_Batch__c LIMIT 1];
                certificationId.Brand_Must_Edit_Before_Submission__c = false;
                update certificationId;
                List<Daily_Sale__c> dailySaleList = BP_Certification_SCert_Controller.getDalySales(certificationId.Id, 'Trading_Day_with_date__c', true);
                Daily_Sales_Certification_Batch__c viewedCert = BP_Certification_SCert_Controller.getCertification(certificationId.Id);
                String nameCert = BP_Certification_SCert_Controller.getCertificationName(certificationId.Id);
                String rangeCert = BP_Certification_SCert_Controller.getCertificationRG (certificationId.Id);
            	Boolean isToSubmit = true;
                BP_Certification_SCert_Controller.submitCertification(certificationId.Id, certificationId.Overall_Comment__c, isToSubmit);
                List<Daily_Sale__c> savedDsList = [SELECT Id, Trading_Day_with_date__c, Total_NET_SALES__c, NET_Value_of_Discounts__c, Brand_Reported_Amount__c, Certified_Amount_NetTotal_Input__c, Certified_Amount_Discount_Input__c, Certified_Amount__c, Variance_Amount__c, Certification_Comment__c, MRI_Suite_Id__c FROM Daily_Sale__c WHERE Certification_Batch__c = :certificationId.Id];
                
                certificationId.Status__c = 'Rejected';
                update certificationId;
                
                List<Daily_Sale__c> savedDaily = BP_Certification_SCert_Controller.saveDaily(savedDsList,certificationId.Id,'testing OverallComment');
          		
                try{
         	    	List<Daily_Sale__c> savedDailyNull = BP_Certification_SCert_Controller.saveDaily(savedDsList,certificationId.Id,'testing OverallComment');                    
                }catch(Exception e){
                    
                }
            	String certCommAfterSave = BP_Certification_SCert_Controller.getCertificationComm(certificationId.Id);
            Test.stopTest();
            
            Daily_Sales_Certification_Batch__c certification = [SELECT Id, Name, Overall_Comment__c, Period_Start_Date__c, Period_End_Date__c FROM Daily_Sales_Certification_Batch__c];
            List<Daily_Sale__c> selectedDSList = [SELECT Id, Trading_Day_with_date__c, Total_NET_SALES__c, NET_Value_of_Discounts__c, Brand_Reported_Amount__c, Certified_Amount_NetTotal_Input__c, Certified_Amount_Discount_Input__c, Certified_Amount__c, Variance_Amount__c, Certification_Comment__c, MRI_Suite_Id__c FROM Daily_Sale__c WHERE Certification_Batch__c = :certification.Id];
            
            Daily_Sales_Certification_Batch__c certificationDiffName = [SELECT Name, Total_Brand_Reported_Amount__c, Total_Certified_Amount__c, Total_Variance_Amount__c, Overall_Comment__c FROM Daily_Sales_Certification_Batch__c];
            certificationDiffName.Name = 'Total';
            update certificationDiffName;
            
            String expectedCertRange = certification.Period_Start_Date__c.format() + ' - ' + certification.Period_End_Date__c.format();
            
            system.assertEquals(selectedDSList, dailySaleList);
            system.assertEquals(certification.Overall_Comment__c, certCommAfterSave);
            system.assertEquals(certification.Name, nameCert);
            system.assertEquals(expectedCertRange, rangeCert);
        }
    }
}