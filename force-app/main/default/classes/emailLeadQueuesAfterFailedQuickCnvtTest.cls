@isTest
global class emailLeadQueuesAfterFailedQuickCnvtTest{

        private static testMethod void Test1() {
 
        
        list <emailLeadQueuesAfterFailedQuickConvert.sendEmailDetails> listofdetails = new list<emailLeadQueuesAfterFailedQuickConvert.sendEmailDetails>();    
        emailLeadQueuesAfterFailedQuickConvert.sendEmailDetails detail = new emailLeadQueuesAfterFailedQuickConvert.sendEmailDetails();
                
                Recordtype myRec = [SELECT id FROM RecordType WHERE name = 'Group Booking Lead' AND sobjectType = 'Lead'];
                               
                Lead L = new Lead();
                L.recordtypeid = myRec.id;
                L.company = 'test Lead';
                L.FirstName = 'test';
                L.LastName = 'user';
                L.email = 'dchilds@test.com';
                L.phone = '0987654321';
                L.Group_Type__c = 'MICE';
                L.Name_Of_Event__c = 'Test Event';
                L.Village_of_Visit_c__c = 'Bicester';
                L.Expected_Arrival__c = system.now();
                L.Expected_Departure__c = system.now()+1;
                L.Number_of_Visitors__c = 10;
                L.Visitors_Country_of_Origin__c = 'Visitors_Country_of_Origin__c';
                L.Quick_Convert__c = true;
                insert L;
            
                detail.Leadid = L.id;
                detail.PrimaryVillageofInterest = L.Village_of_Visit_c__c;
            
                listofdetails.add(detail);
 
                Test.startTest();
                emailLeadQueuesAfterFailedQuickConvert.id(listofdetails);
                Test.stopTest();                
                
            }             
}