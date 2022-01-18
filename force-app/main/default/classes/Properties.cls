/**
 * Global Properties Class
 * Used to store static global system settings and settings stored in the Global_Properties__c config custom setting.
 */
public without sharing class Properties {
	/**
	 * Basic Global Properties Exception
	 */
	public class globalPropException extends Exception {}

    /**
     * Retrieve String property value as it is stored in Global_Properties__c
     */
    private static String getValue(String key) {
        String returnVal;

        try {
	        Global_Properties__c gProp = Global_Properties__c.getInstance(key);

	        if (gProp != null) {
	            returnVal = gProp.Value__c;
	        } else {
	            throw new globalPropException ();
	        }
        } catch (Exception ex) {
        	system.debug('GLOBAL PROPERTY ERROR: ' + key);
        }
        return returnVal;
    }
    
    /**
     * Retrieve Integer property value converted from String stored in Global_Properties__c to Integer
     */
     /*
    private static Integer getIntegerValue(String key) {
    	Integer returnVal;
    	try {
	        Global_Properties__c gProp = Global_Properties__c.getInstance(key);

	        if (gProp != null) {
	        	if(gProp.Value__c!=null)
        			returnVal = Integer.valueOf(gProp.Value__c);
	        } else {
	            throw new globalPropException ();
	        }
        } catch (Exception ex) {
        	system.debug('GLOBAL PROPERTY ERROR: ' + key);
        }
        return returnVal;
    }
    */
    /*
    private static Set<String> getList(Map<String,SObject> customSettings){
    	if(customSettings!=null && customSettings.size()>0)
    		return customSettings.KeySet();
    	else
    		return new Set<String>();
	}
	
	private static void setValue(String key,String value){
		try {
	        Global_Properties__c gProp = Global_Properties__c.getInstance(key);

	        if (gProp != null) {
	        	gProp.Value__c = value;     
	        	update gProp;			
	        } else {
	            throw new globalPropException ();
	        }
	
        } catch (Exception ex) {
        	system.debug('GLOBAL PROPERTY ERROR: ' + key);
        	// ErrorLogger.insertSingleError('GLOBAL PROPERTY ERROR: ' + key , ex, null, 'Properties', ErrorLogger.ERROR);
        }
	}
	*/
	
	// Start of Account Record Types
	public static ID PERSON_ACCOUNT_RECORD_TYPE { get { return getValue('PERSON_ACCOUNT_RECORD_TYPE'); } }
	// End of Account Record Types

	// Start of Profile Record Types
    public static ID SYSTEM_ADMINISTRATOR_PROFILE { get { return getValue('SYSTEM_ADMINISTRATOR_PROFILE'); } }
    // End of Profile Record Types

    // Start of Redemption Config
    /*
	public static Integer BARCODE_CUSTOMER_SEARCH_PAGE_SIZE { get { return getIntegerValue('BARCODE_CUSTOMER_SEARCH_PAGE_SIZE'); } }
	public static Integer BARCODE_CUSTOMER_SEARCH_MAX_RECORDS { get { return getIntegerValue('BARCODE_CUSTOMER_SEARCH_MAX_RECORDS'); } }
	public static Integer BARCODE_CAMPAIGN_SEARCH_PAGE_SIZE { get { return getIntegerValue('BARCODE_CAMPAIGN_SEARCH_PAGE_SIZE'); } }
	public static Integer BARCODE_CUSTOMER_ACTIVITY_MAX_RECORDS { get { return getIntegerValue('BARCODE_CUSTOMER_ACTIVITY_MAX_RECORDS'); } }
	*/
    // End of Redemption Config

    // Start of General Settings
    public static boolean IS_TEST_METHOD = false;
    public static ID PROD_ORGANIZATION_ID { get { return getValue('PROD_ORGANIZATION_ID'); } }    
    public static boolean IS_PROD = UserInfo.getOrganizationId() == PROD_ORGANIZATION_ID;
    public static boolean IS_SANDBOX = UserInfo.getOrganizationId() != PROD_ORGANIZATION_ID;
    // End of General Settings
    
	/*
    public static boolean IS_DEMO = false;
    public static boolean IS_UAT = UserInfo.getUserName().endsWith('sfig');
    public static boolean IS_FUTURE = false;
    public static boolean CONTACT_UPDATE_TRIGGER_COMPLETED = false;
    public static final Integer TRANSACTIONS_PERIOD_OF_TIME = 60;
    public static List<String> TEST_EMAILS { get { return new List<String> {'@igindex','@igmarkets','@iggroup','@extrabet','@fxonline'}; } }
    public static Set<String> EMAIL_WHITE_LIST { get { return getList(Email_White_List__c.getAll()); } }
    public static Set<String> EMAIL_BLACK_LIST { get { return getList(Email_Black_List__c.getAll()); } }
    public static Set<Double> ClientfailedStatusCodes { get { return new Set<Double>{54,55,56,57,58,59,70,71,75,76}; } }

    public static Set<String> AFRICAN_OFFICE_COUNTRIES = new Set<String>{'LS', 'NA', 'SZ', 'ZA'};

	// Case allocation
	public static string CASE_ALLOCATION_IN_PROGRESS { get { return getValue('CASE_ALLOCATION_IN_PROGRESS'); } set { setValue('CASE_ALLOCATION_IN_PROGRESS',value);} }
	public static id CASE_ALLOCATION_JOBID{ get { return getValue('CASE_ALLOCATION_JOBID'); } set { setValue('CASE_ALLOCATION_JOBID',value);} }
   
    // Reallocation Lead Score Master Switch
    public static boolean ENABLE_LEAD_SCORE_IN_REALLOCATIONS { get { return getValue('ENABLE_LEAD_SCORE_IN_REALLOCATIONS').equals('true');}}

	// Date values to use instead of of Date.today and System.today in order to set date in our code
	public static Date USER_CURRENTDATE = Date.today();
	public static Date SYSTEM_CURRENTDATE = System.today();
	// End Date values
	*/
}