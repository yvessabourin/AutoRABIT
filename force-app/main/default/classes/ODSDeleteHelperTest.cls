@isTest
private class ODSDeleteHelperTest {

    private static b2c_customer__c customer = new b2c_customer__c();

    private static void setupData(){
        
        User u1 = TestData_User.setupAdminUser(false);
	    u1.Username = 'vr_u1@test.com';
	    u1.Email = 'vr_u1@test.com';
	    insert u1;
	    
        system.runAs(u1){
	        customer.firstName__c = 'Eraser';
	        customer.lastName__c = 'Head';
	        customer.email__c = 'ee@head.com';
	        
	        insert customer;
        }
        
    }

    static testMethod void unitTest1() {

        setupData();
        
        string recId = customer.Id;
        
        test.startTest();
            delete customer;
        test.stopTest();
        
        list<ODS_Delete_Log__c> logList = [select Deleted_Record_ID__c, sObject__c from ODS_Delete_Log__c 
                                    where Deleted_Record_ID__c = :recId];
                                    
        system.assertEquals(logList.size(), 1);
        system.assertEquals(logList[0].Deleted_Record_ID__c, recId);
        system.assertEquals(logList[0].sObject__c, 'b2c_customer__c');                          

    }
    
    static testMethod void unitTest2() {

        setupData();
        
        string recId = customer.Id;
        // Create test admin user
        User usr = TestData_User.setupAdminUser(true);
        
        test.startTest();
            
            system.runAs(usr){
                ODSDeleteHelper.deleteCustomer(recId);
            }
            
        test.stopTest();
        
        list<ODS_Delete_Log__c> logList = [select Deleted_Record_ID__c, sObject__c from ODS_Delete_Log__c 
                                    where Deleted_Record_ID__c = :recId];
                                    
        system.assertEquals(logList.size(), 1);
        system.assertEquals(logList[0].Deleted_Record_ID__c, recId);
        system.assertEquals(logList[0].sObject__c, 'b2c_customer__c');                          

    }    
}