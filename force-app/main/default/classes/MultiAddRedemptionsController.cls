public class MultiAddRedemptionsController{

    
    // Variables added for introduction of Quick Scan Promotion Home Page Component
    public boolean immediateSave{get; set;} //indicates whether attempt should be made to save redemption immediately on load of page (used by Home Page Component)
    public boolean uiMode {get; set;} //indicates whether class has been called from Home Page Component (true) or not (false)
    public list<boolean> disableInput {get; set;}
    public boolean disableSubmit {get; set;}
    
    // dummy redemption object referenced by VF page to store generic attributes (location, transport mode, visit type and country of origin)
    public Promotion_redemption__c dummyRedemption {get; set;}
    
    public MultiAddRedemptionsController(boolean noPage) {
        immediateSave = true;
        uiMode = noPage;
        disableSubmit = false;
                
    }
    
    public MultiAddRedemptionsController() {
        
        disableInput = new list<boolean>();
        dummyRedemption = new Promotion_redemption__c ();

        disableSubmit = true;  
        
             // grab all the details needed from about the redeemable Campaign
             
           //display a message to the users
        list<Campaign> RedeemableCampaignList = [SELECT ID, Name, Contact_Details_Required__c FROM Campaign WHERE ID = :cID LIMIT 1];  
        
        
        IF (RedeemableCampaignList.isempty()) 
        {
            ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.error, 'No ID supplied. You must enter this page from a Redeemable Campaign');
            ApexPages.addMessage(myMsg);  
            pageerror = true;   
        }
        ELSE
        {
            RedeemableCampaign = RedeemableCampaignList[0]; 
        }
         
            system.debug('@@@@@@@RedeemableCampaign ' + RedeemableCampaign );          
        
        immediateSave = false;
        string mode = ApexPages.currentPage().getParameters().get('uiMode');
    
        if (mode == null){
            uiMode =  false;
        } else {
            uiMode = boolean.valueOf(mode);
        }
        string redemptionCode = ApexPages.currentPage().getParameters().get('redeemCode');
        string visitType = ApexPages.currentPage().getParameters().get('visitType');
        string location = ApexPages.currentPage().getParameters().get('location');
        string transport = ApexPages.currentPage().getParameters().get('transport');
        string country = ApexPages.currentPage().getParameters().get('country');
        
        if (string.isnotBlank(visitType))
            dummyRedemption.Visit_Type__c = visitType;
        if (string.isnotBlank(location))
            dummyRedemption.location__c = location;
        if (string.isnotBlank(transport))
            dummyRedemption.mode_of_transport__c = transport;
        if (string.isnotBlank(country))
            dummyRedemption.Country_of_origin__c = country;
        
        User u = [select UserRole.Name, Village__c from User where Id = :UserInfo.getUserId()];
        string userVillage = u.Village__c;
        string userRole = u.UserRole.Name;
        
system.debug(userVillage + ' - ' + userRole);
        if (userVillage == 'Bicester' || userRole == 'Bicester TIC'){
            dummyRedemption.location__c = '';
        }
                                
        if (string.isnotBlank(redemptionCode)){ //indicates that call has been made from Quick Scan Home Page Component

            disableSubmit = false;
            Promotion_redemption__c redemptionItem = new Promotion_redemption__c();
            redemptionItem.Redeem_Date__c = system.today();
            redemptionItem.Voucher_Code__c = redemptionCode;
            redemptionItem.Redeemable_Campaign__c = RedeemableCampaign.Id;
            
            this.TORList.add(redemptionItem);
            immediateSave = true;                                   

            boolean addCustomer = false;
            if (ApexPages.currentPage().getParameters().get('addCustomer') != null){
                addCustomer = boolean.valueOf(ApexPages.currentPage().getParameters().get('addCustomer'));
            }
            if (addCustomer) {
                immediateSave = false;

                updateDisableList();
            }
        }
        
    }
    
    public PageReference saveNow(){
        if (immediateSave){
            return this.save();
        } else {
            return null;
        }
    } 
    
    public boolean pageerror {public get;set;}
    public integer rowIndex{get; set;}
    Public List<promotion_Redemption__c> TORList = New list<promotion_Redemption__c>();
    public Id cID = ApexPages.currentPage().getParameters().get('Id'); //grab the Campaign ID
    public Id getID {get; set;}
    Public campaign RedeemableCampaign {get;set;}
    private String multiVouchers; // stores the contents of the multiadd text box
    public string badCodes = '';


    public void setmultiVouchers(string value){
        multiVouchers = value;
    }
    
    public string getmultiVouchers(){
        return multiVouchers;
    }

    public PageReference cancel() //button returns the user to the redeemable Campaign
    {
           PageReference campaignpage = new PageReference('/apex/CampaignSearch');//' + RedeemableCampaign.Id);
           campaignpage.setRedirect(true);
           return campaignpage ;      
    }
 
    public List <promotion_Redemption__c> getTORs()
    {
        //if(TORList == null) reset();
        try{
            return TORList;
        } catch (exception e){
            ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.ERROR, 'No customer found! Please try searching again or entering a new name'); 
            return TORList;
        }
    }
 
    
 
    //add records to Campaign Expense  (TOR List) and which are associated with current Campaign
    public PageReference add()
    {
        
        MAP<string,promotion_Redemption__c> uniqueRedemptionMap = new MAP<string,promotion_Redemption__c>();
        
        FOR(promotion_Redemption__c cRedemption: TORList)
        {
            IF(cRedemption.Voucher_Code__c.length() == 14 || cRedemption.Voucher_Code__c.length() == 16 || cRedemption.Voucher_Code__c.length() == 0)
            {
                uniqueRedemptionMap.put(cRedemption.Voucher_Code__c , cRedemption);
            }
            ELSE
            {
                badCodes = badCodes + cRedemption.Voucher_Code__c + ', ';
               
            }
        }       
        
        //clear and refresh the list
        TORList.clear();
        TORList.addall(uniqueRedemptionMap.values());

        IF (badCodes.length() > 0)
        {
           ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.Warning, 'Some codes were removed: ' + badCodes + 'Codes must be 14 or 16 characters long. All other records were verified' ); //show confirmation message on save
           ApexPages.addMessage(myMsg);
           badCodes = '';  
        }
        
        TORList.add(New promotion_Redemption__c(Redeemable_Campaign__c = RedeemableCampaign.Id, Redeem_Date__c = system.today(), Voucher_Code__c = '',  customer__c = null));
        updateDisableList();
        disableSubmit = false;
        return null;
    }
    
    public boolean getContactDetailsRequired() //sets the required flag on redemption contacts, depending on the redeemable campaign setting
    {
        return RedeemableCampaign.Contact_Details_Required__c ;
    }
    
    public void MultiAdd()//splits the ; seperated string and adds a new row into the TORlist for each one
    {

        pageerror = false;
        string cleanString = multiVouchers;
        cleanString = cleanString.replaceAll(' ', '');
        cleanString = cleanString.replaceAll('\n', '');
        
        list<string> ListVoucherCodesSplit = cleanString.split(';');
        set<string> SetVoucherCodeSplit = new set<string>();
        SetVoucherCodeSplit.addAll(ListVoucherCodesSplit );
        
        system.debug('list of voucher codes: '+ SetVoucherCodeSplit);
        system.debug('input String: ' + multiVouchers );
        system.debug('clean String: ' + cleanString);
                
        //loop through the list (VoucherCodesSplit ) and add them to the TORList 
        FOR(string s  :SetVoucherCodeSplit)
        {
            if (string.isnotblank(s) && (s.length() == 14 || s.length() == 16)) //the voucher codes 
            {
                TORList.add(New Promotion_Redemption__c(Redeemable_Campaign__c = RedeemableCampaign.Id, Redeem_Date__c = system.today() , Voucher_Code__c = s,  customer__c = null));
            }
            ELSE
            {
                //add warning message
                badCodes = badCodes + s + ', ';
              
            }
                 
        }//end for loop
        
        IF (badCodes.length() > 0)
        {
           ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.Info, 'Some codes were not added: ' + badCodes + 'codes must be 14 or 16 characters long.' ); //show confirmation message on save
           ApexPages.addMessage(myMsg);
       }
system.debug(' @@@@ dummyRedemption from Process VIP Cards ... ' + dummyRedemption);
       if(string.isBlank(dummyRedemption.Visit_Type__c) || string.isBlank(dummyRedemption.Location__c)
                || string.isBlank(dummyRedemption.Mode_of_Transport__c) || string.isBlank(dummyRedemption.Country_of_Origin__c)){
                    
                    ApexPages.Message msg1 = new ApexPages.message(ApexPages.Severity.Error, 'Please complete all fields in the Visit Details section, before continuing');
                    ApexPages.addMessage(msg1);
                    pageerror = true;
       }
       
       if (TORList.size() > 0 && !pageerror){
           disableSubmit = false;
       }
        
    multiVouchers = '';
    badCodes = '';
    updateDisableList();

system.debug(' @@@ disableSubmit ' + disableSubmit);
    
    }
    
    
    //upsert records on save
    public PageReference save()
    {
system.debug ( ' @@@ dummyRedemption ' + dummyRedemption);
                       
        pageerror = false;
                
        MAP<string,promotion_Redemption__c> uniqueRedemptionMap = new MAP<string,promotion_Redemption__c>();
        
        FOR(promotion_Redemption__c cRedemption: TORList)
        {
            IF(cRedemption.Voucher_Code__c.length() == 14 || cRedemption.Voucher_Code__c.length() == 16)
            {
                try {
                if (dummyRedemption != null){
                    if (string.isnotBlank(dummyRedemption.Location__c))
                        cRedemption.Location__c = dummyRedemption.Location__c;
                    if (string.isnotBlank(dummyRedemption.Visit_Type__c))
                        cRedemption.Visit_Type__c = dummyRedemption.Visit_Type__c;
                    if (string.isnotBlank(dummyRedemption.Mode_of_Transport__c))
                        cRedemption.Mode_of_Transport__c = dummyRedemption.Mode_of_Transport__c;
                    if (string.isnotBlank(dummyRedemption.Country_of_Origin__c))
                        cRedemption.Country_of_Origin__c = dummyRedemption.Country_of_Origin__c;
                }
                }catch (exception e){
                     system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
                }
                
                uniqueRedemptionMap.put(cRedemption.Voucher_Code__c , cRedemption);
            }
            ELSE
            {
                badCodes = badCodes + cRedemption.Voucher_Code__c + ', ';
            }
        
        }
system.debug(' @@@@ uniqueRedemptionMap  ' + uniqueRedemptionMap);            
        //insert the records
        database.upsert(uniqueRedemptionMap.values());
        
        boolean addCustomer = false;
        if (ApexPages.currentPage().getParameters().get('addCustomer') != null){
            addCustomer = boolean.valueOf(ApexPages.currentPage().getParameters().get('addCustomer'));
        } 

        IF (badCodes.length() > 0)
        {
           ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.Warning, 'Some codes were not saved: ' + badCodes + 'Codes must be 14 or 16 characters long. All other records were saved sucessfully' ); //show confirmation message on save
           ApexPages.addMessage(myMsg);
           badCodes = '';
           
           //keep the users on the page
           return null; 
        }
        else if (addCustomer && uiMode){    // Called from Quick Scan Component, but customer details needed         
            disableSubmit = false;
            return null;
        } else {
          if (immediateSave && uiMode){
            PageReference pge = null;
            if (!addCustomer){
                 pge = new PageReference('/' );
            } else {
                 pge = new PageReference('/apex/CampaignSearch');
            }
           //display a message to the users
            ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.CONFIRM, '<p style="font-size:12px; color:blue">' +  TORList[0].Voucher_Code__c +  ' Successfully added to ' + RedeemableCampaign.Name + '</p>') ; //show confirmation message on save
            ApexPages.addMessage(myMsg);
            pge.GetParameters().Put('message', TORList[0].Voucher_Code__c +  ' Successfully added to ' + RedeemableCampaign.Name );
            return pge;         
          }  else { 
          TORList.clear();
          //display a message to the users
            ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.CONFIRM, 'All Records Saved Successfully'); //show confirmation message on save
            ApexPages.addMessage(myMsg);
            //redirect the user to the redeemable campaign page
            PageReference campaignpage = new PageReference('/' + 'apex/CampaignSearch');
                campaignpage.GetParameters().Put('message', uniqueRedemptionMap.size() + ' VIP card(s) Successfully Added to ' + RedeemableCampaign.Name);
                campaignpage.setRedirect(true);
                system.debug('Im Here: and this is the page reference: ' + campaignpage );          
                return campaignpage ;
          }
          
          return null;

               
        }
           
        
      
        
        
    }
    
    
    public PageReference quicksave()
    {
        
        MAP<string,promotion_Redemption__c> uniqueRedemptionMap = new MAP<string,promotion_Redemption__c>();
        
        FOR(promotion_Redemption__c cRedemption: TORList)
        {
            IF(cRedemption.Voucher_Code__c.length() == 14 || cRedemption.Voucher_Code__c.length() == 16)
            {
                uniqueRedemptionMap.put(cRedemption.Voucher_Code__c , cRedemption);
            }
            ELSE
            {
                badCodes = badCodes + cRedemption.Voucher_Code__c + ', ';
               
            }
        
        }       
        
        //clear and refresh the list
        TORList.clear();
        TORList.addall(uniqueRedemptionMap.values());
        disableSubmit = false;
        updateDisableList();
        
        IF (badCodes.length() > 0)
        {
           ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.Warning, 'Some codes were removed: ' + badCodes + 'Codes must be 14 or 16 characters long. All other records were verified' ); //show confirmation message on save
           ApexPages.addMessage(myMsg);
           badCodes = '';
           //keep the users on the page
           return null; 
        }
        ELSE
        {
          //display a message to the users
            ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.CONFIRM, 'All Records verified'); //show confirmation message on save
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    
    public PageReference reset() 
    {
        TORList = New list<promotion_Redemption__c>();
        dummyRedemption = new Promotion_redemption__c ();
        multiVouchers = '';
        disableSubmit = true;
        return null;
    }
    
    public void updateContactFields() {
        
         system.debug('Current Row Index is :  ' +  rowIndex);
        
        promotion_Redemption__c promotionRedemption = TORList[rowIndex];
        system.debug('promotion_Redemption__c BEFORE: ' + promotionRedemption );
        
        //string guestId = promotionRedemption.Guest2__c;
        //moving to b2c_customer__c object
        string guestId = promotionRedemption.customer__c;
        
        system.debug('Contact ID about to be searched for :  ' +  guestId);
        
       IF (string.isblank(guestId )) {
        updateDisableList();
        promotionRedemption.customer__c = null;
        promotionRedemption.Guest_First_Name__c = null;
        promotionRedemption.Guest_Last_Name__c =  null;
        promotionRedemption.Guest_Email__c =  null;
        promotionRedemption.Email_opt_in__c = null;
        return;
       }
        
        //Contact c = [select FirstName, LastName, Email from Contact where Id =:contactId];
        //Account g = [SELECT FirstName, LastName, PersonEmail FROM Account where Id =:guestId];
        //moving to b2c_customer__c object
        b2c_customer__c g = null;
        try {
            g = [SELECT firstName__c, lastName__c, Email__c, optInEmail__c FROM b2c_customer__c where Id =:guestId];
        } catch (exception e){
            ApexPages.Message myMsg = new ApexPages.message(ApexPages.Severity.ERROR, 'No customer found! Please try searching again'); 
            promotionRedemption.customer__c = null;
            promotionRedemption.Guest_First_Name__c = null;
            promotionRedemption.Guest_Last_Name__c =  null;
            promotionRedemption.Guest_Email__c =  null;
            promotionRedemption.Email_opt_in__c = null;
            updateDisableList();
            return;
        }
        promotionRedemption.Guest_First_Name__c = g.firstName__c;
        promotionRedemption.Guest_Last_Name__c =  g.lastName__c;
        promotionRedemption.Guest_Email__c =  g.Email__c;
        promotionRedemption.Email_opt_in__c = g.optInEmail__c;
        

        updateDisableList();
        
//        if (g.optInEmail__c == 'true'){
//            promotionRedemption.Email_opt_in__c = true;
//        } else {
//            promotionRedemption.Email_opt_in__c = false;
//        }
        
        system.debug('promotion_Redemption__c AFTER : ' + promotionRedemption );
        
        //return null;
    }
    
    public void updateDisableList(){
        
        disableInput = new list<boolean>();
        for (promotion_Redemption__c promotionRedemption :TORList){
            if (string.isnotBlank(promotionRedemption.customer__c) ){
                disableInput.add(true);
            } else{
                disableInput.add(false);
            }
            
        }
system.debug(' @@@@@   disableList   ' + disableInput);     
    }

    public pageReference validate(){
    
        string visitValue1=System.currentPageReference().getParameters().get('visitValue1');
system.debug(' @@@@@@@@@@@@@@@   Validating ...' + visitValue1 );
        if (string.isBlank(visitValue1)){
            disableSubmit = true;
        } else {
            if (TORList != null){           
                if (TORList.size() > 0) {             
                    disableSubmit = false;
                }               
            }        
        }        
        
        return null;
    }
    
}//