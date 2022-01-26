@istest
public class CampaignMemberTriggerHelperTest{
 
    static testMethod void CreateandReportCampaignMemberSpam()
    {
        //This test method will fire the CampaignMemberTrigger and update the contact to opt_out
        
        //CREATE DATA
        string OptOutStatus = 'Spam';
        //Account
        Account TourismAccount = TestData_Account.setupTourismAccount(1, true);    
        //Contact
        Contact TourismContact = TestData_Contact.setupContact('1', TourismAccount, true);
        system.debug('Contact Details: ' + TourismContact);
        //Campaign
        //get Tourism Record type id
        id campaignRecordTypeID = Schema.SObjectType.Campaign.RecordTypeInfosByName.get('Tourism').RecordTypeId;
        //get the campaignMemberRecordType (this is set at Campaign level <-- an sfdc thing!)
        id campaignMemberRecordType = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Tourism Campaign Member').RecordTypeId;
        Campaign tCampaign = new Campaign (name = 'Test Campaign', recordtypeid = campaignRecordTypeID, CampaignMemberRecordTypeId  = campaignMemberRecordType);
        insert tCampaign;
        //Campaign Member Status
        CampaignMemberStatus tCampaignMemberStatusSpam = new CampaignMemberStatus ( campaignid = tCampaign.id, HasResponded = true, isdefault = false, label = OptOutStatus, SortOrder = 3);
        insert tCampaignMemberStatusSpam;   
        
        //Campaign Member
        CampaignMember tCampaignMemberSpam = new CampaignMember (contactid = TourismContact.id , campaignid = tCampaign.id);
        insert tCampaignMemberSpam;
               
        //Campaign Member Status Custom Setting    
        Opt_Out_Campaign_Status__c spamStatus = new Opt_Out_Campaign_Status__c (name = OptOutStatus);
        insert spamStatus;
                    
        //RUN TESTS + Assert results
        
       
        
        tCampaignMemberSpam.status = 'Responsed';
        update tCampaignMemberSpam;
        
        contact aContact = [SELECT id, Name, Opt_Out_Campaign_Date__c, Opt_Out_Campaign_Member_ID__c, 
                            Opt_out_Campaign_Status__c, Opt_Out_Campaign_String__c, HasOptedOutOfEmail
                            FROM Contact WHERE id = :TourismContact.Id];
        
        system.debug('Updated Contact (not opted out): ' + aContact);
        //should not be opted out as the response was good
    	system.assertEquals(false, aContact.HasOptedOutOfEmail);
        
        
        //now update the campaign member record to a spam response
        tCampaignMemberSpam.status = OptOutStatus;
        update tCampaignMemberSpam;
        
        //re-fetch the record from the DB
        contact spamContact = [SELECT id, Name, Opt_Out_Campaign_Date__c, Opt_Out_Campaign_Member_ID__c, 
                            Opt_out_Campaign_Status__c, Opt_Out_Campaign_String__c, HasOptedOutOfEmail
                            FROM Contact WHERE id = :TourismContact.Id];
        
               
        system.debug('Updated Contact (should be optedout: ' + spamContact);
        //should  be opted out as the response was "SPAM"
    	system.assertEquals(true, spamContact.HasOptedOutOfEmail);
   
    }
}