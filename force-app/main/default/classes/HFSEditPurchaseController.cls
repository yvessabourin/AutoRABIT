global with sharing class HFSEditPurchaseController {

	private final sObject mysObject;

	public HFSEditPurchaseController(ApexPages.StandardController controller) {  
 		this.mysObject = (sObject)controller.getRecord();
  	}  

	  @RemoteAction
	  global static String getCase(String message){
	      Case guestCase = [SELECT Id FROM Case WHERE Client_QR_Code__c = :message];
	      system.debug(guestCase.Id);
	      return guestCase.Id;
	  }
}