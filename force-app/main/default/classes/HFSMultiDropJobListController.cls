Public Class HFSMultiDropJobListController{


    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    public List<jobWrapper> jobList {get;set;}
    public Boolean showmessage {get;set;}
    public List<SelectOption> LocationOptions { get;set;}
    public String selectedField {get;set;}
    public Boolean pbRendered {get;set;}
    
    public HFSMultiDropJobListController(){
        
        pbRendered = false;
        
        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
        
        string village = users[0].Village__c;
        
        string str = '%'+Village+'%';
        List<HFS_Collection_Point__c> collectionPoints = [SELECT Name FROM HFS_Collection_Point__c WHERE name LIKE: str ];
        
        LocationOptions = new LIST<SelectOption>();
        LocationOptions.add(new SelectOption('','--None--'));
        
        for(HFS_Collection_Point__c cp : collectionPoints ){
        	LocationOptions.add(new SelectOption(cp.name,cp.name));       	
        }
    
        
    }
    
    
    public pageReference updateJobsList(){
   		
    	getJobs();  	
    	return null;
    }


    public pageReference ArrivedAtStoragePoint() {

        list<HFS_Job__c> jobstoUpdate = new list<HFS_Job__c>();

        for(jobWrapper job : jobList){
            if(job.selected){
                job.HFSJob.Arrived_Storage_Point__c = true;
                job.HFSJob.Take_job_for_me__c = false;
                jobstoUpdate.add(job.HFSJob);
            }
        }

        try{
            update jobstoUpdate;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Success, the selected jobs\' status\' have been moved to \"Arrived at Storage Point\" '));
            showmessage = true;
        }
        catch (exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getmessage()));
     
            showmessage = true;
        }

        PageReference pageRef = ApexPages.currentPage();

        return pageRef;
    }
    
    
    Public List<jobWrapper> getJobs(){
    	
    	
       jobList = new List<jobWrapper>();
       string location = selectedField;
       list<HFS_Job__c> jobs = [SELECT id , Name , Arrived_Storage_Point__c, Take_job_for_me__c, Assigned_to_me__c , Job_Status__c , Guest_ID_Code__c , HFS_Purchase__r.Case__r.Service_Guest_Number__c , HFS_Guest_Collection_Point__c FROM HFS_Job__c WHERE  Job_Status__c = 'Delivering' AND Assigned_to_me__c = true AND HFS_Guest_Collection_Point__c =: + location ];
       for(HFS_Job__c job : jobs){
            jobList.add(new jobWrapper(job));
        }
        showmessage = false;
        pbRendered = true;
        if(jobList == NULL || jobList.size() == 0){
            showmessage = true;
            pbRendered = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You have no assigned jobs for this drop off location'));    
        }
        return jobList;
        
    }


     Public Pagereference selectAll() {
        for(jobWrapper cJOB : jobList){
            cJOB.selected = true;
        } 
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }

    Public Pagereference deselectAll() {
        for(jobWrapper cJOB : jobList){
            cJOB.selected = false;
        }
    //PageReference pageRef = new PageReference('/'+recordId);
        return null;
    }



    public class jobWrapper {
        public HFS_Job__c HFSJob {get; set;}
        public Boolean selected {get; set;}

        public jobWrapper(HFS_Job__c job) {
            HFSJob = job;
            selected = false;

        }
    }



    

}