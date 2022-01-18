@isTest
public without sharing class HFS_Utils_TEST {
	static testmethod void searchGuests_test(){
		
		Id guestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Guest').RecordTypeId;
		Id vipGuestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('VIP_Guest').RecordTypeId;		

		Account guest1 = new Account();
		guest1.FirstName = 'Test';
		guest1.LastName = 'Test';
		guest1.RecordTypeId = guestRtId;
		guest1.PersonEmail = 'testing@mail.com';
		guest1.Customer_GUID__c = '12345';

		Account guest2 = new Account();
		guest2.FirstName = 'Tom';
		guest2.LastName = 'Tommy';
		guest2.RecordTypeId = guestRtId;
		guest2.PersonEmail = 'testing2@mail.com';
		guest2.Customer_GUID__c = '45678';

		Account vipGuest = new Account();
		vipGuest.FirstName = 'Tom';
		vipGuest.LastName = 'Tommy';
		vipGuest.RecordTypeId = vipGuestRtId;
		vipGuest.PersonEmail = 'testingvip@mail.com';
		vipGuest.Customer_GUID__c = '43338';

		insert new List <Account> {guest1, guest2, vipGuest};
		Test.setFixedSearchResults(new List <Id> {guest1.Id,guest2.Id,vipGuest.Id});
		Test.startTest();

		Map <String, List <Account>> guestsMap = HFS_Utils.searchGuests('testing');

		system.assertEquals(2, guestsMap.get('Guests').size());
		system.assertEquals(1, guestsMap.get('VIP_Guests').size());

		Test.stopTest();
		
	}

	static testmethod void getCurrencyLevelCalculator_test(){

		Village__c bv = TestDataGenerator.setupVillage(false);
		bv.Oracle_Source_Template_Number__c = '123456';
		bv.Oracle_Organisation__c = 'SourceOrg';
		bv.Name = 'Bicester';
		bv.Village_Code__c = 'BV';
		bv.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		bv.CertSales_Report_Sales_Grace_Period_Days__c = 1;

		Village__c lv = TestDataGenerator.setupVillage(false);
		lv.Oracle_Source_Template_Number__c = '123456';
		lv.Oracle_Organisation__c = 'SourceOrg';
		lv.Name = 'Bicester';
		lv.Village_Code__c = 'LV';
		lv.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		lv.CertSales_Report_Sales_Grace_Period_Days__c = 1;
		
		insert new List <Village__c> {bv, lv};

		HFSSpentLevelCalculator calculator = HFS_Utils.getCurrencyLevelCalculator('BV');

		system.assert(calculator instanceof HFSSpentLevelCalculatorBV);

		calculator = HFS_Utils.getCurrencyLevelCalculator('LV');

		system.assert(calculator instanceof HFSSpentLevelCalculatorGeneric);

	}

	static testmethod void searchVIPGuestByEmail ()  {

		Id guestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('VIP_Guest').RecordTypeId;

		Account guest2 = new Account();
		guest2.FirstName = 'Tom';
		guest2.LastName = 'Tommy';
		guest2.RecordTypeId = guestRtId;
		guest2.PersonEmail = 'testing2@mail.com';
		guest2.Customer_GUID__c = '45678';

		insert guest2;
		
		List<Account> vipRecords = HFS_Utils.searchVIPGuestByEmail('testing2@mail.com');
		system.assert(!vipRecords.isEmpty());

	}

	static testmethod void searchPrivilegeGuest_test ()  {

		Id guestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Guest').RecordTypeId;

		Account guest2 = new Account();
		guest2.FirstName = 'Tom';
		guest2.LastName = 'Tommy';
		guest2.RecordTypeId = guestRtId;
		guest2.PersonEmail = 'testing2@mail.com';
		guest2.Customer_GUID__c = '45678';

		insert guest2;
		
		Account guestRecord = HFS_Utils.searchPrivilegeGuest('testing2@mail.com','Tom','Tommy');
		system.assert(guestRecord != null);

	}

}