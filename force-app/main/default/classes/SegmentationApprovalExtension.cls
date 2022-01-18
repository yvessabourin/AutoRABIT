public with sharing class SegmentationApprovalExtension {

	private final Brand_Segmentation_Approval__c segApproval;
    ApexPages.StandardSetController setCon;
    public Id Id { get; set; }
    public String errormessage { get; set;}
    private static final String PERMISSIONSET_APPROVED_BRAND_SEGMENTATION = 'Approve_Brand_Segmentation';
    private static final String APPROVED_STATUS = 'Approved';
  
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SegmentationApprovalExtension(ApexPages.StandardController stdController) {
        this.segApproval = (Brand_Segmentation_Approval__c)stdController.getRecord();
        Id = segApproval.Id;
        errormessage = '';
    }

    public SegmentationApprovalExtension(ApexPages.StandardSetController controller) {
        setCon = controller;
        errormessage = '';
    }

    public PageReference approveSegmentationRecord() {
        // we need to make sure that this user is permissioned to approve this record
        boolean hasPermissionForAction = false;

        try{
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>([SELECT ID FROM PermissionSetAssignment WHERE PermissionSet.Name = :PERMISSIONSET_APPROVED_BRAND_SEGMENTATION AND AssigneeId = :Userinfo.getUserId()]);

            if(!permissionSetAssignmentList.isEmpty()){
                Map<Id,Brand_Segmentation_Approval__c> brandSegmentationApprovalMap = new Map<Id,Brand_Segmentation_Approval__c>();

                // get brand record
                if(segApproval != null){
                    List<Account> accountBrandListSOQL = [Select Id FROM Account WHERE ID = : segApproval.Brand__c];
                    brandSegmentationApprovalMap.put(accountBrandListSOQL[0].Id, segApproval);
                    mappingBrandSegmentationToAccountBrand(brandSegmentationApprovalMap, accountBrandListSOQL);
                    
                    PageReference pageRef = new PageReference('/'+Id);
                    pageRef.setRedirect(true);
                    return pageRef; //Returns to the Segmentation Approval page

                } else if (setCon != null) {
                    // List View - Bulk
                    List<Brand_Segmentation_Approval__c> brandSegApprovalListGetSelect = (Brand_Segmentation_Approval__c[]) setCon.getSelected();

                    if (brandSegApprovalListGetSelect != null && !brandSegApprovalListGetSelect.isEmpty()) {
                        List<Id> brandIdList = new List<Id>();

                        // then its a list to all be approved
                        for (Brand_Segmentation_Approval__c outAccountBrand : brandSegApprovalListGetSelect) {
                            System.debug('Brand Seg Approval: ' + outAccountBrand);
                            brandSegmentationApprovalMap.put(outAccountBrand.Brand__c, outAccountBrand);
                            brandIdList.Add(outAccountBrand.Brand__c);
                        }

                        List<Account> accountBrandList = [Select Id FROM Account WHERE Id in :brandIdList];

                        mappingBrandSegmentationToAccountBrand(brandSegmentationApprovalMap, accountBrandList);

                    } else {
                        errormessage += 'No record was selected to process';
                    }
                }

            } else {
                 errormessage += 'You do not have the permission to perform this action';
            }

        } catch(Exception e){
            System.debug('The following error has occurred.');
            System.debug('Line: ' + e.getLineNumber());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            errormessage += 'An error has occurred. Please contact Support, and quote the following error:\r\n';
            errormessage += ' Exception: ' + e.getMessage();
        }

        if(String.isNotBlank(errormessage)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errormessage));
        } else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Records successfully approved'));
        }

        return null;
    }

    private void mappingBrandSegmentationToAccountBrand(Map<ID,Brand_Segmentation_Approval__c> inBrandSegApprovalMap, List<Account> inAccountBrandList){
        List<Brand_Segmentation_Approval__c> brandSegmentationApprovalList = new List<Brand_Segmentation_Approval__c>();

        System.debug('Mendes');
        for(Account outAccountBrand : inAccountBrandList){
            System.debug(outAccountBrand.Id);
            Brand_Segmentation_Approval__c brandSegApprovalGet = inBrandSegApprovalMap.get(outAccountBrand.Id);

            // now we can set the status to approved, and get the values over to the account
            outAccountBrand.Brand_Gender__c = brandSegApprovalGet.Brand_Gender__c;
            outAccountBrand.Brand_Guest_Relevance__c = brandSegApprovalGet.Brand_Guest_Relevance__c;
            outAccountBrand.Brand_Segment__c = brandSegApprovalGet.Brand_Segment__c;
            outAccountBrand.Brand_Subsegment__c = brandSegApprovalGet.Brand_Subsegment__c;
            outAccountBrand.Brand_VR_Positioning__c = brandSegApprovalGet.Brand_VR_Positioning__c;

            // now also update the approval data
            brandSegApprovalGet.Approval_Date__c = datetime.now();
            brandSegApprovalGet.Status__c = APPROVED_STATUS;

            brandSegmentationApprovalList.add(brandSegApprovalGet);
        }

        update brandSegmentationApprovalList;
        update inAccountBrandList;

        Approval.LockResult[] lockResultsList = Approval.lock(brandSegmentationApprovalList, false);
        // Iterate through each returned result
        for(Approval.LockResult outLockResult : lockResultsList) {
            if (outLockResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully locked account with ID: ' + outLockResult.getId());

            } else {
                // Operation failed, so get all errors
                for(Database.Error err : outLockResult.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug('LockResult: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Brand Segmentation Approval fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

}