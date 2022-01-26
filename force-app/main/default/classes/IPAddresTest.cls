@isTest
private class IPAddresTest {

    static testMethod void unitTest() {
            
        test.startTest();
        	IPAddress controller = new IPAddress();
        
        test.stopTest();
        
        system.assert(controller.ipAddress.length() > 0);
        
        
        
    }
}