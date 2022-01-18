// Ian Burton
// 15 June 2017
// Utility class to compile CSV file structure for export to Oracle
public with sharing class CSVFileUtils {
	
	// adds data to the MarketingData content for use in the CSV files for download
	
public static OracleMarketingCSVFilesData AddData(Marketing_Campaign__c MarketingCampaign, List<Marketing_Activity__c> MarketingActivities, OracleMarketingCSVFilesData InputOracleMarketingCSVData){

		// firstly populate the Marketing Campaign data
		DateTime projstartDate = Datetime.newInstance(MarketingCampaign.Start_Date__c.year(), MarketingCampaign.Start_Date__c.month(),MarketingCampaign.Start_Date__c.day(),0,0,0);
      	DateTime projendDate = Datetime.newInstance(MarketingCampaign.End_Date__c.year(), MarketingCampaign.End_Date__c.month(),MarketingCampaign.End_Date__c.day(),0,0,0);
      	
      	String CampaignType = MarketingCampaign.RecordType.Name;
        // Campaign type needs to be village or group only, so we need to strip out the 'Campaign' part
        CampaignType = CampaignType.replace('Campaign', '');
        CampaignType = CampaignType.trim(); // also trim off some whitespaces

      	String MCShortDescription = MarketingCampaign.Short_Description__c;
		if(MCShortDescription == null){
			MCShortDescription = '';
		}
		else
		{
			// replace all commas, since this is going to be a CSV
			MCShortDescription = MCShortDescription.ReplaceAll(',',' ').replaceAll('\\n', ' ').replaceAll('\\r', ' ');
		}

		// now we need to deal with the 'Group level' items
		String TemplateNumber = MarketingCampaign.Village__r.Oracle_Source_Template_Number__c;
		String OracleOrganisation = MarketingCampaign.Village__r.Oracle_Organisation__c;
		if(CampaignType.toLowerCase() == 'group'){
			// if its a group level campaign/activity, then it needs PLC mappings
			TemplateNumber = 'VR Campaign Projects UG01';
			OracleOrganisation = 'UG01_Group Brand & Communications';
		}
		String docProjectContent =  MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',,' + TemplateNumber + ',,' + MarketingCampaign.Marketing_Campaign_Ref__c + ',' + OracleOrganisation + ',,' + MCShortDescription + ',,,' + MarketingCampaign.Owner.Email + ',' + projstartDate.format('yyyy/MM/dd') + ',' + projendDate.format('yyyy/MM/dd') + ',,Approved,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,N,,,,Y,,,,,' +  MarketingCampaign.Marketing_Campaign_Ref__c + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END\r\n'; 

		// then do the Mareting Activity data
		String docTaskContent = '';
		for(Marketing_Activity__c ma :MarketingActivities){
			String MAName = ma.Name.ReplaceAll(',',' ').replaceAll('\\n', ' ').replaceAll('\\r', ' '); // need to clean the activities name, since some have commas in :( 
	      	DateTime startDate = Datetime.newInstance(ma.Start_Date__c.year(), ma.Start_Date__c.month(),ma.Start_Date__c.day(),0,0,0);
	      	DateTime endDate = Datetime.newInstance(ma.End_Date__c.year(), ma.End_Date__c.month(),ma.End_Date__c.day(),0,0,0);
	     
	         docTaskContent += MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',,' + MAName + ',' + ma.Marketing_Activity_Ref__c + ',' + MAName + ',,' + startDate.format('yyyy/MM/dd') + ',' + endDate.format('yyyy/MM/dd') + ',,,Y,N,N,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END\r\n'; 
		}

        // then do the team member data
        String docTeamMembersContent = MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',,,' + MarketingCampaign.Owner.email + ',Project Administrator,' +  projstartDate.format('yyyy/MM/dd') + ',' + projendDate.format('yyyy/MM/dd') + ',,END\r\n'; 


        // then do the classifications data

        String docClassificationsContent = ''; //campaign.Name + ' - ' + campaign.Marketing_Campaign_Ref__c + ',,,' + campaign.Owner.email + ',Project Administrator,' + campaign.Start_Date__c + ',' + campaign.End_Date__c + ',\r\n'; 
    	docClassificationsContent += MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',Cost Centre,310,END\r\n';
    	docClassificationsContent += MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',Asset Type,Default,END\r\n';
    	// campaign theme is not required apparently
    	//docClassificationsContent += MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',Campaign Theme,' + MarketingCampaign.Parent_Marketing_Campaign__r.Name + ',\r\n';
    	docClassificationsContent += MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',Campaign Type,' + CampaignType + ',END\r\n';

    	// now we can return the object with the added data
    	InputOracleMarketingCSVData.ProjectContent += docProjectContent;
    	InputOracleMarketingCSVData.TaskContent += docTaskContent;
    	InputOracleMarketingCSVData.TeamMembersContent += docTeamMembersContent;
    	InputOracleMarketingCSVData.ClassificationsContent += docClassificationsContent;

    	return InputOracleMarketingCSVData;    

	}

public static String AddProjectionData(Marketing_Campaign__c MarketingCampaign, List<Marketing_Activity__c> MarketingActivities, String InputOracleMarketingCSVData){

System.debug('AddProjectionData ====== ');
		try{
			// firstly populate the Marketing Campaign data
			DateTime projstartDate = Datetime.newInstance(MarketingCampaign.Start_Date__c.year(), MarketingCampaign.Start_Date__c.month(),MarketingCampaign.Start_Date__c.day(),0,0,0);
	      	DateTime projendDate = Datetime.newInstance(MarketingCampaign.End_Date__c.year(), MarketingCampaign.End_Date__c.month(),MarketingCampaign.End_Date__c.day(),0,0,0);
	      	
	      	// String monthName= d.format(‘MMM’); // will result in short text month (Aug Jun Jul Jan etc...)
			String monthName= projstartDate.format('MMM');
			// need to do some weird stuff with this... need to replace march with Q1 etc...
			if(monthName == 'Mar')
			monthName = 'Q1';
			if(monthName == 'Jun')
			monthName = 'Q2';
			if(monthName == 'Sep')
			monthName = 'Q3';
			if(monthName == 'Dec')
			monthName = 'Q4';

	      	String CampaignType = MarketingCampaign.RecordType.Name;
	        // Campaign type needs to be village or group only, so we need to strip out the 'Campaign' part
	        CampaignType = CampaignType.replace('Campaign', '');
	        CampaignType = CampaignType.trim(); // also trim off some whitespaces

	      	String MCShortDescription = MarketingCampaign.Short_Description__c;
			if(MCShortDescription == null){
				MCShortDescription = '';
			}
			else
			{
				// replace all commas, since this is going to be a CSV
				MCShortDescription = MCShortDescription.ReplaceAll(',',' ').replaceAll('\\n', ' ').replaceAll('\\r', ' ');
			}
			
			// loop each month in the range
			DateTime d1 = projstartDate;
			DateTime d2 = projendDate;
			Set<String> monthYearSet = new Set<String>();

			while(d1 <= d2)
			{
			    monthYearSet.add(d1.format('MMM'));
			    d1 = d1.AddMonths(1);
			}

			// MA = Budget__c
			// MC = Village_Marketing_Budget__c 
			Decimal monthlyAmount = 0;
			if(MarketingCampaign.Village_Marketing_Budget__c > 0){
				// risk of divide by zero...
					monthlyAmount = (MarketingCampaign.Village_Marketing_Budget__c / monthYearSet.size());
			}
			
			
			String docCampaignContent =  '';
			for(String month :monthYearSet){
				//Sales Force Ref Number-FRC-DDMMYYYY
					docCampaignContent +=  'Business Forecast - ' + monthName + ',' + MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',,' + MarketingCampaign.Name + ',,' + MarketingCampaign.Marketing_Campaign_Ref__c + '-FRC-' + projstartDate.format('ddMMYYYY') + ',As Approved in SalesForce,Approved,Financial Resources,';
					docCampaignContent += ' ' + month + '-' + projstartDate.format('YY') + ',' + MarketingCampaign.CurrencyIsoCode + ',,' + monthlyAmount + ',,' +MarketingCampaign.Marketing_Campaign_Ref__c + '-FRC-' + projstartDate.format('ddMMYYYY') + ',END\r\n';		
			}
			
			// then do the Mareting Activity data
			String docActivityContent = '';
			for(Marketing_Activity__c ma :MarketingActivities){
				String MAName = ma.Name.ReplaceAll(',',' ').replaceAll('\\n', ' ').replaceAll('\\r', ' '); // need to clean the activities name, since some have commas in :( 
		      	DateTime startDate = Datetime.newInstance(ma.Start_Date__c.year(), ma.Start_Date__c.month(),ma.Start_Date__c.day(),0,0,0);
		      	DateTime endDate = Datetime.newInstance(ma.End_Date__c.year(), ma.End_Date__c.month(),ma.End_Date__c.day(),0,0,0);
		     
			     // loop each month in the range
				DateTime mad1 = startDate;
				DateTime mad2 = endDate;
				Set<String> MAmonthYearSet = new Set<String>();

				while(mad1 <= mad2)
				{
				    MAmonthYearSet.add(mad1.format('MMM'));
				    mad1 = mad1.AddMonths(1);
				}
				Decimal MAmonthlyAmount = 0;
				if(ma.Budget__c > 0){
					// risk of divide by zero...
						MAmonthlyAmount = (ma.Budget__c / monthYearSet.size());
				}
				
				for(String mamonth :MAmonthYearSet){
		     		docActivityContent += 'Business Forecast - ' + monthName + ',' + MarketingCampaign.Name + ' - ' + MarketingCampaign.Marketing_Campaign_Ref__c + ',,' + MAName + ',,' + ma.Marketing_Activity_Ref__c + '-FRC-' + startDate.format('ddMMYYYY') + ',As Approved in SalesForce,Approved,Financial Resources,';
		     		docActivityContent += ' ' + mamonth + '-' + startDate.format('YY') + ',' + ma.CurrencyIsoCode + ',,' + MAmonthlyAmount + ',,' +ma.Marketing_Activity_Ref__c + '-FRC-' + startDate.format('ddMMYYYY') + ',END\r\n';				         
		     	}
			}
	      	System.debug('InputOracleMarketingCSVData ====== ' + InputOracleMarketingCSVData + docCampaignContent + docActivityContent);
	    	return InputOracleMarketingCSVData + docCampaignContent + docActivityContent;    
    	}
    	catch(Exception ex){
    		System.debug('An exception has occurred: '  + ex.getMessage() + '========' + ex.getStackTraceString());
    		return 'An exception has occurred: '  + ex.getMessage() + '========' + ex.getStackTraceString();

    	}

	}


	public static Zippex ProduceZipFile(OracleMarketingCSVFilesData MarketingData)
	{

		Zippex returnZip = new Zippex();
	    returnZip.addFile('PjfProjectsAllXface.csv', Blob.valueOf(MarketingData.ProjectContent) , null);
	    returnZip.addFile('PjfProjElementsXface.csv', Blob.valueOf(MarketingData.TaskContent), null);
	    returnZip.addFile('PjfProjectPartiesInt.csv', Blob.valueOf(MarketingData.TeamMembersContent), null);
	    // Finance no longer want the Classifications file
	    //returnZip.addFile('PjfProjectClassesInt.csv', Blob.valueOf(MarketingData.ClassificationsContent), null);

	    return returnZip;
	}

	public static Zippex ProduceProjectionZipFile(String FileContent, String FileContentName)
	{

		Zippex returnZip = new Zippex();
	    returnZip.addFile(FileContentName + '.csv', Blob.valueOf(FileContent) , null);

	    return returnZip;
	}

// takes the lists of campaigns and activities, and returns a nice map of each
public static Map<Marketing_Campaign__c,List<Marketing_Activity__c>> ProcessData(List<Marketing_Campaign__c> campaigns, List<Marketing_Activity__c> activities){

	Map<Marketing_Campaign__c,List<Marketing_Activity__c>> FinalReturnMap = new Map<Marketing_Campaign__c,List<Marketing_Activity__c>>();

	for(Marketing_Campaign__c camp :campaigns){
		integer activitycount = 0;
		List<Marketing_Activity__c> actlist = new List<Marketing_Activity__c>();
		for(Marketing_Activity__c act : activities){
			if(act.Marketing_Campaign__c == camp.Id){
				// then add the activity to the list
				actlist.add(act);
				activitycount++;
			}
		}
		// then after adding all the activities to the list, if there are none, then we skip the campaign (we dont want campaigns with no activites)
		if(activitycount > 0){
			FinalReturnMap.put(camp,actlist);
		}

	}
	return FinalReturnMap;
}

	public class OracleMarketingCSVFilesData
	{
		    public OracleMarketingCSVFilesData(){
	                    
	        this.ProjectContent = '';
	        this.TaskContent = '';
	        this.TeamMembersContent = '';
	        this.ClassificationsContent = '';
	        
	    }

		public String ProjectContent {get; set;}
		public String TaskContent {get; set;}
		public String TeamMembersContent {get; set;}
		public String ClassificationsContent {get; set;}
	}
}