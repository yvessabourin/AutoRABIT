public with sharing class bulkAddBrandParticipantsController { 
    
    //properties
    public Marketing_Activity__c cMarketingActivity { get; set; }
    public list<Village_Presence__c> VillagePresences{ get; set; }
    public list<ParticipantBrand> ParticipantBrandList  { get; set; }
    public list<Participating_Brand__c> ExistingParticipantBrands { get; set; }
    public list<Participating_Brand__c> SelectedParticipantBrands { get; set; }
    private map<id, Participating_Brand__c> ExistingParticipantBrandsMap { get; set;}
    
    //Brand Participation values
    public string  defaultstatus { get; set; }
    public string  ApplyFeature_Details {get;set;}
    public boolean allSelected{get; set;}
    public boolean enableSave{get; set;}
    public string defaultDiscount { get; set;}
    public string ApplyDiscount_Percentage{get; set;}
    public string defaultMinimumPurchase{get; set;}
    public string ApplyMinimumPurchase_Amount{get; set;}
    public string defaultGiftWithPurchase{get; set;}
    public string ApplyGiftWithPurchase_Type{get; set;}
    
    public bulkAddBrandParticipantsController () {
        
        enableSave = true;
        //defaultstatus = 'Bobby';
        //ApplyFeature_Type = 'Type';
        //ApplyFeature_Details = 'Details';
        
        //get the Activity information
        cMarketingActivity = [SELECT Id, Name, Marketing_Campaign__r.village__c  FROM Marketing_Activity__c
                              WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
        //get all the Village Presence records for the campaign village
        VillagePresences = [SELECT Id, Name, Brand__r.Name, Marketing_Approval_End_Date__c, Marketing_Approval_Start_Date__c, Marketing_Manager__r.name,
                            Social_Marketing__c, Website_Marketing__c, Email_Marketing__c, Contract_Expiry_Date__c , Expected_Exit_Date__c,
                            Brand__r.Market_Position__c,  Brand__r.Group_Marketing__c,  Brand__r.Department__c, Approval_Comments__c, status__c
                            FROM Village_Presence__c WHERE village__c = :cMarketingActivity.Marketing_Campaign__r.village__c 
                            AND (Status__c = 'Trading' or Status__c = 'Deal Pending')
                            ORDER BY Brand__r.Name];    
        
        if (VillagePresences.isEmpty()){
            string msg = 'There are no villages associated with the marketing activity.';
            msg += ' Brands can only be asociated to activities which are part of a marketing campaign associated to one or more village(s)';           
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
            enableSave = false;
        }
        
        //retrieve existing Participating Brands for activity
        ExistingParticipantBrands  = [SELECT id, Village_Presence__c,Account__c, Primary_Marketing_Contact__r.name, Feature_Details__c, Status__c,  Marketing_Activity__c  FROM Participating_Brand__c WHERE Marketing_Activity__c = :cMarketingActivity.id];
        
        //populate the ExistingParticipantBrandsMap for lookup
        
        //initialize Map
        ExistingParticipantBrandsMap = new map<id,Participating_Brand__c>();
        //populate Map for lookup (where the Village Presence is the key) - so that it can be used to pre-select existing participating brands
        for (Participating_Brand__c cExistingParticipantBrand : ExistingParticipantBrands)
        {
            ExistingParticipantBrandsMap.put(cExistingParticipantBrand.Village_Presence__c, cExistingParticipantBrand);  
        }
        
        //initialize list
        ParticipantBrandList = new list<ParticipantBrand>();
        allSelected = true;
        
        //Add VPs to custom class for display
        for (Village_Presence__c VP : VillagePresences ){
            ParticipantBrand cPBtoAdd = new ParticipantBrand();
            cPBtoAdd.VP_id = VP.id;
            cPBtoAdd.VP_Name = VP.Brand__r.Name;
            ///
            cPBtoAdd.Approval_End_Date = VP.Marketing_Approval_End_Date__c;
            cPBtoAdd.Approval_Start_Date = VP.Marketing_Approval_Start_Date__c; 
            cPBtoAdd.Marketing_Manager = VP.Marketing_Manager__r.name;
            cPBtoAdd.Approval_Comment = VP.Approval_Comments__c;
            cPBtoAdd.VPStatus = VP.Status__c;
            cPBtoAdd.Account = VP.Brand__r.id;
            
            if (VP.Expected_Exit_Date__c != null){
                string dt = VP.Expected_Exit_Date__c.format();
                cPBtoAdd.brand_exit_date = dt;
            }
            
            cPBtoAdd.Market_Position = VP.Brand__r.Market_Position__c;
            cPBtoAdd.Group_Marketing = VP.Brand__r.Group_Marketing__c;
            cPBtoAdd.Department = VP.Brand__r.Department__c;
            
            string marketingapprovals = '';
            marketingapprovals += VP.Social_Marketing__c == 'yes' ? 'Social|' : '';
            marketingapprovals += VP.Website_Marketing__c == 'yes' ? 'Website|' : '';
            marketingapprovals += VP.Email_Marketing__c == 'yes' ? 'Email' : '';
            
            cPBtoAdd.Pre_approval = marketingapprovals  ;
            
            if(ExistingParticipantBrandsMap.get(VP.id) == null){
                cPBtoAdd.selected = false; //not found
                cPBtoAdd.AlreadyExists = false;
                allSelected = false;
            }
            else {//exists
                //cPBtoAdd.selected = true; 
                cPBtoAdd.AlreadyExists = true;
                cPBtoAdd.Feature_Details = ExistingParticipantBrandsMap.get(VP.id).Feature_Details__c;
                cPBtoAdd.Status = ExistingParticipantBrandsMap.get(VP.id).Status__c;
                cPBtoAdd.Primary_Marketing_Contact = ExistingParticipantBrandsMap.get(VP.id).Primary_Marketing_Contact__r.name;            
            }
            
            ParticipantBrandList.add(cPBtoAdd);
        }  
        
        
    }//close controller
    
    
    
    public PageReference save() {
        
        SelectedParticipantBrands = new list<Participating_Brand__c >();
        
        for(ParticipantBrand cParticipantBrand : ParticipantBrandList)
        {
            //remove existing particiating brands from ExistingParticipantBrandsMap that are still selected
            for(id ExistingBrandid : ExistingParticipantBrandsMap.keySet()){
                if(ExistingBrandid == cParticipantBrand.VP_id && !cParticipantBrand.selected && cParticipantBrand.AlreadyExists){ //if *not* selected AND was an existing participant
                    ExistingParticipantBrandsMap.remove(ExistingBrandid); //then remove it from the list
                }
            }
        }
        if (!ExistingParticipantBrandsMap.isEmpty()){
            List <Participating_Brand__c> ListPBtoUpdate = new List <Participating_Brand__c>();
            for(Participating_Brand__c PBtoUpdate : ExistingParticipantBrandsMap.values()){
                PBtoUpdate.Feature_Details__c = ApplyFeature_Details;
                PBtoUpdate.Status__c = defaultstatus;
                PBtoUpdate.Discount__c = defaultDiscount;
                PBtoUpdate.Discount_Percentage__c = ApplyDiscount_Percentage;
                PBtoUpdate.Minimum_Purchase__c = defaultMinimumPurchase;
                PBtoUpdate.Minimum_Purchase_Amount__c = ApplyMinimumPurchase_Amount;
                PBtoUpdate.Gift_With_Purchase__c = defaultGiftWithPurchase;
                PBtoUpdate.Gift_With_Purchase_Type__c = ApplyGiftWithPurchase_Type;
                ListPBtoUpdate.add(PBtoUpdate); 
            }
            
            try {
                
                UPDATE ListPBtoUpdate;
                
            } catch(Exception e) {
                System.debug('Update Failed : ' + e.getMessage());
                ApexPages.addMessages(e);
                return null;
            }            
        }   
        
        for(ParticipantBrand cParticipantBrand : ParticipantBrandList)
        {
            if(cParticipantBrand.selected == true && cParticipantBrand.AlreadyExists == false ){
                Participating_Brand__c PBtoInsert = new Participating_Brand__c();
                PBtoInsert.Village_Presence__c = cParticipantBrand.VP_id;
                PBtoInsert.Feature_Details__c = ApplyFeature_Details;
                PBtoInsert.Status__c = defaultstatus;
                PBtoInsert.Discount__c = defaultDiscount;
                PBtoInsert.Marketing_Activity__c = cMarketingActivity .id;
                PBtoInsert.Account__c = cParticipantBrand.Account;
                PBtoInsert.Discount_Percentage__c = ApplyDiscount_Percentage;
                PBtoInsert.Minimum_Purchase__c = defaultMinimumPurchase;
                PBtoInsert.Minimum_Purchase_Amount__c = ApplyMinimumPurchase_Amount;
                PBtoInsert.Gift_With_Purchase__c = defaultGiftWithPurchase;
                PBtoInsert.Gift_With_Purchase_Type__c = ApplyGiftWithPurchase_Type;
                
                SelectedParticipantBrands.add(PBtoInsert) ;
            }
            else if (cParticipantBrand.selected == true && cParticipantBrand.AlreadyExists == false){
                
            }
        }   
        try {
            
            INSERT SelectedParticipantBrands ;
            
        } catch(Exception e) {
            System.debug('Update Failed : ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        } 
        
        PageReference activitypage = new  PageReference('/' + cMarketingActivity.id );
        activitypage.setRedirect(true);
        return activitypage ;
    }
    
    public PageReference cancel() {
        
        PageReference activitypage = new  PageReference('/' + cMarketingActivity.id );
        activitypage.setRedirect(true);
        return activitypage ;
    }
    
    public PageReference deleteRecord() {
        List<Participating_Brand__c> ListPBtoDelete = new List<Participating_Brand__c>();
        
        for(ParticipantBrand PBtoDelete : ParticipantBrandList){
            //delete existing particiating brands
            for(id ExistingBrandid : ExistingParticipantBrandsMap.keySet()){
                if(ExistingBrandid == PBtoDelete.VP_id && PBtoDelete.selected && PBtoDelete.AlreadyExists){ //if *not* selected AND was an existing participant
                    ListPBtoDelete.add(ExistingParticipantBrandsMap.get(ExistingBrandid)); //then remove it from the list
                }
            }
        }
        
        try {
            
            DELETE ListPBtoDelete;
            
        } catch(Exception e) {
            System.debug('Update Failed : ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        } 
        
        PageReference activitypage = new  PageReference('/' + cMarketingActivity.id );
        activitypage.setRedirect(true);
        return activitypage ;
        
    }
    
    public List<SelectOption> getStatuses()
    {// Get the values for the picklist Status
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =  Participating_Brand__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getDiscounts(){
        // Get the values for the picklist Discounts
        List<SelectOption> discountOptions = new List<SelectOption>();
        //Empty Value
        discountOptions.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Participating_Brand__c.Discount__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple){
            discountOptions.add(new SelectOption(f.getLabel(),f.getValue()));
        }
        return discountOptions;
    }
    
    public List<SelectOption> getMinimumPurchases(){
        // Get the values for the picklist Minimum Purchase
        List<SelectOption> minimumPurchaseOptions = new List<SelectOption>();
        minimumPurchaseOptions.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Participating_Brand__c.Minimum_Purchase__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple){
            minimumPurchaseOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return minimumPurchaseOptions;
    }
    
    public List<SelectOption> getGiftWithPurchases(){
        // Get the values for the picklist Gift with Purchase 
        List<SelectOption> GiftWithPurchaseOptions = new List<SelectOption>();
        GiftWithPurchaseOptions.add(new SelectOption('',''));
        
        Schema.DescribeFieldResult fieldResult = Participating_Brand__c.Gift_With_Purchase__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple){
            GiftWithPurchaseOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return GiftWithPurchaseOptions;
    }
    
    
    public PageReference checkAll(){
        
        PageReference pg = null;
        
        for (ParticipantBrand pb :ParticipantBrandList){
            pb.selected = allSelected;
        }
        
        return pg;
    }
    
    public Class ParticipantBrand{
        public string  VP_id {get;set;}
        public string  VP_Name {get;set;}
        public boolean selected {get;set;}
        public boolean AlreadyExists{get;set;}
        public string  Feature_Details {get;set;}
        public string  Status {get;set;}
        public string  VPStatus {get;set;}
        public string  Primary_Marketing_Contact{get;set;}
        public date    Approval_End_Date {get;set;}
        public date    Approval_Start_Date {get;set;}
        public string  Marketing_Manager{get;set;}
        public string  Pre_approval {get;set;}
        public string  Market_Position{get;set;}
        public string  Approval_Comment{get; set;}
        public boolean Group_Marketing{get;set;}
        public string  Department{get;set;}
        public string  brand_exit_date {get;set;}
        public id  Account {get;set;}
    }
    
}