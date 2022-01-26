@IsTest
Public Class ProductLoanTriggerHandlertest{

	@TestSetup
    public static void SetupData(){

          Account testAccount = new Account(name = 'Test Account XYZ' , RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId);
          insert testAccount;
    
    }

    @isTest
    static void inserttest(){

    	Account acct = [SELECT Id, Name from Account where Name = 'Test Account XYZ'];

    	Product_Loan__c pl = new Product_Loan__c();
    	pl.name = 'Test Loan 1';
    	pl.brand__c = acct.id;
    	pl.status__c = 'Request For Collection';
    	pl.currency__c = 'GBP';

        test.starttest();
    	Insert pl;
    	List<Product_Loan__c> plList = new List<Product_Loan__c>{pl};
        ProductLoanTriggerHandler.isBeforeisInsert(plList);
        test.stoptest();

        //Product_Loan__c pLoan = [SELECT ID, Name,CurrencyIsoCode FROM Product_Loan__c WHERE ID =:pl.id];
        Product_Loan__c pLoan = plList.get(0);
        system.assertEquals('GBP', pLoan.CurrencyIsoCode, 'Error');

    }

    @isTest
    static void updatetest(){

    	Account acct = [SELECT Id, Name from Account where Name = 'Test Account XYZ'];

    	Product_Loan__c pl = new Product_Loan__c();
    	pl.name = 'Test Loan 1';
    	pl.brand__c = acct.id;
    	pl.status__c = 'Request For Collection';
    	pl.currency__c = 'GBP';

        test.starttest();
    	Insert pl;

    	pl.currency__c = 'EUR ';
    	//update pl;
    	List<Product_Loan__c> plList = new List<Product_Loan__c>{pl};
        ProductLoanTriggerHandler.isBeforeUpdate(plList);
        test.stoptest();

        //Product_Loan__c pLoan = [SELECT ID, Name,CurrencyIsoCode FROM Product_Loan__c WHERE ID =:pl.id];
        Product_Loan__c pLoan = plList.get(0);
        system.assertEquals('EUR', pLoan.CurrencyIsoCode, 'Error');

    }


}