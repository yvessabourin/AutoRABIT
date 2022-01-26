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
private class displayImageExtensionTest {

    static testMethod void myUnitTest() {
		
		Account testAcc = TestData_Account.setupBrandAccount(1, true);
		string accId = testAcc.Id;

		Attachment a1 = new Attachment(Name='test.jpg', ParentId = accId, body = blob.valueOf('test1'));
		insert a1;
		
		Attachment a2 = new Attachment(Name='test.png', ParentId = accId, body = blob.valueOf('test2'));
		insert a2;
		
		attachment a3 = new Attachment(Name='test.txt', ParentId = accId, body = blob.valueOf('test3'));
		insert a3;
		
		test.startTest();
		
		test.setCurrentPageReference(new PageReference('Page.TweetImages')); 		
		ApexPages.StandardController stdCont=new ApexPages.StandardController(testAcc);
	
		displayImageExtension testController = new displayImageExtension(stdCont);

		list<string> fileList = testController.getFileIds();
		
		test.stopTest();
		
		system.assertEquals(fileList.size(), 2);
		

		
    }
}