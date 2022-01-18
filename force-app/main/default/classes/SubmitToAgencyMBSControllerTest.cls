@isTest(SeeAllData=true)
public class SubmitToAgencyMBSControllerTest {
    
    @isTest
    static void TestEmailMasterBudgetSheet(){
         
        SubmitToAgencyMBSControllerUtility.testSetup();

        Master_Budget_Sheet__c newMBS = [SELECT Id, Name, Creative_Agency_1__c, Creative_Agency_2__c, Creative_Agency_3__c, 
                                        Creative_Agency_4__c, Creative_Agency_5__c, Creative_Agency_6__c, 
                                        Creative_Agency_7__c, Creative_Agency_8__c, Budget_Village__c 
                                        FROM Master_Budget_Sheet__c WHERE Name = 'MBS Test' LIMIT 1];
        
        Test.startTest();
        PageReference pageRef = Page.SubmitToAgencyMasterBudgetSheet;
        Test.setCurrentPage(pageRef);
          
        String newMBSId = newMBS.id;
        Master_Budget_Sheet__c mbs = [SELECT Id, Name, Creative_Agency_1__c, Budget_Village__c FROM Master_Budget_Sheet__c where id=:newMBSId];
        
        ApexPages.currentPage().getParameters().put('id',newMBSId);
        ApexPages.StandardController con = new ApexPages.StandardController(mbs);
        SubmitToAgencyMBSController controller = new SubmitToAgencyMBSController(con);
       
        try{
            controller.sendEmailToUsers(newMBS);  
            controller.shareRecordWithUsers(newMBS); 
        }catch(Exception e){
            system.debug(e);
            System.assert(String.isBlank(String.valueOf(e)));
        }
        Test.stopTest();
    }
}