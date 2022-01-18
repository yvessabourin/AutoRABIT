public class MasterBudgetSheetSendEmailAgencyFlow {

	private static final String COMMUNITY_NAME = System.Label.CommunityNameMBSAgency;
	private static final String EDIT_LEVEL = 'Edit';

	@InvocableMethod(Label='Send Email Agency')
	public static List<String> sendEmailAgency (List<Master_Budget_Sheet__c> inMasterBudgetSheetList){
		System.debug('Input inMasterBudgetSheetList: ' + inMasterBudgetSheetList);

		String errorMessageReturn = '';
		Map<Id, Set<Id>> userIdMap = new Map<Id, Set<Id>>();
		Map<Master_Budget_Sheet__c, Set<Id>> masterBudgetSheetMap = new Map<Master_Budget_Sheet__c, Set<Id>>();
		Set<Id> budgetVillageIdMap = new Set<Id>();

		if (inMasterBudgetSheetList != null && !inMasterBudgetSheetList.isEmpty()) {
			for (Master_Budget_Sheet__c outMasterBudgetSheet : inMasterBudgetSheetList) {
				if (String.isNotBlank(outMasterBudgetSheet.Budget_Village__c)) {
					budgetVillageIdMap.add(outMasterBudgetSheet.Budget_Village__c);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_1__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_1__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_1__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_2__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_2__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_2__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_3__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_3__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_3__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_4__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_4__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_4__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_5__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_5__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_5__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_6__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_6__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_6__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_7__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_7__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_7__c, outMasterBudgetSheet, userIdMap);
				}

				if (String.isNotBlank(outMasterBudgetSheet.Creative_Agency_8__c)){
					masterBudgetSheetMap = checkMasterBudgetSheet(outMasterBudgetSheet.Creative_Agency_8__c, outMasterBudgetSheet, masterBudgetSheetMap);
					userIdMap = checkUserId(outMasterBudgetSheet.Creative_Agency_8__c, outMasterBudgetSheet, userIdMap);
				}
			}

			if (!userIdMap.isEmpty()) {
				try {
					sendEmails(masterBudgetSheetMap, budgetVillageIdMap);
					createMasterBudgetSheetShare(userIdMap);
				} catch(Exception e) {
					System.debug('Error - ' + MasterBudgetSheetSendEmailAgencyFlow.class.getName());
					System.debug(e.getLineNumber());
					System.debug(e.getMessage());
					System.debug(e.getStackTraceString());

					errorMessageReturn = 'An unexpected application error has occurred. Contact your administrator or try again later.<br/><br/>';
					errorMessageReturn += e.getMessage();
				}
			}
		}

		return new List<String>{errorMessageReturn};
	}

	private static Map<Id, Set<Id>> checkUserId (String inUserId, Master_Budget_Sheet__c inMasterBudgetSheet, Map<Id, Set<Id>> inUserIdMap) {
		Map<Id, Set<Id>> userIdMap = new Map<Id, Set<Id>>(inUserIdMap);

		if(userIdMap.containsKey(inUserId)) {
			Set<Id> masterBudgetSheetId = userIdMap.get(inUserId);
			masterBudgetSheetId.add(inMasterBudgetSheet.Id);
			userIdMap.put(inUserId, masterBudgetSheetId);
		} else {
			userIdMap.put(inUserId, new Set<Id> { inMasterBudgetSheet.Id });
		}

		return userIdMap;
	}

	private static Map<Master_Budget_Sheet__c, Set<Id>> checkMasterBudgetSheet (String inUserId, Master_Budget_Sheet__c inMasterBudgetSheet, Map<Master_Budget_Sheet__c, Set<Id>> inMasterBudgetSheetMap) {
		Map<Master_Budget_Sheet__c, Set<Id>> masterBudgetSheetMap = new Map<Master_Budget_Sheet__c, Set<Id>>(inMasterBudgetSheetMap);

		if(masterBudgetSheetMap.containsKey(inMasterBudgetSheet)) {
			Set<Id> userIdSet = masterBudgetSheetMap.get(inMasterBudgetSheet);
			userIdSet.add(inUserId);
			masterBudgetSheetMap.put(inMasterBudgetSheet, userIdSet);
		} else {
			masterBudgetSheetMap.put(inMasterBudgetSheet, new Set<Id> { inUserId });
		}

		return masterBudgetSheetMap;
	}

	private static void sendEmails (Map<Master_Budget_Sheet__c, Set<Id>> inMasterBudgetSheetMap, Set<Id> inBudgetVillageIdMap) {
		Network networkSOQL = [SELECT Id FROM Network WHERE Name = :COMMUNITY_NAME];
		ConnectApi.Community communitySOQL = null;
		if (!Test.isRunningTest()) {
			communitySOQL = networkSOQL != null ? ConnectApi.Communities.getCommunity(networkSOQL.id) : null;
		}

		Map<Id, Village__c> villageMapSOQL = new Map<Id, Village__c>();
		if (!inBudgetVillageIdMap.isEmpty()) {
			villageMapSOQL = new Map<Id, Village__c>([SELECT Name FROM Village__c WHERE Id = :inBudgetVillageIdMap]);
		}

		list<Messaging.SingleEmailMessage> singleEmailMessageList =new List<Messaging.SingleEmailMessage>();

		for (Master_Budget_Sheet__c outMasterBudgetSheet : inMasterBudgetSheetMap.keySet()) {
			List<Id> userIdList = new List<Id>();

			for (Id outUserId : inMasterBudgetSheetMap.get(outMasterBudgetSheet)) {
				userIdList.add(outUserId);
			}

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setBccAddresses(userIdList);
			mail.setSubject('Email Master Budget Sheet');

			String body = '<br/>';
			body +='Please go to the Salesforce third party portal for Value Retail.<br/><br/>';

			if(outMasterBudgetSheet.Budget_Village__c != null){
				body +='A new Master Budget Sheet has been submitted by '  + villageMapSOQL.get(outMasterBudgetSheet.Budget_Village__c).Name +  '<br/><br/>';
			} else {
				body +='A new Master Budget Sheet has been submitted.<br/><br/>';
			}
			body += outMasterBudgetSheet.Name +  '<br/><br/>';
			body += (communitySOQL != null ? communitySOQL.siteUrl + '/s/master-budget-sheet/' + outMasterBudgetSheet.Id : '');
			mail.setHtmlBody(body);

			System.debug('Send Email: ' + outMasterBudgetSheet.Id + ' - ' + outMasterBudgetSheet.Name + ': ' + userIdList.size() + ' Agency');
			singleEmailMessageList.add(mail);
		}

		Messaging.sendEmail(singleEmailMessageList, true);
	}

	private static void createMasterBudgetSheetShare (Map<Id, Set<Id>> inUserIdMap) {
		List<Master_Budget_Sheet__Share> masterBudgetSheetShareList = new List<Master_Budget_Sheet__Share>();

		for (Id outUserId : inUserIdMap.keySet()) {
			for (Id outMasterBudgetSheet : inUserIdMap.get(outUserId)) {
				Master_Budget_Sheet__Share masterBudgetSheetShare = new Master_Budget_Sheet__Share();
				masterBudgetSheetShare.ParentId= outMasterBudgetSheet;
				masterBudgetSheetShare.UserOrGroupId = outUserId;
				masterBudgetSheetShare.AccessLevel = EDIT_LEVEL;
				masterBudgetSheetShareList.add(masterBudgetSheetShare);
			}
		}

		System.debug('Number of Master Bufget Sheet Share created: ' + masterBudgetSheetShareList.size());
		Database.insert(masterBudgetSheetShareList, false);
	}

}