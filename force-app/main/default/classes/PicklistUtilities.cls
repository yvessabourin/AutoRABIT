/************************************************
Author : Constantine Chimonides
Class Purpose : Helper class to retrieve values from a Picklist and validate entries

Version History:
================
Created  : 28/03/2014

************************************************/
public with sharing class PicklistUtilities {

	
	// return a map of the picklist values for an object field, with the label as the key
	// an optional argument of the field schema map can be passed into the method to avoid
	// too many global describe governor limits.
	public static map<string, string> getPicklistValues(string objectName, string fieldName, Map<String, Schema.SObjectField> objectFields){
		
		map<string, string> returnMap = new map<string, string>();
   		
   		try {
   			
   			// retrieve all Sobject fields (check whether object field schema has been passed, otherwise create)
   			if (objectFields == null){
				objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();         
   			}
   			
			Schema.SObjectField sfield = objectFields.get(fieldName);
            	schema.describeFieldResult dfield = sfield.getDescribe();

        	List<Schema.PicklistEntry> listValues = dfield.getPicklistValues();
        	for (Schema.PicklistEntry ps :listValues){
            	returnMap.put(string.valueOf(ps.label), string.valueOf(ps.value));
        	}
	
		
		} catch (exception e){
	       
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());			
	    	return null;   	
		}
       
		return returnMap;       
		
	}


	// return a boolean, indicating whether a picklist selection is valid
	public static boolean validateValue(string objectName, string fieldName, string value, Map<String, Schema.SObjectField> objectFields){
		
		boolean returnValue =  false;
   		
   		try {
   			
			map <string, string> picklistMap =  getPicklistValues(objectName, fieldName, objectFields);
			
			if(picklistMap.containsKey(value)){
				returnValue = true;
			}
			
		} catch (exception e){
	       
			system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());			
	    	return returnValue;   	
		}
       
		return returnValue;       
		
	}

	//Utility method to sort picklist values alphabetically
     public static list<selectOption> selectOptionSortByLabel(list<selectOption>
                                                            selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
    
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];


        for(selectOption SO : selectOptionsToSort){
            if (SO.getLabel() != pivotValue.getLabel()){
                if(SO.getLabel() <= pivotValue.getLabel()){
                    lessSelectOption.add(SO);
                }else if(SO.getLabel() > pivotValue.getLabel()){
                    greaterSelectOption.add(SO);   
                }
             }
        }

        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }


}