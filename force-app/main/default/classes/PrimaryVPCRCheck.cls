Global with sharing Class PrimaryVPCRCheck{   

public static void vpcrCheck(List<Village_Presence_Contact_Role__c> VPCRfromtrigger) {

            //Records coming from trigger have been filtered to Primary_Contact_Role__c = TRUE
            
            //Map to execute SOQL statement
            map<Id, Id> VPSet = new map<Id, Id>();
            
            //Map of (string,Village_Presence_Contact_Role__c) made up of a unique string of VP and Retail_Role eg. 'Barbour in BicesterRetail' 
            map<string, Village_Presence_Contact_Role__c> otherprimarystringmap  = new map<string, Village_Presence_Contact_Role__c>(); 
          
            //Add ids and VPids to map
            for (Village_Presence_Contact_Role__c vpcr : VPCRfromtrigger) {
            VPSet.put(vpcr.Id, vpcr.Village_presence__c);
            }
            
            //Only get the primaries from the VP, excludes trigger id's
            list<Village_Presence_Contact_Role__c> otherprimarylist = new list<Village_Presence_Contact_Role__c>
            ([select id, Village_Presence__c, Primary_Contact_Role__c,Retail_Role__c,Name FROM
             Village_Presence_Contact_Role__c WHERE village_presence__c in :VPSet.values() and Primary_Contact_Role__c = true 
             and id NOT IN:VPSet.keyset() ]);  
            
            //put string of VillagePresence+retail_role__c into Map for OTHER primary contacts at VP's
            for(Village_Presence_Contact_Role__c vpcr: otherprimarylist){
                   string vprole = vpcr.Village_Presence__c+vpcr.Retail_Role__c;
                   otherprimarystringmap.put(vprole, vpcr);
            }
    
    
        //compare trigger record string (village_presence+retail_role with same values in otherprimarymap
        for(Village_Presence_Contact_Role__c vpcr : VPCRfromtrigger ){
                 string vproles = vpcr.Village_Presence__c+vpcr.Retail_Role__c;
         if(!otherprimarystringmap.containsKey(vproles) && vpcr.UniqueKey__c != NULL){
         //reproduce uniquekey__c workflow field update that doesn't fire after the save operation
              otherprimarystringmap.put(vproles, vpcr);
              string uk = vpcr.UniqueKey__c;
              uk = uk.left(30);
              vpcr.UniqueKey__c = uk+vpcr.Retail_Role__c;
              }
              
              //to handle insert operation without creating second/seperate trigger variables 
              //and enable the UniqueKey__c field update 
             else if(!otherprimarystringmap.containsKey(vproles) && vpcr.UniqueKey__c == NULL){
              otherprimarystringmap.put(vproles, vpcr);
             
              }
              
                  
        else{
         vpcr.addError('This Village Presence already has a Primary '+vpcr.Retail_Role__c+
           ' Contact, please uncheck the Primary Contact Role on <a href=\'https://valueretail.my.salesforce.com/'+otherprimarystringmap.get(vproles).id +
            '\'  target="_blank">' + otherprimarystringmap.get(vproles).name + '</a> before saving this as the Primary '+vpcr.Retail_Role__c+
            ' Contact ',FALSE);
             }     
   }                                 
 }                              
}