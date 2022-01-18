global class reassignToQueueOwner {
    
@InvocableMethod
public static void reassignOwner(list<leadDetails> details)  {  

     String Queue = ' Lead Queue - ';
        
     LIST<Group> Grp = [Select Id,Name from Group where type='Queue' and Name=:details[0].leadGroupType + Queue + details[0].PrimaryVillageofInterest LIMIT 1];
     Lead lead = [Select id,name, ownerid FROM Lead WHERE id =:details[0].LeadId];
    
         try{
             if(GRP.size() > 0){
             lead.ownerid = Grp[0].id;
             update lead;
             }
             }
             catch (Exception e){
                 Throw e;
             }

     }

    global class leadDetails {
    
    @InvocableVariable(required=true)
    global id LeadId;
        
    @InvocableVariable(required=true)
    global string PrimaryVillageofInterest;
        
    @InvocableVariable(required=true)
    global string leadGroupType;
             
    }

}