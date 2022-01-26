public with sharing class ProgressDealController {
	
	public Opportunity deal {get; set;} // current deal in focus
	public Opportunity synchedDeal {get; set;} // reference to deal curently synched with Village Presence (if different from current)
	public boolean dealSynched {get; set;} // flag to indicate another deal is synched with Village Presence	
	public PageReference vpUpdatePage {get; set;} //
	public string vpUpdatePageUrl {get; set;} 
	public boolean disableAutoSynch {get; set;}
	public boolean hideAutoSynch{get; set;}
	public boolean enableSaveBtn {get; set;}
	
	
	private string previousStage = ''; // stage value prior to current update (used where process is cancelled) 
	private boolean currentlySynched = false;  // flag to indicate current deal is already synched with village presence

	// constructor method
	public ProgressDealController(ApexPages.StandardController controller){
		
		vpUpdatePage = null;
		vpUpdatePageUrl = '';
		disableAutoSynch = false;
		hideAutoSynch = false;
		enableSaveBtn = true;
		
		// retrieve current deal data
		dealSynched = false;
		string recId = controller.getId();
		
		string query = 'SELECT ';
		for(Schema.FieldSetMember f : this.getFields()) {
			query += f.getFieldPath() + ', ';
		}
		query += 'Id, Name, Auto_Sync__c, Lease_Type__c , Village_Presence__r.Deal_in_Progress__c';  
		query += ' FROM Opportunity WHERE Id = :recId';
		this.deal = Database.query(query);
				
		currentlySynched = this.deal.Auto_Sync__c;
		previousStage = this.deal.StageName;
		
		// retrieve deal details of any deal currently synched with associated village presence
		// if different from current deal
		if (string.isnotBlank(deal.Village_Presence__r.Deal_in_Progress__c)){
			if (deal.Village_Presence__r.Deal_in_Progress__c != recId){
				dealSynched = true;
				synchedDeal = [select Id, Name, Auto_Sync__c 
								from Opportunity 
								where Id = :deal.Village_Presence__r.Deal_in_Progress__c];
			}
		}
		
	}	
	
	private list<Schema.FieldSetMember> getFields() {
		return SObjectType.Opportunity.FieldSets.Auto_Synch_Fields.getFields();
	}
	
	public PageReference SaveRecord(){
		// If deal is to be auto synched and there is another deal already synched
		// switch off auto synch flag on the other deal
		PageReference pg = null;
		try{ 
			if(deal.Auto_Sync__c){
				if (synchedDeal != null){
					synchedDeal.Auto_Sync__c = false;
					update synchedDeal;
				}
			}
			
			
			if (vpUpdatePage != null){
				pg = vpUpdatePage;
			} else {			
				update deal;
				pg = new PageReference('/' + deal.Id);
			}
		} catch (exception e){
            string errMsg = 'Record could not be saved. Please review any error(s) displayed';
            errMsg += ' or report to System Administrator';
                                             
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString());  
            enableSaveBtn = false;                              
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,errMsg));
			pg = null;
		}
		
		return pg;
		
	}
	
	public void saveRecordSf1(){
		
		PageReference pg = SaveRecord();
		

	}
	
	// Interrogate custom setting to default auto synch flag
	// according to stage selected
	public void stageUpdate(){
		map<string, Deal_Auto_Sync_Stages__c> synchSettings = Deal_Auto_Sync_Stages__c.getAll();
		
		for (string key :synchSettings.keySet() ){
			string stage = synchSettings.get(key).stage_name__c;
			hideAutoSynch = false;
			if (stage == deal.StageName){
				if (currentlySynched == false){
					deal.Auto_Sync__c = synchSettings.get(key).Default_Sync_Value__c;
				}
				disableAutoSynch = false;
				
				// Determine whether stage is moving deal to a Closed state
				boolean dealSuccess = (boolean) synchSettings.get(key).get('Closed_Success__c');
				if (dealSuccess != null){
					if (dealSuccess){
						vpUpdatePageUrl = '/apex/updateVillagePresence?Id=' + deal.Id + '&previousStage='+previousStage 
																	+ '&stage=' + deal.StageName;
						vpUpdatePage = new PageReference(vpUpdatePageUrl);	
						deal.Auto_Sync__c = false;
						disableAutoSynch = true;
						hideAutoSynch = true;
					}
				}
				boolean dealFail = (boolean) synchSettings.get(key).get('Closed_Fail__c');
				if (dealFail != null){
					if (dealFail){
						deal.Auto_Sync__c = false;
						disableAutoSynch = false;
						hideAutoSynch = true;
					}
				}
				break;
			}
		}
		
	}
	
	public void showWarning(){
		system.debug(' @@@@ deal.autoSynch ... ' + deal.Auto_Sync__c);
		if (disableAutoSynch){
			deal.Auto_Sync__c = false;
		}		
	}
}