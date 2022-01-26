public with sharing class TenancyUtilities {

	//to-do : filter on the opportunity status
	
		//send and return a single instance of an opportunity
		public static Opportunity getTenancy(string village, string brand){
		
			Opportunity tenancy = null;
			try{
				tenancy	= [SELECT id, name, village__r.name, village__r.Village_code__c, 
									Account.name, StageName, RecordTypeId, RecordTypeName__c 
									FROM Opportunity 
									WHERE (Village__r.Name = :village OR Village__r.Village_Code__c = :village)
									AND (account.Name = :brand) 
									order by RecordTypeName__c desc
									LIMIT 1];
			} catch (Exception e){
				tenancy = null;	
			}	
								 
			return tenancy;
		}//end method
	
	
		//[overload]send and return a single instance of an opportunity
		public static map<string, map<string,Opportunity>> getTenancy(map<string, list<string>> brandsVillages){
			
			//extract all the brands
			set<string> brandset = brandsVillages.keyset();
				system.debug('brandset: ' + brandset);
			
			set<string> villageset = new set<string>();
			
			//extract all the villages and put them in the set
			for (string brand : brandset) {
					
				 list<string> villages =  brandsVillages.get(brand);
				
				for (string village : villages){
					villageset.add(village);
				}
					
			}
				system.debug('villageset: ' + villageset);
			
			
			//Get all possible opportunities given all villages from all brands (OR) from above variables
			//This enables us to run just one SOQL call.
			list<Opportunity> tenancies = [SELECT id, name, village__r.name, village__r.Village_code__c, Account.name, StageName FROM Opportunity WHERE (Village__r.Name in :villageset OR Village__r.Village_Code__c = :villageset) AND account.Name in :brandset];
				system.debug('opportunities returned: ' + tenancies);
			
			//create a map that matches the return type of the method
			map<string, map<string,Opportunity>> brandVillageTenancies = new map<string, map<string,Opportunity>>();
				
				
			//loop through all the unique brands sent through
			for (string brand: brandset){
				system.debug('in loop, working through the brands: ' + brand);
				
				//create the village-->oppid map which is embedded into the brandVillageTenancies map
				map<string ,Opportunity> villageTenancy = new map<string ,Opportunity>();
				
				//now loop through the tenancies(opportunities) that were returned from our 1 x soql
				for (opportunity tenancy : tenancies ) {	
					//if the brand we are looping through matches the brand on the opportunity then add the tenancy
					//details to the village-->oppid map 
					if(brand == tenancy.account.name){
						system.debug('in the returned opp loop. brand: ' + brand + '. Village: ' + tenancy.village__r.name + '. tenancyid: ' + tenancy.id);
						villageTenancy.put(tenancy.village__r.name, tenancy);
					}
				}
				//add to brandVillageTenancies MAP here
				brandVillageTenancies.put(brand, villageTenancy);
			
			}//end loop. Go and fetch the next brand and go through the returned opportunities again.
		
			system.debug('brandVillageTenancies to returned: ' + brandVillageTenancies);
			
			return brandVillageTenancies;
		}//close method
		
		
		// method to create a shell 'dummy' tenancy record
		public static Opportunity createDummyTenancy(Id brandId, string village, string description, string ownerId){
			
			Opportunity dummyOpp = null;
			boolean createDummy;
			string dummyRecTypeId = '';
			
	
		
			VR1_Configuration_Settings__c settings = VR1_Configuration_Settings__c.getInstance();
					
			if (test.isRunningTest()){
				createDummy = true;
				//dummyRecTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Tenancy Agreement').RecordTypeId;
			} else {
				createDummy = settings.Create_Dummy_Opportunities__c;
				dummyRecTypeId = settings.Dummy_Opportunity_Record_Type_ID__c;
			}
				
			if (createDummy){
				Id villageId = [select Id from village__c where name=:village or village_code__c =:village].Id;
				//to do ... default record type	
				dummyOpp = new Opportunity(village__c = villageId, AccountId = brandId, Name = '<Blank>',
														StageName = 'Initial Conversation', CloseDate=system.today().addDays(180),
														Description = description);
	
				if (string.isnotBlank(ownerId)){
					dummyOpp.OwnerId = ownerId;
				}
	
				insert dummyOpp;
	
			}
			
			return dummyOpp;
		}
	
	}//end class