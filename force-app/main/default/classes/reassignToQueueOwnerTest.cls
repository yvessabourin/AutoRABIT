@isTest
global class reassignToQueueOwnerTest{

        private static testMethod void Test1() {
 
        
        list <reassignToQueueOwner.leadDetails> detailList = new list<reassignToQueueOwner.leadDetails>();    
        reassignToQueueOwner.leadDetails detail = new reassignToQueueOwner.leadDetails();
                
                Recordtype myRec = [SELECT id FROM RecordType WHERE name = 'Group Booking Lead' AND sobjectType = 'Lead'];
                               
                Lead L = new Lead();
                L.recordtypeid = myRec.id;
                L.company = 'test Lead';
                L.Group_Type__c = 'MICE';
                L.FirstName = 'test';
                L.LastName = 'user';
                L.email = 'dchilds@valueretail.com';
                L.phone = '0987654321';
                L.Name_Of_Event__c = 'Test Event';
                L.Village_of_Visit_c__c = 'Bicester';
                L.Expected_Arrival__c = system.now();
                L.Expected_Departure__c = system.now()+1;
                L.Number_of_Visitors__c = 10;
                L.Quick_Convert__c = true;
                insert L;
                
                detail.Leadid = L.id;
                detail.PrimaryVillageofInterest = L.Village_of_Visit_c__c;
                detail.leadGroupType = L.Group_Type__c;
            
                detailList.add(detail);
 
                Test.startTest();
                reassignToQueueOwner.reassignOwner(detailList);
                Test.stopTest();                
                
                Group Grp = [Select Id,Name from Group where type='Queue' and Name = 'MICE Lead Queue - Bicester' LIMIT 1];
                Lead lead = [SELECT id,name,ownerid FROM Lead WHERE Id =:L.id];
                
                system.assert(lead.ownerid == Grp.id, 'wrong');
            }             
}