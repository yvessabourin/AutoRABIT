public with sharing class AccountViewer {
    
    public string recId {get; set;}
    public string AccountTree {get; set;}
    public string currentDeals {get;set;}
    public string helpTextMap {get; set;}
    
    private map<string, string> vpDealMap = new map<string, string>();
    
    public AccountViewer(ApexPages.StandardController controller) {
        this.recId = controller.getId();
        string accId = [select VR1UID__c from Account where Id =:recId].VR1UID__c;
                
        helpTextMap = string.escapeSingleQuotes(json.serialize(getHelpText()));
        
        AccountTreeView a = getAccountTree(accId);
        this.AccountTree =  string.escapeSingleQuotes(json.serialize(a));
        
        currentDeals = string.escapeSingleQuotes(json.serialize(getvpDeals()));
        
    }



    private list<Account> getChildAccounts(string accountId){
    
        list<Account> returnList = [select Name, id, Parent.Name, Parent.Id, 
                                        (select Name, Status__c, Initial_Opened_Date__c, latest_review_deal__r.Id,
                                        latest_review_deal__r.open_date__c, latest_review_deal__r.Signed_Date__c,
                                        Village__r.Name,
                                        Contract_Tenant_Break_Date__c, Unit__r.name,
                                         Unit__r.Size_GEA__C, Unit__r.Size_sq_ft__c, Unit__r.Size_Mezzanine__c,
                                         Newness_Date__c,Age_of_Shop_Fit_Years__c,
                                         Contract_Expiry_Date__c, Last_Remerchandising_Date__c,
                                         Projected_Sales_Yield_Local_Converted__c,
                                         Total_Rating__c, Position_Rating__c, Sales_Rating__c,
                                         Income_Rating__c, latest_review_deal__r.Projected_Income_Local__c,
                                         latest_review_deal__r.Annual_ToR_Gross__c, Deal_in_progress__c
                                         from Village_Presences__r),
                                         (select Id, name from ChildAccounts where Parent.Id = :accountId) 
                                        from Account where Id = :accountId];    
        
        return returnList;
    
    }
    private map<string, string> getHelpText(){
        string helpText = '';
        map <string, string> returnMap = new map<string, string>();
            
        helpText= Village_Presence__c.Status__c.getDescribe().getInlineHelpText();
        returnMap.put('Status', helpText);
        helpText= Village_Presence__c.Initial_Opened_Date__c.getDescribe().getInlineHelpText();
        returnMap.put('InitialOpenedDate', helpText);
        helpText = Opportunity.Signed_Date__c.getDescribe().getInlineHelpText();
        returnMap.put('ActualSignedDate', helpText);        
        helpText= Village_Presence__c.Contract_Tenant_Break_Date__c.getDescribe().getInlineHelpText();      
        returnMap.put('ContractTenantBreakDate', helpText);
        helpText= Unit__c.Name.getDescribe().getInlineHelpText();
        returnMap.put('Unit', helpText);        
        helpText= Unit__c.Size_GEA__c.getDescribe().getInlineHelpText();
        returnMap.put('UnitSizeGEA', helpText);
        helpText= Unit__c.Size_sq_ft__c.getDescribe().getInlineHelpText();
        returnMap.put('UnitSizeSQFT', helpText);        
        helpText= Unit__c.Size_Mezzanine__c.getDescribe().getInlineHelpText();
        returnMap.put('MezzanineSize', helpText);
        helpText= Village_Presence__c.Newness_Date__c.getDescribe().getInlineHelpText();
        returnMap.put('LastShopfitDate', helpText);
        helpText= Village_Presence__c.Age_of_Shop_Fit_Years__c.getDescribe().getInlineHelpText();
        returnMap.put('AgeOfShopfit', helpText);
        helpText= Village_Presence__c.Contract_Expiry_Date__c.getDescribe().getInlineHelpText();
        returnMap.put('ContractExpiryDate', helpText);
        helpText= Village_Presence__c.Last_Remerchandising_Date__c.getDescribe().getInlineHelpText();
        returnMap.put('LastRemerchandisingDate', helpText);
        helpText= Village_Presence__c.Projected_Sales_Yield_Local_Converted__c.getDescribe().getInlineHelpText();
        returnMap.put('ProjectedSalesYieldLocalConverted', helpText);
        helpText= Village_Presence__c.Total_Rating__c.getDescribe().getInlineHelpText();
        returnMap.put('TotalRating', helpText);
        helpText= Village_Presence__c.Position_Rating__c.getDescribe().getInlineHelpText();
        returnMap.put('PositionRating', helpText);
        helpText= Village_Presence__c.Sales_Rating__c.getDescribe().getInlineHelpText();
        returnMap.put('SalesRating', helpText);
        helpText= Village_Presence__c.Income_Rating__c.getDescribe().getInlineHelpText();
        returnMap.put('IncomeRating', helpText);
        helpText= Opportunity.Projected_Income_Local__c.getDescribe().getInlineHelpText();
        returnMap.put('ProjectedIncomeLocal', helpText);
        helpText= Opportunity.Annual_ToR_Gross__c.getDescribe().getInlineHelpText();
        returnMap.put('AnnualTORGross', helpText);
        
        return returnMap;
                                                                                                                                                                                                                                            
    }
    
    
    private AccountTreeView getAccountTree(string accountId){
        
        AccountTreeView returnView = new AccountTreeView();
        list<Account> accountList = getChildAccounts(accountId);
        
        if (accountList.size() > 0){

            list<Account> childAccounts = accountList[0].ChildAccounts;
            list<Village_Presence__c> vpList = accountList[0].Village_Presences__r;
            list<AccountVillagePresence> vpViewList = new list<AccountVillagePresence>();
            
            returnView.AccountName =  accountList[0].Name;
            returnView.RecordId = accountList[0].Id;
            returnView.ParentName = accountList[0].Parent.Name;
            returnView.ParentId = accountList[0].parent.Id;

                                                
                    
            for (Village_Presence__c vp :vpList){
                AccountVillagePresence vpView = new AccountVillagePresence();
                string helpText = '';
                
                vpView.ParentId = accountId;
                vpView.RecordId = vp.Id;
                vpView.Name = vp.Name;
                vpView.VillageName =  vp.Village__r.Name;               
                vpView.Status = vp.Status__c;
                vpView.InitialOpenedDate = formatDate(string.valueOf(vp.Initial_Opened_Date__c));
                vpView.ActualSignedDate = formatDate(string.valueOf(vp.Latest_Review_Deal__r.Signed_Date__c));
                vpView.ContractTenantBreakDate = formatDate(string.valueOf(vp.Contract_Tenant_Break_Date__c));
                vpView.Unit = string.valueOf(vp.Unit__r.Name);
                vpView.UnitSizeGEA = string.valueOf(vp.Unit__r.Size_GEA__c);
                vpView.UnitSizeSQFT = string.valueOf(vp.Unit__r.Size_sq_ft__c);
                vpView.MezzanineSize = string.valueOf(vp.Unit__r.Size_Mezzanine__c);            
                vpView.LastShopfitDate = formatDate(string.valueOf(vp.Newness_Date__c));            
                vpView.AgeOfShopfit = string.valueOf(vp.Age_of_Shop_Fit_Years__c);          
                vpView.ContractExpiryDate = formatDate(string.valueOf(vp.Contract_Expiry_Date__c));             
                vpView.LastRemerchandisingDate = formatDate(string.valueOf(vp.Last_Remerchandising_Date__c));           
                vpView.ProjectedSalesYieldLocalConverted = string.valueOf(vp.Projected_Sales_Yield_Local_Converted__c);                             
                vpView.TotalRating = string.valueOf(vp.Total_Rating__c);            
                vpView.PositionRating = string.valueOf(vp.Position_Rating__c);              
                vpView.SalesRating = string.valueOf(vp.Sales_Rating__c);        
                vpView.IncomeRating = string.valueOf(vp.Income_Rating__c);      
                vpView.ProjectedIncomeLocal = string.valueOf(vp.latest_review_deal__r.Projected_Income_Local__c);           
                vpView.AnnualTORGross = string.valueOf(vp.latest_review_deal__r.Annual_ToR_Gross__c);

                vpViewList.add(vpView);
                
                vpDealMap.put(vp.Id, vp.Deal_in_progress__c);
                
            }
            returnView.vpList = vpViewlist;
            if(childAccounts.size() > 0){
                for (Account a :childAccounts){
                    AccountTreeView childView = getAccountTree(a.Id);
                    returnView.accountTreeList.add(childView);
                }
            }
        }
        
    
        return returnView;
        
        
    }
    
    private list<vpDeal> getvpDeals(){
        
        list<vpDeal> returnList = new list<vpDeal>();
system.debug (' @@@ vpDealMap  ' + vpDealMap);      
        if (!vpDealMap.isEmpty()){
            
            map<Id, Opportunity> dealMap = new map<Id, Opportunity>([select Id, Name, RecordType.Name, StageName, Type, Lease_Type__c, 
                                                            Tier_Level__c, Lead_Negotiator_for_VR__r.Name, Expected_Signature_Date__c,
                                                            Next_step_update__c, next_step_due_date__c, comments__c, CloseDate, Unit__r.Name,
                                                            Projected_Sales_Yield_Local__c, Projected_Income__c, Annual_TOR_Gross_Local__c,
                                                            Total_Rating__c, Position_Rating__c, Sales_Rating__c, Income_Rating__c, Ideal_Size__c 
                                                        from Opportunity where Id in :vpDealMap.values()]);

system.debug (' @@@ dealMap  ' + dealMap);          
            for (string vpId :vpDealMap.keySet()){
            
                Opportunity deal = dealMap.get(vpDealMap.get(vpId));
                if (deal != null){
                    vpDeal vpDeal = new vpDeal();
                    vpDeal.vpId = vpId;
                    vpDeal.dealName = deal.Name;
                    vpDeal.dealId = deal.Id;
                    vpDeal.recType = deal.RecordType.Name;
                    vpDeal.stage = deal.StageName;
                    vpDeal.dealType = deal.Type;
                    vpDeal.leaseType = deal.Lease_Type__c;
                    vpDeal.tierLevel = deal.Tier_Level__c;
                    vpDeal.leadNegotiatorVR = deal.Lead_Negotiator_for_VR__r.Name;
                    vpDeal.expectedSignatureDate = formatDate(string.valueOf(deal.Expected_Signature_Date__c));
                    vpDeal.nextStep = deal.Next_step_update__c;
                    vpDeal.nextStepDue  = formatDate(string.valueOf(deal.next_step_due_date__c));
                    vpDeal.comments = deal.Comments__c;
                    vpDeal.closeDate = formatDate(string.valueOf(deal.CloseDate));
                    vpDeal.projectedSalesYield = string.valueOf(deal.Projected_Sales_Yield_Local__c);
                    vpDeal.projectedIncome = string.valueOf(deal.Projected_Income__c);
                    vpDeal.annualTOR = string.valueOf(deal.Annual_TOR_Gross_Local__c);
                    vpDeal.totalRating = string.valueOf(deal.Total_Rating__c);
                    vpDeal.positionRating = string.valueOf(deal.Position_Rating__c);
                    vpDeal.incomeRating = string.valueOf(deal.Income_Rating__c);
                    vpDeal.salesRating =  string.valueOf(deal.Sales_Rating__c);
                    vpDeal.unit = deal.Unit__r.Name;
                    vpDeal.idealSize = string.valueOf(deal.Ideal_Size__c);
                    
                    returnList.add(vpDeal);
                }
                
                
                
            }

        }
        
        return returnList;
        
        
    }
    
    private string formatDate(string val){
        
        string returnVal = '';
        
        if(string.isnotblank(val)){
            list<string> dtArray = val.split('-');
            if(dtArray.size() == 3){
                string d = dtArray[2];
                string m = dtArray[1];
                string y = dtArray[0];
                
                returnVal = d + '/' + m + '/' + y;
            }
            
        }
        
        return returnVal;
    
    }
    

    private class AccountTreeView{
        
        public string AccountName{get; set;}
        public string ParentName{get; set;}
        public string RecordId{get; set;}
        public string ParentId{get; set;}
        
        public list<AccountVillagePresence> vpList{get; set;}
        public list<AccountTreeView> accountTreeList{get; set;}
        
        public AccountTreeView(){
            this.vpList = new list<AccountVillagePresence>();
            this.accountTreeList = new list<AccountTreeView>();         
        }
        
    }
    
    private class AccountVillagePresence{

        string RecordId {get;set;}
        string ParentId {get; set;}
        string Name{get; set;}
        string VillageName {get; set;}
        string Status{get; set;}
        string InitialOpenedDate{get;set;}
        string ActualSignedDate {get;set;}
        string ContractTenantBreakDate {get; set;}
        string Unit {get;set;}
        string UnitSizeGEA {get;set;}
        string UnitSizeSQFT{get;set;}
        string MezzanineSize {get; set;}
        string LastShopfitDate {get; set;}
        string AgeOfShopfit {get; set;}
        string ContractExpiryDate {get; set;}
        string LastRemerchandisingDate {get; set;}
        string ProjectedSalesYieldLocalConverted {get; set;}
        string TotalRating {get;set;}
        string PositionRating {get; set;}
        string SalesRating {get; set;}
        string IncomeRating {get; set;}
        string ProjectedIncomeLocal {get; set;}
        string AnnualTORGross {get;set;}

    }   
    
    private class vpDeal{
        
        string vpId {get; set;}
        string dealName {get; set;}
        string dealId {get; set;}
        string recType {get; set;}
        string stage {get; set;}
        string dealType {get; set;}
        string leaseType {get; set;}
        string tierLevel {get; set;}
        string leadNegotiatorVR {get; set;}
        string expectedSignatureDate {get; set;}
        string nextStep {get; set;}
        string nextStepDue {get; set;}
        string comments {get; set;}
        string closeDate {get; set;}
        string projectedSalesYield {get; set;}
        string projectedIncome {get; set;}
        string annualTOR {get; set;}
        string totalRating{get; set;}
        string positionRating {get; set;}
        string incomeRating {get; set;}
        string salesRating {get; set;}
        string unit{get; set;}
        string idealSize{get; set;}
                
    }  
}