public with sharing class marketingCampaignActionsControllerExt {


    //edit Campaign Level on marketing Campaign Object
    private ApexPages.StandardController stdController;
    public String Option { get; set; }
    public marketing_Campaign__c MC { get; set; }
    public List<SelectOption> Options { get;set;}
    public String selectedOption { get; set; }
    public boolean shouldredirect {get;set;}
    public string redirectURL {get;set;}
    public boolean showLevelButton {get;set;}
   
    // Oracle Sync Section
    // private final Marketing_Campaign__c mysObject;
    public Boolean displayError {public get; private set;}
    public String errorMessage {public get; public set;}
    public Boolean displayWarning {public get; private set;}
    public String warningMessage {public get; public set;}
    public Boolean displayMessage {public get; private set;}
    public String pageMessage {public get; public set;}
    public Boolean showCSVButton {public get; private set;}
    public Boolean showCSVProjButton {public get; private set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public marketingCampaignActionsControllerExt(ApexPages.StandardController stdController) {
    
        showLevelButton = False;
        showCSVButton = false;
        showCSVProjButton = false;
        // set all messages as default false
        displayError = false;
        displayWarning = false;
        displayMessage = false;
    
        List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if(perm.PermissionSet.Name == 'Edit_Marketing_Campaign_Level_Themes_Lead_Group_Tactical'){
                showLevelButton = true;
            }
            if(perm.PermissionSet.Name == 'Sync_Marketing_Campaigns'){
                showCSVButton = true;
                showCSVProjButton = true;
            }
            //System.debug('perm ==== ' + perm + '------' + perm.PermissionSet.Name);
        }

        this.MC = (marketing_Campaign__c)stdController.getRecord();

        if(showLevelButton){
            this.stdController = stdController; 
          //  stdController.addFields(new List<String>{'Campaign_Level__c'});
          Marketing_Campaign__c Camp = [Select ID, Name, Campaign_Level__c FROM Marketing_Campaign__c WHERE ID = :this.MC.ID ];
            Id recordId = stdController.getId();
           
            Options = new LIST<SelectOption>();
            Options.add(new SelectOption('','--None--'));
            Options.add(new SelectOption('Theme','Theme'));
            Options.add(new SelectOption('Lead Group Campaign','Lead Group Campaign', true));
            Options.add(new SelectOption('Tactical Campaign','Tactical Campaign',true));
            Options.add(new SelectOption('Lead Moment','Lead Moment'));
            Options.add(new SelectOption('Local Moment','Local Moment'));
            Options.add(new SelectOption('BAU Campaign','BAU Campaign'));

            selectedOption = Camp.Campaign_Level__c;
        }     

    }

    public PageReference generateCSVprojections(){
         try{
            List<Marketing_Campaign__c> campaigns = getAllCampaignsForCSV(this.MC.ID, 3);
            List<Marketing_Activity__c> activities = [Select Id, Name, CurrencyIsoCode, Marketing_Activity_Ref__c,Start_Date__c,End_Date__c,Marketing_Campaign__c, Budget__c, Transfer_To_Oracle__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c in :campaigns AND Status__c in ('Approved','To be Approved') ];

            System.debug('campaigns ===== ' + campaigns);

            Map<Marketing_Campaign__c,List<Marketing_Activity__c>> CampaignData = CSVFileUtils.ProcessData(campaigns, activities);

            System.debug('CampaignData ===== ' + CampaignData);

            String filedata = '';
            // do a different loop here        

            for(Marketing_Campaign__c campaign :CampaignData.keyset()){

                System.debug('campaign Item adding to Data ===== ' + campaign);
               // filedata = CSVFileUtils.AddData(campaign,CampaignData.get(campaign),filedata);
               filedata = CSVFileUtils.AddProjectionData(campaign,CampaignData.get(campaign),filedata);
            }

        // we need to get the Marketing Ref number to use as the file title
        String CampaignReference = '';
        for(Marketing_Campaign__c camp :campaigns)
        {
          if(camp.Id == this.MC.Id){
            CampaignReference = camp.Marketing_Campaign_Ref__c;
          }

        }

             Zippex outputZip = new Zippex();
             outputZip = CSVFileUtils.ProduceProjectionZipFile(filedata,CampaignReference );

             String docName = 'Campaign-Budget-' + CampaignReference + '.zip'; // Document's name

                  Attachment attach = new Attachment();     
                  attach.parentId = this.MC.Id;
                  attach.Name =  docName;
                  attach.body = outputZip.getZipArchive();
                  attach.ContentType = 'text';
                //insert attach;
                displayMessage = true;
                pageMessage = 'Marketing Campaign successfully syncronised';
                showCSVButton = false;
                showCSVProjButton = false;

             ContentVersion contentVersion = new ContentVersion();
             contentVersion.VersionData = outputZip.getZipArchive();
             contentVersion.Title = docName;
             contentVersion.PathOnClient = docName + '.zip';
             contentVersion.ContentLocation = 'S';
             contentVersion.FirstPublishLocationId = this.MC.Id;

             Database.insert(contentVersion, true);

            return new PageReference('/' + this.MC.Id);
            
         }
         catch(Exception ex){
            System.debug('Exception ====== ' + ex.getMessage() + '========' + ex.getStackTraceString());
         }
            return null;
     }

     private List<Marketing_Campaign__c> getAllCampaignsForCSV(Id CampID, Integer levels){

 // at risk of blowing more queries, im going to get all 'grandchildren' too, in the form of another query
            if(Levels == 0){
                // if the level is 0 then we will only return this campaign, and no others
                List<Marketing_Campaign__c> thiscampaign = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name, Village_Marketing_Budget__c, Transfer_To_Oracle__c  FROM Marketing_Campaign__c WHERE Status__c in ('Approved','To be Approved') AND ID = :CampID ];
                return thiscampaign;
            }
            else{
                System.debug('CampID ' + CampID);
                List<Marketing_Campaign__c> campaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name, Village_Marketing_Budget__c,Transfer_To_Oracle__c, CurrencyIsoCode FROM Marketing_Campaign__c WHERE Status__c in ('Approved','To be Approved') AND (ID = :CampID OR Parent_Marketing_Campaign__c = :CampID) ];
                List<Marketing_Campaign__c> grandchildcampaigns;
                if(Levels > 1){
                    grandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name, Village_Marketing_Budget__c,Transfer_To_Oracle__c FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :campaigns AND Status__c in ('Approved','To be Approved') ];
                     campaigns.addAll(grandchildcampaigns);
                }
                if(Levels > 2){
                    // adding ANOTHER level (this could blow the query limit)
                    List<Marketing_Campaign__c> greatgrandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name, Village_Marketing_Budget__c,Transfer_To_Oracle__c FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :grandchildcampaigns AND Status__c in ('Approved','To be Approved') ];
                    // then combine the lists into one
                    campaigns.addAll(greatgrandchildcampaigns);
                }

                return campaigns;
            }
            return null;
     }

    public PageReference generateCSV(){
         try{
            // lets get the data from the object:
/*
            // at risk of blowing more queries, im going to get all 'grandchildren' too, in the form of another query
            //Marketing_Campaign__c campaign = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE ID = :this.mysObject.ID];
            List<Marketing_Campaign__c> campaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Status__c in ('Approved','To be Approved') AND (ID = :this.MC.ID OR Parent_Marketing_Campaign__c = :this.MC.ID )];
            List<Marketing_Campaign__c> grandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :campaigns AND Status__c in ('Approved','To be Approved')];
            // adding ANOTHER level (this could blow the query limit)
            List<Marketing_Campaign__c> greatgrandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :grandchildcampaigns AND Status__c in ('Approved','To be Approved')];
            // then combine the lists into one
            campaigns.addAll(grandchildcampaigns);
            campaigns.addAll(greatgrandchildcampaigns);
            */
            List<Marketing_Campaign__c> campaigns = getAllCampaignsForCSV(this.MC.ID, 3);

            List<Marketing_Activity__c> activities = [Select Id, Name,Marketing_Activity_Ref__c,Start_Date__c,End_Date__c,Marketing_Campaign__c,Budget__c,Transfer_To_Oracle__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c in :campaigns AND Status__c in ('Approved','To be Approved')];

            System.debug('campaigns ===== ' + campaigns);

            Map<Marketing_Campaign__c,List<Marketing_Activity__c>> CampaignData = CSVFileUtils.ProcessData(campaigns, activities);

            System.debug('CampaignData ===== ' + CampaignData);

            CSVFileUtils.OracleMarketingCSVFilesData filedata = new CSVFileUtils.OracleMarketingCSVFilesData();
            // do a different loop here        

            for(Marketing_Campaign__c campaign :CampaignData.keyset()){

                System.debug('campaign Item adding to Data ===== ' + campaign);
                filedata = CSVFileUtils.AddData(campaign,CampaignData.get(campaign),filedata);
            }

        // we need to get the Marketing Ref number to use as the file title
        String CampaignReference = '';
        for(Marketing_Campaign__c camp :campaigns)
        {
          if(camp.Id == this.MC.Id){
            CampaignReference = camp.Marketing_Campaign_Ref__c;
          }

        }
            Zippex outputZip = new Zippex();
            outputZip = CSVFileUtils.ProduceZipFile(filedata);

            String docName = 'Campaign-Export-' + CampaignReference + '.zip'; // Document's name

                  Attachment attach = new Attachment();     
                  attach.parentId = this.MC.Id;
                  attach.Name =  docName;
                  attach.body = outputZip.getZipArchive();
                  attach.ContentType = 'text';
                //insert attach;
                displayMessage = true;
                pageMessage = 'Marketing Campaign successfully syncronised';
                showCSVButton = false;
                showCSVProjButton = false;

             ContentVersion contentVersion = new ContentVersion();
             contentVersion.VersionData = outputZip.getZipArchive();
             contentVersion.Title = docName;
             contentVersion.PathOnClient = docName + '.zip';
             contentVersion.ContentLocation = 'S';
             contentVersion.FirstPublishLocationId = this.MC.Id;

             Database.insert(contentVersion, true);

            return new PageReference('/' + this.MC.Id);
       
        } catch ( Exception ex ) {
            displayError = true;
            showCSVButton = false;
            showCSVProjButton = false;
            errorMessage = 'There was an error producing your data \r\n' + ex.getMessage();
            System.debug('>>> ERROR ' + ex);
        }
        return null;
  
    }

    public pagereference EditCampaignLevel(){
        pagereference ref = new PageReference('/apex/EditCampaignLevel');
        return ref;
    }


    public pagereference Save(){

        try{
            shouldRedirect = true;
            redirectUrl = stdController.view().getUrl();

            this.MC.Campaign_Level__c = selectedOption;
            update this.MC;
        
        } catch ( Exception ex ) {
            system.debug('error message @@@@@@ ' + ex);
            this.MC.addError('There was a problem updating the record, Salesforce errorMessage : ' + ex + ', Please contact your System Administrator');
        }
        return null;
    }


    
    public PageReference cancel(){
        PageReference ref = new PageReference('/apex/Marketing_Campaign_Actions');
        return ref;
    }

}