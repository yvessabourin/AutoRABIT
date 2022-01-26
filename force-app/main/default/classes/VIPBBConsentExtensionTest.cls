@isTest
public class VIPBBConsentExtensionTest {

	@TestSetup
	public static void setup(){
		Id recordTypeGuesId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Guest').getRecordTypeId();
		Account account = new Account();
		account.FirstName = 'TestAcc';
		account.LastName = 'TestAcc';
		account.RecordTypeId = recordTypeGuesId;
		account.Customer_GUID__c = '666';
		insert account;

		Village__c vill = TestDataGenerator.setupVillage(false);
		vill.Oracle_Source_Template_Number__c = '123456';
		vill.Oracle_Organisation__c = 'SourceOrg';
		vill.Name = 'Bicester';
		vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
		vill.Village_Code__c = 'LV';
		insert vill;

		Case guestCase = new Case();
		guestCase.Village__c = vill.Id;
		guestCase.Service_Guest_ID__c = '123456789';
		guestCase.Service_Guest_Number__c = 'XA1';
		guestCase.Guest_ID_Number_Part__c = 12;
		guestCase.Payment_Status__c = 'Paid';
		guestCase.Client_QR_Code__c = '123456789';
		guestCase.Status = 'New';
		guestCase.Origin = 'Email';
		insert guestCase;
	}

	@isTest
	static void testController(){
		PageReference pageRef = Page.VIPBBConsent;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController standardController = new ApexPages.StandardController(getAccount());
		VIPBBConsentExtension vipbbConsentExtension = new VIPBBConsentExtension(standardController);
	}

	@isTest
	static void testSaveGuest(){
		VIPBBConsentExtension.saveGuest('', 'FirstNameTest', 'LastNameTest', 'emailTest@mail.pt', null, [SELECT Id FROM Case LIMIT 1].Id, null, null, 'Male', null, false, null, null);
	}

	@isTest
	static void testSaveGuestNew(){
		VIPBBConsentExtension.saveGuest(getAccount().Id, 'FirstNameTest', 'LastNameTest', 'emailTest@mail.pt', null, null, null, null, 'Male', null, false, null, null);
	}

	@isTest
	static void testGetLanguageLabels(){
		String language = 'en';

		Custom_Label__c customLabel = new Custom_Label__c();
		customLabel.Name = 'CancelButton';
		customLabel.Custom_Label_Value__c = 'TestButton';
		customLabel.Language__c = language;
		customLabel.Used_in_App__c = 'HFS';
		customLabel.Used_on_page__c = 'HFSGuestCheckOutPage';
		insert customLabel;

		VIPBBConsentExtension.getLanguageLabels(language);
	}

	@isTest
	static void testSearchDuplicates(){
		VIPBBConsentExtension.searchDuplicates('', '', 'test@mail.pt', '9111111111');
		VIPBBConsentExtension.searchDuplicates('', '', 'test@mail.pt', '');
		VIPBBConsentExtension.searchDuplicates('', '', '', '');
	}

	@isTest
	static void testSearchPartner(){
		VIPBBConsentExtension.searchPartner('test');
	}

	private static Account getAccount() {
		return [SELECT Id, Partner_Program_Membership_1__c FROM Account LIMIT 1];
	}
}