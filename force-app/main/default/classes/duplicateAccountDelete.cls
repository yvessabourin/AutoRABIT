Public Class duplicateAccountDelete{

     public List<Account> acts {get;set;}
     public Integer actCount {get;set;}
     public Boolean shouldRedirect {get; set;}
     
         public duplicateAccountDelete(){
         
         acts = [Select id,Duplicate_of_Account__c,Name,Duplicate_of_Account__r.Name FROM Account WHERE Duplicate_of_Account__c != NULL];
         actCount = acts.size();
         shouldRedirect = False;
        
         }


    Public pagereference deleteaccounts(){
    
               map<Id, Account> accountMap = new map<Id, Account>([select Id, Name, Duplicate_of_Account__c, Duplicate_of_Account__r.Name
                                                                           from Account where Duplicate_of_Account__c != null
                                                                           LIMIT 149]);      
                
               list<string> masterAccountIds = new list<string>();
         
               for (Account a :accountMap.values()){
                   masterAccountIds.add(a.Duplicate_of_Account__c);                   
               }
                
               map<Id, Account> masterAccountMap= new map<Id, Account>([select Id, Name from Account where Id in:masterAccountIds]);
                
               for (Account a :accountMap.values()){
                   Account master = masterAccountMap.get(a.Duplicate_of_Account__c);
                    
                   try {
                       system.debug('about to merge (delete) ' + a.id );
                       system.debug(' into ' + master.id);
                       merge master a;
                       shouldRedirect = True;
                   } catch (DmlException  e){
                       // Process exception
                       System.debug('An unexpected error has occurred: ' + e.getMessage());
                        
                   }      
               }
               return null;
    }           
}