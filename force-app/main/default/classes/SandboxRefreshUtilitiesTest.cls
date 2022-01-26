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
private class SandboxRefreshUtilitiesTest {

    static testMethod void chatterGroupTest() {
        
        VR1_Chatter_Groups__c grp1 = new VR1_Chatter_Groups__c(name='Test1', Group_Name__c = 'Test1');
        insert grp1;
        
        VR1_Chatter_Groups__c grp2 = new VR1_Chatter_Groups__c(name='Test2', Group_Name__c = 'Test2');
        insert grp2;
        
        test.startTest();
        	
        	SandboxRefreshUtilities.loadChatterGroups();
        

        
	        list<CollaborationGroup> grpList = [select Id, Name from CollaborationGroup 
	        										where Name Like 'Test%'
	        										order by Name Asc];
	        
	        system.assertEquals(grpList.size(), 2);
	        system.assertEquals(grpList[0].Name, 'Test1');
	    
	        // test error
	        VR1_Chatter_Groups__c grp3 = new VR1_Chatter_Groups__c(name='Test3', Group_Name__c = 'Test1');
	        insert grp3;
	
			grpList = [select Id, Name from CollaborationGroup 
	        										where Name Like 'Test%'
	        										order by Name Asc];
	        
	        SandboxRefreshUtilities.loadChatterGroups();
	        
	        system.assertEquals(grpList.size(), 2);
        
		test.stopTest();    
        
    }
    
    static testMethod void villageDataTest(){
    	
    	Village__c village = new Village__c(Name = 'Test1', Village_Code__c = 'V1', Currency__c = 'EUR', Village_Local_Language__c = 'Italian',CertSales_CertPeriod_Cut_Off_Days__c = 1, CertSales_Report_Sales_Grace_Period_Days__c = 1);
    	insert village;
    	
    	test.startTest();
    		SandboxRefreshUtilities.refreshVillageRefData();
    	test.stopTest();
    	
    	list<Village_Reference_Data__c> dataList = Village_Reference_Data__c.getall().values();
    	system.assertEquals(dataList.size(), 1);
    	system.assertEquals(dataList[0].Name, village.Name);
    	system.assertEquals(dataList[0].MRI_Code__c, village.Village_Code__c);
    	
    }
}