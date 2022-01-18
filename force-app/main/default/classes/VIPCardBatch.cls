global class VIPCardBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
    global class VipBarCodesRequest{
        global List<String> VipBarcodes;
        global String StartDateTime;
        global String EndDateTime;
    }
    
    global class HNWPurchases{
        global String Id;
        global String BrandCode;
        global String VillageCode;
        global Decimal SpendAmount;
        global String TransactionDateTime;
    }
    
    global class VipBarCodesResponse{
        global String Id;
        global String BarcodeNumber;
        global List<HNWPurchases> HNWPurchases;
    }
    
    global class DataResponse{
        List<VipBarCodesResponse> lstDataResp;
    }
    
	public String query;
    public List<Id> cardIdList;
	
	public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<VIP_Card_Exchange__c> scope){
        String apiHost = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('API_Host__c')));
        String endPoint = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('Read_HNW_Purchases__c')));
        String apiKey = nullToEmptyString(string.valueOf(API_Configuration__c.getAll().get('API Config LIVE').get('API_Key__c')));

       	Map<String, Id> cardMapByCardCode = new Map<String, Id>();
        VipBarCodesRequest dataReq = new VipBarCodesRequest();
        List<String> lstDataReq = new List<String>();
        List<VIP_Card_Brand_Purchase__c> purchasesToInsert = new List<VIP_Card_Brand_Purchase__c>();
        
        for(VIP_Card_Exchange__c card : scope){
            lstDataReq.add(card.VIP_Card_Code__c);
            cardMapByCardCode.put(card.VIP_Card_Code__c, card.Id);
        }
        
        if(!lstDataReq.isEmpty()){
            dataReq.VipBarcodes = lstDataReq;
            dataReq.StartDateTime = String.valueOf(Date.today().addMonths(-4));
            dataReq.EndDateTime = String.valueOf(Date.today().addDays(1));
            
            String requestBody = JSON.serialize(dataReq);
            System.debug('requestBody ' + requestBody);
            String endPointRequestURL = apiHost + endPoint;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPointRequestURL);
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            request.setHeader('Ocp-Apim-Subscription-Key', apiKey);
            request.setBody(requestBody);
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('response.getBody() ' + response.getBody());
                if (String.isNotEmpty(response.getBody())) {
                    List<VipBarCodesResponse> lstDataResp = (List<VipBarCodesResponse>)JSON.deserialize(response.getBody(),List<VipBarCodesResponse>.class);
                    
                    DateTime StartDate = DateTime.now().addMonths(-4);
                    DateTime EndDate = DateTime.now().addDays(1);
                    List<VIP_Card_Brand_Purchase__c> HNWPurchaseCheck = new List<VIP_Card_Brand_Purchase__c>();
                    HNWPurchaseCheck = [SELECT Id, VIP_Card_Exchange__r.VIP_Card_Code__c, Purchase_Date__c, Brand_Code__c FROM VIP_Card_Brand_Purchase__c 
                                        WHERE CreatedDate < :EndDate AND CreatedDate > :StartDate];
                    
                    List<DateTime> existingDateTime = new List<DateTime>();
                    if (!HNWPurchaseCheck.isEmpty()) {
                        System.debug('HNWPurchaseCheck.size() HNW Purchases that already exist in the list: ' + HNWPurchaseCheck.size());
                        for (VIP_Card_Brand_Purchase__c purchaseCheck : HNWPurchaseCheck) {
                            existingDateTime.add(purchaseCheck.Purchase_Date__c);
                        }
                    }
                    
                    for (VipBarCodesResponse vbc : lstDataResp) {
                        for (HNWPurchases purch : vbc.HNWPurchases) {
                            if (existingDateTime.isEmpty() || !existingDateTime.contains(DateTime.valueOf(purch.TransactionDateTime))) {
                                VIP_Card_Brand_Purchase__c newPurchase = new VIP_Card_Brand_Purchase__c();
                                newPurchase.Brand_Code__c = purch.BrandCode;
                                newPurchase.Purchase_Date__c = DateTime.valueOf(purch.TransactionDateTime);
                                newPurchase.Village_Code__c = purch.VillageCode;
                                newPurchase.Spend_Amount__c = purch.SpendAmount;
                                newPurchase.VIP_Card_Exchange__c = cardMapByCardCode.get(vbc.BarcodeNumber);
                                purchasesToInsert.add(newPurchase);
                            }
                        }
                    }
                    System.debug('purchasesToInsert.size() HNW Purchases that are going to be inserted: ' + purchasesToInsert.size());
                    if (!purchasesToInsert.isEmpty()) {
                        INSERT purchasesToInsert;
                    }
                }
            } else {
                //Send out error emails
                system.debug('There is an error in integration: ' + response.getStatus() + ', ' + response.getStatusCode() + ', ' + response.getBody());
            }
        }
    }

    public string nullToEmptyString(string value){
        string returnVal = '';
        if (string.isBlank(value)){
            returnVal = '';
        } else {
            returnVal = value;
        }
        return returnVal;
    }
    
    public void finish(Database.BatchableContext bc){}
}