@isTest
private class VIPBBSearchExtensionTest {

	@TestSetup
	public static void SetupData(){

		Account testAccount = new Account(FirstName = 'John', LastName = 'Smith' , PersonEmail='testemail@mail.com', RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId);
		insert testAccount;
	}

	static testMethod void testGuestSearch() {

		//VIPBBSearchExtension searchext = new VIPBBSearchExtension();
		Test.startTest();
		List<Account> accs = [SELECT ID, Name FROM Account WHERE RecordTypeID = :Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId];
		System.debug('ALL Accounts = ' + accs);

		//Setting the search results

		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = accs[0].Id;
		Test.setFixedSearchResults(fixedSearchResults);


		list<VIPBBSearchExtension.guest> guests = VIPBBSearchExtension.retrieveGuests('John');
		Test.stopTest();

		System.assertEquals(1,guests.size(),'Should be 1 guest returned.' + guests);
	}

	@isTest
	static void createVisitTest(){
		Village__c vill = TestDataGenerator.setupVillage(false);
		vill.Name = 'Bicester';
		INSERT vill;

		Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		User testUser = new User();
		testUser.Village__c = vill.Id;
		testUser.LastName = 'test';
		testUser.Alias = 'tst';
		testUser.Email = 'test@valueretai.com';
		testUser.Username = 'test@valueretai.com';
		testUser.CommunityNickname = 'tstst';
		testUser.ProfileId = sysAdminId;
		testUser.Village__c = 'Bicester';
		testUser.TimeZoneSidKey = 'GMT';
		testUser.LocaleSidKey = 'en_GB';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		INSERT testUser;

		Id guestRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Guest').getRecordTypeId();
		Account userAccount = new Account();
		userAccount.FirstName = 'TestAcc';
		userAccount.LastName = 'TestAcc';
		userAccount.RecordTypeId = guestRType;
		userAccount.Customer_GUID__c = '666';
		INSERT userAccount;

		List<Visit__c> beforeResult = [SELECT Id FROM Visit__c];

		Test.startTest();
		System.runAs(testUser){
			VIPBBSearchExtension.createVisit(userAccount.Id);
		}
		Test.stopTest();

		List<Visit__c> afterResult = [SELECT Id FROM Visit__c];

		System.assertNotEquals(beforeResult, afterResult, 'Results are not as expected.');
	}

	@isTest
	static void UpdateAttendeeStatusTest(){
		Village__c vill = TestDataGenerator.setupVillage(false);
		vill.Name = 'Bicester';
		INSERT vill;

		Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		User testUser = new User();
		testUser.Village__c = vill.Id;
		testUser.LastName = 'test';
		testUser.Alias = 'tst';
		testUser.Email = 'test@valueretai.com';
		testUser.Username = 'test@valueretai.com';
		testUser.CommunityNickname = 'tstst';
		testUser.ProfileId = sysAdminId;
		testUser.Village__c = 'Bicester';
		testUser.TimeZoneSidKey = 'GMT';
		testUser.LocaleSidKey = 'en_GB';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		INSERT testUser;

		Id guestRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
		Account userAccount = new Account();
		userAccount.Name = 'TestAccsd';
		//userAccount.LastName = 'TestAcc';
		userAccount.RecordTypeId = guestRType;
		userAccount.Customer_GUID__c = '666';
		INSERT userAccount;
		
		Contact con1 = new contact(AccountId = userAccount.id, FirstName = 'Test1666', LastName = 'Test1666', email = 'test1@test.com',Primary_Relationship_Contact__c = true);
		//Contact con2 = new contact(AccountId = act.id, FirstName = 'Test2667', LastName = 'Test2667', email = 'test2@test.com');
		insert con1;
		
		List<Visit__c> beforeResultUpdateStatus = [SELECT Id FROM Visit__c];
        Trade_Event__c t = new Trade_Event__c();
        t.Name = 'test';
        t.Event_Date__c = system.today();
        insert t;
        List<Trade_Event_Attendee__c> trade_lst = new list<Trade_Event_Attendee__c>();
        for(integer i=0; i<1; i++) {
            Trade_Event_Attendee__c trade = new Trade_Event_Attendee__c();
            //trade.Name ='test'+i;
            trade.Contact__c = con1.id;
            trade.Trade_Event__c =  t.id;
            trade_lst.add(trade);
        }
		 insert trade_lst;
		Test.startTest();
		System.runAs(testUser){
			VIPBBSearchExtension.UpdateAttendeeStatus(userAccount.Id);
		}
		Test.stopTest();

		List<Visit__c> afterResultUpdateStatus = [SELECT Id FROM Visit__c];

		System.assertNotEquals(beforeResultUpdateStatus, afterResultUpdateStatus, 'Results are not as expected.');
	}

	@isTest
	static void testUpdateVisit(){
		Village__c vill = TestDataGenerator.setupVillage(false);
		vill.Name = 'Bicester';
		insert vill;

		Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		User testUser = new User();
		testUser.Village__c = vill.Id;
		testUser.LastName = 'test';
		testUser.Alias = 'tst';
		testUser.Email = 'test@valueretai.com';
		testUser.Username = 'test@valueretai.com';
		testUser.CommunityNickname = 'tstst';
		testUser.ProfileId = sysAdminId;
		testUser.Village__c = 'Bicester';
		testUser.TimeZoneSidKey = 'GMT';
		testUser.LocaleSidKey = 'en_GB';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		insert testUser;

		Id guestRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Guest').getRecordTypeId();
		Account userAccount = new Account();
		userAccount.FirstName = 'TestAcc';
		userAccount.LastName = 'TestAcc';
		userAccount.RecordTypeId = guestRType;
		userAccount.Customer_GUID__c = '666';
		insert userAccount;

		Id visitVIPRecordTypeId = Schema.SObjectType.Visit__c.getRecordTypeInfosByName().get('VIP Visit').getRecordTypeId();
		Visit__c visit = new Visit__c();
		visit.RecordTypeId = visitVIPRecordTypeId;
		visit.Arrival_Date__c = System.today();
		visit.Village__c = vill.Id;
		visit.Account__c = userAccount.Id;
		insert visit;

		List<Visit__c> beforeResultUpdateStatus = [SELECT id, name, RecordtypeId, Arrival_Date__c,Visit_Date_Time__c FROM Visit__c
		WHERE Account__c=:userAccount.Id AND RecordTypeId=:visitVIPRecordTypeId
		AND Arrival_Date__c=TODAY ORDER BY CreatedDate DESC LIMIT 1];

		System.debug(beforeResultUpdateStatus.size());
		System.debug([SELECT id FROM Visit__c].size());

		Test.startTest();
		System.runAs(testUser){
			VIPBBSearchExtension.updateVisit(userAccount.Id);
		}
		Test.stopTest();
	}
	@isTest
	static void testtodayVisit(){
		Village__c vill = TestDataGenerator.setupVillage(false);
		vill.Name = 'Bicester';
		insert vill;

		Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		User testUser = new User();
		testUser.Village__c = vill.Id;
		testUser.LastName = 'test23';
		testUser.Alias = 'tst34';
		testUser.Email = 'test34@valueretai.com';
		testUser.Username = 'test34@valueretai.com';
		testUser.CommunityNickname = 'tstst34';
		testUser.ProfileId = sysAdminId;
		testUser.Village__c = 'Bicester';
		testUser.TimeZoneSidKey = 'GMT';
		testUser.LocaleSidKey = 'en_GB';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		insert testUser;

		Id guestRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Guest').getRecordTypeId();
		Account userAccount = new Account();
		userAccount.FirstName = 'TestAcc';
		userAccount.LastName = 'TestAcc';
		userAccount.RecordTypeId = guestRType;
		userAccount.Customer_GUID__c = '666';
		insert userAccount;

		Id visitVIPRecordTypeId = Schema.SObjectType.Visit__c.getRecordTypeInfosByName().get('VIP Visit').getRecordTypeId();
		Visit__c visit = new Visit__c();
		visit.RecordTypeId = visitVIPRecordTypeId;
		visit.Arrival_Date__c = System.today();
        visit.Visit_Date_Time__c = system.today();
		visit.Village__c = vill.Id;
		visit.Account__c = userAccount.Id;
		insert visit;

		List<Visit__c> beforeResultUpdateStatus = [SELECT id, name, RecordtypeId, Arrival_Date__c,Visit_Date_Time__c FROM Visit__c
		WHERE Account__c=:userAccount.Id AND RecordTypeId=:visitVIPRecordTypeId
		AND Arrival_Date__c=TODAY ORDER BY CreatedDate DESC LIMIT 1];

		System.debug(beforeResultUpdateStatus.size());
		System.debug([SELECT id FROM Visit__c].size());

		Test.startTest();
		System.runAs(testUser){
			VIPBBSearchExtension.updateVisitRecord(userAccount.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(visit);
            VIPBBSearchExtension v = new VIPBBSearchExtension(sc);
            v.getVisitInfo();
            Visit__c v1 = v.getvisitRecordInfo();
           
		}
		Test.stopTest();
	}
    
	
	
}