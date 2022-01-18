// Utilitiy class for ad hoc calls to the GetLeaseList Microservice
// Can be invoked from Developer console, column selections should remain
// unchanged, but where clause can be modified as required
// Example:

/* string q = 'select Id, Name, Brand__r.Id, Brand__r.Name, Status__c, Village__r.Village_Code__c from Village_Presence__c ';
q += 'where Village__c in (select Id from Village__c where Name = \'La Roca\')';
q += 'order by Name';

Database.executeBatch(new generateLeaseIdExtract(q), 90);
*/

global class GenerateLeaseIdExtract implements Database.Batchable<sObject>, Database.AllowsCallouts {
  
    global final String query;
     
     
    //constructor
    global generateLeaseIdExtract (String q) {
        query = q;   
    }
     
    //start
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
     
     
    //execute
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        string output = '';
        
        for (Sobject obj :scope){
        
            string status = string.valueOf(obj.get('Status__c'));
            string brandId = string.valueOf(obj.getSobject('Brand__r').get('Id'));
            string brand = string.valueOf(obj.getSobject('Brand__r').get('Name'));
            string vpId = string.valueOf(obj.get('Id'));
            string vpName = string.valueOf(obj.get('Name'));
            string villageCode = string.valueOf(obj.getSobject('Village__r').get('Village_Code__c'));
            string leaseId = '';
            string error = '';
            
            if (test.isRunningTest())
                    brandId = 'SF_TEST';
            
            string xmlLease = apiService.readLeaseList(brandId, villageCode, system.today());
            if (xmlLease.indexOf('Error') > -1){
                error = xmlLease;
            } else {
                list<apiLease.cls_LeaseItem> leaseList = apiLease.parseXML(xmlLease);
                if (leaseList.size() == 1){
                    leaseId = leaseList[0].leaseId;
                } else {
                    for (apiLease.cls_LeaseItem lease :leaseList){
                        leaseId += lease.leaseId + ',';
                    }
                }   
            
            }    
            output += brand + ',' + brandId + ',' + vpId + ',' + vpName + ',' + status + ',' + leaseId + ',' + error + '\r\n';        
            
        
        }

        system.debug(output);
    }
  
  
    //finish
    global void finish(Database.BatchableContext BC) {
    }
    
}