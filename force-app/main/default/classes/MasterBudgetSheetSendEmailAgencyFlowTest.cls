@isTest
public class MasterBudgetSheetSendEmailAgencyFlowTest {

	@TestSetup
	static void init(){
		SubmitToAgencyMBSControllerUtility.testSetup();
	}

	@isTest
	static void testSendEmailAgency (){
		Master_Budget_Sheet__c newMBS = [SELECT Id, Name, Creative_Agency_1__c, Creative_Agency_2__c, Creative_Agency_3__c,
		Creative_Agency_4__c, Creative_Agency_5__c, Creative_Agency_6__c,
		Creative_Agency_7__c, Creative_Agency_8__c, Budget_Village__c
		FROM Master_Budget_Sheet__c WHERE Name = 'MBS Test' LIMIT 1];

		Test.startTest();
		MasterBudgetSheetSendEmailAgencyFlow.sendEmailAgency(new List<Master_Budget_Sheet__c>{ newMBS });
		Test.stopTest();
	}

}