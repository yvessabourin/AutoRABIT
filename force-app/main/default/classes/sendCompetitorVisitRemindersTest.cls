@IsTest
Public Class sendCompetitorVisitRemindersTest{

    private static Village__c village = new Village__c();
    private static competitor_site__c compsite = new competitor_site__c ();

    @testSetup static void setupdata(){
    
        Profile pf = [select Id from Profile where name = 'Tourism'];

        User usr1 = new User();
        usr1.LastName = 'myTestu1';
        usr1.Alias = 'myTestu1';
        usr1.Email = 'myTestu1@valueretail.com';
        usr1.Username = 'controllertest12@valueretail.com';
        usr1.Communitynickname = 'myTestu1' + 'Nickname';
        usr1.profileId = pf.Id;
        usr1.PortalRole = 'Manager';
        usr1.timezonesidkey = 'Europe/London';
        usr1.emailencodingkey = 'UTF-8';
        usr1.languagelocalekey = 'en_US';
        usr1.localesidkey = 'en_GB';
        usr1.isActive = true;   
        insert usr1;    
        
        User usr2 = new User();
        usr2.LastName = 'myTestu2';
        usr2.Alias = 'myTestu2';
        usr2.Email = 'myTestu2@valueretail.com';
        usr2.Username = 'controllertest123@valueretail.com';
        usr2.Communitynickname = 'myTestu2' + 'Nickname';
        usr2.profileId = pf.Id;
        usr2.PortalRole = 'Manager';
        usr2.timezonesidkey = 'Europe/London';
        usr2.emailencodingkey = 'UTF-8';
        usr2.languagelocalekey = 'en_US';
        usr2.localesidkey = 'en_GB';
        usr2.isActive = true;   
        insert usr2;   
                 
      village.Name = 'TestVillage1';     
      village.Village_Code__c = 'AA';
	  village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
	  village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
      insert village;
         
    }

    Static testmethod void reminderSentSuccessful(){
    
        
       list<user> usrs = [select id,name FROM user WHERE lastname LIKE 'myTestu%'];
        
      competitor_site__c compsite = new competitor_site__c();
      compsite.Name = 'test comp site';
      compsite.Next_On_Site_Visit__c = system.today()-1;
      compsite.Site_Captain__c = usrs[0].id;
      compsite.Additional_Site_Captain__c = usrs[1].id;
      insert compsite;
    
    Test.StartTest();
    sendCompetitorVisitReminders s=new sendCompetitorVisitReminders();
    s.execute(null);
    Integer invocations = Limits.getEmailInvocations();
    Test.stopTest();
    
    System.assertEquals(1, invocations, 'An email has not been sent');
    
    }
    

}