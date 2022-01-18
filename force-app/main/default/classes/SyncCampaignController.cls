public with sharing class SyncCampaignController {

    private final Marketing_Campaign__c mysObject;
  public Boolean displayError {public get; private set;}
  public String errorMessage {public get; public set;}
  public Boolean displayWarning {public get; private set;}
  public String warningMessage {public get; public set;}
  public Boolean displayMessage {public get; private set;}
  public String pageMessage {public get; public set;}
  public Boolean showButton {public get; private set;}
  

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SyncCampaignController(ApexPages.StandardController stdController) {
        this.mysObject = (Marketing_Campaign__c)stdController.getRecord();
        // set all messages as default false
        displayError = false;
        displayWarning = false;
        displayMessage = false;
        showButton = true;
    }

    /**
   * Zip files and redirect to download url of zip ducument
   * @return [description]
   */
  public PageReference generateCSV(){
 
  try{
        // lets get the data from the object:

        // at risk of blowing more queries, im going to get all 'grandchildren' too, in the form of another query
        //Marketing_Campaign__c campaign = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE ID = :this.mysObject.ID];
        //List<Marketing_Campaign__c> campaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Status__c in ('Confirmed','To Be Confirmed') AND (ID = :this.mysObject.ID OR Parent_Marketing_Campaign__c = :this.mysObject.ID )];
        List<Marketing_Campaign__c> campaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Status__c in ('Approved','To be Approved') AND (ID = :this.mysObject.ID OR Parent_Marketing_Campaign__c = :this.mysObject.ID )];
        //List<Marketing_Campaign__c> grandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :campaigns AND Status__c in ('Confirmed','To Be Confirmed')];
        List<Marketing_Campaign__c> grandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :campaigns AND Status__c in ('Approved','To be Approved')];
        // adding ANOTHER level (this could blow the query limit)
        //List<Marketing_Campaign__c> greatgrandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :grandchildcampaigns AND Status__c in ('Confirmed','To Be Confirmed')];
        List<Marketing_Campaign__c> greatgrandchildcampaigns = [Select Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Parent_Marketing_Campaign__c in :grandchildcampaigns AND Status__c in ('Approved','To be Approved')];
        // then combine the lists into one
        campaigns.addAll(grandchildcampaigns);
        campaigns.addAll(greatgrandchildcampaigns);
        
        //List<Marketing_Activity__c> activities = [Select Id, Name,Marketing_Activity_Ref__c,Start_Date__c,End_Date__c,Marketing_Campaign__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c in :campaigns AND Status__c in ('Confirmed','To Be Confirmed')];
        List<Marketing_Activity__c> activities = [Select Id, Name,Marketing_Activity_Ref__c,Start_Date__c,End_Date__c,Marketing_Campaign__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c in :campaigns AND Status__c in ('Approved','To be Approved')];

        System.debug('campaigns ===== ' + campaigns);

        Map<Marketing_Campaign__c,List<Marketing_Activity__c>> CampaignData = CSVFileUtils.ProcessData(campaigns, activities);

        CSVFileUtils.OracleMarketingCSVFilesData filedata = new CSVFileUtils.OracleMarketingCSVFilesData();
        // do a different loop here        

        for(Marketing_Campaign__c campaign :CampaignData.keyset()){

            filedata = CSVFileUtils.AddData(campaign,CampaignData.get(campaign),filedata);
        }

    
        Zippex outputZip = new Zippex();
        outputZip = CSVFileUtils.ProduceZipFile(filedata);

        String docName = 'Campaign-Export.zip'; // Document's name

              Attachment attach = new Attachment();     
              attach.parentId = this.mysObject.Id;
              attach.Name =  docName;
              attach.body = outputZip.getZipArchive();
              attach.ContentType = 'text';
            insert attach; 
            displayMessage = true;
            pageMessage = 'Marketing Campaign successfully syncronised';
            showButton = false;

        return new PageReference('/servlet/servlet.FileDownload?file=' + attach.Id);
   
    } catch ( Exception ex ) {
        displayError = true;
        showButton = false;
        errorMessage = 'There was an error producing your data \r\n' + ex.getMessage();
        System.debug('>>> ERROR ' + ex);
    }
    return null;
  }
/*
// this code may be used at a later stage for 
   public PageReference syncroniseMarketingCampaign(){
      Marketing_Campaign__c campaign = [Select Id, Name,  Oracle_Project_ID__c, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c FROM Marketing_Campaign__c WHERE ID = :this.mysObject.ID];
      try{
        OracleCalloutUtils Outils = new OracleCalloutUtils();

        // lets see if the campaign has been syncronised before. if not, then we must create it in Oracle Fusion
        if(campaign.Oracle_Project_ID__c == null){
              
              OracleCalloutUtils.createProjectRequestObject ProjectRequestObj = new OracleCalloutUtils.createProjectRequestObject();
              ProjectRequestObj.ProjectName = campaign.Name + ' - ' + campaign.Marketing_Campaign_Ref__c;
              ProjectRequestObj.TemplateKey = campaign.Village__r.Oracle_Source_Template_Number__c;
              ProjectRequestObj.ProjectDescription = campaign.Name + ' - ' + campaign.Marketing_Campaign_Ref__c;
              ProjectRequestObj.StartDate = String.valueOf(campaign.Start_Date__c);
              ProjectRequestObj.EndDate = String.valueOf(campaign.End_Date__c);
              ProjectRequestObj.ProjectManagerEmail = UserInfo.getUserEmail(); // TODO get the village managers email from contact.

              OracleCalloutUtils.createProjectResponseObject ProjectResponseObj =  Outils.createProject(ProjectRequestObj);
              System.debug('ProjectResponseObj === ' + ProjectResponseObj);

              campaign.Oracle_Project_Number__c = ProjectResponseObj.ProjectNumber;
              campaign.Oracle_Project_ID__c = ProjectResponseObj.ProjectID;

              update campaign;

              displayMessage = true;
              pageMessage = 'Marketing Campaign successfully syncronised';
              showButton = false;
              return null;
          }
          else
          {
            // means the value is set, and the project needs ot be updated :) 
              OracleCalloutUtils.updateProjectRequestObject ProjectRequestObj = new OracleCalloutUtils.updateProjectRequestObject();
              ProjectRequestObj.ProjectName = campaign.Name + ' - ' + campaign.Marketing_Campaign_Ref__c;
              ProjectRequestObj.ProjectID = campaign.Oracle_Project_ID__c;
              ProjectRequestObj.ProjectDescription = campaign.Name + ' - ' + campaign.Marketing_Campaign_Ref__c;
              ProjectRequestObj.StartDate = String.valueOf(campaign.Start_Date__c);
              ProjectRequestObj.EndDate = String.valueOf(campaign.End_Date__c);

               OracleCalloutUtils.updateProjectResponseObject ProjectResponseObj =  Outils.updateProject(ProjectRequestObj);
               // this should succeed, or throw exception
              displayMessage = true;
              pageMessage = 'Marketing Campaign successfully syncronised';
              showButton = false;
              return null;
          }
        } 
        catch( OracleCalloutUtils.OracleServiceException ose){
            displayError = true;
            showButton = false;
            errorMessage = '';
            for(OracleCalloutUtils.OracleResponseErrorObject error :ose.errors){
              errorMessage += error.message + ' ';
            }
        }
        catch ( Exception ex ) {
          displayError = true;
          showButton = false;
          errorMessage = ex.getMessage();
          System.debug('>>> ERROR ' + ex);
        }
        return null;
   }
   */
}