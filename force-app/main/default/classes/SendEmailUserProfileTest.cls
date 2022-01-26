@isTest
public class SendEmailUserProfileTest {

    @testSetup
    static void setup(){
        User testUser = TestData_User.setupUser('TestUser', 'Bicester Finance', 'Brand Marketing SP', true, true);
    }
    
    @isTest
    public static void testEmail(){
        User testUser = [SELECT Id FROM User WHERE UserName = 'TestUser@valueretail.com'];
        
        Test.startTest();
            SendEmailUserProfile.sendEmail(new List<Id>{testUser.Id});
        Test.stopTest();
    }
}