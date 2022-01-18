public class BP_Certification_Landing_History_Ct{

    @AuraEnabled
    public static List<Daily_Sales_Certification_Batch__c> getHistory(){ //Get History Certifications
        Id userID = UserInfo.getUserId();
        User theUser = [SELECT Id, ContactId FROM User WHERE ID = :userID];
        List<Village_Presence_Contact_Role__c> vpcrList = [SELECT Id, Village_Presence__c,Certification_Active__c
                                                           FROM Village_Presence_Contact_Role__c
                                                           WHERE Contact__c = :theUser.ContactId
                                                           AND Certification_Active__c= true];
        Set<Id> vpcrSet = new Set<Id>();
        
        for(Village_Presence_Contact_Role__c theVPCR : vpcrList){
            vpcrSet.add(theVPCR.Village_Presence__c);
        }
        
        List <Daily_Sales_Certification_Batch__c> outStandingList = [SELECT Period_Start_Date__c, Village_Presence__r.Name, Period_End_Date__c,Name
                                                                    FROM Daily_Sales_Certification_Batch__c
                                                                    WHERE Village_Presence__c = :vpcrSet
                                                                    AND (Status__c = 'Pending Approval' 
                                                                    OR Status__c = 'Approved'
                                                                    OR Status__c = 'Batch Complete')];
        
        return outStandingList;
    }
    
    
    
    
}