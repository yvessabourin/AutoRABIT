Global class getVillageLanguageURL{

    public Id caseId {get;set;}   
    public returnobject theURls {get {
        returnobject ret = new returnobject();
       
        case thecase = [select id,Village__r.name, Language_on_Registration__c from Case where id =:caseId ];
        list<Custom_Label__c> labels = [SELECT id, Name, Custom_Label_Value__c,Language__c FROM Custom_Label__c where
                                        (Name = 'VillagePrivacyNotice' OR Name = 'TermsConditions') AND Language__c =:thecase.Language_on_Registration__c ];
        system.debug('labels -- ' + labels);
        for(Custom_Label__c label : labels){
            if(label.name == 'VillagePrivacyNotice'){
                ret.theVillagePrivacyPolicy = label.Custom_Label_Value__c;
            }
            if (label.name == 'TermsConditions'){
                 ret.theVillageTermsandConditions = label.Custom_Label_Value__c;
            }

        }   
        
        string thequery = thecase.Village__r.name + '-' + thecase.Language_on_Registration__c;
        Village_Privacy_Policy_URLs__c villageURL = [SELECT id, Name,VillageLink__c,Village_Terms_and_Conditions__c FROM Village_Privacy_Policy_URLs__c WHERE name =: thequery LIMIT 1 ];
        ret.theVillageTermsandConditionsURL = villageURL.Village_Terms_and_Conditions__c;
        ret.theVillagePrivacyPolicyURL = villageURL.VillageLink__c;
        
        return ret;
                                       }  
    	set; }
    
    
      
    	global class returnobject{
            public string theVillageTermsandConditions {get;set;}
            public string theVillageTermsandConditionsURL {get;set;}
            public string theVillagePrivacyPolicy {get;set;}
            public string theVillagePrivacyPolicyURL {get;set;}
        
        
    	}
   
}