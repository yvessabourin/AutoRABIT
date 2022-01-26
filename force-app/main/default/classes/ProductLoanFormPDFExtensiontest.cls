@isTest
Public Class ProductLoanFormPDFExtensiontest{

	@isTest static void test_method_one() {

    Product_Loan__c pl = new Product_Loan__c();

    ApexPages.StandardController sc = new ApexPages.StandardController(pl);  
    ProductLoanFormPDFExtension plfcon = new ProductLoanFormPDFExtension(sc);

    system.assert(plfcon.html.startsWith('<table id="emptytable"'));

	}

	@isTest static void test_method_two() {

	Account testAccount = new Account(name = 'Test Account XYZ' , RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId);
    insert testAccount;

    Product_Loan__c pl = new Product_Loan__c();
    pl.brand__c = testAccount.id;
    pl.Name = 'Test';
    pl.status__c = 'Request for collection';
    pl.currency__c = 'GBP';
    insert pl;

    Product_Loan_Item__c pli = new Product_Loan_Item__c();
    pli.Name = 'test';
    pli.Product_Loan__c = pl.id;
    insert pli;


    ApexPages.StandardController sc = new ApexPages.StandardController(pl);  
    ProductLoanFormPDFExtension plfcon = new ProductLoanFormPDFExtension(sc);

    system.assert(plfcon.html.startsWith('<table id="productItemTable"'));

	}


}