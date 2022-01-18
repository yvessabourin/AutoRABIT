@isTest
public class TestData_User {

    /**
    * Setup Admin User for use in RunAs() method.
    */
    public static User setupAdminUser(Boolean insertToDatabase){        

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User adminUser = new User(alias='BOSS1',email= 'bossman@valueretail.com', emailencodingkey= 'UTF-8',
                        lastname= 'bossman', firstname= 'the', languagelocalekey= 'en_US', localesidkey= 'en_GB',
                        profileid = p.Id, timezonesidkey= 'Europe/London',
                        username= 'objSetUpUser1@valueretail.com', isActive = true );
        
        if (insertToDatabase) {
            insert adminUser;
        }
        
        return adminUser;
    }
   
    /**
    * Setup Single User
    */
    
    public static User setupUser(String userName, string userRole, string userProfile, Boolean isActive, Boolean insertToDatabase) {
    
        list <UserRole> urList = null;
        UserRole ur = null;
        
        if (string.isBlank(userRole)){
            urList = [select Id, parentRoleId from UserRole where parentRoleId = null];
            ur = urList[0];
        } else {
            urList = [select Id, parentRoleId from UserRole where Name = :userRole];
            ur = urList[0];
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name= :userProfile]; 
        
        String truncUserName;
        if (userName.length() > 5) {
            truncUserName = userName.substring(0, 5);
        } else {
          truncUserName = userName;
        }

        User newUser = new User(LastName = userName,
              Alias = truncUserName.toUpperCase() + '123',
              Email = userName + '@valueretail.com',
              Username = userName + '@valueretail.com',
              Communitynickname = userName + 'Nickname',
              userroleId = ur.Id,
              profileId = p.Id,
              timezonesidkey = 'Europe/London',
              emailencodingkey = 'UTF-8',
              languagelocalekey = 'en_US',
              localesidkey = 'en_GB',
              isActive = isActive);

        
        if (insertToDatabase) {
            insert newUser;
        }
        
        return newUser;
    }    

    public static void addPermissionSetToUser(ID userID, String PermissionSetName){
        PermissionSet perm = [Select ID, Name FROM PermissionSet WHERE Name = :PermissionSetName];
       
        insert new PermissionSetAssignment(AssigneeId=userID, PermissionSetId=perm.Id);   
    }

}