@Istest
Public Class obfuscationClassTest{

	private static Account acnt = new Account();
	private static Contact cnt = new Contact();
	private static Group_Booking__c grp = new Group_Booking__c();
	private static emailmessage email = new emailmessage();

	static testMethod void testMethod1(){

		setupdata();
        
        Test.startTest();

            map<String, list<String>> theObjectFieldMap = new map<String, list<String>>();
			list<string> theGBFields = new list<string>{'Coach_Tour_Company_Name__c','Coach_Tour_Contact_Email__c','Coach_Tour_Phone__c','Contact_Number__c','Contact__c','Secondary_MICE_Contact_Email__c','Secondary_MICE_Contact_First_Name__c','Secondary_MICE_Contact_Last_Name__c','Secondary_MICE_Contact_Phone__c','Tour_Leader_Driver_Contact__c','Tour_Leader_or_Driver_Name__c','Primary_Contacts_Secondary_Email__c'};
			theObjectFieldMap.put('Group_Booking__c', theGBFields);
			obfuscationClass myBatchObject = new obfuscationClass(theObjectFieldMap, null); 
			Id batchId = Database.executeBatch(myBatchObject, 200);

        Test.stopTest();
    }


    static testMethod void testMethod2(){

		setupdata();
        
        Test.startTest();

        	list<Recordtype> RTIDs = [SELECT Id, Name from Recordtype where sobjecttype = 'account' AND (Name = 'guest' OR Name = 'VIP Guest')];
			list<string> ids = new list<string>();
			for(Recordtype rec : RTIDs){
			    ids.add(rec.id);    
			}
			map<String, list<String>> theObjectFieldMap = new map<String, list<String>>();
			list<string> theAccountFields = new list<string>{'LastName','FirstName','Phone','PersonMobilePhone','PersonAssistantPhone','PersonEmail','PersonAssistantName','PersonBirthdate','Account_Manager__c','Phone_2__c','Account_Email__c','Brand_Advocate__c','China_Brand_Captain__c','EU_Brand_Captain__c','GRS_Captain__c','Marketing_Captain__c'};
			theObjectFieldMap.put('Account', theAccountFields);
			obfuscationClass myBatchObject = new obfuscationClass(theObjectFieldMap, ids); 
			Id batchId = Database.executeBatch(myBatchObject, 200);
            
        Test.stopTest();
    }

    static testMethod void testMethod3(){

		setupdata();
        
        Test.startTest();

        	map<String, list<String>> theObjectFieldMap = new map<String, list<String>>();
			list<string> theEmailsFields = new list<string>{'BccAddress','CcAddress','FromAddress','FromName','ToAddress'};
			theObjectFieldMap.put('EmailMessage', theEmailsFields);
			obfuscationClass myBatchObject = new obfuscationClass(theObjectFieldMap, NULL); 
			Id batchId = Database.executeBatch(myBatchObject, 200);
     
        Test.stopTest();
    }





    static void setupdata(){

    	recordtype acntRecType = [SELECT id, name from Recordtype WHERE sObjectType = 'Account' AND DeveloperName = 'Tourism'];
    	recordtype conRecType = [SELECT id, name from Recordtype WHERE sObjectType = 'Contact' AND name = 'Tourism Contact'];

    	acnt = new account();
    	acnt.recordtypeid = acntRecType.id;
    	acnt.Name = 'TEST Partner';
    	acnt.Type_of_Business__c = 'Airline';
    	insert acnt;

    	cnt = new contact();
    	cnt.LastName = 'test';
    	cnt.AccountId = acnt.id;
    	cnt.Phone = '546456456';
        cnt.Email = 'testuser@valueretail.com';
    	insert cnt;	
   
		list<Village__c> VilsToInsert = new list<Village__c>();

		Village__c Bicestervillage = new Village__c();
		Bicestervillage.Name = 'Bicester Village';     
		Bicestervillage.Village_Code__c = 'BV';
		Bicestervillage.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		Bicestervillage.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
		VilsToInsert.add(Bicestervillage);

		insert VilsToInsert;

		recordType rtid = [SELECT id, name FROM RecordType WHERE sobjecttype = 'Group_Booking__c' AND Name = 'Group Booking'];
		id villid = [SELECT Id, Name FROM Village__c WHERE NAME = 'Bicester Village'].id;

        List<Group_Booking__c> grpBookings= new List<Group_Booking__c>();
        for(Integer i=0 ;i <20;i++)
        {
            Group_Booking__c grp = new Group_Booking__c();
            grp.recordtypeid =rtid.id;
            grp.Village__c = villid;
            grp.Visitors_Country_of_Origin__c = 'Belgium';
            grp.Expected_Arrival__c = system.now();
            grp.Expected_Departure__c = system.now() + 10;
            grp.Number_of_Visitors_Expected__c = 20;
            grp.Group_Type__c = 'MICE';
            grp.Group_Booking_Source__c = 'Salesforce Front End';
            grp.Status__c = 'proposed';
            grp.Name_of_Event__c = 'test' + i;
            grp.Coach_Tour_Company_Name__c = 'The Coach Party';
            grp.Coach_Tour_Contact_Email__c = 'test@test.com';
            grp.Coach_Tour_Phone__c = '9876543210';
            grp.Contact_Number__c = '456789456789';
            grp.Secondary_MICE_Contact_Email__c = 'Secondary@test.com';
            grp.Secondary_MICE_Contact_First_Name__c = 'Luke';
            grp.Secondary_MICE_Contact_Last_Name__c = 'Skywalker';
            grp.Secondary_MICE_Contact_Phone__c = '0012384589';
            grp.Tour_Leader_Driver_Contact__c = 'Darth vader';
            grp.Tour_Leader_or_Driver_Name__c = 'Anakin Skywalker';
            grp.Primary_Contacts_Secondary_Email__c = 'Anny@takeovertheuniverse.com';
            grp.Contact__c = cnt.id;
            grp.Organisation__c = acnt.id;
            grpBookings.add(grp);
            i ++;
        }
        
        insert grpBookings;


        email = new emailmessage();
        email.FromAddress = 'traveltrade@chicoutletshopping.com';
        email.FromName = 'Chic Outlet Shopping';
        email.ToAddress = 'dmoirc@hotmail.com';
        email.Subject = 'test';
        email.TextBody = 'test';
        insert email;

  	}

}