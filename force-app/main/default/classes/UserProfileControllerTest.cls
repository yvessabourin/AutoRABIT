@isTest
private class UserProfileControllerTest {

    static testMethod void unitTest() {
        
        User u = UserProfileController.getCurrentUser();
        
        system.assertEquals(u.Id, system.UserInfo.getUserId());
        
    }
}