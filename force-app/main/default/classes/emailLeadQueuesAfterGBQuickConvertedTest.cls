@isTest
global class emailLeadQueuesAfterGBQuickConvertedTest{

        private static Account account = new Account();
        private static Village__c village3 = new Village__c();
        private static Opportunity opp = new Opportunity();
        private static Group grp = new Group();
        private static Contact con = new Contact();
        private static Group_Booking__c GB = new Group_Booking__c();

        static void setupData(){
        
        account = TestData_Account.setupTourismAccount(1, true);
        con = TestData_Contact.setupTourismContact('A',account,true);
                  
             //create village 1
             
             village3.Name = 'TestVillage1';     
             village3.Village_Code__c = 'AA';
			 village3.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			 village3.CertSales_Report_Sales_Grace_Period_Days__c = 1;
             insert village3;
             village3 = [select name, id, Village_Code__c from Village__c where Village_Code__c = 'AA' LIMIT 1];  
             
             Recordtype myRec = [SELECT id FROM RecordType WHERE name = 'Group Booking' AND sobjectType = 'Group_Booking__c'];
                system.debug('myrec ' + myRec);
                               
                
                GB.recordtypeid = myRec.id;
                GB.village__c = village3.id;
                GB.Name_of_Event__c = 'TEST GB';
                GB.Organisation__c = account.id;
                GB.Group_Type__c = 'MICE';
                GB.Status__c = 'Proposed';
                GB.Group_Booking_Source__c = 'External MICE Form';
                GB.Expected_Arrival__c = system.now();
                GB.Visitors_Country_of_Origin__c = 'united Kingdom';
                GB.Expected_Departure__c = system.now()+1;
                GB.Contact__c = con.id;
                GB.Number_of_Visitors_Expected__c = 10;
                //GB.Was_Quick_Converted2__c = true;   
                system.debug('myGB1 ' + GB);        
            
                insert GB;     
                system.debug('myGB2 ' + GB);   
                
                Group_Booking__c GB2 = [SELECT Id,Was_Quick_Converted__c FROM Group_Booking__c WHERE Id =: GB.id];
                GB2.Was_Quick_Converted__c = true;
                update GB2;
                   
            }


        private static testMethod void Test1() {
 
        setupData();
        
        list <emailLeadQueuesAfterGBQuickConverted.sendEmailDetails> listofdetails = new list<emailLeadQueuesAfterGBQuickConverted.sendEmailDetails>();    
        emailLeadQueuesAfterGBQuickConverted.sendEmailDetails detail = new emailLeadQueuesAfterGBQuickConverted.sendEmailDetails();
                
                
                
                
                detail.GBId = GB.id;
                detail.PrimaryVillageofInterest = 'Bicester';
                system.debug('thisdetail ' + detail);
            
                listofdetails.add(detail);
                system.debug('thislistdetail ' + listofdetails);
 
                Test.startTest();
                emailLeadQueuesAfterGBQuickConverted.sendEmail(listofdetails);
                Test.stopTest();                
                
            }             
}