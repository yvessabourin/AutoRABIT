public with sharing class DealBusinessUtilities {
    
    // variable to contain Deal Business history specific fields 
    // (with no equivalent field on the parent deal that should be copied)
    private static map<string, string> historyFieldsOnly = new map<string, string>
                                                                    {'Approved_By__c' => 'Approved_By__c', 
                                                                    'Review_Comment__c' => 'Review_Comment__c',
                                                                    'Approved_Date__c' => 'Approved_Date__c',
                                                                    'Deal__c' => 'Deal__c',
                                                                    'Approval_Decision__c' => 'Approval_Decision__c'};
    
    public DealBusinessUtilities(){
        
        
    }
    
    
    public static void recordApproval(set<Id> historyIdList){
                
        try {       
            list<string> dealIdList = new list<string>();
            // retrieve the history records from the id's provided
            list<Deal_Business_History__c> historyList = [select Id, Deal__c from Deal_Business_History__c 
                                                            where Id in:historyIdList ];
            
            // extract parent Deal Ids
            for (Deal_Business_History__c h :historyList){
                dealIdList.add(h.Deal__c);  
            }
            
            // call method to retrieve the deal field values to be copied
            map<Id, Opportunity> oppMap = retrieveDealValues(dealIdList);
    
            // extract the deal business history fields which should be written to
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();        
    
            string query = 'select Id, CurrencyIsoCode,';
            
            Map <String, Schema.SObjectField> fieldMap = gd.get('Deal_Business_History__c').getDescribe().fields.getMap();
            for (Schema.SobjectField fld :fieldMap.values()){
                schema.describefieldresult dfield = fld.getDescribe();
                if (dfield.isCustom()){
                    string fldName = string.valueOf(dField.getName());                          
                    query = query + fldName + ',';
                }
            }
            query = query.subString(0,query.length() - 1);
            query = query + ' from ';
            query = query + ' Deal_Business_History__c';
            query = query + ' where Id in :historyIdList';      
            
            // extract the deal business history records to update
            map<Id, Deal_Business_History__c> historyMap = new map<Id, Deal_Business_History__c>((List<Deal_Business_History__c>)Database.query(query));
            
            // loop throuigh list of deal history records
            for (Deal_Business_History__c h :historyMap.values()){
                string dealId = h.Deal__c;
                // retrieve parent deal values from map populated earlier
                Opportunity opp = oppMap.get(dealId);
                for (Schema.SobjectField fld :fieldMap.values()){
                    schema.describefieldresult dfield = fld.getDescribe();
                    string fldName = string.valueOf(dField.getName());
                    // update deal history field values according to deal values and field type
                    if (dfield.isCustom() && historyFieldsOnly.containsKey(fldName) == false || (dfield.Name == 'CurrencyIsoCode')){
                        string fldType = string.valueOf(dfield.getType());                                          
                        if (fldType == 'Boolean'){
                            h.put(fldName, boolean.valueOf(opp.get(fldName)));
                        }
                         else if (fldType == 'Double' || fldType == 'Currency'){
                            h.put(fldName, double.valueOf(opp.get(fldName)));                           
                        } else  {                           
                            h.put(fldName, string.valueOf(opp.get(fldName)));               
                        }
                    }
                }
                // update parent deal with Approved date/time from history record
                opp.Approved_Date__c = h.Approved_Date__c;        
            }
            // perform dml update
            update historyMap.values();
            update oppMap.values();
        
        } catch (exception e){
            system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());           
        }
    }
    
    // retrieve equivalent field values from parent deal record
    private static map<Id, Opportunity> retrieveDealValues(list<string> dealIdList){

    
        // Retrieve list of fields from object meta data (api names should match deal field names)      
        // generate a map of tokens for the sObjects in organization
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();        

        string query = 'select Id, Approved_Date__c, CurrencyIsoCode, ';
        
        Map <String, Schema.SObjectField> fieldMap = gd.get('Deal_Business_History__c').getDescribe().fields.getMap();
        for (Schema.SobjectField fld :fieldMap.values()){
            schema.describefieldresult dfield = fld.getDescribe();
            if (dfield.isCustom()){
                // only query fields which are also on the Deal object
                string fldName = string.valueOf(dField.getName());                          
                if (historyFieldsOnly.containsKey(fldName) == false){
                    query = query + fldName + ',';
                }
            }
        }
        query = query.subString(0,query.length() - 1);
        query = query + ' from ';
        query = query + ' Opportunity';
        query = query + ' where Id in :dealIdList';

        system.debug('Build Query == ' + query);

        map<Id, Opportunity> oppMap = new map<Id, Opportunity>((List<Opportunity>)Database.query(query));
        
        return oppMap;
        
    }

}