public with sharing class SegmentationEmailExtension {

    private final Brand_Segmentation_Approval__c SegApproval;
    ApexPages.StandardSetController setCon;
    public Id Id { get; set; }
    public String errormessage { get; set;}
  
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SegmentationEmailExtension(ApexPages.StandardController stdController) {
        this.SegApproval = (Brand_Segmentation_Approval__c)stdController.getRecord();       
        Id = SegApproval.Id;
        errormessage = '';
    }
    public SegmentationEmailExtension(ApexPages.StandardSetController controller) {
        setCon = controller;
        errormessage = '';
    }

     public PageReference emailSegmentationRecord() {
        // we need to make sure that this user is permissioned to approve this record      
        boolean hasPermissionForAction = false;
        // Approve_Brand_Segmentation 
        List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if(perm.PermissionSet.Name == 'Email_Brand_Segmentation'){
                hasPermissionForAction = true;
            }           
        }
        if(hasPermissionForAction){
            // get segmentation record
            if(SegApproval != null){
                // this means that its a single email for a single BSA record

                // but if this record is in the status 'Requesting Approval' then we need to email the group
                if(SegApproval.Status__c == 'Requesting Approval'){
                    sendSingleRequestingEmail();
                }
                else if(SegApproval.Status__c == 'Pending') { // then its pending 
                    sendSinglePendingEmail();
                
                }
                
                PageReference pageRef = new PageReference('/'+Id);
                pageRef.setRedirect(true);
                return pageRef; //Returns to the Segmentation Approval page

            }
            else if(setCon != null){
                // this means its a list of BSAs that need emails for all of them.
               // lets first see if all the selected segmentation records are in the same status

                // we need to loop through the segmentation records, and split them by assigned to...
                Map<Id,Brand_Segmentation_Approval__c> userFirstSeg = new Map<Id,Brand_Segmentation_Approval__c>(); // this is just to get the email address and ID of the user
                Map<Id,List<Brand_Segmentation_Approval__c>> userBySegMap = new Map<Id,List<Brand_Segmentation_Approval__c>>();
                List<Brand_Segmentation_Approval__c> allsegs = (Brand_Segmentation_Approval__c[])setCon.getSelected();
                String selectedSegmentStatus = '';
                boolean allBSAsameStatus = true;
                for (Brand_Segmentation_Approval__c seg :allsegs)
                {
                    if(SelectedSegmentStatus == ''){
                        selectedSegmentStatus = seg.Status__c;                   
                    }
                    else if(selectedSegmentStatus != seg.Status__c){
                        allBSAsameStatus = false;
                    }
                    // check if its in the map already has the user in
                    if(!userBySegMap.containsKey(seg.Assigned_To__c)){
                        userBySegMap.put(seg.Assigned_To__c, new List<Brand_Segmentation_Approval__c>{seg});
                        // and add this to the other map
                        userFirstSeg.put(seg.Assigned_To__c,seg);
                    }
                    else
                    {
                        userBySegMap.get(seg.Assigned_To__c).add(seg);
                    }
                   
                }

                if(allBSAsameStatus){
                    if(selectedSegmentStatus == 'Requesting Approval'){
                        sendSelectedRequestingEmails(allsegs);
                    }
                    else if(selectedSegmentStatus == 'Pending'){
                        sendSelectedPendingEmails(userBySegMap,userFirstSeg);
                    }
                   
                }
                else{
                     errormessage += 'All Segmentation records need to be in the same status';
                }
            }
        }
        else
        {
             errormessage += 'You do not have the permission to perform this action';
        }

        if(errormessage != ''){        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errormessage));    
        }
        else{             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Emails sent successfully')); 
        }
        return null;
    }

    private void sendSinglePendingEmail(){

        emailUtils mailUtils = new emailUtils('vr1@valueretail.com', '');

        // lets get the 'To Address'
        LIST<string> toaddresses = new List<String>();
        toaddresses.add(SegApproval.Assigned_To__r.email);
        
        String htmlContent = '<p>Hello, ' + SegApproval.Assigned_To__r.Name + '</p>';
        htmlContent += '<p>You have been allocated a brand to segment. Please click on the link in this email to complete the request. Your response is due one week from now.</p>';
        htmlContent += '<p>' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + SegApproval.id + '">' + SegApproval.Name + '</a> for ' + SegApproval.Brand__r.Name + '</p>';
        htmlContent += '<p>Many Thanks,<br/>Group Retail and Group Remerchandising</p>';

        String plainContent = 'Hello, ' + SegApproval.Assigned_To__r.Name + '\r\n';
        plainContent += 'You have been allocated a brand to segment. Please click on the link in this email to complete the request. Your response is due one week from now.\r\n';
        plainContent +=  URL.getSalesforceBaseUrl().toExternalForm() + '/' + SegApproval.id + '">' + SegApproval.Name + ' for ' + SegApproval.Brand__r.Name + '\r\n';
        plainContent += '\r\nMany Thanks,\r\nGroup Retail and Group Remerchandising';

        String emailSubject = 'Brand Segmentation to be updated';
        emailUtils.emailSendResponse emailResponse = mailUtils.sendEmail(toaddresses,null,SegApproval.Id,emailSubject,htmlContent,plainContent);
        // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
        errormessage = emailResponse.emailResultMessage;

        // and also we need to update the SegApproval for the email sent
        SegApproval.Email_Notification_Date__c = datetime.now();
        update SegApproval;

    }

    private void sendSingleRequestingEmail() {
        
        directorEmailaudience audience = new  directorEmailaudience();  
        system.debug('audience ===== '+audience);             
        // now we have the audience, we need to build an email
        emailUtils mailUtils = new emailUtils('vr1@valueretail.com', '');
        String htmlContent = '<p>Hello,</p>';
        htmlContent += '<p>The following brand has been assigned segmentation. Now, we require you and those in copy on this email to review, edit, and approve the responses. Please click on the link in this email to complete the request. Your approvals are due one week from now.</p>';
        htmlContent += '<p>' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + SegApproval.id + '">' + SegApproval.Name + '</a> for ' + SegApproval.Brand__r.Name + '</p>';
        htmlContent += '<p>Many Thanks,<br/>Group Retail and Group Remerchandising</p>';

        String plainContent = 'Hello\r\n';
        plainContent += 'The following brand has been assigned segmentation. Now, we require you and those in copy on this email to review, edit, and approve the responses. Please click on the link in this email to complete the request. Your approvals are due one week from now.\r\n';
        plainContent +=  URL.getSalesforceBaseUrl().toExternalForm() + '/' + SegApproval.id + '">' + SegApproval.Name + ' for ' + SegApproval.Brand__r.Name + '\r\n';
        plainContent += '\r\nMany Thanks,\r\nGroup Retail and Group Remerchandising';

        String emailSubject = 'Brand Segmentation to be approved';
        emailUtils.emailSendResponse emailResponse = mailUtils.sendEmail(audience.toaddresses,audience.ccaddresses,SegApproval.Id,emailSubject,htmlContent,plainContent);
        // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
        errormessage = emailResponse.emailResultMessage;

    }

    private void sendSelectedPendingEmails(Map<Id,List<Brand_Segmentation_Approval__c>> userBySegMap, Map<Id,Brand_Segmentation_Approval__c> userFirstSeg){

        emailUtils mailUtils = new emailUtils('vr1@valueretail.com', '');

        List<Brand_Segmentation_Approval__c> allsegsforupdate = new List<Brand_Segmentation_Approval__c> ();
        // now we have a good loop structure
        for (ID userID : userBySegMap.keySet()){                   
            // now we have a single assignees details
            String usersEmail = userFirstSeg.get(userID).Assigned_To__r.Email;
            String usersName = userFirstSeg.get(userID).Assigned_To__r.Name;
            LIST<string> toaddresses = new List<String>();
            toaddresses.add(usersEmail);

            String htmlContent = '<p>Hello, ' + usersName + '</p>';
            String plainContent = 'Hello, ' + usersName + '\r\n';
            htmlContent += '<p>You have been allocated some brands to segment. Please click on the links in this email to complete the request. Your response is due one week from now.</p>';
            plainContent += 'You have been allocated a brand to segment. Please click on the link in this email to complete the request. Your response is due one week from now.\r\n';
            // we need to build a table to show the list of approvals to process

            htmlContent += '<table border="1"><tr><th>Approval Record</th><th>Brand</th></tr>';
            for(Brand_Segmentation_Approval__c bsa :userBySegMap.get(userID)){
                htmlContent += '<tr><td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + bsa.id + '">' + bsa.Name + '</a></td><td>' + bsa.Brand__r.Name + '</td></tr>';
                 plainContent +=  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bsa.id + '">' + bsa.Name + ' for ' + bsa.Brand__r.Name + '\r\n';
                 // might aswel update the email date for all these records
                bsa.Email_Notification_Date__c = datetime.now();
            }
            htmlContent += '</table>';
           
            htmlContent += '<p>Many Thanks,<br/>Group Retail and Group Remerchandising</p>';
            plainContent += '\r\nMany Thanks,\r\nGroup Retail and Group Remerchandising';

            String emailSubject = 'Brand Segmentations to be updated';

            emailUtils.emailSendResponse emailResponse = mailUtils.sendEmail(toaddresses,null,userFirstSeg.get(userID).Id,emailSubject,htmlContent,plainContent);
            // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
            if(emailResponse.emailSendResult){
                // only update the segs for the emails that suceeded.
                errormessage += '\r\n' + emailResponse.emailResultMessage;
                allsegsforupdate.addAll(userBySegMap.get(userID));
            }

        }

        // if its all done, and emails are gone... we can save the date to the segmentations
        update allsegsforupdate;

    }

    private void sendSelectedRequestingEmails(List<Brand_Segmentation_Approval__c> allsegs){
         directorEmailaudience audience = new  directorEmailaudience();  
        system.debug('audience ===== '+audience);             
        // now we have the audience, we need to build an email
        emailUtils mailUtils = new emailUtils('vr1@valueretail.com', '');


        String htmlContent = '<p>Hello,</p>';
        String plainContent = 'Hello, \r\n';
        htmlContent += '<p>The following brand has been assigned segmentation. Now, we require you and those in copy on this email to review, edit, and approve the responses. Please click on the link in this email to complete the request. Your approvals are due one week from now.</p>';
        plainContent += 'The following brand has been assigned segmentation. Now, we require you and those in copy on this email to review, edit, and approve the responses. Please click on the link in this email to complete the request. Your approvals are due one week from now.\r\n';
        // we need to build a table to show the list of approvals to process

        htmlContent += '<table border="1"><tr><th>Approval Record</th><th>Brand</th><th>VR Positioning</th><th>Guest Relevance</th><th>Gender</th><th>Segment</th><th>Subsegment</th></tr>';
        for(Brand_Segmentation_Approval__c bsa :allsegs){
            htmlContent += '<tr>';
            htmlContent += '<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + bsa.id + '">' + bsa.Name + '</a></td>';
            htmlContent += '<td>' + bsa.Brand__r.Name + '</td>';
            htmlContent += '<td>' + bsa.Brand_VR_Positioning__c + '</td>';
            htmlContent += '<td>' + bsa.Brand_Guest_Relevance__c + '</td>';
            htmlContent += '<td>' + bsa.Brand_Gender__c + '</td>';
            htmlContent += '<td>' + bsa.Brand_Segment__c + '</td>';
            htmlContent += '<td>' + bsa.Brand_Subsegment__c + '</td>';
            htmlContent += '</tr>';
            plainContent +=  URL.getSalesforceBaseUrl().toExternalForm() + '/' + bsa.id + '">' + bsa.Name + ' for ' + bsa.Brand__r.Name + '\r\n';
             // might aswel update the email date for all these records
            bsa.Email_Notification_Date__c = datetime.now();
        }
        htmlContent += '</table>';
       
        htmlContent += '<p>Many Thanks,<br/>Group Retail and Group Remerchandising</p>';
        plainContent += '\r\nMany Thanks,\r\nGroup Retail and Group Remerchandising';

        String emailSubject = 'Brand Segmentations to be approved';


        emailUtils.emailSendResponse emailResponse = mailUtils.sendEmail(audience.toaddresses,audience.ccaddresses,allsegs[0].Id,emailSubject,htmlContent,plainContent);
        // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
        errormessage = emailResponse.emailResultMessage;

    }

    private class directorEmailaudience{

        LIST<string> toaddresses {get; set;}
        List<String> ccaddresses {get; set;}

        directorEmailaudience(){

            List<Group> brandDirectorGroups = [SELECT ID, Name FROM Group WHERE (Name = 'Brand Directors' OR Name = 'Brand Director Primary') LIMIT 2];
             Map<Id,String> brandDirectorsGroupIDs = new Map<Id,String>();
            for(Group g : brandDirectorGroups){
                brandDirectorsGroupIDs.put(g.Id, g.Name);
            }
           
            Map<ID,String> userIdGroupNameSet = new Map<ID,String>();
            String userType = Schema.SObjectType.User.getKeyPrefix();   
            // Loop through all group members in a group 
            for (GroupMember m : [Select Id, UserOrGroupId,GroupId From GroupMember Where GroupId in :brandDirectorsGroupIDs.keyset()]) {
                // If the user or group id is a user 
                if (((String)m.UserOrGroupId).startsWith(userType)) {
                    userIdGroupNameSet.put(m.UserOrGroupId,brandDirectorsGroupIDs.get(m.GroupId));
                    System.debug('Adding User: ' + m.UserOrGroupId + ' === ' + brandDirectorsGroupIDs.get(m.GroupId));
                }
                    
            }
            System.debug('userIdGroupNameSet === ' + userIdGroupNameSet);
            toaddresses = new List<String>();
            ccaddresses = new List<String>();
            Set<ID> userids = userIdGroupNameSet.keyset();
            List<User> users = [SELECT ID, Email, Name FROM User WHERE ID in :userids];

            for(User u :users){
                  System.debug('user === ' + u + '====== ' + userIdGroupNameSet.get(u.ID));
                  String usersGroup = userIdGroupNameSet.get(u.ID);
                   System.debug('usersGroup === ' + usersGroup);
                if(usersGroup == 'Brand Director Primary'){
                    toaddresses.add(u.email);
                }
                else  if(usersGroup == 'Brand Directors'){
                    ccaddresses.add(u.email);
                }
            }

        }
    }
}