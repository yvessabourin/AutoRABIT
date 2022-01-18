@isTest
Public class TestData_Account{

   /**
   * Setup Brand Account
   */
    public static Account setupBrandAccount(Integer identifier, Boolean insertToDatabase) {
        
        Id brandRecordType; 
        brandRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        return setupAccount(identifier, insertToDatabase, brandRecordType );
    }
    
   /**
   * Setup Group(brand) Account
   */
    public static Account setupGroupAccount(Integer identifier, Boolean insertToDatabase) {
        
        Id groupRecordType; 
        groupRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group').getRecordTypeId();
        return setupAccount(identifier, insertToDatabase, groupRecordType );
    }
    

   /**
   * Setup Tourism Account (Partner)
   */
    public static Account setupTourismAccount(Integer identifier, Boolean insertToDatabase) {
    
        Id tourismRecordType;
        tourismRecordType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        return setupAccount(identifier, insertToDatabase, tourismRecordType );
    }
    


    /**
    * Setup Basic Account
    */
    public static Account setupAccount(Integer identifier, Boolean insertToDatabase, Id recordTypeId) {
        Account testAccount = new Account(name = 'Test Account' + identifier, BillingPostalCode = ''+identifier,
                                          RecordTypeId = recordTypeId);
        if (insertToDatabase) {
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.DuplicateRuleHeader.AllowSave = true;
            Database.insert(testAccount, dmlOptions); 
        }
        return testAccount;
    }

}