public with sharing class MultipleActivityCreationController {
    
    private final Marketing_Activity__c activity;
    private final Marketing_Campaign__c campaign;
    public Marketing_Activity__c clonedActivity;
    public List<SelectOption> recurrencePattern {get;set;}
    public List<SelectOption> recurrencePatternDaily {get;set;}
    public List<SelectOption> recurrencePatternWeekly {get;set;}
    public List<SelectOption> monthDayOptions {get;set;}
    public List<SelectOption> recurrenceDetails {get;set;}
    public List<SelectOption> endAfterOccurrences {get;set;}
    public List<String> listOfDays{get;set;}
    public Set<String> weekDaysSet;
    public Set<String> entireWeekSet;
    public Boolean showDailyDetails {get;set;}
    public Boolean showWeeklyDetails {get;set;}
    public Boolean showMonthlyDetails {get;set;}
    public Boolean showEndDate {get;set;}
    public Boolean showStartDateError {get;set;}
    public Boolean showEndDateError {get;set;}
    public Boolean showOccurrences {get;set;}
    public String getSelectedValue {get;set;}
    public String getSelectedReccurrence {get;set;}
    public String selectedMonthDay {get;set;}
    public String reccurrencePatternDetail {get;set;}
    public String totalOccurrences {get;set;}
    public String recordId;
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    
    public MultipleActivityCreationController() {
        listOfDays = new List<String>();
        recordId = System.currentPageReference().getParameters().get('id');
        activity = [SELECT Id, Start_Date__c, End_Date__c, Name, Business_Function__c, Channel__c, Sub_Channel__c, Performance_Measure__c,
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
                    WHERE Id =: recordId];
        
        campaign = [SELECT Id, Start_Date__c, End_Date__c 
                    FROM Marketing_Campaign__c 
                    WHERE Id =: activity.Marketing_Campaign__c];
        
        startDate = activity.Start_Date__c;
        endDate = activity.End_Date__c;
        showDailyDetails = true;
        showWeeklyDetails = false;
        showMonthlyDetails = false;
        showEndDate = true;
        showOccurrences = false;
        showStartDateError = false;
        showEndDateError = false;
        weekDaysSet = new Set<String>();
        entireWeekSet = new Set<String>();
        monthDayOptions = new List<SelectOption>();
        recurrencePattern = new List<SelectOption>();
        recurrencePatternDaily = new List<SelectOption>();
        recurrencePatternWeekly = new List<SelectOption>();
        recurrenceDetails = new List<SelectOption>();
        endAfterOccurrences = new List<SelectOption>();
        recurrencePatternWeekly.add (new SelectOption('Monday','Monday'));
        recurrencePatternWeekly.add (new SelectOption('Tuesday','Tuesday'));
        recurrencePatternWeekly.add (new SelectOption('Wednesday','Wednesday'));
        recurrencePatternWeekly.add (new SelectOption('Thursday','Thursday'));
        recurrencePatternWeekly.add (new SelectOption('Friday','Friday'));
        recurrencePatternWeekly.add (new SelectOption('Saturday','Saturday'));
        recurrencePatternWeekly.add (new SelectOption('Sunday','Sunday'));
        recurrencePatternDaily.add (new SelectOption('Weekdays','Weekdays'));
        recurrencePatternDaily.add (new SelectOption('Entire Week','Entire Week'));
        recurrencePattern.add (new SelectOption('Daily','Daily'));
        recurrencePattern.add (new SelectOption('Weekly','Weekly'));
        recurrencePattern.add (new SelectOption('Monthly','Monthly'));
        recurrenceDetails.add (new SelectOption('End By','End By'));
        recurrenceDetails.add (new SelectOption('End After','End After'));
        weekDaysSet.add('Monday');
        weekDaysSet.add('Tuesday');
        weekDaysSet.add('Wednesday');
        weekDaysSet.add('Thursday');
        weekDaysSet.add('Friday');
        entireWeekSet.add('Monday');
        entireWeekSet.add('Tuesday');
        entireWeekSet.add('Wednesday');
        entireWeekSet.add('Thursday');
        entireWeekSet.add('Friday');
        entireWeekSet.add('Saturday');
        entireWeekSet.add('Sunday');
        getSelectedValue = 'Daily';
        reccurrencePatternDetail = 'Weekdays';
        getSelectedReccurrence = 'End By';
        for(Integer i = 1; i <= 31; i++){
            monthDayOptions.add (new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        for(Integer i = 1; i <= 10; i++){
            endAfterOccurrences.add (new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
    }
    
    public void renderSection(){
        if(getSelectedValue.equals('Daily')){
            showDailyDetails = true;
            showWeeklyDetails = false;
            showMonthlyDetails = false;
            showStartDateError = false;
            showEndDateError = false;
        } else if(getSelectedValue.equals('Weekly')){
            showDailyDetails = false;
            showWeeklyDetails = true;
            showMonthlyDetails = false;
            showStartDateError = false;
            showEndDateError = false;
        } else if(getSelectedValue.equals('Monthly')){
            showDailyDetails = false;
            showWeeklyDetails = false;
            showMonthlyDetails = true;
            showStartDateError = false;
            showEndDateError = false;
        }
    }
    
    public void renderOccurrence(){
        if(getSelectedReccurrence.equals('End By')){
            showEndDate = true;
            showOccurrences = false;
            showStartDateError = false;
            showEndDateError = false;
        } else if (getSelectedReccurrence.equals('End After')){
            showEndDate = false;
            showOccurrences = true;
            showStartDateError = false;
            showEndDateError = false;
        }
    }
    
    public PageReference save(){
        List<Marketing_Activity__c> clonedActivityList = new List<Marketing_Activity__c>();
        Set<String> weekDaysChosen = new Set<String>();
        String currentWeekDay;
        Integer dayDifference;
        Integer monthDifference;
        Integer campaignStartDateDiff;
        Integer campaignEndDateDiff;
        Datetime myDate;
        Date testDate;
        
        Schema.DescribeSObjectResult result = Marketing_Activity__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        
        
        showStartDateError = false;
        showEndDateError = false;
        campaignStartDateDiff = campaign.Start_Date__c.monthsBetween(startDate);
        campaignEndDateDiff = campaign.End_Date__c.monthsBetween(endDate);
        if(campaignStartDateDiff > 4){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The start date can not be 3 months older than the Campaign start date ' + campaign.Start_Date__c.format()));
            showStartDateError = true;
        } else if(campaignEndDateDiff > 3){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The end date can not be 3 months older than the Campaign end date ' + campaign.End_Date__c.format()));
            showEndDateError = true;
        } else {
            if(getSelectedValue.equals('Daily')){
                if(reccurrencePatternDetail.equals('Weekdays')){
                    weekDaysChosen.addAll(weekDaysSet);
                } else if(reccurrencePatternDetail.equals('Entire Week')){
                    weekDaysChosen.addAll(entireWeekSet);
                }
                dayDifference = startDate.daysBetween(endDate);
                for(Integer i = 0; i <= dayDifference; i++){
                    testDate = startDate.addDays(i);
                    myDate = Datetime.newInstance(testDate.year(), testDate.month(), testDate.day());
                    currentWeekDay = myDate.format('EEEE');
                    if(weekDaysChosen.contains('Monday') && currentWeekDay.equals('Monday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Tuesday') && currentWeekDay.equals('Tuesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Wednesday') && currentWeekDay.equals('Wednesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Thursday') && currentWeekDay.equals('Thursday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Friday') && currentWeekDay.equals('Friday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Saturday') && currentWeekDay.equals('Saturday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Sunday') && currentWeekDay.equals('Sunday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    }
                }
            }
            if(getSelectedValue.equals('Weekly')){
                for(String day : listOfDays){
                    weekDaysChosen.add(day);
                }
                dayDifference = startDate.daysBetween(endDate);
                for(Integer i = 0; i <= dayDifference; i++){
                    testDate = startDate.addDays(i);
                    myDate = Datetime.newInstance(testDate.year(), testDate.month(), testDate.day());
                    currentWeekDay = myDate.format('EEEE');
                    if(weekDaysChosen.contains('Monday') && currentWeekDay.equals('Monday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Tuesday') && currentWeekDay.equals('Tuesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Wednesday') && currentWeekDay.equals('Wednesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Thursday') && currentWeekDay.equals('Thursday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Friday') && currentWeekDay.equals('Friday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Saturday') && currentWeekDay.equals('Saturday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Sunday') && currentWeekDay.equals('Sunday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    }
                }
            }
            if(getSelectedValue == 'Monthly'){
                Integer daysInMonth;
                monthDifference = startDate.monthsBetween(endDate);
                dayDifference = startDate.day() - Integer.valueOf(selectedMonthDay);
                if(dayDifference < 0){
                    dayDifference = dayDifference * -1;
                } else if(startDate.day() > Integer.valueOf(selectedMonthDay)){
                    dayDifference = dayDifference * -1; 
                }
                if(monthDifference != 0){
                    for(Integer i = 0; i <= monthDifference; i++){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = activity.Start_Date__c.addMonths(i);
                        daysInMonth = Date.daysInMonth(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month());
                        if(daysInMonth == 30 && selectedMonthDay == '31'){
                            clonedActivity.Start_Date__c = Date.newInstance(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month(), 30);
                        } else if(daysInMonth == 28 || daysInMonth == 29 && Integer.valueOf(selectedMonthDay) > 29){
                            if(Date.isLeapYear(clonedActivity.Start_Date__c.year())){
                                clonedActivity.Start_Date__c = Date.newInstance(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month(), 29);
                            } else {
                                clonedActivity.Start_Date__c = Date.newInstance(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month(), 28);
                            }
                        } else {
                            clonedActivity.Start_Date__c = clonedActivity.Start_Date__c.addDays(dayDifference);
                        }
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    }
                }
            }
            upsert clonedActivityList;
            return pageRef; 
        }
        return null;
    }
    
    public PageReference saveWithEndAfter(){
        List<Marketing_Activity__c> clonedActivityList = new List<Marketing_Activity__c>();
        Set<String> weekDaysChosen = new Set<String>();
        String currentWeekDay;
        Integer dayDifference;
        Integer maxOccurrences;
        Integer monthDifference;
        Integer campaignStartDateDiff;
        Integer occurrencesDone = 0;
        Integer daysCounter = 0;
        Datetime myDate;
        Date testDate;
        
        Schema.DescribeSObjectResult result = Marketing_Activity__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
        pageRef.setRedirect(true); 
        
        showStartDateError = false;
        campaignStartDateDiff = campaign.Start_Date__c.monthsBetween(startDate);
        maxOccurrences = Integer.valueOf(totalOccurrences);
        if(campaignStartDateDiff > 4){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The start date can not be 3 months older than the Campaign start date ' + campaign.Start_Date__c.format()));
            showStartDateError = true;
        } else {
            if(getSelectedValue.equals('Daily')){
                if(reccurrencePatternDetail.equals('Weekdays')){
                    weekDaysChosen.addAll(weekDaysSet);
                } else if(reccurrencePatternDetail.equals('Entire Week')){
                    weekDaysChosen.addAll(entireWeekSet);
                }
                do{
                    daysCounter++;
                    testDate = startDate.addDays(daysCounter);
                    myDate = Datetime.newInstance(testDate.year(), testDate.month(), testDate.day());
                    currentWeekDay = myDate.format('EEEE');
                    if(weekDaysChosen.contains('Monday') && currentWeekDay.equals('Monday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    } else if (weekDaysChosen.contains('Tuesday') && currentWeekDay.equals('Tuesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    } else if (weekDaysChosen.contains('Wednesday') && currentWeekDay.equals('Wednesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    } else if (weekDaysChosen.contains('Thursday') && currentWeekDay.equals('Thursday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    } else if (weekDaysChosen.contains('Friday') && currentWeekDay.equals('Friday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    } else if (weekDaysChosen.contains('Saturday') && currentWeekDay.equals('Saturday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    } else if (weekDaysChosen.contains('Sunday') && currentWeekDay.equals('Sunday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                        occurrencesDone++;
                    }
                } while(maxOccurrences > occurrencesDone);
            }
            if(getSelectedValue.equals('Weekly')){
                for(String day : listOfDays){
                    weekDaysChosen.add(day);
                }
                for(Integer i = 0; i < maxOccurrences; i++){
                    testDate = startDate.addDays(i);
                    myDate = Datetime.newInstance(testDate.year(), testDate.month(), testDate.day());
                    currentWeekDay = myDate.format('EEEE');
                    if(weekDaysChosen.contains('Monday') && currentWeekDay.equals('Monday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Tuesday') && currentWeekDay.equals('Tuesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Wednesday') && currentWeekDay.equals('Wednesday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Thursday') && currentWeekDay.equals('Thursday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Friday') && currentWeekDay.equals('Friday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Saturday') && currentWeekDay.equals('Saturday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    } else if (weekDaysChosen.contains('Sunday') && currentWeekDay.equals('Sunday')){
                        clonedActivity = activity.clone(false, true, false, false);
                        clonedActivity.Start_Date__c = testDate;
                        clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                        clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                        clonedActivity.Continue_with_Date_error__c = true;
                        clonedActivityList.add(clonedActivity);
                    }
                }
                
            }
            if(getSelectedValue == 'Monthly'){
                Integer daysInMonth;
                dayDifference = startDate.day() - Integer.valueOf(selectedMonthDay);
                if(dayDifference < 0){
                    dayDifference = dayDifference * -1;
                } else if(startDate.day() > Integer.valueOf(selectedMonthDay)){
                    dayDifference = dayDifference * -1; 
                }
                for(Integer i = 0; i < maxOccurrences; i++){
                    clonedActivity = activity.clone(false, true, false, false);
                    clonedActivity.Start_Date__c = activity.Start_Date__c.addMonths(i);
                    daysInMonth = Date.daysInMonth(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month());
                    if(daysInMonth == 30 && selectedMonthDay == '31'){
                        clonedActivity.Start_Date__c = Date.newInstance(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month(), 30);
                    } else if(daysInMonth == 28 || daysInMonth == 29 && Integer.valueOf(selectedMonthDay) > 29){
                        if(Date.isLeapYear(clonedActivity.Start_Date__c.year())){
                            clonedActivity.Start_Date__c = Date.newInstance(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month(), 29);
                        } else {
                            clonedActivity.Start_Date__c = Date.newInstance(clonedActivity.Start_Date__c.year(), clonedActivity.Start_Date__c.month(), 28);
                        }
                    } else {
                        clonedActivity.Start_Date__c = clonedActivity.Start_Date__c.addDays(dayDifference);
                    }
                    clonedActivity.Name = activity.Name + ' ' + clonedActivity.Start_Date__c.format();
                    clonedActivity.End_Date__c = clonedActivity.Start_Date__c;
                    clonedActivity.Continue_with_Date_error__c = true;
                    clonedActivityList.add(clonedActivity);
                }
            }
            upsert clonedActivityList;
            return pageRef;
        }
        return null;
    } 
}