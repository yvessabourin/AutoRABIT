/*
    Controller class for Customer VF page
    
    Created : 28/05/2015
    Author: Constantine Chimonides
    
    Modification History:
*/
public with sharing class apiCustomerController {
    
    private static final string defaultLeadSourceText = 'TIC';
    
    public apiCustomer.cls_Customer customer {get; set;}
    public apiCustomer.cls_properties customerProperties {get; set;}
    public apiCustomer.cls_references customerReferences {get; set;}
    public list<SelectOption> villages {get; set;}
    public list<SelectOption> countries {get; set;}
    public list<SelectOption> languages  {get; set;}
    public list<SelectOption> genders  {get; set;}

    //public string preference {get; set;}
    public boolean validPage {get; set;}
    public string recTypeName {get; set;}
    public Recordtype objRectype {get; set;}
    public boolean customerSaved{get;set;}
    public boolean emailReadOnly{get; set;}
    
    public string deleteResult {get; set;}
    
    public string newEmail {get; set;}
    public string emailResult {get; set;}
    private string currentEmail{get; set;}
    private string currentGuid{get; set;}
    
    private ApexPages.StandardController theController;
    private ApexPages.StandardSetController theSetController;
    
    private map<string, string> preferenceMap = new map<string, string>();
    private map<string, map<string, string>> enumMap = new map<string, map<string, string>>();
    private string recId = '';
    public boolean showLeadSourceTextField {get;set;}




    public apiCustomerController() {

        showLeadSourceTextField = false;
        List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
            for(PermissionSetAssignment perm :usersPerms){
                if(perm.PermissionSet.Name == 'View_Lead_Source_Text'){
                    showLeadSourceTextField = true;
                }
            } 

    }


    public apiCustomerController(ApexPages.StandardSetController controller) {

        system.debug('@@@@ StandardSetController init');
        theSetController = controller;
        validPage = true;
        customerSaved = false;
                
        villages = this.getVillages();
        languages = this.getLanguages();
        genders = this.getGenders();
        countries = this.getCountries();
                
        initializeCustomer();        
        
        recId = ApexPages.currentPage().getParameters().get('Id');
        string readOnly = ApexPages.currentPage().getParameters().get('readOnly');
        if (string.isnotBlank(ApexPages.currentPage().getParameters().get('emailReadOnly'))){
            emailReadOnly = boolean.valueOf(ApexPages.currentPage().getParameters().get('emailReadOnly'));
        } else {
            emailReadOnly = false;
        }
        
        if (string.isNotBlank(recId)) //is not a New record
            getCustomerData(recId);        
         
    }

    
    public apiCustomerController(ApexPages.StandardController controller) {

        system.debug('@@@@ StandardController init');
        theController = controller;
        recId = ApexPages.currentPage().getParameters().get('Id');
        currentEmail = ApexPages.currentPage().getParameters().get('currentEmail');
        currentGuid = ApexPages.currentPage().getParameters().get('guid');
      
         
    }
    
    @RemoteAction
    public static string saveEmailfromMobile(string guid, string currentEmail, string newEmail){
    
    list<account> query = [SELECT id from Account WHERE PersonEmail =:newEmail Limit 1];
        
        if(query.size() > 0){
            string errMsg = 'ERROR - This Guest email address already exists in Salesforce.';
            system.debug(errMsg); 
            return errMsg;
            
           
        }else{
        
                string returnValue = '';
                string apiCall = apiService.postEmailChange(currentEmail, newEmail, guid);            
                system.debug(' @@@ Changing EMAIL response ' + apiCall);
                if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
                    // Workflow update to Microservice customer record is an async process,
                    // Microservice will trigger a customer update message to Salesforce with new value but not immediately.
                    returnValue = 'Email change notification has been successfully received and will be processed shortly.';
                    
                } else{
                    string errMsg = 'ERROR - Email could not be changed at this present time - please report to system administrator if error persists.';
                    errMsg += '\r\n' + apiCall;                
                    system.debug(errMsg); 
                    returnValue = errMsg;  
                                               
                }                   
                
                return returnValue;
         }
        
    }
    
    public void saveEmail(){
        
        PageReference pg = null;
    system.debug(' @@@ Changing EMAIL For  ' + currentGuid + ' From : ' + currentEmail + ' To : ' + newEmail);

        string apiCall = apiService.postEmailChange(currentEmail, newEmail, currentGuid);            
    system.debug(' @@@ Changing EMAIL response ' + apiCall);
        if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
            // Workflow update to Microservice customer record is an async process,
            // Microservice will trigger a customer update message to Salesforce with new value but not immediately.
            Account updAccount = [select Id, PersonEmail from Account where Id = :recId];
            //updAccount.PersonEmail = newEmail;
            //update updAccount; 
            pg = new PageReference('/' + updAccount.Id); 
            emailResult = 'Email change notification has been successfully received and will be processed shortly.';
            /*
            initializeCustomer();
            if (string.isNotBlank(recId)) 
                apiCall = apiService.readByGUID(currentGuid);
    system.debug(' @@@ Changing EMAIL customer read ' + apiCall);
                Account updAccount = apiCustomer.upsertCustomer(apiCall, false, currentGuid);
                if (updAccount != null)
                    pg = new PageReference('/' + updAccount.Id);             
             */
        } else if (ApexPages.currentPage() != null){
            string errMsg = 'Email could not be changed at this present time - please report to system administrator if error persists.';
            errMsg += '\r\n' + apiCall;                
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
            system.debug(errMsg); 
            emailResult = errMsg;                               
        }           
    
        //return pg;
                
    }   
               
    // Method to setup the customer object variable bound to visualforce page
    private void initializeCustomer(){

        customer = new apiCustomer.cls_Customer();
        customer.name = new apiCustomer.cls_name();
        customer.address = new apiCustomer.cls_address();
        
        apiCustomer.cls_item REFitem = new apiCustomer.cls_item();
        apiCustomer.cls_item[] REFitems = new apiCustomer.cls_item[]{};
            
        REFitem.x_type = 'EMAIL';
        REFitem.y_text = '';
        
        REFitems.add(REFitem);

        REFitem = new apiCustomer.cls_item();

        REFitem.x_type = 'SALESFORCEID';
        REFitem.y_text = '';
        
        REFitems.add(REFitem);
                
        customerReferences = new apiCustomer.cls_references();
        customerReferences.item = REFitems;
        customer.References = customerReferences;
        
        apiCustomer.cls_item PROPitem = new apiCustomer.cls_item();
        apiCustomer.cls_item[] PROPitems = new apiCustomer.cls_item[]{};
            
        PROPitem.x_type = 'PHONENUMBER';
        PROPitem.y_text = '';
        
        PROPitems.add(PROPitem);
        
        PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'BARCODENUMBER';
        PROPitem.y_text = '';
        
        PROPitems.add(PROPitem);

        PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'LEADSOURCE';
        PROPitem.y_text = defaultLeadSourceText; 
        
        PROPitems.add(PROPitem);
                
        customerProperties = new apiCustomer.cls_properties();      
        customerProperties.item = PROPitems;
        customer.Properties = customerProperties; 
      
        string villageCode = apiCustomerUtilities.getDefaultVillage();
        if (string.isnotBlank(villageCode)){
            this.customer.x_VillagePrimary = villageCode;
        }
        
        string lang = apiCustomerUtilities.getDefaultLanguage();
        if (string.isnotBlank(lang)){
            this.customer.x_Language = lang;
        }
                
    }
    
    private void getCustomerData(string recId){

system.debug('@@@@ getCustomerData for id ..  ' + recId);
        Account a = [select Customer_GUID__c from Account where Id = :recId];
        validPage = true; 
        string guid = a.Customer_GUID__c;
system.debug('@@@@ getCustomerData for guid ..  ' + guid);        
        if (string.isnotBlank(guid)){
            // Call api service utility class to retrieve record using GUID 
            string apiCall = apiService.readByGUID(guid);            
system.debug('@@@@ getCustomerData .. apiCall ' +apiCall);
            if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
                this.customer = apiCustomer.parseXML(apiCall);
                if (string.isBlank(this.customer.x_VillagePrimary)){
                    string villageCode = apiCustomerUtilities.getDefaultVillage();
                    if (string.isnotBlank(villageCode)){
                        this.customer.x_VillagePrimary = villageCode;
                    }                   
                }
                this.customerSaved = true;
                
            } else if (ApexPages.currentPage() != null){
                validPage = false; 
                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                                
            }            
            
        }        
        
    }

    // Guest delete method called from mobile page version
    @RemoteAction   
    public static string deleteGuest(string guestRecId){
        
        string returnValue = '';
        string guid = [select Customer_GUID__c from Account where id = :guestRecId].Customer_GUID__c;
        
        try{        

            returnValue = apiCustomerUtilities.deleteGuest(guid);
                   
            /*
            if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
                pg = new PageReference('/home/home.jsp'); // redirect to home page
                deleteResult = 'Request to delete guest has been successfully received and will be processed shortly.';
                                    
            } else{
                string errMsg = 'Guest could not be deleted at this present time - please report to system administrator if error persists.';
                errMsg += '\r\n' + apiCall;                
                system.debug(errMsg); 
                returnValue = errMsg;                               
                }
            */                      
        } catch (exception e){

            string errMsg = 'ERROR - Internal technical error - Guest could not be deleted at this present time - please report to system administrator if error persists.';
            errMsg += '\r\n' + e.getMessage() + ' : ' + e.getStackTraceString();                
            system.debug(errMsg); 
            returnValue = errMsg;                               
                            
        }
         return returnValue;
        
    }
    
    public PageReference saveCustomer(){                
        
        PageReference pg = null;
        string apiCallResponse = '';
        
        try{
            boolean newCustomer = false;
            if (string.isBlank(customer.x_CustomerId)){ //New customer, otherwise an amendment to an existing one
                newCustomer = true;

                customer.x_DateCreated = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            }
            
            string xmlCustomer = apiCustomer.convertToXML(customer);
     system.debug(' NEW CUSTOMER ...  ' + newCustomer + ' --- ' + customer.x_CustomerId);       
            /** JSON Processing  ****
            system.debug(customer);
            system.debug(json.serialize(customer));     
            string jsonCustomer = json.serializePretty(customer);
            // Replace JSON item prefixes to match interface message
            // defintion
            jsonCustomer = jsonCustomer.replace('x_', '@');
            jsonCustomer = jsonCustomer.replace('y_', '#');
            jsonCustomer = '{ "Customer":' + jsonCustomer + '}';
            
            // if Properties is after References, need to swap them round for precious IMG
            integer intPosReferences = jsonCustomer.indexOf('"References"');
            integer intPosProperties = jsonCustomer.indexOf('"Properties"');
            integer intPosName = jsonCustomer.indexOf('"name"');
            string properties = jsonCustomer.substring(intPosProperties, intPosName);
            string references = jsonCustomer.substring(intPosReferences, intPosProperties);
            
            if(intPosProperties > intPosReferences){
                system.debug (' PROPERTIES ..  ' +properties);
                string jsonCustomer1 = jsonCustomer.substring(0, intPosReferences);
                jsonCustomer1 = jsonCustomer1 + properties + references;
                system.debug (' JSON CUSTOMER 1 ..  ' + jsonCustomer1);
                string jsonCustomer2 = jsonCustomer.substring(intPosName);
                system.debug (' JSON CUSTOMER 2 ..  ' + jsonCustomer2);
                system.debug (' JSON CUSTOMER 1 + 2 ..  ' + jsonCustomer1 + jsonCustomer2);
                jsonCustomer = jsonCustomer1 + jsonCustomer2;
            }
            *****/

            Account newAccount = null;
            Account updAccount = null;
            
            if (newCustomer){                
                // Call Microservice API
                apiCallResponse = apiService.postNewCustomer(xmlCustomer);
                customerSaved = true;
            } else {                    
                apiCallResponse = apiService.updateCustomer(xmlCustomer);
                customerSaved = true;
            }
            
            // Check for error
            if (apiCallResponse.contains('ERROR') && ApexPages.currentPage() != null){
                
                customerSaved = false;
                
                string custErr = 'There was an error updating Customer data - please report to system administrator if error persists.';
                custErr += '\r\n' + apiCallResponse;                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, custErr));                
            } 
            
            if (newCustomer && customerSaved){
                newAccount = apiCustomer.upsertCustomer(apiCallResponse, true, customer.x_CustomerId, enumMap);
                if (newAccount != null){
                    pg = new PageReference('/' + newAccount.Id);
                    
                    /* - Following code triggers async process to pass Salesforce ID to Microservice for
                     * new guest which may (or may not) be required
                    Integration_Salesforce_Id_Queue__c q = new Integration_Salesforce_Id_Queue__c();
                    q.Salesforce_Id__c = newAccount.Id;
                    q.Customer_GUID__c = newAccount.Customer_GUID__c;   
                    insert q;
                    // queue async job to send sf id
                    system.enqueueJob(new apiCustomerSFIDUpdateQueue());
                    */
                } 
            }
            
            if (!newCustomer  && customerSaved){
                updAccount = apiCustomer.upsertCustomer(apiCallResponse, false, customer.x_CustomerId, enumMap);
                if (updAccount != null)
                    pg = new PageReference('/' + updAccount.Id); 
            }
                        
        } catch (exception e){

            string errMsg = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
            if (ApexPages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
            }
            system.debug(errMsg);               
        }
        
        return pg;
    }
    

    
    public PageReference Cancel(){
        
        if (theController != null)
            return theController.cancel();
        
        if (theSetController != null)
            return theSetController.cancel();
            
        return null;    
    }
    
    // Retrieve Gender lookup
    public list<SelectOption> getGenders(){
        
        list<SelectOption> returnList = new list<SelectOption>();
        map<string, string> enumValues = new map<string, string>();

        if (Genders == null) {
        
            enumValues = apiCustomerUtilities.getEnumValueMap('Genders');
            returnList.add(new SelectOption('', '-- Please Select --'));
            
            if (enumValues != null){
                for (string key :enumValues.keySet()){
                    returnList.add(new SelectOption(key, enumValues.get(key)));
                }
                enumMap.put('Gender', enumValues);              
            } else if (ApexPages.currentPage() != null){
                validPage = false; 
                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                                
            }
        
        }    
        return returnList;
    }
    
    // Retrieve Villages enum
    public list<SelectOption> getVillages(){

        list<SelectOption> returnList = new list<SelectOption>();
        map<string, string> enumValues = new map<string, string>();

        if (Villages == null) {
        
            enumValues = apiCustomerUtilities.getEnumValueMap('Villages');
            returnList.add(new SelectOption('', '-- Please Select --'));
            
            if (enumValues != null){
                for (string key :enumValues.keySet()){
                    returnList.add(new SelectOption(key, enumValues.get(key)));
                }
                enumMap.put('VillagePrimary', enumValues);              
            } else if (ApexPages.currentPage() != null){
                validPage = false; 
                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                                
            }
        
        }    
        return returnList;


        /*** JSON Enum Service version  ***        
        
        list<SelectOption> returnList = new list<SelectOption>();       
        
        if (villages == null){
            returnList.add(new SelectOption('', '-- Please Select --'));
            
            string jsonVillages = apiService.readEnum('villages');

            if (string.isNotBlank(jsonVillages)){
                apiEnum.cls_Navigation enumVillages = apiEnum.parse(jsonVillages);
        
                for (apiEnum.cls_Navigation n :enumVillages.Navigation){
                    string itemId = '';
                    string itemText = '';
                    for (apiEnum.cls_Property p :n.Property){               
                        if (p.x_key == 'VillageId')
                            itemId = p.y_text;
                        if (p.x_Key == 'Name')
                            itemText = p.y_text;    
                    }
                    if (string.isnotBlank(itemId) && string.isnotBlank(itemText)){
                        returnList.add(new SelectOption(itemId, itemText));
                    }       
                }
            } else {
                string errMsg = 'Lookup values cannot be retrieved at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                   
            }
        } else {
            returnList = villages;
        }
        return returnList;

        *****/
    }

    // Retrieve Countries enum
    public list<SelectOption> getCountries(){
                
        list<SelectOption> returnList = new list<SelectOption>();
        map<string, string> enumValues = new map<string, string>();

        if (Countries == null) {
        
            enumValues = apiCustomerUtilities.getEnumValueMap('Countries');
            returnList.add(new SelectOption('', '-- Please Select --'));
            
            if (enumValues != null){
                for (string key :enumValues.keySet()){
                    returnList.add(new SelectOption(key, enumValues.get(key)));
                }
                enumMap.put('Country', enumValues);
                enumMap.put('CountryOfResidence', enumValues);                
            } else if (ApexPages.currentPage() != null){
                validPage = false; 
                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                                
            }
        
        }    
        return returnList;



        /**** JSON ENUM version ****
        list<SelectOption> returnList = new list<SelectOption>();       
        if (countries == null) {

            returnList.add(new SelectOption('', '-- Please Select --'));
            
            string jsonCountries = apiService.readEnum('countries');
            if (string.isNotBlank(jsonCountries)){
                apiEnum.cls_Navigation enumVillages = apiEnum.parse(jsonCountries);
        
                for (apiEnum.cls_Navigation n :enumVillages.Navigation){
                    string itemId = '';
                    string itemText = '';
                    for (apiEnum.cls_Property p :n.Property){               
                        if (p.x_key == 'ISOCode')
                            itemId = p.y_text;
                        if (p.x_Key == 'Name')
                            itemText = p.y_text;    
                    }
                    if (string.isnotBlank(itemId) && string.isnotBlank(itemText)){
                        returnList.add(new SelectOption(itemId, itemText));
                    }       
                }
                if (returnList.size() > 1){
                    returnList.remove(0);
                    returnList = PicklistUtilities.selectOptionSortByLabel(returnList);                    
                    returnList.add(0, new SelectOption('', '-- Please Select --'));
                }
            } else {
                validPage = false; 
                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                                
            }
        } else {
            returnList = countries;
        }
        return returnList;
        
        *******/
    }
    

    // Retrieve Languages enum
    public list<SelectOption> getLanguages(){

        
        list<SelectOption> returnList = new list<SelectOption>();
        map<string, string> enumValues = new map<string, string>();

        if (Languages == null) {
        
            enumValues = apiCustomerUtilities.getEnumValueMap('Languages');
            returnList.add(new SelectOption('', '-- Please Select --'));
            
            if (enumValues != null){
                for (string key :enumValues.keySet()){
                    returnList.add(new SelectOption(key, enumValues.get(key)));
                }
                enumMap.put('Language', enumValues);              
            } else if (ApexPages.currentPage() != null){
                validPage = false; 
                string errMsg = 'The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                                
            }
        
        }    
        return returnList;

        /*** JSON Enum version ***        
        list<SelectOption> returnList = new list<SelectOption>();
        if (languages == null){         
            returnList.add(new SelectOption('', '-- Please Select --'));
            
            string jsonLanguages = apiService.readEnum('languages');
            if (string.isnotBlank(jsonLanguages)){
                apiEnum.cls_Navigation enumVillages = apiEnum.parse(jsonLanguages);
        
                for (apiEnum.cls_Navigation n :enumVillages.Navigation){
                    string itemId = '';
                    string itemText = '';
                    for (apiEnum.cls_Property p :n.Property){               
                        if (p.x_key == 'Name')
                            itemId = p.y_text;
                        if (p.x_Key == 'Description')
                            itemText = p.y_text;    
                    }
                    if (string.isnotBlank(itemId) && string.isnotBlank(itemText)){
                        returnList.add(new SelectOption(itemId, itemText));
                    }       
                }
            } else {
                string errMsg = 'Lookup values cannot be retrieved at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);                
            }

        } else {
            returnList = languages;
        }
        return returnList;

        *****/
    }   


    // Guest read method called from mobile page version
    @RemoteAction
    public static string readGuest(string recId){
        
        
        Account a = [select Customer_GUID__c from Account where Id = :recId];
        apiCustomer.cls_Customer customer = new apiCustomer.cls_Customer();
        string returnValue = '';
        
        string guid = a.Customer_GUID__c;
system.debug('@@@@ getCustomerData for guid ..  ' + guid);        
        if (string.isnotBlank(guid)){
            // Call api service utility class to retrieve record using GUID 
            string apiCall = apiService.readByGUID(guid);            
system.debug('@@@@ getCustomerData .. apiCall ' +apiCall);
            if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
                customer = apiCustomer.parseXML(apiCall);
                if (string.isBlank(customer.x_VillagePrimary)){
                    string villageCode = apiCustomerUtilities.getDefaultVillage();
                    if (string.isnotBlank(villageCode)){
                        customer.x_VillagePrimary = villageCode;
                    }                   
                }                
                returnValue =  json.serialize(customer);
            } else if (ApexPages.currentPage() != null){
                string errMsg = 'ERROR - The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);
                returnValue = errMsg;
            }            
            
        } 
        
        return returnValue;
    }
    

    // Guest upsert method called from mobile page version
    @RemoteAction
    public static string saveGuest(string recId, string title, string firstName, string lastName,
                                        string gender, string birthDate, string mobile,
                                        string email, string village, string language,
                                        string address1, string address2,
                                        string city, string county, string postCode,
                                        string country, string leadsourcetext,
                                        string optoutEmail, string optoutMobile, string optoutPostal
                                        ){
                                   system.debug('save guest called @ @ @ @ ');        
                                   system.debug('entry leadsourcetext @@ '+ leadsourcetext);          
        string returnVal = '';
        string guid = '';
        string apiCall = '';
        boolean customerSaved = false;
        map<string, map<string, string>> enumMap = new map<string, map<string, string>>();
        map<string, string> enumValues = new map<string, string>();
        
        map<string, integer> prefIndex = new map<string, integer>();
        integer index = 3;
                    
        apiCustomer.cls_Customer customer = new apiCustomer.cls_Customer();
        apiCustomer.cls_properties customerProperties = new apiCustomer.cls_properties();
        apiCustomer.cls_references customerReferences = new apiCustomer.cls_references();
        
        boolean newCustomer = false;
        string apiCallResponse = '';
        
        if (string.isBlank(recId)){ //New customer, otherwise an amendment to an existing one
            newCustomer = true;
     
            customer.name = new apiCustomer.cls_name();
            customer.address = new apiCustomer.cls_address();
            
            apiCustomer.cls_item REFitem = new apiCustomer.cls_item();
            apiCustomer.cls_item[] REFitems = new apiCustomer.cls_item[]{};
                
            REFitem.x_type = 'EMAIL';
            REFitem.y_text = '';
            
            REFitems.add(REFitem);
    
            REFitem = new apiCustomer.cls_item();
                    
            customerReferences = new apiCustomer.cls_references();
            customerReferences.item = REFitems;
            customer.References = customerReferences;
            
            apiCustomer.cls_item PROPitem = new apiCustomer.cls_item();
            apiCustomer.cls_item[] PROPitems = new apiCustomer.cls_item[]{};
                
            PROPitem.x_type = 'PHONENUMBER';
            PROPitem.y_text = '';            
            PROPitems.add(PROPitem);
            
system.debug('@@@@  Lead Source Text is .. ' + leadsourcetext);
            PROPitem = new apiCustomer.cls_item();
            PROPitem.x_type = 'LEADSOURCE';
            PROPitem.y_text = 'leadsourcetext';              
            PROPitems.add(PROPitem);
                                
            customerProperties = new apiCustomer.cls_properties();      
            customerProperties.item = PROPitems;
            customer.Properties = customerProperties;
            customer.x_DateCreated = datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            
        } else {
            Account a = [select Customer_GUID__c from Account where Id = :recId];
            newCustomer = false;
            guid = a.Customer_GUID__c;          
            apiCall = apiService.readByGUID(guid);            
system.debug('@@@@ getCustomerData .. apiCall ' +apiCall);
            if (string.isnotBlank(apiCall) && !apiCall.contains('Error')){
                customer = apiCustomer.parseXML(apiCall);
system.debug('@@@@  allProperties  DURING SAVE  ' + customer.allProperties);
system.debug('@@@@  allReferences  DURING SAVE ' + customer.allReferences);
                
            } else if (ApexPages.currentPage() != null){
                string errMsg = 'ERROR - The system is not available at present, please retry in a moment. If problem persists, report to system administrator';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                system.debug(errMsg);
                returnVal = errMsg;                                
            }                       
            
        }

        if (string.isBlank(returnVal)){
            customer.name.x_Title = title;
            customer.name.x_Given = firstName;
            customer.name.x_Family = lastName;
            customer.x_Gender = gender;
            //if (string.isnotBlank(birthDate))
            //  customer.x_DateOfBirth = Date.newInstance(birthDate);
            if (string.isnotBlank(birthDate)){
                Date dt = null;
                try {
                    dt = Date.parse(birthDate);
                    customer.x_DateOfBirth = dt;
                }catch (exception e){
                    // do nothing - invalid date
                }
            } 

            apiCustomer.cls_item[] chkPROPitems = customer.properties.item;
system.debug('@@@@   chkPROPitems  ' + chkPROPitems);            
            boolean phoneExists = false;

            boolean leadsourceExists = false;
            boolean optoutEmailExists = false;
            boolean optoutMobileExists = false;
            boolean optoutPostalExists = false;
            
            index = 0;
            for (apiCustomer.cls_item chk :chkPROPitems){
                if (chk.x_type == 'PHONENUMBER'){
                    phoneExists = true;
                    prefIndex.put('PHONENUMBER', index);
                }
                if (chk.x_type == 'LEADSOURCE'){
                    leadsourceExists = true;
                    prefIndex.put('LEADSOURCE', index);
                }                
                if (chk.x_type == 'OPTOUTEMAIL'){
                    optoutEmailExists = true;
                    prefIndex.put('OPTOUTEMAIL', index);
                }
                if (chk.x_type == 'OPTOUTMOBILE'){
                    optoutMobileExists = true;
                    prefIndex.put('OPTOUTMOBILE', index);
                }
                if (chk.x_type == 'OPTOUTPOSTAL'){
                    optoutPostalExists = true;
                    prefIndex.put('OPTOUTPOSTAL', index);
                }
                index++;
            }
system.debug('@@@@   prefIndex 1  ' + prefIndex);             
            if (!phoneExists){
                apiCustomer.cls_item addItem = new apiCustomer.cls_item();
                addItem.x_type = 'PHONENUMBER';
                addItem.y_text = '';               
                customer.properties.item.add(addItem);
                index = customer.properties.item.size() - 1;
                prefIndex.put('PHONENUMBER', index);
            }
            
            if (!leadsourceExists && string.isnotBlank(leadsourcetext)){
                apiCustomer.cls_item addItem = new apiCustomer.cls_item();
                addItem.x_type = 'LEADSOURCE';
                addItem.y_text = '';            
                customer.properties.item.add(addItem);
                index = customer.properties.item.size() - 1;
                prefIndex.put('LEADSOURCE', index);
                system.debug('leadsourcetext value '+ leadsourcetext );
                /////////
            }           
  
            
            if (!optoutEmailExists && string.isnotBlank(optoutEmail)){
                apiCustomer.cls_item addItem = new apiCustomer.cls_item();
                addItem.x_type = 'OPTOUTEMAIL';
                addItem.y_text = '';            
                customer.properties.item.add(addItem);
                index = customer.properties.item.size() - 1;
                prefIndex.put('OPTOUTEMAIL', index);                
            }
            if (!optoutMobileExists && string.isnotBlank(optoutMobile)){
                apiCustomer.cls_item addItem = new apiCustomer.cls_item();
                addItem.x_type = 'OPTOUTMOBILE';
                addItem.y_text = '';            
                customer.properties.item.add(addItem);
                index = customer.properties.item.size() - 1;
                prefIndex.put('OPTOUTMOBILE', index);                
            }
            if (!optoutPostalExists && string.isnotBlank(optoutPostal)){
                apiCustomer.cls_item addItem = new apiCustomer.cls_item();
                addItem.x_type = 'OPTOUTPOSTAL';
                addItem.y_text = '';            
                customer.properties.item.add(addItem);
                index = customer.properties.item.size() - 1;
                prefIndex.put('OPTOUTPOSTAL', index);                 
            }
system.debug('@@@@   prefIndex 2  ' + prefIndex);             
            customer.properties.item[prefIndex.get('PHONENUMBER')].y_text = mobile;
            
            // only set if new customer
            if (string.isnotBlank(leadsourcetext))
                customer.properties.item[prefIndex.get('LEADSOURCE')].y_text = leadsourcetext;
                system.debug('Leadsourcetext prefIndex'+leadsourcetext);

            
            if (string.isnotBlank(optoutEmail)){
                customer.properties.item[prefIndex.get('OPTOUTEMAIL')].y_text = optoutEmail;
            }

            if (string.isnotBlank(optoutMobile)){           
                customer.properties.item[prefIndex.get('OPTOUTMOBILE')].y_text = optoutMobile;
            }
    
            if (string.isnotBlank(optoutPostal)){           
                customer.properties.item[prefIndex.get('OPTOUTPOSTAL')].y_text = optoutPostal;
            }
                        
            if (string.isBlank(customer.references.item[0].y_text))
                customer.references.item[0].y_text = email;
            customer.x_VillagePrimary = village;
            customer.x_Language = language;
            
            customer.address.x_AddressLine1 = address1;
            customer.address.x_AddressLine2 = address2;
            customer.address.x_City = city;
            customer.address.x_County = county;
            customer.address.x_PostCode = postCode;
            customer.address.x_Country = country;

            if (string.isBlank(customer.x_VillagePrimary)){
                string villageCode = apiCustomerUtilities.getDefaultVillage();
                if (string.isnotBlank(villageCode)){
                    customer.x_VillagePrimary = villageCode;
                }                   
            }
            
            // Add remaining non-salesforce properties to message
            if (customer.allProperties != null){
                for (string key :customer.allProperties.keySet()){
                    if (!prefIndex.containsKey(key)){
                        apiCustomer.cls_item addItem = new apiCustomer.cls_item();
                        addItem.x_type = key;
                        addItem.y_text = customer.allProperties.get(key);            
                        customer.properties.item.add(addItem);                    
                    }       
                }
            }
            
            // Add other non-Salesforce references to message
            if (customer.allReferences != null){
                for (string key :customer.allReferences.keySet()){
                    if (key != 'EMAIL' && key !='SALESFORCEID' && key != 'BARCODENUMBER'){
                        apiCustomer.cls_item REFitem = new apiCustomer.cls_item();                                            
                        REFitem.x_type = key;
                        REFitem.y_text = customer.allReferences.get(key);
                        
                        customer.References.item.add(REFItem);                    
                        
                    }
                }            
            }
            
            string xmlCustomer = apiCustomer.convertToXML(customer);
            Account newAccount = null;
            Account updAccount = null;
            


            if (newCustomer){                
                // Call Microservice API
                apiCallResponse = apiService.postNewCustomer(xmlCustomer);
                customerSaved = true;
            } else {                    
                apiCallResponse = apiService.updateCustomer(xmlCustomer);
                customerSaved = true;
            }
            
            // Check for error
            if (apiCallResponse.contains('ERROR') && ApexPages.currentPage() != null){
                
                customerSaved = false;
                
                string custErr = 'ERROR - There was an error updating Customer data - please report to system administrator if error persists.';
                custErr += '\r\n' + apiCallResponse;                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, custErr));
                returnVal = custErr;                
            }

            enumValues = apiCustomerUtilities.getEnumValueMap('Villages');
            enumMap.put('VillagePrimary', enumValues);
            enumValues = apiCustomerUtilities.getEnumValueMap('Genders');
            enumMap.put('Gender', enumValues);
            enumValues = apiCustomerUtilities.getEnumValueMap('Languages');
            enumMap.put('Language', enumValues);
            enumValues = apiCustomerUtilities.getEnumValueMap('Countries');
            enumMap.put('Country', enumValues);
            enumMap.put('CountryOfResidence', enumValues);      
            
            if (newCustomer && customerSaved){
                newAccount = apiCustomer.upsertCustomer(apiCallResponse, true, customer.x_CustomerId, enumMap);
                if (newAccount != null){
                    returnVal = newAccount.Id;
                    
                    /* - Following code triggers async process to pass Salesforce ID to Microservice for
                     * new guest which may (or may not) be required
                    Integration_Salesforce_Id_Queue__c q = new Integration_Salesforce_Id_Queue__c();
                    q.Salesforce_Id__c = newAccount.Id;
                    q.Customer_GUID__c = newAccount.Customer_GUID__c;   
                    insert q;
                    // queue async job to send sf id
                    system.enqueueJob(new apiCustomerSFIDUpdateQueue());
                    */
                } 
            }
                
            if (!newCustomer  && customerSaved){
                updAccount = apiCustomer.upsertCustomer(apiCallResponse, false, customer.x_CustomerId, enumMap);
                if (updAccount != null)
                    returnVal = updAccount.Id; 
            }        
        }
        
        return returnVal;     
    }
    
    
     @RemoteAction
     public static String getLevelandStars(string recId){
         list<apiCustomerRead.cls_CustomerReadItem> itemList = new list <apiCustomerRead.cls_CustomerReadItem>();
         map<string, list<apiCustomerRead.cls_CustomerReadItem>> readOnlyItems = new map<string, list<apiCustomerRead.cls_CustomerReadItem>>();
         string guid = [select id, Customer_GUID__c FROM Account WHERE id =: recId].Customer_GUID__c;     
         string apiCall = apiService.getLevelandStars(guid);
         apiCall = apiCall.trim(); 
         itemList = apiCustomerRead.parseXML(apiCall, 'MembershipStatus');
         readOnlyItems.put('MembershipStatus', itemList);
      
     return json.serialize(readOnlyItems);
     
     }
     
         
    // method used on mobile guest creation screen to retrive enum dropdowns
    @RemoteAction
    public static string getDropdownValues(){
        
        map <string, map<string, string>> returnList = new map<string, map<string, string>>();
        list<string> enumList = new list<string>();
        enumList.add('Countries');
        enumList.add('Villages');
        enumList.add('Genders');
        enumList.add('Languages');
        JSONGenerator gen;
        
        gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        for(string s :enumList){
            map<string, string> theValues =  apiCustomerUtilities.getEnumValueMap(s);
    
            returnList.put(s, theValues);


            gen.writeFieldname(s);
            gen.writeStartArray();
            for (string key :theValues.keySet()){
                gen.writeStartObject();
                gen.writestringfield(key, theValues.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
            
            
            
        }
        gen.writeEndObject();
        gen.close();
        return gen.getAsString();
        //return json.serialize(returnList); //?? Reverse sorts the values map for some reason, therefore using JSON Generator      
        
    }
    @RemoteAction
    Public static string getLeadSourceTextValues(){
        return apiCustomerUtilities.getLeadSourceTextValues();  
    }
    
    // method used on mobile guest creation screen to retrive default primary village value
    @RemoteAction
    public static string getDefaultVillage(){
        
        return apiCustomerUtilities.getDefaultVillage();
        
    }   

    // method used on mobile guest creation screen to retrive default preferred language value
    @RemoteAction
    public static string getDefaultLanguage(){
        
        return apiCustomerUtilities.getDefaultLanguage();
        
    }    
    
                
}