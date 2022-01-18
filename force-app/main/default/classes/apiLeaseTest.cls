@isTest
public class apiLeaseTest {

    private static Account account = new Account();
    private static API_Configuration__c settings = new API_Configuration__c();
    private static MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
    private static Village__c village1 = new Village__c();
    private static string dateString = '';
    
    static void setupData(){

		account = TestData_Account.setupBrandAccount(1, true);
        
        //create village 1
        village1 = new Village__c();
        village1.Name = 'TestVillage1'; 		
        village1.Village_Code__c = 'AA';
		village1.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village1.CertSales_Report_Sales_Grace_Period_Days__c = 1;
        insert village1;
        village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];   	
               
		dateString = string.valueOfGmt(system.today());
        dateString = dateString.split(' ')[0].replace('-', '');
        
        setupCustomSettings();
        
    }    
    
	static void setupCustomSettings(){

		settings.name = 'API Config LIVE';
    	settings.Api_host__c = 'https://test.apiCustomer.com';
    	settings.Api_key__c = '123456';
    	settings.Customer_create__c = '/createCustomer';
    	settings.Customer_read_GUID__c = '/readCustomer';
    	settings.Debug_mode__c = true;
    	settings.Enum_read__c = '/enumRead';
    	settings.Lookup_read__c = '/lookupRead';
    	settings.Preference_create__c = '/prefCreate';
    	settings.Preference_read__c = '/prefRead';
    	settings.Email_Change__c = '/emailChange';
        settings.Lease_List__c = '/leaseList';

    	insert settings;				
	}
    
    static testMethod void unitTest(){
        
        setupData();
        
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/xml');
     	
     	// Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        test.startTest();

            multimock.setStaticResource(settings.Api_Host__c + settings.Lease_List__c + '/' + 'SF_TEST' + '|' + Village1.Village_Code__c + '|' + dateString, 'TestAPI_LeaseList1');        
        	
        	string xmlLease = apiService.readLeaseList('SF_TEST', Village1.Village_Code__c, system.today());
        	list<apiLease.cls_LeaseItem> leaseList = apiLease.parseXML(xmlLease);
system.debug('@@@@  ' + leaseList);        
        	
        	system.assertEquals(leaseList.size(), 1);
        
		test.stopTest();        
        
    }
    
}