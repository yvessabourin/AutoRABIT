Global Class CompetitorVisitAddAttachmentsExt{

    public Competitor_Visit__c visit {get;set;}
    public id visitId {get;set;}
    public transient List<ContentVersion> myattachments {get;set;}
    public string compName {get;set;}
    public Date dateToday {get;set;}
    public String fn { get; set; }  
    public transient blob file { get; set; }
    public Competitor_Visit__c cv {get;set;}

    Public CompetitorVisitAddAttachmentsExt(ApexPages.StandardController sc){
        visit = (Competitor_Visit__c)sc.getRecord(); 
        visitId = visit.id;  
        Competitor_Visit__c cv = [Select id, name,Competitor_Site__r.name FROM Competitor_Visit__c WHERE id =: visitId ];
        compName = cv.Competitor_Site__r.name;
        dateToday = system.today();
    }
    

    @RemoteAction
    public static String doUploadAttachment(String cvId, String attachmentBody, String attachmentName, String attachmentId) {
        if(cvId != null) {
            Competitor_Visit__c cvs = getVisits(cvId);
            if(cvs != null) {
                if(attachmentBody != null) {
                
                list<CollaborationGroup > siteGroup = [SELECT id, NAME FROM CollaborationGroup WHERE name = 'Competitor Site Visits' LIMIT 1 ];
                
                    ContentVersion contVers = getContentVersion(attachmentId);
                    String newBody = '';
                    if(contVers.VersionData != null) {
                        newBody = EncodingUtil.base64Encode(contVers.VersionData);
                    }
                    newBody += attachmentBody;
                    contVers.VersionData = EncodingUtil.base64Decode(newBody);
                    list<string> listIds = new list<string>();
                    if(attachmentId == null) {
                        contVers.Title = attachmentName;
                        contVers.PathOnClient = attachmentName + '.jpg';
                        contVers.FirstPublishLocationId = cvs.Id;
                        contVers.ContentLocation = 'S';
                        contVers.SharingPrivacy = 'N';
                    }
                    upsert contVers;
                    listIds.add(contVers.id);
                    
                    //--------------
                    list<ContentVersion> theAttachments = [SELECT id,description,ContentDocumentId,PathOnClient,FileType,title FROM ContentVersion WHERE id in :listIds];
                    list<string> contDocIds = new list<string>();
                    for(ContentVersion cv : theAttachments)
                    {
                        contDocIds.add(cv.ContentDocumentId);          
                    }
                    
                    list<ContentDocumentLink> links = new list<ContentDocumentLink>();
                    
                    for(string id : contDocIds){
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.Visibility = 'AllUsers';
                        cdl.LinkedEntityId = siteGroup[0].id;
                        cdl.ShareType = 'V';
                        cdl.ContentDocumentId = id;
                        links.add(cdl);
                    }
                    insert links;
                  
                    //----------------
                    return contVers.Id;
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
   
    private static ContentVersion getContentVersion(String cvId) {
        list<ContentVersion> contVers = [SELECT Id, VersionData 
                                        FROM ContentVersion 
                                        WHERE Id =: cvId];
        if(contVers.isEmpty()) {
            ContentVersion cv = new ContentVersion();
            return cv;
        } else {
            return contVers[0];
        }
    }


    private static Competitor_Visit__c getVisits(String visId) {
        list<Competitor_Visit__c> cvs = [SELECT Id, Name
                                  FROM Competitor_Visit__c
                                  WHERE Id =: visId];
        if(cvs.isEmpty()) {
            return null;
        } else {
            return cvs[0];
        }
    }
    
    public ContentVersion contentversion {
              get {
                  if (contentversion == null)
                  contentversion = new ContentVersion();
                  return contentversion;
              }
              set;
    }
    
    public PageReference go() {
        
                contentversion.versionData = file;
                contentversion.pathOnClient = fn;
                contentversion.FirstPublishLocationId = visitId;
                system.debug('go called ');
                
            try {
                  insert contentversion;
                  mylist.add(contentversion.id);
                  system.debug('mylist ' + mylist);
                  
                                  
                } catch (DMLException e) {
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
                  return null;
                } finally 
                {
                 contentversion = new ContentVersion(); 
                }
                system.debug('1st debug: ');
                myattachments = [SELECT id,description,ContentDocumentId,PathOnClient,FileType,title FROM ContentVersion WHERE id in :mylist];
                system.debug('2nd debug: ');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));  
                return null;
                //return page.Competitor_Report_AttachmentsV2;    
        }
  
  
      public list<string> mylist{
                get{
                if(mylist == null)
                mylist = new List<string>();
                return mylist;
                }
                set;
       }
}