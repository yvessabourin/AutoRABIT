/* 
	Generic class to get and interact with countries data. Provides method to convert from country Code to Label and viceversa.
	Implemented with a private constructor following the Singleton Design patter for generic util classes ( https://developer.salesforce.com/wiki/apex_design_patterns#Singleton )
*/

public without sharing class HFS_CountryController {

	private List <HFS_Country_Data__c> countriesData = new List <HFS_Country_Data__c> ();
	private static HFS_CountryController countryCtrlInstance;
	private List<HFS_Country_Data__c> defaultCountries = new List <HFS_Country_Data__c> ();
	private List<HFS_Country_Data__c> otherCountries = new List <HFS_Country_Data__c> ();
	private Map <String, String> codeToLabelMap = new Map <String, String> ();
	private Map <String, String> labelToCodeMap = new Map <String, String> ();

    private HFS_CountryController() {

		this.countriesData = getCountriesData();

		for (HFS_Country_Data__c countryData : countriesData) {
			if (countryData.HFS_Default_Option__c) {
				defaultCountries.add(countryData);
			} else {
				otherCountries.add(countryData);
			}
			codeToLabelMap.put(countryData.HFS_Country_Code__c, countryData.HFS_Country_Name__c);
			labelToCodeMap.put(countryData.HFS_Country_Name__c, countryData.HFS_Country_Code__c);
		}

	}
	
	public static HFS_CountryController getInstance() {
		if (countryCtrlInstance == null) {
			countryCtrlInstance = new HFS_CountryController ();
		}
		return countryCtrlInstance;
	}

	private static List <HFS_Country_Data__c> getCountriesData () {
		return  [SELECT HFS_Country_Code__c, HFS_Country_Name__c, HFS_Default_Option__c FROM HFS_Country_Data__c ORDER BY HFS_Country_Name__c];
	}

	public List<HFS_Country_Data__c> getDefaultCountries() {
		return this.defaultCountries;
	}

	public List<HFS_Country_Data__c> getOtherCountries() {
		return this.otherCountries;
	}

	public String getCountryLabel (String countryCode) {
		if (codeToLabelMap.containsKey(countryCode)) {
			return codeToLabelMap.get(countryCode);
		} else {
			return '';
		}
	}

	public String getCountryCode (String countryLabel) {
		if (labelToCodeMap.containsKey(countryLabel)) {
			return labelToCodeMap.get(countryLabel);
		} else {
			return '';
		}
	}
}