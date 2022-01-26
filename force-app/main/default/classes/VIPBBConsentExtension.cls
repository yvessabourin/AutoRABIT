global without sharing class VIPBBConsentExtension{
	public static final Integer PARTNER_LIST_LIMIT = 20;
	public string languageSelected {get;set;}
	public string CountryTypes {get;set;}
	public static String userVillage {get; set;}
	public static String userVillageCode {get; set;}
	public string language {get;set;}
	private Account a;
	public String hfsCaseId {get;set;}
	public String guestJson {get;set;}
	public String partnerNameJson {get;set;}
	public static String[] labelsonpage = new String[]{'CancelButton', 'Email', 'FirstName', 'LastName',
													   'PleaseComplete', 'SaveNextButton', 'Tel', 'WelcomeVIPHeading','VIPConsentTopHeading','Gender','Yes',
													   'No','Birthday','BirthdayInvalid','EmailTelInvalid', 'EmailInvalid', 'Male', 'Female', 'January', 'February',
													   'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December','Preferredmethodofcontact', 'PossibleDuplicates','PossibleDuplicatesEmail','ProfessionalBuyer','Close','SearchPartner','SelectPartner','NoPartnerFound',
													   'PartnerInvalid','PostalCode'};
	public static String languagelabels {get;set;}
	public static String lang {get; set;}

	Public VIPBBConsentExtension(Apexpages.standardController stdController){
		if(!Test.isRunningTest()){ stdController.addFields(new List<String>{'Birth_Day__c', 'Birth_Month__c', 'Gender__c','Preferred_method_of_contact__c','Professional_Buyer__c','Partner_Program_Membership_1__c'}); }

		a = (Account) stdController.getRecord();

		Map <String, String> parameters = ApexPages.currentPage().getParameters();
		lang = parameters.get('lang');

		hfsCaseId = parameters.get('hfsId');
		if (String.isNotEmpty(hfsCaseId) && stdController.getId() == null) {
			a = new Account();
			Case hfsCase = getHFSCase(hfsCaseId);
			a.FirstName = hfsCase.HFS_First_Name__c;
			a.LastName = hfsCase.HFS_Last_Name__c;
			a.PersonEmail = hfsCase.SuppliedEmail;
			a.PersonMobilePhone = hfsCase.SuppliedPhone;

		}

		if(a.Partner_Program_Membership_1__c!=null){
			Account partner = [SELECT id, Name FROM Account where id=:a.Partner_Program_Membership_1__c];
			partnerNameJson = partner.Name;
		}
		else{
			partnerNameJson='';
		}

		guestJson = JSON.serializePretty(a);


		if(lang == null || lang == ''){
			userVillage = getUsersVillage();

			lang=getVillageLanguage(userVillage);
		}


		languagelabels = getLanguageLabels(lang);
	}

	@RemoteAction
	global static string saveGuest(String accID, string name, string surname, string email, string telephone, String caseId, string birthday, string birthmonth, string gender,string preferredmethodofcontact, boolean profBuyer,string partnerID,string postalCode){
		try{
			Account acc;
			String returnText;
			Case hfsCase;

			if (String.isNotBlank(caseId)) {
				hfsCase = [SELECT Village__c, Experience_Start__c, Visit__c, Payment_Status__c, Village__r.Village_Code__c, Total_Spent_Amount__c, Country_of_Residence__c, HFS_Promo_Code__c FROM Case WHERE Id =: caseId];
			}

			if(accID == null || accID == ''){
				Database.DMLOptions dmlOptions = new Database.DMLOptions();
				dmlOptions.DuplicateRuleHeader.AllowSave = true;

				// then its a new guest, and we need to insert.
				acc = new Account();

                Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('VIP_Guest').getRecordTypeId();
				acc.FirstName = name;
				acc.LastName = surname;
				acc.PersonEmail = email;
				acc.PersonMobilePhone = telephone;
				acc.RecordTypeId = rtId;
				acc.Birth_Day__c = birthday;
				acc.Birth_Month__c = birthmonth;
				acc.Gender__c = gender;
                acc.Preferred_method_of_contact__c=preferredmethodofcontact;
            	acc.Professional_Buyer__c=profBuyer;
                acc.PersonMailingPostalCode = postalCode;
				if(partnerID!=null && partnerID!=''){
					acc.Partner_Program_Membership_1__c=partnerID;
				}
				else{
					acc.Partner_Program_Membership_1__c=null;
				}

				if (hfsCase != null) {
					acc.Country_of_Residence__c = hfsCase.Country_of_Residence__c;
					if (hfsCase.Village__r.Village_Code__c == 'LV') {
						acc.Introduced_By__c = hfsCase.HFS_Promo_Code__c;
						HFSSpentLevelCalculator levelCalculator = HFS_Utils.getCurrencyLevelCalculator(hfsCase.Village__r.Village_Code__c);
						acc.VIP_Guest_Type__c = levelCalculator.getGuestLevel(hfsCase.Total_Spent_Amount__c, hfsCase.Country_of_Residence__c) == HFS_SpentLevel.HIGH ? true : false;
					}
				}

				Database.SaveResult sr = Database.insert(acc, dmlOptions);

				returnText = 'NEWID' + String.valueOf(acc.Id) ;
			}
			else
			{
				// means its an exsisting guest, and needs updating
				System.Debug('Details: ' + accID + name + surname + email + telephone + birthday + birthmonth + gender + Preferredmethodofcontact + profBuyer + partnerID + postalCode);
				acc = [Select ID,FirstName, LastName, PersonEmail, PersonMobilePhone, Birth_Day__c, Birth_Month__c , Gender__c,Preferred_method_of_contact__c, Professional_Buyer__c,Partner_Program_Membership_1__c,PersonMailingPostalCode FROM Account WHERE ID = :accID];

				acc.FirstName = name;
				acc.LastName = surname;
				acc.PersonEmail = email;
				acc.PersonMobilePhone = telephone;
				acc.Birth_Day__c = birthday;
				acc.Birth_Month__c = birthmonth;
				acc.Gender__c = gender;
                acc.Preferred_method_of_contact__c=Preferredmethodofcontact;
                acc.PersonMailingPostalCode = postalCode;
				acc.Professional_Buyer__c = profBuyer;

				if(partnerID!=null && partnerID!=''){
					acc.Partner_Program_Membership_1__c=partnerID;
				}
				else{
					acc.Partner_Program_Membership_1__c=null;
				}

				update acc;
				returnText = 'SAVEDID' + accID;
			}

			//In case that we came from the HFS Guest Page, create the Visit and link the Case to both the Visit and the Account
			if (String.isNotBlank(caseId)) {

				Id visitVIPRecordTypeId = Schema.SObjectType.Visit__c.RecordTypeInfosByDeveloperName.get('VIP_Visit').getRecordTypeId();

				if (hfsCase.Visit__c == null) {
					Visit__c newVisit = new Visit__c(RecordTypeId = visitVIPRecordTypeId,
							Village__c = hfsCase.Village__c,
							Visit_Date_Time__c = hfsCase.Experience_Start__c,
							Type__c = 'VIP Shopping Day',
							Account__c = acc.Id,
							Total_Visit_Spend_HFS__c = hfsCase.Total_Spent_Amount__c);

					insert newVisit;

					hfsCase.AccountId = acc.Id;
					hfsCase.Visit__c = newVisit.Id;
					//US-41008: Requested by La Vallée. After creating the VIP Guest, the payment status of the guest should be updated to "Free of charge"
					if (hfsCase.Village__r.Village_Code__c == 'LV') {
						hfsCase.Payment_Status__c = hfsCase.Payment_Status__c.containsIgnoreCase('Free of Charge') ? hfsCase.Payment_Status__c : 'Free of Charge';
					}
					update hfsCase;
				}
			}

			return returnText;
		} catch(Exception ex){
			return 'ERROR ' + ex.getMessage();
		}
	}

	@RemoteAction
	global static string getLanguageLabels(String lang){
		// gets the labels for this page, for display by angular
		List<Custom_Label__c> custlabels = [SELECT ID, Name,Custom_Label_Value__c, Language__c FROM Custom_Label__c WHERE Language__c = :Lang AND Name IN :labelsonpage ];
		List<LabelValue> lblvals = new List<LabelValue>();
		for(Custom_Label__c cl :custlabels){
			LabelValue lval = new LabelValue();
			lval.LabelName = cl.Name;
			Lval.LabelValue = cl.Custom_Label_Value__c;
			lblvals.add(lval);
		}

		return JSON.serializePretty(lblvals);
	}

	public Case getHFSCase(String caseId){
		return [SELECT Id, HFS_Last_Name__c, HFS_First_Name__c, SuppliedPhone, SuppliedEmail FROM Case WHERE Id =: caseId];
	}

	@RemoteAction
	global static List <Account> searchDuplicates (String firstName, String lastName, String email, String phone) {
        Set<Id> foundAccountIds = new Set<Id>();

        Id  vipGuestRtId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('VIP_Guest').getRecordTypeId();
        Account acc = new Account(FirstName = firstName, LastName = lastName, PersonEmail = email, PersonMobilePhone = phone, RecordTypeId = vipGuestRtId);
        List<Account> accListToCheck = new List<Account>{ acc };
            try {
                List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(accListToCheck);
                Account foundAccount = null;
                // Find the first duplicate result with a match result, then use the first match record.
                for(Datacloud.MatchResult mr: results[0].getDuplicateResults()[0].getMatchResults()){
                    for(Datacloud.MatchRecord mRec : mr.getMatchRecords()){
                        // Add only Accounts that are VIP Guest in the list 
                        //if( vipGuestRtId == ((Account) mRec.getRecord()).RecordTypeId){
                        	foundAccountIds.add(((Account) mRec.getRecord()).Id);
                        //}
                    }
                }         
                // Find the first duplicate result with a match result, then use the second match record.
                for(Datacloud.MatchResult mr: results[0].getDuplicateResults()[1].getMatchResults()){
                    for(Datacloud.MatchRecord mRec : mr.getMatchRecords()){
                        // Add only Accounts that are VIP Guest in the list 
                        //if( vipGuestRtId == ((Account) mRec.getRecord()).RecordTypeId){
                        	foundAccountIds.add(((Account) mRec.getRecord()).Id);
                        //}
                    }
                }    
                
            } catch (Exception ex) {
                // FYI if there are no active rules for an object, then the exception is
                // System.HandledException: No active duplicate rules are defined for the [objname] object type
                return new List <Account> ();
            }
        if(foundAccountIds.isEmpty()){
            return new List <Account> ();
        }
        List <Account> toRet = [SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone, RecordTypeId FROM Account WHERE ID IN :foundAccountIds and RecordTypeId = :vipGuestRtId];
        return toRet;    
    }
	@RemoteAction
	global static List<Account> searchPartner(String partnerName){
		partnerName = String.escapeSingleQuotes( partnerName );
		ID villageID;
		string pName = '%'+partnerName+'%';
		List<Account> PTNs = [SELECT id, Name from Account WHERE RecordType.DeveloperName='Tourism' AND Name LIKE :pName LIMIT :PARTNER_LIST_LIMIT];
		System.debug('PTNs: ' + PTNs );
		return PTNs;
	}

	private class LabelValue{
		String LabelName {get; set;}
		String LabelValue {get; set;}
	}

	private static string getUsersVillage(){
		string userId = UserInfo.getUserId();
		list<user> users = [SELECT id, Village__c FROM USER
		WHERE id = :userId
		LIMIT 1];

		string village = users[0].Village__c;

		return village;

	}
	public static string getVillageLanguage(string village){
		if(village=='La Vallée'){
			lang='fr';
		}
		else if(village=='Maasmechelen'){
			lang='nl';
		}
		else if(village=='Fidenza'){
			lang='it';
		}
		else if(village=='Las Rozas' || village=='La Roca'){
			lang='es';
		}

		else if(village=='Wertheim' || village=='Ingolstadt'){
			lang='de';
		}

		else{
			lang='en';
		}
		return lang;

	}

}