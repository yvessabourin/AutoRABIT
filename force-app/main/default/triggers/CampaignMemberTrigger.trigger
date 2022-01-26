/*
*Class: CampaignMemberTrigger
*purpose: when an campaign email bounces or is reported as SPAM etc., this trigger will update
*the Contact (via helper Class)
*Created by: Ian Womack
*Date: 24/01/2014
*
**/

trigger CampaignMemberTrigger on CampaignMember (after insert, after update) {

    if(Trigger.isUpdate || Trigger.isInsert)  
    {
    	CampaignMemberTriggerHelper.ProcessOptouts(Trigger.new);
    }
          
}