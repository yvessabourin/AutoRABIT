public with sharing class HFSOperationGuidesTilesController {
    
    @AuraEnabled
    public static List<Document> getDocuments() {
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
        String userLanguage = u.LanguageLocaleKey;
        
        if(userLanguage == 'Español'){
            List<Document> someDocuments = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - ESP'];
            return someDocuments;
        } else if(userLanguage == 'Deutsch'){
            List<Document> someDocuments = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - GER'];
            return someDocuments;
        } else if(userLanguage == 'Français'){
            List<Document> someDocuments = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - FR'];
            return someDocuments;
        } else if(userLanguage == 'Italiano'){
            List<Document> someDocuments = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - IT'];
            return someDocuments;
        } else {
            List<Document> someDocuments = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - EN'];
            return someDocuments;
        }
    }
    
    @AuraEnabled
    public static string DownloadAttachment(Id DownloadAttachmentID) {
        
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
        String userLanguage = u.LanguageLocaleKey;
        
        if(userLanguage == 'Español'){
            Document theDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - ESP' AND Id = :DownloadAttachmentID];
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String UrlDownload = baseUrl +'/brands/servlet/servlet.FileDownload?file='+theDocument.Id;
            return UrlDownload;
        } else if(userLanguage == 'Deutsch'){
            Document theDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - GER' AND Id = :DownloadAttachmentID];
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String UrlDownload = baseUrl +'/brands/servlet/servlet.FileDownload?file='+theDocument.Id;
            return UrlDownload;
        } else if(userLanguage == 'Français'){
            Document theDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - FR' AND Id = :DownloadAttachmentID];
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String UrlDownload = baseUrl +'/brands/servlet/servlet.FileDownload?file='+theDocument.Id;
            return UrlDownload;
        } else if(userLanguage == 'Italiano'){
            Document theDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - IT' AND Id = :DownloadAttachmentID];
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String UrlDownload = baseUrl +'/brands/servlet/servlet.FileDownload?file='+theDocument.Id;
            return UrlDownload;
        } else {
            Document theDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name = 'HFS Operational Guides - EN' AND Id = :DownloadAttachmentID];
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String UrlDownload = baseUrl +'/brands/servlet/servlet.FileDownload?file='+theDocument.Id;
            return UrlDownload;
        }

    } 
}