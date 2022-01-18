//Daniel Childs 11/04/2017
Public Class LeadUtilities { 


    public static void setAccountReference(Lead LeadToSet){ 
    
        //set the Lead as one that has come from a Partner webform submission
        //and set the check boxes so that the code can determine if a lead used the "QAuick COnvert" function or the standard convert function
        LeadToSet.Quick_Convert__c = True;
        LeadToSet.Create_Group_Booking__c = False;
        
        //Concatentate the lead First and Last names to give a semi unique string for use later in the method
        string LeadConcatenatedName = LeadToSet.FirstName+LeadToSet.LastName;
        
        //Link the Account_Reference__c to the correct account
        id rec = [SELECT Id,Name FROM Recordtype WHERE sObjectType = 'Account' AND DeveloperName = 'Tourism'].id;
        List<Account> Acct = [Select id,Name FROM Account WHERE Account_Reference_Number__c =:LeadToSet.Account_Reference_Number__c AND RecordTypeid =:rec LIMIT 1];
        IF(!Acct.isempty()){
        LeadToSet.Account_Reference__c = Acct[0].id;
        }
            
        List <Contact> PrimaryEmailatThisAcnt = [Select ID,FirstName, LastName FROM Contact WHERE email =: LeadToSet.email AND email != NULL AND Accountid =:LeadToSet.Account_Reference__c AND isPersonAccount = False];
        List <Contact> PrimaryEmailNotatThisAcnt = [Select ID FROM Contact WHERE email =: LeadToSet.email AND email != NULL AND Accountid !=:LeadToSet.Account_Reference__c AND isPersonAccount = False LIMIT 1 ];
        
        //If lead Email exists at a Contact Email move the Lead Email to the Secondary_Email__c field 
        if(PrimaryEmailNotatThisAcnt.Size() > 0){
            LeadToSet.Secondary_Email_Address__c = LeadToSet.Email;
            LeadToSet.Email = '';
            system.debug('@@@@@ Secondary Email1 :' + LeadToSet.Secondary_Email_Address__c + ' ------- Primary Email1 :' + LeadToSet.Email );
        }
            
        //If Lead Email exists already at THIS (Acct) account check to see if the LeadConcatenatedName == contactConcatenatedName
        //If they are the same do nothing and leave the Lead Email in the Lead.Email field
        //If they DO NOT Match ie. the Email is already a Primary at this account for another contact then move it to the Secondary Email Field    
        string contactConcatenatedName = '';
        if(!PrimaryEmailatThisAcnt.isempty()){
        contactConcatenatedName = PrimaryEmailatThisAcnt[0].FirstName+PrimaryEmailatThisAcnt[0].LastName;
            if(LeadConcatenatedName != contactConcatenatedName ){
                LeadToSet.Secondary_Email_Address__c = LeadToSet.Email;
                LeadToSet.Email = '';
                system.debug('@@@@@ Secondary Email2 :' + LeadToSet.Secondary_Email_Address__c + ' ------- Primary Email2 :' + LeadToSet.Email );
            }
        }
    }
    
    
    
    public static string displayEmailError(Lead LeadToCheck){
    
        string errormessage;
        
        IF(LeadToCheck.Account_Reference_Number__c != NULL && LeadToCheck.Account_Reference__c != NULL){
        
            List<Contact> Con = [Select ID,Account.Name FROM Contact WHERE email =: LeadToCheck.email AND email != NULL AND Accountid !=:LeadToCheck.Account_Reference__c  AND isPersonAccount = False];
                IF(Con.size() >= 1){
                errormessage = 'This email address already exists at '+ con[0].Account.Name + ', please move it to the Secondary Email Address field.';
                    }else {
                    }           
            }
        return errormessage;
        }    
        
        
        
        public static string displayEmailCompanyError(Lead LeadToCheck){
    
        string errormessage;

            List<Contact> Con = [Select ID,Account.name FROM Contact WHERE email =: LeadToCheck.email AND email != NULL AND isPersonAccount = False];
                IF(Con.size() >= 1){
                errormessage = errormessage = 'This email address already exists at ' + Con[0].account.name + ', if this is not correct please move it to the Secondary Email Address field.';
                    }else {
                    }           
            
        return errormessage;
        }    
        
        
    
        public static string displayvillageError(Lead LeadToCheck){
        
        string errormessage;
            
        list<Village__c> Villagelist = [SELECT id, Name FROM Village__c];
        Map<string,id> VillageMap = new Map<string,id>();     
                 
            for(Village__c v : Villagelist){
            VillageMap.put(v.name, v.id);
            }
                
                IF(!villageMap.containsKey(LeadToCheck.Village_of_Visit_c__c)){    
                errormessage = 'The Primary Village of Visit is not a valid Village option';
                }else {
                }
        
        return errormessage;
        }
    
    
    
        public static string displayAccountRefError(Lead LeadToCheck){
            
        string errormessage;
        id rec = [SELECT Id,Name FROM Recordtype WHERE sObjectType = 'Account' AND DeveloperName = 'Tourism'].id;
            
        List<Account> ActRefNum = [Select ID FROM Account WHERE Account_Reference_Number__c =: LeadToCheck.Account_Reference_Number__c AND RecordTypeid =:rec LIMIT 1];
                    
            IF(LeadToCheck.Account_Reference_Number__c == NULL){
            //errormessage = 'There is no account with that reference number';
                return errormessage;
            }
               
            //If a user manually sets the "Account Ref Number" and "Account Ref" incorrectly will throw up the error and stop Quick Conversion           
            IF(ActRefNum.size() == 0){
                errormessage = 'There is no tourism account with that reference number';
                return errormessage;
            }  
            
            //If a user manually sets the "Account Ref Number" and "Account Ref" incorrectly will throw up the error and stop Quick Conversion  
            IF(LeadToCheck.Account_Reference_Number__c != NULL && LeadToCheck.Account_Reference__C == NULL){
                errormessage = 'The Account Reference field is empty, to enable quick convert please link this record to the correct Account';
                return errormessage;
            }                  
            
            //If a user manually sets the "Account Ref Number" and "Account Ref" incorrectly will throw up the error and stop Quick Conversion 
            IF(ActRefNum.size() > 0 && ActRefNum[0].id != LeadToCheck.Account_Reference__r.id){
                errormessage = 'The Account Reference Number on the Lead and its related Account do not match';
                return errormessage;
            }    
            return errormessage;   
        }




    public static boolean canQuickConvert(Lead LeadToConvert){
        
        boolean partsfound = False;
               
        //Check to see if the Email address already exists at another account
        List<Contact> Con = [Select ID FROM Contact WHERE email =: LeadToConvert.email AND email != NULL AND Accountid !=:LeadToConvert.Account_Reference__c AND isPersonAccount = False];
        IF(Con.size() < 1){  
        
            //make sure the Village
            list<Village__c> Villagelist = [SELECT id, Name FROM Village__c];
            Map<string,id> VillageMap = new Map<string,id>();     
            for(Village__c v : Villagelist){
            VillageMap.put(v.name, v.id);
            }
            IF(villageMap.containsKey(LeadToConvert.Village_of_Visit_c__c)){    
        
                IF(LeadToConvert.Account_Reference__c != NULL && LeadToConvert.Account_Reference_Number__c != Null && LeadToConvert.Quick_Convert__C == True && LeadToConvert.Create_group_Booking__C == False){           
                    LIST<Account> Acct = [Select id,Name,Account_Reference_Number__c FROM Account WHERE Account_Reference_Number__c =:LeadToConvert.Account_Reference_Number__c AND RecordTypeid = '012b0000000ar4wAAA' LIMIT 1];
                    LIST<Account> Acct2 = [Select id,Name,Account_Reference_Number__c FROM Account WHERE id =:LeadToConvert.Account_Reference__c AND RecordTypeid = '012b0000000ar4wAAA' LIMIT 1];   
                    
                    IF(Acct.size() > 0 && Acct2.size() > 0 ){
                    
                        IF(LeadToConvert.Account_Reference_Number__c == Acct[0].Account_Reference_Number__c && LeadToConvert.Account_Reference_Number__c == Acct2[0].Account_Reference_Number__c ){
                        
                                           
                                IF(!String.isBlank(LeadToConvert.company) && Acct != Null){
                                partsfound = True;
                                    for(String strFinal: LeadToConvert.company.split(' ')){
                                    //system.assert(False, LeadToConvert.Account_Reference__r.name);
                                        IF(!Acct[0].name.tolowercase().contains(strFinal.tolowercase()) && !Acct2[0].name.tolowercase().contains(strFinal.tolowercase())){
                                        partsfound = False;   
                                        }
                                    }   
                               } 
                        }  
                    }                      
                }
             }   
          }  
        
        //system.debug('partsfound2 :' + partsfound);
        
        return partsFound;
    }
    
    

    public static boolean quickConvert(Lead LeadToConvert){
         
            List <Contact> PrimaryEmailContact = [Select ID FROM Contact WHERE email =: LeadToConvert.email AND email != NULL AND Accountid =:LeadToConvert.Account_Reference__c AND LastName =: LeadToConvert.LastName AND FirstName =: LeadToConvert.FirstName  ];
            boolean PrimaryEmailexists = !PrimaryEmailContact.isempty();
            //system.debug('check1 is empty' + ' :'+PrimaryEmailContact);
            //system.debug('check1 is empty' + ' :' +PrimaryEmailexists);
            List <Contact> SecondaryEmailContact = [Select id FROM CONTACT WHERE Secondary_Email_Address__c =: LeadToConvert.Secondary_Email_Address__c AND Secondary_Email_Address__c != NUll AND Accountid =:LeadToConvert.Account_Reference__c AND LastName =: LeadToConvert.LastName AND FirstName =: LeadToConvert.FirstName]; 
            boolean SecondaryEmailExists = !SecondaryEmailContact.isempty();
            //system.debug('check2 is empty' + ' :'+SecondaryEmailContact);
            //system.debug('check2 is empty' +  ' :' +SecondaryEmailExists);
            List <Contact> SecondaryEmailinPrimaryEmailContact = [Select id FROM CONTACT WHERE Secondary_Email_Address__c =: LeadToConvert.email AND Secondary_Email_Address__c != NUll AND Accountid =:LeadToConvert.Account_Reference__c AND LastName =: LeadToConvert.LastName AND FirstName =: LeadToConvert.FirstName]; 
            boolean SecondaryEmailinPrimaryEmailExists = !SecondaryEmailinPrimaryEmailContact.isempty();
            system.debug('SecondaryEmailinPrimaryEmailExists' +  ' :' +SecondaryEmailinPrimaryEmailExists);
            
            id contactId;
            //system.assert(false,primaryemailcontact);
            //system.debug('Account Ref r :' + LeadToConvert.Account_Reference__r.id);
            //system.debug('Account Ref c :' + LeadToConvert.Account_Reference__c);
    
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(LeadToConvert.Id);
            lc.setaccountid(LeadToConvert.account_reference__c);
            lc.setDoNotCreateOpportunity(true);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);   
            lc.setOwnerId(LeadToConvert.account_reference__r.ownerid);
            
                if(PrimaryEmailexists == True){            
                    lc.setContactId(PrimaryEmailContact[0].id);
                    contactId = PrimaryEmailContact[0].id;
                }
                
                else if(SecondaryEmailExists == True) {
                    lc.setContactId(SecondaryEmailContact[0].id);
                    contactId = SecondaryEmailContact[0].id;
                }
                
                else if(SecondaryEmailinPrimaryEmailExists == True) {
                    lc.setContactId(SecondaryEmailinPrimaryEmailContact[0].id);
                    contactId = SecondaryEmailinPrimaryEmailContact[0].id;
                }
            
            
                else { 
                    RecordType RecordTypeid = [Select id from RecordType WHERE name = 'Tourism Contact' AND sObjectType = 'Contact'];
                    Contact con = new Contact();
                    con.FirstName = LeadToConvert.FirstName;
                    //con.ownerid = LeadToConvert.account_reference__r.ownerid;
                    con.LastName = LeadToConvert.LastName;
                    con.email = LeadToConvert.Email;
                    con.Secondary_Email_Address__c = LeadToConvert.Secondary_Email_Address__c;
                    con.phone = LeadToConvert.phone;
                    con.leadsource = LeadToConvert.leadsource;
                    con.accountid = LeadToConvert.Account_Reference__c;
                    con.recordtypeid = RecordTypeid.id;
                    //system.debug(con);
                    insert con;
                    contactId = con.id;
                    system.debug('created con'+con);
                    lc.setContactId(con.id);
                 }   
        
            //Convert lead           
            Database.LeadConvertResult lcr = Database.convertLead(lc); 
            //------------------------------
            //Receives the Leads to convert to GBIs
        //system.debug('###Leads passed through###' + LeadstoAdd );
        
        Id GBRecordTypeId = Schema.SObjectType.Group_Booking__c.getRecordTypeInfosByName().get('Group Booking').getRecordTypeId();
        list<Village__c> Villagelist = [SELECT id, Name FROM Village__c];
        
        Map<string,id> VillageMap = new Map<string,id>();
        
        for(Village__c v : Villagelist){
            VillageMap.put(v.name, v.id);
        }
        
        //system.debug('###record type id###' + GBRecordTypeId );
        
        //List to hold all the records to insert
        list<Group_Booking__c> GBIsToInsert = new list<Group_Booking__c>();
        
        //For each Lead that comes in, create a Group_Booking_Information__c record by mapping the data that was captured on the lead.
            
                
                Group_Booking__c  cGBI = new Group_Booking__c();
                
                cGBI.recordtypeid = GBRecordTypeId ;
                
                //----------------------------------------------------
                IF(LeadToConvert.Name_of_Event__c == NULL){
                    cGBI.Name_of_Event__c = LeadToConvert.Company;
                }else{
                cGBI.Name_of_Event__c = LeadToConvert.Name_of_Event__c;
                }
                
                //cGBI.Name_of_Event__c = LeadToConvert.Name_of_Event__c;
                
                cGBI.Organisation__c = LeadToConvert.Account_Reference__c;
                
                cGBI.Contact__c = contactId;     
                
                
                //cGBI.Village_of_Visit__c = LeadToConvert.Village_of_Visit_c__c;
                cGBI.Village__c = VillageMap.get(LeadToConvert.Village_of_Visit_c__c);
                
                cGBI.Group_Type__c = LeadToConvert.Group_Type__c;
                       
                cGBI.Expected_Arrival__c = LeadToConvert.Expected_Arrival__c;
                cGBI.Expected_Departure__c = LeadToConvert.Expected_Departure__c;
               
                cGBI.Number_of_Visitors_Expected__c  = LeadToConvert.Number_of_Visitors__c;
                cGBI.Visitors_Country_of_Origin__c = LeadToConvert.Visitors_Country_of_Origin__c;
                cGBI.Region__c = LeadToConvert.Region__c;
                //cGBI.Group_Source_lookup__c = LeadToConvert.Group_Source_lookup__c;
                cGBI.Transport_Required__c = LeadToConvert.Transport_Required__c;
                cGBI.Mode_of_Transport__c = LeadToConvert.Mode_of_Transport__c;
                cGBI.Food_Beverage__c = LeadToConvert.Food_Beverage__c;
                cGBI.Gift_Card__c = LeadToConvert.Gift_Card__c;
                cGBI.Gift__c = LeadToConvert.Gift__c;
                cGBI.Welcome_Pack__c = LeadToConvert.Welcome_Pack__c;
                cGBI.Originating_Lead__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+LeadToConvert.id;
                cGBI.VIP_Lounge_Access__c = LeadToConvert.VIP_Lounge_Access__c;
                cGBI.Boutique_Private_Viewing__c = LeadToConvert.Boutique_Private_Viewing__c;
                cGBI.Notes_and_Additional_Comments__c  = LeadToConvert.Notes_and_Additional_Comments__c ;
                //cGBI.Coach_Tour_Company_Name__c  = LeadToConvert.Coach_Tour_Company_Name__c ;
                //cGBI.Inbound_Coach_Operator__c  = LeadToConvert.Inbound_Coach_Operator__c ;
                //cGBI.Coach_Country_of_Origin__c  = LeadToConvert.Coach_Country_of_Origin__c ;
                //cGBI.Passengers_Expected__c  = LeadToConvert.Passengers_Expected__c ;
                //cGBI.Tour_Leader_or_Driver_Name__c  = LeadToConvert.Tour_Leader_or_Driver_Name__c ;
                //cGBI.Coach_Tour_Contact_Email__c  = LeadToConvert.Coach_Tour_Contact_Email__c ;
                //cGBI.Coach_Tour_Phone__c  = LeadToConvert.Coach_Tour_Phone__c ;
                //Now a calculated field
                //cGBI.Estimated_Spend__c  = LeadToConvert.Estimated_Spend__c ;
                cGBI.Group_Booking_Source__c  = LeadToConvert.LeadSource ;
               
                
                cGBI.Secondary_MICE_Org_or_Agency_name__c = LeadToConvert.Secondary_MICE_Org_or_Agency_name__c;

                // lets try to get the Rep from the text
                cGBI.VR_Representative__c = GetTourismRepresentitave(LeadToConvert.Secondary_MICE_Org_or_Agency_name__c);

                cGBI.Secondary_MICE_Contact_Country__c = LeadToConvert.Secondary_MICE_Contact_Country__c;
                cGBI.Secondary_MICE_Contact_Title__c = LeadToConvert.Secondary_MICE_Contact_Title__c;
                cGBI.Secondary_MICE_Contact_First_Name__c = LeadToConvert.Secondary_MICE_Contact_First_Name__c;
                cGBI.Secondary_MICE_Contact_Last_Name__c = LeadToConvert.Secondary_MICE_Contact_Last_Name__c;
                cGBI.Secondary_MICE_Contact_Position__c = LeadToConvert.Secondary_MICE_Contact_Position__c;
                cGBI.Secondary_MICE_Contact_Address_1__c = LeadToConvert.Secondary_MICE_Contact_Address_1__c;
                cGBI.Secondary_MICE_Contact_Address_2__c = LeadToConvert.Secondary_MICE_Contact_Address_2__c;
                cGBI.Secondary_MICE_Contact_Address_3__c = LeadToConvert.Secondary_MICE_Contact_Address_3__c;
                cGBI.Secondary_MICE_Contact_Town_City__c = LeadToConvert.Secondary_MICE_Contact_Town_City__c;
                cGBI.Secondary_MICE_Contact_State__c = LeadToConvert.Secondary_MICE_Contact_State__c;
                cGBI.Secondary_MICE_Contact_ZIP_Postcode__c = LeadToConvert.Secondary_MICE_Contact_ZIP_Postcode__c;
                cGBI.Secondary_MICE_Contact_Phone__c = LeadToConvert.Secondary_MICE_Contact_Phone__c;
                cGBI.Secondary_MICE_Contact_Email__c = LeadToConvert.Secondary_MICE_Contact_Email__c;
                cGBI.Was_Quick_Converted__c = True;
                cGBI.Status__c = 'Confirmed';
                
               
                
                 //Add this GBI to the list to be added
                 GBIsToInsert.add(cGBI);
            
            
                //Add them all
                insert GBIsToInsert;

                //Mapping Optin/Out from Lead to Contact
                list<id> leadIds = new list<id>();
                leadIds.add(LeadToConvert.id);
                FutureLeadContactUpdates.processRecords(leadIds);
                
                return lcr.isSuccess();  

            
    }

    public static ID GetTourismRepresentitave(String RepName)
    {
        try{
            if(String.isNotBlank(RepName)){
                // this will get all the reps, we arent expecting many, and we want to do the fuzzy text search in code, and not in SOQL
                
                // now we need to 'clean' the input name.... 
                // this is a bit specific, but its what people seem to be putting in the text.
                // first lets lower-case the whole thing...
                RepName = RepName.toLowerCase();
                // most people input Aviareps, and really we need it to say avia
                RepName = RepName.replace('aviareps', 'avia');
                // now we can try to be clever, and convert a 'SH' to 'shanghai'
                String regExp = '\\bsh\\b';
                RepName = RepName.replaceFirst(regExp, 'shanghai');
               // RepName = RepName.replace(' sh ', 'shanghai'); 
                
                System.Debug('RepName: ' + RepName);
                String[] parts = RepName.split(' ');
              
                Integer partsneeded = parts.size();
                System.Debug('partsneeded: ' + partsneeded);

                // we can do a few things here
                // firstly, we expect that the user will give us the tourism rep in 2 parts
                // the name of the tourism company (avia) and the name of the country/city (Indonesia)
                if(partsneeded > 1){
                    // if theres only 1 part, then theres no point carrying on.... theres no way to match that.
                    List<User> Reps = [SELECT Role_Name__c, ID, Name FROM User WHERE Role_Name__c = 'Tourism Consultant'];

                    ID UserID;
                    for(User usr :Reps){
                        // lets find the RepName
                         System.Debug('usr.Name: ' + usr.Name);
                         Integer partsfound = 0;
                        for(String part :parts){
                            System.Debug('part: ' + part);
                            if(usr.Name.toLowerCase().contains(part) )
                            {
                                partsfound++;
                            }
                        }
                        if(partsfound == partsneeded)
                        {
                            return usr.Id;
                        }
                    }
                }
                else{return null;}
            }
        }
        catch(Exception ex)
        {
            // if we have any issues, we just return null, and the user will have to make the link themselves
            return null;
        }
        return null;
    }
  
        
}