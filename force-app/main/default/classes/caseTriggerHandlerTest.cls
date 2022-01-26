@isTest
private class caseTriggerHandlerTest{


  static void setupData(){
  
  village__c v = new vilLage__c();
  v.Name = 'Bicester';
  v.CertSales_Report_Sales_Grace_Period_Days__c = 1;
  v.Village_Code__c = 'BV';
  insert v;
  
  village__c vill = [SELECT ID, Name FROM Village__c WHERE Name = 'Bicester'];
  
      case c = new case();
      c.Guest_ID_Number_Part__c = 1;
      c.Payment_Status__c = 'Paid';
      c.Service_Guest_ID__c = 'x1';
      c.Service_Guest_Number__c = 'test';
      c.Village__c = vill.id;
      c.Client_QR_Code__c = 'ffdwfdw';
      c.HFS_Collection_Location__c = 'Bicester Train Station';
      insert c;  
      
  }

  static testMethod void unitTest() {
  
    setupData();
    
    case c = [SELECT id, HFS_Collection_Location__c FROM case WHERE HFS_Collection_Location__c ='Bicester Train Station'];
    c.HFS_Collection_Location__c = 'Bicester The Apartment';
    update c;
  
  }

}