public class SubmitToAgencyMBSController {

    Private Final Master_Budget_Sheet__c mbs;
    
    public SubmitToAgencyMBSController(ApexPages.StandardController stdController){
        
        this.mbs = (Master_Budget_Sheet__c)stdController.getRecord(); 
        
    }
    
    /**
     *  Submit to agency actions regarding the users that are on creative agency fields:
     * 1. Send email to that list of users
     * 2. Share the record with that list of the users
     */
    public pageReference SubmitToAgencyMBS(){
        String theId = ApexPages.currentPage().getParameters().get('id');
        Master_Budget_Sheet__c mbs = [select Id, Name, Creative_Agency_1__c,Creative_Agency_2__c,Creative_Agency_3__c, Creative_Agency_4__c,
                                      Creative_Agency_5__c, Creative_Agency_6__c, Creative_Agency_7__c, Creative_Agency_8__c, Budget_Village__c
                                      from Master_Budget_Sheet__c 
                                      where Id=:theId];
         
        sendEmailToUsers(mbs);
        
        shareRecordWithUsers(mbs);
           
        PageReference pageRef = new PageReference ('/' + theId);
        pageRef.setRedirect(true);
        
    
        return pageRef;        
    }   
    
    public void sendEmailToUsers(Master_Budget_Sheet__c mbs){
        List<Messaging.SingleEmailMessage> allMessag = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
		Village__c bv;
        
        if(mbs.Budget_Village__c!=null){
        	bv = [select Id, Name from Village__c where Id =:mbs.Budget_Village__c];
    	}
        
        if(mbs.Creative_Agency_1__c != null){ 
            sendTo.add(mbs.Creative_Agency_1__c);  
        }

        if(mbs.Creative_Agency_2__c != null){ 
            sendTo.add(mbs.Creative_Agency_2__c);  
        }

        if(mbs.Creative_Agency_3__c != null){ 
            sendTo.add(mbs.Creative_Agency_3__c);  
        }

        if(mbs.Creative_Agency_4__c != null){ 
            sendTo.add(mbs.Creative_Agency_4__c);  
        }
        
        if(mbs.Creative_Agency_5__c != null){ 
            sendTo.add(mbs.Creative_Agency_5__c);  
        }
        
        if(mbs.Creative_Agency_6__c != null){ 
            sendTo.add(mbs.Creative_Agency_6__c);  
        }
        
        if(mbs.Creative_Agency_7__c != null){ 
            sendTo.add(mbs.Creative_Agency_7__c);  
        }
        
        if(mbs.Creative_Agency_8__c != null){ 
            sendTo.add(mbs.Creative_Agency_8__c);  
        }

        if(sendTo.size() != 0 && sendTo != NULL){
            
            Network myNetwork = [SELECT Id FROM Network WHERE Name = '3rdParty'];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setBccAddresses(sendTo);

            mail.setSubject('Email Master Budget Sheet');
            
            
            String body = '<br/>';
                body +='Please go to the Salesforce third party portal for Value Retail.<br/>';
            if(bv != null){
                body +='A new Master Budget Sheet has been submitted by '  + bv.Name +  '<br/>';
            } else {
                body +='A new Master Budget Sheet has been submitted.<br/>';
            }
                body += mbs.Name +  '<br/>';
                body += myCommunity.siteUrl +'/s/master-budget-sheet/'+mbs.Id +'';
                


            mail.setHtmlBody(body);
            mail.setSaveAsActivity(false); 
            allMessag.add(mail);
        
        	Messaging.sendEmail(allMessag);
        	System.debug('user mail id '+allMessag);       
        }       
    }    
    
    public void shareRecordWithUsers(Master_Budget_Sheet__c mbs){

        List<Id> userIdList = new List<Id>();
    
        if(mbs.Creative_Agency_1__c != null){ 
			userIdList.add(mbs.Creative_Agency_1__c);
        }

        if(mbs.Creative_Agency_2__c != null){ 
            userIdList.add(mbs.Creative_Agency_2__c);  
        }

        if(mbs.Creative_Agency_3__c != null){ 
            userIdList.add(mbs.Creative_Agency_3__c);  
        }

        if(mbs.Creative_Agency_4__c != null){ 
            userIdList.add(mbs.Creative_Agency_4__c);  
        }
        
        if(mbs.Creative_Agency_5__c != null){ 
            userIdList.add(mbs.Creative_Agency_5__c);  
        }
        
        if(mbs.Creative_Agency_6__c != null){ 
            userIdList.add(mbs.Creative_Agency_6__c);  
        }
        
        if(mbs.Creative_Agency_7__c != null){ 
            userIdList.add(mbs.Creative_Agency_7__c);  
        }
        
        if(mbs.Creative_Agency_8__c != null){ 
            userIdList.add(mbs.Creative_Agency_8__c);  
        }  
                      

        for(integer i = 0; i<userIdList.size();i++){
            Master_Budget_Sheet__Share mbsShare = new Master_Budget_Sheet__Share(); 
  			mbsShare.ParentId= mbs.id;
            mbsShare.UserOrGroupId = userIdList.get(i);  
            mbsShare.AccessLevel = 'Edit';
            Database.SaveResult sr = Database.insert(mbsShare,false);
        }
         
    }
    
}