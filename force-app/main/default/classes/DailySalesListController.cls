public with sharing class DailySalesListController {
	
	private static User runningUser = null;
	private static string userContactId = null;

	@AuraEnabled
	public static boolean getConfirmUser(){
		
		Boolean confirmUser = false;
		User currentUser = UserProfileController.getCurrentUser();
		userContactId = currentUser.contactId;
    	if (string.isnotBlank(userContactId)){
    		list<Village_Presence_Contact_Role__c> roleList = new list<Village_Presence_Contact_Role__c>();
    		roleList = [select Id from Village_Presence_Contact_Role__c 
    						where Contact__c = :userContactId
    						and Confirm_Daily_Sales_Records__c = true];
    		if (!roleList.isEmpty()){
    			confirmUser = true;
    		} else {
    			confirmUser = false;
    		}				
    		
    	}
    	return confirmUser;        			
		
	}   
	    
    @AuraEnabled
	public static  List<dailySale> getDailySalesList(string fieldSetName, string listViewName, boolean confirmList, string device) {

        if (runningUser == null && string.isnotBlank(device)){
        	
        	runningUser = UserProfileController.getCurrentUser();
        	runningUser.Last_Portal_Login__c = system.now();
        	runningUser.Last_Portal_Login_Device__c = device;
        	update runningUser;
        	
        }
              
        system.debug(' @@@@ fieldSetName passed in ..   ' + fieldSetName);
        system.debug(' @@@@ listViewName passed in ..   ' + listViewName);
        system.debug(' @@@@ confirmList passed in ..   ' + confirmList);
        
    	List<Daily_Sale__c> dailySaleList = new List<Daily_Sale__c>();

        string query = 'select Id, Name, Store__r.Name, Status__c,Turnover_Rent_Date__c,Grace_Period_Expired_On_Date__c,';

        List<FieldSetMember> fsFlds = getFields(fieldSetName);
        system.debug(' @@@@ Field Set Memeber  ' + fsFlds);
        for (FieldSetMember fm :fsFlds){
            string fldName = fm.fieldPath;
            if (fldName != 'Id' && fldName != 'Name' && fldName != 'Status__c'){
                query = query + fldName + ',';
                system.debug(query);
            }            
        }
        query = query.subString(0,query.length() - 1);
        query = query + ' from ';
        query = query + ' Daily_Sale__c';
        
        map<Id, Daily_Sale__c> dailySaleMap = new map<Id, Daily_Sale__c>();
        list<dailySale> returnList = new list<dailySale>();
        
        if (confirmList){
			query = query + ' where Valid_for_Confirmation__c = true ';
        	//query = query + ' and Status__c <> ' + '\'TOR\'';
        	query = query + ' and ( Status__c = ' + '\'Created\'' + ' OR Status__c = ' + '\'Reported Incomplete\'' + ' OR Status__c = ' + '\'Reported Confirmed\')'; 
            query = query + ' and ( Grace_Period_Expired_On_Date__c = null )';  
        	query = query + ' order by Store__r.Name, Trading_Date__c';

            system.debug('Query1Confirm ' + query);
        	// extract the Daily Sale records
        	dailySaleMap = new map<Id, Daily_Sale__c>((List<Daily_Sale__c>)Database.query(query));   
            
            system.debug('Query2Confirm ' + query);
            
        } else {
            
            //query = query + ' where Status__c = ' + '\'Created\'';                
            query = query + ' LIMIT 1 ';
            
            system.debug('Query1 ' + query);
            
        	list<Daily_Sale__c> dsViewList = getListViewRecords(listViewName, query);
            
            system.debug('QueryList ' + dsViewList);
            for (Daily_Sale__c ds :dsViewList){
                dailySale ds2 = new dailySale();
                ds2.Id = ds.Id;
                ds2.dailySaleItem = ds;
                ds2.fields = fsFlds;
                list<FieldSetMember> fieldValues = new list<FieldSetMember>();
                list<string> fldkeys = new list<string>();
                string val = '';
                for (FieldSetMember fs : fsFlds){
                    val = '';
                    system.debug (' @@@ ' + fs.fieldPath + '  -  ' + fs.type);
                    if (fs.type == 'DATE' || fs.type == 'DATETIME'){
                        date dt;
                        datetime dtt;
                        if (fs.type == 'DATE'){
                        	dt = (Date) ds.get(fs.fieldPath);
                        	if (dt != null)
                            	val = dt.format();                        
                        }
						if (fs.type == 'DATETIME'){
                        	dtt = (DateTime) ds.get(fs.fieldPath);
                        	if (dtt != null)
                        		val = dtt.format();
                        }
                        
                    } else if (fs.type == 'DOUBLE' || fs.type == 'DECIMAL' || fs.type == 'CURRENCY' || fs.type== 'PERCENT'){
                        Double dbl = (Decimal)ds.get(fs.fieldPath);
                        if (dbl != null){
                            val = dbl.format();
                            if (fs.type == 'PERCENT')
                                val = val + '%';
                        }
                        
                    } else if (fs.type == 'INTEGER'){
                        integer i = (Integer)ds.get(fs.fieldPath);
                        if (i != null)
                            val = i.format();
                        
                    } else{
                        val = string.valueOf(ds.get(fs.fieldPath));  
                        
                    }
                    fldKeys.add(val);
                    FieldSetMember fsv = new FieldSetMember(false);
                    fsv.value=val;
                    fsv.label = fs.label;
                    fieldValues.add(fsv);
                    
                }
                system.debug(' @@@@@    fldKeys ...   '   + fldKeys );
                system.debug(' @@@@@    fieldValues ...   '   + fieldValues ); 
                ds2.fldkeys = fldkeys;
				ds2.fieldValues = fieldValues;                
                returnList.add(ds2);
            }
            
        }        
                
        if (!dailySaleMap.isEmpty() && confirmList){
            
            list<string> storeIds = new list<string>();
            for (Daily_Sale__c ds :dailySaleMap.values()){
                storeIds.add(ds.Store__c);
            }
            User u = [select Id, ContactId from User where Id = :UserInfo.getUserId()];
            string contactId = u.ContactId;
            
            map<Id,UserRecordAccess> usrAcsMap = new Map<Id,UserRecordAccess>( [SELECT RecordId, HasReadAccess, HasEditAccess 
                                                                                FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId()
                                                                                AND RecordId IN :dailySaleMap.keySet()] );
            
            system.debug('@@@ storeIds ... ' + storeIds.size() + ' - ' + storeIds);
            map<Id, Village_Presence__c> vpMap = new map<Id, Village_Presence__c>( [select Id, (SELECT id, Village_presence__c, Contact__c,
                                                                 Daily_Sales_Active_From__c, Daily_Sales_Active_To__c,
                                                                 Confirm_Daily_Sales_Records__c
                                                                 from Village_Presence_Contact_roles__r
                                                                 where Daily_Sales_Active_From__c != null
                                                                 and contact__c = :contactId
                                                                 and Confirm_Daily_Sales_Records__c = true)
                                                                 from Village_Presence__c 
                                                                 where Id in :storeIds                              
                                                                 ] );
            
            
            system.debug('@@@ vpMap ... ' + vpMap.size() + ' - ' + vpMap);
            for (string key :dailySaleMap.keySet()){
                dailySale ds = new dailySale();
                system.debug('@@@ usrAcsMap ... ' + usrAcsMap.size() + ' - ' + usrAcsMap);
                boolean hasAccess = usrAcsMap.get(key).HasEditAccess;
               
                if (hasAccess) {
                    village_presence__c vp = vpMap.get(dailySaleMap.get(key).Store__c);
                    if (vp != null){
                        list<Village_Presence_Contact_Role__c> vpcrList = vp.Village_Presence_Contact_roles__r;
                        if (vpcrList != null)
                            if (!vpcrList.isEmpty()){
                                ds.Id = key;
                                ds.selected = false;
                                ds.fields = fsFlds;
                                list<string> fldkeys = new list<string>();
                                list<FieldSetMember> fieldValues = new list<FieldSetMember>();
                                string val = '';
                                for (FieldSetMember fs : fsFlds){
                                    val = '';
                                    system.debug (' @@@ ' + fs.fieldPath + '  -  ' + fs.type);
                                    if (fs.type == 'DATE' || fs.type == 'DATETIME'){
                                        Date dt = (Date)dailySaleMap.get(key).get(fs.fieldPath);
                                        if (dt != null)
                                        	val = dt.format();
                                        
                                    } else if (fs.type == 'DOUBLE' || fs.type == 'DECIMAL' || fs.type == 'CURRENCY' || fs.type== 'PERCENT'){
                                        Double dbl = (Decimal)dailySaleMap.get(key).get(fs.fieldPath);
                                        if (dbl != null){
                                        	val = dbl.format();
                                         	if (fs.type == 'PERCENT')
                                                val = val + '%';
                                        }
                                    	
                                    } else if (fs.type == 'INTEGER'){
                                        integer i = (Integer)dailySaleMap.get(key).get(fs.fieldPath);
                                        if (i != null)
                                        	val = i.format();                                    	                                    
                                    } else {
                                    	val = string.valueOf(dailySaleMap.get(key).get(fs.fieldPath));  
                                    	
                                    }
                                    fldKeys.add(val);
									FieldSetMember fsv = new FieldSetMember(false);
                    				fsv.value=val;
                    				fsv.label = fs.label;
                    				fieldValues.add(fsv);
                                }
system.debug(' @@@@@    fldKeys ...   '   + fldKeys );
system.debug(' @@@@@    fieldValues ...   '   + fieldValues );                                
                                ds.fldkeys = fldkeys;
                                ds.fieldValues = fieldValues;
                                
                                ds.dailySaleItem = dailySaleMap.get(key);
                                returnList.add(ds);
                            }    
                    }
                }
            }

        }    
system.debug(' @@@@ returnList  ' + returnList);    	

        return returnList;

	}

    @AuraEnabled
	public Static string confirmList(string dsIds) {
		
		system.debug(' @@@@ dsIds for confirming .. ' + dsIds);
        //dsIds format .. ["a1z8E000000RYocQAG","a1z8E000000RZ4VQAW"]
        
        string returnValue = '';
        integer recordsConfirmed = 0;
        
        List<String> selectedIdsList = new List<String>();
		Object[] values = (Object[])System.JSON.deserializeUntyped(dsIds);
		if(values.size()>0){        
     		for (Object id : values) {
         		selectedIdsList.add(string.valueof(id) );

     		}

 		}
        
        if (!selectedIdsList.isEmpty()){
            
			map<Id, Daily_Sale__c> dsMap = new map<Id, Daily_Sale__c>([select Id, Store__r.Name, Trading_Date__c, Brand_Status__c,
                                                                       Brand_Confirmed_Date_Time__c, Brand_Confirmed_Name__c,
                                                                       Date_Last_Sent_to_MRI__c, Status__c
                                                                       from Daily_Sale__c
                                         									where Id in :selectedIdsList]);
            
            for (Daily_Sale__c ds :dsMap.values()){
                ds.Brand_Status__c = 'Confirmed';
                ds.Status__c = 'Reported Confirmed';
                ds.Brand_Confirmed_Date_Time__c = system.now();
                ds.Date_Last_Sent_to_MRI__c = system.now();
                ds.Brand_Confirmed_Name__c = userInfo.getFirstName() + ' ' + userInfo.getLastName();
            }
            
            try{
                
                Database.SaveResult[] resultList = Database.update(dsMap.values(), false);
				recordsConfirmed = resultList.size();
                for (Integer i = 0; i < dsMap.values().size(); i++) {
                    Database.SaveResult r = resultList[i];
                    Daily_Sale__c dsRec = dsMap.values()[i];
                    if (!r.isSuccess()) {
    					recordsConfirmed --;
                        string recId = dsRec.Id;

                        string store = dsRec.Store__r.Name;
                        string tradingDate = dsRec.Trading_Date__c.format();
                        
                        for (Database.Error e : r.getErrors()){  
      						// errors here
      						StatusCode status = e.getStatusCode();
      						string errMsg = e.getMessage();
                            
                            string msg = 'ERROR confirming Daily Sales Record .. ' + store + ' - ' + tradingDate + ' - ' + status + ' : ' + errMsg;
                            system.debug(msg );
                            returnValue += msg + '\r\n';
                            
                        }
                    } 
                }                

                
            } catch (exception e){
                system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
                returnValue += 'ERROR ...ERROR ... ERROR,  A technical error has occured - '  + e.getMessage() + ' : ' + e.getStackTraceString();
            }
            
            
        }
        
        if (string.isBlank(returnValue)){
            returnValue = recordsConfirmed + ' ' + System.Label.DAILY_SALE_CONFIRM_SUCCESSFUL;
        } 
        
        return returnValue;
    }

    @AuraEnabled
	public Static string saveTheList(string dsUpdateList) {
        
        string returnValue = '';
        integer recordsConfirmed = 0;
        
        map<Id, Daily_Sale__c> updateMap = new map<Id, Daily_Sale__c>();
		DailySalesListController.dailySale[] values = (DailySalesListController.dailySale[])System.JSON.deserialize(dsUpdateList, list<DailySalesListController.dailySale>.class);
system.debug(' @@@@ values  .. ' + values);
        if(values.size()>0){
            /*
            try{ 
                for (DailySalesListController.dailySale o : values) {
                    Daily_Sale__c ds = new Daily_Sale__c();
                    ds.Total_GROSS_SALES__c =  string.isnotBlank(o.totalGrossSales) ?  decimal.valueOf(o.totalGrossSales.replace(',', ''))  : null;
                    ds.Non_VAT_able_Sales__c =  string.isnotBlank(o.nonVATSales) ?  decimal.valueOf(o.nonVATSales.replace(',', ''))  : null;
                    ds.GROSS_Value_of_Discounts__c = string.isnotBlank(o.grossDiscounts) ?  decimal.valueOf(o.grossDiscounts.replace(',', ''))  : null;
                    ds.Number_of_Transactions__c = string.isnotBlank(o.transactions) ?  decimal.valueOf(o.transactions.replace(',', '')) : null;
                    ds.Tax_Free_Sales_Amount__c = string.isnotBlank(o.taxFreeSales) ?  decimal.valueOf(o.taxFreeSales.replace(',', '')) : null;
                    ds.Tax_Free_Transactions__c = string.isnotBlank(o.taxFreeTransactions) ?  decimal.valueOf(o.taxFreeTransactions.replace(',', '')) : null;
                    ds.Footfall__c = string.isnotBlank(o.footfall) ?  decimal.valueOf(o.footfall.replace(',', '')) : null;
                    updateMap.put(string.valueOf(o.Id),ds);
                } 
            } catch (exception e){
                string msg = 'ERROR updating Daily Sales Records - Invalid entries';
                system.debug(msg );
                returnValue += msg + '\r\n';
            }

        }
system.debug(' @@@@ updateMap  .. ' + updateMap);        
        if (!updateMap.isEmpty()){
            
            map<Id, Daily_Sale__c> dsMap = new map<Id, Daily_Sale__c>([select Id, Store__r.Name, Trading_Date__c, Brand_Status__c,
                                                                       Brand_Reported_Amount__c, Number_Of_Transactions__c,
                                                                       Tax_Free_Sales_Amount__c, Tax_Free_Transactions__c,
                                                                       Footfall__c
                                                                       from Daily_Sale__c
                                         							   where Id in :updateMap.keySet()]);
            
            for (Daily_Sale__c ds :dsMap.values()){
                ds.Total_GROSS_SALES__c = updateMap.get(ds.Id).Total_GROSS_SALES__c;
                ds.Non_VAT_able_Sales__c = updateMap.get(ds.Id).Non_VAT_able_Sales__c;
                ds.GROSS_Value_of_Discounts__c = updateMap.get(ds.Id).GROSS_Value_of_Discounts__c;
                ds.Brand_Reported_Amount__c = updateMap.get(ds.Id).Brand_Reported_Amount__c;
                ds.Number_Of_Transactions__c = updateMap.get(ds.Id).Number_Of_Transactions__c;
                ds.Tax_Free_Sales_Amount__c = updateMap.get(ds.Id).Tax_Free_Sales_Amount__c;
                ds.Tax_Free_Transactions__c = updateMap.get(ds.Id).Tax_Free_Transactions__c;
                ds.Footfall__c = updateMap.get(ds.Id).Footfall__c;
            }
system.debug(' @@@@ dsMap  .. ' + dsMap);             
            try{
                
                Database.SaveResult[] resultList = Database.update(dsMap.values(), false);
				recordsConfirmed = resultList.size();
                for (Integer i = 0; i < dsMap.values().size(); i++) {
                    Database.SaveResult r = resultList[i];
                    Daily_Sale__c dsRec = dsMap.values()[i];
                    if (!r.isSuccess()) {
    					recordsConfirmed --;
                        string recId = dsRec.Id;

                        string store = dsRec.Store__r.Name;
                        string tradingDate = dsRec.Trading_Date__c.format();
                        
                        for (Database.Error e : r.getErrors()){  
      						// errors here
      						StatusCode status = e.getStatusCode();
      						string errMsg = e.getMessage();
                            
                            string msg = 'ERROR updating Daily Sales Record .. ' + store + ' - ' + tradingDate + ' - ' + status + ' : ' + errMsg;
                            system.debug(msg );
                            returnValue += msg + '\r\n';
                            
                        }
                    } 
               
				}                
 */
            /*    
            } catch (exception e){
                system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
                returnValue += 'ERROR ...ERROR ... ERROR,  A technical error has occured - '  + e.getMessage() + ' : ' + e.getStackTraceString();
            }
            */
            
        }
        
        if (string.isBlank(returnValue)){
            returnValue = 'All record(s) successfully updated';
        } 
        
        return returnValue;
    }
	
    private static list<Daily_Sale__c> getListViewRecords(string viewName, string qry){
        
        string listViewId = '';
        list<Daily_Sale__c> returnList = new list<Daily_Sale__c>();
           system.debug('Query2 ' + qry);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Database.getQueryLocator(qry));
        List<SelectOption> listViews = sc.getListViewOptions();
        system.debug('Get Records ' + sc.getRecords());
        for(SelectOption o : ListViews ){
            if(o.getLabel()==viewName){
                system.debug('Get List View Label ' + o);
                listViewId = o.getValue().left(15);
				break;
            }
        }
         
        if (string.isnotBlank(listViewId)){
            sc.setFilterId(listViewId);
            sc.setPageSize(270);
            returnList = sc.getRecords();
            system.debug(returnList.Size());
        }
        
        return returnList;
        
    }

	@AuraEnabled
    public static List<FieldSetMember> getFields( string fsName) {
        
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map <String, Schema.SObjectField> fieldMap = gd.get('Daily_Sale__c').getDescribe().fields.getMap();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Daily_Sale__c');
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        
        if (fs != null){
            List<Schema.FieldSetMember> fieldSet = fs.getFields();

            for (Schema.FieldSetMember f: fieldSet) {
                FieldSetMember fsmember = new FieldSetMember(f);
                schema.describefieldresult dfield = fieldMap.get(f.fieldPath).getDescribe();
                string helpText = dfield.getInlineHelpText();
                fsmember.helpText = helpText;
                
                fset.add(fsmember);
            }
        }
        return fset;
        
    }


    @AuraEnabled
    public static string  getLabel(string labelReference) {
        system.debug('@@@@ labelReference  ' + labelReference);
        
        string language = userinfo.getLanguage();
        
        ZLabelTranslator t = new ZLabelTranslator();
        
        string lbl_text = '';
        
        try {    
            lbl_text = t.translate(labelReference,language);
        } catch (exception e){
            lbl_text = '';
        }
        
		return lbl_text;  
    }
    
    public class dailySale{
    
        @AuraEnabled
        public Boolean selected{get; set;}
        @AuraEnabled
        public Daily_Sale__c dailySaleItem{get; set;}
        @AuraEnabled
        public list<FieldSetMember> fields{get; set;}
		@AuraEnabled
        public list<FieldSetMember> fieldValues{get; set;}        
        @AuraEnabled
    	public list<string> fldkeys {get; set;}
        @AuraEnabled
    	public String Id{get; set;}   
    }

    public class FieldSetMember {

        public FieldSetMember(Schema.FieldSetMember f) {
            this.DBRequired = f.DBRequired;
            this.fieldPath = f.fieldPath;
            this.label = f.label;
            this.required = f.required;
            this.type = '' + f.getType();
            this.value = '';
        }
    
        public FieldSetMember(Boolean DBRequired) {
            this.DBRequired = DBRequired;
        }
    
        @AuraEnabled
        public Boolean DBRequired { get;set; }
    
        @AuraEnabled
        public String fieldPath { get;set; }
    
        @AuraEnabled
        public String label { get;set; }
    
        @AuraEnabled
        public Boolean required { get;set; }
    
        @AuraEnabled
        public String type { get; set; }
        
        @AuraEnabled
        public String helpText { get; set; }

        @AuraEnabled
        public String value { get; set; }         
	}
}