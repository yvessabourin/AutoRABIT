global with sharing class VIPBBDeclineExtension {


    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public static String[] labelsonpage = new String[]{'OKButton', 'ThankyouTopHeader','ThankyouHeader','ThankYouContent','OKButton','DeclineContent','DeclineTopHeader','DeclineHeader','YesDeclineButton','NoDeclineButton','DeclineThankTopHeader','DeclineThankHeader','DeclineThankContent','ThankYouBelowContent'};
    public static String languagelabels {get;set;}
    public static String lang {get; set;}
     public String accId {get;set;}

    public VIPBBDeclineExtension(ApexPages.StandardController stdController) {
        lang = ApexPages.currentPage().getParameters().get('lang');
        languagelabels = getLanguageLabels(lang);
        accId = stdController.getId();
        getAccountInfo();
    }
    
    
    public Account accountRecordInfo ;
    public Account getaccountRecordInfo()
    {
        return accountRecordInfo;
    }
    public void setAccount(Account accountRecordInfo)
    {
        this.accountRecordInfo = accountRecordInfo;
    }
    
   
    
    @RemoteAction
    global static String deleteGuest(String accID){
        DeleteVIPGuest deleteguest = new DeleteVIPGuest((ID)accID);
        Account acc = [SELECT ID, Name FROM Account WHERE ID = :(ID)accID];
        try{
            System.debug('Aboun to call DeleteVIPGuestRecord');
            //deleteguest.DeleteVIPGuestRecord();
            String result = deleteguest.DeleteGuestAndCreateRecord(acc);
            return result;
          /*  if(result.startsWith('ERROR')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, result));
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,result));
            }*/
        }
        catch(Exception ex){
            System.debug('EXCEPTION!!!=====' + ex.getMessage());
        }
        return '';
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
    
       

    global void getAccountInfo(){
        System.debug('>>> accId'+accId);
        
        List<Account>  Accounts	= [Select ID,Country_of_Residence__c, Preferred_Language__c, Company_Name__c, Car_Registration__c, Private_Client_Notes__c, Guest_Source__c ,Private_Client_Team__c, Professional_Buyer__c,Village_Specific__c,Domestic_International_Partner__c,
                                   Personal_Shopper__c,Brand_Referral__c,Brand_Event__c,Marketing_Activity__c,Partner_Program_Membership_1__c,Guest_Source_Notes__c FROM Account WHERE ID = :accId];
        
        accountRecordInfo = accounts.isEmpty() ? new Account():Accounts[0];
        System.debug('>>> accId'+ accountRecordInfo);
    }
    
    global PageReference saveAccountInfo()
    {
        SYstem.debug('Account**************'+JSON.serialize(accountRecordInfo));
        update accountRecordInfo;
        return null;
    }
    
}