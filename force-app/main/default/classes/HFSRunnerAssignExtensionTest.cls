@isTest
public class HFSRunnerAssignExtensionTest {

    static void setupData(){

        Profile profileRunner = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Runner'];
        Profile profileCoordinator = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Co-ordinator'];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'CEO'];
        Group grp = [SELECT id,DeveloperName,type FROM Group WHERE Type = 'Regular' AND DeveloperName = 'Runners'];
        Group grp2 = [SELECT id,DeveloperName,type FROM Group WHERE Type = 'Regular' AND DeveloperName = 'HFS_Owners_Bicester'];
        Group grp3 = [SELECT id,DeveloperName,type FROM Group WHERE Type = 'Regular' AND DeveloperName = 'Co_ordinator'];
        Group grp4 = [SELECT id,DeveloperName,type FROM Group WHERE Type = 'Regular' AND DeveloperName = 'All_BV_HFS'];
        
        list<GroupMember> grpmrs = new list<GroupMember>();
        GroupMember grpmr1 = new GroupMember(GroupId = grp.id);
        GroupMember grpmr11 = new GroupMember(GroupId = grp2.id);
        GroupMember grpmr111 = new GroupMember(GroupId = grp3.id);
        GroupMember grpmr1111 = new GroupMember(GroupId = grp4.id);
        GroupMember grpmr2 = new GroupMember(GroupId = grp.id);
        GroupMember grpmr22 = new GroupMember(GroupId = grp2.id);
        GroupMember grpmr222 = new GroupMember(GroupId = grp3.id);
         GroupMember grpmr2222 = new GroupMember(GroupId = grp4.id);


        User runner = new User();
        runner.LastName = 'John';
        runner.Alias = 'jhn';
        runner.Email = 'john@valueretai.com';
        runner.Username = 'john@valueretai.com';
        runner.CommunityNickname = 'johnvr';
        runner.UserRoleId = role.Id;
        runner.ProfileId = profileRunner.Id;
        runner.Village__c = 'Bicester';
        runner.TimeZoneSidKey = 'GMT';
        runner.LocaleSidKey = 'en_GB';
        runner.EmailEncodingKey = 'ISO-8859-1';
        runner.LanguageLocaleKey = 'en_US';
        insert runner;
        
        grpmr1.UserOrGroupId = runner.id; 
        grpmr11.UserOrGroupId = runner.id; 
        grpmr111.UserOrGroupId = runner.id; 
        grpmr1111.UserOrGroupId = runner.id; 
        grpmrs.add(grpmr1);
        grpmrs.add(grpmr11);
        grpmrs.add(grpmr111);
         grpmrs.add(grpmr1111);

        User coordinator = new User();
        coordinator.LastName = 'Paul';
        coordinator.Alias = 'pal';
        coordinator.Email = 'paul@valueretai.com';
        coordinator.Username = 'paul@valueretai.com';
        coordinator.CommunityNickname = 'paulas';
        coordinator.UserRoleId = role.Id;
        coordinator.ProfileId = profileCoordinator.Id;
        coordinator.Village__c = 'Bicester';
        coordinator.TimeZoneSidKey = 'GMT';
        coordinator.LocaleSidKey = 'en_GB';
        coordinator.EmailEncodingKey = 'ISO-8859-1';
        coordinator.LanguageLocaleKey = 'en_US';
        insert coordinator;
        
        grpmr2.UserOrGroupId = coordinator.id; 
        grpmr22.UserOrGroupId = coordinator.id; 
        grpmr222.UserOrGroupId = coordinator.id; 
        grpmr2222.UserOrGroupId = coordinator.id; 
        grpmrs.add(grpmr2);
        grpmrs.add(grpmr22);
        grpmrs.add(grpmr222);
        grpmrs.add(grpmr2222);
 
        
        insert grpmrs;

        system.runAs(coordinator){
            // first create a village
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
            vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
            vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert vill;

            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            RecordType guestRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];

            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;

            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            insert presentBrand;

            Case guestCase = new Case();
            guestCase.Village__c = vill.Id;
            guestCase.Service_Guest_ID__c = '123456789';
            guestCase.Service_Guest_Number__c = 'XA1';
            guestCase.Guest_ID_Number_Part__c = 12;
            guestCase.Payment_Status__c = 'Paid';
            guestCase.Client_QR_Code__c = '123456789';
            guestCase.Status = 'New';
            guestCase.Origin = 'Email';
            insert guestCase;

            Case newGuest = [SELECT ID, Service_Guest_ID__c, Village__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
            Village_Presence__c brandS = [SELECT Id, Village__c FROM Village_Presence__c WHERE Village__c = :newGuest.Village__c];

            Case_Item__c hfsPurchase = new Case_Item__c();
            hfsPurchase.Case__c = guestCase.Id;
            hfsPurchase.Status__c = 'Awaiting Pick-up from Brand';
            hfsPurchase.Start_Time__c = system.now();
            hfsPurchase.Item_Count__c = 3;
            hfsPurchase.Bag_Barcodes_Manual__c = '123456,false,123457,true,152635,false';
            hfsPurchase.Require_a_Runner__c = true;       // RIC
            hfsPurchase.HFS_Bag_Transfer__c = false;
            hfsPurchase.Village_Presence__c = brandS.Id; //RIC
            insert hfsPurchase;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.Village__c = 'Bicester';
            newRunner.User__c = runner.Id;
            insert newRunner;

            HFS_Storage_Point__c newSP = new HFS_Storage_Point__c();
            newSP.Name = 'Bicester Village Center';
            newSP.Village__c = 'Bicester';
            insert newSP;

            HFS_Storage_Location__c newSL = new HFS_Storage_Location__c();
            newSL.Name = 'B1';
            newSL.HFS_Storage_Point__c = newSP.Id;
            newSL.Status__c = 'Empty';
            newSL.QR_Code_hidden__c = '123456789';
            insert newSL;
        }
    }

    static testMethod void assignTestN1(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
            controller.selectedAssignedRunner = 'null';
            controller.assign();
    

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        System.assertEquals(null, controller.assign());
        System.assertEquals('null', controller.selectedAssignedRunner);
        }
        Test.stopTest();
    }

    static testMethod void assignTestN2(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        HFS_Runner__c runner = [SELECT Id FROM HFS_Runner__c];


Test.startTest();
system.runAs(hfsCoordinator){
        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
            
                job.HFS_Runner__c = runner.Id;
                update job;
            

            controller.selectedAssignedRunner = runner.Id;
            controller.assign();
        

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        System.assertEquals(null, controller.assign());
        }
        Test.stopTest();
    }

    static testMethod void assignTestN3(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        HFS_Runner__c runner = [SELECT Id FROM HFS_Runner__c];
        
        Test.startTest();
            system.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
                job.HFS_Runner__c = null;
                update job;
                controller.selectedAssignedRunner = runner.Id;
                controller.assign();
           

        HFS_Job__c thejob = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        System.assertEquals(null, controller.assign());
        System.assertEquals(controller.selectedAssignedRunner,thejob.HFS_Runner__c);
        
         }
        Test.stopTest();
      
    }
    


    static testMethod void createNewJobTestN1(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c, Job_Type__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        HFS_Runner__c runner = [SELECT Id FROM HFS_Runner__c];
        
         Test.startTest();
            System.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

       
                controller.selectedAssignedRunner = 'null';
                controller.createNewJob();

                System.assertNotEquals(null, controller.createNewJob());
           

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        
         }
        Test.stopTest();
    }

    static testMethod void createNewJobTestN2(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsRunner = [SELECT Id FROM User WHERE Alias = 'pal'];
        HFS_Runner__c runner = [SELECT Id FROM HFS_Runner__c];
        
        Test.startTest();
            System.runAs(hfsRunner){

        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
                controller.selectedAssignedRunner = runner.Id;
                controller.createNewJob();

                System.assertNotEquals(null, controller.createNewJob());
            

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        
        }
        Test.stopTest();
    }

    static testMethod void createNewJobTestN3(){
        setupData();
        
        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        HFS_Runner__c runner = [SELECT Id FROM HFS_Runner__c];
        
         Test.startTest();
            System.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

       
  
                controller.createNewJob();
               
          

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        System.assertEquals(null, controller.createNewJob());
        
          }
        Test.stopTest();
       
       
    }
    
    static testMethod void createNewJobTestN4(){
        
        setupData();
      
        HFS_Job__c job = [SELECT Id, HFS_Runner__c, Job_Type__c FROM HFS_Job__c ];
        HFS_Runner__c Runner = [SELECT Id FROM  HFS_Runner__c WHERE name ='John'];
         User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal' ];
      
        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);
           Test.startTest();
              
         System.runAs(hfsCoordinator){ 
         job.Job_Type__c = 'Bag Transfer';
         update job;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);
      
               
                 controller.selectedAssignedRunner = runner.Id;
                 controller.createNewJob();
                
                System.assertNotEquals(null, controller.createNewJob());
                 
          }
            Test.stopTest();     
        
    }
    
     static testMethod void createNewJobTestN5(){
        
        setupData();
      
        HFS_Job__c job = [SELECT Id, HFS_Runner__c, Job_Type__c FROM HFS_Job__c ];
        HFS_Runner__c Runner = [SELECT Id FROM  HFS_Runner__c WHERE name ='John'];
         User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal' ];
         
         Test.startTest();
              
         System.runAs(hfsCoordinator){ 
      
        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);
           
         job.Job_Type__c = 'Bag Drop';
         update job;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);
      
       
                
                 controller.selectedAssignedRunner = runner.Id;
                 controller.createNewJob();
                
                System.assertNotEquals(null, controller.createNewJob());
                 
          }
            Test.stopTest();     
        
    }

    static testMethod void cancelTest(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
        system.runAs(hfsCoordinator){
        PageReference pageRef = Page.HFSRunnerAssign;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
            controller.cancel();
        

        System.assertNotEquals(null, controller.getRunners());
        System.assertNotEquals(null, controller.allRunners);
        System.assertNotEquals(null, controller.cancel());
        }
        Test.stopTest();
    }

    static testMethod void autoRunTestN1(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
            system.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSCreateNewJobAutomatically;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
                controller.autoRun();

                System.assertNotEquals(null, controller.getRunners());
                System.assertNotEquals(null, controller.allRunners);
                System.assertNotEquals(null, controller.autoRun());
            }
        Test.stopTest();
    }
    
    
    static testMethod void autoRunTestN2(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
            system.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSCreateNewJobAutomatically;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
                job.Job_Type__c = 'Bag Drop';
                update job;
                controller.autoRun();

                System.assertNotEquals(null, controller.getRunners());
                System.assertNotEquals(null, controller.allRunners);
                System.assertNotEquals(null, controller.autoRun());
            }
        Test.stopTest();
    }

    static testMethod void autoRunTestN3(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        
         Test.startTest();
            system.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSCreateNewJobAutomatically;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

       
                job.Job_Type__c = 'Bag Transfer';
                update job;
                controller.autoRun();

                System.assertNotEquals(null, controller.getRunners());
                System.assertNotEquals(null, controller.allRunners);
                System.assertNotEquals(null, controller.autoRun());
            }
        Test.stopTest();
    }

    static testMethod void cancelJobTest(){
        setupData();

        HFS_Job__c job = [SELECT Id, HFS_Runner__c FROM HFS_Job__c];
        User hfsCoordinator = [SELECT Id FROM User WHERE Alias = 'pal'];
        
        Test.startTest();
            system.runAs(hfsCoordinator){

        PageReference pageRef = Page.HFSCancelJob;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(job);
        HFSRunnerAssignExtension controller = new HFSRunnerAssignExtension(sc);

        
                controller.cancelAJob();

                System.assertNotEquals(null, controller.getRunners());
                System.assertNotEquals(null, controller.allRunners);
                System.assertNotEquals(null, controller.cancelAJob());
            }
        Test.stopTest();
    }
}