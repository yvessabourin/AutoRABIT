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
private class OperationalIncidentTriggerHelperTest {

	private static User usr = new User();
	private static User usr2 = new User();
	private static User usr3 = new User();
	private static User usr4 = new User();
	private static Operations_Department__c opDept = new Operations_Department__c();
	private static Operations_Department__c defaultDept = new Operations_Department__c();
	
	static void setupData(){

		// Create test admin user
 		User adminUsr = TestData_User.setupUser('AdminUser', null, 'System Administrator', true, true);
		
		// Create test normal user
		usr = TestData_User.setupUser('BillyBones', null, 'Standard User', true, true);
		usr.Village__c = 'TestVillage';
		update usr; 
		
		// Create test admin user
 		usr2 = TestData_User.setupAdminUser(true);
		
		// Create another test admin user 
 		usr3 = TestData_User.setupUser('sa', null, 'System Administrator', true, true);
		
		usr4 = TestData_User.setupUser('JackMack', null, 'Standard User', true, true);
		
		system.runAs(adminUsr){
			// create default operations dept
			defaultDept = new Operations_Department__c();
			defaultDept.Escalation_point_1__c = usr2.Id;
			defaultDept.Escalation_point_2__c = usr3.Id;
	        defaultDept.Escalation_point_3__c = usr3.Id;
			defaultDept.Village__c = 'TestVillage';
			defaultDept.P1_Offset_Days__c = 1;
			defaultDept.P2_Offset_Days__c = 2;
			defaultDept.P3_Offset_Days__c = 3;
			defaultDept.Department__c = 'Test Default Department';
			insert defaultDept;
			
	
			// create operations dept
			opDept = new Operations_Department__c();
			opDept.Escalation_point_1__c = usr.Id;
			opDept.Escalation_point_2__c = usr3.Id;
	        opDept.Escalation_point_3__c = usr4.Id;
			opDept.Village__c = 'TestVillage';
			opDept.P1_Offset_Days__c = 1;
			opDept.P2_Offset_Days__c = 2;
			opDept.P3_Offset_Days__c = 3;		
			opDept.Department__c = 'Test Op Department';
			insert opDept;		
	
			VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getOrgDefaults();
			if (settings != null) {
				settings.Default_Operations_Department__c = defaultDept.Id;
			} else {
				settings = new VR1_Configuration_Settings__c();
				settings.Default_Operations_Department__c = defaultDept.Id;
			}
			upsert settings;
		}
	}
	
    static testMethod void testValidCategory() {
		
		setupData();
		
		Operational_Incident__c incident = new Operational_Incident__c();
		incident.Category__c = opDept.Department__c;
		incident.Reported_By__c = usr.Id;
		incident.Description__c = 'Test';
		incident.Priority__c = 'P2';
		incident.Status__c = 'Not Started';
		incident.Name = 'Test1';
		
		test.startTest();
			System.runAs(usr) {
				insert incident;
			}
		test.stopTest();
		
		incident = [select Operations_Department__c from Operational_Incident__c where Id = :incident.Id];
		system.assertEquals(incident.Operations_Department__c, opDept.Id); 
		
    }

    static testMethod void testDefaultDept() {
		
		setupData();
		
		Operational_Incident__c incident = new Operational_Incident__c();
		incident.Category__c = 'Something Random';
		incident.Reported_By__c = usr.Id;
		incident.Description__c = 'Test';
		incident.Priority__c = 'P2';
		incident.Status__c = 'Not Started';		
		incident.Name = 'Test1';
		
		test.startTest();
			System.runAs(usr) {
				insert incident;
			}
		test.stopTest();
		
		incident = [select Operations_Department__c from Operational_Incident__c where Id = :incident.Id];
		system.assertEquals(incident.Operations_Department__c, defaultDept.Id);

    }    
    
}