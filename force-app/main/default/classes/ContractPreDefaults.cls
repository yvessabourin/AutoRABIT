/************************************************
Author : Constantine Chimonides
Purpose : Class created to handle before insert trigger when creating a new
		Opportunity Contract


Version History:
================
Created  : 22/11/2013

************************************************/

public with sharing class ContractPreDefaults {

	// Method to predefault values from associated village record on a new Opportunity Contract
	public static void PreDefaultValuesFromOpportunity(list<Contract> contractList){
		
		// Variable used for debug purposes
		string processField = '';
		
		try{
			if (!contractList.isEmpty()){
				
				//Setup map of village fields to contract fields, with village fields as key.
				map <string, string> villageContractFieldMap = new map <string, string>();
				
				villageContractFieldMap.put('Currency__c',	'Currency__c');				
				villageContractFieldMap.put('Projected_Annual_Sales_Uplift__c','Annual_Sales_Uplift_Projection__c');			
				villageContractFieldMap.put('Std_Break_Clause__c','Landlords_Break_Rights__c');
				villageContractFieldMap.put('Std_Base_Rent__c','Notional_Base_Rent__c');
				villageContractFieldMap.put('Std_Base_Rent_Clause__c','Base_Rent_Clause__c');	
				villageContractFieldMap.put('Std_Deposit_Clause__c','Deposit_Clause__c');
				villageContractFieldMap.put('Std_Deposit_Period_months__c','Deposit_Period_months__c');
				villageContractFieldMap.put('Std_Fit_Out_days__c','Fitting_out_Period_days__c');
				villageContractFieldMap.put('Std_Fit_Out_weeks__c','Fitting_Out_Period_weeks__c');
				villageContractFieldMap.put('Std_Fit_Out_Clause__c','Fit_Out_Clause__c');
				villageContractFieldMap.put('Std_Initial_Marketing_Fee_Clause__c','Initial_Marketing_Fee_Clause__c');
				villageContractFieldMap.put('Std_Lease_Term_Clause__c','Term_Clause__c');
				villageContractFieldMap.put('Std_Lease_Term_months__c','ContractTerm');
				villageContractFieldMap.put('Std_Legal_Costs_Clause__c','Legal_Costs_Clause__c');
				villageContractFieldMap.put('Std_Legal_Fees__c','Legal_Costs__c');
				villageContractFieldMap.put('Std_LFDA_Fee__c','LFDA_Fee__c');
				villageContractFieldMap.put('Std_Licence_Fee_Clause__c','Licence_Fee_Clause__c');
				villageContractFieldMap.put('Std_LSA_Fee_Clause__c','LFDA_Fee_Clause__c');
				villageContractFieldMap.put('Std_Management_Fee__c','Service_Charge__c');
				villageContractFieldMap.put('Std_Maintenance_Period__c','Maintenance_Period_years__c');
				villageContractFieldMap.put('Std_Marketing_Fee__c','Initial_Marketing_Fee__c');
				villageContractFieldMap.put('Std_Non_Compete_Clause__c','Competition_Clause__c');
				villageContractFieldMap.put('Std_Non_Compete_Distance__c','Non_Compete_Distance__c');
				villageContractFieldMap.put('Std_Notice_Period_months__c','Notice_Period_months__c');
				villageContractFieldMap.put('Std_Relocation_Clause__c','Landlords_Relocation_Rights__c');	
				villageContractFieldMap.put('Std_Repayment_Clause__c','Repayment_Terms__c');
				villageContractFieldMap.put('Std_Service_Charge_Clause__c','Management_Fee_Clause__c');
				villageContractFieldMap.put('Std_T_O_Rent_Clause__c','Turnover_Rent_Clause__c');
				villageContractFieldMap.put('Std_Trading_Hours_Clause__c','Trading_Hours__c');
				villageContractFieldMap.put('Default_Contract_Type__c','Contract_Type__c');
				villageContractFieldMap.put('Std_Repayment_Clause__c','Repayment_terms__c');
				
				villageContractFieldMap.put('Village_Size_Metric__c','Size_Metric__c');
				villageContractFieldMap.put('Std_Charge_Basis__c','Charge_Basis__c');
				villageContractFieldMap.put('Std_Billing_Frequency__c','Billing_Frequency__c');
				villageContractFieldMap.put('Std_Service_Charge_Basis__c','Service_Charge_Fee_Basis__c');
				villageContractFieldMap.put('Std_Maintenance_Clause__c','Maintenance_Clause__c');
				           
				// Create schema map, to check field data types when required
				Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        		Schema.SObjectType leadSchema = schemaMap.get('Contract');
        		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
				
				
				//To avoid running queries in a for loop, retrieve required objects and ids
				// in a list (or set) to use when processing contracts list.
				
				// First retrieve opportunityIds from contract list
				set<string> oppIds = new set <string>();
				for (Contract contract :contractList){
					oppIds.add(contract.Opportunity__c);	 
				}
				// retrieve village Id from opportunity list
				list<Opportunity> oppList = [select Id, Village__c from Opportunity where id in :oppIds];
				set<string> villageIds = new set<string>();
				for(Opportunity opp :oppList){
					villageIds.add(opp.Village__c);
				}
				
				// construct query to retrieve associated Village objects
				// with required predefault field values
				string soqlVillage = 'select ';
				for (string fld :villageContractFieldMap.keySet()){
					soqlVillage += fld + ',';
					string contractFld = villageContractFieldMap.get(fld);
				}	
				soqlVillage = soqlVillage.removeEnd(',');
				soqlVillage += ' from Village__c where Id in :villageIds';				
				
				// Query for Village data
				list<Village__c> villageList = Database.query(soqlVillage);
				
				//Loop through contract list
				for (Contract contract :contractList){
					
					// Retrieve contract opportunity id
					string opportunityId = Contract.Opportunity__c;
					string villageId = '';
					// retrieve village Id associated with opportunity
					for(Opportunity opp :oppList){
						if (opp.Id == opportunityId){
							villageId = opp.Village__c;
							break;
						}						
					}
					
					// Now populate contract predefault values by using the appropriate
					// village object
					for (Village__c village :villageList){
						if (village.Id == villageId){ // Village Id  is the same as Contract village id
							// stamp village Id onto the contract
							contract.Village__c = villageId;
							// Predefault other contract values from village object
							for (string fld :villageContractFieldMap.keySet()){
								string contractFld = villageContractFieldMap.get(fld);
								processField = contractFld + ' = ' + village.get(fld);
								Schema.DisplayType fielddataType = fieldMap.get(contractFld).getDescribe().getType();
								
								// To avoid Double -> integer errors, convert required values
								if(fielddataType == Schema.DisplayType.Integer){
									contract.put(contractFld, Integer.valueOf(village.get(fld)));
								} else {											
									contract.put(contractFld, village.get(fld));
								}
							}							
							break;
						}
					}
				}
			}			
			
		} catch (exception e){
			// Log technical error
			system.debug(e.getMessage() + ' : ' + e.getStackTraceString() + ' * Process Field * ' + processField);	
		}
		
	}


}