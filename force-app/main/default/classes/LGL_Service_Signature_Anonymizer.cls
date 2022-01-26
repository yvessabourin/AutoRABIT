public without sharing class LGL_Service_Signature_Anonymizer {

	@InvocableMethod
	public static void deleteSignatureAttachments (List <Id> objectIds) {

		List <ContentVersion> signatureAttachmentsVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId IN: objectIds AND Title LIKE '%signature%'];
        if(signatureAttachmentsVersions.isEmpty()) return;
        
        Set<Id> contDocumentIds = new Set<Id>();
        for(ContentVersion cv: signatureAttachmentsVersions){
            contDocumentIds.add(cv.ContentDocumentId);
        }
        
        List <ContentDocument> signatureAttachments = [SELECT Id FROM ContentDocument WHERE Id IN :contDocumentIds];
		delete signatureAttachments;
	}

}