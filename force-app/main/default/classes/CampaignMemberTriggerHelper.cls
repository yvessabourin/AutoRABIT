/*
*Class: CampaignMemberTriggerHelper (called from CampaignMemberTrigger)
*purpose: when an Tourism campaign email bounces or is reported as SPAM etc., this trigger will update
*the Contact 
*Created by: Ian Womack
*Date: 24/01/2014
*
**/
public with sharing class CampaignMemberTriggerHelper{

    public Static void ProcessOptouts( list<CampaignMember> campaignMembersList)
    {
        system.debug('in the helper class');
        
        //TO-DO only run for Tourism Campaigns - get the record type id
        id campaignMemberRecordTypeID = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Tourism Campaign Member').RecordTypeId;
        
        //Get the list of opt out statuses from custom settings
        List<Opt_Out_Campaign_Status__c> outOutStatuses = Opt_Out_Campaign_Status__c.getall().values();
        
        set<string> optOutStatuses = new set<string>(); //{'Spam','Hard Bounced','Opt Out'};
        //swap out the list for a Set so that we can do a compare
        FOR (Opt_Out_Campaign_Status__c optoutStatus : outoutstatuses) 
        {
            optOutStatuses.add(optoutStatus.name);
        }
        system.debug('Opt Out statuses: ' + optOutStatuses);
        //end of retrieve opt out statuses
        
        map<id,CampaignMember> CMMap= new map<id,CampaignMember>();
        
    	for(CampaignMember cm : campaignMembersList)
        {
            IF(optOutStatuses.contains(cm.Status) )
            {
                CMMap.put(cm.ContactId, cm);            
            }
     	}

		System.debug('Contact/Campaign member map: ' + CMMap);	
        
        List<Contact> OptOutContacts= [SELECT id, Opt_Out_Campaign_Date__c, Opt_Out_Campaign_Member_ID__c,
                                   Opt_out_Campaign_Status__c, Opt_Out_Campaign_String__c,
                                   HasOptedOutOfEmail
                                   FROM Contact WHERE ID in :CMMap.keySet()];
    
   
    //loop through all the contacts that need to be updated
    FOR(Contact cContact : OptOutContacts)
    {
        //retrieve the related campaignmember for the contact, from the CMMAP created above
    	campaignmember CM = CMMap.get(cContact.id);
    	//only update the contact if the contact is not already opted out
        //so as not to overwrite the original reason for opting out
        if (string.isBlank(cContact.Opt_Out_Campaign_Member_ID__c) && CM.RecordTypeId == campaignMemberRecordTypeID)
        {
            system.debug('Contact is is about to be opted out:' + cContact.Id);
            //Update the relevant fields on the Contact
            cContact.Opt_Out_Campaign_Date__c = CM.LastModifiedDate;
            cContact.Opt_Out_Campaign_Member_ID__c = CM.Id;
            cContact.Opt_out_Campaign_Status__c = CM.Status;
            cContact.Opt_Out_Campaign_String__c = CM.CampaignId;
            cContact.HasOptedOutOfEmail = true;
        }
        else
        {
        	system.debug('Contact is already opted out:' + cContact.Id);
        }
    }
    
    //update all contacts
    update OptOutContacts;
        
    }//end of ProcessOptouts method
    
}