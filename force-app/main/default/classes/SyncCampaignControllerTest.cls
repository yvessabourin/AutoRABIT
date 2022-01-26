@isTest
public  class SyncCampaignControllerTest {

private static Marketing_Campaign__c MC ;

    @TestSetup
    public static void SetupData(){

        // first create a village
        Village__c vill = TestDataGenerator.setupVillage(false);
        vill.Oracle_Source_Template_Number__c = '123456';
        vill.Oracle_Organisation__c = 'SourceOrg';
		vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		vill.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert vill;

          Account testAccount = new Account(name = 'Test Account' , RecordTypeId =  Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Tourism').RecordTypeId);
          insert testAccount;

        Map <String,Schema.RecordTypeInfo> recordTypesadjustment = Marketing_Campaign__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        //System.assertEquals(1,2,recordTypesadjustment);
        Id RecTypeIdinadj = recordTypesadjustment.get('Village Campaign').getRecordTypeId();

        MC = new Marketing_Campaign__c();

        
        MC.Name = 'TestCampaignForTestingSync';
        //MC.Marketing_Campaign_Ref__c = 'MCREF001';
        MC.Short_Description__c = 'TestCampaign Description';
        MC.Start_Date__c = Date.today();
        MC.End_Date__c = Date.today();
        MC.Village__c = vill.Id;
        MC.RecordTypeId = RecTypeIdinadj;
        MC.Campaign_Level__c = 'Theme';

        insert MC;

        // and now insert an activity
        //Select Id, Name,Marketing_Activity_Ref__c,Start_Date__c,End_Date__c,Marketing_Campaign__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c in :campaigns];
        Marketing_Activity__c MA = new Marketing_Activity__c();

        MA.Name = 'TestActivity';
        //MA.Marketing_Activity_Ref__c = 'MA Ref';
        MA.Start_Date__c = Date.today();
        MA.End_Date__c = Date.today();
        MA.Marketing_Campaign__c = MC.ID;
        MA.Partner__c = testAccount.Id;
        insert MA;

        //System.assertEquals(1,2,MC);
    }
    public testmethod static void createCSV_Success(){

        
        // get the data again
        Marketing_Campaign__c MCamp = [SELECT Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Name = 'TestCampaignForTestingSync' LIMIT 1];
        // once the data is inserted, we can process it

        Test.startTest();
        PageReference pageRef = Page.Sync_Campaign;

        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('id',MCamp.id);

        ApexPages.StandardController stdController = new ApexPages.standardController(MCamp);

        SyncCampaignController ExController = new SyncCampaignController(stdController);

        ExController.generateCSV();
        
        Test.stopTest();
        // once the CSV is generated, it should have saved in the attachements of the record.

        List<Attachment> attachments = [SELECT name FROM Attachment WHERE ParentID =: MCamp.id];

        System.assertEquals(attachments.size(),1,'Attachment count is incorrect.');

        System.assertEquals(attachments[0].name,'Campaign-Export.zip','No file named Campaign-Export.zip found');

    }

    public testmethod static void testCSVUtilAddData(){

    	        CSVFileUtils.OracleMarketingCSVFilesData filedata = new CSVFileUtils.OracleMarketingCSVFilesData();
        // do a different loop here        
        // get the data again
        List<Marketing_Campaign__c> MCamps = [SELECT Id, Name, Marketing_Campaign_Ref__c, Short_Description__c, Start_Date__c, End_Date__c,Village__r.Oracle_Source_Template_Number__c, Village__r.Oracle_Organisation__c, RecordType.Name,Owner.Name, Owner.email, Parent_Marketing_Campaign__r.Name FROM Marketing_Campaign__c WHERE Name = 'TestCampaignForTestingSync'];
        // once the data is inserted, we can process it
        List<Marketing_Activity__c> MActs = [SELECT Id, Name,Marketing_Activity_Ref__c,Start_Date__c,End_Date__c,Marketing_Campaign__c FROM Marketing_Activity__c WHERE Marketing_Campaign__c = :MCamps[0].Id];

 		Map<Marketing_Campaign__c,List<Marketing_Activity__c>> CampaignData = CSVFileUtils.ProcessData(MCamps, MActs);


        for(Marketing_Campaign__c campaign :CampaignData.keyset()){

            filedata = CSVFileUtils.AddData(campaign,CampaignData.get(campaign),filedata);
        }
        System.assert(filedata != null);

        // then lets create a zip file in memory
        Zippex returnZip = new Zippex();
        returnZip = CSVFileUtils.ProduceZipFile(filedata);

        System.assert(returnZip != null);


        // then lets also add some more data
        String ProjectionData = '';
        for(Marketing_Campaign__c campaign :CampaignData.keyset()){

            ProjectionData = CSVFileUtils.AddProjectionData(campaign,CampaignData.get(campaign),ProjectionData);
        }
        System.assert(ProjectionData != '');
    }
}