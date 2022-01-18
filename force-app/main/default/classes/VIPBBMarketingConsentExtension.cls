global with sharing class VIPBBMarketingConsentExtension {

	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    private Account a;
    public static String[] labelsonpage = new String[]{'DeclineButton', 'SaveNextButton', 'Email', 'MarketingHeading','VIPMarketingTopHeading','MarketingContent','PostLabel','Addresslabel', 'StreetLabel', 'CityLabel', 'PostCodeLabel','CountryLabel','PhoneLabel','Tel'};
    public static String languagelabels {get;set;}
    public static String lang {get; set;}
    public String guestJson {get;set;}

    Public VIPBBMarketingConsentExtension(Apexpages.standardController stdController){
        a = (Account) stdController.getRecord();

        guestJson = JSON.serializePretty(a);
        lang = ApexPages.currentPage().getParameters().get('lang');
        languagelabels = getLanguageLabels(lang);
    }


    @RemoteAction
    global static String saveMarketingConsent(String accID, String email, String phone, String postStreet,String postCity,String postPostalCode,String postCountry , String boolemail, String boolphone, String boolpost){
       
/*
        PersonMailingStreet 
        PersonMailingCity   
        PersonMailingPostalCode 
        PersonMailingCountry    
 
*/

        try{

            Account acc = [Select ID,FirstName, LastName, PersonEmail, PersonMobilePhone FROM Account WHERE ID = :accID];
            if(boolemail == 'true'){
                acc.Marketing_Consent_Email__c = true;
                acc.Vip_Marketing_Consent_Email__c='In Village';
                acc.PersonEmail = email;
                acc.Marketing_Consent_Email_Date__c = DateTime.now();
            }
            else if(boolemail == 'false' || boolemail == '' )
            {
                acc.Marketing_Consent_Email__c = false;
                acc.Vip_Marketing_Consent_Email__c='';
                acc.Marketing_Consent_Email_Date__c = DateTime.now();
            }

            if(boolphone == 'true'){
                acc.Marketing_Consent_Phone__c = true;
                acc.Vip_Marketing_Consent_Phone__c='In Village';
                acc.PersonMobilePhone = phone;
                acc.Marketing_Consent_Phone_Date__c = DateTime.now();
            }
            else if(boolphone == 'false' || boolphone == ''){
                acc.Marketing_Consent_Phone__c = false;
                acc.Vip_Marketing_Consent_Phone__c='';
                acc.Marketing_Consent_Phone_Date__c = DateTime.now();
            }
            if(boolpost == 'true'){
                acc.Marketing_Consent_Post__c = true;
                acc.Vip_Marketing_Consent_Post__c='In Village';
                acc.PersonMailingStreet = postStreet;
                acc.PersonMailingCity = postCity;
                acc.PersonMailingPostalCode = postPostalCode;
                acc.PersonMailingCountry = postCountry;
                acc.Marketing_Consent_Post_Date__c = DateTime.now();
            }
            else if(boolpost == 'false' || boolpost == ''){
                acc.Marketing_Consent_Post__c = false;
                acc.Vip_Marketing_Consent_Post__c='';
                acc.Marketing_Consent_Post_Date__c = DateTime.now();
            }

            update acc;
            return 'SAVEDID' + accID;
            
        }
        catch(Exception ex){
            return 'ERROR ' + ex.getMessage();
        }
    }


    @RemoteAction
    global static string getLanguageLabels(String lang){
        // gets the labels for this page, for display by angular
        List<Custom_Label__c> custlabels = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c WHERE Language__c = :Lang AND Name IN :labelsonpage ];
        List<LabelValue> lblvals = new List<LabelValue>();
        for(Custom_Label__c cl :custlabels){
            LabelValue lval = new LabelValue();
            lval.LabelName = cl.Name;
            Lval.LabelValue = cl.Custom_Label_Value__c;
            lblvals.add(lval);
        }

        return JSON.serializePretty(lblvals);
    }

     private class LabelValue{
        String LabelName {get; set;}
        String LabelValue {get; set;}
     }
}