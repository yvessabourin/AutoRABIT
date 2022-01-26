public Class compSiteVisitEmailHandler{

    @future
    public static void sendEmails(list<id> visitids){

        list<Competitor_Visit__c> visits = [SELECT id, name,Competitor_Site__r.Type__c ,BVSC_Employees_Name__c,Date_of_Visit__c,Number_of_Empty_Units__c,Competitor_Site__c,
        Announced_New_Arrivals__c,Retail_Discount__c,General_Presentation__c,Customer_Service__c,Extra_Services__c,
        Food_Beverage_Options__c,Overall_Experience__c,Share_Site_Visit_Info__c,
        Description__c,Key_Leasing_Points__c,Brands_we_should_consider__c,Retail_Offer__c,
        In_Store_Presentation__c,Customer_profile_and_bag_count__c,Food_Beverage_Quality__c,
        Other_Matters__c,Risks__c,Opportunities__c,Change_Since_Last_Visit__c,Instore_Services__c FROM Competitor_Visit__c WHERE id in:visitids];
        
        map<id, list<ContentVersion>> attachmentsMap = new map<id, list<ContentVersion>>();
        list<ContentVersion> attachmentsList = [SELECT Id, Title, VersionData, FirstPublishLocationId, FileType, PathOnClient FROM ContentVersion WHERE FirstPublishLocationId IN:visits AND IsLatest = true LIMIT 4];
        
        if(attachmentsList.size() > 0 && attachmentsList != NULL){   
    
            for(ContentVersion att : attachmentsList ){
                if(attachmentsMap.get(att.FirstPublishLocationId) == NULL){
                    attachmentsMap.put(att.FirstPublishLocationId, new list<ContentVersion>{att});
                }
                else {
                    attachmentsMap.get(att.FirstPublishLocationId).add(att);
                }

            }
        }

        list<Collaborationgroup> groups = [SELECT id, Name FROM Collaborationgroup WHERE Name like 'B2B Meetings%'];
        list<CollaborationGroupMember> groupMembers = [SELECT Id,MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId in:groups];
        set<id> userIdSet = new set<id>();
        Map<id, id> competitorIdMap = new Map<id, id>();
        Map<id, Competitor_Site__c> competitorMap = new Map<id, Competitor_Site__c>();
        Map<id, Village__c> villageMap = new Map<id, Village__c>();
        set<id> VillageIdSet = new set<id>();
        List<Messaging.SingleEmailMessage> listMsgs = new List<Messaging.SingleEmailMessage>();
        
            for(Competitor_Visit__c cv : visits){
                competitorIdMap.put(cv.id,cv.Competitor_Site__c);
            }
            
            for(Competitor_Site__c cs : [Select id, name,Competitor_to_Village__r.name from Competitor_Site__c where id IN: competitorIdMap.values()]){
                competitorMap.put(cs.id, cs);
            }
        
            for(CollaborationGroupMember cgm : groupMembers){
                userIdSet.add(cgm.MemberId);
            }
            
            OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address = 'traveltrade@thebicestervillageshoppingcollection.com' limit 1];
            
            list<user> usrs = [SELECT id, name, email from USER WHERE id in: userIdSet AND isActive = true AND Profile.UserLicense.Name != 'Customer Community Plus'];
            set<user> userSet = new set<user>();
            userSet.addall(usrs);
            system.debug('userSet :' + userSet);
            system.debug('userSet size :' + userSet.size());
        
            for(Competitor_Visit__c vis : visits){

                    string compVisitLinkURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + vis.Id;
                    string compsiteLinkURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + vis.Competitor_Site__c;

                    Datetime dt = vis.Date_of_Visit__c;
                    string theDay = dt.format('EEEE');
                    string theMonth = '';
                    switch on vis.Date_of_Visit__c.month(){            
                        when 1 {
                            theMonth = 'January';
                        }
                        when 2 {
                            theMonth = 'February';
                        } 
                        when 3 {
                            theMonth = 'March';
                        }  
                        when 4 {
                            theMonth = 'April';
                        }  
                        when 5 {
                            theMonth = 'May';
                        }  
                        when 6 {
                            theMonth = 'June';
                        }  
                        when 7 {
                            theMonth = 'July';
                        }                        
                        when 8 {
                            theMonth = 'August';
                        }
                        when 9 {
                            theMonth = 'September';
                        } 
                        when 10 {
                            theMonth = 'October';
                        } 
                        when 11 {
                            theMonth = 'November';
                        }   
                        when else{
                            theMonth = 'December';
                        }             
                    }

                    string village = competitorMap.get(competitorIdMap.get(vis.id)).Competitor_to_Village__r.name;
                    string CompSite = competitorMap.get(competitorIdMap.get(vis.id)).name;         
                                      
                    string html = '<html>';
                    html += '<head></head>';
                    html += '<body><style>ul{background:white; font-family:Arial,sans-serif;}</style>';
                    html += '<body><style>li{margin: 5px 0;}</style>';
                    html += '<style>table,td{border: 1px solid black;}</style>';
                    html += '<style>br{font-size: 10%;}</style>';

                    html += '<p style="margin-left:2.5em"><b><u>Competitor Site</u></b> <b>:</b> '+CompSite + ' ,competitor to ' + village + ' village<p/>';
                    
                    html += '<p style="margin-left:2.5em"><b><u>Development Type</u></b> <b>:</b> '+ vis.Competitor_Site__r.Type__c +'<p/>';

                    html += '<p style="margin-left:2.5em"><b><u>Date of visit</u></b> <b>:</b> ' +theDay+', '+theMonth+' '+vis.Date_of_Visit__c.day()+' '+vis.Date_of_Visit__c.year()+'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>BVSC Employees</u></b> <b>:</b> ' + vis.BVSC_Employees_Name__c + '<p/>';

                    html += '<p style="margin-left:2.5em"><b><u>Description</u></b>  <b>:</b> '+ vis.Description__c+'<br/>';

                    html += '<p style="margin-left:2.5em"><b><u>Number of Empty Units</u></b> <b>:</b> '+ vis.Number_of_Empty_Units__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>Announced New Arrivals</u></b> <b>:</b> '+ vis.Announced_New_Arrivals__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>Retail Discount</u></b>  <b>:</b> '+ vis.Retail_Discount__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>General Presentation</u></b>  <b>:</b> '+ vis.General_Presentation__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>Customer Service</u></b>  <b>:</b> '+ vis.Customer_Service__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>Extra Services</u></b>  <b>:</b> '+ vis.Extra_Services__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>Food and Beverage Options</u></b>  <b>:</b> '+ vis.Food_Beverage_Options__c +'<p/>';
                    html += '<p style="margin-left:2.5em"><b><u>Overall Experience</u></b>  <b>:</b> '+ vis.Overall_Experience__c +'<p/><br></br>';             
                    html += '<ul><li><b><u>Key Leasing Points</u></b>  <b>:</b> '+ vis.Key_Leasing_Points__c +'</li><br></br>';
                    html += '<li><b><u>Brand we should consider</u></b>  <b>:</b> '+ vis.Brands_we_should_consider__c +'</li><br></br>';
                    html += '<li><b><u>Retail Offer</u></b>  <b>:</b> '+ vis.Retail_Offer__c +'</li><br></br>';
                    html += '<li><b><u>In Store Presentation</u></b>  <b>:</b> '+ vis.In_Store_Presentation__c +'</li><br></br>';
                    html += '<li><b><u>Customer Profile and Bag Count</u></b>  <b>:</b> '+ vis.Customer_profile_and_bag_count__c +'</li><br></br>';
                    html += '<li><b><u>Food & Beverage Quality</u></b>  <b>:</b> '+ vis.Food_Beverage_Quality__c +'</li><br></br>';
                    html += '<li><b><u>Other Matters</u></b>  <b>:</b> '+ vis.Other_Matters__c +'</li><br></br>';
                    html += '<li><b><u>Risks</u></b>  <b>:</b> '+ vis.Risks__c +'</li><br></br>';
                    html += '<li><b><u>Opportunities</u></b>  <b>:</b> '+ vis.Opportunities__c +'</li><br></br>';
                    html += '<li><b><u>Change Since Last Visit</u></b>  <b>:</b> '+ vis.Change_Since_Last_Visit__c +'</li><br></br>';
                    html += '<li><b><u>Instore Services</u></b>  <b>:</b> '+ vis.Instore_Services__c +'</li><br></br>';            
                    html += '</ul>';

                    html += '<br></br>';
                    
                    html += '<a href='  + compVisitLinkURL + '>Click here to view the record, any images and any other files.</a>';

                    
                    html += '<br></br>';
                   

                    html += '<table style="border: 1px solid black;">';

                     if(attachmentsList.size() > 0 && attachmentsMap.get(vis.id) != NULL){
                     
                      html += '<b>Images from the visit:</b><br></br>';
                      
                        Integer i = 0;
                        Integer finalInt = attachmentsMap.get(vis.id).size();
                         
                        for(ContentVersion att : attachmentsMap.get(vis.id)){
                            Integer remainder;
                            remainder = math.mod(i, 2);
                            if(remainder == 0){
                                html += '<tr>';
                            }

                            string enocodedBody = EncodingUtil.base64Encode(att.VersionData);
                            html +='<td><center><img src="data:image/png;base64,'+enocodedBody+'" alt="Red dot"></center></td><br></br>';
                            
                            if(i == finalInt){
                                html += '</tr>';                   
                            }
                            if(remainder != 0){
                                html += '</tr>';
                            }
                            i ++ ;
                        }                     
                    }

                    
                    html += '</table>';
                    html += '<br></br>';
                    html += '<br></br>';

                    html += '<a href='  + compsiteLinkURL + '>To learn more about this competitor site please click here.</a>';
                              
                    html += '</body></html>';
                    
                    
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setSubject('A Competitor Site Visit has occured at ' + CompSite + ' ,competitor to ' + village + ' village.'  );                       
                    msg.setHtmlBody(html);
                    msg.setOrgWideEmailAddressId(OWA.id);
                    msg.setWhatId(vis.id);
                    msg.saveAsActivity = false;  
                
                    for(user u : userSet){
                    system.debug('u id' + u.id);           
                        msg.setTargetObjectId(u.Id);   
                        listMsgs.add(msg); 
                    }

            }
        system.debug('listMsgs.size' + listMsgs.size());  
        system.debug('Limits.getHeapSize() : ' + Limits.getHeapSize());  
        system.debug('Limits.getLimitHeapSize() : ' + Limits.getLimitHeapSize());

        Messaging.sendEmail(listMsgs);

    }

}