public with sharing class VisitTriggerHelper {
    
    public static boolean processVisit = false;
    
    public static void setNoShow(set<Id> visitIds){
        
        list<Visit__c> visitList = [select No_Show__c, Visit_Date_Time__c, Number_of_Guests__c,
                                    (select Id from VIP_Card_Exchanges__r) from Visit__c where Id in :visitIds];
        
        list<VIP_Card_Exchange__c> cardList = new list<VIP_Card_Exchange__c>();
        
        for(Visit__c visit :visitList){
            if(visit.No_Show__c == true){
                visit.Visit_Date_Time__c = null;
                visit.Number_Of_Guests__c = null;
                if (!visit.VIP_Card_Exchanges__r.isEmpty())
                    cardList.addAll(visit.VIP_Card_Exchanges__r);       
            }   
        }
        
        update visitList;
        
        if (!cardList.isEmpty()){               
            delete cardList;
            
        }
    }
    
    // Perform Visit After Update/Create/Delete processing
    public static void processVisitAfter(Map<Id,Visit__c> oldvisits, Map<Id,Visit__c> newvisits){
        
        Map<Id,Visit__c> oldvisitstoprocess = new Map<Id,Visit__c>();
        Map<Id,Visit__c> newvisitstoprocess = new Map<Id,Visit__c>();


        // if all thats changed is the send email flag getting set... then we can ignore it all
        if(newvisits!=null){
            for(Visit__c vst :newvisits.values()){
                Visit__c oldvst = null;
                if(oldvisits != null){
                    oldvst = oldvisits.get(vst.Id);
                }
                
                if(oldvst == null){
                    // then its an insert, so we can just process it.
                    newvisitstoprocess.put(vst.Id, vst);
                }
                else{
                    if(vst.Check_out_Email_Sent__c == oldvst.Check_out_Email_Sent__c && vst.Check_in_Email_Sent__c == oldvst.Check_in_Email_Sent__c){
                        // means we havent changed the email sending, so we can process as per normal
                        // but, if an email fails, then it causes a re-trigger, and we dont want that...
                        // so if the notification errors field is blank, then we can process... but else, lets assume theres an error and not continue
                        if(vst.Email_Notification_Errors__c == null || vst.Email_Notification_Errors__c == ''){
                            // so lets check to see if the visit notes
                            newvisitstoprocess.put(vst.Id, vst);
                            System.debug('something');
                            oldvisitstoprocess.put(vst.Id, oldvst);
                        }
                    }
                    // else it means we have changed the email send settings, and we dont want to do any processing... since all we have changed is the email sending flag
                }
            }
        }
        // Flavio Justino - We need to catch when newvisits is null and oldvisits is not, because this means it's a delete trigger and values get updated accordingly
        else{
            for(Visit__c ov : oldvisits.values()){
                if(ov.id!=null){
                    oldvisitstoprocess.put(ov.Id, ov);
                }
                
            }
        }
        // lets get the valid visits to calculate guests on
        Map<Id,Visit__c> newvisitstoprocessProjections = new Map<Id,Visit__c>();
        Set<Integer> monthsForTheVisits = new Set<Integer>();
        if(newvisits!=null){
            for(Visit__c vst :newvisits.values()){
                Visit__c oldvst = null;
                if(oldvisits != null){
                    oldvst = oldvisits.get(vst.Id);
                }
                
                if(oldvst == null){
                    // this means the visit is an insert (old is null) and we can just add the visit for calculation 
                    if(vst.Number_of_Guests__c > 0){
                        if (!newvisitstoprocessProjections.containskey(vst.Id)) {
                            newvisitstoprocessProjections.put(vst.Id, vst);
                            if(!monthsForTheVisits.contains(vst.Visit_Date_Time__c.month()))
                            {
                                monthsForTheVisits.add(vst.Visit_Date_Time__c.month());
                            }
                        }
                        
                    }
                }
                else{
                    // this means its an update 
                    // lets check if the number of guests has changed
                    if(oldvst.Number_of_Guests__c != vst.Number_of_Guests__c){
                        // means the number of guests has changed, so we need to tot them up
                        if (!newvisitstoprocessProjections.containskey(vst.Id)) {
                            newvisitstoprocessProjections.put(vst.Id, vst);
                            if(!monthsForTheVisits.contains(vst.Visit_Date_Time__c.month()))
                            {
                                monthsForTheVisits.add(vst.Visit_Date_Time__c.month());
                            }
                        }
                    }
                }
                
            }
        }
        
        Set<Id> accountIds = new Set<Id>();
        // lets recalculate the amount of money spent on the VIP visits
        // adding both old and new maps, then we will get inserts, and deletes without having to check.
        // then just de-duplicate by adding to a Set
        
        for(Visit__c vst :newvisitstoprocess.values())
        {
            if(vst.recordTypeID != null){      
                    // if its a VIP visit that has been affected, then we need to update all of its associated accounts
                    if (!accountIds.contains(vst.Account__c)) {
                        accountIds.add(vst.Account__c);
                    }
            }
        }
        
        for(Visit__c ovst :oldvisitstoprocess.values()){
            if(ovst.recordTypeID != null){   
                    if (!accountIds.contains(ovst.Account__c)) {
                        accountIds.add(ovst.Account__c);
                    }
            }
        }
        // now that we have all the affected Account Ids, we need to update them.
        if(accountIds != null){
            updateVIPBrandsPurchasedRollup(accountIds);
        }

        //-------------------------------------------
        // we need to handle the email sending of a booking
        // but if we edit a visit, to say the email was sent, it will re-trigger this process, and we could end in an infinite loop
        // to prevent this, we will only look to see if the status has changed
        
        // if (Check_in_Email_Sent__c ) then ignore
        if(newvisitstoprocess.size() > 0){
            // lets process the visits that have checked in or checked out
            // i dont like doing more queries, but i need to get more data fields.
            List<Visit__c> visitlist = [SELECT ID, Name,Group_Booking__r.RecordTypeId,Group_Booking__r.RecordType.DeveloperName,No_Show__c, Check_Out_Date_Time__c ,Check_out_Email_Sent__c,Number_of_Guests__c, Group_Booking__c, Check_in_Email_Sent__c, Visit_Date_Time__c FROM Visit__c WHERE ID in :newvisitstoprocess.keyset()];
            
            System.debug('On After UPDATE of VISIT!!!! ====== ');
            
            List<ID> allVisitsGB = new List<ID>();
            
            List<Id> checkinVisitsId = new List<Id>();
            List<Id> checkoutVisitsId = new List<Id>();
            
            for(Visit__c vst :visitlist)
            {
                // we want to exclude any emails that have already been sent
                
                
                System.debug('RECORD TYPE = ' + vst.Group_Booking__r.RecordType.DeveloperName);
                
                
                if(vst.Group_Booking__c != null && vst.Number_of_Guests__c >= 1 && vst.No_Show__c == false && vst.Group_Booking__r.RecordType.DeveloperName == 'Group_Booking'){
                    
                    if(vst.Visit_Date_Time__c != null && vst.Check_Out_Date_Time__c == null && !vst.Check_in_Email_Sent__c){
                        // means its a Check in
                        checkinVisitsId.add(vst.Id);
                        allVisitsGB.add(vst.Group_Booking__c);
                        // we need to send the checkin email         
                        System.debug('ADDING VISIT!!!! ====== ' + vst+ ' === ' + vst.Group_Booking__c);          
                    }             
                    
                    
                    if(vst.Visit_Date_Time__c != null && vst.Check_Out_Date_Time__c != null && !vst.Check_out_Email_Sent__c){
                        // means its a checkout
                        checkoutVisitsId.add(vst.Id);
                        allVisitsGB.add(vst.Group_Booking__c);
                        // we need to send the checkout email
                        System.debug('ADDING VISIT!!!! ====== ' + vst+ ' === ' + vst.Group_Booking__c); 
                        
                    }
                }
                
            }
            
            List<Visit__c> checkinVisits = [Select ID, Group_Booking__c,Check_in_Email_Sent__c, Visit_Notes__c,Email_Notification_Errors__c FROM  Visit__c WHERE ID in :checkinVisitsId];
            List<Visit__c> checkoutVisits = [Select ID, Group_Booking__c,Check_out_Email_Sent__c, Visit_Notes__c,Email_Notification_Errors__c FROM  Visit__c WHERE ID in :checkoutVisitsId];
            
            Map<ID,Group_Booking__c> GBMap = new Map<ID,Group_Booking__c>([SELECT Id,Contact__r.Secondary_Email_Address__c,Organisation__r.Account_Email__c ,contact__c,contact__r.email,Secondary_MICE_Contact_Email__c,status__c FROM Group_Booking__c where id in :allVisitsGB]); 
            if(checkinVisits != null && checkinVisits.size() > 0){
                System.debug('checkinVisits is not null!!!! ====== ' + checkinVisits); 
                emailUtils checkinmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_In');
                for(Visit__c vist :checkinVisits){
                    
                    Group_Booking__c GB = GBMap.get(vist.Group_Booking__c);
                    if(GB != null){
                        LIST<string> toaddress = New List<String>();
                        IF(GB.contact__c!= null && GB.contact__r.email != NULL){
                            toaddress.add(GB.contact__r.email);
                        }
                        
                        IF(GB.contact__c!= null && GB.contact__r.Secondary_Email_Address__c != NULL){
                            toaddress.add(GB.contact__r.Secondary_Email_Address__c);
                        }
                        
                        IF(GB.Secondary_MICE_Contact_Email__c != NULL){
                            toaddress.add(GB.Secondary_MICE_Contact_Email__c);
                        }
                        IF(GB.Organisation__c != null && GB.Organisation__r.Account_Email__c  != NULL){
                            toaddress.add(GB.Organisation__r.Account_Email__c );
                        }
                        System.Debug('About to call SEND EMail == == ' + toaddress);
                        // lets check to make sure there are actually addresses to send to
                        
                        if(toaddress.size() > 0){
                            
                            emailUtils.emailSendResponse emailResponse = checkinmailUtils.sendEmail(toaddress,null,vist.Id,null,null,null);
                            // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                            System.Debug('emailResponse == == ' + emailResponse);
                            if(emailResponse.emailSendResult){
                                // only update the visits for the emails that suceeded.
                                if(emailResponse.emailSendResult){
                                    vist.Check_in_Email_Sent__c = true;
                                    vist.Email_Notification_Errors__c = ''; // just clear the error in case its set.
                                }  
                                else{
                                    // need to surface an error if possible
                                    vist.Visit_Notes__c += ' Email Sending Failed - Please Contact IT Support (' + emailResponse.emailResultMessage + ')'; 
                                    vist.Email_Notification_Errors__c = ' Email Sending Failed - Please Contact IT Support (' + emailResponse.emailResultMessage + ')'; 
                                }           
                            }
                        }
                        else{
                            vist.Email_Notification_Errors__c = ' Email Sending Failed - No Valid email addresses found.'; 
                        }
                    }
                }
            }
            // now do the checked out email bit
            if(checkoutVisits != null && checkoutVisits.size() > 0){
                System.debug('checkoutVisits is not null!!!! ====== ' + checkoutVisits); 
                emailUtils checkoutmailUtils = new emailUtils('traveltrade@thebicestervillageshoppingcollection.com', 'Group_Booking_Checked_Out');
                for(Visit__c vist :checkoutVisits){
                    
                    Group_Booking__c GB = GBMap.get(vist.Group_Booking__c);
                    if(GB != null){
                        LIST<string> toaddress = New List<String>();
                        IF(GB.contact__c!= null && GB.contact__r.email != NULL){
                            toaddress.add(GB.contact__r.email);
                        }
                        
                        IF(GB.contact__c!= null && GB.contact__r.Secondary_Email_Address__c != NULL){
                            toaddress.add(GB.contact__r.Secondary_Email_Address__c);
                        }
                        
                        IF(GB.Secondary_MICE_Contact_Email__c != NULL){
                            toaddress.add(GB.Secondary_MICE_Contact_Email__c);
                        }
                        IF(GB.Organisation__c != null && GB.Organisation__r.Account_Email__c  != NULL){
                            toaddress.add(GB.Organisation__r.Account_Email__c );
                        }
                        System.Debug('About to call SEND EMail == == ' + toaddress);
                        if(toaddress.size() > 0){
                            emailUtils.emailSendResponse emailResponse = checkoutmailUtils.sendEmail(toaddress,null,vist.Id,null,null,null);
                            // public emailSendResponse sendEmail( LIST<string> toaddresses,ID whatID, String htmlContent, String plainContent){ 
                            System.Debug('emailResponse == == ' + emailResponse);
                            if(emailResponse.emailSendResult){
                                // only update the visits for the emails that suceeded.
                                if(emailResponse.emailSendResult){
                                    vist.Check_out_Email_Sent__c = true;
                                    vist.Email_Notification_Errors__c = ''; 
                                    
                                }  
                                else{
                                    // need to surface an error if possible
                                    vist.Visit_Notes__c += ' Email Sending Failed - Please Contact IT Support (' + emailResponse.emailResultMessage + ')'; 
                                    vist.Email_Notification_Errors__c = ' Email Sending Failed - Please Contact IT Support (' + emailResponse.emailResultMessage + ')'; 
                                }           
                            }
                        } 
                        else{
                            vist.Email_Notification_Errors__c = ' Email Sending Failed - No Valid email addresses found.'; 
                        }
                        
                    }
                }
            }
            
            processVisit = true;
            
            update checkinVisits;
            update checkoutVisits;
            
        }

        if(newvisits!=null){
            accountOneTimeVisit(newvisits.values());
        } else{
            accountOneTimeVisit(oldvisits.values());
        }
        
        // this is going to become a problem
        Set<Id> PartnerProjectionsAccounts = new Set<Id>();
        // need to get the group booking account, and the partnership promotion account
        List<Visit__c> allVisits = [SELECT ID, Partnership_Promotion__r.Partner__c , Group_Booking__r.Organisation__c FROM Visit__c WHERE ID in :newvisitstoprocessProjections.keyset() AND Number_Of_Guests__c > 0];
        for(Visit__c visititem :allVisits){
            if(visititem.Partnership_Promotion__r.Partner__c != null){
                if (!PartnerProjectionsAccounts.contains(visititem.Partnership_Promotion__r.Partner__c)) {                
                    PartnerProjectionsAccounts.add(visititem.Partnership_Promotion__r.Partner__c);
                }
            }
            if(visititem.Group_Booking__r.Organisation__c != null){
                if (!PartnerProjectionsAccounts.contains(visititem.Group_Booking__r.Organisation__c)) {                
                    PartnerProjectionsAccounts.add(visititem.Group_Booking__r.Organisation__c);
                }
            }
        }
        // im going to have to wrap this in a 
        // now we have a list of accounts that need their visits number of guests re-calculated
        String ThisYear = String.valueOf(date.today().year());
        //String ThisYear = '2018';
        TourismPartnerProjectionUtils.UpdatePartnerProjections(PartnerProjectionsAccounts,ThisYear,monthsForTheVisits);
        
    }    
    
    public static void onBeforeUpdate(Map<Id,Visit__c> newvisits){
        
        //id Group_BookingRecTypeId = Schema.SObjectType.Group_Booking__c.getRecordTypeInfosByName().get('Group_Booking').getRecordTypeId();
		// Below code is added by Harish for Village specific Rooms should be selected.
        Id personalShoppingRecordType = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('Personal Shopping Visit').RecordTypeId;
		Set<id> village_setID = new set<id>();
        map<id, list<Room__c>> villageRoom_Map = new map<id, list<Room__c>>();
        for (Visit__c visit : newvisits.values()) {
        	if(visit.RecordtypeID == personalShoppingRecordType &&  visit.Village__c != null && visit.room__c != null) {
                village_setID.add(visit.Village__c);
            }
        }
        if(!village_setID.isEmpty()) {
        	List<Room__c> roomlist = [SELECT id, Name, village__c from Room__c where village__c IN: village_setID];
            if(!roomlist.isEmpty()) {
                for(Room__c r: roomlist) {
                    if(!villageRoom_Map.containsKey(r.village__c)) {
                        villageRoom_Map.put(r.village__c, new list<Room__c>{r});
                    }
                    else {
                        villageRoom_Map.get(r.village__c).add(r);
                    }
                }
            }
        }
        if(!villageRoom_Map.isEmpty()) {
            for(Visit__c vst : newvisits.values()) {
                if(villageRoom_Map.containsKey(vst.Village__c) && vst.room__c != null ) {
                    set<id> roomid_set = new set<id>();
                    for(Room__c r :villageRoom_Map.get(vst.Village__c)) { 
                       roomid_set.add(r.id);
                    }
                    if(!roomid_set.contains(vst.room__c)) {
                        vst.addError('Please add Village related Room\'s only.');
                    }
                }
            }
        }
    }
    
    // updates all accounts with the rollup summary of the total amount they have purchased for all visits.
    private static void updateVIPBrandsPurchasedRollup(Set<Id> accountIds){
        System.Debug(' accountIds === ' + accountIds + ' == count ==' + accountIds.size());
        List<Id> accIds = new List<Id>();
        Id vipVisitRecordTypeId = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('VIP Visit').RecordTypeId;
        
        // get the accounts to be updated
        for(ID num :accountIds)
        {
            System.Debug('Num == ' + num);
            if(num != null){
                accIds.add(num);
            }
        }
        if(accountIds != null){
            string currentUserCurrency=UserInfo.getDefaultCurrency();
            List<Account> accs = [Select Id, Total_Guest_Spend__c, Last_Visit_Date_Time__c,CurrencyISOCode FROM Account WHERE Id in :accIds];
            System.Debug(' accs === ' + accs + ' ===' + accs.size());
            
            // then also get all all the account visits
            List<Visit__c> visits = [Select Id, Name, Account__c, convertCurrency(Total_Spend__c), Village__c, CurrencyISOCode,RecordTypeId FROM Visit__c WHERE Account__c = :accIds];
            List<AggregateResult> AggregateResultList = [select Account__c, max(Visit_Date_Time__c) maxDate from Visit__c WHERE Account__c = :accIds GROUP BY Account__c];
            System.Debug(' visits === ' + visits + ' ===' + visits.size());
            
            for(Account acc :accs){
                Decimal accTotalGuestSpend = 0.0;
                String accountCurrency = acc.CurrencyISOCode;
                if(acc.CurrencyISOCode!=currentUserCurrency){
                    //Because the visits are being converted to the user currency, we need to make sure that the account has the same currency type so the rollup is correct
                    //useful when there are visits with different currencies
                    acc.CurrencyIsoCode=currentUserCurrency;    
                }
                for(Visit__c vs :visits){
                    if(vs.Account__c == acc.Id && vs.RecordTypeId==vipVisitRecordTypeId){
                           SYSTEM.debug('VISIT AMOUNT: '+vs.Total_Spend__c);
                           // then add the visit to the list for the Sum
                           accTotalGuestSpend += vs.Total_Spend__c;
                           
                           System.Debug(' vs.CurrencyISOCode MODDED === ' + vs.CurrencyISOCode);
                       }
                }
                acc.Total_Guest_Spend__c = accTotalGuestSpend;
                System.Debug(' acc.Total_Guest_Spend__c === ' +  acc.Total_Guest_Spend__c);
                
                if(AggregateResultList != null && AggregateResultList.size() > 0){ 
                    for(AggregateResult aggr:AggregateResultList){
                        Id accountId=(Id)aggr.get('Account__c');
                        if(accountId==acc.id){
                            acc.Last_Visit_Date_Time__c=(Datetime)aggr.get('maxDate');
                        }
                    }
                }
            }
            
            update accs;
        }
    }
    
    public static void onBeforeInsert(List<Visit__c> newvisits){
        
        Id vipVisitRecordTypeId = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('VIP Visit').RecordTypeId;
        List<Visit__c> visitsForCurrency = new List<Visit__c>();
        
        for(VIsit__c visit : newvisits){
            if(visit.RecordTypeId == vipVisitRecordTypeId){
                visitsForCurrency.add(visit);
            }
        }
        
        if(visitsForCurrency != null && !visitsForCurrency.isEMpty()){
            assignVisitCurrency(visitsForCurrency);
        }
        
        Id personalShoppingRecordType = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('Personal Shopping Visit').RecordTypeId;
        List<Id> accList = new List<Id>();
        List<Id> accVisitList = new List<Id>();
        //Added by Harish for display error message for villagesroom does not matched.
        Set<id> village_setID = new set<id>();
        map<id, list<Room__c>> villageRoom_Map = new map<id, list<Room__c>>();
        for (Visit__c visit : newvisits) {            
            accList.add(visit.Account__c);
            if(visit.Account__c!=null){
                accVisitList.add(visit.Account__c);
            }
            if(visit.RecordtypeID == personalShoppingRecordType &&  visit.Village__c != null && visit.Room__c != null) {
                village_setID.add(visit.Village__c);
            }
        }
        if(!village_setID.isEmpty()) {
        	List<Room__c> roomlist = [SELECT id, Name, village__c from Room__c where village__c IN: village_setID];
            if(!roomlist.isEmpty()) {
                for(Room__c r: roomlist) {
                    if(!villageRoom_Map.containsKey(r.village__c)) {
                        villageRoom_Map.put(r.village__c, new list<Room__c>{r});
                    }
                    else {
                        villageRoom_Map.get(r.village__c).add(r);
                    }
                }
            }
        } 
        List<Visit__c> visitAccounts = [Select Id, Account__c FROM Visit__c where Account__c=:accVisitList];
        System.debug('VISIT ACCOUNTS SIZE: '+visitAccounts.size());
        for(Visit__c vst : newvisits){
            vst.Blackbook_Guest_Status__c='1st Visit';
            if(visitAccounts!=null && visitAccounts.size()>0){
                for(Visit__c v: visitAccounts){
                    if(vst.Account__c==v.Account__c){
                        vst.Blackbook_Guest_Status__c='Existing';
                    }
                } 
            }
            SYSTEM.debug('BLACKBOOK STATUS: '+vst.Blackbook_Guest_Status__c);
            if(vst.Room__c != null && !villageRoom_Map.isEmpty() && villageRoom_Map.containsKey(vst.Village__c)) {
                set<id> roomid_set = new set<id>();
                //roomid_set.addAll(villageRoom_Map.get(vst.Village__c).id);  
                for(Room__c r :villageRoom_Map.get(vst.Village__c)) { 
                   roomid_set.add(r.id);
                }
                if(!roomid_set.contains(vst.room__c)) {
                    vst.addError('Please add Village related Room\'s only.');
                }
            }
        }
        
        List<Visit__c> visitAccountsPersonal = [Select Id, Account__c FROM Visit__c where Account__c=:accVisitList AND RecordTypeid = :personalShoppingRecordType];
        System.debug('VISIT ACCOUNTS SIZE - Personal Shopping: '+visitAccountsPersonal.size());

        for(Visit__c vst : newvisits){
            if(vst.RecordTypeId == personalShoppingRecordType){
            	vst.Private_Client_Personal_Shopping_Status__c  ='1st Visit';                
            }

            if(visitAccountsPersonal !=null && visitAccountsPersonal.size()>0){
                for(Visit__c v: visitAccountsPersonal){
                    if(vst.Account__c==v.Account__c){
                        vst.Private_Client_Personal_Shopping_Status__c ='Existing';
                    }
                } 
            }
        }
        List<Visit__c> lasVisitsList = [Select Id, Account__c,Total_Visit_Spend__c FROM Visit__c WHERE Account__c = :accList AND RecordTypeid = :personalShoppingRecordType ORDER BY createddate ASC];         
        // Map Account Id and Last Visit
        Map<Id, Visit__c> lastVisitMap = new Map<Id,Visit__c>();
        
        if(lasVisitsList != null){
            for (Visit__c visit : lasVisitsList) {
                lastVisitMap.put(visit.Account__c, visit);            
            }
        }
        
        for (Visit__c visit : newvisits) {
            // Check if it is a Personal Shopping Visit
            if(visit.RecordTypeID == personalShoppingRecordType){
                visit.last_spend__c = lastVisitMap.get(visit.account__c).Total_Visit_Spend__c;
            }
        }
        
        
    }
    
    public static void assignVisitCurrency(List<Visit__c> newvisits){
        //The currency is now set according to the Custom Currency of the Village
        List<Id> villageIdList = new List<Id>();
        Map<Id, String> villageMap = new Map<Id, String>();
        
        for(Visit__c visit : newvisits){
            if(visit.Village__c != null){
                villageIdList.add(visit.Village__c);
            }
        }
        
        List<Village__c> villageList = new List<Village__c>();
        villageList = [SELECT Id, Name, Currency__c FROM Village__c WHERE Id IN :villageIdList];
        
        if(villageList != null && !villageList.isEmpty()){
            for(Village__c village : villageList){
                villageMap.put(village.Id, village.Currency__c);
            }
        }
        
        for(Visit__c visit : newvisits){
            if(villageMap.keyset().contains(visit.Village__c)){
                visit.CurrencyIsoCode = villageMap.get(visit.Village__c);
                //villageMap.get(visit.Village__c)
                System.Debug(' visit.CurrencyISOCode AS WAS === ' + visit.CurrencyISOCode);
            }
        }
    } 

    Private Static void accountOneTimeVisit(List<Visit__c> visitList) {

        Id personalShoppingRecordType = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('Personal Shopping Visit').RecordTypeId;
        Set<String> setAccount = new Set<String>();
        Map<String, list<Visit__c>> mapAccountVisit = new Map<String, list<Visit__c>>();
        List<Visit__c> lstVisit = new  List<Visit__c>();
        List<Account> lstAccountUpdate = new  List<Account>();
        Integer contVisit = 0;
        
        System.debug('### visitList'+visitList);

        for(Visit__c visit : visitList){
            setAccount.add(visit.Account__c); 
        }
 
        Map<ID, Visit__c> mapVisit = new Map<ID, Visit__c>([Select Id, Account__c,RecordTypeId From Visit__c Where Account__c IN :setAccount]);
        
        for(Visit__c vis : visitList){ 
            for(Visit__c visTotal : mapVisit.values()){
                if(vis.Account__c == visTotal.Account__c){ 
                    lstVisit.add(visTotal);
                }
                mapAccountVisit.put(vis.Account__c, lstVisit);	
            }
        }

        for(Visit__c visitResult : visitList){
            contVisit = 0;
            List<Visit__c> lstResult = mapAccountVisit.get(visitResult.Account__c);
            Account accUpdate = new Account(Id=visitResult.Account__c);
           	
            if(lstResult != null){
                for(Visit__c visit : lstResult ) {
                    if(visit.RecordTypeId == personalShoppingRecordType) {
                        contVisit = contVisit + 1;
                    }
                }
    
                System.debug('### contVisit'+contVisit);
    
                accUpdate.Personal_Shopping_engagements__c = contVisit;
            
                System.debug('### lstResult'+lstResult.Size());
                
                if(lstResult.Size() == 1){
                    accUpdate.One_Time_Visitor__c = true;
                } else {
                    accUpdate.One_Time_Visitor__c = false;
                }
    
                lstAccountUpdate.add(accUpdate);
            }
        }
        
        if(lstAccountUpdate.Size() > 0)
        	Update lstAccountUpdate;
    }

}