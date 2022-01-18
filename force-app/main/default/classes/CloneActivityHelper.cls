global class CloneActivityHelper {


    webservice static void cloneWithId(List<String> idList){
        List<Marketing_Activity__c> clonedActivityList = new List<Marketing_Activity__c>();
        Marketing_Activity__c clonedActivity;
        List<Marketing_Activity__c> activityList = [SELECT Id, Start_Date__c, End_Date__c, Name, Business_Function__c, Channel__c, Sub_Channel__c, Performance_Measure__c,
                                            Transfer_To_Oracle__c, Prescribed_by_Group__c, BAU_Boost__c, Third_Party_Actual_Spend__c,
                                            Target_Audience__c, Date_Assets_Sent__c, List_of_Hash_tags_to_be_used__c, Link_to_Oracle__c,
                                            Links_to_SharePoint__c, Creative_Agency_Access_To_Salesforce__c, Marketing_Campaign__c,
                                            Group_or_Village_Activity__c, Group_or_Village_Activity_for_filter__c, Continue_with_Date_error__c,
                                            Marketing_Campaign_Village__c, Status__c, Reason_for_Removal_or_Cancellation__c, VR_Rep_Office__c,
                                            Other_Notes__c, Source_Market__c, Audience_Category__c, Audience__c, Audience_Village_local__c, x18_digit_ID__c,
                                            Accountable1__c, Activity_Display_Name__c, Activity_History__c, Actual_spend__c, Apollo_Assets_Links__c,
                                            Asset_Link__c, Barcode__c, Brand_Product_Opportunity__c, Category__c, Communication_Plan__c, Coniq_ID_Entered__c,
                                            Consulted__c, Customer_Dimension__c, Details_Comments__c, Display_Name__c, Email_Type__c, Expected_Average_Spend__c,
                                            Expected_Footfall__c, Expected_New_Members__c, Expected_Sales__c, Function__c, Global_Partner_Level__c, Help_With_Segmentation__c,
                                            Help_with_Tiers__c, Hero_message__c, Informed__c, Is_My_Partner_Activity__c, Legal_mandatories_and_other_reference__c, Budget__c,
                                            Activity_Cost__c, Marketing_Activity_Ref__c, Measurement_Description__c, Message__c, My_Activity__c, My_Village_Activity__c,
                                            Objective__c, Offer_ID__c, Old_Redemption_Campaign_ID__c, Parent_Campaign_Name__c, Parent_Group_Marketing_Campaign__c, Partner__c,
                                            Partner_Campaign__c, Partner_Contact__c, Partner_Name__c, Planned_Send_Date__c, Picklist_Multi_Select__c, Promo_Messages__c,
                                            QR_Code__c, Query_Field__c, Reach__c, Response_Description__c, Responsible_Person__c, Responsys_ID__c, Responsys_ID_Entered__c,
                                            Search_ID__c, Search_Keywords__c, Segmentation__c, Split_Type__c, Sub_Category__c, Sub_Channel_Type__c, Subject_Line__c, Template__c,
                                            Tier__c, Tier_Status__c, Tracked_Average_Spend__c, Tracked_Footfall__c, Tracked_New_Members__c, Tracked_Sales__c, Transfer_Redemptions_Now__c,
                                            Transfer_Redemptions_on_Go_Live__c, RecordTypeId
                                            FROM Marketing_Activity__c 
                                            WHERE Id IN :idList];
        for(Marketing_Activity__c activity : activityList){
            clonedActivity = activity.clone(false, true, false, false);
            clonedActivity.Name = 'Clone of ' + activity.Name;
            clonedActivityList.add(clonedActivity);
        }
        upsert clonedActivityList;
    }
}