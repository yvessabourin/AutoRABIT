@isTest
public class RedeemableCampaignWizardControllerTest{

//properties
Private Static Campaign multiChannelCampaign = new Campaign(); 
Private Static Campaign singleChannelCampaign = new Campaign();
Private Static Campaign DuplicateRedeemableCampaign = new Campaign();
    
private static string village = 'Test Village'; 
private static village__c testvillage = new village__c();
private static id GroupCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Group Campaign').getRecordTypeId();
private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();    
private static integer countOfPromotions;
  
    
    public static testMethod void multiChannelCampaignTest()
    {
        //setup test data
        setupdata(false);
        
        PageReference pg = new PageReference('Page.RedeemableCampaignWizard');
            pg.getParameters().put('id', multiChannelCampaign.Id);
            test.setCurrentPageReference(pg);

        test.startTest();
            RedeemableCampaignWizardController controller = new RedeemableCampaignWizardController();
            controller.SubmitCampaigns();
        test.stopTest();
        
        //Asserts
        //There should be just one campaign inserted as there 
        //is one village and it's a multi-channel campaign
         list<campaign> insertedCampaigns = [SELECT id, Contact_Details_Required__c, parent_campaign_id__c
                                            FROM Campaign 
                                            WHERE RecordTypeId = :RedeemableCampRecordTypeId];
        system.assertEquals(1, insertedCampaigns.size() );
        
        //contact details should NOT be required for this multi channel campaign
        system.assertEquals(false , insertedCampaigns[0].Contact_Details_Required__c);
        
    }
    
    public static testMethod void singleChannelCampaignTest()
    {
        //setup test data
        setupdata(false);
        
        PageReference pg = new PageReference('Page.RedeemableCampaignWizard');
            pg.getParameters().put('id', singleChannelCampaign.Id);
            test.setCurrentPageReference(pg);

        test.startTest();
            RedeemableCampaignWizardController controller = new RedeemableCampaignWizardController();
        
            controller.getGroupCampaignName();
            controller.SubmitCampaigns();
            controller.getCampaigns();

        test.stopTest();
        //Asserts
        //There should be two campaigns inserted as there 
        //is one village but it's a single-channel campaign
        list<campaign> insertedCampaigns = [SELECT id, Contact_Details_Required__c, parent_campaign_id__c
                                            FROM Campaign 
                                            WHERE RecordTypeId = :RedeemableCampRecordTypeId];
        system.assertEquals(2, insertedCampaigns.size() );
        
        //contact details should be required
         system.assertEquals(true , insertedCampaigns[0].Contact_Details_Required__c);
        
        //it's also a multi-village campaign so make sure the parent Id is populated
        //so that it is SOSL searchable.
        system.assertEquals(singleChannelCampaign.Id , insertedCampaigns[0].parent_campaign_id__c ); 
        
        //tack on this additional test
        controller.Cancel2();
    }
    
 
     public static testMethod void singleChannelCampaignTest2() // non UI context
    {
        //setup test data
        setupdata(false);

        test.startTest();
            RedeemableCampaignWizardController controller = new RedeemableCampaignWizardController(singleChannelCampaign.Id);
        
            controller.getGroupCampaignName();
            controller.SubmitCampaigns();
            controller.getCampaigns();

        test.stopTest();
        //Asserts
        //There should be two campaigns inserted as there 
        //is one village but it's a single-channel campaign
        list<campaign> insertedCampaigns = [SELECT id, Contact_Details_Required__c, parent_campaign_id__c
                                            FROM Campaign 
                                            WHERE RecordTypeId = :RedeemableCampRecordTypeId];
        system.assertEquals(2, insertedCampaigns.size() );
        
        //contact details should be required
         system.assertEquals(true , insertedCampaigns[0].Contact_Details_Required__c);
        
        //it's also a multi-village campaign so make sure the parent Id is populated
        //so that it is SOSL searchable.
        system.assertEquals(singleChannelCampaign.Id , insertedCampaigns[0].parent_campaign_id__c ); 
        
        //tack on this additional test
        controller.Cancel2();
    }
       
    
    
    
 ////////////////////////data setup/////////////////////////////   
        static void setupdata(boolean createduplicate)
    {
        //Setup new test Village
        testvillage.Name = village;
        testvillage.Village_Code__c = 'TV';
		testvillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		testvillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert testvillage;
                      
        //new multi channel Group campaign  
        multiChannelCampaign.Contact_Details_Required__c = false;
        multiChannelCampaign.Name = 'My Test Group Campaign';
        multiChannelCampaign.Communication_Channel__c = 'Email;SMS';
        multiChannelCampaign.Status = 'In Progress' ;
        multiChannelCampaign.isActive = true;
        multiChannelCampaign.Villages__c = village;
        multiChannelCampaign.description = 'This is my test Group campaign description';
        multiChannelCampaign.startdate = Date.today();
        multiChannelCampaign.enddate = Date.today()+3;
        multiChannelCampaign.RecordTypeId = GroupCampRecordTypeId;
        multiChannelCampaign.Multi_Channel_Campaign__c = true;
        multiChannelCampaign.Multi_Village_Campaign__c = false;
        insert multiChannelCampaign;
        
        //new single channel Group campaign   
        singleChannelCampaign.Contact_Details_Required__c = true;
        singleChannelCampaign.Name = 'My Test Group Campaign';
        singleChannelCampaign.Communication_Channel__c = 'Email;SMS';
        singleChannelCampaign.Status = 'In Progress' ;
        singleChannelCampaign.isActive = true;
        singleChannelCampaign.Villages__c = village;
        singleChannelCampaign.description = 'This is my test Group campaign description';
        singleChannelCampaign.startdate = Date.today();
        singleChannelCampaign.enddate = Date.today()+3;
        singleChannelCampaign.RecordTypeId = GroupCampRecordTypeId;
        singleChannelCampaign.Multi_Channel_Campaign__c = false;
        singleChannelCampaign.Multi_Village_Campaign__c = true;
        insert singleChannelCampaign;
        
         if (createduplicate)
        {
            DuplicateRedeemableCampaign.Contact_Details_Required__c = true;
            DuplicateRedeemableCampaign.Name = 'My Test RedeemableCampaign';
            DuplicateRedeemableCampaign.Communication_Channel__c = 'Email';
            //DuplicateRedeemableCampaign.Status = 'In Progress' ;
            //DuplicateRedeemableCampaign.isActive = true;
            DuplicateRedeemableCampaign.Village__c = testvillage.id;
            DuplicateRedeemableCampaign.description = 'This is my test Group campaign description';
            DuplicateRedeemableCampaign.startdate = Date.today();
            DuplicateRedeemableCampaign.enddate = Date.today()+3;
            DuplicateRedeemableCampaign.RecordTypeId = RedeemableCampRecordTypeId;
            DuplicateRedeemableCampaign.ParentID = singleChannelCampaign.id;
            
            insert DuplicateRedeemableCampaign;
        
        }
        
    }
    
    
    
}