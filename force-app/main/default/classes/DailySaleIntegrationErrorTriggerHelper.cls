public without sharing class DailySaleIntegrationErrorTriggerHelper {
	
	@future
    public static void postNewRecordChatter(set<Id> errorIds) {
        
        try {

            list<Daily_Sale_Integration_Error__c> errorList = [select Id, Daily_Sale__c, Integration_Message__c,
                                                                Daily_Sale__r.Store_Formula__c, Daily_Sale__r.Id,
                                                                Daily_Sale__r.Name, Daily_Sale__r.Trading_Day_with_date__c,
                                                                Daily_Sale__r.Store__r.Village__r.Name,
                                                                Daily_Sale__r.Store__r.Village__r.Village_Code__c   
                                                                from Daily_Sale_Integration_Error__c
                                                                where Id in :errorIds];

            string grpId = '';
            
            if (test.isRunningTest()){
            	grpId = [select Id from CollaborationGroup where Name = 'Daily Sale Integration Errors Test'].Id;
            } else {                                                               
            	grpId = [select Id from CollaborationGroup where Name = 'Daily Sale Integration Errors'].Id;            
            }
            
            
            map<Id, CollaborationGroup> villageGroups = new map<Id, CollaborationGroup>([select Id, Name from CollaborationGroup where Name like 'Daily Sale Integration Errors - %']);
            map<string,Id> villageGroupIds = new map<string,Id>();
            if (!villageGroups.isEmpty()){
                for (CollaborationGroup grp :villageGroups.values()){
                    villageGroupIds.put(grp.Name, grp.Id);
                }
            }
            
            list<feedItem> feedList = new list<feedItem>();
            
            for (Daily_Sale_Integration_Error__c err :errorList){           
                
                string title = '\n Daily Sale Integration Error \n\n';
                string village = err.Daily_Sale__r.Store__r.Village__r.Village_Code__c;
                string villageGroup = 'Daily Sale Integration Errors - ' + village; 
    
                string msg =   '\n An Integration Error has been recorded for -  \n'
                + 'Daily Sale Ref : ' + err.Daily_Sale__r.Name + ' \n'
                + 'Brand : ' +  err.Daily_Sale__r.Store_Formula__c  + ' \n'
                + 'Trading Day : ' + err.Daily_Sale__r.Trading_Day_with_date__c + '\n' 
                + 'Integration Message : ' +  err.Integration_Message__c + ' \n'; 
       
                feeditem newPost = new feeditem();
    
                if (string.isnotBlank(grpId)){
                    newPost.parentid = grpId;
                    newPost.Title = title;
                    newPost.LinkUrl = '/' +  err.Daily_Sale__r.Id;
                    newPost.Body = msg;
                    
                    
                    feedList.add (newPost);
                }
                
                string villageGroupId = villageGroupIds.get(villageGroup);
                if (string.isnotBlank(villageGroupId)){
                    newPost = new feeditem();
                    newPost.parentid = villageGroupId;
                    newPost.Title = title;
                    newPost.LinkUrl = '/' +  err.Daily_Sale__r.Id;
                    newPost.Body = msg;                 
                    feedList.add (newPost);
                }
                
    
            }
            
            if (!feedList.isEmpty()){
                insert feedList;
            }
        } catch (exception e){

            string errMsg = '@@@ ERROR - Internal technical error - Attempting to log Daily Sale Integration Error';
            errMsg += '\r\n' + e.getMessage() + ' : ' + e.getStackTraceString();                
            system.debug(errMsg); 
                
        }
    
    }
}