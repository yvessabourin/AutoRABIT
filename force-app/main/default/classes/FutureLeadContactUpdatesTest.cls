@isTest
private class FutureLeadContactUpdatesTest{

	private static Account account = new Account();
	private static Contact contact = new Contact();
	private static Village__c village = new Village__c();
	private static Opportunity opportunity = new Opportunity();
	private static Lead lead = new Lead();
	private static Lead lead2 = new Lead();
	
    
    static void setupData(){
    
		account = TestData_Account.setupTourismAccount(1, true);
					
 		village = new Village__c();
 		village.Name = 'TestVillage1'; 		
 		village.Village_Code__c = 'AA';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
 		insert village;

 		id LeadRTID = Schema.SObjectType.Lead.RecordTypeInfosByName.get('Group Booking Lead').RecordTypeId;
 		lead.firstName = 'John';
 		lead.lastName = 'Test';
 		lead.company = 'test';
 		lead.email = 'testA@valueretail.com';
 		lead.LeadSource = 'Village Registration Card';
 		lead.recordtypeid = LeadRTID;
 		lead.HasOptedOutOfEmail = true;

 		lead2.firstName = 'Paul';
 		lead2.lastName = 'Test2';
 		lead2.company = 'test2';
 		lead2.email = 'test2A@valueretail.com';
 		lead2.LeadSource = 'Village Registration Card';
 		lead2.recordtypeid = LeadRTID;
 		lead2.HasOptedOutOfEmail = false;

 		insert lead;
 		insert lead2;

    }


    static testMethod void unitTest() {
    	
    	setupData();

    	list<lead> leads = [SELECT id, Name FROM Lead];
	    // and add it to the list of lead conversions to be executed.
	    List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
	    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
	        
	    FOR (Lead cLead : leads)
	    {
	        Database.LeadConvert lc = new database.LeadConvert();
	        lc.setConvertedStatus( convertStatus.MasterLabel );
	        lc.setLeadId(cLead.id);
	        lc.setDoNotCreateOpportunity(True);
	        leadConversions.add(lc);
	    }

	    // reset the limits
	    test.startTest();
	    // Convert the Lead records that cause the trigger to execute
	        Database.convertLead(leadConversions);   
	    // Stop the test, this changes limit context back to test from trigger.
	    test.stopTest();

	    list<contact> con1 = [select id,Name,email,HasOptedOutOfEmail FROM contact WHERE email = 'testA@valueretail.com'];
	    list<contact> con2 = [select id,Name,email,HasOptedOutOfEmail FROM contact WHERE email = 'test2A@valueretail.com'];

	    system.assert(con1[0].HasOptedOutOfEmail == false, 'error1');
	    system.assert(con2[0].HasOptedOutOfEmail == true, 'error2');




    }

}