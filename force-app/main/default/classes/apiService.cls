/*
    Interface utiltiy class.
    
    Created : 28/05/2015
    Author: Constantine Chimonides
    
    Modification History:
*/

public with sharing class apiService {

    // Extract interface definition parameters from Custom Setting object
    private static final string apiKey = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('API_Key__c')));
    private static final string apiHost = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('API_Host__c')));
    private static final string customerRead = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Customer_Read__c')));
    private static final string customerReadGuid = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Customer_Read_GUID__c')));
    private static final string customerCreate = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Customer_Create__c')));
    private static final string preferenceCreateDelete = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Preference_Create__c')));
    private static final string preferenceRead = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Preference_Read__c')));
    private static final string enumRead = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Enum_Read__c')));
    private static final string lookupRead = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Lookup_Read__c')));
    private static final string emailChange = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Email_Change__c')));
    private static final string customerDelete = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Customer_Delete__c')));
    private static final string readOnlyURL = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Customer_Overview__c')));
    private static final string leaseList = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Lease_List__c')));           
    
    // debug mode will write request and response messages to the system log
    private static final boolean debugMode = boolean.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Debug_Mode__c'));
    
    private static integer retryCount = 0; //keep track of attempts and stop after 3 retries 
        
    
    //Public method to read an enumerator list. 
    //Inputs: typeName description (such as Villages, Countries, Languages)
    //Returns: JSON string representing enumerator object definition
/*
    public static string readEnum(string typeName){

        string returnString = doGet(enumRead + '/' + typeName);
        if (returnString.contains('ERROR')){
            returnString = '';
        } else {
            // Remove unnecessary JSON header items from response message to match
            // enumerator object definition
            returnString = returnString.replace('"Navigation":{"@Type":"list",', '');
            returnString = returnString.substring(0,returnString.length()-1);       
            returnString = returnString.replace('"Navigation":{"@Type":"Results",', '');
            returnString = returnString.substring(0,returnString.length()-1);
            
            // replace JSON item preix items from repsonse message to match
            // enumerator object definition 
            returnString = returnString.replace('@', 'x_');
            returnString = returnString.replace('#', 'y_');
        }
        
        return returnString;
        
    }
*/
    
    // Public method to retrieve Lookup from Customer API
    // Inputs: typeName description (such as Genders, Countries, Languages)
    // Returns: XML string representing lookup values
    public static string readLookup(string typeName){
		
        string returnString = doGet(lookupRead + '/' + typeName, true);
		
        return returnString;
    }

    // Public method to retrieve Customer using GUID
    // Inputs: GUID to search for
    // Returns: XML string representing the customer found
    public static string readByGUID(string guid){
        
        string returnString = doGet(customerReadGUID + '/' + guid, true);
        
        return returnString;
    }    
    
    public static string getLevelandStars(string guid){
    string jsonContent = readReadOnlyItem(guid);      
    return jsonContent  ;
    }

    // Public method to retrieve Customer Preferences using GUID
    // Inputs: GUID to search for
    // Returns: XML string representing the customer preferences found
    public static string readPreferences(string guid){
        
        string returnString = doGet(preferenceRead + '/' + guid, true);
        
        return returnString;
    } 
    
    // Public method to retrieve Customer Read Only item using GUID
    // Inputs: Customer GUID to return items for, url fo read only item derived from Custom Setting
    // Returns: XML string representing the items found
    public static string readReadOnlyItem(string guid){     
        
        string returnString = doGet(readOnlyURL + '/' + guid, true);
        
        return returnString;        
    }
        
    //Public method to create a new customer. 
    //Inputs: JSON/XML string representing Customer object definition)
    //Returns: HTTP Response message status
    public static string postNewCustomer(string customer){
        
        string returnString = doPost(customerCreate , customer);
        
        return returnString;
        
    }

    //Public method to create a new customer. 
    //Inputs: JSON/XML string representing Preference object definition)
    //Returns: HTTP Response message status
    public static string postPreference(string preference){
        
        string returnString = doPost(preferenceCreateDelete , preference);
        
        return returnString;
        
    }


    // Public method to retrieve List of Leases for a given Brand/Village/Date
    // Inputs: BrandId|VillageCode|Date
    // Returns: XML string representing the leases found
    public static string readLeaseList(string brandId, string villageCode, date theDate){
        
        if(theDate == null){
            theDate = system.today();
        }
        string dateString = string.valueOfGmt(theDate);
        dateString = dateString.split(' ')[0].replace('-', '');
        
        
        string returnString = doGet(leaseList + '/' + brandId + '|' + villageCode + '|' + dateString, false);
        
        return returnString;
    }     
    
    public static string postEmailChange(string oldEmail, string newEmail, string guid){
        
        string request = 'oldEmail=' + EncodingUtil.urlEncode(oldEmail, 'UTF-8');
        request += '&newEmail=' + EncodingUtil.urlEncode(newEmail, 'UTF-8');
        
        string returnString = doFormPost(emailChange + '/' + guid, request);
        
        return returnString;
        
    }
    
    public static string deletePreference(string preference){
        
        string returnString = doDelete(preferenceCreateDelete, preference);
        
        return returnString;
        
    }

    public static string deleteCustomer(string guid){
        
        string returnString = doDelete(customerDelete +'/' + guid, '');
        
        return returnString;
        
    }
        
    //Public method to update customer. 
    //Inputs: JSON/XML string representing Customer object definition)
    //Returns: HTTP Response message status
    public static string updateCustomer(string customer){
        
        string returnString = doPut(customerCreate , customer);
        
        return returnString;
        
    }
    // Method used for all http GET requests.
    // Inputs: Interface service URL end point (excluding host prefix), retry indicator whether call should be retried
    // in the event of a failure
    // Returns: JSON/XML Response string or HTTP Response message status (if error)
    private static string doGet(string endPoint, boolean retry){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string responseString = '';
        
        try{
            
            string apiUrl = apiHost + endPoint; //+ '?subscription-key=' + apiKey;

            req.setEndPoint (apiUrl);
            req.setMethod('GET');
            req.setTimeout(5000); //5 seconds
                req.setHeader('Accept', 'application/xml');
            req.setHeader('Ocp-Apim-Subscription-Key', apiKey);
            res = h.send(req);
            
            responseString = res.getBody();
            integer httpStatus = res.getStatusCode();
            
            if (debugMode){
                debugApiCall(req, res);
            }
            
            if (httpStatus != 200){             
                responseString = 'ERROR Returned : HTTP Status Code ' + httpStatus + ', ';
                responseString += ' HTTP Error ' + res.getStatus() + ', ';
                responseString += 'Details returned ' + res.getBody(); 
                retryCount++;
                if (retry){
                    if (retryCount < 3){ //try again upto 3 times
                        system.debug( ' Current Retry Count is : ' + retryCount + ' Attempting retry of : ' + endPoint);
                        responseString = doGet(endPoint, true);
                    } else {
                        retryCount = 0;
                    }
                }    
            } else {
                responseString = res.getBody();
                retryCount = 0;
            }
            
            
        } catch (exception e){
            
            if (retryCount < 3){ //try again upto 3 times
                system.debug( ' Current Retry Count is : ' + retryCount + ' Attempting retry of : ' + endPoint);
                retryCount++;
                responseString = doGet(endPoint, retry);
            } else if (retryCount > 2){
                responseString = 'ERROR ... Internal Technical Error ' + e.getMessage();
                system.debug('ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString());             
            } else {
                retryCount = 0;
            }                                                               
        }
        
        return responseString;          
    }
    
    // Method used for all http POST requests.
    // Inputs: Interface service URL end point (excluding host prefix)
    // Returns: HTTP Response message status
    private static string doPost (string endPoint, string postBody){

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string responseString = '';
                
        try{

            string apiUrl = apiHost + endPoint; // + '?subscription-key=' + apiKey;
            
            req.setHeader('Content-type', 'application/xml');
            req.setHeader('Ocp-Apim-Subscription-Key', apiKey);
            req.setBody(postBody);
            req.setEndPoint (apiUrl);
            req.setMethod('POST');

            if (debugMode){
                system.debug('**** About to send Request Message to : ' + apiUrl);
                system.debug('BODY ... ' + postBody);
                system.debug('**** Request Debug End ****');
            }
                        
            res = h.send(req);

            if (debugMode){
                debugApiCall(req, res);
            }
                        
            responseString = res.getBody();
            integer httpStatus = res.getStatusCode();
            
            if (httpStatus != 200){             
                responseString = 'ERROR Returned : HTTP Status Code ' + httpStatus +', ';
                responseString += ' HTTP Error ' + res.getStatus() +', ';
                responseString += 'Details returned ' + res.getBody(); 
            } else {
                responseString = res.getBody();
            }           
            
            
        } catch (exception e){
            
            // To do... log into custom object (IW)
            responseString = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(responseString);               
        }
        
        return responseString;
    }

    // Method used for all http Form POST requests.
    // Inputs: Interface service URL end point (excluding host prefix), post body string
    // Returns: HTTP Response message status
    private static string doFormPost (string endPoint, string postBody){

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string responseString = '';
                
        try{

            string apiUrl = apiHost + endPoint; // + '?subscription-key=' + apiKey;
            
            req.setHeader('Content-type', 'application/x-www-form-urlencoded');
            req.setHeader('Ocp-Apim-Subscription-Key', apiKey);
            req.setBody(postBody);
            req.setEndPoint (apiUrl);
            req.setMethod('POST');

            if (debugMode){
                system.debug('**** About to send Request Message to : ' + apiUrl);
                system.debug('BODY ... ' + postBody);
                system.debug('**** Request Debug End ****');
            }
                        
            res = h.send(req);

            if (debugMode){
                debugApiCall(req, res);
            }
                        
            responseString = res.getBody();
            integer httpStatus = res.getStatusCode();
            
            if (httpStatus != 200){             
                responseString = 'ERROR Returned : HTTP Status Code ' + httpStatus +', ';
                responseString += ' HTTP Error ' + res.getStatus() +', ';
                responseString += 'Details returned ' + res.getBody(); 
            } else {
                responseString = res.getBody();
            }           
            
            if (string.isBlank(responseString)){
                responseString = 'OK';
            }
            
        } catch (exception e){
            
            // To do... log into custom object (IW)
            responseString = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(responseString);               
        }
        
        return responseString;
    }
    
    // Method used for all http PUT requests.
    // Inputs: Interface service URL end point (excluding host prefix)
    // Returns: HTTP Response message status
    private static string doPut (string endPoint, string putBody){

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string responseString = '';
                
        try{

            string apiUrl = apiHost + endPoint; // + '?subscription-key=' + apiKey;
            
            req.setHeader('Content-type', 'application/xml');
            req.setHeader('Ocp-Apim-Subscription-Key', apiKey);
            req.setBody(putBody);
            req.setEndPoint (apiUrl);
            req.setMethod('PUT');
            
            res = h.send(req);

            if (debugMode){
                debugApiCall(req, res);
            }
                        
            responseString = res.getBody();
            integer httpStatus = res.getStatusCode();
            
            if (httpStatus != 200){             
                responseString = 'ERROR Returned : HTTP Status Code ' + httpStatus +', ';
                responseString += ' HTTP Error ' + res.getStatus() +', ';
                responseString += 'Details returned ' + res.getBody(); 
            } else {
                responseString = res.getBody();
            }           
            
            
        } catch (exception e){
            
            // To do... log into custom object (IW)
            responseString = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(responseString);               
        }
        
        return responseString;
    }

    // Method used for all http DELETE requests.
    // Inputs: Interface service URL end point (excluding host prefix)
    // Returns: HTTP Response message status
    private static string doDelete (string endPoint, string deleteParams){

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string responseString = '';
                
        try{

            string apiUrl = apiHost + endPoint + deleteParams; // + '?subscription-key=' + apiKey;
            
            req.setHeader('Content-type', 'application/xml');
            req.setHeader('Ocp-Apim-Subscription-Key', apiKey);
            req.setEndPoint (apiUrl);
            req.setMethod('DELETE');
            
            res = h.send(req);

            if (debugMode){
                debugApiCall(req, res);
            }
                        
            responseString = res.getBody();
            integer httpStatus = res.getStatusCode();
            
            if (httpStatus != 200){             
                responseString = 'ERROR Returned : HTTP Status Code ' + httpStatus +', ';
                responseString += ' HTTP Error ' + res.getStatus() +', ';
                responseString += 'Details returned ' + res.getBody(); 
            } else {
                responseString = 'OK';
            }           
            
            
        } catch (exception e){
            
            // To do... log into custom object (IW)
            responseString = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
            system.debug(responseString);               
        }
        
        return responseString;
    }
        
    private static void debugApiCall(HttpRequest req, HttpResponse res){
                
        system.debug (' **************    Debug Output Follows ***************');
        
        system.debug(req.getBody());

        //get the list of header names (keys)
        List<string> headerkeys = res.getHeaderKeys();
          
        //create an object to store header key-value pairs
         map<string, string> headers = new map<string, string>();
         
        //iterate through they keys, and populate map
        for(string s : headerkeys){
            if (s != null){
                headers.put(s,res.getHeader(s));
            
                system.debug('header: ' + s + ' value: ' + res.getHeader(s));
            }
        }
        system.debug(res.getBody());        
        
        system.debug (' **************    Debug Output END ***************');           
        
        
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
    
}