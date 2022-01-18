@isTest
private class PrimaryVPCRCheckTest {
  
  private static Account account = new Account();
  private static Village_Presence_Contact_Role__c vpcr = new Village_Presence_Contact_Role__c();
  private static Village_Presence_Contact_Role__c vpcr2 = new Village_Presence_Contact_Role__c();
  private static Village_Presence__c vp = new Village_Presence__c();
  private static Village__c village = new Village__c();
  private static Contact con1 = new Contact();
  private static Contact con2 = new Contact();
  
    
    static testmethod void setupData(){
    
   // account = TestData_Account.setupBrandAccount(1, true);
  //  contact = TestData_Contact.setupBrandContact('A',account, true);  
  List<Village_Presence_Contact_Role__c> vpcrs = new List<Village_Presence_Contact_Role__c>{};
  
     //create village 1
     village = new Village__c();
     village.Name = 'TestVillage1';     
     village.Village_Code__c = 'AA';
	 village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
	 village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
     insert village;
    
          
     //create account
     account.name = 'Test Account1';
     account.recordtypeid = '012b0000000KrCs';
     insert account;
     
     //create Village Presence
     vp.name = 'test';
     vp.brand__c = account.id;
     vp.village__c = village.id;
     insert vp;
     
     con1.recordtypeid = '012b0000000c8wK';
     con1.firstName = 'Danny';
     con1.lastname = 'Test1';
     con1.Account = account;
     con1.email = 'dmoirc@hotmail.com';
     insert con1;
     
     con2.recordtypeid = '012b0000000c8wK';
     con2.firstName = 'Danny';
     con2.lastname = 'Test2';
     con2.Account = account;
     con2.email = 'dmoirc@hotmail.co.uk';
     insert con2;
     
     
      
     vpcr.contact__c = con1.id;
     vpcr.Village_Presence__c = vp.id;
     vpcr.Retail_Role__c = 'Marketing';
     vpcr.Primary_Contact_Role__c = TRUE;
     vpcrs.add(vpcr);

     
     vpcr2.contact__c = con2.id;
     vpcr2.Village_Presence__c = vp.id;
     vpcr2.Retail_Role__c = 'Marketing';
     vpcr2.Primary_Contact_Role__c = False;
     vpcrs.add(vpcr2);
     insert vpcrs;
     
     
     try{
     vpcr = [select name, Primary_Contact_Role__c from Village_Presence_Contact_Role__c where id = :vpcr2.Id];
     vpcr.Primary_Contact_Role__c = TRUE;
     update vpcr;
   
     }
     catch (DMLException e){
     System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
     } catch(Exception e){
     
     
     }
     
     
     

    }

}