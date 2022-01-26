@isTest
public class HFSDeliverToGuestControllerTest {

	@TestSetup
	static void init(){
		HFS_Collection_Point__c hfsCollectionPoint = new HFS_Collection_Point__c();
		hfsCollectionPoint.Name = 'Bicester';
		hfsCollectionPoint.Village__c = 'Bicester';
		insert hfsCollectionPoint;

		Village__c village = new Village__c();
		village.Oracle_Source_Template_Number__c = 'VR Campaign Projects US01';
		village.Oracle_Organisation__c = 'US01_Local Brand & Communications';
		village.Name = 'Bicester';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1;
		village.Village_Code__c = 'BV';
		insert village;

		Case hfsCase = new Case();
		hfsCase.Village__c = village.Id;
		hfsCase.Service_Guest_ID__c = '88899';
		hfsCase.Service_Guest_Number__c = '88899';
		hfsCase.Guest_ID_Number_Part__c = 899;
		hfsCase.Payment_Status__c = 'Payment on Collection';
		hfsCase.Client_QR_Code__c = '88899';
		hfsCase.Status = 'New';
		hfsCase.Service_Date__c = system.today();
		hfsCase.Guest_30_minutes__c = false;
		insert hfsCase;

		Account account = new Account();
		account.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Brand'].Id;
		account.Name = 'Brand 1';
		insert account;

		Village_Presence__c villagePresence = new Village_Presence__c();
		villagePresence.Name = 'Account Brand Test 2 in Bicester';
		villagePresence.Brand__c = account.Id;
		villagePresence.Village__c = village.Id;
		villagePresence.Status__c = 'Exited';
		villagePresence.HFS_Bags_Used__c = 0;
		insert villagePresence;

		case_item__c caseItem = new case_item__c();
		caseItem.Case__c = hfsCase.Id;
		caseItem.Village_Presence__c = villagePresence.id;
		caseItem.status__c = 'Awaiting Pick-up from Brand';
		caseItem.Start_Time__c = system.now();
		caseItem.Estimated_Spend__c = 123.00;
		caseItem.Item_Count__c = 1;
		caseItem.Bag_Barcodes_Manual__c = '111111,false';
		caseItem.Pickup_Location__c = 'Teste Bicester Brand in Bicester';
		caseItem.Require_a_Runner__c = true;
		caseItem.HFS_Bag_Drop__c = false;
		caseItem.HFS_Bag_Transfer__c = false;
		insert caseItem;

		HFS_Bag__c hfsBag = new HFS_Bag__c();
		hfsBag.Barcode__c = '15795';
		hfsBag.HFS_Job__c = getJobLastId();
		hfsBag.Status__c = 'In Transit';
		hfsBag.HFS_Add_Reason__c = 'Guest request';
		hfsBag.HFS_Bag_Active__c = true;
		hfsBag.HFS_Purchase__c = caseItem.Id;
		hfsBag.Scanned_for_Quick_Handover__c = true;
		insert hfsBag;
	}

	@isTest
	static void testHFSDeliverToGuestController(){
		PageReference pageReference = Page.HFSDeliverToGuest;
		Test.setCurrentPage(pageReference);
		pageReference.getParameters().put('Id', getJobLastId());
		pageReference.getParameters().put('barcodeBagQH', [SELECT Barcode__c FROM HFS_Bag__c WHERE HFS_Bag_Active__c = true LIMIT 1].Barcode__c);
		ApexPages.StandardController standardController = new ApexPages.StandardController(new HFS_Job__c());
		Test.startTest();
		HFSDeliverToGuestController hfsDeliverToGuestCont = new HFSDeliverToGuestController(standardController);
		hfsDeliverToGuestCont.updateBags();
		hfsDeliverToGuestCont.verifyEquals(null);
		hfsDeliverToGuestCont.scanBag();
		hfsDeliverToGuestCont.CurrentJob();
		hfsDeliverToGuestCont.AssignedJob();
		hfsDeliverToGuestCont.AvailableJob();
		HFSDeliverToGuestController.handOvertoGuest(String.valueOf(getJobLastId()));
		Test.stopTest();
	}

	private static Id getJobLastId () {
		return [SELECT Id FROM HFS_Job__c ORDER BY CreatedDate DESC LIMIT 1].Id;
	}
}