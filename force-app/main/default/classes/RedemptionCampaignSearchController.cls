public with sharing class RedemptionCampaignSearchController {

    public string redemptionCode{get;set;}
    public string searchString {get;set;}
    public string navURL{get; set;}
    public boolean customerDetails {get;set;}   
    
    public string visitType {get; set;}
    public string country {get; set;}
    public string location {get; set;}
    public string transport {get; set;}
    
    private Map<String, Schema.SObjectField> objectFields = null;
    
    public RedemptionCampaignSearchController(){
    
        location = 'TIC';        
    
        User u = [select UserRole.Name, Village__c from User where Id = :UserInfo.getUserId()];
        string userVillage = u.Village__c;
        string userRole = u.UserRole.Name;
        
system.debug(userVillage + ' - ' + userRole);
        if (userVillage == 'Bicester' || userRole == 'Bicester TIC'){
            location = '';
        }
           
        // retrieve object field metadata
        objectFields = Schema.getGlobalDescribe().get('Promotion_Redemption__c').getDescribe().fields.getMap();
       
    }
    
    public PageReference searchCampaign(){

        try{        
            PageReference pg = null;
            navURL = '';
            
            if (string.isBlank(redemptionCode)){        
                navURL = 'Invalid';
                return null;
            } else {
                if (redemptionCode.length() != 14 && redemptionCode.length() != 16){                
                    navURL = 'Invalid';
                    return null;
                }
            }

                    
            if(visitType == '-- Please Select --')
                visitType = '';
            if(country== '-- Please Select --')
                country = '';
            if(location == '-- Please Select --')
                location = '';
            if(transport == '-- Please Select --')
                transport = '';                                                                        
            
            boolean visitError = false;
            if (string.isBlank(visitType)){
                navURL = ' - Visit Type must be entered - ';
                visitError = true;
            }
            if (string.isBlank(country)) {
                navURL += ' - Country of residence must be entered - ';
                visitError = true;
            }
            if (string.isBlank(location)){                    
                navURL += ' - Location must be entered - ';
                visitError = true;
            }
            if (string.isBlank(transport)) {
                navURL += ' - Transport mode must be entered - ';
                visitError = true;
            }

            if (visitError){
                navURL = 'ERROR : ' + navURL;
                return null;
            }
                        
            CampaignSearchController searchController = new CampaignSearchController();
            searchController.SearchString = this.searchString;
            pg = searchController.SubmitSearch();
                
            if (pg!= null){
                string campaignId = pg.getParameters().get('Id');
                if (string.isnotBlank(campaignId)){
                    MultiAddRedemptionsController redemption = new MultiAddRedemptionsController(true);
                    Promotion_redemption__c redemptionItem = new Promotion_redemption__c();
                    redemptionItem.Redeem_Date__c = system.today();
                    redemptionItem.Voucher_Code__c = redemptionCode;
                    redemptionItem.Redeemable_Campaign__c = campaignId;

                    if (string.isnotBlank(visitType)){
                        redemptionItem.Visit_Type__c = visitType;
                    } 
                    if (string.isnotBlank(country)) {
                        redemptionItem.Country_of_origin__c = country;
                    } 
                    if (string.isnotBlank(location)){                    
                        redemptionItem.Location__c = location;
                    } 
                    if (string.isnotBlank(transport)) {
                        redemptionItem.Mode_of_Transport__c = transport;                                                                    
                    } 

                    redemption.RedeemableCampaign = [select Id, Name, Contact_Details_Required__c from Campaign where Id =:campaignId];
                    redemption.TORList.add(redemptionItem);
                    if (customerDetails){
                        pg = new PageReference('apex/multiaddredemptions');
                        pg.getParameters().put('Id', campaignId);
                        pg.getParameters().put('redeemCode', redemptionCode);
                        pg.getParameters().put('addCustomer', 'true');
                        pg.getParameters().put('uiMode', 'false');
                        
                        pg.getParameters().put('visitType', visitType);
                        pg.getParameters().put('country', country);
                        pg.getParameters().put('location', location);
                        pg.getParameters().put('transport', transport);
                        
                        navURL = pg.getUrl();
                    } else {                            
                        pg = redemption.save();
                        string msg = pg.getParameters().get('message');
system.debug('@@@@@ msg  ' + msg);
                        if (string.isNotBlank(msg)){
                            integer found = msg.indexOf('Successfully');
                            
                            if (found > -1){
                                string redemptionId = [select Id from Promotion_Redemption__c
                                                        where Voucher_Code__c = :redemptionCode
                                                        and Redeemable_Campaign__c = :campaignId].Id;
                                navURL = 'home';

                            }
                            
                            found = msg.indexOf('ERROR');
                            
                            if (found > -1){
                                navURL = msg;
                            }
                        
                        }
                    }               
                } else {
                     pg.getParameters().put('visitType', visitType);
                     pg.getParameters().put('country', country);
                     pg.getParameters().put('location', location);
                     pg.getParameters().put('transport', transport);
                     navURL = pg.getURL();
                }
            } else {
                 navURL = string.valueOf(customerDetails);
                 navURL +='&location=' + location +
                          '&visitType=' + visitType +
                          '&country=' + country +
                          '&transport=' + transport +                                              
                          '&uiMode=true';
            }
        } catch (exception e){
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
            return null;    
        }
        
        return null;
        
    }
    
    public list<SelectOption> getVisitTypes(){
        
        list<SelectOption> poList = new list<SelectOption>();
        
        map<string, string> optionsMap = PicklistUtilities.getPicklistValues('Promotion_Redemption__c', 'Visit_Type__c', objectFields);

        poList.add(new SelectOption('-- Please Select --','-- Please Select --'));
        for (string key :optionsMap.keySet()){
            poList.add(new SelectOption(key, optionsMap.get(key)));
        }
        
        return poList;
            
    }

    public list<SelectOption> getCountries(){

        list<SelectOption> poList = new list<SelectOption>();
        
        map<string, string> optionsMap = PicklistUtilities.getPicklistValues('Promotion_Redemption__c', 'Country_of_Origin__c', objectFields);

        poList.add(new SelectOption('-- Please Select --','-- Please Select --'));
        for (string key :optionsMap.keySet()){
            poList.add(new SelectOption(key, optionsMap.get(key)));
        }
        
        return poList;    
    }
    
    public list<SelectOption> getTransportModes(){

        list<SelectOption> poList = new list<SelectOption>();
        
        map<string, string> optionsMap = PicklistUtilities.getPicklistValues('Promotion_Redemption__c', 'Mode_of_Transport__c', objectFields);

        poList.add(new SelectOption('-- Please Select --','-- Please Select --'));
        for (string key :optionsMap.keySet()){
            poList.add(new SelectOption(key, optionsMap.get(key)));
        }
        
        return poList;    
    }
    
    public list<SelectOption> getLocations(){

        list<SelectOption> poList = new list<SelectOption>();
        
        map<string, string> optionsMap = PicklistUtilities.getPicklistValues('Promotion_Redemption__c', 'Location__c', objectFields);

        poList.add(new SelectOption('-- Please Select --','-- Please Select --'));
        for (string key :optionsMap.keySet()){
            poList.add(new SelectOption(key, optionsMap.get(key)));
        }
        
        return poList;    
    }

}