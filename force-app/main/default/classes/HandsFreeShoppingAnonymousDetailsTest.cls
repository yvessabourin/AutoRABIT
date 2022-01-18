@isTest
public class HandsFreeShoppingAnonymousDetailsTest {


    static void SetupData(){

            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
			vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert vill;

            Case guestCase = new Case();
            guestCase.Village__c = vill.Id;
            guestCase.Service_Guest_ID__c = '123456789';
            guestCase.Service_Guest_Number__c = 'XA1';
            guestCase.Guest_ID_Number_Part__c = 12;
            guestCase.Payment_Status__c = 'Paid';
            guestCase.Client_QR_Code__c = '123456789';
            guestCase.Status = 'New';
            guestCase.Origin = 'Email';
            guestCase.Service_Date__c = system.today() - 14;
            guestCase.CreatedDate = system.today() - 14;
            guestCase.Status = 'Closed';
            guestCase.SuppliedEmail = 'test@gmail.com';
            guestCase.SuppliedName = 'Julio';
            guestCase.SuppliedPhone = 'Cesar';
            insert guestCase;


    }

   
    static testMethod void executeTest(){

            setupData();
            

    		Test.startTest();

            system.schedule('testschedule', '0 56 11 * * ?', new HandsFreeShoppingAnonymousDetails());

    		Test.stopTest();

            Case guestCase = [SELECT SuppliedEmail,SuppliedName,SuppliedPhone FROM Case];
            
            System.assertEquals(null, guestCase.SuppliedEmail);
            System.assertEquals(null, guestCase.SuppliedName);
            System.assertEquals(null, guestCase.SuppliedPhone);


    }


}