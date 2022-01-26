public class DownloadAdbuilderController {
    
        public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="2.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public DownloadAdbuilderController(ApexPages.StandardController controller) {

    }
    
    @AuraEnabled
    public static String getLink(String recordId){
        Adbuilder__c rec = [SELECT Id, Format__c FROM Adbuilder__c WHERE Id = :recordId];
        
        String vfPage = null;
        
        if(rec.Format__c == 'Facebook Canvas'){
            vfPage = 'DownloadAdbuilderCanvasPage';
        }
        else if(rec.Format__c == 'Facebook Carousel' || rec.Format__c == 'Instagram Carousel'){
            vfPage = 'DownloadAdbuilderCarouselPage';
        }
        else if(rec.Format__c == 'Instagram Story'){
            vfPage = 'DownloadAdbuilderInstagramStoryPage';
        }
        else if(rec.Format__c == 'Facebook Image Link Ad'){
            vfPage = 'DownloadAdbuilderImageLinkAdPage';
        }
        else if(rec.Format__c == 'Image Post Page'){
            vfPage = 'DownloadAdbuilderImagePostPage';
        }
        else if(rec.Format__c == 'Video Link Ad'){
            vfPage = 'DownloadAdbuilderVideoLinkAdPage';
        }
        else if(rec.Format__c == 'Video Post Page'){
            vfPage = 'DownloadAdbuilderVideoPostPage';
        }
        
        if(vfPage == null) return null;
        
        return '/apex/' + vfPage + '?id=' + rec.Id;
    }
    
}