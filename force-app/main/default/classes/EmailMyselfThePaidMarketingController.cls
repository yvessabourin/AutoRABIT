public class EmailMyselfThePaidMarketingController{
    
    Private Final Marketing_Activity__c ma;
    
    public EmailMyselfThePaidMarketingController(ApexPages.StandardController stdController){
        
        this.ma = (Marketing_Activity__c)stdController.getRecord(); 
        
    }
    
    public pageReference sendEmailMySelfMarketingActivity(){
        String theId = ApexPages.currentPage().getParameters().get('id');
        List<Marketing_Activity__c> listMarketing = new List<Marketing_Activity__c>();
        List<Messaging.SingleEmailMessage> allMessag = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        Marketing_Activity__c acc = [select Id, Name,Business_Function__c, Channel__C,Sub_Channel__c,Performance_Measure__c,Links_to_SharePoint__c,Influencers__c,Link_to_Oracle__c,
                                     Marketing_Campaign_Village__c,Marketing_Campaign__r.Name,Marketing_Campaign__r.Marketing_Campaign_Ref__c, Status__c,Reason_for_Removal_or_Cancellation__c, Start_Date__c, End_Date__c, VR_Rep_Office__c,Date_Assets_Sent__c,Other_Notes__c,Source_Market__c,Audience_Category__c,
                                     Audience_Village_local__c,Target_Audience__c,Coniq_ID_Entered__c,Responsys_ID_Entered__c,Creative_Agency_Access_To_Salesforce__c,Segmentation__c,Customer_Dimension__c,
                                     Marketing_Activity_Ref__c,Activity_Display_Name__c,Objective__c,Response_Description__c,Measurement_Description__c,Communication_Plan__c,Message__c,Legal_mandatories_and_other_reference__c,
                                     Details_Comments__c,Budget__c,	Third_Party_Actual_Spend__c,Activity_Cost__c,Expected_Footfall__c, Split_Type__c, List_of_Hash_tags_to_be_used__c,	Expected_Sales__c,	Reach__c,
                                     Expected_Average_Spend__c,Expected_New_Members__c,BAU_Boost__c, Oracle_Task_Id__c,  Oracle_Task_Number__c, Oracle_Secondary_Task_Id__c, Oracle_Secondary_Task_Number__c, 
                                     Region__c, Market__c, Oracle_Primary_Project_No__c, Oracle_Secondary_Project_No__c, Transfer_To_Oracle__c, toLabel(Integration_Status__c), Re_send_to_Oracle_for_NewActivity__c, Error_Message__c
                                     from  Marketing_Activity__c where Id=:ApexPages.currentPage().getParameters().get('id')];
        
        list<Activity_Budget_Split__c> splits = [SELECT Id, Name,Financial_plan_Type__c,Year__c, Split_Start_Date__c,Split_End_Date__c,X01_January__c, X02_Febraury__c, X03_March__c,
        X04_April__c,X05_May__c,X06_June__c,X07_July__c,X08_August__c,X09_September__c,X10_October__c,X11_November__c,X12_December__c,Total_Budget__c FROM Activity_Budget_Split__c WHERE Marketing_Activity__c =: acc.id LIMIT 1];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        sendTo.add(UserInfo.getUserEmail());  
        mail.setToAddresses(sendTo);
        
        mail.setSubject('Details Marketing Activity');
        String body = '<b>**********Marketing Activity Detail**********</b><br/>';
        body +=  '<br/>';
        body +=  'Marketing Activity Name :   '  + acc.Name +  '<br/>';
        body +=  'Marketing Activity Ref  :  ' + acc.Marketing_Activity_Ref__c + '<br/>';  
        body +=  acc.Oracle_Task_Id__c == null ? 'Oracle Primary Task Id  :  <br/>' : 'Oracle Primary Task Id  :  ' + acc.Oracle_Task_Id__c + '<br/>';
        body +=  acc.Oracle_Task_Number__c == null ? 'Oracle Primary Task Number  :  <br/>' : 'Oracle Primary Task Number  :  ' + acc.Oracle_Task_Number__c + '<br/>';
        body +=  acc.Oracle_Secondary_Task_Id__c == null ? 'Oracle Secondary Task Id  :  <br/>' : 'Oracle Secondary Task Id  :  ' + acc.Oracle_Secondary_Task_Id__c + '<br/>';
        body +=  acc.Oracle_Secondary_Task_Number__c == null ? 'Oracle Secondary Task Number   :  <br/>' : 'Oracle Secondary Task Number   :  ' + acc.Oracle_Secondary_Task_Number__c + '<br/>';
        body +=  'Marketing Campaign Name :  ' + acc.Marketing_Campaign__r.Name + '<br/>'; 
        body +=  'Marketing Campaign Ref :  ' + acc.Marketing_Campaign__r.Marketing_Campaign_Ref__c + '<br/>';
        body +=  'Marketing Campaign Village  :  ' + acc.Marketing_Campaign_Village__c + '<br/>';
        body +=  'Business Function :  '  + acc.Business_Function__c + '<br/>';
        body +=  'Sub Channel :  '  + acc.Sub_Channel__c +  '<br/>';
        //body +=  'Performance Measure : ' + acc.Sub_Channel__c +  '<br/>';
        //body +=  'Link to Oracle  :  ' + acc.Link_to_Oracle__c +  '<br/>';
        body +=  'Status :  ' + acc.Status__c + '<br/>';
        //body +=  acc.Reason_for_Removal_or_Cancellation__c == null ? 'Reason for Removal or Cancellation  :  <br/>' : 'Reason for Removal or Cancellation  :  ' + acc.Reason_for_Removal_or_Cancellation__c + '<br/>';
        body +=  'Start Date  :  ' + String.valueOf(Date.newinstance(acc.Start_Date__c.year(), acc.Start_Date__c.month(), acc.Start_Date__c.day())) + '<br/>';
        body +=  'End Date  :  ' + String.valueOf(Date.newinstance(acc.End_Date__c.year(), acc.End_Date__c.month(), acc.End_Date__c.day())) + '<br/>';
        //body +=  'Influencers__c  :  ' + acc.Influencers__c + '<br/>';
        //body +=  'VR Rep Office  :  ' + acc.VR_Rep_Office__c + '<br/>';
        body +=  '<br/>';
        body +=  '<b>**********Details**********</b><br/>';
        body +=  '<br/>';
        //body +=  'Date Assets Sent  :  ' + acc.Date_Assets_Sent__c + '<br/>';
        //body +=  acc.Other_Notes__c == null ? 'Other Notes  :  <br/>' : 'Other Notes  :  ' + acc.Other_Notes__c + '<br/>';
        //body +=  'Source Market  :   ' + acc.Source_Market__c + '<br/>';
        //body +=  'Market  :   ' + acc.Region__c + ' - ' + acc.Market__c + '<br/>';
        body +=  acc.Audience_Category__c == null ? 'Audience Category  :  <br/>' : 'Audience Category  :  ' + acc.Audience_Category__c + '<br/>';
        //body +=  acc.Target_Audience__c == null ? 'Target Audience  :  <br/>' : 'Target Audience  :  ' + acc.Target_Audience__c + '<br/>';
        //body +=  'Creative Agency Access To Salesforce  :  ' + acc.Creative_Agency_Access_To_Salesforce__c + '<br/>';
        body +=  acc.Region__c == null ? 'Region  :  <br/>' : 'Region  :  ' + acc.Region__c+ '<br/>';
        body +=  acc.Market__c == null ? 'Market  :  <br/>' : 'Market  :  ' + acc.Market__c+ '<br/>';
        body +=  acc.Segmentation__c == null ? 'Segmentation  :  <br/>' : 'Segmentation  :  ' + acc.Segmentation__c+ '<br/>';
        //body +=  'Customer Dimension  :  ' + acc.Customer_Dimension__c + '<br/>';
        //body +=  'Activity Display Name  :  ' + acc.Activity_Display_Name__c + '<br/>';
        //body +=  '<br/>';
        //body +=  '<b>**********Objectives**********</b><br/>';
        //body +=  '<br/>';
        //body +=  acc.Objective__c == null ? 'Objective  :  <br/>' : 'Objective  :  ' + acc.Objective__c + '<br/>';
        //body +=  acc.Response_Description__c == null ? 'Response Description  :  <br/>' : 'Response Description  :  ' + acc.Response_Description__c + '<br/>';
        //body +=  acc.Measurement_Description__c == null ? 'Measurement Description  :  <br/>' : 'Measurement Description  :  ' + acc.Measurement_Description__c + '<br/>';
        //body +=  acc.Message__c == null ? 'Message  :  <br/>' : 'Message  :  ' + acc.Message__c +  '<br/>';
        //body +=  acc.Legal_mandatories_and_other_reference__c == null ? 'Legal, Mandatories & Other Reference  :  <br/>' : 'Legal, Mandatories & Other Reference  :  ' + acc.Legal_mandatories_and_other_reference__c +  '<br/>';
        //body +=  acc.Details_Comments__c == null ? 'Details/Comments  : <br/>' : 'Details/Comments  :  ' + acc.Details_Comments__c +  '<br/>';
        //body +=  acc.Communication_Plan__c == null ? 'Communication Plan  :  <br/>' : 'Communication Plan  :  ' + acc.Communication_Plan__c +  '<br/>';
        body +=  '<br/>';
        body +=  '<b>**********Metrics**********</b><br/>';
        body +=  '<br/>';

        body +=  'Primary Project No  :  ' + acc.Oracle_Primary_Project_No__c +  '<br/>';
        body +=  'Secondary Project No  :  ' + acc.Oracle_Secondary_Project_No__c +  '<br/>';
        body +=  'Transfer to Oracle  :  ' + acc.Transfer_To_Oracle__c +  '<br/>';
        body +=  acc.Integration_Status__c == null ? 'Integration Status  :  <br/>' : 'Integration Status  :  ' + acc.Integration_Status__c +  '<br/>';
        body +=  'Re-send to Oracle  :  ' + acc.Re_send_to_Oracle_for_NewActivity__c +  '<br/>';
        body +=  acc.Error_Message__c == null ? 'Error Message  :  <br/>' : 'Error Message  :  ' + acc.Error_Message__c +  '<br/>';
        
        body +=  acc.Budget__c == null ? 'Marketing Activity Budget  :  <br/>' : 'Marketing Activity Budget  :  ' + acc.Budget__c +  '<br/>';

        if(!splits.isEmpty()){

            body +=  '<ul>';
            body +=  '<li>January :  ' + splits[0].X01_January__c +  '</li>';
            body +=  '<li>February :  ' + Splits[0].X02_Febraury__c +  '</li>';
            body +=  '<li>March :  ' + splits[0].X03_March__c +  '</li>';
            body +=  '<li>April :  ' + splits[0].X04_April__c +  '</li>';
            body +=  '<li>May :  ' + splits[0].X05_May__c +  '</li>';
            body +=  '<li>June :  ' + splits[0].X06_June__c +  '</li>';
            body +=  '<li>July :  ' + splits[0].X07_July__c +  '</li>';
            body +=  '<li>August :  ' + splits[0].X08_August__c +  '</li>';
            body +=  '<li>September :  ' + splits[0].X09_September__c +  '</li>';
            body +=  '<li>October :  ' + splits[0].X10_October__c +  '</li>';
            body +=  '<li>November :  ' + splits[0].X11_November__c +  '</li>';
            body +=  '<li>December :  ' + splits[0].X12_December__c +  '</li>';
            body +=  '</ul>';

        }
        
        body +=  '<br/>';
        body += System.Url.getSalesforceBaseUrl().toExternalForm()
                    +'/'+acc.Id +'';
        
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false); 
        
        Messaging.SendEmailResult [] r = Messaging.SendEmail(new Messaging.SingleEmailMessage[] {mail}); 
        for (Messaging.sendEmailResult result : r ){
            
            if(!r[0].isSuccess()){
                System.debug ( result  );
            }
            else{
                
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Email Sent Successfully');
                
                ApexPages.addMessage(msg); 
                
            }
            
        }
        
        PageReference pageRef = new PageReference ('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
}