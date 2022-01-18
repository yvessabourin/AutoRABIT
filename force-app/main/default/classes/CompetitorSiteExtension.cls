Public Class CompetitorSiteExtension{

        public date startdate {get;set;}
        public time starttime {get;set;}
        public time endtime {get;set;}
        public List<Event> myevents {get;set;} 
        public id myeventid {get;set;}
        public transient List<ContentVersion> myattachments {get;set;}
        public string crossoverbrands {get;set;}
        public string experience {get;set;}
        public string shopfits {get;set;}
        public string FoodandBeverage {get;set;}
        public string Hospitality {get;set;}
        public string Accesability {get;set;}
        public string GuestProfile {get;set;}
        public id neweventid {get;set;}
        public transient Competitor_site__c compsite;
        public string compsiteid {get;set;}
        public string compsitename {get;set;}
        public string compsitevillage {get;set;}       
        public id getmyeventid(){return myevents[0].id;} 
        public transient blob file { get; set; }
        public String fN { get; set; }
        public transient feedItem Fi { get; set; }  
        
        
        
        public ContentVersion contentversion {
              get {
                  if (contentversion == null)
                  contentversion = new ContentVersion();
                  return contentversion;
              }
              set;
        }
        
        
        public list<string> mylist{
            get{
            if(mylist == null)
            mylist = new List<string>();
            return mylist;
            }
            set;
            }
              
              
        public void startdate(date startdate)
        {
        this.startdate = startdate;
        }
        
        
        public void starttime(time starttime)
        {
        this.starttime = starttime;
        }
        
        
        public void endtime(time endtime)
        {
        this.endtime = endtime;
        }
               
       
        public void crossoverbrands(String crossoverbrands)
        {
        this.crossoverbrands = crossoverbrands;
        }
        public String getcrossoverbrands(){return crossoverbrands;} //{crossoverbrands = 'Enter Cross Over Brand data here';}
        
        
        public void experience(String experience)
        {
        this.experience = experience;
        } 
        public String getexperience(){return experience;} //{experience = 'Enter Experience data here';}
        
        
        public void shopfits(String shopfits)
        {
        this.shopfits = shopfits;
        }
        public String getshopfits(){return shopfits;} //{shopfits = 'Enter shopfit data here';}
        
        
        public void FoodandBeverage(String FoodandBeverage)
        {
        this.FoodandBeverage = FoodandBeverage;
        }
        public String getFoodandBeverage(){return FoodandBeverage;} //{FoodandBeverage = 'Enter Food and Beverage data here';}
        
        
        public void Hospitality(String Hospitality)
        {
        this.Hospitality = Hospitality;
        }
        public String getHospitality(){return Hospitality;} //{Hospitality = 'Enter Hospitality data here';}
        
        
        public void Accesability(String Hospitality)
        {
        this.Accesability = Accesability;
        }
        public String getAccesability(){return Accesability;} //{Accesability = 'Enter Accessibility data here';}
        
        
        public void GuestProfile(String GuestProfile)
        {
        this.GuestProfile = GuestProfile;
        }
        public String getGuestProfile(){return GuestProfile;} //{GuestProfile = 'Enter Guest Profile data here';}
        
        
        public CompetitorSiteExtension(ApexPages.StandardController controller) {                      
         this.compsite = (Competitor_site__c)Controller.getRecord(); 
         compsiteid = compsite.id;
         compsitename = compsite.name;
         Competitor_Site__c csv = [SELECT competitor_to_Village__r.name from Competitor_Site__c WHERE id =:compsiteid];
         compsitevillage = csv.competitor_to_Village__r.name;
     
        }
        
        
        
        public PageReference addAttachements() {  
                  
             RecordType rt = [SELECT id,name FROM RecordType where Name = 'Competitor Site Visit'];
                     
             Date mydate = startdate;
           //  time mystarttime = starttime;
           //  time myendtime = endtime;
             DateTime Datetimestart = DateTime.newInstance(startdate,starttime);
             DateTime Datetimeend = Datetime.newinstance(startdate,endtime);
           
             event me = new event();
             me.recordtypeid = rt.id;
             me.StartDateTime = Datetimestart;
             me.Share_Competitor_Report__c = true;
             me.EndDateTime = Datetimeend;
             me.Villages_Discussed__c = compsitevillage;
             me.Event_Department__c = 'Leasing/Commercialisation';
             me.Subject = UserInfo.getname() + ' created a competitor Site visit at ' + compsitename + ', competitor to village: ' +  compsitevillage;   
             me.ownerid = UserInfo.getUserid();
             me.whatid = compsiteid;
             me.Description = 
                'Cross Over Brands :' +  CrossOverBrands + '\n' + '\n' +
                'Experience :' + experience + '\n' + '\n' +
                'Shopfits :' + shopfits + '\n' + '\n' +
                'Food & Beverage :' + FoodandBeverage + '\n' + '\n' +
                'Hospitality Service :' + Hospitality + '\n' + '\n' +
                'Accessibility :' + Accesability + '\n' + '\n' +
                'Guest Profile :' + GuestProfile;
             insert me; 
             myevents = [SELECT Id,whatid,Villages_Discussed__c,Ownerid,Subject FROM EVENT WHERE id =:me.id];
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Competitor Site Visit created successfully'));  
             
             return Page.Competitor_Report_Attachments;
         }
        


        public PageReference share() {
         
                string user = UserInfo.getUserid();
                Collaborationgroup chattergroup = [select Id from Collaborationgroup WHERE NAME = 'Competitor Site Visits'];
            
                // Post a feed item that has an @-mention.
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                textSegmentInput.text = 'Competitor Site Report' + '\n' + '\n' +
                        'Village :'  + compsitevillage + '\n' + '\n' +
                        'Cross Over Brands :' +  CrossOverBrands + '\n' + '\n' +
                        'Experience :' + experience + '\n' + '\n' +
                        'Shopfits :' + shopfits + '\n' + '\n' +
                        'Food & Beverage :' + FoodandBeverage + '\n' + '\n' +
                        'Hospitality Service :' + Hospitality + '\n' + '\n' +
                        'Accessibility :' + Accesability + '\n' + '\n' +
                        'Guest Profile :' + GuestProfile + '\n' + '\n' ;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                mentionSegmentInput.id = chattergroup.id ;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = myevents[0].id;
                
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                Fi = [SELECT id from FeedItem WHERE id =: feedelement.id];
                Event ME = [SELECT Chatter_Post_Id__c FROM EVENT WHERE id =: myevents[0].id];
                ME.Chatter_Post_id__c = feedelement.id;
                update ME;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have shared this successfully to the Competitor Site Visits group, please click finish to exit')); 
                PageReference pageRef = new PageReference('/'+compsiteid);
                
                List<FeedAttachment> FAS = new List<FeedAttachment>();
                for (string ids : mylist){
                
                    FeedAttachment postAttachment = new FeedAttachment();
                    postAttachment.FeedEntityId = Fi.id;
                    postAttachment.Type = 'Content';
                    postAttachment.RecordId = ids;
                    //insert postAttachment;  
                    FAS.add(postAttachment);   
                    }
                    insert FAS;
                    return pageref;
         }
         
                 
   
         public PageReference go() {
        
                contentversion.versionData = file;
                contentversion.pathOnClient = fn;
                
            try {
                  insert contentversion;
                  mylist.add(contentversion.id);
                  
                                  
                } catch (DMLException e) {
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
                  return null;
                } finally 
                {
                 contentversion = new ContentVersion(); 
                }
                myattachments = [SELECT id,description,ContentDocumentId,PathOnClient,FileType,title FROM ContentVersion WHERE id in :mylist];
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));  
                return page.Competitor_Report_Attachments;    
        }
        
                   
        public PageReference finish() {
                 
                string user = UserInfo.getUserid();
                Collaborationgroup chattergroup = [select Id from Collaborationgroup WHERE NAME = 'Competitor Site Visits'];
            
                // Post a feed item that has an @-mention.   
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                
                //ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                textSegmentInput.text = 'Competitor Site Report' + '\n' + '\n' +
                        'Village :'  + compsitevillage + '\n' + '\n' +
                        'Cross Over Brands :' +  CrossOverBrands + '\n' + '\n' +
                        'Experience :' + experience + '\n' + '\n' +
                        'Shopfits :' + shopfits + '\n' + '\n' +
                        'Food & Beverage :' + FoodandBeverage + '\n' + '\n' +
                        'Hospitality Service :' + Hospitality + '\n' + '\n' +
                        'Accessibility :' + Accesability + '\n' + '\n' +
                        'Guest Profile :' + GuestProfile + '\n' + '\n' ;
                messageBodyInput.messageSegments.add(textSegmentInput);
                               
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = myevents[0].id;
                
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                Fi = [SELECT id from FeedItem WHERE id =: feedelement.id];
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have shared this successfully to the Competitor Site Visits group, please click finish to exit')); 
                PageReference pageRef = new PageReference('/'+compsiteid);
                
                List<FeedAttachment> imgs = new List<FeedAttachment>();
                for (string ids : mylist){
                
                    FeedAttachment postAttachment = new FeedAttachment();
                    postAttachment.FeedEntityId = Fi.id;
                    postAttachment.Type = 'Content';
                    postAttachment.RecordId = ids;
                    imgs.add(postAttachment);     
                    }
                    //Attach images to post
                    insert imgs;
            
                event myevent = [SELECT Share_Competitor_Report__c from EVENT where id =:myevents[0].id];
                myevent.Share_Competitor_Report__c = false;
                myevent.Chatter_Post_Id__c = feedelement.id;
                update myevent;         
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'FINISHED'));
                PageReference pageReffin = new PageReference('/'+compsiteid);
                return pageReffin;          
            }
            
            
            
           /*   public PageReference uploadnewattachment(){
            
            PageReference pageRef = new PageReference('/'+compsiteid);
            return null;
            }
            
            //Ignore......old code            
               public Attachment attachment {
              get {
              if (attachment == null)
              attachment = new Attachment();
              return attachment;
              }
              set;
        }
    
    
      public PageReference upload() {        

            attachment.OwnerId = UserInfo.getUserId();
            attachment.ParentId = myevents[0].id; // the record the file is attached to
            attachment.IsPrivate = false;
                
            try {
                  insert attachment;
                  myattachments = [SELECT id,Name, description FROM Attachment WHERE Parentid = :myevents[0].id];
                                  
                } catch (DMLException e) {
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
                  return null;
                } finally 
                {
                 attachment = new Attachment(); 
                }

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));              
                return page.Competitor_Report_Attachments;   
            }
            */   
            
}