public without sharing class  RedemptionSearchComponentController {
	
    private static final id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
    private static final id MICERedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('MICE Redeemable Campaign').getRecordTypeId();
         
	@AuraEnabled
    public static List<Campaign> findCampaigns(String searchKey) {
	
	boolean IdSearch = false;
	
if (string.isnotBlank(searchKey)) {
	system.debug('@@@@@@@@@@@@@@@@@  Search String : ' + searchKey +'(' + searchKey.length() + ')' ); 
} 
 		string loggedInUSerId = UserInfo.getUserId();
		list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :LoggedInUSerId
                            LIMIT 1];
		string usersVillage = users[0].Village__c;                   
        list<Campaign> returnList = new list<Campaign>();

		
		if (string.isnotBlank(searchKey)){	
			if (searchKey.length() > 2){
	        	if (searchKey.substring(0,3) == '701'){
	        		if (searchKey.length() < 15){
	        			searchKey = '';
	        		} else {
		        		searchKey = searchKey;
		        		if (searchKey.length() == 15 || searchKey.length() == 18){
		        			IdSearch = true;
		        		} else {
		        			searchKey = '';
		        		} 	
	    			}
	        	}
			}
		}
		
        if (string.isBlank(searchKey) || searchKey.length() <= 2){
        	returnList = null;
        } else {	        
	        	if (!IdSearch)
	        		searchKey = searchKey + '*';
		        List<List<SObject>> searchList = [FIND :searchKey IN ALL FIELDS 
		                                              RETURNING 
		                                                 Campaign (id, Name, Village__r.name, communication_Channel__c, Partner__r.Name, Description, isActive, calculated_Status__c,
		                                                            Total_Redemptions__c, Parent.Name, recordtypeid, QR_Code_Image__c, Group_Booking__c, COS_campaign__c
		                                                            WHERE recordtypeid IN  (:RedeemableCampRecordTypeId,:MICERedeemableCampRecordTypeId )
		                                                            AND Village__r.name = :usersVillage
		                                                            AND startDate <= :Date.today()
		                                                            AND endDate >= :Date.today())];
		    
				returnList = (list<Campaign>) searchList[0];
	    }
        
        
        return returnList;
        
    }

    
}