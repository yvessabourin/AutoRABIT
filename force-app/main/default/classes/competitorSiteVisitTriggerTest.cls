@IsTest
Public Class competitorSiteVisitTriggerTest{

        @testSetup 
        static void setUpData(){
    
        Profile profileSysAdmin = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator'];

        UserRole adminRole = new UserRole();
        adminRole.DeveloperName = 'CustomRole';
        adminRole.Name = 'Custom Role';
        insert adminRole;

        User admin = new User();
        admin.LastName = 'AdministratorForTestingHere';
        admin.Alias = 'admin';
        admin.Email = 'adminFortests@valueretai.com';
        admin.Username = 'adminFortests@valueretai.com';
        admin.CommunityNickname = 'admin';
        admin.UserRoleId = adminRole.Id;
        admin.ProfileId = profileSysAdmin.Id;
        admin.Village__c = 'Bicester';
        admin.TimeZoneSidKey = 'GMT';
        admin.LocaleSidKey = 'en_GB';
        admin.EmailEncodingKey = 'ISO-8859-1';
        admin.LanguageLocaleKey = 'en_US';
        insert admin;
    
            system.runAs(admin){
                User usr = TestData_User.setupUser('BillyBones', null, 'System Administrator', true, true);
                usr.email = 'dchilds@valueretail.com';
        
                Collaborationgroup cg = new Collaborationgroup(); 
                cg.name = 'B2B Meetings Test';
                cg.CollaborationType = 'Public';
                insert cg;
                
                CollaborationGroupMember grpMember = new CollaborationGroupMember(MemberId = usr.Id, CollaborationGroupId = cg.Id);
                insert grpMember;
                
                Village__c village = TestDataGenerator.setupVillage(true);
                
                Competitor_Site__c cs = new Competitor_Site__c(name = 'Test Site', competitor_to_village__c = village.id);
                insert cs;
                
                Competitor_Visit__c cv = new Competitor_Visit__c(Competitor_Site__c = cs.id,Date_of_Visit__c = system.today(),Number_of_Empty_Units__c = 2, Announced_New_Arrivals__c = 3 );
                insert cv;
            
            }
        }


    @istest
    public static void updateTest(){ 
    
    Competitor_Visit__c cv = [SELECT Id, name, Share_Site_Visit_Info__c FROM Competitor_Visit__c ];
        
    test.startTest();
       
        try{
        cv.Share_Site_Visit_Info__c = true;
        update cv;
        }
        Catch (exception e){
            system.debug(e.getmessage());
        }
     
     test.stopTest();
    
             
    }  
    
    static testmethod void testSendEmails_Success1(){
        Competitor_Visit__c compVisit = [SELECT Id FROM Competitor_Visit__c LIMIT 1];
        CompetitorVisitAddAttachmentsExt.doUploadAttachment(compVisit.Id, 'This is a test', 'ExampleTestContentVersion', null);
        CompetitorVisitAddAttachmentsExt.doUploadAttachment(compVisit.Id, 'This is a test2', 'ExampleTestContentVersion2', null);

        List<Id> cvIdsList = new List<Id>{compVisit.Id};
        Test.startTest();
        compSiteVisitEmailHandler.sendEmails(cvIdsList);
        Test.stopTest();
    } 
    
        static testmethod void testSendEmails_Success2(){
            Competitor_Site__c cs = [SELECT Id FROM Competitor_Site__c LIMIT 1];

            List<Competitor_Visit__c> compVisitToInsert = new List<Competitor_Visit__c>();
            for(Integer i = 1; i <= 12; i++){
                compVisitToInsert.add(new Competitor_Visit__c(Competitor_Site__c = cs.id, Date_of_Visit__c = Date.newInstance(2021, i, 1), Number_of_Empty_Units__c = 2, Announced_New_Arrivals__c = 3 ));
            }
            insert compVisitToInsert;
            CompetitorVisitAddAttachmentsExt.doUploadAttachment(compVisitToInsert[0].Id, 'This is a test', 'ExampleTestContentVersion', null);

            List<Id> cvIdsList = new List<Id>(new Map<Id, Competitor_Visit__c>(compVisitToInsert).keySet());
            Test.startTest();
            compSiteVisitEmailHandler.sendEmails(cvIdsList);
            Test.stopTest();
    } 

}