@isTest
public class ParentAccountEventsControllerTest {

//properties
Private Static String mystring;
Private Static account groupAccount;
Private Static account brandAccount;
     
    public static testMethod void MainTest()
    {
            //setup test data      
            setupdata();           
 
            ApexPages.StandardController sc = new ApexPages.standardController(brandAccount);    
            ParentAccountEventsController extensionController = new ParentAccountEventsController(sc);
    
            test.startTest();  
                //now we can test methods by calling controller.
                list<event> returnedEvents = extensionController.getParentEvents();
                boolean Eventspresent = extensionController.getdisplayresults();  
            test.stopTest();
            
            //now we assert the results
            system.assertEquals(1, returnedEvents.size());
            system.assertEquals(true, Eventspresent);          
    }
    
    //ensure the VF elements are not displayed when there is no parent on the account.
     public static testMethod void NoParentTest()
    {
            //setup test data      
            setupdata();           
             
            ApexPages.StandardController sc = new ApexPages.standardController(groupAccount);    
            ParentAccountEventsController extensionController = new ParentAccountEventsController(sc);
    
            test.startTest();  
                //now we can test methods by calling controller.
                boolean Eventspresent = extensionController.getdisplayresults(); 
            test.stopTest();
            
            //now we assert the results
            system.assertEquals(false, Eventspresent);         
    }
    
     
     
    static void setupdata()
    {       
        //Create Parent(group) Account 
        groupAccount = TestData_Account.setupGroupAccount(1, true);
        
        //Create Event for Parent Account 
        id B2BEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('B2B meeting').getRecordTypeId();
        Event GroupEvent = new Event(subject = 'Test Subject', RecordTypeId = B2BEventRecordTypeId,
                                     whatid = groupAccount.id, 
                                     StartDateTime = datetime.now(),
                                     EndDateTime = datetime.now() + 1
                                     );
        insert GroupEvent;

        //Create Brand Account
        brandAccount = TestData_Account.setupBrandAccount(1, false);
        brandAccount.parentid = groupAccount.Id;
        Insert brandAccount;   
            
    }    
    
    
    
}