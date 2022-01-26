@isTest
public class ParticipatingBrandTriggerTest{

	@testSetup
	static void testSetup(){
		Village__c village = TestDataGenerator.setupVillage(true);
		Account brand = TestData_Account.setupBrandAccount(6, true);

		Village_Presence__c vp = new Village_Presence__c(Village__c = village.Id, Brand__c = brand.Id);
		INSERT vp;

		Id campaignRecTypeId = Schema.SObjectType.Marketing_Campaign__c.getRecordTypeInfosByDeveloperName().get('Village_Campaign').getRecordTypeId();
		Marketing_Campaign__c marketCamp = new Marketing_Campaign__c();
		
		marketCamp.RecordTypeId = campaignRecTypeId;
        marketCamp.Start_Date__c = Date.today().addDays(-10);
        marketCamp.End_Date__c = Date.today().addDays(10);
        marketCamp.Campaign_Level__c = 'Theme';
        marketCamp.Village__c = village.Id;

        INSERT marketCamp;

  //    Id actRecTypeId = Schema.SObjectType.Marketing_Activity__c.getRecordTypeInfosByName().get('General Activity').getRecordTypeId();
		Id actRecTypeId = Schema.SObjectType.Marketing_Activity__c.getRecordTypeInfosByDeveloperName().get('General_Activity').getRecordTypeId();
        Marketing_Activity__c mAct = new Marketing_Activity__c(RecordTypeId = actRecTypeId,
																Start_Date__c = Date.today().addDays(-10), 
																End_Date__c = Date.today().addDays(10), 
																Marketing_Campaign__c = marketCamp.Id);
		INSERT mAct;
	}

	@isTest
	public static void testCreate(){
		List<Village_Presence__c> vpList = [SELECT Id FROM Village_Presence__c];
		List<Marketing_Activity__c> mActList = [SELECT Id FROM Marketing_Activity__c];

		Participating_Brand__c pBrand = new Participating_Brand__c(Village_Presence__c = vpList.get(0).Id, Marketing_Activity__c = mActList.get(0).Id);

		Test.startTest();
			INSERT pBrand;
		Test.stopTest();

		List<Participating_Brand__c> result = [SELECT Id FROM Participating_Brand__c];
		System.assertNotEquals(null, result, 'Result was not as expected.');
	}

	@isTest
	public static void testUpdate(){
		List<Village_Presence__c> vpList = [SELECT Id FROM Village_Presence__c];
		List<Marketing_Activity__c> mActList = [SELECT Id FROM Marketing_Activity__c];

		Participating_Brand__c pBrand = new Participating_Brand__c(Village_Presence__c = vpList.get(0).Id, Marketing_Activity__c = mActList.get(0).Id);
		INSERT pBrand;

		Test.startTest();
			UPDATE pBrand;
		Test.stopTest();

		List<Participating_Brand__c> result = [SELECT Id, Marketing_Campaign__c FROM Participating_Brand__c];
		System.assertNotEquals(null, result[0].Marketing_Campaign__c, 'Result was not as expected.');
	}
}