/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PicklistUtilitiesTest {

    static testMethod void testGetPicklistValues() {
        
    	map<string, string> returnMap = PicklistUtilities.getPicklistValues('Account', 'AccountSource', null);
    	
    	system.assert(returnMap.keySet().size() > 0 );
    	
		// test sorting
		list<SelectOption> poList = new list<SelectOption>();
		for (string key :returnMap.keySet()){
			poList.add(new SelectOption(key, returnMap.get(key)));
		}
		// sort the list for coverage
		poList = PicklistUtilities.selectOptionSortByLabel(poList);
    
    
    }
    
	static testMethod void testValidatePicklistValue() {
        
    	boolean valid = PicklistUtilities.validateValue('Account', 'AccountSource', 'nonsense', null);
    	
    	system.assertEquals(valid, false);
 
     	valid = PicklistUtilities.validateValue('Account', 'AccountSource', 'Other', null);
    	
    	system.assertEquals(valid, true);   
    
    }
    
    
	static testMethod void testTechnicalError() {
        
    	map<string, string> returnMap = PicklistUtilities.getPicklistValues('Not an object', 'AccountSource', null);
    	
    	system.assertEquals(returnMap, null);
    	
    	try {
    		boolean valid = PicklistUtilities.validateValue('Not an object', 'AccountSource', 'nonsense', null);
    	} catch (exception e){
    		system.assert(e.getMessage().length() > 0);
    	}
    }
    
}