@isTest
private class TourismPartnerProjectionsTest
{
    @TestSetup
    public static void SetupData(){
        
        // first create a village
        Village__c vill = TestDataGenerator.setupVillage(false);
        vill.Oracle_Source_Template_Number__c = '123456';
        vill.Oracle_Organisation__c = 'SourceOrg';
        vill.Name = 'Bicester';
		vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		vill.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert vill;

    
          Account testAccount = new Account(name = 'Test Account' , RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId);
          insert testAccount;

            Contact con1 = new contact(AccountId = testAccount.id, FirstName = 'Test1', LastName = 'Test1', email = 'test1@valueretail.com',Primary_Relationship_Contact__c = true);
            insert con1;
            
            String ThisYear = String.valueOf(date.today().year());

            Group_Source__c grpsrc = new Group_Source__c();
            grpsrc.Revenue_per_Visitor__c = 120.00;
            grpsrc.Source__c = 'Domestic Group';
            grpsrc.Village__c = vill.Id;
            insert grpsrc;

          // then we also need to add the Tourism Partner Projection
          Tourism_Partner_Projection__c TPP = new Tourism_Partner_Projection__c();
          TPP.Partnership_Account__c = testAccount.Id;
          TPP.Village__c = vill.Name;
          TPP.Projected_Year__c = ThisYear;
          TPP.Status__c = 'New';
          TPP.Group_or_Village_Projection__c = 'Group Projection';
          TPP.Visitor_Source__c = grpsrc.ID;
          insert TPP;

        id grpBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByDeveloperName.get('Group_Booking').RecordTypeId;
        id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByDeveloperName.get('Partnership_Promotion').RecordTypeId;
        
        //id promoRecordTypeId = Schema.SObjectType.Marketing_Activity__c.RecordTypeInfosByName.get('Village Partnership Promotion').RecordTypeId; 
        Map <String,Schema.RecordTypeInfo> recordTypesadjustment = Marketing_Campaign__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        //System.assertEquals(1,2,recordTypesadjustment);
        Id RecTypeIdinadj = recordTypesadjustment.get('Village_Campaign').getRecordTypeId();
        
        
        Marketing_Activity__c partnerPromo = null;
        Marketing_Campaign__c marketingCampaign = null;
        Group_Booking__c oneOffBooking = null;    
        Group_Booking__c individualsPartnership = null; 
        
        
        marketingCampaign = new Marketing_Campaign__c();
        marketingCampaign.Start_Date__c = system.today();
        marketingCampaign.End_Date__c = system.today().addDays(30);
        marketingCampaign.Name = 'Test Campaign';
        marketingCampaign.RecordTypeId = RecTypeIdinadj;
        marketingCampaign.Village__c = vill.Id;
		marketingCampaign.Campaign_Level__c = 'Theme';
        insert marketingCampaign;
        
        partnerPromo = new Marketing_Activity__c();
        partnerPromo.Start_Date__c = system.today();
        partnerPromo.End_Date__c = system.today().addDays(10);
        partnerPromo.Name = 'Test Village promo';
        partnerPromo.Marketing_Campaign__c = marketingCampaign.Id;
        partnerPromo.Partner__c = testAccount.Id;
        
        partnerPromo.recordTypeId = promoRecordTypeId;
        insert partnerPromo;          
        
        oneOffBooking = new Group_Booking__c();
        oneOffBooking.Name_of_Event__c= 'Test one off booking for TPP';
        oneOffBooking.recordTypeId = grpBookingRecordTypeId;
        oneOffBooking.Status__c = 'Confirmed';
        oneOffBooking.Village__c = vill.Id;
        oneOffBooking.Expected_Arrival__c = system.today();
        oneOffBooking.Expected_Departure__c = system.now();
        oneOffBooking.visitors_country_of_origin__c = 'China';
        oneOffBooking.expected_mode_of_transport__c = 'Train';
        oneOffBooking.group_type__c  ='Leisure';
        oneOffBooking.Organisation__c = testAccount.Id;
        insert oneOffBooking;
        
        // setup complete
    }
    
    @isTest
    static void checkVisitAppearsInTPP()
    {
        List<Group_Booking__c> groupBookings = [Select ID, Name FROM Group_Booking__c WHERE Name_of_Event__c = 'Test one off booking for TPP'];
        System.assert(groupBookings != null, 'groupBooking is null');
        System.assertEquals(groupBookings.Size(),1, 'groupBooking count is not 1');
        
        Group_Booking__c groupBooking = groupBookings[0];
        Test.StartTest();
        //  we should have a visit, we can edit it to make it 'check in', and this should calculate the Tourism Partner Projection
        Visit__c visit = [select Id from Visit__c where Group_Booking__c = :groupBooking.Id];
        System.assert(visit != null, 'Visit is null');
        
        // lets edit the visit to say that the people arrived
        DateTime CheckoutOn = System.Now().addHours(4);
        
        visit.Visit_Date_Time__c = System.Now();
        visit.Check_Out_Date_Time__c = CheckoutOn;
        visit.Number_of_Guests__c = 25;
        
        update visit;
        Test.StopTest();
        // this should trigger the updating process, and roll up the numbers
        // lets re-get the TPP and see if the number of guests have been updated...
        String ThisYear = String.valueOf(date.today().year());
        //String TPPName = 'Test Account' + ' for ' + ThisYear + ' for Bicester';
        Account act = [select id, name from Account WHERE name = 'Test Account'];
        
        //List<Tourism_Partner_Projection__c> TPProjections = [Select ID, Name,Total_Actual_Pax__c FROM Tourism_Partner_Projection__c WHERE Name = :TPPName] ;
        List<Tourism_Partner_Projection__c> TPProjections = [Select ID, Name,Total_Actual_Pax__c FROM Tourism_Partner_Projection__c WHERE Partnership_Account__c =:act.id] ;
        System.assert(TPProjections != null, 'TPProjections is null');
        System.assertEquals(1,TPProjections.Size(), 'TPProjections count is not 1');
        
        // now we need to see that the 'month' number has been incremented.....
        System.assertEquals(TPProjections[0].Total_Actual_Pax__c,25,'Total_Actual_Pax__c must be 25');
    }
    
}