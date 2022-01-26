global class deleteGiftsFromFlowSelection {


    @InvocableMethod
    global static void deleteGifts(list<giftDeleteRequest> deleteRequest)  {   
    
    list<string> mystringids = deleteRequest[0].ids.split(';');
    list<id> ids = new list<id>();
    
    for(string parts : mystringids){
        parts = parts.trim();
        ids.add(parts);
    }
    
    list<Gift__c> gifts = [SELECT Id FROM Gift__c WHERE id IN :ids ];
    
    try {
    delete gifts; 
    } catch (DmlException e) {
    throw e;
    }
    
    }
    
   

    global class giftDeleteRequest {
    @InvocableVariable(required=true)
    global string ids;

    }

}