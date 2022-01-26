public class MAProjectNumberShowHandler {
    public final Marketing_Activity__c ma;
    public String bu1{get;set;}
    Public String bu2{get;set;}
    public String primaryNumber{get;set;}
    public String secondaryNumber{get;set;}
    
    public MAProjectNumberShowHandler(ApexPages.StandardController stdController){
        this.ma = (Marketing_Activity__c)stdController.getRecord();      
        
        Marketing_Activity__c mact = [Select id, Marketing_Campaign__r.Oracle_Project_Number__c, Marketing_Campaign__r.Oracle_Secondary_Project_Number__c, Marketing_Campaign__r.Village__c  from Marketing_Activity__c where id=:ma.id];
        primaryNumber   = mact.Marketing_Campaign__r.Oracle_Project_Number__c;
        secondaryNumber = mact.Marketing_Campaign__r.Oracle_Secondary_Project_Number__c; 
        
        Business_Unit__c[] bUnit = [Select id, Business_Unit_Code__c,OraclePrimaryBusinessUnit__c from Business_Unit__c where Village__c=:mact.Marketing_Campaign__r.Village__c];
        
        if(bUnit.size()>0){
            system.debug('BU1##'+bUnit[0].OraclePrimaryBusinessUnit__c);
            system.debug('BUCODE1##'+bUnit[0].Business_Unit_Code__c);
            bu1 = bUnit[0].Business_Unit_Code__c;
        }
        if(bUnit.size()>1){
            system.debug('BU2##'+bUnit[1].OraclePrimaryBusinessUnit__c);
            system.debug('BUCODE2##'+bUnit[1].Business_Unit_Code__c);
            bu2 = bUnit[1].Business_Unit_Code__c;
        }
    } 
}