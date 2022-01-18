@isTest
public class GuestSearchControllerTest {

	private static final String NEWEMAIL = 'newEmail@mail.pt';

	@TestSetup
	static void init(){

	}

	@isTest
	static void testGuestSearchController(){
		Profile profile = [SELECT Id FROM Profile WHERE Name='HFS Host'];
		User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = profile.Id,
				TimeZoneSidKey='America/Los_Angeles', UserName='newusertest@testorg.com');

		Test.startTest();
		Test.setCurrentPage(Page.GuestSearch);
		new GuestSearchController();

		System.runAs(u2) {
			new GuestSearchController();
		}
		Test.stopTest();
	}

	@isTest
	static void testSearchGuests(){
		Test.startTest();
		GuestSearchController.searchGuests('dfdf');
		Test.stopTest();
	}

	@isTest
	static void testEditEmail(){
		Test.startTest();
		try {
			GuestSearchController.editEmail('88c63302-0120-4d33-bddc-419c2c95c3f0', 'oldEmail@mail.pt', NEWEMAIL);
		} catch(Exception e) {
			System.debug('The following exception has occurred: ' + e.getMessage());
		}
		Test.stopTest();
	}

}