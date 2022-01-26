@isTest
public class EmailMyselfThePaidMarketingTest {

    @testSetup
    public static void Setup(){
    
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
        
        Account account = TestData_Account.setupTourismAccount(1, true);
        
        Profile pf = [select Id from Profile where name = 'Tourism'];
        
        RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            
            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;
        
            RecordType brandContactRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand Contact'];
        
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
        
        //NewUser
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User newUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='Emarck@testorg.com',
            Village__c ='Bicester'   
            
        );
        insert newUser;
        
          //newAccount
        Account  newAcc = new Account(
            RecordTypeId = '012b0000000ar4wAAA',
            name='teste',
            Country__c ='Albania',
            Type_of_Business__c ='Airline'  
        );
        insert newAcc;
        
         //New Village
        Village__c newVillage = new Village__c(
            Name= 'Test',
            Village_Code__c= '1',
            Currency__c= 'EUR',
            CertSales_CertPeriod_Cut_Off_Days__c = 1,
            CertSales_Report_Sales_Grace_Period_Days__c = 1
        );    
        insert NewVillage;
        
          //New  Marketing Campaign 
        
        Marketing_Campaign__c newCampaign = new Marketing_Campaign__c(
            Name= 'Test',
            Short_Description__c= 'XPTO',
            Campaign_Level__c= 'THEME',
            Village__c= NewVillage.Id,
            //Status__c= 'To Be Confirmed',
            Status__c= 'To be Approved',
            Start_Date__c= system.today(),
            End_Date__c= system.today(),
            CurrencyIsoCode= 'GBP',
            //Responsible_Person__c= 'XPTO',
            Responsible__c= newUser.id,
            //Accountable__c= 'XPTO',
            Accountable_Person__c = newUser.id,
            Proposition__c= 'XPTO',
            Target_Audience__c= 'XPTO',
            KPI_Targets__c= 'XPTO'
            
            );
        insert newCampaign;
        
         
        
       }
    }
    
    @isTest
    static void TestSendEmailPaidMarketing(){
          
        Marketing_Campaign__c  camp = [SELECT Id,  Name FROM Marketing_Campaign__c]; 
        Account  acc = [SELECT Id, Name FROM Account LIMIT 1];
        User us= [SELECT Id, email FROM user WHERE Username = 'john@valueretai.com'];
        
         //New  Marketing Activity
        Marketing_Activity__c newMarketing = new Marketing_Activity__c(
            Name = 'Test',
            Business_Function__c = 'Local Tourism',
            Channel__c = 'CRM',
            Sub_Channel__c = 'Blogger',
            Marketing_Campaign__c    = camp.Id,
            //Status__c    = 'To Be Confirmed',
            Status__c    = 'To be Approved',
            Start_Date__c = system.today(),   
            End_Date__c = system.today(),     
            Partner__c = acc.Id,
            //Accountable__c = 'Test',
            Accountable1__c = us.Id,
            Responsible_Person__c = us.Id,
            Creative_Agency_Access_To_Salesforce__c = us.id            
            );
        
          insert newMarketing;
          Test.startTest();
          PageReference pageRef = Page.SendEmailMySelfMarketingActivityPage;
          Test.setCurrentPage(pageRef); 
          
         String newMarckId = newMarketing.id;
          Marketing_Activity__c marck = [SELECT Id, Name, Business_Function__c, Channel__c, Sub_Channel__c, Marketing_Campaign__c, Status__c, Start_Date__c,
                                       End_Date__c, Partner__c, Accountable1__c, Responsible_Person__c FROM Marketing_Activity__c where id=:newMarckId];
        
         
        ApexPages.currentPage().getParameters().put('id',newMarckId);
        ApexPages.StandardController con = new ApexPages.StandardController(marck);
        EmailMyselfThePaidMarketingController controller = new EmailMyselfThePaidMarketingController(con);
       
        try{
       
            controller.sendEmailMySelfMarketingActivity();
               
        }catch(Exception e){
             system.debug('' + e);
            System.assert(String.isBlank(String.valueOf(e)) );
        }
     
       
       
                   
 }
}