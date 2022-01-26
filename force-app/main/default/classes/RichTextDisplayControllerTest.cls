@isTest
private class RichTextDisplayControllerTest {

	private static Account account = new Account();
    private static list<Account> accountList = new list<Account>();
	private static Contact contact = new Contact();
    private static list<Contact> contactList = new list<Contact>();
	private static User usr1 = null;
    private static User usr2 = null;
    private static Village__c village1 = new Village__c();
    private static Unit__c unit1 = new Unit__c();
    private static string labelName = '$Label.DAILY_SALE_NO_CONFIRM_RECORDS';

    private static Village_Presence__c vp1;

    private static list<Village_Presence__c> vpList = new list<Village_Presence__c>();
    private static Village_Presence_Contact_Role__c vpcr1;
        
    static void setupData(){	
		
        Profile pf = [select Id from Profile where name = 'Brand Community Plus User'];
		Profile pf2 = [select Id from Profile where name = 'System Administrator'];
        UserRole ur = [select id from UserRole where name = 'CEO'];
        
        // create Admin user
        usr2 = TestData_User.setupAdminUser(true);
		usr2 = [Select UserRoleId from User where Id = :usr2.id];
        usr2.UserRoleId = ur.Id;
        update usr2;
   
        
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
            village1.Daily_Sales_Message__c = '<b>hello world</b>';
			village1.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			village1.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
            insert village1;
            village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];   	

            
            // create unit2
            unit1 = new Unit__c(Name = 'AAA', Village__c = village1.Id, Phase_Id__c = 'P1', Suite_Id__c = 'S1', Size_GEA__c = 100);
            insert unit1;
            unit1 = [select Name, MRI_Unit_Id__c from Unit__c where Id = :unit1.Id];

            
            vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);
            vp1 = [select Id, name, Status__c, Daily_Sales_Active__c, Brand__c, Unit__c from Village_Presence__c where Id = :vp1.Id];
            vp1.status__c = 'Trading';
            vp1.Daily_Sales_Active__c = true;
            vp1.Brand__c = account.Id;
            vp1.Unit__c = unit1.Id;
            update vp1;
            vpcr1 = new Village_Presence_Contact_Role__c(Daily_Sales_Active_From__c = system.today().addDays(-1), Contact__c = contact.Id, 
                                                         	Confirm_Daily_Sales_Records__c = true, Village_Presence__c = vp1.id);
            insert vpcr1;
            

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
    static testMethod void unitTest() {
		
		setupData();
		
		system.runAs(usr1){
			
			test.startTest();
			
			RichTextDisplayController.userVillage uv = RichTextDisplayController.getCurrentUserDetails();
			system.debug('@@@ uv ' +  uv);
			system.assertEquals(uv.User.Id, usr1.Id);
			
			string label = RichTextDisplayController.getLabel(labelName,'en');
			system.assertEquals(label, '{"$Label.DAILY_SALE_NO_CONFIRM_RECORDS":"UNIT.TEST"}');
			
			test.stopTest();
			
			
		}
        
    }
}