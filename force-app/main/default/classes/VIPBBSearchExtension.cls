Global without sharing Class VIPBBSearchExtension{
    public Visit__c visitRecordInfo ;
    public Visit__c getvisitRecordInfo()
    {
        return visitRecordInfo;
    }
    public void setVisit(Visit__c visitRecordInfo)
    {
        this.visitRecordInfo = visitRecordInfo;
    }
    public String visitId {get;set;}
    
    public VIPBBSearchExtension(Apexpages.standardController stdController){
        visitRecordInfo = new Visit__c();
    } 
    
    List<String> ServicesUsedSelection= new List<String>();
    
    public List<String> getServicesUsedSelection()
    {
        return ServicesUsedSelection;
    }
    
    public void setServicesUsedSelection(List<String> servicesSelected)
    {
        
        this.ServicesUsedSelection =  servicesSelected   ;
    }
    
    public List<SelectOPtion> getServicesUsed()
    {
        List<SelectOption> options = new List<SelectOPtion>();
        for(Schema.PickListEntry pl : Visit__c.Services_Used__c.getDescribe().getPicklistValues())
        {
            options.add(new SelectOption(pl.getLabel(),pl.getValue())) ;
        }
        return options;
    }
    
    @Remoteaction
    
    global static list<guest> retrieveGuests(string name){
        
        id guestRecId = [SELECT id from RecordType where sObjectType = 'Account' AND Name = 'VIP Guest' ].id;
        
        string param1 = '\'' + '*' + name + '*' + '\''; 
        string param2 = '\'' + name + '*' + '\'';
        string param3 = '\'' + '*' + name + '\'';
        string param4 = name;
        name = '\'' + name  + '\'';
        string searchParam = param4 + ' OR (' + param1 + ' OR ' + param2 + ' OR ' + param3 + ' OR ' + name + ')'; 
        
        system.debug(' @@@ Search for .. ' + searchParam );
        
        List<List<SObject>> searchList = [FIND :searchParam IN ALL FIELDS 
                                          RETURNING                         
                                          Account (Id, Name, Firstname,LastName, PersonEmail,Permission_to_hold_data__c where RecordTypeId = : guestRecId)];
        
        list<Account> foundVIPs = ((list<Account>) searchList[0]);
        list<guest> guests = new list<guest>();
        
        //gets event attendee records that correspond to the VIP Guests if the event occurs today
        List<Trade_Event_Attendee__c> attendeeList=[SELECT id, name, Invite_Status__c,Contact__c, Contact__r.Account.Name, Visit__c,Trade_Event__c, Trade_Event__r.Event_Date__c  from Trade_Event_Attendee__c
                                                    where Contact__r.AccountId =:foundVIPs and Trade_Event__r.Event_Date__c=TODAY and Invite_Status__c<>'Attended'];
        
        Id vipVisitRecordTypeId = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('VIP Visit').RecordTypeId;
        Id personalShoppingVisitRecTypeId = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('Personal Shopping Visit').RecordTypeId;
        List<Visit__c> vstList=[SELECT id, name,Account__c,RecordTypeId,Visit_Date_Time__c,Arrival_Date__c from Visit__c
                                WHERE Account__c=:foundVIPs AND RecordTypeId=:vipVisitRecordTypeId
                                AND Arrival_Date__c=TODAY];
        Set<Id> recordTypeIds = new Set<Id>{vipVisitRecordTypeId,personalShoppingVisitRecTypeId};
            
            //Gets Visit record if the visit has check in today
            List<Visit__c> vst1List=[SELECT id, name,Account__c,RecordTypeId,Visit_Date_Time__c from Visit__c
                                     WHERE Account__c=:foundVIPs AND RecordTypeId IN:recordtypeIds
                                     AND Visit_Date_Time__c=TODAY];
        
        List<Visit__c> vst2List=[SELECT id, name,Account__c,RecordTypeId,Visit_Date_Time__c from Visit__c
                                 WHERE Account__c=:foundVIPs AND RecordTypeId IN:recordtypeIds
                                 AND Visit_Date_Time__c=TODAY];
        
        
        
        //
        
        for(Account act : foundVIPs){
            boolean guestHasEvent=false;
            boolean guestHasCheckinVisit=false;
            boolean updateVisitRecord=false;
            boolean getvisit=false;
            //if at least one guest has an event to attend today, then for each guest it loops through event attendee records to match it to the guest, if there's a match then guest has an event
            if(attendeeList.size()!=0 && attendeeList!=NULL){
                for(Trade_Event_Attendee__c tea : attendeeList){
                    if(act.id==tea.Contact__r.AccountId){
                        guestHasEvent=true;
                    }
                }
            }
            //if at least one guest visit has an Arrival Date matching today, it means the visit is already created
            //and guest should be checkedin instead of creating a visit
            if(vstList.size()!=0 && vstList!=NULL){
                for(Visit__c vst : vstList){
                    if(act.id==vst.Account__c){
                        guestHasCheckinVisit=true;
                    }
                }
            }
            //If Guest has checkin Visit
            if(vst1List.size()!=0 && vst1List!=NULL){
                for(Visit__c vst : vst1List){
                    if(act.id==vst.Account__c){
                        updateVisitRecord=true;
                    }
                }
            }
            
            if(vst2List.size()!=0 && vst2List!=NULL){
                for(Visit__c vst : vst2List){
                    if(act.id==vst.Account__c){
                        getvisit=true;
                    }
                }
            }
            //
            
            guest g = new guest();
            g.Id = act.Id;
            g.Name = act.Name;
            g.Email = act.PersonEmail;
            g.Firstname = act.FirstName;
            g.Lastname = act.LastName;
            g.Permissiontoholddata = (act.Permission_to_hold_data__c == true ? 'true' : 'false');
            g.HasEvent=guestHasEvent;
            g.HasCheckinVisit=guestHasCheckinVisit;
            g.updateVisitrecord=updateVisitRecord;
            g.getvisit=getvisit;
            guests.add(g);
        }
        
        return guests;
        
    }
    
    @Remoteaction
    global static Id createVisit(Id accountId){
        Id visitVIPRecordTypeId = Schema.SObjectType.Visit__c.getRecordTypeInfosByName().get('VIP Visit').getRecordTypeId();
        
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, Village__c, Profile.Name, Alias FROM User WHERE Id = :currentUserId];
        Id villageId;
        if(currentUser.Profile.Name == 'Personal Shopper for Clientelling App') {
            visitVIPRecordTypeId = Schema.SObjectType.Visit__c.getRecordTypeInfosByName().get('Personal Shopping Visit').getRecordTypeId();
        }
        
        if(currentUser.Village__c != null){
            villageId = [SELECT Id FROM Village__c WHERE Name = :currentUser.Village__c LIMIT 1].Id;
        }else{
            return null;
        }
        // Count should be calculta e
        //List<Visit__c> vlstExist = [SELECT id from Visit__c where createddate = today];
        Visit__c newVisit = new Visit__c(RecordTypeId = visitVIPRecordTypeId,
                                         Village__c = villageId,
                                         Visit_Date_Time__c = DateTime.now(),
                                         Type__c = 'VIP Shopping Day');
        
        if(accountId!=null){
            newVisit.Account__c = accountId;
        }
        else{
            newVisit.Anonymous_Guest__c=true;
        }
        
        try{
            DataBase.insert(newVisit);
            SYSTEM.DEBUG('VISIT ID: '+newVisit.id);
        }catch(DMLException ex){
            return null;
        }
        return newVisit.Id;
        
    } 
    
    @Remoteaction
    global static Id updateVisit(Id accountId){
        Id visitVIPRecordTypeId = Schema.SObjectType.Visit__c.getRecordTypeInfosByName().get('VIP Visit').getRecordTypeId();
        
        //If, by mistake, there are 2 visits that meet the criteria, then it will always take the latest created visit
        Visit__c checkinVisit = [SELECT id, name, RecordtypeId, Arrival_Date__c,Visit_Date_Time__c FROM Visit__c
                                 WHERE Account__c=:accountId AND RecordTypeId=:visitVIPRecordTypeId
                                 AND Arrival_Date__c=TODAY ORDER BY CreatedDate DESC LIMIT 1];
        
        checkinVisit.Visit_Date_Time__c = DateTime.now();
        
        try{
            Database.update(checkinVisit);
        }
        catch(DMLException ex){
            system.debug('UPDATE ERROR');
        }
        return checkinVisit.id;
        
    }
    
    @Remoteaction
    //updates event attendee invitation status to attended on all today's events where the guest is invited for, and associates today's visit with event attendee record
    global static Id UpdateAttendeeStatus(Id accountId){
        
        id VisitID=createVisit(accountID);
        List<Trade_Event_Attendee__c> attendeeList=[SELECT id, name, Invite_Status__c,Contact__c, Contact__r.Account.Name, Visit__c,Trade_Event__c, Trade_Event__r.Event_Date__c  from Trade_Event_Attendee__c
                                                    where Contact__r.AccountId =:accountId and Trade_Event__r.Event_Date__c=TODAY and Invite_Status__c<>'Attended'];
        
        if(attendeeList.size()!=0 && attendeeList!=NULL){
            for(Trade_Event_Attendee__c att : attendeeList){
                att.Invite_Status__c='Attended';
                att.Visit__c=VisitID;
            }
            try{
                Database.update(attendeeList);
            }
            catch(DMLException ex){
                system.debug('UPDATE ERROR');
            }
        }
        return VisitID;
    }
    
    @Remoteaction
    global static id updateVisitRecord(Id accountId){
        system.debug('accountId-->'+accountId);
        Visit__c v = [SELECT Id,Visit_Date_Time__c from Visit__c where Account__c =: accountId and Visit_Date_Time__c >:system.today().adddays(-1) order by Visit_Date_Time__c desc limit 1];
        system.debug('accountId--> Visit'+V);
        Date currdate=Date.today();
        if(currdate.isSameday(v.Visit_Date_Time__c.DateGMT())){
            return v.id;   
        }
        else{
            return null;
        }
    }
    
    Global class guest{
        public string Id {get; private set;}
        public string Name {get; private set;} 
        public string Firstname {get; private set;} 
        public string LastName {get; private set;} 
        public string Email {get; private set;} 
        public string Permissiontoholddata {get; private set;}
        public boolean HasEvent {get; private set;}
        public boolean HasCheckinVisit {get; set;}
        public boolean updateVisitRecord {get; set;}
        public boolean getvisit {get; set;}
        
        
        public guest(){
            this.Id = '';
            this.Name = ''; 
            this.Firstname = ''; 
            this.LastName = ''; 
            this.Email = '';
            this.Permissiontoholddata = '';
            this.HasEvent=false;
            this.HasCheckinVisit=false;
            this.updateVisitRecord=false;
            this.getvisit=false;
            
        }
    }  
    
    global void getVisitInfo(){
        System.debug('>>> visitId'+visitId);
        
        List<Visit__c>  visits = [Select id, Name, Services_Used__c,Number_of_Guests__c,Number_of_Children__c,	Virtual_Visit__c,Walk_in_Booked__c,Visit_Source__c,Visit_Notes__c,
                                  Partnership__c,Visit_Source_Notes__c,Domestic_or_International_Partner__c,Brand_Event__c,	Personal_Shopper__c,Brand_Referral__c,Private_Client_Team__c,Marketing_Activity__c,Village_Specific__c From Visit__c
                                  where Id = :visitId];
        visitRecordInfo = visits.isEmpty() ? new Visit__c():visits[0];
        System.debug('>>> visitId'+ visitRecordInfo);
    }
    global PageReference saveVisitInfo()
    {
        visitRecordInfo.Services_Used__c = ServicesUsedSelection.isEmpty() ? '':String.join(ServicesUsedSelection,';');
        SYstem.debug('VIDSIT**************'+JSON.serialize(visitRecordInfo));
        update visitRecordInfo;
        return null;
    }
}