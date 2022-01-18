@isTest
public class HFS_CountryControllerTest {

	
	static testmethod void mainTest(){
		
		HFS_Country_Data__c cd1 = new HFS_Country_Data__c (Name='001',HFS_Country_Code__c='ES', HFS_Country_Name__c='Spain', HFS_Default_Option__c=true);
		HFS_Country_Data__c cd2 = new HFS_Country_Data__c (Name='002',HFS_Country_Code__c='UK', HFS_Country_Name__c='United Kingdom', HFS_Default_Option__c=true);
		HFS_Country_Data__c cd3 = new HFS_Country_Data__c (Name='003',HFS_Country_Code__c='DE', HFS_Country_Name__c='Germany', HFS_Default_Option__c=true);
		HFS_Country_Data__c cd4 = new HFS_Country_Data__c (Name='004',HFS_Country_Code__c='RU', HFS_Country_Name__c='United Kingdom', HFS_Default_Option__c=false);
		HFS_Country_Data__c cd5 = new HFS_Country_Data__c (Name='005',HFS_Country_Code__c='AO', HFS_Country_Name__c='Angola', HFS_Default_Option__c=false);
		
		List <HFS_Country_Data__c> cdList = new List <HFS_Country_Data__c> {cd1,cd2,cd3,cd4,cd5};


		insert cdList;

		Test.startTest();

		HFS_CountryController ctrl = HFS_CountryController.getInstance();
		
		system.assertEquals(3, ctrl.getDefaultCountries().size());
		system.assertEquals(2, ctrl.getOtherCountries().size());
		system.assertEquals('Spain', ctrl.getCountryLabel('ES'));
		system.assertEquals('AO', ctrl.getCountryCode('Angola'));

		Test.stopTest();
	
	}
}