//Actions for the lead page
//Daniel Childs & Ian Burton 06/04/2017
Public Class LeadActionsController {

    private ApexPages.StandardController standardController;
    public Boolean showbutton  { get; set; }
    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirect {public get; private set;}
    public Boolean showerror {public get; private set;}
    public String errormessage {public get; public set;}
    public String displayEmailError {get; set;}
    public String displayAccountRefError {public get; public set;}
    public String displayvillageError {get; set;}
    public String displayEmailCompanyError {get; set;}
    
    

       
    
    public LeadActionsController(ApexPages.StandardController standardController){ 
    //Initialise the variables and get lead data
        this.standardController = standardController;   
        showbutton = False;
        shouldRedirect = False;
        //system.debug('shouldredirect1 :'+shouldredirect);
        Id recordId = standardController.getId();
        Lead record = [SELECT id,Village_of_Visit_c__c, Account_Reference__c,Account_Reference_Number__c,Create_Group_Booking__c,Quick_Convert__c,Email, Secondary_Email_Address__c,Account_Reference__r.id,company,Account_Reference__r.Name,Account_Reference__r.Account_Reference_Number__c from LEAD WHERE id =:recordId];
        displayEmailError = LeadUtilities.displayEmailError(record);
        displayAccountRefError = LeadUtilities.displayAccountRefError(record);
        //Only display the button if there is an account reference set from process builder workflow
        showbutton = (LeadUtilities.canQuickConvert(record) && record.Quick_Convert__c);
        displayvillageError = LeadUtilities.displayvillageError(record);
        displayEmailCompanyError = LeadUtilities.displayEmailCompanyError(record);
        
    }
    
    public PageReference QuickConvert(){
            //button press action from visualforce page
            Id record2Id = standardController.getId();
            Lead record2 = [SELECT id, 
            Account_Reference__c,Account_Reference_Number__c,Quick_Convert__c,Create_Group_Booking__c,FirstName,LastName,email,Secondary_Email_Address__c,
            phone,Leadsource,company,Account_Reference__r.name,Name_of_Event__c,account_reference__r.ownerid,Account_Reference__r.id,Account_Reference__r.Account_Reference_Number__c,Village_of_Visit_c__c,Boutique_Private_Viewing__c,Group_Type__c
            ,Expected_Arrival__c,Expected_Departure__c,Number_of_Visitors__c,Visitors_Country_of_Origin__c,Region__c
            ,Transport_Required__c,Mode_of_Transport__c,Food_Beverage__c,Gift_Card__c,Gift__c,Welcome_Pack__c,VIP_Lounge_Access__c,Notes_and_Additional_Comments__c,
            Secondary_MICE_Org_or_Agency_name__c,Secondary_MICE_Contact_Country__c,Secondary_MICE_Contact_Title__c,Secondary_MICE_Contact_First_Name__c,Secondary_MICE_Contact_Last_Name__c
            ,Secondary_MICE_Contact_Position__c,Secondary_MICE_Contact_Address_1__c,Secondary_MICE_Contact_Address_2__c,Secondary_MICE_Contact_Address_3__c,Secondary_MICE_Contact_Town_City__c,Secondary_MICE_Contact_State__c
            ,Secondary_MICE_Contact_ZIP_Postcode__c,Secondary_MICE_Contact_Phone__c,Secondary_MICE_Contact_Email__c from LEAD WHERE id =:record2Id ];
            RecordType RecordTypeid = [Select id from RecordType WHERE name = 'Tourism Contact' AND sObjectType = 'Contact'];
            
            //system.debug('cancquickconvert :'+LeadUtilities.canQuickConvert(record2));
            //displayAccountRefError = LeadUtilities.displayAccountRefError(record2);
         
            IF(LeadUtilities.canQuickConvert(record2)){ 
            try{
            boolean wasQuickConverted = LeadUtilities.quickConvert(record2);           
                        
            //create leadconversion object     
            //check lead conversion result
            if(!wasQuickConverted){
               errormessage = 'Failed to convert lead';
               throw new leadconvertException('Cannot convert lead');
            } 
            shouldRedirect = true;
            //system.debug('shouldredirect1.1 :'+shouldredirect);
            redirectUrl = standardController.view().getUrl();
            return null;
           }
            catch (DMLException e){
            if(e.getDmlType(0) == system.StatusCode.DUPLICATE_VALUE){
                errormessage = 'Duplicate value found, please check the data';
            }
             
            if(e.getDmlType(0) == system.StatusCode.REQUIRED_FIELD_MISSING){
                errormessage = 'A required field is missing, please check the data';
            }  
            
            if(e.getDmlType(0) == system.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                errormessage = 'At least one of Mobile, Phone or Email address must be entered before you can save the record';
            } 
            
            shouldredirect = false;
            //system.debug('shouldredirect2 :'+shouldredirect);
            showerror = true;
            return null;
            
            
            
        }
        catch (exception e){
            shouldredirect = false;
            errormessage = 'Please check the data';
            //system.debug('shouldredirect3 :'+shouldredirect);
            showerror = true;
            return null;
              
        }
            
            }
           
            else{
            errormessage = 'Cannot Quick convert, please check Company Name matches Account Reference Name';
            shouldredirect = false;
            //system.debug('shouldredirect4 :'+shouldredirect);
            showerror = true;
            return NUll;   
            }
    
        
            
        }
        public class leadconvertException extends Exception {}

}