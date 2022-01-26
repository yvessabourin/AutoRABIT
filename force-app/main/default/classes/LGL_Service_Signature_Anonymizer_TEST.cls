@isTest
public class LGL_Service_Signature_Anonymizer_TEST {

    private static String encodedSignature = 'iVBORw0KGgoAAAANSUhEUgAAAPoAAACW';

    static testmethod void attachmentDeletionTest() {
        
        LGL_Testing_Utils.createServiceOfferingHierarchy();

        Map <String, LGL_Service_Offering__c> serviceOfferingsMap = LGL_Testing_Utils.getServiceOfferingsMap('Bicester');
        LGL_Service__c serviceRequestBTA = LGL_Testing_Utils.createServiceRequest(serviceOfferingsMap.get('Bicester The Apartment_lLugg').LGL_Service_Offering_Location__c);
        insert serviceRequestBTA;
        
        List <LGL_Service_Item__c> serviceItemsBTAList = new List <LGL_Service_Item__c> ();
        serviceItemsBTAList.add(LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_lLugg').Id,'lLugg1'));
        serviceItemsBTAList.add(LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair1'));
        serviceItemsBTAList.add(LGL_Testing_Utils.createServiceItem(serviceRequestBTA.Id, serviceOfferingsMap.get('Bicester The Apartment_pChair').Id,'pChair2'));  
        insert serviceItemsBTAList;

        LGL_DashController.insertSignature(serviceRequestBTA.Id, encodedSignature, LGL_DashController.SAVE_REQUEST_SIGNATURE_NAME);

        List <ContentVersion> attachments = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: serviceRequestBTA.Id];

        system.assertEquals(1, attachments.size());

        LGL_Service_Signature_Anonymizer.deleteSignatureAttachments(new List <Id> {serviceRequestBTA.Id});
        
        attachments = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: serviceRequestBTA.Id];
        
        system.assertEquals(0, attachments.size());

    }
}