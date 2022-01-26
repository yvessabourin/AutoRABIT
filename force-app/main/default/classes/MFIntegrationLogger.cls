public with sharing class MFIntegrationLogger {
	
	static final String INBOUND_REQUEST = 'inbound';
	static final String OUTBOUND_REQUEST = 'outbound';
	static final String MARKETING_ACTIVITY_REL_OBJECT = 'Marketing Activity';
	static final String MARKETING_CAMPAIGN_REL_OBJECT = 'Marketing Campaign';

	MF_Integration_Log__c integrationLog;
	String sessionId;
	String statusCode;
	String errorMessage;

	List <Integration_Callout_Body__c> calloutBodies = new List <Integration_Callout_Body__c> ();
	
	public MFIntegrationLogger(String sessionId) {
		this.sessionId = sessionId;
		this.getIntegrationLog();
	}

	public MFIntegrationLogger() {
		this.integrationLog = new MF_Integration_Log__c();
	}

	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
		this.integrationLog.Session_Id__c = sessionId;
	}

	public void setResponseStatusCode(Integer statusCode) {
		this.statusCode = String.valueOf(statusCode);
	}

	public void setResponseStatusCode(String statusCode) {
		this.statusCode = statusCode;
	}

	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage.length() > 250 ? errorMessage.subString(0,250) : errorMessage;
	}

	public void setMarketingActivityAsRelatedObject() {
		this.setRelatedObject(MARKETING_ACTIVITY_REL_OBJECT);
	}

	public void setMarketingCampaignAsRelatedObject() {
		this.setRelatedObject(MARKETING_CAMPAIGN_REL_OBJECT);
	}

	public void setRelatedObject(String relatedObject) {
		this.integrationLog.Related_Object__c = relatedObject;
	}

	private MF_Integration_Log__c getIntegrationLog() {
		if (this.integrationLog == null) {
			if (String.isNotBlank(sessionId)) {
				//Query for a list to check for existency and avoid errors although the sessionId should be unique
				List <MF_Integration_Log__c> existingIntegrationLog = [SELECT Id, Session_Id__c FROM MF_Integration_Log__c WHERE Session_Id__c =: sessionId];
				if (!existingIntegrationLog.isEmpty()) {
					this.integrationLog = existingIntegrationLog[0];
				}
			}
		}

		//In case that we haven't found any existing integration Log, we instantiate a new one
		if (this.integrationLog == null) {
			this.integrationLog = new MF_Integration_Log__c ();
			this.integrationLog.Session_Id__c = this.sessionId;
		}

		return this.integrationLog;
	}

	public Integration_Callout_Body__c setInboundRequest(Object body, Id salesforceRecordId) {
		return this.setNewRequest(body, INBOUND_REQUEST, salesforceRecordId);
	}

	public Integration_Callout_Body__c setOutboundRequest(Object body, Id salesforceRecordId) {
		return this.setNewRequest(body, OUTBOUND_REQUEST, salesforceRecordId);
	}

	private Integration_Callout_Body__c setNewRequest(Object body, String type, Id salesforceRecordId) {
		Integration_Callout_Body__c newRequest = new Integration_Callout_Body__c ();
		String serializedBody = JSON.serializePretty(body, false);

		//In case that the serialized request exceed the total characters allowed for the body field, create a substring
		if (serializedBody.length() > 10000) {
			serializedBody = serializedBody.subString(0,10000);
		}

		newRequest.Request_Type__c = type;
		newRequest.Request_Body__c = serializedBody;
		newRequest.Salesforce_Record_Id__c = salesforceRecordId;
		this.calloutBodies.add(newRequest);
		return newRequest;
	}

	public void saveRequests() {

		upsert this.integrationLog;

		if (!this.calloutBodies.isEmpty()) {
			for (Integration_Callout_Body__c integrationBody : this.calloutBodies) {
				integrationBody.Marketing_Finance_Integration_Log__c = this.integrationLog.Id;
				integrationBody.Response_Code__c = this.statusCode;
				integrationBody.Response_Error_Message__c = this.errorMessage;
			}
			upsert calloutBodies;
		}
	}	

}