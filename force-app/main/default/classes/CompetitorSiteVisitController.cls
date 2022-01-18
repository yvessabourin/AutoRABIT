Global Class CompetitorSiteVisitController{

  public date startdate {get;set;}
  public List<Event> myevents {get;set;} 
  public transient List<ContentVersion> myattachments {get;set;}
  public string experience {get;set;}
  public transient Competitor_site__c compsite;
  public string compsiteid {get;set;}
  public string compsitename {get;set;}
  public string compsitevillage {get;set;}       
  public transient blob file { get; set; }
  public String fn { get; set; }  
  public String recType {get;set;}
  public Competitor_Site__c csv {get;set;}
  public Competitor_Visit__c cv {get;set;}
  public boolean isMobile {get;set;}
  public string compName {get;set;}
  public Date dateToday {get;set;}
  public id listViewId {get;set;}
  public string theURL {get;set;}
  


  public CompetitorSiteVisitController(ApexPages.StandardController controller) {     
  listViewId = [SELECT id FROM ListView WHERE SobjectType = 'Competitor_site__c' AND Name = 'All'].id;
  compsite = (Competitor_site__c)Controller.getRecord(); 
  compsiteid = compsite.id;
  system.debug('compsiteid :' + compsiteid);
  cv = new Competitor_Visit__c();
  cv.Retail_Discount__c = 'Select Retail Discount';
  cv.General_Presentation__c = 'Select General Presentation';
  cv.Customer_Service__c = 'Select Customer Services';
  cv.Extra_Services__c = 'Select Extra Services';
  cv.Food_Beverage_Options__c = 'Select Food & Beverages';
  cv.Overall_Experience__c = 'Select Overall Experience';
  string userisMobile = UserInfo.getUiTheme();
  isMobile = !userisMobile.contains('Theme4t');  
  dateToday = system.today();
  Competitor_site__c cs = [Select id, name FROM Competitor_site__c WHERE id =: compsiteid ];
  compName = cs.name;
  theuRL = URL.getSalesforceBaseUrl().toExternalForm();
  }



  public List<SelectOption> getOveralls() {
    List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Competitor_Visit__c.Overall_Experience__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      SelectOption placeholder = new SelectOption('Select Overall Experience','Select Overall Experience',true);
      options.add(placeholder);
      for( Schema.PicklistEntry pickListVal : ple){
      options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
      }      
    return options;
  }

  public List<SelectOption> getFoodBeverage() {
    List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Competitor_Visit__c.Food_Beverage_Options__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      SelectOption placeholder = new SelectOption('Select Food & Beverages','Select Food & Beverages',true);
      options.add(placeholder);
      for( Schema.PicklistEntry pickListVal : ple){
      options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
      }      
    return options;
  }


  public List<SelectOption> getExtras() {
    List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Competitor_Visit__c.Extra_Services__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      SelectOption placeholder = new SelectOption('Select Extra Services','Select Extra Services',true);
      options.add(placeholder);
      for( Schema.PicklistEntry pickListVal : ple){
      options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
      }      
    return options;
  }



  public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Competitor_Visit__c.Retail_Discount__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      SelectOption placeholder = new SelectOption('Select Retail Discount','Select Retail Discount',true);
      options.add(placeholder);
      for( Schema.PicklistEntry pickListVal : ple){
      options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
      }      
    return options;
  }

  public List<SelectOption> getPresentations() {
    List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Competitor_Visit__c.General_Presentation__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      SelectOption placeholder = new SelectOption('Select General Presentation','Select General Presentation',true);
      options.add(placeholder);
      for( Schema.PicklistEntry pickListVal : ple){
      options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
      }      
    return options;
  }

  public List<SelectOption> getServices() {
    List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = Competitor_Visit__c.Customer_Service__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      SelectOption placeholder = new SelectOption('Select Customer Services','Select Customer Services',true);
      options.add(placeholder);
      for( Schema.PicklistEntry pickListVal : ple){
      options.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
      }      
    return options;
  }

      
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
        
        
  public void startdate(date startdate){
  this.startdate = startdate;
  }
  
         
  public PageReference addAttachements() {  
            
      RecordType rt = [SELECT id,name FROM RecordType where sObjectType = 'Competitor_Visit__c' AND Name =:recType ];     

      if(cv.General_Presentation__c != NULL){
        string newStr = '';
          for (string str : cv.General_Presentation__c.split(',') ){
              if(str.contains('[')){
                str = str.right(str.length()-1);
              }
              if(str.contains(']')){
                str = str.left(str.length()-1);
              }
              newStr = newStr + str + ';';
        }
        cv.General_Presentation__c = newStr;
      }    


      if(cv.Customer_Service__c != NULL){
        string newStr = '';
          for (string str : cv.Customer_Service__c.split(',') ){
              if(str.contains('[')){
                str = str.right(str.length()-1);
              }
              if(str.contains(']')){
                str = str.left(str.length()-1);
              }
              newStr = newStr + str + ';';
        }
        cv.Customer_Service__c = newStr;
      } 

      if(cv.Extra_Services__c != NULL){
        string newStr = '';
          for (string str : cv.Extra_Services__c.split(',') ){
              if(str.contains('[')){
                str = str.right(str.length()-1);
              }
              if(str.contains(']')){
                str = str.left(str.length()-1);
              }
              newStr = newStr + str + ';';
        }
        cv.Extra_Services__c = newStr;
      } 
        
       CV.Recordtypeid = rt.id; 
       cv.Competitor_Site__c = compsiteid;
       CV.Date_of_Visit__c = startdate;
       insert cv; 
       
       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Record created successfully'));  
       
       return Page.Competitor_Report_AttachmentsV2;
   }
     

   public PageReference go() {
  
          contentversion.versionData = file;
          contentversion.pathOnClient = fn;
          contentversion.FirstPublishLocationId = cv.id;
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
          return page.Competitor_Report_AttachmentsV2;    
  }


  public PageReference toNextPage() {
    PageReference pageRef = page.Competitor_Report_CreateV2; 
    system.debug('recType' + recType);
    return pageRef;
  }


  public PageReference finishUp() {
    PageReference pageRef = new PageReference('/'+cv.Id);
    return pageRef;
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

private static Competitor_Visit__c getVisits(String acctId) {
  list<Competitor_Visit__c> cvs = [SELECT Id, Name
                            FROM Competitor_Visit__c
                            WHERE Id =: acctId];
  if(cvs.isEmpty()) {
      return null;
  } else {
      return cvs[0];
  }
}
    
}