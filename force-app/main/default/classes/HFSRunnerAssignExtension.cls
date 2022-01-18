public with sharing class HFSRunnerAssignExtension {
    
    public HFS_Job__c job {get; set; }
    public List<SelectOption> allRunners {get; set; }
    public String selectedAssignedRunner {get; set; }
    public static String userVillage {get; set;}
    
    public HFSRunnerAssignExtension(ApexPages.StandardController stdController) {
        this.job = (HFS_Job__c)stdController.getRecord();
        userVillage = getUsersVillage();
        getRunners();
        
    }

    private static string getUsersVillage(){
            
        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
        Village__c uservillage  = [SELECT Name, Village_Code__c FROM Village__c WHERE Name =:users[0].Village__c LIMIT 1];
        
        string village = users[0].Village__c;
        //userVillageCode = uservillage.Village_Code__c;
        
        return village;     
    }

    //DEVELOPMENT FOR THE BUTTON PRESENT IN EACH JOB -> THIS IS FOR VF: HFSRunnerAssign

    public List<SelectOption> getRunners(){

        allRunners = new List<SelectOption>();
        List<HFS_Runner__c> existingRunners = [SELECT Id, Name, User__c FROM HFS_Runner__c WHERE HFS_Runner__c.User__r.village__c =:userVillage  ORDER BY Name];
        
        allRunners.add(new SelectOption('null','Select a Runner'));
        
        for(HFS_Runner__c eachRunner : existingRunners){
            allRunners.add(new SelectOption(eachRunner.Id,eachRunner.Name));
        }
        return allRunners;
    }

    public PageReference assign(){
        Apexpages.Message error_msg = new Apexpages.Message(Apexpages.Severity.Error, 'An error occurred while saving changes!');
        Apexpages.Message assign_msg = new Apexpages.Message(Apexpages.Severity.Info, 'Runner already assigned to this Job!');
        Apexpages.Message errorMessage = new Apexpages.Message(Apexpages.Severity.Error, 'A value for the Runner field is required.');

        HFS_Job__c theJob = [SELECT Id, Name, HFS_Runner__c, HFS_Purchase__c FROM HFS_Job__c WHERE ID =: job.ID];
            
        if(selectedAssignedRunner == 'null'){
            
            Apexpages.addMessage(errorMessage);
            
        } else if(theJob.HFS_Runner__c == selectedAssignedRunner){
            
            Apexpages.addMessage(assign_msg);
            
        } else if (theJob.HFS_Runner__c == null || theJob.HFS_Runner__c != selectedAssignedRunner){

            theJob.HFS_Runner__c = selectedAssignedRunner;
            theJob.Job_Status__c = 'Assigned';
            
            try{
                update theJob;
                PageReference jobPage = new PageReference('/' + theJob.Id);
                return jobPage;

            } catch(Exception e){
                
                Apexpages.addMessage(error_msg); 
                
                System.debug('@@@@ calling save on HFSRunnerAssignExtension. Following error occurred while saving changes: ' + e); 
            }
        }
        return null;
    }

    public PageReference createNewJob(){
        
        Apexpages.Message error_msg = new Apexpages.Message(Apexpages.Severity.Error, 'An error occurred while saving changes !');
        
        HFS_Job__c theJob = [SELECT Id, Name, HFS_Runner__c, HFS_Purchase__c, Job_Type__c, Job_Status__c FROM HFS_Job__c WHERE ID =: job.ID];
        RecordType rtId = [SELECT Id, Name FROM RecordType WHERE Name = 'New Job General'];
        
        HFS_Job__c cloneJob = new HFS_Job__c(
            RecordTypeId = rtId.Id,
            HFS_Purchase__c = theJob.HFS_Purchase__c,
            Job_Type__c = 'Shared Pick-up Request'
        );
        
        if(theJob.HFS_Runner__c != null || selectedAssignedRunner == 'null'){
            
            if(theJob.Job_Type__c == 'Bag Transfer'){
                cloneJob.Job_Type__c = 'Bag Transfer';
                insert cloneJob;
            } else if(theJob.Job_Type__c == 'Bag Drop'){
                cloneJob.Job_Type__c = 'Bag Drop';
            } else {
                updateJobs(theJob);
                insert cloneJob;
            }

            PageReference goToPage = Page.HFSRunnerAssign;
            goToPage.setRedirect(true);
            goToPage.getParameters().put('id',cloneJob.Id);
            return goToPage;
            
        } else if(selectedAssignedRunner != null){
            
            try{

                if(theJob.Job_Type__c == 'Bag Transfer'){
                    cloneJob.Job_Type__c = 'Bag Transfer';
                    insert cloneJob;
                    theJob.HFS_Runner__c = selectedAssignedRunner;
                    theJob.Job_Status__c = 'Assigned';
                    update theJob;
                } else if(theJob.Job_Type__c == 'Bag Drop'){
                    cloneJob.Job_Type__c = 'Bag Drop';
                    insert cloneJob;
                    theJob.HFS_Runner__c = selectedAssignedRunner;
                    theJob.Job_Status__c = 'Assigned';
                    update theJob;
                } else {
                    specialUpdateJob(theJob, selectedAssignedRunner);
                    insert cloneJob;
                }
                
                PageReference goToPage = Page.HFSRunnerAssign;
                goToPage.setRedirect(true);
                goToPage.getParameters().put('id',cloneJob.Id);
                return goToPage;
                
            } catch(Exception e){
                
                Apexpages.addMessage(error_msg); 
                
                System.debug('@@@@ calling save on HFSRunnerAssignExtension. Following error occurred while saving changes: ' + e); 
            }
        }

        return null;
    }

    public PageReference cancel(){
        
        PageReference jobPage = new PageReference('/' + job.Id);
        
        return jobPage;
    }

    //DEVELOPMENT FOR THE BUTTON PRESENT IN EACH JOB -> THIS IS FOR VF: CreateNewJobAutomatically

    public PageReference autoRun(){

        HFS_Job__c theJob = [SELECT Id, Name, HFS_Runner__c, HFS_Purchase__c, Job_Type__c FROM HFS_Job__c WHERE ID =: job.ID];
        Id rtId = Schema.getGlobalDescribe().get('HFS_Job__c').getDescribe().getRecordTypeInfosByName().get('New Job General').getRecordTypeId();

        HFS_Job__c cloneJob = new HFS_Job__c(
            RecordTypeId = rtId,
            HFS_Purchase__c = theJob.HFS_Purchase__c,
            Job_Type__c = 'Shared Pick-up Request'
        );

        try{

            if(theJob.Job_Type__c == 'Bag Transfer'){
                cloneJob.Job_Type__c = 'Bag Transfer';
                insert cloneJob;
            } else if(theJob.Job_Type__c == 'Bag Drop'){
                cloneJob.Job_Type__c = 'Bag Drop';
                insert cloneJob;
            } else {
                updateJobs(theJob);
                insert cloneJob;
            }

            PageReference goToPage = Page.HFSRunnerAssign;
            goToPage.setRedirect(true);
            goToPage.getParameters().put('id',cloneJob.Id);
            return goToPage;

        } catch(Exception e){

            System.debug('@@@@ calling save on HFSRunnerAssignExtension. Following error occurred while saving changes: ' + e);
            return null;
        }
    }

    public void updateJobs(HFS_Job__c aJob){
        List<HFS_Job__c> allJobs = [SELECT Id, Name, HFS_Runner__c, HFS_Purchase__c, Job_Type__c FROM HFS_Job__c WHERE HFS_Purchase__c =: aJob.HFS_Purchase__c];
        List<HFS_Job__c> updateAJob = new List<HFS_Job__c>();

        for(HFS_Job__c eachJob : allJobs){
            eachJob.Job_Type__c = 'Shared Pick-up Request';
            updateAJob.add(eachJob);
        }

        update updateAJob;
    }

    public void specialUpdateJob(HFS_Job__c aJob, String selectedAssignedRunner){
        List<HFS_Job__c> allJobs = [SELECT Id, Name, HFS_Runner__c, HFS_Purchase__c, Job_Type__c, Job_Status__c FROM HFS_Job__c WHERE HFS_Purchase__c =: aJob.HFS_Purchase__c];
        List<HFS_Job__c> allUpdatedJobs = new List<HFS_Job__c>();

        for(HFS_Job__c eachJob : allJobs){
            if(aJob.Id == eachJob.Id){
                eachJob.HFS_Runner__c = selectedAssignedRunner;
                eachJob.Job_Status__c = 'Assigned';
            }
            eachJob.Job_Type__c = 'Shared Pick-up Request';
            allUpdatedJobs.add(eachJob);
        }

        update allUpdatedJobs;
    }

    //DEVELOPMENT FOR THE CANCEL BUTTON PRESENT IN EACH JOB -> THIS IS FOR VF: HFSCancelJob
    public PageReference cancelAJob(){
        HFS_Job__c theJob = [SELECT Id, Name, Cancel_Job_are_you_sure__c FROM HFS_Job__c WHERE ID =: job.ID];

        theJob.Cancel_Job_are_you_sure__c = true;
        update theJob;
        
        PageReference jobPage = new PageReference('/' + theJob.Id);
        
        return jobPage;
    }
}