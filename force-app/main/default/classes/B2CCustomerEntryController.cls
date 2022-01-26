public with sharing class B2CCustomerEntryController {

	private b2c_customer__c customer {get; set;}
    private ApexPages.StandardController controller {get; set;}
    private boolean partnerInput = false;
    private string village;
    
    public B2CCustomerEntryController(ApexPages.StandardController controller) {

		this.controller = controller;
		initValues();

    }
	

	
	public PageReference initValues(){

		this.customer = (b2c_customer__c) controller.getRecord();

		string inputType = ApexPages.currentPage().getParameters().get('InputType'); 
		if (string.isnotBlank(inputType)){
			partnerInput = true;			
			customer.leadSource__c = inputType;					
		}
		
		if (string.isBlank(village)){
			string userId = userInfo.getUserId();
			User u = [select village__c from User where Id = :userId];
			village = u.Village__c;
			if (string.isnotBlank(village)){
				Village__c v = [select Village_Code__c from Village__c where Name = :village];
				string villageCode = v.Village_Code__c;
				customer.primaryVillage__c = villageCode;
			}
		}
		return null;		
		
	}
	
	public PageReference saveRecord(){
		
		PageReference pg = null;
		string prefix = '';
		this.customer = (b2c_customer__c) controller.getRecord();
		VR1_Configuration_Settings__c orgSettings = VR1_Configuration_Settings__c.getOrgDefaults();
		string homeUrl = orgSettings.Salesforce_Instance_URL__c;		
				
		try {
		
			//pg = controller.save();			
			insert customer;
 			Schema.DescribeSObjectResult objectSchema = Schema.getGlobalDescribe().get('b2c_customer__c').getDescribe();
        	prefix = objectSchema.getKeyPrefix();
        	pg = new PageReference(homeUrl + '/' + prefix + '/o');	
			
		} catch (exception e){
			
			string errMsg = e.getMessage();
			
			if (errMsg.indexOf('duplicate value found') > -1){				
				integer pos1 = errMsg.lastIndexOf('id:');
				integer pos2 = errMsg.lastIndexOf(':');				
				string dupeId = errMsg.substring(pos1 + 4 , pos2);
		
				errMsg = 'This email address is already registered. Please enter a different email address or <a href="' + homeUrl + '/' + dupeId +'">click here</a> to view the existing customer.';				
				pg = null;
			} else {
				
				errMsg = 'A technical error has occurred, record could not be saved. ' + e.getMessage();
				
			}
			
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
			
		}
		
		return pg;
		
	}

}