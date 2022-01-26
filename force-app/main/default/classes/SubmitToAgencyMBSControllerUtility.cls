@isTest
public class SubmitToAgencyMBSControllerUtility{
	
    public static void testSetup(){

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
        
    
        List<Contact> communityContacts = new List<Contact>();
        for(Integer i = 0; i <= 7; i++){
            Contact communityContact = new Contact();           
            communityContact.RecordTypeId = brandContactRecordType.Id;
            communityContact.LastName = 'John';
            communityContact.AccountId = brand.Id;
            communityContact.Village_Presence__c = 'Bicester';
            communityContact.Email = 'testcommunity'+i+'.contact@brand.com';
            communityContacts.add(communityContact);
        }    
        insert communityContacts;
        
        Profile profileCommunity = [SELECT ID, Name FROM Profile WHERE Name = 'Third Party Community User'];
        
        List<User> communityUsers = new List<User>();
        
        for(Integer i = 0; i <= 7; i++){
            User communityUser = new User();
            communityUser.LastName = communityContacts.get(i).LastName;
            communityUser.Alias = 'jhn';
            communityUser.Email = communityContacts.get(i).Email;
            communityUser.Username = 'john'+i+'@valueretai.com';
            communityUser.CommunityNickname = 'johnvr'+i;
            communityUser.ProfileId = profileCommunity.Id;
            communityUser.Village__c = 'Bicester';
            communityUser.TimeZoneSidKey = 'GMT';
            communityUser.LocaleSidKey = 'en_GB';
            communityUser.EmailEncodingKey = 'ISO-8859-1';
            communityUser.LanguageLocaleKey = 'en_US';
            communityUser.ContactId = communityContacts.get(i).Id;
            communityUser.PortalRole = 'Manager';
            communityUsers.add(communityUser);
        }
            
        insert communityUsers;
             
         //New Village
        Village__c newVillage = new Village__c(
            Name= 'Test',
            Village_Code__c= '1',
            Currency__c= 'EUR',
            CertSales_CertPeriod_Cut_Off_Days__c = 1,
            CertSales_Report_Sales_Grace_Period_Days__c = 1
        );    
        Insert NewVillage;       
       
        Village__c  village = [SELECT Id, Name FROM Village__c LIMIT 1];
        List<User> us = [SELECT Id, Email FROM user WHERE Username = 'john0@valueretai.com' OR Username = 'john1@valueretai.com' OR Username = 'john2@valueretai.com'
                         OR Username = 'john3@valueretai.com' OR Username = 'john3@valueretai.com' OR Username = 'john4@valueretai.com'
                         OR Username = 'john5@valueretai.com' OR Username = 'john6@valueretai.com' OR Username = 'john7@valueretai.com' ];
        
         //New  Marketing Activity
        Master_Budget_Sheet__c newMBS = new Master_Budget_Sheet__c(
            Name= 'MBS Test',
            Budget_Village__c= village.Id,
            Creative_Agency_1__c= us.get(0).Id,
            Creative_Agency_2__c= us.get(1).Id,
            Creative_Agency_3__c= us.get(2).Id,
            Creative_Agency_4__c= us.get(3).Id,
            Creative_Agency_5__c= us.get(3).Id,
            Creative_Agency_6__c= us.get(3).Id,
            Creative_Agency_7__c= us.get(3).Id,
            Creative_Agency_8__c= us.get(3).Id,
            Month__c = 'June'
        );
        Insert newMBS;
       
       }

    }

}