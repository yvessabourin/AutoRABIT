@isTest
public class HandsFreeShoppingGuestExtensionTest{

    static void setupData(){

        Profile profileRunner = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Runner'];
        Profile profileCoordinator = [SELECT ID, Name FROM Profile WHERE Name = 'HFS Co-ordinator'];

        UserRole runnerRole = new UserRole();
        runnerRole.DeveloperName = 'CustomRole';
        runnerRole.Name = 'Custom Role';
        insert runnerRole;

        User runner = new User();
        runner.LastName = 'John';
        runner.Alias = 'jhn';
        runner.Email = 'john@valueretai.com';
        runner.Username = 'john@valueretai.com';
        runner.CommunityNickname = 'johnvr';
        runner.UserRoleId = runnerRole.Id;
        runner.ProfileId = profileRunner.Id;
        runner.Village__c = 'Bicester';
        runner.TimeZoneSidKey = 'GMT';
        runner.LocaleSidKey = 'en_GB';
        runner.EmailEncodingKey = 'ISO-8859-1';
        runner.LanguageLocaleKey = 'en_US';
        insert runner;

        User coordinator = new User();
        coordinator.LastName = 'Paul';
        coordinator.Alias = 'pal';
        coordinator.Email = 'paul@valueretai.com';
        coordinator.Username = 'paul@valueretai.com';
        coordinator.CommunityNickname = 'paulas';
        coordinator.UserRoleId = runnerRole.Id;
        coordinator.ProfileId = profileCoordinator.Id;
        coordinator.Village__c = 'Bicester';
        coordinator.TimeZoneSidKey = 'GMT';
        coordinator.LocaleSidKey = 'en_GB';
        coordinator.EmailEncodingKey = 'ISO-8859-1';
        coordinator.LanguageLocaleKey = 'en_US';
        insert coordinator;

        system.runAs(coordinator){
            
            // first create a village
            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
            vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
            vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert vill;
            
            Unit__c unit = new Unit__c(Name='TU1', Village__c = vill.Id, size_GEA__c = 200,  Unit_Status__c = 'Available', Phase_ID__c = 'BV1', Suite_ID__c = 'etc');
            insert unit;

            RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            RecordType guestRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];
            RecordType vipRecordType = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'VIP_Guest'];

            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';

            Account guest = new Account();
            guest.RecordTypeId = guestRecordType.Id;
			guest.LastName = 'Guest';
			guest.Customer_GUID__c = '65764186463';
			guest.PersonEmail = 'guest@test.com';
			
            Account vipGuest = new Account();
            vipGuest.RecordTypeId = vipRecordType.Id;
			vipGuest.LastName = 'Vip Guest';
			vipGuest.Customer_GUID__c = '84164848646';
			vipGuest.PersonEmail = 'vipguest@test.com';

			insert new List <Account> {brand, guest, vipGuest};
			
            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            presentBrand.Status__c = 'Trading';
			presentBrand.Unit__c = unit.Id;
			presentBrand.HFS_Bags_Used__c = 0;
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
            guestCase.Service_Date__c = system.today();
            guestcase.Guest_30_minutes__c = false;
            insert guestCase;
            
            case_item__c p = new case_item__c();
        	p.Case__c = guestCase.Id;
        	p.Village_Presence__c = presentBrand.id;
        	p.status__c = 'Awaiting Pick-up from Brand';
        	p.Start_Time__c = system.now();
        	p.Estimated_Spend__c = 123.00;
        	p.Item_Count__c = 1;
        	p.Bag_Barcodes_Manual__c = '111111,false';
        	p.Pickup_Location__c = 'Teste Bicester Brand in Bicester';
        	p.Require_a_Runner__c = true;
            p.HFS_Bag_Drop__c = false;
            p.HFS_Bag_Transfer__c = false;
        	insert p;

            RecordType RT = [SELECT Id, Name FROM RecordType WHERE Name = 'HFS Bags Missing' AND SobjectType = 'HFS_Incident__c' ];
            HFS_Incident__c incident = new HFS_Incident__c(Bag_s_returned_to_guest__c = 'No', Brand_Involved__c = 'test brand',Date_of_Incident__c = system.today(),HFS_Case__c = guestcase.id,Impact__c = 'test',Incident_Description__c = 'test', 
                                                        Incident_Reason__c = 'Bags given to another Guest',Is_Resolved__c = 'No',Is_Retail_Manager_Aware__c = 'No',Resolution_Notes__c = 'test', Status__c = 'Open');
            incident.recordtypeid = RT.id;
            insert incident;

            RecordType newJobRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];

            HFS_Runner__c newRunner = new HFS_Runner__c();
            newRunner.Name = 'John';
            newRunner.Village__c = 'Bicester';
            newRunner.User__c = runner.Id;
            insert newRunner;
        }
    }
    
    static testMethod void updateCaseXXMinutesTest(){
         setupData();
            
            User us = [SELECT Id FROM User WHERE Alias = 'pal'];
            
            Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
         
            Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        	
                    
            Test.startTest();
                system.runAs(us){
             

                    string theCollectiontime = '10:56 AM';
                ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
                HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);
                //string theIncidentId, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){    // String Impact,String Brand  ){
                string theId = guestCase.id;
                   
                HandsFreeShoppingGuestExtension.updateCaseXXMinutes(theId, theCollectiontime);
                    
                }
         
             Case updateguestCase = [SELECT ID, Guest_30_minutes__c,Guest_Arrive_at_Collection_Point__c FROM Case WHERE id =: guestCase.id];
            
             System.assertNotEquals(NULL, updateguestCase.Guest_Arrive_at_Collection_Point__c, 'failed');
    
            Test.stopTest();
                   
        }
    
    
    static testMethod void updateCase30MinutesTest(){
         setupData();
            
            User us = [SELECT Id FROM User WHERE Alias = 'pal'];
            
            Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
         
            Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        	
                    
            Test.startTest();
                system.runAs(us){
             
        
                ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
                HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);
                //string theIncidentId, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){    // String Impact,String Brand  ){
                string theId = guestCase.id;
                    
                HandsFreeShoppingGuestExtension.updateCase30Minutes(theId);
                    
                }
         
             Case updateguestCase = [SELECT ID, Guest_30_minutes__c FROM Case WHERE id =: guestCase.id];
            
             System.assertEquals(true, updateguestCase.Guest_30_minutes__c, 'failed');
    
            Test.stopTest();
                   
        }
    
    
     static testMethod void checkOutNoBagsTest(){
         setupData();
            
            User us = [SELECT Id FROM User WHERE Alias = 'pal'];
            
            Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
         
            Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        	
                    
            Test.startTest();
                system.runAs(us){
             
        
                ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
                HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);
                //string theIncidentId, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){    // String Impact,String Brand  ){
                string theId = guestCase.id;
                    
                HandsFreeShoppingGuestExtension.checkOutNoBags(theId);
                    
                }
         
             Case updateguestCase = [SELECT ID, Status FROM Case WHERE id =: guestCase.id];
            
             System.assertEquals('Did Not Participate', updateguestCase.Status, 'failed');
    
            Test.stopTest();
                   
        }
    
       static testMethod void saveHFSIncidentTest(){
         setupData();
            
            User us = [SELECT Id FROM User WHERE Alias = 'pal'];
            
            Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];

            
            Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        	
                    
            Test.startTest();
        	system.runAs(us){
         
    
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);
			//string theIncidentId, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){    // String Impact,String Brand  ){
            string theId = guestCase.id;
                

            string theDate = string.valueOf(system.today());
            HandsFreeShoppingGuestExtension.saveHFSIncident(theId,theDate,'HFS Bags Missing','Bags given to another Guest','other reason','Open','description test','test notes','Yes','Yes','Yes','Impact test','test brand2' );
                
            }
            HFS_Incident__c theupdatedincident = [SELECT id, Status__c FROM HFS_Incident__c WHERE Brand_Involved__c = 'test brand2'];
            
             System.assertEquals('Open', theupdatedincident.Status__c, 'failed');
    
            Test.stopTest();
            
            
                
        }
    
    static testMethod void clearoutHistoricItemsTest(){
         setupData();
            
            User us = [SELECT Id,Alias FROM User WHERE Alias = 'pal'];
            
        system.runAs(us){
            Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
            village_presence__c v = [SELECT id from village_presence__c WHERE Village__c =: village.id LIMIT 1];
            
            Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
       	
                    
            Test.startTest();
        	
         
    
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);
            string theId = guestCase.id;
            HandsFreeShoppingGuestExtension.clearoutHistoricItems(us.Alias, 'Close Reason Test', theId);
                
            
             Case updatedguestCase = [SELECT ID, Historic_Close_Reason__c,Was_Historically_Closed__c FROM Case WHERE id = : guestCase.id];
             System.assertEquals(true, updatedguestCase.Was_Historically_Closed__c, 'failed');
    
            Test.stopTest();
            
        }
            
            
                
        }

    
    static testMethod void updateHFSIncidentTest(){
         setupData();
            
            User us = [SELECT Id FROM User WHERE Alias = 'pal'];
            
            Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
            
            Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        	
            HFS_Incident__c theincident = [SELECT id, Bag_s_returned_to_guest__c, Brand_Involved__c ,Date_of_Incident__c ,HFS_Case__c ,Impact__c ,Incident_Description__c, 
                                                        Incident_Reason__c , Is_Resolved__c ,Is_Retail_Manager_Aware__c ,Resolution_Notes__c , Status__c FROM HFS_Incident__c WHERE Brand_Involved__c = 'test brand'];
		    
          
        Test.startTest();
        	system.runAs(us){
         
    
            ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
            HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);
			//string theIncidentId, String IncidentReasonOther,String Status, String Description, String ResNotes, String BagsReturned, String Resolved, String RetailMgrAware, String Impact,String Brand  ){    // String Impact,String Brand  ){
            string theId = theincident.id;
            string theDate = string.valueOf(system.today());
            HandsFreeShoppingGuestExtension.updateHFSIncident(theId,'other reason','Closed','description test','test notes','Yes','Yes','Yes','Impact test','test brand' );
                
            }
            HFS_Incident__c theupdatedincident = [SELECT id, Status__c FROM HFS_Incident__c WHERE id =:theincident.id];
            
             System.assertEquals('Closed', theupdatedincident.Status__c, 'failed');
    
            Test.stopTest();
            
            
                
        }

    static testMethod void guestExtensionTestN1(){
        setupData();
		
		User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Village__c village = [SELECT Id, Name FROM Village__c WHERE Name = 'Bicester'];
        
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
		system.runAs(us){
        	Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
			HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);

			HandsFreeShoppingGuestExtension.getcollectionLocation();

			Test.stopTest();

			System.assertEquals(guestCase.HFS_Collection_Location__c, HandsFreeShoppingGuestExtension.getcollectionLocation());
		}
    }
    
    static testMethod void guestExtensionTestN2(){
        setupData();
		User us = [SELECT Id FROM User WHERE Alias = 'pal'];        
        Village__c villageName = [SELECT Name FROM Village__c WHERE Name = 'Bicester'];
        List<Village_Presence__c> villagePresenceName = [SELECT Id, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];

		system.runAs(us){

			Test.startTest();

			ApexPages.StandardController sc = new ApexPages.StandardController(guestCase);
			HandsFreeShoppingGuestExtension hFSGext = new HandsFreeShoppingGuestExtension(sc);

			HandsFreeShoppingGuestExtension.searchBrand(villagePresenceName[0].Name, villageName.Name);

			Test.stopTest();

			System.assertEquals(villagePresenceName, HandsFreeShoppingGuestExtension.searchBrand(villagePresenceName[0].Name, villageName.Name));
		}
    }

    static testMethod void guestExtensionTestN3(){
        setupData();

        Village__c villageName = [SELECT Name FROM Village__c WHERE Name = 'Bicester'];
        Village_Presence__c villagePresenceName = [SELECT Id, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
			//Adding new Shopping Item. Bags should be included as used
            HandsFreeShoppingGuestExtension.saveShoppingItem(villagePresenceName.Id, '1200', '3', '123456,false,123457,true,152635,false',
															guestCase.Id, villagePresenceName.Name, 'Valet', true, false);
																		
			villagePresenceName = [SELECT HFS_Bags_Used__c, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
			System.assertEquals(3, villagePresenceName.HFS_Bags_Used__c);
			
			//Bagdrop. Bags MUSTN'T be included in the used tally
            HandsFreeShoppingGuestExtension.saveShoppingItem(villagePresenceName.Id, '1200', '3', '123456,false,123457,true,152635,false',
															guestCase.Id, villagePresenceName.Name, 'Valet', true, true);
			villagePresenceName = [SELECT Name, HFS_Bags_Used__c FROM Village_Presence__c WHERE Village__c = :villageName.Id];
			System.assertEquals(3, villagePresenceName.HFS_Bags_Used__c);															

            Case_Item__c caseItem = [SELECT ID FROM Case_Item__c WHERE case__c =:guestCase.id LIMIT 1];
            List<HFS_Bag__c> bags = [SELECT ID, Barcode__c, Scanned_for_collection__c FROM HFS_Bag__c WHERE HFS_Purchase__c =:caseItem.id ];
            bags[0].Scanned_for_collection__c = true;
            update bags[0];

            HandsFreeShoppingGuestExtension.checkoutGuest(guestCase.Id, ' ', false, NULL,'', 'TEST');
            HandsFreeShoppingGuestExtension.updateShoppingItem(caseItem.Id, 'Guest Collected');
            HandsFreeShoppingGuestExtension.updateCaseScanBagCollection(bags[0].Barcode__c, guestCase.Id);
        Test.stopTest();

            System.assertNotEquals(null,
                HandsFreeShoppingGuestExtension.saveShoppingItem(villagePresenceName.Id, '1200', '3', '123456,false,123457,true,152635,false',
                                                                guestCase.Id, villagePresenceName.Name, 'Valet', true, false));
            System.assertEquals('success', HandsFreeShoppingGuestExtension.checkoutGuest(guestCase.Id, ' ', false, NULL,'','TEST'));
            System.assertEquals('success', HandsFreeShoppingGuestExtension.updateShoppingItem(caseItem.Id, 'Guest Collected'));
			System.assertEquals(true, HandsFreeShoppingGuestExtension.updateCaseScanBagCollection(bags[0].Barcode__c, guestCase.Id));

        }
    }

    static testMethod void guestExtensionTestN4(){
        setupData();

        Village__c villageName = [SELECT Name FROM Village__c WHERE Name = 'Bicester'];
        Village_Presence__c villagePresenceName = [SELECT Id, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
        Case guestCase = [SELECT ID, Service_Guest_Number__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            
            HandsFreeShoppingGuestExtension.goToGuestPage(guestCase.Service_Guest_Number__c);

        
        Test.stopTest();
            System.assertEquals(guestCase.Id, HandsFreeShoppingGuestExtension.goToGuestPage(guestCase.Service_Guest_Number__c));
        }
    }

    static testMethod void guestExtensionTestN5(){
        setupData();

        Village__c villageName = [SELECT Name FROM Village__c WHERE Name = 'Bicester'];
        Village_Presence__c villagePresenceName = [SELECT Id, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
        Case guestCase = [SELECT ID, Service_Guest_Number__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            HandsFreeShoppingGuestExtension.saveShoppingItem(villagePresenceName.Id, '1200', '3', '123456,false,123457,true,152635,false',
                                                            guestCase.Id, villagePresenceName.Name, 'Valet', true, false);

            List<HFS_Bag__c> bags = [SELECT ID, Barcode__c, Scanned_for_collection__c FROM HFS_Bag__c];
            bags[0].Scanned_for_collection__c = true;
            update bags[0];
            
            HandsFreeShoppingGuestExtension.GuestBagsCancel(guestCase.Id);
            System.assertEquals('success', HandsFreeShoppingGuestExtension.GuestBagsCancel(guestCase.Id));

        }
        Test.stopTest();
    }

    static testMethod void guestExtensionTestN6(){
        setupData();

        Village__c villageName = [SELECT Name FROM Village__c WHERE Name = 'Bicester'];
        Village_Presence__c villagePresenceName = [SELECT Id, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
        List<Case> guestCase = [SELECT ID, Service_Guest_Number__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            List<String> caseString = new List<String>();

            for(Case theCase : guestCase){
                caseString.add(theCase.Service_Guest_Number__c);
            }

            HandsFreeShoppingGuestExtension.searchGuestID(guestCase[0].Service_Guest_Number__c, villageName.Name);
            
        Test.stopTest();
            System.assertEquals(caseString, HandsFreeShoppingGuestExtension.searchGuestID(guestCase[0].Service_Guest_Number__c, villageName.Name));
        }
    }

    static testMethod void guestExtensionTestN7(){
        setupData();

        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){

            HFS_Collection_Point__c cp1 = new HFS_Collection_Point__c();
            cp1.Name = 'Bicester';
            cp1.Village__c = 'Bicester';
            insert cp1;

            HFS_Collection_Point__c cp2 = new HFS_Collection_Point__c();
            cp2.Name = 'Apartment';
            cp2.Village__c = 'Bicester';
            insert cp2;        

            HFS_Storage_Point__c sp1 = new HFS_Storage_Point__c();
            sp1.Name = 'Bicester';
            sp1.Village__c = 'Bicester';
            insert sp1;

            HFS_Storage_Point__c sp2 = new HFS_Storage_Point__c();
            sp2.Name = 'Apartment';
            sp2.Village__c = 'Bicester';
            insert sp2;    


            HFS_Relation_Collection_Storage__c rcs1 = new HFS_Relation_Collection_Storage__c();
            rcs1.HFS_Collection_Point__c = cp1.Id;
            rcs1.HFS_Storage_Point__c = sp1.Id;
            rcs1.Name = 'Bicester - Bicester';
            rcs1.Village__c = 'Bicester';
            insert rcs1;


            HFS_Relation_Collection_Storage__c rcs2 = new HFS_Relation_Collection_Storage__c();
            rcs2.HFS_Collection_Point__c = cp2.Id;
            rcs2.HFS_Storage_Point__c = sp2.Id;
            rcs2.Name = 'Apartment - Apartment';
            rcs2.Village__c = 'Bicester';
            insert rcs2;

            HandsFreeShoppingGuestExtension.getStorageLocationBool('Bicester', 'Apartment');
            

        
        Test.stopTest();
        System.assertEquals(false, HandsFreeShoppingGuestExtension.getStorageLocationBool('Bicester', 'Apartment'));
        }
    }

    static testMethod void guestExtensionTestN9(){
        setupData();

        Case guestCase = [SELECT ID, Service_Guest_Number__c,Client_QR_Code__c FROM Case WHERE Service_Guest_ID__c = '123456789'];


        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){

            HandsFreeShoppingGuestExtension.updateQRcode(guestCase.ID,'79879879');
                system.debug(guestCase.Client_QR_Code__c);
        Test.stopTest();

        Case getGuestCase = [SELECT ID, Service_Guest_Number__c,Client_QR_Code__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        System.assertEquals('79879879', getGuestCase.Client_QR_Code__c);
        }
    }

    static testMethod void guestExtensionTestN10(){
        setupData();
        String [] listOfBags = new List<String>();
        String bagRes;

        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){            
            listOfBags = HandsFreeShoppingGuestExtension.autoGenerate(1);
            bagRes=DateTime.now().format('yyyyMMddHHmmss');                    
        }
        Test.stopTest();  
        System.assertEquals('01',listOfBags[0].substring(14,16));    
	}
	
    static testMethod void testVIPsettings(){
        setupData();

		User us = [SELECT Id FROM User WHERE Alias = 'pal'];
		String guestId;
		String vipGuestId;
		HandsFreeShoppingGuestExtension hfsController;
		for (Account guest : [SELECT Id, RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName IN ('Guest', 'VIP_Guest')]) {
			if (guest.RecordType.DeveloperName == 'VIP_Guest') {
				vipGuestId = guest.Id;
			} else {
				guestId = guest.Id;
			}
		}
		Case hfsCase = [SELECT Id FROM Case WHERE Service_Guest_ID__c = '123456789'];

        Test.startTest();
        system.runAs(us){
			//Case1: No Guest Account
			ApexPages.StandardController sc = new ApexPages.StandardController(hfsCase);
			hfsController = new HandsFreeShoppingGuestExtension(sc);                  

			System.assertEquals(false, HandsFreeShoppingGuestExtension.isVIP);    
			System.assertEquals('Non-Privilege Guest', HandsFreeShoppingGuestExtension.privilegeType);

			//Case2: Standard Guest Account
			hfsCase.AccountId = guestId;
			update hfsCase;

			sc = new ApexPages.StandardController(hfsCase);
			hfsController = new HandsFreeShoppingGuestExtension(sc);                  

			System.assertEquals(false, HandsFreeShoppingGuestExtension.isVIP);    
			System.assertEquals('Privilege Guest', HandsFreeShoppingGuestExtension.privilegeType);

			//Case3: VIP Account
			hfsCase.AccountId = vipGuestId;
			update hfsCase;

			sc = new ApexPages.StandardController(hfsCase);
			hfsController = new HandsFreeShoppingGuestExtension(sc);                  

			System.assertEquals(true, HandsFreeShoppingGuestExtension.isVIP);    
			System.assertEquals('VIP Guest', HandsFreeShoppingGuestExtension.privilegeType);
		}
	    Test.stopTest(); 
    }


    /*
    static testMethod void guestExtensionTestN10(){ //Bag transfer
        setupData();

        Village__c villageName = [SELECT Name FROM Village__c WHERE Name = 'Bicester'];
        Village_Presence__c villagePresenceName = [SELECT Id, Name FROM Village_Presence__c WHERE Village__c = :villageName.Id];
        Case guestCase = [SELECT ID, HFS_Collection_Location__c FROM Case WHERE Service_Guest_ID__c = '123456789'];
        User us = [SELECT Id FROM User WHERE Alias = 'pal'];

        Test.startTest();
        system.runAs(us){
            HandsFreeShoppingGuestExtension.saveShoppingItem(villagePresenceName.Id, '1200', '3', '123456,false,123457,true,152635,false',
                                                            guestCase.Id, villagePresenceName.Name, 'Valet', true, false);

            Case_Item__c caseItem = [SELECT ID FROM Case_Item__c];
            List<HFS_Bag__c> bags = [SELECT ID, Barcode__c, Scanned_for_collection__c FROM HFS_Bag__c];
            bags[0].Scanned_for_collection__c = true;
            update bags[0];

            HandsFreeShoppingGuestExtension.checkoutGuest(guestCase.Id, ' ', false);
            HandsFreeShoppingGuestExtension.updateShoppingItem(caseItem.Id, 'Guest Collected');
            HandsFreeShoppingGuestExtension.updateCaseScanBagCollection(bags[0].Barcode__c, guestCase.Id);


            }
        Test.stopTest();
    }
*/



}