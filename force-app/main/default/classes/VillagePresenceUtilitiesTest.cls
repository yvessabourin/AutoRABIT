/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class VillagePresenceUtilitiesTest {


    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static Village__c village1 = new Village__c();
    private static Village__c village2 = new Village__c();
    
    static void setupData(){
    
        account = TestData_Account.setupBrandAccount(1, true);
        contact = TestData_Contact.setupBrandContact('A',account, true);    
                    
        //create village 1
        village1 = new Village__c();
        village1.Name = 'TestVillage1';         
        village1.Village_Code__c = 'AA';
        village1.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village1.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert village1;
        village1 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];     

        //create village 2
        village2 = new Village__c();
        village2.Name = 'TestVillage2';         
        village2.Village_Code__c = 'BB';
        village2.CertSales_CertPeriod_Cut_Off_Days__c = 1;
        village2.CertSales_Report_Sales_Grace_Period_Days__c = 1;   
        insert village2;
        village2 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'BB' LIMIT 1]; 
    
    }
    
    static testMethod void testCreateVillagePresence() {
        
        setupData();
        
        test.startTest();
        
            Village_Presence__c vp = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);
            vp = [select name from Village_Presence__c where Brand__c = :account.Id];
            system.assertEquals(vp.Name, account.Name + ' in ' + village1.Name);
        
        
        test.stopTest();
    }
    
    
    static testMethod void testSearchSingleVillagePresence() {
        
        setupData();
        
        test.startTest();
        
            Village_Presence__c vp = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);         
            vp = VillagePresenceUtilities.getVillagePresence(village1.name, account.name);
            system.assertEquals(vp.Name, account.Name + ' in ' + village1.Name);
            
            // check for no record
            vp = VillagePresenceUtilities.getVillagePresence(account.Id, 'abcde');
            system.assert(vp == null);
            
        test.stopTest();
    }


    static testMethod void testSearchMultipleVillagePresence() {
        
        setupData();
        
        test.startTest();
        
            Village_Presence__c vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);            
            Village_Presence__c vp2 = VillagePresenceUtilities.createVillagePresence(account.Id, village2.Name);
            
            map<string, list<string>> brandsVillages = new map<string, list<string>> ();
            list<string> villageList = new list<string>();
            villageList.add(village1.name);
            villageList.add(village2.name);
            brandsVillages.put(account.name, villageList);
            map<string, map<string,Village_Presence__c>> resultMap = VillagePresenceUtilities.getVillagePresence(brandsVillages); 
            map<string,Village_Presence__c> brandMap = resultMap.get(account.name);
            
            system.assert(brandMap != null);            
            system.assertEquals(brandMap.size(), 2);
            
                    
        
        test.stopTest();
    }


    static testMethod void testContactRoleInsert() {
        
        setupData();
        

        test.startTest();
        
            Village_Presence__c vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);            
            Village_Presence__c vp2 = VillagePresenceUtilities.createVillagePresence(account.Id, village2.Name);
            
            Village_Presence_Contact_Role__c vpRole1 = new Village_Presence_Contact_Role__c(Village_presence__c = vp1.Id,
                                                                                            Contact__c = contact.id);
            
            insert vpRole1;
        test.stopTest();            
      
        
        contact = [select Village_Presence__c from contact where id = :contact.Id];                                                                                             
        string contactRoles = contact.Village_Presence__c;

        vp1 = [select village__r.name from Village_Presence__c where village__c = :village1.Id];
        system.assertEquals(contactRoles, vp1.Village__r.name);
   
    }
 
    static testMethod void testContactRoleDelete() {
        
        setupData();
        

        test.startTest();
        
            Village_Presence__c vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);            
            Village_Presence__c vp2 = VillagePresenceUtilities.createVillagePresence(account.Id, village2.Name);
            
            Village_Presence_Contact_Role__c vpRole1 = new Village_Presence_Contact_Role__c(Village_presence__c = vp1.Id,
                                                                                            Contact__c = contact.id);
            
            insert vpRole1;
        
            Village_Presence_Contact_Role__c vpRole2 = new Village_Presence_Contact_Role__c(Village_presence__c = vp2.Id,
                                                                                            Contact__c = contact.id);                   
            insert vpRole2;
            
            delete vpRole1;
        
        test.stopTest();
        
                
        contact = [select Village_Presence__c from contact where id = :contact.Id];                                                                                             
        list<string> contactRoles = contact.Village_Presence__c.split(';');

        //DC system.assertEquals(contactRoles.size(),1);
        
        vp2 = [select village__r.name from Village_Presence__c where village__c = :village2.Id];
      //DC  system.assertEquals(contactRoles[0], vp2.Village__r.name);
        
    }

    static testMethod void testDuplicateCheck() {
        
        setupData();
        

        test.startTest();

            Village_Presence__c vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);            
            
            try {
                // insert the same record again
                vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);
            } catch (exception e){
                
                boolean expectedExceptionThrown =  e.getMessage().contains('already exists') ? true : false;
            //DC   system.assertEquals(expectedExceptionThrown, true);             
            }
        
        
        test.stopTest();
        
    }
    
    static testMethod void testCompetitorStoreLink(){

        setupData();
 
        Competitor_Site__c competitorSite = new Competitor_Site__c();
        competitorSite.Competitor_to_Village__c = village1.Id;
        competitorSite.Site_Coordinates__Latitude__s = 50.100;
        competitorSite.Site_Coordinates__Longitude__s = -1;
        insert competitorSite;
        
        Competitor_Store__c store = new Competitor_Store__c();
        store.Brand__c = account.Id;
        store.Competitor_Site__c = competitorSite.Id;
        insert store;
 
        test.startTest();

            Village_Presence__c vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);            
            
  
        test.stopTest();

        store = [select Village_Presence__c from Competitor_Store__c where id =:store.Id];
        
        //DC system.assertEquals(store.Village_Presence__c, vp1.Id); 

    }
    
      static testMethod void testVIPBrandPreference(){

        setupData();
 
        // add VIP guest
        
      Account testAccount = new Account(FirstName = 'John', LastName = 'Smith' , PersonEmail='testemail@mail.com', RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByName.get('VIP Guest').RecordTypeId);
        insert testAccount;
        
        Village_Presence__c vp1 = VillagePresenceUtilities.createVillagePresence(account.Id, village1.Name);            
            
            
        VIP_Brand_Preference__c VBP = new VIP_Brand_Preference__c();
        
 VBP.Name = 'test';
 VBP.Village_Presence__c = vp1.Id;
 VBP.VIP_Guest__c = testAccount.Id;
        test.startTest();

            insert VBP;
  
        test.stopTest();
VIP_Brand_Preference__c VBPReGet = [SELECT ID, Name FROM VIP_Brand_Preference__c WHERE ID = :VBP.Id LIMIT 1];

      system.assertEquals(VBPReGet.Name, account.Name); 

    }
}