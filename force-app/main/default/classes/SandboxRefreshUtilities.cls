public with sharing class SandboxRefreshUtilities {


	public static void loadChatterGroups(){
		
		
		try {
			
	  		// Retrieve list of Chatter Group names from Custom Setting definition object            
	  		list<VR1_Chatter_Groups__c> groupsList = VR1_Chatter_Groups__c.getall().values();
	  		
	  		// create list of Chatter group objects to insert
	  		list<CollaborationGroup> chatterGroupList = new list<CollaborationGroup>();
	  		
	  		for (VR1_Chatter_Groups__c grp :groupsList){
	  			
	  			CollaborationGroup chatterGroup = new CollaborationGroup(Name = grp.Group_Name__c, 
	  																	CollaborationType = 'Public');
	  			chatterGroupList.add(chatterGroup);
	  			
	  		}				
			
			if (!chatterGroupList.isEmpty()){
				Database.SaveResult[] resultList = null;
				resultList = Database.insert(chatterGroupList, false);
				for (Database.SaveResult r : resultList){  // Examine DML errors
  					if (!r.isSuccess()){  
    					for (Database.Error e : r.getErrors()){  
      						// errors here
				            System.debug('*** The following error has occurred. ***');                    
				            System.debug(e.getStatusCode() + ': ' + e.getMessage());
				            System.debug('Chatter Group fields that affected this error: ' + e.getFields());
    					}
  					}
				}				
			}
		
		} catch (exception e){
			
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
		
		}
		
	}
	
	
	// Populate Village lookup up data held in Custom Setting with data held against the custom Village object
	public static void refreshVillageRefData(){
		
		
		list<Village_Reference_Data__c> dataList = Village_Reference_Data__c.getall().values();
		if (!dataList.isEmpty()){
			delete dataList;
		}
		
		list<Village__c> villageList = [select Name, Region__c, Currency__c, Village_Local_Language__c, Village_Code__c
											from Village__c];
		
		if (!villageList.isEmpty()){
			list<Village_Reference_Data__c> settings = new list<Village_Reference_Data__c>();
			map<Id, Region__c> regionMap = new map<Id, Region__c>([select Id, Name from Region__c]);
			
			for (Village__c v :villageList){
				
				Village_Reference_Data__c setting = new Village_Reference_Data__c();
				setting.Name = v.Name;
				setting.Currency__c = v.Currency__c;
				setting.Language__c = v.Village_Local_Language__c;
				setting.MRI_Code__c = v.Village_Code__c;
				if (regionMap.get(v.Region__c) != null)
					setting.Region__c = regionMap.get(v.Region__c).Name;
				settings.add(setting);
				
			}
			
			insert settings;
			
		}
		
	}

}