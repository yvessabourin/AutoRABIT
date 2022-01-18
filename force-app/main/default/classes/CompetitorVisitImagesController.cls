Public Class CompetitorVisitImagesController{
    
    
    String userAgent {get;set;}
    public list<contentversion> images {get;set;}
    public id visitId {get;set;}
    public list<id> ids {get;set;}
    public boolean show {get;set;}
    public list<string> fileIdsLtg {get;set;}
    private static final List<String> fileExtensions = new List<String>{'JPG', 'PNG'};

    public ContentVersion contentversion {
        get {
            if (contentversion == null)
                contentversion = new ContentVersion();
            return contentversion;
        }
        set;
    }
    
    Public CompetitorVisitImagesController(ApexPages.StandardController sc){
        fileIdsLtg = new List<String>();
        
        string isMobile = UserInfo.getUiTheme();
        show = !isMobile.contains('Theme4t');
        visitId = sc.getid(); 
        
        //List<ContentVersion> cvList = [SELECT Id FROM ContentVersion];
        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId = :visitId AND FileType IN :fileExtensions];
        //List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE LinkedEntityId = :visitId AND FileType IN :fileExtensions];
        
        for(ContentVersion cv : cvList ){
            fileIdsLtg.add(cv.Id);
        }
    }
    
    
    
}