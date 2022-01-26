global with sharing class VIPBBTermsExtension {

	private final sObject mysObject;
    private Account a;
    public static String[] labelsonpage = new String[]{'DeclineButton', 'TermsDetails', 'IAgreeButton', 'TermsHeading','VIPTermsTopHeading','TermsCloseButton','TermsPopupHeading','VIPTermsTopHeading','TermsContent1','TermsContent2','TermsPopupLinkText','TermsHeading'};
    public static String languagelabels {get;set;}
    public static String lang {get; set;}
    public String guestJson {get;set;}
    public String villageTermsURL {get; set;}

    Public VIPBBTermsExtension(Apexpages.standardController stdController){
        a = (Account) stdController.getRecord();

        guestJson = JSON.serializePretty(a);
        lang = ApexPages.currentPage().getParameters().get('lang');
        languagelabels = getLanguageLabels(lang);

        User usr = [Select ID, Name,Village__c FROM User WHERE ID = :UserInfo.getUserId() ];

        // get users village
        String userVillage = usr.Village__c;
        // compare
        if(userVillage == 'Bicester'){
            villageTermsURL = 'https://www.bicestervillage.com/';
        }
        if(userVillage == 'Fidenza'){
            villageTermsURL = 'https://www.fidenzavillage.com/';
        }
        if(userVillage == 'Ingolstadt'){
            villageTermsURL = 'https://www.ingolstadtvillage.com/';
        }
        if(userVillage == 'Kildare'){
            villageTermsURL = 'https://www.kildarevillage.com/';
        }
        if(userVillage == 'La Roca'){
            villageTermsURL = 'https://www.larocavillage.com/';
        }
        if(userVillage == 'Las Rozas'){
            villageTermsURL = 'https://www.lasrozasvillage.com/';
        }
        if(userVillage == 'La Vallée'){
            villageTermsURL = 'https://www.lavalleevillage.com/';
        }
        if(userVillage == 'Maasmechelen'){
            villageTermsURL = 'https://www.maasmechelenvillage.com/';
        }
        if(userVillage == 'Shanghai'){
            villageTermsURL = 'https://www.bicestervillage.com/';
        }
        if(userVillage == 'Suzhou'){
            villageTermsURL = 'https://www.bicestervillage.com/';
        }
        if(userVillage == 'Wertheim'){
            villageTermsURL = 'https://www.wertheimvillage.com/';
        }
    }

    @RemoteAction
    global static String saveConsentTerms(String accID){

        // update Permission_to_hold_data__c 
        // and Date_Permission_given__c
        try{
            Account acc = [Select ID,Permission_to_hold_data__c, Date_Permission_given__c FROM Account WHERE ID = :accID];

            acc.Permission_to_hold_data__c = true;
            acc.Consent_Process_Data__c='In Village';
            acc.Date_Permission_given__c = Datetime.now();

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