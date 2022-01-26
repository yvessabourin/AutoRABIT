global with sharing class GuestSearchController {

	private static string guestRecType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Guest').RecordTypeId;
	
  public Boolean showHFSButton {public get; private set;}
  public Boolean showHFSHistoric {public get; private set;}

  public GuestSearchController(){

        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        showHFSButton = false;
        List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if( perm.PermissionSet.Name == 'Hands_Free_Shopping_Enabled' || perm.PermissionSet.Name == 'Host_Hands_Free_Shopping_Enabled'){
                showHFSButton = true;
            }     

        }

        showHFSHistoric = true;
        if(profileName == 'HFS Host' || profileName == 'HFS Runner'){          
            showHFSHistoric = false;
        }   

        if(profileName == 'HFS Co-ordinator' || profileName == 'HFS VR Assistant'  || profileName == 'System Administrator'){          
            showHFSButton = true;
        }  



  }


    @RemoteAction
    global static list<Account> searchGuests(string param){
    
        list<Account> returnList = new list<Account>();
          

        
        String paramSearch = param + '%';
        
        system.debug(' @@@ Search for .. ' + param);
        system.debug(guestRecType);

        /*List<Account> searchList = [SELECT Id, Name, FirstName, LastName,Salutation,
                                    Customer_GUID__c, PersonEmail, PersonMailingPostalCode,
                                    Country_of_Residence__c, PersonMobilePhone
                                    FROM Account
                                    WHERE RecordTypeId = :guestRecType AND (     LIKE :paramSearch
                                    OR FirstName LIKE :paramSearch)
                                    ORDER BY PersonEmail ASC
                                    LIMIT 10];*/
            
    List<List<SObject>> searchList = [FIND :param IN ALL FIELDS 
                                          RETURNING 
                                             Account (Id, Name, FirstName, LastName, Customer_GUID__c,Salutation,
                                             			PersonEmail, PersonMailingPostalCode, Country_of_Residence__c,
                                             			PersonMobilePhone
                                                        WHERE recordtypeid =:guestRecType
                                                        order by PersonEmail ASC
                                                        limit 50
                                              )];

		returnList = searchList[0];
        system.debug(searchList);
		return returnList;
    }

    @RemoteAction
    global static string editEmail(string guid, string currentEmail, string newEmail){
    
      // just pass the request to the existing code
        return apiCustomerController.saveEmailfromMobile(guid,currentEmail,newEmail);
    }
}