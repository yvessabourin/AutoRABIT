@isTest
public class MultiAddRedemptionsControllerTest{

Private Static Campaign multiChannelCampaign = new Campaign(); 
private static string village = 'Test Village'; 
private static village__c testvillage = new village__c();
private static Account TourismAccount = new Account();

//Private Static Account GuestContact = new Account();
Private Static b2c_customer__c GuestContact = new b2c_customer__c();
    
private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
//private static id GuestRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Guest').getRecordTypeId();
    
     public static testMethod void testReset() 
    { 
        setupdata();
        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        test.setCurrentPageReference(pg);
        
        test.startTest();
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();
        	//addsome records before the reset      
            controller.setmultiVouchers('14xxxxxxxxxxxx;14xxxxxxxxxxyy');
            controller.MultiAdd();
        	//check that where are two items in the TORlist
        	system.assertEquals(controller.TORList.size(), 2);
        	//this is what we are testing - after reset the list should be null(0)
        	controller.reset();
        test.stopTest();
        //After a reset the TORlist size should be 0
        system.assertEquals(controller.TORList.size(), 0);
    }
    
    public static testMethod void TestAddwithBadCode() 
    {
        setupdata();
        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();
            //TODO
            controller.setmultiVouchers('14xxxxxxxxxxxx;14xxxxxxxxxxyy');
            controller.MultiAdd();
            //manually add a  bad code (replicating a user typing something directly in the list
            controller.TORList.add(New Promotion_Redemption__c(Redeemable_Campaign__c = multiChannelCampaign.Id, Redeem_Date__c = system.today() , Voucher_Code__c = 'invalid', customer__c = null));
            controller.add();
        	//check the TORlist has 3 records - 2 good, one bad
        	system.assertEquals(controller.TORList.size(), 3);
            //first quicksave (validate) should remove bogus code
        	controller.quicksave();
        	//After the first quicksave(validate) the TORlist size should now be 2
        	system.assertEquals(controller.TORList.size(), 2);
        	//and a user msg should be setup.
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:msgs)
            {
                if (msg.getDetail().contains('Some codes were removed')) b = true;
            }
            system.assert(b);
        
            //second quicksave (validate) should all validate sucessfully.
            controller.quicksave();
        	//After the second quicksave(validate) the TORlist size should still be 2
        	system.assertEquals(controller.TORList.size(), 2);
        
        test.stopTest();
    }
    
    public static testMethod void testGuestPopulation() 
    {
        setupdata();
        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();       
            //manually add a  bad code (replicating a user typing something directly in the list
            controller.TORList.add(New Promotion_Redemption__c(Redeemable_Campaign__c = multiChannelCampaign.Id, Redeem_Date__c = system.today() , Voucher_Code__c = 'invalid', customer__c = guestContact.Id));
            controller.rowIndex = 0;
            controller.updateContactFields();
        test.stopTest();
        
        //ensure the guest email address is populated from the person accoout lookup.
        system.assertEquals('guest@guest.com', controller.TORList[0].Guest_Email__c);
    }
    
    public static testMethod void testInValidCampaignIdinURL() 
    {
        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', '701110000001bad'); 
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();
        test.stopTest();
        
        //there should not be an error and the redeemableCampaign should be null
        system.assertEquals(Null, controller.RedeemableCampaign);   
    }
    
    public static testMethod void Cancel() 
    {
        setupdata();
        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();
            controller.cancel();
        test.stopTest(); 
        //no asserts - we're just cancelling the request and dedirecting the user 
    }
    
    public static testMethod void testredemptionWithBadCode() 
    {
        setupdata();
        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();
    
            controller.setmultiVouchers('14xxxxxxxxxxxx;ddd');
        	//Ensure the getmultivouchers returns our entire input string
            system.assertEquals(controller.getmultiVouchers(),'14xxxxxxxxxxxx;ddd');
            
            controller.MultiAdd();
        	
            //ensure the multiadd function strips out the invalid ID and adds 
        	//just one record to the TROList
            system.assertEquals(controller.getTORs().size() ,1);
            
        	//We didn't set the contact details required on the campaign
        	//so  ensure they are indeed not required
            system.assertEquals(controller.getContactDetailsRequired(), false);
            
            //add a  bad vouchercode - inline
            controller.add();
           //controller.TORList.add(New Promotion_Redemption__c(Redeemable_Campaign__c = multiChannelCampaign.Id, Redeem_Date__c = system.today() , Voucher_Code__c = 'badcode'));         
            controller.save();
        test.stopTest();
        
        //ensure the badcodes string has captured the bad code (to display on screen)
        //badcode = 'badcode' Length = 7
        //n.b. Can't test the length of badcodes as it is reset after use. Assert == 0
        system.assertEquals(0, controller.badCodes.length());
    }
    
    
    public static testMethod void testRedemptionNoBadCodes() 
    {
        setupdata();

        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();  
            controller.setmultiVouchers('14xxxxxxxxxxxx');
            controller.MultiAdd();
            system.assertEquals(controller.getTORs().size() ,1);         
            controller.save();
        test.stopTest();
        
        //ensure there are no bad codes reported
        system.assertEquals(0, controller.badCodes.length());
    }

	public static testMethod void testQuickRedemption() 
    {
        setupdata();

        PageReference pg = new PageReference('Page.MultiAddRedemptions');
        pg.getParameters().put('id', multiChannelCampaign.id); 
        pg.getParameters().put('redeemCode', '00000000000001');
        pg.getParameters().put('addCustomer', 'true');
         
        test.setCurrentPageReference(pg);
        
        test.startTest();   
            MultiAddRedemptionsController controller = new MultiAddRedemptionsController();  
            system.assertEquals(controller.getTORs().size() ,1);         
            controller.save();
        test.stopTest();
        
        //ensure there are no bad codes reported
        system.assertEquals(0, controller.badCodes.length());
    }


/////////////////////DATA setup///////////////////////
    static void setupdata()
    {
        
        //Setup new test Village
        //TO-DO - convert to generic object creation
        testvillage.Name = village;
        testvillage.Village_Code__c = 'TV';
		testvillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		testvillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert testvillage;
        
        //Setup Partner
       TourismAccount = TestData_Account.setupTourismAccount(1,true);
        
        //setup b2c customer Contact
        //GuestContact.RecordTypeId = GuestRecordTypeId;
        GuestContact.FirstName__c = 'GuestFN';
        guestContact.LastName__c = 'GuestLN';
        guestcontact.Email__c = 'guest@guest.com';
        
        insert guestContact;
        system.debug('@@@Test GUEST ID: ' + guestcontact.id);
               
        //new redeemable campaign    
        multiChannelCampaign.Name = 'My Test Group Campaign';
        multiChannelCampaign.Communication_Channel__c = 'Email';
        multiChannelCampaign.Status = 'In Progress' ;
        multiChannelCampaign.isActive = true ;
        multiChannelCampaign.Village__c = testvillage.id;
        multiChannelCampaign.Partner__c = TourismAccount.id;
        multiChannelCampaign.description = 'This is my test campaign';
        multiChannelCampaign.startdate = Date.today();
        multiChannelCampaign.enddate = Date.today()+3;
        multiChannelCampaign.RecordTypeId = RedeemableCampRecordTypeId;
        
        insert multiChannelCampaign;
    
    }
    
}