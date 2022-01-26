public class DailySalesValidations {
    
    private string errMsg = '';
    
    // Custom setting indicating whether validations on the Daily_Sale__c object should be performed
    private static final boolean validationsActive = boolean.valueOf(Global_Object_Validation__c.getInstance().get('Daily_Sales_Validations_Active__c'));
    
    // Validate whether user confirming record is authorised to do so.
    // This is defined by Confirm_Daily_Sales_Records__c flag on Village Presence Contact Role record
    public static void checkConfirmUser(list<Daily_Sale__c> DailySalesList){
        
        if (validationsActive){
            
            boolean valid = true;
           
            string userId =  system.userInfo.getUserId();
            
            string contactId = [select ContactId from User where Id = :userId].contactId; //Equivalent brand contact id for the running user 
            map<string, string> vpIdSet = new map<string, string>() ;
            
            for(Daily_Sale__c ds: DailySalesList)
            {
                vpIdSet.put(ds.Id, ds.Store__c);
            }
            
            map<Id, Village_Presence__c> vpcontactRoleMap = new map<Id, Village_Presence__c>([select Id, Name, (SELECT id, Village_presence__c, Contact__c,
                                                                 Daily_Sales_Active_From__c, Daily_Sales_Active_To__c,
                                                                 Confirm_Daily_Sales_Records__c
                                                                 from Village_Presence_Contact_roles__r
                                                                 where Daily_Sales_Active_From__c != null
                                                                 and Contact__c = :contactId)
                                                            From Village_Presence__c
                                                            where Id in :vpIdSet.values()]);
                

            for(Daily_Sale__c ds :DailySalesList){
                
                list<Village_Presence_Contact_Role__c> vpcontactRoleList = vpcontactRoleMap.get(ds.Store__c).Village_Presence_Contact_roles__r;
            
                if (vpcontactRoleList.size() == 1){
                    if (!vpcontactRoleList[0].Confirm_Daily_Sales_Records__c)
                        valid = false;
                } else {
                    valid = false;
                }

        
                if(!Valid){
                    ds.addError('Sorry! you do not have authority to confirm this record');
                }
            } 
        }

        
    }
    
    
}