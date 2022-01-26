@IsTest
Public Class contactTriggerHelperTest{

	@testSetup
	public static void setupData(){

		id accId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
		Account act = new account(Name = 'test Acc 1', Recordtypeid = accId);
		insert act;

		Contact con1 = new contact(AccountId = act.id, FirstName = 'Test1', LastName = 'Test1', email = 'test1@test.com',Primary_Relationship_Contact__c = true);
		Contact con2 = new contact(AccountId = act.id, FirstName = 'Test2', LastName = 'Test2', email = 'test2@test.com');

		list<Contact> obs = new list<Contact>();
		obs.add(con1);
		obs.add(con2);

		try{
		insert obs;
		}
		catch (exception e){
			system.debug('exception ' + e);
		}
	}

	@IsTest
	public static void testOne(){

		Contact con = [SELECT id,Primary_Relationship_Contact__c FROM Contact WHERE email = 'test2@test.com' ];
		con.Primary_Relationship_Contact__c = true;
		test.startTest();
		try{
			update con;
		}
		catch (exception e){
			system.debug('exception ' + e);
			System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
		}
		
		test.stopTest();

	}

	@isTest
    public Static void updateRelatedAccountTest(){
        List<Contact> contactsList = [SELECT id, AccountId, email, RecordtypeId FROM Contact WHERE email = 'test1@test.com' OR email = 'test2@test.com'];
        
        Test.startTest();
        	contactTriggerHelper.updateRelatedAccount(contactsList);
        	contactTriggerHelper.checkDuplicate(contactsList);
        	contactTriggerHelper.populateUniqueKey(contactsList);
        Test.stopTest();
        
        Account acc = [SELECT Id, Last_action_type__c FROM Account WHERE Id = :contactsList[0].AccountId];
        System.assertNotEquals(null, acc.Last_action_type__c, 'Result not as expected.');
    } 
}