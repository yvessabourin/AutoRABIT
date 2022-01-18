/*
##Name: Lead2GroupBookingClass
##Created by: Ian Womack
##Date: 14/01/2014
##Purpose: Upon Lead conversion, of a MICE lead, create a Group_Booking_Information__c record
##Used by: LeadTrigger --> Sends in converted leads that require Group_Booking_Information__c records to be created
## The list that comes in has already been filtered by the trigger class which removes all non MICE leads.
*/


public with sharing class Lead2GroupBookingClass{

    Public static void CreateGroupBookings(list<lead> LeadstoAdd)
    {
    //Receives the Leads to convert to GBIs
    system.debug('###Leads passed through###' + LeadstoAdd );
    
    Id GBRecordTypeId = Schema.SObjectType.Group_Booking__c.getRecordTypeInfosByName().get('Group Booking').getRecordTypeId();
    list<Village__c> Villagelist = [SELECT id, Name FROM Village__c];
    
    Map<string,id> VillageMap = new Map<string,id>();
    
    for(Village__c v : Villagelist){
        VillageMap.put(v.name, v.id);
    }
    
    system.debug('###record type id###' + GBRecordTypeId );
    
    Set<Id> contactIdSet = new Set<Id>();
    //List to hold all the records to insert
    list<Group_Booking__c> GBIsToInsert = new list<Group_Booking__c>();

    //For each Lead that comes in, create a Group_Booking_Information__c record by mapping the data that was captured on the lead.
        FOR (Lead cLead : LeadstoAdd)
        {
            
            Group_Booking__c  cGBI = new Group_Booking__c();
            
            cGBI.recordtypeid = GBRecordTypeId ;
            
            cGBI.Name_of_Event__c = cLead.Name_of_Event__c;
            cGBI.Organisation__c = cLead.ConvertedAccountId;
            cGBI.Contact__c = cLead.ConvertedContactId;
            contactIdSet.add(cLead.ConvertedContactId);
            //cGBI.Village_of_Visit__c = cLead.Village_of_Visit_c__c;
            cGBI.Village__c = VillageMap.get(cLead.Village_of_Visit_c__c);
            
            cGBI.Group_Type__c = cLead.Group_Type__c;
            
           
            cGBI.Expected_Arrival__c = cLead.Expected_Arrival__c;
            cGBI.Expected_Departure__c = cLead.Expected_Departure__c;
           
            cGBI.Number_of_Visitors_Expected__c  = cLead.Number_of_Visitors__c;
            cGBI.Visitors_Country_of_Origin__c = cLead.Visitors_Country_of_Origin__c;
            cGBI.Region__c = cLead.Region__c;
            //cGBI.Group_Source_lookup__c = cLead.Group_Source_lookup__c;
            cGBI.Transport_Required__c = cLead.Transport_Required__c;
            cGBI.Mode_of_Transport__c = cLead.Mode_of_Transport__c;
            cGBI.Food_Beverage__c = cLead.Food_Beverage__c;
            cGBI.Gift_Card__c = cLead.Gift_Card__c;
            cGBI.Gift__c = cLead.Gift__c;
            cGBI.Welcome_Pack__c = cLead.Welcome_Pack__c;
            cGBI.VIP_Lounge_Access__c = cLead.VIP_Lounge_Access__c;
            cGBI.Boutique_Private_Viewing__c = cLead.Boutique_Private_Viewing__c;
            cGBI.Notes_and_Additional_Comments__c  = cLead.Notes_and_Additional_Comments__c ;
            //cGBI.Coach_Tour_Company_Name__c  = cLead.Coach_Tour_Company_Name__c ;
            //cGBI.Inbound_Coach_Operator__c  = cLead.Inbound_Coach_Operator__c ;
            //cGBI.Coach_Country_of_Origin__c  = cLead.Coach_Country_of_Origin__c ;
            //cGBI.Passengers_Expected__c  = cLead.Passengers_Expected__c ;
            //cGBI.Tour_Leader_or_Driver_Name__c  = cLead.Tour_Leader_or_Driver_Name__c ;
            //cGBI.Coach_Tour_Contact_Email__c  = cLead.Coach_Tour_Contact_Email__c ;
            //cGBI.Coach_Tour_Phone__c  = cLead.Coach_Tour_Phone__c ;
            //Now a calculated field
            //cGBI.Estimated_Spend__c  = cLead.Estimated_Spend__c ;
            cGBI.Group_Booking_Source__c  = cLead.LeadSource ;
           
            
            cGBI.Secondary_MICE_Org_or_Agency_name__c = cLead.Secondary_MICE_Org_or_Agency_name__c;
            cGBI.Secondary_MICE_Contact_Country__c = cLead.Secondary_MICE_Contact_Country__c;
            cGBI.Secondary_MICE_Contact_Title__c = cLead.Secondary_MICE_Contact_Title__c;
            cGBI.Secondary_MICE_Contact_First_Name__c = cLead.Secondary_MICE_Contact_First_Name__c;
            cGBI.Secondary_MICE_Contact_Last_Name__c = cLead.Secondary_MICE_Contact_Last_Name__c;
            cGBI.Secondary_MICE_Contact_Position__c = cLead.Secondary_MICE_Contact_Position__c;
            cGBI.Secondary_MICE_Contact_Address_1__c = cLead.Secondary_MICE_Contact_Address_1__c;
            cGBI.Secondary_MICE_Contact_Address_2__c = cLead.Secondary_MICE_Contact_Address_2__c;
            cGBI.Secondary_MICE_Contact_Address_3__c = cLead.Secondary_MICE_Contact_Address_3__c;
            cGBI.Secondary_MICE_Contact_Town_City__c = cLead.Secondary_MICE_Contact_Town_City__c;
            cGBI.Secondary_MICE_Contact_State__c = cLead.Secondary_MICE_Contact_State__c;
            cGBI.Secondary_MICE_Contact_ZIP_Postcode__c = cLead.Secondary_MICE_Contact_ZIP_Postcode__c;
            cGBI.Secondary_MICE_Contact_Phone__c = cLead.Secondary_MICE_Contact_Phone__c;
            cGBI.Secondary_MICE_Contact_Email__c = cLead.Secondary_MICE_Contact_Email__c;
            cGBI.Originating_Lead__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+cLead.id;
            cGBI.Status__c = 'Proposed';
            
           
            
                        //Add this GBI to the list to be added
             GBIsToInsert.add(cGBI);
        }
        
        //Add them all
        insert GBIsToInsert;
        
        if(!contactIdSet.isEmpty()){
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Booking_Partnership__c FROM Contact WHERE Id IN :contactIdSet]);
            for(Group_Booking__c gb : GBIsToInsert){
                contactMap.get(gb.Contact__c).Booking_Partnership__c = gb.Id;
            }
            update contactMap.values();
        }

        //Mapping Optin/Out from Lead to Contact
        list<id> leadIds = new list<id>();
            FOR (Lead cLead : LeadstoAdd){
                leadIds.add(clead.id);
            }
        FutureLeadContactUpdates.processRecords(leadIds);
    }


    

}