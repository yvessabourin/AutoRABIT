public with sharing class AccountUtilities {
    
    public static void mergeTourismAccounts(){

        map<Id, Account> accountMap = new map<Id, Account>([select Id, Name, Duplicate_of_Account__c, Duplicate_of_Account__r.Name
                                                                    from Account where Duplicate_of_Account__c != null]);       
        
        list<string> masterAccountIds = new list<string>();

        for (Account a :accountMap.values()){
            masterAccountIds.add(a.Duplicate_of_Account__c);                    
        }
        
        map<Id, Account> masterAccountMap= new map<Id, Account>([select Id, Name from Account where Id in:masterAccountIds]);
        
        for (Account a :accountMap.values()){
            Account master = masterAccountMap.get(a.Duplicate_of_Account__c);
            
            try {
                merge master a;
            } catch (DmlException  e){
                // Process exception
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                
            }       
        }
    
    }
    
}