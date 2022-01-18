public with sharing class TourismPartnerProjectionUtils {

	public static void UpdatePartnerProjections(Set<Id> AccountIds, String year,Set<Integer> Months){

		// not particularly great code, but we are going to call the accounts, month by month
		for(Integer x = 1; x < 13; x++){
			if(Months.contains(x)){
			System.debug('About to call future method : AccountIds = ' + AccountIds);
			FutureUpdatePartnerProjections(AccountIds, x, year);
		}
		}

	}
	// goes through the list of all visits for an account, and updates the projections for that partner, to update the 'Actuals'
	// this will only calculate the current years numbers
	@future
	public static void FutureUpdatePartnerProjections(Set<Id> AccountIds, Integer Month, String year){
		// lets get todays date, and use the datepart year
		String ThisYear = year ; 
		Integer intYear = Integer.valueOf(year);
		// Select Id, Date__c from Object where CALENDAR_MONTH(Date__c) == MonthInVF

		System.debug('AccountIds === ' + AccountIds.size() + ' ----- ' + AccountIds);
		// lets get all the visits for the accounts in question
		List<Visit__c> allVisits = [SELECT ID, Partnership_Promotion__r.Partner__c , Group_Booking__r.Organisation__c,Number_of_Guests__c,Visit_Date_Time__c, Village__r.Name FROM Visit__c WHERE (Partnership_Promotion__r.Partner__c in :AccountIds OR Group_Booking__r.Organisation__c in :AccountIds) AND Number_Of_Guests__c > 0 AND CALENDAR_MONTH(Visit_Date_Time__c )  = :Month AND CALENDAR_YEAR(Visit_Date_Time__c) = :intYear];
 		System.debug('allVisits === ' + allVisits.size() + ' ----- ' + allVisits);
		// lets build a map of lists
		Map<ID, List<Visit__c>> partnerVisitMap = new Map<ID, List<Visit__c>>();
		for (Visit__c vst : allVisits) {
			// fist lets use a device to get the account ID
			ID accID = null;
			if(vst.Partnership_Promotion__r.Partner__c != null)
			{
				accID = vst.Partnership_Promotion__r.Partner__c;
			}
			else if(vst.Group_Booking__r.Organisation__c != null){
				accID = vst.Group_Booking__r.Organisation__c;
			}
			if(accID != null){
			    List<Visit__c> listSo = partnerVisitMap.get(accID);
			    if (listSo == null) {
			        listSo = new List<Visit__c>();
			        partnerVisitMap.put(accID, listSo);
			    }
			    System.debug('Adding Visit to acc === ' + vst);
			    listSo.add(vst);
			}
			// if it is null, then its a dud visit....
		}

		// now we have a nice map of visits by account.
		// next we will need to know what projections to update
		List<Tourism_Partner_Projection__c> projections = [SELECT ID, Name,Partnership_Account__c, Village__c FROM Tourism_Partner_Projection__c WHERE Projected_Year__c = :ThisYear AND Partnership_Account__c in :partnerVisitMap.keyset()];
		// we have to assume that there is only 1 projection per year, per partner (if there are more, then it will only update the first)
		List<Tourism_Partner_Projection__c> projectionsforupdate = new List<Tourism_Partner_Projection__c>();
		for(ID accID :partnerVisitMap.keyset()){
			// need to try to do it by village too
			Map<String,Map<String,Integer>> visitByVillageByMonth = new Map<String,Map<String,Integer>>();


		//	Map<String,Integer> visitGuestsByMonthMap = new Map<String,Integer>();
			// now we get the visits
			List<Visit__c> visits = partnerVisitMap.get(accID);
			// now loop the visits
			for(Visit__c vst :visits){

				// check if this village has been added yet
				if(visitByVillageByMonth.get(vst.Village__r.Name) != null){
					// then the village does exist, and we need to add to the guests
				}
				else
				{
					// means we need to add the village
					visitByVillageByMonth.put(vst.Village__r.Name,new Map<String,Integer>());
				}

				// now we need to count the number of guests by month
				Map<String,Integer> visitGuestsByMonthMap = visitByVillageByMonth.get(vst.Village__r.Name);
				Integer guestcount = visitGuestsByMonthMap.get(vst.Visit_Date_Time__c.format('MMMMM'));
			    if (guestcount == null) {				    	        
			        visitGuestsByMonthMap.put(vst.Visit_Date_Time__c.format('MMMMM'), Integer.Valueof(vst.Number_Of_Guests__c)); // just making the count 0 and will provide the actual value after
			    }
			    else
			    {
			    	guestcount += Integer.Valueof(vst.Number_Of_Guests__c);
			    	visitGuestsByMonthMap.put(vst.Visit_Date_Time__c.format('MMMMM'), guestcount); 
				}
				// then add the map to the village
				visitByVillageByMonth.put(vst.Village__r.Name,visitGuestsByMonthMap);
				System.debug('visitGuestsByMonthMap === ' + visitGuestsByMonthMap);
			}

			// now we have finished looping all the visits for that account, we can update the projections
			for(Tourism_Partner_Projection__c proj :projections){
				// lets get the projection for this account and village
				if(proj.Partnership_Account__c == accID){
					Map<String,Integer> visitGuestsByMonthMap = visitByVillageByMonth.get(proj.Village__c);
					System.debug('proj === ' + proj);
					// now we can update each field
					// need to get the value by village and month....
					if(Month == 1){
						proj.January_Actual__c  = visitGuestsByMonthMap.get('January');}
					if(Month == 2){
					proj.February_Actual__c = visitGuestsByMonthMap.get('February');}
					if(Month == 3){
					proj.March_Actual__c = visitGuestsByMonthMap.get('March');}
					if(Month == 4){
					proj.April_Actual__c = visitGuestsByMonthMap.get('April');}
					if(Month == 5){
					proj.May_Actual__c = visitGuestsByMonthMap.get('May');}
					if(Month == 6){
					proj.June_Actual__c = visitGuestsByMonthMap.get('June');}
					if(Month == 7){
					proj.July_Actual__c = visitGuestsByMonthMap.get('July');}
					if(Month == 8){
					proj.August_Actual__c = visitGuestsByMonthMap.get('August');}
					if(Month == 9){
					proj.September_Actual__c = visitGuestsByMonthMap.get('September');}
					if(Month == 10){
					proj.October_Actual__c = visitGuestsByMonthMap.get('October');}
					if(Month == 11){
					proj.November_Actual__c = visitGuestsByMonthMap.get('November');}
					if(Month == 12){
					proj.December_Actual__c = visitGuestsByMonthMap.get('December');}
					

					projectionsforupdate.add(proj);
				}
			}
		}
		update projectionsforupdate;
	}
}