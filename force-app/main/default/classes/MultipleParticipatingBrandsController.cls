public with sharing class MultipleParticipatingBrandsController {
    
    @AuraEnabled
    public static String getMarketingActivityName(String recordId) {
        return [SELECT Id, Name FROM Marketing_Activity__c WHERE Id = :recordId].Name;
    }
    
    /* massEditBrandActivities aura component */    
    @AuraEnabled        
    public static Map<String,String> getPicklistValues(String objectAPIName, String fieldAPIName, Boolean notRequired){
        Map<String,String> pickListValuesMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(fieldAPIName).getDescribe();
        //Boolean isFieldNotRequired = fieldResult.isNillable();
        if(notRequired){
            pickListValuesMap.put('', '');
        }
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isActive()){
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
            }
        }
        return pickListValuesMap;
    }
    
    @AuraEnabled
    public static List<Participating_Brand__c> getParticipatingBrands(String recordId) {
        List<Participating_Brand__c> partBrandsList = [SELECT Id, Village_Presence__c, Village_Presence__r.Name, Village_Presence__r.Brand__r.Name, Discount__c, Discount_Percentage__c, Minimum_Purchase__c, Minimum_Purchase_Amount__c,
                                                       Gift_With_Purchase__c, Gift_With_Purchase_Type__c, Feature_Details__c, Status__c, Participating_Brand_Link__c    
                                                       FROM Participating_Brand__c 
                                                       WHERE Marketing_Activity__c = :recordId
                                                       ORDER BY Village_Presence__r.Brand__r.Name];
        return partBrandsList;
    }
       
    @AuraEnabled
    public static String updateParticipantBrands(List<Participating_Brand__c> partBrands, Map<String, String> statusChangedRows){
        Map<Id, Participating_Brand__c> partBrandsMap = new Map<Id, Participating_Brand__c>(partBrands);
        for(Participating_Brand__c pb: partBrandsMap.values()){
            if(pb.Discount__c != null){ 
                pb.Discount__c = boolean.valueOf(pb.get('Discount__c')) ? 'Yes' : 'No'; 
            }
            if(pb.Minimum_Purchase__c != null){ 
                pb.Minimum_Purchase__c = boolean.valueOf(pb.get('Minimum_Purchase__c')) ? 'Yes' : 'No'; 
            }
            if(pb.Gift_With_Purchase__c != null){ 
                pb.Gift_With_Purchase__c = boolean.valueOf(pb.get('Gift_With_Purchase__c')) ? 'Yes' : 'No'; 
            }
        }
        for(String pbId: statusChangedRows.keySet()){
            if(partBrandsMap.containsKey(pbId)){
                partBrandsMap.get(pbId).Status__c = statusChangedRows.get(pbId);
            }
            else{
                partBrandsMap.put(pbId, new Participating_Brand__c(Id = pbId, Status__c = statusChangedRows.get(pbId)));
            }
        }
        try{
            update partBrandsMap.values();
            return null;
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    /* AddRemoveParticipatingBrands aura component */
    @AuraEnabled
    public static List<ParticipatingBrandWrapper> getPotentialParticipatingBrands(String recordId) {
        
        //get the Activity information
        Marketing_Activity__c cMarketingActivity = [SELECT Id, Name, Marketing_Campaign__r.village__c  FROM Marketing_Activity__c  WHERE Id = :recordId];
        
        //get all the Village Presence records for the campaign village
        List<Village_Presence__c> villagePresenceList = [SELECT Id, Name, Brand__c, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.Name,
                                                         Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                                                         Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, Status__c
                                                         FROM Village_Presence__c 
                                                         WHERE village__c = :cMarketingActivity.Marketing_Campaign__r.Village__c AND (Status__c = 'Trading' or Status__c = 'Deal Pending')
                                                         ORDER BY Brand__r.Name];    
        if (villagePresenceList.isEmpty()){
            string msg = 'There are no villages associated with the marketing activity.';
            msg += ' Brands can only be associated to activities which are part of a marketing campaign associated to one or more village(s)';           
            throw new ParticipatingBrandException(msg);
        }
        
        Map<Id, ParticipatingBrandWrapper> returnMap = new Map<Id, ParticipatingBrandWrapper>();

        //retrieve existing Participating Brands for activity
        List<Participating_Brand__c> existingParticipatingBrands = [SELECT id, Village_Presence__c, Account__c, Primary_Marketing_Contact__r.Name, Feature_Details__c, Status__c,  Marketing_Activity__c,
                                                                    Village_Presence__r.Marketing_Approval_End_Date__c, Village_Presence__r.Marketing_Approval_Start_Date__c, Village_Presence__r.Marketing_Manager__r.Name,
                                                                    Village_Presence__r.Approval_Comments__c, Village_Presence__r.Status__c, Village_Presence__r.Brand__c, Village_Presence__r.Expected_Exit_Date__c, 
                                                                    Village_Presence__r.Brand__r.Market_Position__c, Village_Presence__r.Brand__r.Group_Marketing__c, Village_Presence__r.Brand__r.Department__c, 
                                                                    Village_Presence__r.Social_Marketing__c, Village_Presence__r.Website_Marketing__c, Village_Presence__r.Email_Marketing__c,
                                                                    Village_Presence__r.Brand__r.Name
                                                                    FROM Participating_Brand__c
                                                                    WHERE Marketing_Activity__c = :cMarketingActivity.id
                                                                    ORDER By Village_Presence__r.Brand__r.Name
                                                                   ];
        
        for(Participating_Brand__c pb: existingParticipatingBrands){
            returnMap.put(pb.Village_Presence__c, new ParticipatingBrandWrapper(pb));
        }
        
        //Add VPs to custom class for display
        for (Village_Presence__c vp : villagePresenceList){
            if(returnMap.containsKey(vp.Id)) continue;
            returnMap.put(vp.Id, new ParticipatingBrandWrapper(vp));
        }  
        
        List<ParticipatingBrandWrapper> returnListSorted = returnMap.values();
        returnListSorted.sort();
        return returnListSorted;
    }
    
    @AuraEnabled
    public static String savePotentialBrands(String recordId, String selectedListJSON) {
        
        List<ParticipatingBrandWrapper> selectedList = (List<ParticipatingBrandWrapper>)JSON.deserialize(selectedListJSON, List<ParticipatingBrandWrapper>.class);
        
        Map<String, ParticipatingBrandWrapper> selectedPartBrandByVilPresId = new Map<String, ParticipatingBrandWrapper>();
        for(ParticipatingBrandWrapper pbw: selectedList){
            selectedPartBrandByVilPresId.put(pbw.vpId, pbw);
        }
        
        List<Participating_Brand__c> existingParticipatingBrands = [SELECT id, Village_Presence__c, Account__c, Primary_Marketing_Contact__r.Name, Feature_Details__c, Status__c,  Marketing_Activity__c,
                                                                    Village_Presence__r.Marketing_Approval_End_Date__c, Village_Presence__r.Marketing_Approval_Start_Date__c, Village_Presence__r.Marketing_Manager__r.Name,
                                                                    Village_Presence__r.Approval_Comments__c, Village_Presence__r.Status__c, Village_Presence__r.Brand__c, Village_Presence__r.Expected_Exit_Date__c, 
                                                                    Village_Presence__r.Brand__r.Market_Position__c, Village_Presence__r.Brand__r.Group_Marketing__c, Village_Presence__r.Brand__r.Department__c, 
                                                                    Village_Presence__r.Social_Marketing__c, Village_Presence__r.Website_Marketing__c, Village_Presence__r.Email_Marketing__c,
                                                                    Village_Presence__r.Brand__r.Name
                                                                    FROM Participating_Brand__c
                                                                    WHERE Marketing_Activity__c = :recordId
                                                                    ORDER By Village_Presence__r.Brand__r.Name
                                                                   ];
        
        Map<String, Participating_Brand__c> existingPartBrandByVilPresId = new Map<String, Participating_Brand__c>();
        for(Participating_Brand__c pb: existingParticipatingBrands){
            existingPartBrandByVilPresId.put(pb.Village_Presence__c, pb);
        }
        
        
        // Isolate the existing Participating Brands that were not selected and delete them
        Set<String> partBrandsExistingNotSelected = existingPartBrandByVilPresId.keySet().clone();
        partBrandsExistingNotSelected.removeAll(selectedPartBrandByVilPresId.keySet());
        
        List<Participating_Brand__c> partBrandsToDelete = new List<Participating_Brand__c>();
        for(String vpId: partBrandsExistingNotSelected){
            partBrandsToDelete.add(existingPartBrandByVilPresId.get(vpId));
        }
                
        // Isolate the selected Participating Brands that are not created and create them
        Set<String> partBrandsSelectedNotExisting = selectedPartBrandByVilPresId.keySet().clone();
        partBrandsSelectedNotExisting.removeAll(existingPartBrandByVilPresId.keySet());
        
        List<Participating_Brand__c> partBrandsToInsert = new List<Participating_Brand__c>();
        for(String vpId: partBrandsSelectedNotExisting){
            ParticipatingBrandWrapper pbw = selectedPartBrandByVilPresId.get(vpId);
            
            Participating_Brand__c newPartBrand = new Participating_Brand__c();
            newPartBrand.Village_Presence__c = vpId;
            newPartBrand.Status__c = 'Target';
            newPartBrand.Marketing_Activity__c = recordId;
            newPartBrand.Account__c = pbw.account;
            partBrandsToInsert.add(newPartBrand);
        }
        
        try{
            delete partBrandsToDelete;
            insert partBrandsToInsert;
        }
        catch(Exception ex){
            return ex.getMessage();
        }
        return null;
    }
    
    public class ParticipatingBrandWrapper implements Comparable{
        @AuraEnabled public String  vpId {get;set;}
        @AuraEnabled public String  vpName {get;set;}
        @AuraEnabled public String  vpUrl {get;set;}
        @AuraEnabled public String  vpStatus {get;set;}
        @AuraEnabled public String  primaryMarketingContact {get;set;}
        @AuraEnabled public String  approvalEndDate {get;set;}
        @AuraEnabled public String  approvalStartDate {get;set;}
        @AuraEnabled public String  marketingManager {get;set;}
        @AuraEnabled public String  preApproval {get;set;}
        @AuraEnabled public String  marketPosition {get;set;}
        @AuraEnabled public String  approvalComment {get; set;}
        @AuraEnabled public Boolean groupMarketing {get;set;}
        @AuraEnabled public String  department {get;set;}
        @AuraEnabled public String  brandExitDate {get;set;}
        @AuraEnabled public Id  	account {get;set;}
        @AuraEnabled public String  featureDetails {get;set;}
        @AuraEnabled public String  status {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        
        public ParticipatingBrandWrapper(Village_Presence__c vp){
            this.vpUrl = '/' + vp.id;
            this.vpId = vp.id;
            this.vpName = vp.Brand__r.Name;
            
            this.approvalEndDate = vp.Marketing_Approval_End_Date__c != null ? vp.Marketing_Approval_End_Date__c.format() : '';
            this.approvalStartDate = vp.Marketing_Approval_Start_Date__c != null ? vp.Marketing_Approval_Start_Date__c.format() : '';
            this.marketingManager = vp.Marketing_Manager__r.name;
            this.approvalComment = vp.Approval_Comments__c;
            this.vpStatus = vp.Status__c;
            this.account = vp.Brand__c;
            
            this.brandExitDate = vp.Expected_Exit_Date__c != null ? vp.Expected_Exit_Date__c.format() : '';
            
            this.marketPosition = vp.Brand__r.Market_Position__c;
            this.groupMarketing = vp.Brand__r.Group_Marketing__c;
            this.Department = vp.Brand__r.Department__c;
            
            string marketingApprovals = '';
            marketingapprovals += vp.Social_Marketing__c == 'yes' ? 'Social|' : '';
            marketingapprovals += vp.Website_Marketing__c == 'yes' ? 'Website|' : '';
            marketingapprovals += vp.Email_Marketing__c == 'yes' ? 'Email' : '';
            this.preApproval = marketingApprovals;
            this.isSelected = false;
        }
        
        public ParticipatingBrandWrapper(Participating_Brand__c pb){
            this(pb.Village_Presence__r);
            
            this.featureDetails = pb.Feature_Details__c;
            this.status = pb.Status__c;
            this.primaryMarketingContact = pb.Primary_Marketing_Contact__r.Name;            
            this.isSelected = true;
        }
        
        public Integer compareTo(Object compareTo) {
            ParticipatingBrandWrapper compareObj = (ParticipatingBrandWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.vpName > compareObj.vpName) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.vpName < compareObj.vpName) {
                // Set return value to a negative value.
                returnValue = -1;
            }      
            return returnValue;       
        }
    }
    
    public class ParticipatingBrandException extends Exception {}
}