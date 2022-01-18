@isTest
private class duplicateAccountDeletetest{

        private static List<Account> acts = new List<Account>();
        private static Account Act1 = new Account();  
        private static Account Act2 = new Account();
    
    
        @testSetup static void setupdata(){
          
              LIST<recordtype> actrtid = [SELECT id from Recordtype WHERE DeveloperName = 'Tourism' AND SobjectType = 'Account'];
              LIST<recordtype> conrtid = [SELECT id from Recordtype WHERE Name = 'Tourism Contact' AND SobjectType = 'Contact'];
              List<Lead> Leadstoadd = new List<lead>();
          
              //create account
              act1.name = 'ControllerTest1';
              act1.recordtypeid = actrtid[0].id;
              act1.country__c = 'Albania';
              act1.Type_of_Business__c = 'Airline';
              insert act1;
              
               //create account
              act2.name = 'ControllerTest2';
              act2.recordtypeid = actrtid[0].id;
              act2.country__c = 'Albania';
              act2.Type_of_Business__c = 'Airline';
              act2.Duplicate_of_Account__c = act1.id;
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.DuplicateRuleHeader.AllowSave = true;
            Database.insert(act2, dmlOptions); 
          
         }

    
    
     
        static testmethod void mergeAccounts(){
        
            PageReference testPage = new pagereference('/apex/Duplicate_Act_Delete');
            
            Test.setCurrentPage(testPage);
            
            duplicateAccountDelete mycontroller = new duplicateAccountDelete();
            
            system.assertequals(1,mycontroller.acts.size(),'Expecting to find 1 acts' );
            
            mycontroller.deleteaccounts();
            
            List<account> deleted = [SELECT id from Account WHERE id =:Act2.id];
            system.assertequals(0,deleted.size(),'Acts is not zero');
                  
        }
         
         











}