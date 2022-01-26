@isTest
public class DisableCustomeruserControllerTest {

    private static Account account = new Account();
    private static list<Account> accountList = new list<Account>();
	private static Contact contact = new Contact();
    private static list<Contact> contactList = new list<Contact>();
	private static User usr1 = null;
    private static User usr2 = null;
    
    static void setupData(){	
        
        Profile pf = [select Id from Profile where name = 'Brand Community Plus User'];
        Profile pf2 = [select Id from Profile where name = 'System Administrator'];
        UserRole ur = [select id from UserRole where name = 'CEO'];
        
        // create Admin user
        usr2 = TestData_User.setupAdminUser(true);
        usr2 = [Select UserRoleId from User where Id = :usr2.id];
        usr2.UserRoleId = ur.Id;
        update usr2;
        
        string dateString = string.valueOfGmt(system.today());
        dateString = dateString.split(' ')[0].replace('-', '');        
        
        system.runAs(usr2) {
            
            for (integer i = 1; i < 5; i++){
                account = TestData_Account.setupBrandAccount(i, true);
                contact = TestData_Contact.setupBrandContact('A' + i,account, true);
                accountList.add(account);
                contactList.add(contact);
            }
            account = accountList[0];
            contact = contactList[0];
            
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

    static testmethod void testDisable(){
        
        setupData();
        
        string result1 = DisableCustomeruserController.getCustomerStatus(contact.Id);
        system.assertEquals(result1, 'Active');
        
        string result2 = DisableCustomeruserController.updateCustomerUser(contact.Id, false);
        system.assert(result2.indexOf('disabled') > -1);
        
    }

    static testmethod void testEnable(){
        
        setupData();
        
        usr1 = [select IsActive from User where Id = :usr1.Id];
        usr1.IsActive = false;
        update usr1;

        string result1 = DisableCustomeruserController.getCustomerStatus(contact.Id);
        system.assertEquals(result1, 'InActive');
        
        string result2 = DisableCustomeruserController.updateCustomerUser(contact.Id, true);
        system.assert(result2.indexOf('enabled') > -1);        
        
        
    }

    static testmethod void testNullUser(){
        
        setupData();
        
        Contact contact2 = contactList[1];
		string result1 = DisableCustomeruserController.getCustomerStatus(contact2.Id);
        system.assertEquals(result1, 'Null');        

        string result2 = DisableCustomeruserController.updateCustomerUser(contact2.Id, true);
      
    }
    
}