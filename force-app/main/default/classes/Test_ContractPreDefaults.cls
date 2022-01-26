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
private class Test_ContractPreDefaults {

    private static final id brandRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
        
    static testMethod void testPreDefaultsOnInsert() {
    	
    	// Set up Account test data
    	Account account = new Account(Name='TestA', RecordTypeId = brandRecordTypeId);
    	insert account;
    	
    	// Set up Village test data
    	Village__c village = new Village__c(Name='TestV', Std_Break_Clause__c = 'Test_Std_Break_Clause__c',
    									Std_Fit_Out_days__c = 7, Default_Contract_Type__c = 'Lease',
    									Std_Lease_Term_months__c = 12, Village_Code__c = 'TT',CertSales_CertPeriod_Cut_Off_Days__c = 1, CertSales_Report_Sales_Grace_Period_Days__c = 1);
    	insert village;
    	
    	//Set up Opportunity test data
    	Opportunity opportunity = new Opportunity(Name='TestO', StageName = 'In discussion', 
    									AccountId = account.Id, CloseDate=system.today()+7,
    									Village__c = village.id);
    	insert opportunity;
    	
    	test.startTest();
    	Contract contract = new Contract(Name = 'TestC', AccountId = account.Id, Opportunity__c = opportunity.id);
    	insert contract;
    	contract = [select Landlords_Break_Rights__c, Fitting_out_Period_days__c, Contract_Type__c, ContractTerm 
    					from Contract where Name = 'TestC'];
    	/*
    	system.assertEquals(contract.Landlords_Break_Rights__c, village.Std_Break_Clause__c);
    	system.assertEquals(contract.Fitting_out_Period_days__c, village.Std_Fit_Out_days__c);
    	system.assertEquals(contract.Contract_Type__c, village.Default_Contract_Type__c);
    	system.assertEquals(contract.ContractTerm, village.Std_Lease_Term_months__c);
    	*/
    	test.stopTest();
    
    }
    
    
    static testMethod void testPreDefaultsOnBulkInsert() {
    	
    	// Set up Account test data
    	Account account = new Account(Name='TestA', RecordTypeId = brandRecordTypeId);
    	insert account;
    	
    	// Set up Village test data
    	Village__c village = new Village__c(Name='TestV', Std_Break_Clause__c = 'Test_Std_Break_Clause__c',
    									Std_Fit_Out_days__c = 7, Default_Contract_Type__c = 'Lease',
    									Std_Lease_Term_months__c = 12, Village_Code__c = 'TT',CertSales_CertPeriod_Cut_Off_Days__c = 1, CertSales_Report_Sales_Grace_Period_Days__c = 1);
    	insert village;
    	
    	//Set up Oportunity test data
    	Opportunity opportunity = new Opportunity(Name='TestO', StageName = 'In discussion', 
    									AccountId = account.Id, CloseDate=system.today()+7,
    									Village__c = village.id);
    	insert opportunity;
    	
    	test.startTest();
    	
    	// Create 200 Contract records
    	list<Contract> contractList = new list<Contract>();
    	for(integer i = 0; i < 200; i++){
    		Contract contract = new Contract(Name = 'TestC' + i, AccountId = account.Id, Opportunity__c = opportunity.id);
    		contractList.add(contract);
    	}
    	insert contractList;
    	
    	contractList = [select Landlords_Break_Rights__c, Fitting_out_Period_days__c, Contract_Type__c, ContractTerm 
    					from Contract where Name like 'TestC%'];
    	/*
    	for (Contract contract :contractList){
	    	system.assertEquals(contract.Landlords_Break_Rights__c, village.Std_Break_Clause__c);
	    	system.assertEquals(contract.Fitting_out_Period_days__c, village.Std_Fit_Out_days__c);
	    	system.assertEquals(contract.Contract_Type__c, village.Default_Contract_Type__c);
	    	system.assertEquals(contract.ContractTerm, village.Std_Lease_Term_months__c);
    	}
    	*/
    	test.stopTest();
    
    }
    
}