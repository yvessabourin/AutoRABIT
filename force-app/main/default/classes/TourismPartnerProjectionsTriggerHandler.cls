public class TourismPartnerProjectionsTriggerHandler 
{
   
     public static void processBeforeInsert( Map<Id,Tourism_Partner_Projection__c> newRecords){


        // now we can update the name from the supplied values
        // we need to build the name as "Account" + for + "Year" + for "Village"
        // eg. Kuoni International for 2017 for Bicester

        // lets get all the data..
        List<ID> acc = new List<ID>();
        System.debug('newRecords ===== '+newRecords);
          for (string key :newRecords.keySet()){
            acc.add(newRecords.get(key).Partnership_Account__c);
          }
        

        Map<ID,Account> tppaccs = new Map<ID,Account>([Select ID, Name FROM Account WHERE ID in :acc]);

        for(Tourism_Partner_Projection__c TPP :newRecords.values()){
            System.debug(TPP.Projected_Year__c);
            Account TPPAccount = tppaccs.get(TPP.Partnership_Account__c);
            String TPPName = TPPAccount.Name + ' for ' + TPP.Projected_Year__c + ' for ' + TPP.Village__c;
            //TPP.Name = TPPName;
        }

     } 

   
}