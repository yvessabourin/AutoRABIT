public class OracleProjectIdShowHandler{
    public final Marketing_Campaign__c mc;
    public String bu1{get;set;}
    Public String bu2{get;set;}
    public String primaryNumber{get;set;}
    public String secondaryNumber{get;set;}
    
    public OracleProjectIdShowHandler(ApexPages.StandardController stdController){
        this.mc = (Marketing_Campaign__c)stdController.getRecord();      
        
        Marketing_Campaign__c mcamp = [Select id, Oracle_Project_Number__c, Oracle_Secondary_Project_Number__c , Village__c, Village__r.Name from Marketing_Campaign__c where id=:mc.id];
        primaryNumber = mcamp.Oracle_Project_Number__c;
        secondaryNumber = mcamp.Oracle_Secondary_Project_Number__c;
        
    
      Business_Unit__c[] bUnit = [Select id, Business_Unit_Code__c,OraclePrimaryBusinessUnit__c from Business_Unit__c where Village__c=:mcamp.Village__c];
        
        if(bUnit.size()>0){
            bu1 = bUnit[0].Business_Unit_Code__c;
        }
        
        if(bUnit.size()>1){
            bu2 = bUnit[1].Business_Unit_Code__c;
        }    
    } 
}