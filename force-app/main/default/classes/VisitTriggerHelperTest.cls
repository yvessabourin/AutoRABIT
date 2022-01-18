@isTest
private class VisitTriggerHelperTest{

    @TestSetup
    public static void SetupData(){
        Account account = new Account();
        account = TestData_Account.setupBrandAccount(1, true);
        
        Village__c newVillage = new Village__c(Currency__c = 'EUR',
                                                Village_Code__c = 'TT',
                                                CertSales_Report_Sales_Grace_Period_Days__c = 2,
                                                CertSales_CertPeriod_Open_Days__c = 2);
        INSERT newVillage;
		List<Room__c> room_lst = new List<Room__c>();
        For(integer i=0; i<10; i++) {
            Room__c r = new Room__c();
            r.Capacity__c = 10;
            r.Room_is_Active__c = true;
            r.Unit_of_Measurement__c ='SQM';
            r.Name ='Test'+i;
            r.Room_Name__c ='Test'+i;
            r.Village__c = newVillage.id;
            room_lst.add(r);
        }
        
        insert room_lst;
        list<Visit__c> visitList = new List<Visit__c>();
        Id vipVisitRecordTypeId = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('VIP Visit').RecordTypeId;
        Id personalShoppingRecordType = Schema.SObjectType.Visit__c.RecordTypeInfosByName.get('Personal Shopping Visit').RecordTypeId;
        Visit__c newVisit1 = new Visit__c(Village__c = newVillage.Id, No_Show__c =true, room__c = room_lst[0].id, RecordTypeId = personalShoppingRecordType, Account__c = account.Id);
        visitList.add(newVisit1);
        Visit__c newVisit = new Visit__c(Village__c = newVillage.Id, RecordTypeId = vipVisitRecordTypeId, Account__c = account.Id);
        visitList.add(newVisit);
        INSERT visitList;
        List<VIP_Card_Exchange__c> vipcardex_lst = new List<VIP_Card_Exchange__c>();
        for(integer i=0; i<5; i++) {
            VIP_Card_Exchange__c v = new VIP_Card_Exchange__c();
            v.Guest__c =account.id;
            v.VIP_Card_Code__c = 'test'+i;
            v.Visit__c =visitList[0].id;
            vipcardex_lst.add(v);
        }
        
    }

    @isTest
    static void assignVisitCurrencyTest(){
        Visit__c visit = [SELECT Id, Village__c FROM Visit__c LIMIT 1];

        Test.startTest();
            VisitTriggerHelper.assignVisitCurrency(new List<Visit__c>{visit});
        Test.stopTest();
    } 
     @isTest
    static void assignvillageRooms(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
        }
        Test.startTest();
            VisitTriggerHelper.setNoShow(setid);
        Test.stopTest();
    }
    @isTest
    static void insertupdateactivity(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
            mapidvisti.put(v.id, v);
            v.Email_Notification_Errors__c ='';
            //v.Number_of_Guests__c =10;
            visit1.add(v);
        }
        Test.startTest();
        VisitTriggerHelper.processVisitAfter(null, mapidvisti);
        update visit1;
        
         for(Visit__c v: visit1) {
            //setid.add(v.id);
            mapidvisti1.put(v.id, v);
            //v.Email_Notification_Errors__c ='';
            //visit1.add(v);
        }
        
            VisitTriggerHelper.processVisitAfter(mapidvisti1, mapidvisti);
        Test.stopTest();
    }
    @isTest
    static void insertupdateactivity_v2(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
            mapidvisti.put(v.id, v);
            v.Email_Notification_Errors__c ='';
            //v.Number_of_Guests__c =10;
            visit1.add(v);
        }
        Test.startTest();
         update visit1;
        VisitTriggerHelper.processVisitAfter(null, mapidvisti);
       
        
         for(Visit__c v: visit1) {
            //setid.add(v.id);
            mapidvisti1.put(v.id, v);
            //v.Email_Notification_Errors__c ='';
            //visit1.add(v);
        }
         //VisitTriggerHelper.processVisitAfter(mapidvisti1, mapidvisti);
            VisitTriggerHelper.processVisitAfter(mapidvisti1, null);
        Test.stopTest();
    }
    @isTest
    static void insertupdateactivity_v3(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
           
            v.Email_Notification_Errors__c ='';
            v.Number_of_Guests__c =10;
            v.Visit_Date_Time__c = system.today();
            visit1.add(v);
             mapidvisti.put(v.id, v);
        }
        Test.startTest();
         //update visit1;
        VisitTriggerHelper.processVisitAfter(null, mapidvisti);        
        Test.stopTest();
    }
     @isTest
    static void insertupdateactivity_v4(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
           
            v.Email_Notification_Errors__c ='';
            v.Number_of_Guests__c =10;
            v.Visit_Date_Time__c = system.today();
            visit1.add(v);
             mapidvisti.put(v.id, v);
        }
        Test.startTest();
        visit1[0].Number_of_Guests__c = 20;
         update visit1;
        for(Visit__c v: visit1) {
             mapidvisti1.put(v.id, v);
        }
        VisitTriggerHelper.processVisitAfter(mapidvisti1, mapidvisti);        
        Test.stopTest();
    }
    @isTest
    static void insertupdateactivity_v5(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        Id groupbookingrectypeID = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByName.get('Group Booking').RecordTypeId;
        
        Group_Booking__c g = new Group_Booking__c();
        g.recordtypeID = groupbookingrectypeID;
        insert g;
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
           
            v.Email_Notification_Errors__c ='';
            v.Number_of_Guests__c =10;
            v.Visit_Date_Time__c = system.today();
            visit1.add(v);
             mapidvisti.put(v.id, v);
        }
        Test.startTest();
        visit1[0].Number_of_Guests__c = 20;
        visit1[0].Group_Booking__c = g.id;
        visit1[0].No_Show__c = false;
        visit1[0].Check_in_Email_Sent__c = false;
        visit1[0].Check_Out_Date_Time__c = null;
         update visit1;
        for(Visit__c v: visit1) {
             mapidvisti1.put(v.id, v);
        }
        VisitTriggerHelper.processVisitAfter(mapidvisti1, mapidvisti);        
        Test.stopTest();
    }
    @isTest
    static void insertupdateactivity_v6(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        id accId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
		Account act = new account(Name = 'test Acc 231', Recordtypeid = accId);
		insert act;

		Contact con1 = new contact(AccountId = act.id, FirstName = 'Test12', LastName = 'Test13', email = 'test12@test.com',Primary_Relationship_Contact__c = true);
		Contact con2 = new contact(AccountId = act.id, FirstName = 'Test23', LastName = 'Test23', email = 'test23@test.com',Secondary_Email_Address__c = 'test23@test.com');

		list<Contact> obs = new list<Contact>();
		obs.add(con1);
		obs.add(con2);
		insert obs;
		
        Id groupbookingrectypeID = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByName.get('Group Booking').RecordTypeId;
        
        Group_Booking__c g = new Group_Booking__c();
        g.recordtypeID = groupbookingrectypeID;
        g.contact__c = obs[1].id;
        insert g;
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
           
            v.Email_Notification_Errors__c ='';
            v.Number_of_Guests__c =10;
            v.Visit_Date_Time__c = system.today();
            visit1.add(v);
             mapidvisti.put(v.id, v);
        }
        Test.startTest();
        visit1[0].Number_of_Guests__c = 20;
        visit1[0].Group_Booking__c = g.id;
        visit1[0].No_Show__c = false;
        visit1[0].Check_in_Email_Sent__c = false;
        visit1[0].Check_Out_Date_Time__c = null;
         update visit1;
        for(Visit__c v: visit1) {
             mapidvisti1.put(v.id, v);
        }
        VisitTriggerHelper.processVisitAfter(mapidvisti1, mapidvisti);        
        Test.stopTest();
    }
    @isTest
    static void insertupdateactivity_v7(){
        list<Visit__c> visit = [SELECT Id, Village__c FROM Visit__c];
        list<Visit__c> visit1 = new list<visit__c>();
		Room__c  r = [SELECT id from Room__c where name ='Test1' limit 1];
        id accId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
		Account act = new account(Name = 'test Acc 231', Recordtypeid = accId);
		insert act;

		Contact con1 = new contact(AccountId = act.id, FirstName = 'Test12', LastName = 'Test13', email = 'test12@test.com',Primary_Relationship_Contact__c = true);
		Contact con2 = new contact(AccountId = act.id, FirstName = 'Test23', LastName = 'Test23', email = 'test23@test.com',Secondary_Email_Address__c = 'test23@test.com');

		list<Contact> obs = new list<Contact>();
		obs.add(con1);
		obs.add(con2);
		insert obs;
		
        Id groupbookingrectypeID = Schema.SObjectType.Group_Booking__c.RecordTypeInfosByName.get('Group Booking').RecordTypeId;
        
        Group_Booking__c g = new Group_Booking__c();
        g.recordtypeID = groupbookingrectypeID;
        g.contact__c = obs[1].id;
        insert g;
        map<id, Visit__c> mapidvisti = new map<id, visit__c>();
         map<id, Visit__c> mapidvisti1 = new map<id, visit__c>();
        set<id> setid = new set<id>();
        for(Visit__c v: visit) {
            setid.add(v.id);
           
            v.Email_Notification_Errors__c ='';
            v.Number_of_Guests__c =10;
            v.Visit_Date_Time__c = system.today();
            v.Check_Out_Date_Time__c = system.today().addDays(1);
            v.Check_out_Email_Sent__c = false;
            visit1.add(v);
             mapidvisti.put(v.id, v);
        }
        Test.startTest();
        visit1[0].Number_of_Guests__c = 20;
        visit1[0].Group_Booking__c = g.id;
        visit1[0].No_Show__c = false;
        visit1[0].Check_in_Email_Sent__c = false;
        visit1[0].Check_Out_Date_Time__c = system.today().addDays(1);
         update visit1;
        for(Visit__c v: visit1) {
             mapidvisti1.put(v.id, v);
        }
        VisitTriggerHelper.processVisitAfter(mapidvisti1, mapidvisti);        
        Test.stopTest();
    }
}