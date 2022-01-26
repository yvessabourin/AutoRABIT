/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProfileTabUserControllerTest {

    static testMethod void unitTest() {

		// Create test user
 		User usr = TestData_User.setupAdminUser(true);
 		

   		PageReference pg = new PageReference('Page.userprefs');
		pg.getParameters().put('sfdc.userId', usr.Id);     	
		
		test.setCurrentPageReference(pg);

		test.startTest();

			ApexPages.StandardController controller = new ApexPages.StandardController(usr);
		
			ProfileTabUserController profileTab = new ProfileTabUserController(controller);

			usr.Receive_B2B_Emails__c = true;
			
			pg = profileTab.save();
			
			usr.Receive_Weekly_B2B_Emails__c = true;
			
			pg = profileTab.cancel();
		
		test.stopTest();
		
		usr = [select Receive_B2B_Emails__c, Receive_Weekly_B2B_Emails__c from User where Id = :usr.Id];
		
		system.assert(usr.Receive_B2B_Emails__c); // check value true
		system.assertEquals(usr.Receive_Weekly_B2B_Emails__c, false); //check value still false
		
    }
}