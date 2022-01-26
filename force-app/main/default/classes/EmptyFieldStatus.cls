public class EmptyFieldStatus {
    
    public static void EmptyStatus(List< Marketing_Activity__c> newlistMarketing){
       
        for(Marketing_Activity__c marck : newlistMarketing){
            //if(marck.Status__c == 'To be confirmed' || marck.Status__c == 'Confirmed' ){
              if(marck.Status__c == 'To be Approved' || marck.Status__c == 'Confirmed' ){
                marck.Reason_for_Removal_or_Cancellation__c='';
            } 
            
        }
    }
    
}