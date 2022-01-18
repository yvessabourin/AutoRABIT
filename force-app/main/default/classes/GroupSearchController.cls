global with sharing class GroupSearchController {


  public Boolean showHFSButton {public get; private set;}
    private static final id grpBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByName.get('Group Booking').RecordTypeId;    
    private static final id indBookingRecordTypeId = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByName.get('Individuals Partnership').RecordTypeId;

    private static string[] statusFilterList = new List<string>{'Removed', 'Cancelled'};
    
    private static final Map<string,Id> imageFolders = populateImageFolders();
    
    public static final string usersVillage = getUsersVillage();
    private static final string usersVillageId = getUsersVillageId();
    private static final string defaultImageId = getDefaultImageId();
    private static final string imagePrefix = ''; //'/servlet/servlet.FileDownload?file=';
    public static String guestRecType { get;  set;}
    
    private static final Map<string,string> statusIcons = populateStatusIcons();
    public static String groupBookings { get;  set;}
    public static String summary { get; set; }
    public static String guestsumm { get; set; }
    public static Integer VIPCardCount { get; set; }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public GroupSearchController() {
      
                showHFSButton = false;
            List<PermissionSetAssignment> usersPerms = [SELECT ID,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment perm :usersPerms){
            if(perm.PermissionSet.Name == 'Hands_Free_Shopping_Enabled'){
                showHFSButton = true;
            }          
        } 

        groupBookings = getGroupBookingsToday();

        guestRecType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Guest').RecordTypeId;

    }

    private static Map<string,string> populateStatusIcons()
    {
        // get the status icons 
        Map<string,string> returnIcons = new Map<string,string>();
      /*  System.debug('imageFolders = = ' + imageFolders);
         List<Document> documents = [select Id,Name from Document where FolderId = :imageFolders.get('Logos')];
         for(Document d :documents)
         {
              System.debug('Icon = ' + d);
            returnIcons.put(d.Name,d.Id);
         }
         System.debug('returnIcons = ' + returnIcons);
       */


         //-----------------------

StaticResource static_resource = [SELECT Id,Name, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'TICImages'
                                  LIMIT 1];
String clock_ref = '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name')
                    + '/clock-on-wall.png';
String check_ref = '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name')
                    + '/map-point-pointer.png';
String logout_ref = '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name')
                    + '/checking-mark.png';
String checkout_ref = '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name')
                    + '/remote-control-fast-forward-button.png';

String vipcard_ref = '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name')
                    + '/cinema.png';


returnIcons.put('clock',clock_ref);
returnIcons.put('check',check_ref);
returnIcons.put('logout',logout_ref);
returnIcons.put('checkout',checkout_ref);
returnIcons.put('vipcard',vipcard_ref);

//System.assertEquals(1,2,'url_file_ref === ' + url_file_ref );


         //-0-----------------------

           return returnIcons;
    }
    
    private static Map<string,Id> populateImageFolders(){
        // get all the folders
        Map<string,Id> returnfolders = new Map<string,Id>();
         List<Folder> folders = [select Id,Name from Folder];
         for(Folder f :folders)
         {
            returnfolders.put(f.Name,f.Id);
         }
         return returnfolders;
    }    
    
    public static string getUsersVillage(){


        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
                            
        string village = users[0].Village__c;
        
        return village; 
                
    }

    private static string getUsersVillageId(){


        string userId = UserInfo.getUserId();
        list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :userId
                            LIMIT 1];
                            
        string village = users[0].Village__c;
        
        Village__c v = [select Id from Village__c where Name = :village limit 1];
        string villageId = '';
        if (v != null){
            villageId = v.Id;
        }
        return villageId; 
                
    }
    

    private static string getDefaultImageId(){
        Id folderId;
        if (test.isRunningTest()){
            folderId = UserInfo.getUserId();
        } else {
            folderId = [select Id from Folder where Name = 'Partner Images'].Id; 
        }
        List<Document> docs = [select Id from Document where FolderId = :folderId and Name = 'Default'];
        string imageId = '';
        if(docs.size() > 0){
         imageId = docs[0].Id;
        }
        return imageId;
        
    } 

    global static String getGroupBookingsToday(){
System.Debug('getGroupBookingsToday ====== ');
        list <groupKey> returnList = new list<groupKey>();           
                 map<Id, Group_Booking__c> bookingList = new map<Id, Group_Booking__c>([select Id, Name, Valid_From__c, Valid_To__c, Expected_Arrival__c, Expected_Departure__c,
                                                                    Organisation__r.Name,Organisation__r.Logo_Id__c, Organisation__r.Funding_Program_Lightning__c, Name_of_Event__c, RecordType.Name, Village__c,
                                                                    Number_of_Visitors_Expected__c
                                                                    from Group_Booking__c 
                                                                    where (village__c =:usersVillageId or village__c = null) and Recordtypeid != :indBookingRecordTypeId 
                                                                    and ((Valid_From__c <= :system.today() and Valid_to__c >= :system.today())
                                                                    or Expected_Arrival__c >= :system.today())
                                                                    AND Status__c NOT in :statusFilterList ]);  
System.Debug('bookingList ====== ' + bookingList);
               list<AggregateResult> arList2  = [select Group_Booking__c, count(Id)visitCount, count(VIP_Cards_Exchanged__c)exchangeCount 
                                from Visit__c
                                where Group_Booking__c in :bookingList.keySet()
                                and (Visit_Date_Time__c = TODAY or Expected_Arrival_Date_Time__c = TODAY) 
                                group by Group_Booking__c
                                  ORDER BY MAX(Visit_Date_Time__c) DESC NULLS FIRST ];

System.Debug('arList2 ====== ' + arList2);

                                // was being ordered like this: "order by count(Id) desc" not sure why....

        // i dont think i can get away with this, so ill have to do another query
        Map<Id, List<Visit__c>> visitMapByGroupBookingId = new Map<Id, List<Visit__c>>();

        for(Visit__c VisitItem  :[select Group_Booking__c, Id, Visit_Date_Time__c,  Check_out_date_time__c,Number_of_Guests__c,VIP_Cards_Exchanged__c 
                                from Visit__c
                                where Group_Booking__c in :bookingList.keySet()
                                and (Visit_Date_Time__c = TODAY or Expected_Arrival_Date_Time__c = TODAY) ORDER BY Visit_Date_Time__c DESC NULLS FIRST ])
        {
            if(visitMapByGroupBookingId.containsKey(VisitItem.Group_Booking__c)) {
                List<Visit__c> VisitsForMap = visitMapByGroupBookingId.get(VisitItem.Group_Booking__c);
                VisitsForMap.add(VisitItem);
                visitMapByGroupBookingId.put(VisitItem.Group_Booking__c, VisitsForMap);
            } else {
                visitMapByGroupBookingId.put(VisitItem.Group_Booking__c, new List<Visit__c> { VisitItem });
            }

        }

System.Debug('visitMapByGroupBookingId ====== ' + visitMapByGroupBookingId);

        bookingSummary booksummary = new bookingSummary();
        integer awaitingcount = 0;
        integer arrivedcount = 0;
        integer checkedoutcount = 0;
        integer totalcount = 0;
        guestsSummary gsummary = new guestsSummary();
        integer gawaitingcount = 0;
        integer garrivedcount = 0;
        integer gcheckedoutcount = 0;
        integer gtotalcount = 0;
        integer vipcardsExchanged = 0;

        for (AggregateResult ar :arList2){
            groupKey p = new groupKey();
            Group_Booking__c g = bookingList.get(string.valueOf(ar.get('Group_Booking__c')));
            
            List<Visit__c> visitsForGB = visitMapByGroupBookingId.get(string.valueOf(ar.get('Group_Booking__c')));
            // now lets loop through the visits, and if any visits are awaiting, then we set the 
            boolean GBAwaiting = true;
            boolean GBArrived = false;
            boolean GBLeft = false;
            integer totalactualguestcount = 0;
            integer bookingVIPCards = 0;
            for(Visit__c v :visitsForGB){
                p.visitId = v.Id;
                if(v.Visit_Date_Time__c != null){
                    // means a visit has arrived.
                    GBArrived = true;
                    p.visitarrivalTime = v.Visit_Date_Time__c.format();
                }
                if(v.Check_out_date_time__c != null){
                    // means a visit has left
                    GBLeft = true;
                }
                if(v.Number_of_Guests__c != null){
                    totalactualguestcount += v.Number_of_Guests__c.intValue();
                }
                if(v.VIP_Cards_Exchanged__c != null){
                    vipcardsExchanged += v.VIP_Cards_Exchanged__c.intValue();
                    bookingVIPCards += v.VIP_Cards_Exchanged__c.intValue();
                }
            }                    
            
            p.cardsscanned = String.valueOf(bookingVIPCards);
            p.cardsImageURL = imagePrefix + statusIcons.get('vipcard');

            p.Id = g.Id;
            p.Name = g.Name;
            p.campaignName = g.Name_of_Event__c;
            p.Partner = g.Organisation__r.Name;
            if (g.Valid_From__c != null)
                p.startDate =  g.Valid_From__c.format();
            if (g.Valid_To__c != null)
                p.endDate = g.Valid_To__c.format();
            if (g.Expected_Arrival__c != null)
                p.arrivalTime = g.Expected_Arrival__c.format();
            if (string.isnotBlank(g.Organisation__r.Logo_Id__c)){
              p.imageUrl = g.Organisation__r.logo_id__c;
            } else {
              p.imageUrl = imagePrefix + defaultImageId;
            }
            
            // try to get the status, and set the status image
            if(GBAwaiting){
                p.statusimageUrl = imagePrefix + statusIcons.get('clock');
                p.statusText = 'Awaiting Arrival';     
                   
            }
            if(GBArrived){
                p.statusimageUrl = imagePrefix + statusIcons.get('check');
                p.statusText = 'Arrived at Village'; 
                if(visitsForGB.size() == 1){
                    // means there is only 1 visit, and we can quickcheckout 
                    p.quickcheckoutvisitid = visitsForGB[0].Id;
                   //grbook.statusText == 'Arrived at Village';
                }         
                     
            }
            if(GBLeft){
                p.statusimageUrl = imagePrefix + statusIcons.get('logout');
                p.statusText = 'Checked out';                          
            }

            if(p.statusText == 'Checked out'){
                checkedoutcount ++;   
                gcheckedoutcount += totalactualguestcount;  
            }
            if(p.statusText == 'Arrived at Village'){
                 arrivedcount ++; 
                 // also add the actual number of guests
                 garrivedcount += totalactualguestcount;     
            }
            if(p.statusText == 'Awaiting Arrival'){
                 awaitingcount ++; 
                if(g.Number_of_Visitors_Expected__c != null){ 
                    gawaitingcount += g.Number_of_Visitors_Expected__c.intValue();
                }
            }

            totalcount ++;
            p.checkoutimageUrl = statusIcons.get('checkout');        
            p.pType = 'Booking';
            p.recType = g.RecordType.Name;
            p.numberOfVisitors = string.valueOf(g.Number_of_Visitors_Expected__c);
            if(totalactualguestcount != 0){
                p.actualnumberOfVisitors = string.valueOf(totalactualguestcount);
            }
            p.fundingProgram = g.Organisation__r.Funding_Program_Lightning__c;    
            returnList.add(p);
        } 
        // then add all the totals to the object
        booksummary.awaiting = String.valueOf(awaitingcount);
        booksummary.checkedout = String.valueOf(checkedoutcount);
        booksummary.arrived = String.valueOf(arrivedcount);
        booksummary.total = String.valueOf(totalcount);

        gsummary.awaiting = String.valueOf(gawaitingcount);
        gsummary.checkedout = String.valueOf(gcheckedoutcount);
        gsummary.arrived = String.valueOf(garrivedcount);

        summary = JSON.serialize(booksummary);
        guestsumm = JSON.serialize(gsummary);

        // vip cards exchanged
        VIPCardCount = vipcardsExchanged;
   return JSON.serialize(returnList);
       // return returnList;
    }
    
    @RemoteAction
    global static string quickCheckout(string visitId){
            // update the visit with a chechout date/time of now
            try{
            ID vID = (Id)visitId;
            Visit__c vst = [Select ID,Check_out_date_time__c FROM Visit__c WHERE ID = :vID ];

            vst.Check_out_date_time__c = DateTime.now();

            update vst;
            return '';
        }
        catch(Exception ex){
                return 'ERROR ' + ex.getMessage();

        }
    }
    
    @RemoteAction
    global static string clonebooking(string SourceBookingID){
        // clone the booking, and return the new booking ID
        try{
            // first lets get the source booking
            Group_Booking__c sourceGB = [select Name, Name_of_Event__c, Status__c, Village__c, Expected_Arrival__c, Expected_Departure__c, Visitors_country_of_origin__c, Expected_mode_of_transport__c,
            Group_type__c, Organisation__c,Primary_Contacts_Secondary_Email__c,Number_of_Visitors_Expected__c,Transport_Required__c,Gift__c,Mode_of_Transport__c,Gift_Card__c,Food_Beverage__c, 
            VIP_Lounge_Access__c, Boutique_Private_Viewing__c, Welcome_Pack__c, Notes_and_Additional_Comments__c, Secondary_MICE_Org_or_Agency_name__c,  
            Secondary_MICE_Contact_Address_1__c ,
            Secondary_MICE_Contact_Title__c ,
            Secondary_MICE_Contact_Address_2__c ,
            Secondary_MICE_Contact_First_Name__c,   
            Secondary_MICE_Contact_Address_3__c ,
            Secondary_MICE_Contact_Last_Name__c ,
            Secondary_MICE_Contact_Town_City__c ,
            Secondary_MICE_Contact_Phone__c ,
            Secondary_MICE_Contact_State__c ,
            Secondary_MICE_Contact_Email__c  ,
            Secondary_MICE_Contact_ZIP_Postcode__c  ,
            Secondary_MICE_Contact_Country__c,VR_Representative__c,RecordTypeId from Group_Booking__c where id = :SourceBookingID limit 1][0];


            Group_Booking__c  targetBooking = new Group_Booking__c();
            targetBooking.Name_of_Event__c= sourceGB.Name_of_Event__c;
            targetBooking.recordTypeId = sourceGB.recordTypeId;
            targetBooking.Status__c = 'Pending';
            targetBooking.Village__c = sourceGB.Village__c;
            targetBooking.Expected_Arrival__c = system.today();
            targetBooking.Expected_Departure__c = system.now();
            targetBooking.visitors_country_of_origin__c = sourceGB.visitors_country_of_origin__c;
            targetBooking.expected_mode_of_transport__c = sourceGB.expected_mode_of_transport__c;
            targetBooking.group_type__c = sourceGB.group_type__c;
            targetBooking.Primary_Contacts_Secondary_Email__c = sourceGB.Primary_Contacts_Secondary_Email__c;
            targetBooking.Organisation__c =sourceGB.Organisation__c;
            targetBooking.Number_of_Visitors_Expected__c = sourceGB.Number_of_Visitors_Expected__c;
            targetBooking.Transport_Required__c   = sourceGB.Transport_Required__c;
            targetBooking.Gift__c = sourceGB.Gift__c;
            targetBooking.Mode_of_Transport__c    = sourceGB.Mode_of_Transport__c;
            targetBooking.Gift_Card__c    = sourceGB.Gift_Card__c;
            targetBooking.Food_Beverage__c =    sourceGB.Food_Beverage__c;
            targetBooking.VIP_Lounge_Access__c =    sourceGB.VIP_Lounge_Access__c;
            targetBooking.Boutique_Private_Viewing__c = sourceGB.Boutique_Private_Viewing__c;
            targetBooking.Welcome_Pack__c  = sourceGB.Welcome_Pack__c;
            targetBooking.Notes_and_Additional_Comments__c = sourceGB.Notes_and_Additional_Comments__c + ' - Booking cloned from ' + sourceGB.Name + ' - ' + sourceGB.Id;
            targetBooking.Secondary_MICE_Org_or_Agency_name__c = sourceGB.Secondary_MICE_Org_or_Agency_name__c; 
            targetBooking.Secondary_MICE_Contact_Address_1__c   = sourceGB.Secondary_MICE_Contact_Address_1__c;
            targetBooking.Secondary_MICE_Contact_Title__c   = sourceGB.Secondary_MICE_Contact_Title__c;
            targetBooking.Secondary_MICE_Contact_Address_2__c   = sourceGB.Secondary_MICE_Contact_Address_2__c;
            targetBooking.Secondary_MICE_Contact_First_Name__c  = sourceGB.Secondary_MICE_Contact_First_Name__c;
            targetBooking.Secondary_MICE_Contact_Address_3__c   = sourceGB.Secondary_MICE_Contact_Address_3__c;
            targetBooking.Secondary_MICE_Contact_Last_Name__c   = sourceGB.Secondary_MICE_Contact_Last_Name__c;
            targetBooking.Secondary_MICE_Contact_Town_City__c   = sourceGB.Secondary_MICE_Contact_Town_City__c;
            targetBooking.Secondary_MICE_Contact_Phone__c   = sourceGB.Secondary_MICE_Contact_Phone__c;
            targetBooking.Secondary_MICE_Contact_State__c   = sourceGB.Secondary_MICE_Contact_State__c;
            targetBooking.Secondary_MICE_Contact_Email__c   = sourceGB.Secondary_MICE_Contact_Email__c;
            targetBooking.Secondary_MICE_Contact_ZIP_Postcode__c    = sourceGB.Secondary_MICE_Contact_ZIP_Postcode__c;
            targetBooking.Secondary_MICE_Contact_Country__c = sourceGB.Secondary_MICE_Contact_Country__c;
            targetBooking.VR_Representative__c = sourceGB.VR_Representative__c;

            insert targetBooking;

          // if this succeeds, then we can mark the old booking as 'cancelled'

            sourceGB.Status__c = 'Cancelled';
            sourceGB.Notes_and_Additional_Comments__c += ' - Booking cloned into ' + targetBooking.Name + ' - ' + targetBooking.Id;
            update sourceGB;

          // but also, we need to make sure the new group booking is confirmed, and we can do that by making it status = confirmed.
            targetBooking.Status__c = 'Confirmed';
            update targetBooking;
            // then we can return the new ID, and let the checkin continue

            return String.valueOf(targetBooking.ID);
        }
        catch(Exception ex){
                return 'ERROR ' + ex.getMessage();

        }
    }


    @RemoteAction
    global static list<groupKey> searchActivities(string param){
    
        list<groupKey> returnList = new list<groupKey>();
          

        
        string param1 = '\'' + '*' + param + '*' + '\'';
        string param2 = '\'' + param + '*' + '\'';
        string param3 = '\'' + '*' + param + '\'';
        string param4 = param;
        param = '\'' + param  + '\'';
        string searchParam = param4 + ' OR (' + param1 + ' OR ' + param2 + ' OR ' + param3 + ' OR ' + param + ')'; 
        
        system.debug(' @@@ Search for .. ' + searchParam );
            
   /*     // Due a salesforce limitation on search numbers (only 2000 records at a time) we are forced to do 2 separate queries.... which could cause some delays :( 
        List<List<SObject>> searchList = [FIND :searchParam  IN ALL FIELDS 
                          RETURNING                         
                          Group_Booking__c (Id, Name, Valid_From__c, Valid_To__c, Expected_Arrival__c, Expected_Departure__c, Number_of_Visitors_Expected__c,
                                                                    Organisation__r.Name, Organisation__r.Logo_Id__c,Organisation__r.Funding_Program__r.Name, Name_of_Event__c, RecordType.Name, RecordTypeId
                                                                     where (village__c =:usersVillageId or village__c = null) and ((Valid_From__c <= :system.today() and Valid_to__c >= :system.today())
                                                                    or Expected_Arrival__c >= :system.today())
                                                                    AND Status__c NOT in :statusFilterList)];
*/
                                                                            // Due a salesforce limitation on search numbers (only 2000 records at a time) we are forced to do 2 separate queries.... which could cause some delays :( 
        List<List<SObject>> searchList = [FIND :searchParam  IN ALL FIELDS 
                          RETURNING                         
                          Group_Booking__c (Id, Name, Valid_From__c, Valid_To__c, Expected_Arrival__c, Expected_Departure__c, Number_of_Visitors_Expected__c,
                                                                    Organisation__r.Name, Organisation__r.Logo_Id__c,Organisation__r.Funding_Program_Lightning__c, Name_of_Event__c, RecordType.Name, RecordTypeId
                                                                     where (village__c =:usersVillageId or village__c = null)
                                                                    AND Status__c NOT in :statusFilterList ORDER BY Expected_Arrival__c DESC NULLS FIRST)];

system.debug('@@@@ searchList   ' + searchList);
system.debug('@@@@ searchList[0]   ' + searchList[0]);
//system.debug('@@@@ searchList[1]   ' + searchList[1]);



          //add the campaigns that were found to this list                                    
        list<Group_Booking__c> foundBookings = ((list<Group_Booking__c>) searchList[0]);
                 

        
        if (foundBookings.size() > 0){

            // we also need to get the visits for these bookings
            Map<Id, List<Visit__c>> visitMapByGroupBookingId = new Map<Id, List<Visit__c>>();

            for(Visit__c VisitItem  :[select Group_Booking__c, Id, Visit_Date_Time__c,  Check_out_date_time__c,Number_of_Guests__c,VIP_Cards_Exchanged__c 
                                    from Visit__c
                                    where Group_Booking__c in :foundBookings
                                     ORDER BY Visit_Date_Time__c DESC NULLS FIRST ])
            {
                if(visitMapByGroupBookingId.containsKey(VisitItem.Group_Booking__c)) {
                    List<Visit__c> VisitsForMap = visitMapByGroupBookingId.get(VisitItem.Group_Booking__c);
                    VisitsForMap.add(VisitItem);
                    visitMapByGroupBookingId.put(VisitItem.Group_Booking__c, VisitsForMap);
                } else {
                    visitMapByGroupBookingId.put(VisitItem.Group_Booking__c, new List<Visit__c> { VisitItem });
                }

            }

        integer awaitingcount = 0;
        integer arrivedcount = 0;
        integer checkedoutcount = 0;
        integer totalcount = 0;
        integer gawaitingcount = 0;
        integer garrivedcount = 0;
        integer gcheckedoutcount = 0;
        integer gtotalcount = 0;
        integer vipcardsExchanged = 0;

System.debug(' visitMapByGroupBookingId ==== ' + visitMapByGroupBookingId);
            for (Integer i=0; i<foundBookings.size(); i++) {

                List<Visit__c> visitsForGB = visitMapByGroupBookingId.get(string.valueOf(foundBookings[i].Id));



                groupKey p = new groupKey();
                
                // now lets loop through the visits, and if any visits are awaiting, then we set the 
                boolean GBAwaiting = true;
                boolean GBArrived = false;
                boolean GBLeft = false;
                integer totalactualguestcount = 0;
                if(visitsForGB != null){
                    for(Visit__c v :visitsForGB){
                        p.visitId = v.Id;
                        if(v.Visit_Date_Time__c != null){
                            // means a visit has arrived.
                            GBArrived = true;
                            p.visitarrivalTime = v.Visit_Date_Time__c.format();
                        }
                        if(v.Check_out_date_time__c != null){
                            // means a visit has left
                            GBLeft = true;
                        }
                        if(v.Number_of_Guests__c != null){
                            totalactualguestcount += v.Number_of_Guests__c.intValue();
                        }
                        if(v.VIP_Cards_Exchanged__c != null){
                            vipcardsExchanged += v.VIP_Cards_Exchanged__c.intValue();
                        }
                    }                    
                }

                p.cardsImageURL = imagePrefix + statusIcons.get('vipcard');

                p.Id = foundBookings[i].Id;
                p.Name = foundBookings[i].Name;
                p.campaignName = foundBookings[i].Name_of_Event__c;
                p.Partner = foundBookings[i].Organisation__r.Name;
                if (foundBookings[i].Valid_From__c != null)
                    p.startDate =  foundBookings[i].Valid_From__c.format();
                if (foundBookings[i].Valid_To__c != null)
                    p.endDate = foundBookings[i].Valid_To__c.format();
                if (foundBookings[i].Expected_Arrival__c != null){
                    p.arrivalTime = foundBookings[i].Expected_Arrival__c.format();     
                    p.arrivalTimeSort = foundBookings[i].Expected_Arrival__c.format('YYYY-MM-DD HH:mm');                 
                }
                if (string.isnotBlank(foundBookings[i].Organisation__r.Logo_Id__c)){
                  p.imageUrl = foundBookings[i].Organisation__r.logo_id__c;
                } else {
                  p.imageUrl = imagePrefix + defaultImageId;
                }
                

                // try to get the status, and set the status image
                if(GBAwaiting){
                    p.statusimageUrl = imagePrefix + statusIcons.get('clock');
                    p.statusText = 'Awaiting Arrival';     
                       
                }
                if(GBArrived){
                    p.statusimageUrl = imagePrefix + statusIcons.get('check');
                    p.statusText = 'Arrived at Village'; 
                    if(visitsForGB.size() == 1){
                        // means there is only 1 visit, and we can quickcheckout 
                        p.quickcheckoutvisitid = visitsForGB[0].Id;
                       //grbook.statusText == 'Arrived at Village';
                    }         
                         
                }
                if(GBLeft){
                    p.statusimageUrl = imagePrefix + statusIcons.get('logout');
                    p.statusText = 'Checked out';                          
                }
                

                totalcount ++;
                p.checkoutimageUrl = statusIcons.get('checkout');        
               
                if(totalactualguestcount != 0){
                    p.actualnumberOfVisitors = string.valueOf(totalactualguestcount);
                }
                p.pType = 'Booking';                
                p.recType = foundBookings[i].RecordType.Name;
                p.numberOfVisitors = string.valueOf(foundBookings[i].Number_of_Visitors_Expected__c);
                p.fundingProgram = string.valueOf(foundBookings[i].Organisation__r.Funding_Program_Lightning__c);                  
                returnList.add(p);
            }
            
        }
        
        //return JSON.serialize(returnList);  
        return returnList;
    }

    global class visitCounter implements Comparable{    
        integer visitCount;
        string recordId;

        global Integer compareTo(Object other) {
            Integer otherCount = other != null ? ((visitCounter)other).visitCount : 0;            
            // subtraction between this and other 
            return otherCount - this.visitCount;
        }
    }

    global class bookingSummary{
        
        global bookingSummary(){
            this.awaiting = '';
            this.arrived = '';
            this.checkedout = '';
            this.total = '';
        }

        public string awaiting {get; private set;}
        public string arrived {get; private set;}
        public string checkedout {get; set;}
        public string total {get; set;}
    }

    global class guestsSummary{
        
        global guestsSummary(){
            this.awaiting = '';
            this.arrived = '';
            this.checkedout = '';
            this.total = '';
        }

        public string awaiting {get; private set;}
        public string arrived {get; private set;}
        public string checkedout {get; set;}
        public string total {get; set;}
    }

    global class groupKey{
        
        global groupKey(){
                        
            this.Id = '';
            this.Name = '';
            this.Partner = '';
            this.startDate = '';
            this.endDate = '';
            this.arrivalTime = '';
            this.arrivalTimeSort = '';
            this.visitarrivalTime = '';
            this.visitarrivalTimeSort = '';
            this.campaignName = '';
            this.imageUrl = '';
            this.statusimageUrl = ''; 
            this.pType = '';
            this.recType = '';
            this.numberOfVisitors = '';
            this.actualnumberOfVisitors = '';
            this.statusText = '';
            this.visitId = '';
            this.checkoutimageUrl = ''; 
            this.quickcheckoutvisitid = ''; 
            this.cardsscanned = '';
            this.cardsImageURL = '';

        }
        
        public string Id {get; private set;}
        public string Name {get; private set;}
        public string campaignName {get; private set;}
        public string Partner{get; set;}
        public string startDate {get; set;}
        public string endDate {get; set;}
        public string arrivalTime {get; set;}
        public string arrivalTimeSort {get; set;}
        public string visitarrivalTime {get; set;}
        public string visitarrivalTimeSort {get; set;}
        public string imageUrl {get; set;}
        public string statusimageUrl {get; set;}
        public string statusText {get; set;}  
        public string pType {get; set;}
        public string recType {get; set;}
        public string numberOfVisitors {get; set;}
        public string actualnumberOfVisitors {get; set;}    
        public string fundingProgram{get; set;}
        public string notes {get;set;}
        public string visitId {get;set;}
        public string checkoutimageUrl {get; set;}
        public string quickcheckoutvisitid {get; set;}
        public string cardsscanned {get; set;}
        public string cardsImageURL {get; set;}
        
    }    

}