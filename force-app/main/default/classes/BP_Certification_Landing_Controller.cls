public with sharing class BP_Certification_Landing_Controller {
    
    @AuraEnabled
    public static List<Daily_Sales_Certification_Batch__c> getOutCertifications(String sortField, boolean isAsc){ //Get Outstanding Certifications
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
        
        String queryDSCB = 'SELECT Period_Start_Date__c, Village_Presence__r.Name, Period_End_Date__c, Name, Certification_Submission_Deadline__c';
        queryDSCB += ' FROM Daily_Sales_Certification_Batch__c WHERE Village_Presence__c =: vpcrSet';
        queryDSCB += ' AND Status__c != ' + '\'Generated\'' + ' AND Status__c != ' + '\'Pending Approval\'' + ' AND Status__c != ' + '\'Approved\'' + ' AND Status__c != ' + '\'Batch Complete\'' + ' AND Period_End_Date__c <= TODAY';
        if(sortField != '' || sortField != null){
        	queryDSCB += ' ORDER BY ' + sortField;
        }
        if(isAsc){
            queryDSCB += ' ASC';
        } else {
            queryDSCB += ' DESC';
        }
        system.debug(queryDSCB);
        
        List<Daily_Sales_Certification_Batch__c> outStandingList = Database.query(queryDSCB);
        return outStandingList;
    }
}