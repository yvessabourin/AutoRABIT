public without sharing class DeleteVIPGuest {

  private final Account acc;
   private ApexPages.Standardcontroller stdCtrl;
    ApexPages.StandardSetController setCon;
   String errorMsg {get; set;}
    public Boolean HideConfirm {get; set;}
    public Boolean ShowComplete {get; set;}
  
   public DeleteVIPGuest(ApexPages.Standardcontroller std)
   {
      stdCtrl=std;
       this.acc = (Account)stdCtrl.getRecord(); 
   }

   public DeleteVIPGuest(ApexPages.StandardSetController controller){

      setCon=controller;
   
   }

   public DeleteVIPGuest(ID accID){

    acc = [Select ID, Name FROM Account WHERE ID = :accID ];
    stdCtrl = new ApexPages.Standardcontroller(acc);
   }

public String DeleteGuestAndCreateRecord(Account accrec){
    String message = '';
    System.debug('About to delete guest: ' +  accrec);
    try
    {
        Deleted_Record__c delrec = new Deleted_Record__c();

        delrec.Object_Type__c = 'VIP Guest';
        delrec.Object_ID__c = String.ValueOf(acc.ID);
        delrec.Delete_Reason__c = 'User Delete';
        delrec.Deleted_By_User__c = UserInfo.getUserId();
        delrec.Record_Name__c = acc.Name;

        insert delrec;

        delete acc;   
        HideConfirm = true;
        ShowComplete = true;
        message = 'Guest details deleted.';
       

    }
    catch(Exception e){
        message = 'ERROR: Failed to delete record. please contact an administrator. - Technical Details: ' + e.getMessage();
    }
    return message;
}

   public void DeleteVIPGuestRecord()
   {
        if(acc != null){    
            // lets create the delete record, and then if that saves correctly, then we delete the VIP guest.
            String result = DeleteGuestAndCreateRecord(acc);
            if(result.startsWith('ERROR')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, result));
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,result));
            }
        }
        else  if(setCon != null){
            List<Account> allaccs = (Account[])setCon.getSelected();
            List<Deleted_Record__c> delrecs = new List<Deleted_Record__c>();
            try
            {
                for(Account acc : allaccs){
                    Deleted_Record__c delrec = new Deleted_Record__c();

                    delrec.Object_Type__c = 'VIP Guest';
                    delrec.Object_ID__c = String.ValueOf(acc.ID);
                    delrec.Delete_Reason__c = 'User Delete';
                    delrec.Deleted_By_User__c = UserInfo.getUserId();
                    delrec.Record_Name__c = acc.Name;
                    delrecs.add(delrec);
                }
                insert delrecs;
                delete allaccs;
                HideConfirm = true;
                ShowComplete = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All Guest details deleted.'));
            }
            catch(Exception e){
                errorMsg = 'Failed to delete records. please contact an andministrator. - Technical Details: ' + e.getMessage();
            }

            if(errorMsg != null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR: ' + errorMsg));
            }
        }
      
   }

    public PageReference ReturnBack()
   {
    PageReference returnPage = new PageReference('/001');  
    return returnPage;
   }


}