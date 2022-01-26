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
private class RetailLivePostTest {


	private static Account account = new Account();
	private static Account account2 = new Account();
	private static Contact contact = new Contact();
	private static Contact contact2 = new Contact();
	private static Village__c village1 = new Village__c();
    private static Village_Presence__c villagePresence = new Village_Presence__c();
    
    static void setupData(){
    
		account = TestData_Account.setupBrandAccount(1, true);
		account2 = TestData_Account.setupBrandAccount(2, true);
		contact = TestData_Contact.setupBrandContact('A',account, true);	
		contact2 = TestData_Contact.setupBrandContact('B',account2, true);
					
 		//create village 1
 		village1 = new Village__c();
 		village1.Name = 'TestVillage1'; 		
 		village1.Village_Code__c = 'AA';
		village1.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village1.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
 		insert village1;
		village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];   	

		villagePresence = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);
    
    }

    static testMethod void unitTest() {
       
 		setUpData();
    	
    	PageReference pg = new PageReference('Page.RetailLivePostAction');
		test.setCurrentPageReference(pg);
		contact = [select Id, Name, email from Contact where Id = :contact.Id];
		account = [select No_Whitespace_Name__c from Account where Id =:account.Id];
 		
 		test.startTest();	
			ApexPages.StandardController controller = new ApexPages.StandardController(villagePresence);
			
			RetailLivePost retailLive = new RetailLivePost(controller);
		
			
			List<SelectOption> accountContacts = retailLive.AccountContacts;
			
			system.assertEquals(accountContacts.size(), 1);
			system.assertEquals(accountContacts[0].getValue().toUpperCase(), contact.email.toUpperCase());
			
			RetailLivePost.sf1Data dataValues = new RetailLivePost.sf1Data();
			
			dataValues.toList = new list<string>{contact.email};		
			dataValues.ccList = new list<string>{'cc@test.com'};
			dataValues.bccList = new list<string>{'bcc@test.com'};
			dataValues.villageCode = village1.Village_Code__c;
			dataValues.brandName = account.No_Whitespace_Name__c;
			dataValues.villagePresenceId = villagePresence.Id;
			dataValues.subjectText = 'Test Message';
			string returnVal = RetailLivePost.postRetailLive(dataValues);
			
			//send again
			// create vp role for contact 2 (unrelated account)
			Village_Presence_Contact_Role__c vpRole = new Village_Presence_Contact_Role__c(Contact__c = contact2.Id, 
																							Village_Presence__c = villagePresence.Id);
																							
			insert vpRole;
			dataValues.toList = new list<string>{contact.email, contact2.email};
			dataValues.subjectText = 'Test Message 2';
			returnVal = RetailLivePost.postRetailLive(dataValues);

			//send again
			dataValues.toList = new list<string>{contact.email, contact2.email};
			dataValues.subjectText = 'Test Message 3';
			returnVal = RetailLivePost.postRetailLive(dataValues);
			
		test.stopTest(); 
		
		system.assertEquals(returnVal, 'Success');      
    	
    	list<Village_Presence_Contact_Role__c> vpRoleList  = [select Id, Contact__c from Village_Presence_Contact_Role__c 
    														where Village_Presence__c = :villagePresence.Id
    														and contact__c in :new list<string>{contact.Id, contact2.id}];
    	system.assertequals(vpRoleList.size(), 2);
    	
    
    }
    
 	static testMethod void unitTest2() {
       
 		setUpData();

		contact = [select Id, Name, email from Contact where Id = :contact.Id];
		account = [select No_Whitespace_Name__c from Account where Id =:account.Id];
 		
 		test.startTest();	

			// add vp role before invoking
			Village_Presence_Contact_Role__c vpRole = new Village_Presence_Contact_Role__c(Contact__c = contact.Id, 
																							Village_Presence__c = villagePresence.Id,
																							Receive_Retail_LIVE__c = true);		    
 			insert vpRole;

			ApexPages.StandardController controller = new ApexPages.StandardController(villagePresence);
			
			RetailLivePost retailLive = new RetailLivePost(controller);
			 			
 			RetailLivePost.sf1Data dataValues = new RetailLivePost.sf1Data();
			
			dataValues.toList = new list<string>{contact.email};
			dataValues.villageCode = village1.Village_Code__c;
			dataValues.brandName = account.No_Whitespace_Name__c;
			dataValues.villagePresenceId = villagePresence.Id;
			dataValues.subjectText = 'Test Message';
			dataValues.publicReplies = false;
			string returnVal = RetailLivePost.postRetailLive(dataValues);		
 			
 		test.stopTest();
 		
 		system.assertEquals(returnVal, 'Success');
 		
 	}
 
 
  	static testMethod void unitTest3() {
       
 		setUpData();
 		
 		//force an error
 		test.startTest();	

			ApexPages.StandardController controller = new ApexPages.StandardController(villagePresence);
			
			RetailLivePost retailLive = new RetailLivePost(controller);
			 			
 			RetailLivePost.sf1Data dataValues = new RetailLivePost.sf1Data();
			
			dataValues.toList = null; //force error
			dataValues.villageCode = village1.Village_Code__c;
			dataValues.brandName = account.No_Whitespace_Name__c;
			dataValues.villagePresenceId = villagePresence.Id;
			dataValues.subjectText = 'Test Message';
			dataValues.publicReplies = false;
			string returnVal = RetailLivePost.postRetailLive(dataValues);		
 			
 		test.stopTest();
 		
 		system.assert(returnVal.indexOf('A technical error has occurred') > -1);
 		
 	}


  	static testMethod void unitTest4() {
       
 		setUpData();
 		
 		// test attachments
 		
 		test.startTest();	

			ApexPages.StandardController controller = new ApexPages.StandardController(villagePresence);
			
			RetailLivePost retailLive = new RetailLivePost(controller);
			 			
 			RetailLivePost.sf1Data dataValues = new RetailLivePost.sf1Data();
			
			dataValues.toList = new list<string>{contact.email};
			dataValues.villageCode = village1.Village_Code__c;
			dataValues.brandName = account.No_Whitespace_Name__c;
			dataValues.villagePresenceId = villagePresence.Id;
			dataValues.subjectText = 'Test Message';
			dataValues.publicReplies = false;
			
			//Add attachment

			Document d = new Document(); 
			d.Name = 'text file'; 
			string myContent = 'text file text contents';			
			blob body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(blob.valueOf(myContent)));  
			d.Body =  body;
			d.ContentType = 'text/plain';
			d.Type = 'txt';
			d.FolderId = UserInfo.getUserId();
			insert d;

			string returnVal1 = RetailLivePost.uploadAttachment(EncodingUtil.base64Encode(blob.valueOf(myContent)), d.Name, d.Id);			
			string returnVal2 = RetailLivePost.postRetailLive(dataValues);		
 			
 		test.stopTest();
 		
 		system.assertEquals(returnVal2, 'Success');
 		system.assertEquals(returnVal1, d.Id);
 	}
    
}