/*
    Customer definition class
    
    Created : 28/05/2015
    Author: Constantine Chimonides

*/
public class apiCustomer {
    
    private static final id customerRecordTypeID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Guest').RecordTypeId;
    private static map<string, string> allPropertiesMap = new map<string, string>();
    private static map<string, string> allReferencesMap = new map <string, string>();
    
    public class cls_Customer {

        public cls_references References {get;set;}
        public cls_properties Properties {get; set;}        
        public cls_name name {get;set;}
        public cls_address address {get;set;}
        
        public String x_CustomerId {get;set;}               //00000000-0000-0000-0000-000000000000
        public String x_VersionId {get;set;}               //00000000-0000-0000-0000-000000000000
        public String x_DateCreated {get;set;}         //2015-01-27T02:47:46.5203626Z
        public String x_Language {get;set;}                //de-de -- ENUM
        public String x_Gender {get;set;}    //1
        public String x_VillagePrimary {get;set;}      //WV  -- ENUM
        public String x_Source {get;set;}     //Web
        public date x_DateOfBirth {get; set;}
        
        public map<string, string> allProperties {get; set;}
        public map<string, string> allReferences {get; set;}
        
        //Preferences
        public map<string, string> preferenceMap {get; set;}
        public string x_optInStatus {get;set;}
            
        public cls_Customer(){

            this.x_Language = '';
            this.x_Gender = '';
            this.x_VillagePrimary = '';
            this.x_Source = 'SFTIC';
            this.x_DateOfBirth = null;
            
            this.name = new cls_name();
            this.address = new cls_address();
            
            // retrieve preferences required from custom setting
        	map<String, API_Preference_Map__c> preferenceSettings = API_Preference_Map__c.getAll();
 			this.preferenceMap = new map<string, string>();
            for(string key :preferenceSettings.keySet()){
            	this.preferenceMap.put(key, '');
            }
            
        }

    }
    
    public class cls_properties {
        public cls_item[] item{get;set;}
    }    
    
    public class cls_references {
        public cls_item[] item{get;set;}
        
    }

    public class cls_item {
        public String x_type{get;set;}          //CUSTOMERID    
        public String y_text{get;set;}          //000000
    }
        
    public class cls_name {
        public String x_Title{get;set;}           //Mr
        public String x_Given{get;set;}       //John
        public String x_Family{get;set;}      //Doe
    }

    public class cls_address {
        public String x_AddressLine1{get;set;}        //4 The Address
        public String x_AddressLine2{get;set;}        //4 The Address
        public String x_County{get;set;}        //4 The Address 
        public String x_City{get;set;}            //London
        public String x_PostCode{get;set;}                //000
        public String x_Country{get;set;}   //UK -- ENUM
        
        public cls_address(){
            this.x_AddressLine1 = '';
            this.x_AddressLine2 = '';
            this.x_County = '';
            this.x_City = '';
            this.x_PostCode = '';
            this.x_Country = '';
            
        }
    }

    // Method to deserialize JSON string into an apiCustomer object
    public static apiCustomer parse(String json){
        return (apiCustomer) System.JSON.deserialize(json, apiCustomer.class);
    }
    

    // Method to deserialize XML string into an apiCustomer object
    public static apiCustomer.cls_Customer parseXML(String xmlCustomer){
       
        apiCustomer.cls_Customer returnCustomer = new apiCustomer.cls_Customer();
        
        map<string, string> valueMap = getValuesFromXMLString(xmlCustomer, false, null);
		
        returnCustomer.allProperties = allPropertiesMap;
		returnCustomer.allReferences = allReferencesMap;        

        system.debug('@@@@  valueMap  ' + valueMap);

        returnCustomer.x_CustomerId = valueMap.get('CustomerGuId');
        returnCustomer.x_VersionId = valueMap.get('VersionId');
        if (valueMap.get('DateOfBirth') != null){
            returnCustomer.x_DateOfBirth = date.valueOf(valueMap.get('DateOfBirth'));    
        }
        returnCustomer.x_Language = valueMap.get('Language');
        returnCustomer.x_Gender = valueMap.get('Gender');
        returnCustomer.x_VillagePrimary = valueMap.get('VillagePrimary');
        returnCustomer.x_Source = valueMap.get('Source');
        
        returnCustomer.Properties = new apiCustomer.cls_properties();
        returnCustomer.Properties.item = new list<apiCustomer.cls_item>();
        apiCustomer.cls_item PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'PHONENUMBER';
        PROPitem.y_text = valueMap.get('PHONENUMBER');
        returnCustomer.Properties.item.add(PROPItem);

        PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'LEADSOURCE';
        PROPitem.y_text = valueMap.get('LEADSOURCE');
        returnCustomer.Properties.item.add(PROPItem);

        PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'OPTOUTEMAIL';
        PROPitem.y_text = valueMap.get('OPTOUTEMAIL');
        returnCustomer.Properties.item.add(PROPItem);

        PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'OPTOUTMOBILE';
        PROPitem.y_text = valueMap.get('OPTOUTMOBILE');
        returnCustomer.Properties.item.add(PROPItem);
        
        PROPitem = new apiCustomer.cls_item();
        PROPitem.x_type = 'OPTOUTPOSTAL';
        PROPitem.y_text = valueMap.get('OPTOUTPOSTAL');
        returnCustomer.Properties.item.add(PROPItem);
                                
        returnCustomer.References = new apiCustomer.cls_references();
        returnCustomer.References.item = new list<apiCustomer.cls_item>();
        apiCustomer.cls_item REFitem = new apiCustomer.cls_item();
        REFitem.x_type = 'EMAIL';
        REFitem.y_text = valueMap.get('EMAIL');
        returnCustomer.References.item.add(REFItem);

        /*
        REFitem = new apiCustomer.cls_item();
        REFitem.x_type = 'CUSTOMERID';
        REFitem.y_text = valueMap.get('CUSTOMERID');
        returnCustomer.References.item.add(REFItem);        
		*/
        
        REFitem = new apiCustomer.cls_item();
        REFitem.x_type = 'SALESFORCEID';
        REFitem.y_text = valueMap.get('SALESFORCEID');
        returnCustomer.References.item.add(REFItem);

        REFitem = new apiCustomer.cls_item();
        REFitem.x_type = 'BARCODENUMBER';
        REFitem.y_text = valueMap.get('BARCODENUMBER');
        returnCustomer.References.item.add(REFItem);
                                                                           
        returnCustomer.name.x_Title = valueMap.get('Title');
        returnCustomer.name.x_Given = valueMap.get('Given');
        returnCustomer.name.x_Family = valueMap.get('Family');
        
        string addressLine = valueMap.get('AddressLine');
        if(string.isnotBlank(addressLine)){
            list<string> addressLines = addressLine.split(',');
            returnCustomer.address.x_AddressLine1 = addressLines[0];
            if (addressLines.size() == 2){
                returnCustomer.address.x_AddressLine2 = addressLines[1];
            }
        }
        returnCustomer.address.x_city = valueMap.get('City');
        returnCustomer.address.x_county = valueMap.get('County');
        returnCustomer.address.x_postcode = valueMap.get('PostCode');
        returnCustomer.address.x_country = valueMap.get('Country');
        
        return returnCustomer;
    }

    public static apiCustomer.cls_Customer parsePreferenceXML(String xmlPreferences, apiCustomer.cls_Customer customer){
               
        map<string, string> valueMap = getPreferenceValuesFromXMLString(xmlPreferences, customer);
system.debug('@@@ valueMap preferenceValues  ' + valueMap);
 
        // retrieve preferences required from custom setting
        map<String, API_Preference_Map__c> preferenceSettings = API_Preference_Map__c.getAll();
 		customer.preferenceMap = new map<string, string>();
 		
 		// populate preference map with values returned
        for (string key: preferenceSettings.keySet()){
        	string value = '';
        	if (valueMap.containsKey(preferenceSettings.get(key).API_Name__c)){
        		value = valueMap.get(preferenceSettings.get(key).API_Name__c);
        	}
        	customer.preferenceMap.put(key, nullToEmptyString(value));        	
        }
        
        return customer;   
        
    }
    
    private static map<string, string> getPreferenceValuesFromXMLString(string xmlString, apiCustomer.cls_Customer customer){

        string email = '';
        string mobile = '';
        string post = '';
        string privacy = '';
        string thirdParty = '';
        
        map<string, string> returnMap = new map<string, string>();

        TG_XmlDom dom = new TG_XmlDom(xmlString);
        TG_XmlNode root = dom.root;         

        TG_XmlNode preferences = root.getElementByTagName('CustomerPreferences');    	
    	
        list<TG_XmlNode> preferenceItems = preferences.getElementsByTagName('CustomerPreference');
        for (TG_XmlNode node :preferenceItems){
           
            string nodeType = node.getAttribute('Key');
           	  
            if (nodeType == 'email'){
                email = nullToEmptyString(node.getAttribute('Value'));
            }
            if (nodeType == 'mobile'){
                mobile = nullToEmptyString(node.getAttribute('Value'));
            }
            if (nodeType == 'post'){
                post = nullToEmptyString(node.getAttribute('Value'));
            }
            if (nodeType == 'privacy'){
                privacy = nullToEmptyString(node.getAttribute('Value'));
            }
            if (nodeType == 'thirdParty'){
                thirdParty = nullToEmptyString(node.getAttribute('Value'));
            }                        
        }        
        
        returnMap.put('email', email);
        returnMap.put('mobile', mobile);
        returnMap.put('post', post);
        returnMap.put('privacy', privacy);
        returnMap.put('thirdParty', thirdParty);
        
        return returnMap;
    }         
    
    // Method to convert customer object into an XML string
    public static string convertToXML(apiCustomer.cls_Customer customer){

    /* Example string
    <Customer CustomerId="00000000-0000-0000-0000-000000000000" 
              VersionId="00000000-0000-0000-0000-000000000000" 
              DateCreated="2015-01-27T02:47:46.5203626Z" 
              DateOfBirth="" 
              DateMembership="" 
              Language="de-de" 
              Gender="1" 
              VillagePrimary="WV" 
              Source="Web">
        <Properties>
            <item type="CUSTOMERIDHASH">0000000000000000000000000000000000000000</item>
            <item type="CUSTOMERCARDID" />
            <item type="PHONENUMBER" />
            <item type="BARCODENUMBER">76008728412950</item>
            <item type="OLDCOUNTRY">GERMANY</item>
            <item type="OLDGENDER">Male</item>
            <item type="OLDLANGUAGE">DE</item>
        </Properties>
        <References>
            <item type="CUSTOMERID">000000</item>
            <item type="EMAIL">john.doe@domain.com</item>
        </References>
        <name Title="Mr" Given="John" Family="Doe" />
        <address AddressLine1="4 The Address" AddressLine2="" County="" City="London" PostCode="000" Country="UK" />
    </Customer>
    
    
    */      
        XmlStreamWriter w = new XmlStreamWriter();
        string m;
        string d;
        
        w.writeStartElement(null, 'Customer', null);
        	if (string.isnotBlank(customer.x_CustomerId))
            	w.writeAttribute(null, null, 'CustomerId', customer.x_CustomerId);
            if (string.isnotBlank(customer.x_VersionId))
            	w.writeAttribute(null, null, 'VersionId', customer.x_VersionId);
            string dateCreated = nullToEmptyString(customer.x_DateCreated);
            if (string.isnotBlank(dateCreated)){
                w.writeAttribute(null, null, 'DateCreated', dateCreated);
            }
            if (customer.x_DateOfBirth != null){
                date dtdob = customer.x_DateOfBirth;
                m = padZero(dtdob.month());
                d = padZero(dtdob.day());
                //string dob = dtdob.month() + '/' + dtdob.day() + '/' + dtdob.year(); 
                string dob = dtdob.year() + '-' + m + '-' + d;                               
                w.writeAttribute(null, null, 'DateOfBirth', dob);
            } else {
                //w.writeAttribute(null, null, 'DateOfBirth', '');
            }
            
            string language = nullToEmptyString(customer.x_Language);
            string gender = nullToEmptyString(customer.x_Gender);
            string village = nullToEmptyString(customer.x_VillagePrimary);
        
            w.writeAttribute(null, null, 'Language', language);
            w.writeAttribute(null, null, 'Gender', gender);
            w.writeAttribute(null, null, 'VillagePrimary', village);
            w.writeAttribute(null, null, 'Source', customer.x_Source);
            
            w.writeStartElement(null, 'Properties', null);
            if(customer.Properties.item != null){
                for (apiCustomer.cls_item property :customer.Properties.item){
                    w.writeStartElement(null, 'item', null);
                    w.writeAttribute(null, null, 'type', property.x_type);
                    w.writeCharacters(property.y_text);
                    w.writeEndElement(); 
                }
            }
            w.writeEndElement();
            
            w.writeStartElement(null, 'References', null);
            if(customer.References.item != null){
                for (apiCustomer.cls_item reference :customer.References.item){
                    if (string.isnotBlank(reference.y_text)){
                        w.writeStartElement(null, 'item', null);
                        w.writeAttribute(null, null, 'type', reference.x_type);
                        w.writeCharacters(reference.y_text);
                        w.writeEndElement();
                    }
                }
            }
            w.writeEndElement();
            
            w.writeStartElement(null, 'name', null);
				if (string.isnotBlank(customer.name.x_Title)) {
                    w.writeAttribute(null, null, 'Title', customer.name.x_Title);
                } else {
                    w.writeAttribute(null, null, 'Title', '');  // Digital requires Title attribute to be sent even if empty - bug#2362
                }
                if (string.isnotBlank(customer.name.x_Given))
                	w.writeAttribute(null, null, 'Given', customer.name.x_Given);
                if (string.isnotBlank(customer.name.x_Family))
                	w.writeAttribute(null, null, 'Family', customer.name.x_Family);
            w.writeEndElement();                

            w.writeStartElement(null, 'address', null);
                w.writeAttribute(null, null, 'AddressLine1', nullToEmptyString(customer.address.x_AddressLine1));
                w.writeAttribute(null, null, 'AddressLine2', nullToEmptyString(customer.address.x_AddressLine2));
                w.writeAttribute(null, null, 'County', nullToEmptyString(customer.address.x_County));
                w.writeAttribute(null, null, 'City', nullToEmptyString(customer.address.x_City));
                w.writeAttribute(null, null, 'PostCode', nullToEmptyString(customer.address.x_PostCode));
                string country = nullToEmptyString(customer.address.x_Country);
                w.writeAttribute(null, null, 'Country', country);
            w.writeEndElement();
        
        w.writeEndElement();
        
        return w.getXmlString();                
    }

    // parse xml to populate values in a map object
    // perform any data transformations required prior to updating Salesforce in this method (if required)
    // Inputs : xmlString, the string to deserialize, transform - boolean value to determine whether to
    // perform transformation logic (for Salseforce upsert)
    private static map<string, string> getValuesFromXMLString(string xmlString, boolean transform, map<string, map<string,string>> enumMap){
    
        map<string, string> returnMap = new map<string, string>();
        map<string, string> enumValues = null;

        TG_XmlDom dom = new TG_XmlDom(xmlString);
        TG_XmlNode root = dom.root;
        
        TG_XmlNode customer = root.getElementByTagName('Customer');
        
        string customerGuid = customer.getAttribute('CustomerId');
        string versionId = customer.getAttribute('VersionId');
        string dateOfBirth = customer.getAttribute('DateOfBirth');
        
        string language = customer.getAttribute('Language');
        if (transform && enumMap != null){
            if (enumMap.containsKey('Language')){
	            enumValues = enumMap.get('Language');
	            if (enumValues.containsKey(language))
	            	language = enumValues.get(language);
            }        	
        }
                
        string gender = customer.getAttribute('Gender');
        if (transform && enumMap != null){
            if (enumMap.containsKey('Gender')){
	            enumValues = enumMap.get('Gender');
	            if (enumValues.containsKey(gender))
	            	gender = enumValues.get(gender);
            }
        }
        
        string villagePrimary = customer.getAttribute('VillagePrimary');
        if (transform && enumMap != null){
        	if (enumMap.containsKey('VillagePrimary')){
	            enumValues = enumMap.get('VillagePrimary');
	            if (enumValues.containsKey(villagePrimary))
	            	villagePrimary = enumValues.get(villagePrimary);
        	}        	
        }
        
        string source = customer.getAttribute('Source');
        
        string email = '';
        string customerId = '';
        string salesforceId = '';
        string phoneNumber = '';
        string barcode = '';
        string leadsourcetext = '';
        string title = '';
        string given = '';
        string family = '';
        string addressLine = '';
        string county = '';
        string city = '';
        string postalCode = '';
        string country = '';
        string optoutEmail = '';
        string optoutMobile = '';
        string optoutPostal = '';
		
        TG_XmlNode properties = root.getElementByTagName('Properties');     
        list<TG_XmlNode> propertyItems = properties.getElementsByTagName('item');
        for (TG_XmlNode node :propertyItems){            
            string nodeType = node.getAttribute('type');
            allPropertiesMap.put(nodeType, node.nodeValue);
            if (nodeType == 'PHONENUMBER'){
                phoneNumber = node.nodeValue;
            }
            if (nodeType == 'LEADSOURCE'){
                leadsourcetext = node.nodeValue;
            }
            if (nodeType == 'OPTOUTEMAIL'){
                optoutEmail = node.nodeValue;
            }
            if (nodeType == 'OPTOUTMOBILE'){
                optoutMobile = node.nodeValue;
            }
            if (nodeType == 'OPTOUTPOSTAL'){
                optoutPostal = node.nodeValue;
            }            
        }

        TG_XmlNode references = root.getElementByTagName('References');     
        list<TG_XmlNode> referenceItems = references.getElementsByTagName('item');
        for (TG_XmlNode node :referenceItems){
            string nodeType = node.getAttribute('type');
            allReferencesMap.put(nodeType, node.nodeValue);
            if (nodeType == 'EMAIL'){
                email = node.nodeValue;
            }
            if (nodeType == 'CUSTOMERID'){
                customerId = node.nodeValue;
            }
            if (nodeType == 'SALESFORCEID'){
                salesforceId = node.nodeValue;
            }
            if (nodeType == 'BARCODENUMBER'){
                barcode = node.nodeValue;
            }
        }
system.debug(' @@@ referenceItems ... ' + referenceItems);        
system.debug(' @@@ SALESFORCE ID ... ' + salesforceId);
        
        TG_XmlNode name = root.getElementByTagName('name');
        title = name.getAttribute('Title');
        given = name.getAttribute('Given');
        family = name.getAttribute('Family');
        
        TG_XmlNode address = root.getElementByTagName('address');
        addressLine = address.getAttribute('AddressLine1') + ', ' + address.getAttribute('AddressLine2');
        county = address.getAttribute('County');
        city = address.getAttribute('City');
        postalCode = address.getAttribute('PostCode');
        
        country = address.getAttribute('Country');      
        if (transform && enumMap != null){
        	if (enumMap.containsKey('Country')){
	            enumValues = enumMap.get('Country');
	            if (enumValues.containsKey(country))
	            	country = enumValues.get(country);
        	}        	
        }        
        
        returnMap.put('CustomerGuId', customerGuid);
        returnMap.put('VersionId', versionId);
        returnMap.put('DateOfBirth', dateOfBirth);
        returnMap.put('Language', language);
        returnMap.put('Gender', gender);
        returnMap.put('VillagePrimary', villagePrimary);
        returnMap.put('Source', source);
        returnMap.put('PHONENUMBER', phoneNumber);
        returnMap.put('BARCODENUMBER', barcode);
        returnMap.put('LEADSOURCE', leadsourcetext);
        returnMap.put('OPTOUTEMAIL', optoutEmail);
        returnMap.put('OPTOUTMOBILE', optoutMobile);
        returnMap.put('OPTOUTPOSTAL', optoutPostal);
        returnMap.put('SALESFORCEID', salesforceId);
//        returnMap.put('CUSTOMERID', customerId);            
        returnMap.put('EMAIL', email); 
        returnMap.put('Title', title);
        returnMap.put('Given', given);
        returnMap.put('Family', family);
        returnMap.put('AddressLine', addressLine); //concatenation of AddressLine1 and AddressLine2
        returnMap.put('County', county);
        returnMap.put('City', city);
        returnMap.put('PostCode', postalCode);
        returnMap.put('Country', country);
        returnMap.put('CountryOfResidence' , country);  
        
system.debug (' @@@@@   VALUES RETURNED AND MAPPED ..  ' + returnMap);      
                
        return returnMap;
        
    }
    
    //method to map apiCustomer class object attributes with PersonAccount field names
    private static map<string, string> customerToPersonAccount(){
            
        map<string, string> returnMap = new map<string, string>();

        returnMap.put('CustomerGuId', 'Customer_GUID__c');
        returnMap.put('VersionId', 'Version_GUID__c');
        returnMap.put('DateOfBirth', 'PersonBirthdate');
        returnMap.put('Language', 'Preferred_Language__c');
        returnMap.put('Gender', 'Gender__c');
        returnMap.put('VillagePrimary', 'Primary_Village__c');
        returnMap.put('Source', 'PersonLeadSource');
        returnMap.put('PHONENUMBER', 'PersonMobilePhone');
        returnmAP.put('BARCODENUMBER', 'BarcodeNumber__c');
        returnMap.put('LEADSOURCE', 'Lead_Source_Text__c');
        returnmAP.put('SALESFORCEID', 'Integration_Salesforce_Id__c');
//        returnMap.put('CUSTOMERID', 'Customer_ID__c');          
        returnMap.put('EMAIL', 'PersonEmail'); 
        returnMap.put('Title', 'Salutation');
        returnMap.put('Given', 'FirstName');
        returnMap.put('Family', 'LastName');
        returnMap.put('AddressLine', 'PersonMailingStreet'); //concatenation of AddressLine1 and AddressLine2
        returnMap.put('County', 'PersonMailingState');
        returnMap.put('City', 'PersonMailingCity');
        returnMap.put('PostCode', 'PersonMailingPostalCode');
        returnMap.put('Country', 'PersonMailingCountry');   
        returnMap.put('CountryOfResidence', 'Country_of_Residence__c');
        
        return returnMap;
        
    }
    

    
    public static Account upsertCustomer (string xmlString, boolean newRecord, 
											string guid, map<string, map<string, string>> enumMap){
        
        Account returnAccount = null;
        string fldName = '';
        string fldValue = '';
        string fldType = '';
        
        try{
            
            map <string, string> fieldMap =  customerToPersonAccount();
            map<string, string> valueMap = getValuesFromXMLString(xmlString, true, enumMap);

SYSTEM.DEBUG('@@@  valueMap in upsertCustomer   ' + valueMap);
            
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Account');
            // Create Sobject of the correct type to perform DML transaction with
            Sobject obj;
            if (newRecord){
                obj = targetType.newSObject();
            } else {
                map<string, string> fldMap = customerToPersonAccount();
                string soql = '';
                for (string f :fldMap.values()){
                    soql += f + ',';
                }
                soql = soql + 'RecordTypeId ';
                soql = 'select ' + soql + ' from Account where Customer_GUID__c = :guid';
             
                obj = Database.query(soql);
            }
            Map<String, Schema.SObjectField> accountFields 
                        = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();          
            obj.put('RecordTypeId', customerRecordTypeID);

           

            for (string key :fieldMap.keySet()){

                fldName = fieldMap.get(key);
                fldValue = valueMap.get(key);
                                
                Schema.SObjectField fld = accountFields.get(fldName);
                
                schema.Describefieldresult dFld = fld.getDescribe();
                fldType = string.valueOf(dFld.getType());
                if (fldType == 'DOUBLE' || fldType == 'INTEGER'){
                    if (string.isnotBlank(fldValue)){
                        obj.put(fldName, fldValue);
                    } else {
                        obj.put(fldName, null);
                    }
                } else if (fldType == 'DATE' || fldType == 'DATETIME'){
                    if (string.isnotBlank(fldValue)){
                        date dt = date.valueOf(fldValue);
                        obj.put(fldName, dt);
                    } else {
                        obj.put(fldName, null);
                    }
                    
                } else {
                    obj.put(fldName, fldValue);
                }
                               
                
            }
            if (newRecord){
                insert obj;
            } else {
                update obj;
            }
            
            returnAccount = (Account)obj;
            
            
            
            
        } catch (exception e){
            returnAccount = null;
            string errMsg = 'ERROR ... Internal Technical Error ';
            if (string.isnotBlank(fldName)){
                errMsg = errMsg + ' Last field set .. ' + fldType + ' - ' + fldName + ' = ' + fldValue;
            }
            errMsg = errMsg +   e.getMessage() + ' : ' + e.getStackTraceString();
            if (ApexPages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
            }
            system.debug(errMsg);   
                        
        }
        
        return returnAccount;
        
        
    }
    
    private static string nullToEmptyString(string value){
        
        string returnVal = '';
        
        if (string.isBlank(value)){
            returnVal = '';
        } else {
            returnVal = value;
        }
        return returnVal;
        
    }
    
    private static string padZero(integer i){
        if (i < 10){
            return '0' + i;
        } else {
            return string.valueOf(i);
        }
    
    }    
}