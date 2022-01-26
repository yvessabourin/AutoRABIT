@isTest

private class B2CCustomerEntryControllerTest {
    static testMethod void uniTest() {
        
    b2c_customer__c customer = new b2c_customer__c();
    Village__c village = new Village__c(Name='Test Village', Village_code__c = 'TV', CertSales_CertPeriod_Cut_Off_Days__c = 1, CertSales_Report_Sales_Grace_Period_Days__c = 1);
    
    User u1 = TestData_User.setupAdminUser(false);
    u1.Username = 'vr_u1@test.com';
    u1.Email = 'vr_u1@test.com';
    insert u1;
    
    
    system.runAs(u1){
    	insert village;
    }
    
    User u = TestData_User.setupAdminUser(false);
    u.Village__c = 'Test Village';
      
    customer.firstName__c = 'Trevor';
    customer.lastName__c = 'Tester';
    customer.email__c = 'tt@test.com';
    customer.primaryVillage__c = 'TV';
    customer.preferredLanguage__c = 'English';
          
    ApexPages.StandardController sc = new ApexPages.StandardController(customer); 
    PageReference pg = new PageReference('/apex/B2CCustomerEntry');
    test.setCurrentPageReference(pg);
    
    test.startTest();    
      system.runAs(u){
	      B2CCustomerEntryController controller = new B2CCustomerEntryController(sc);    
	      pg = controller.saveRecord();
	      list<b2c_customer__c> customerList = [select id from b2c_customer__c where email__c = 'tt@test.com' ];
	      
	      system.assertEquals(customerList.size(), 1);
	      
	      // force duplicate error
	      customer = new b2c_customer__c();
	      
	      customer.firstName__c = 'Terry';
	      customer.lastName__c = 'Tester';
	      customer.email__c = 'tt@test.com';
	      customer.primaryVillage__c = 'TV';
	      customer.preferredLanguage__c = 'English';
	      sc = new ApexPages.StandardController(customer);
	      controller = new B2CCustomerEntryController(sc);  
	      pg = controller.saveRecord();
	      customerList = [select id from b2c_customer__c where email__c = 'tt@test.com' ];
	      system.assertEquals(customerList.size(), 1);      
	
	      List<Apexpages.Message> msgs = ApexPages.getMessages();
	      boolean b = false;
	      for(Apexpages.Message msg:msgs){
	          if (msg.getDetail().contains('email address is already registered')) b = true;
	      }
	      system.assert(b);
      }
    test.stopTest();
    

    }

}