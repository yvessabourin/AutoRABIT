Public Class LeadTriggerHandler{

    public static boolean isAfterInsert = false;

    public static void handlBeforeInsert(List<Lead> Leads){
     system.debug('before insert1');
            For (Lead cLead : Leads){ 
                IF(cLead.Account_Reference_Number__c != NULL){
                   LeadUtilities.setAccountReference(cLead);
                   system.debug('before insert2');

                }
            }
        }


    public static void handleafterInsert(List<Lead> Leads){

        list<logFile__c> logs = new list<logFile__c>();
        List<ID> lstLeadUpdate = new List<ID>();

        For (Lead cLead : Leads){ 
            try{
                //Checks if we can quickConvert the lead - Account & Contact info exists we can auto convert
                IF(LeadUtilities.canQuickConvert(cLead)){
                    system.debug('###Leads passed through### IN' + cLead );
                    //If True perform quickConvert
                    LeadUtilities.quickConvert(cLead);
                } else {
                    lstLeadUpdate.add(cLead.Id);
                }
            }
            catch (exception e){
                 
                    string leadConversionResults = '@@@@@@ lead Conversion failed ' + e + ' ------ ';
                    leadConversionResults += 'LeadData: ' + cLead;
                    logFile__c log = new logFile__c();
                    log.Body__c = leadConversionResults;
                    log.Type__c = 'Lead Conversion Error';
                    logs.add(log);
            }
        }
        
        if(lstLeadUpdate.Size() > 0){
            isAfterInsert = true;
            updateLead(lstLeadUpdate);
        }

        if(!logs.isempty()){
            insert logs;
        }
    }
    
   public static void updateLead(List<ID> Leads){
        List<Lead> lstLead = [Select Id from Lead Where Id IN :Leads];
        List<Lead> lstLeadUpdate = new List<Lead>();

        for(Lead leadUp : lstLead){
            leadUp.Quick_Convert__c = false;
            lstLeadUpdate.add(leadUp);
        }

        Update lstLeadUpdate;
    }

    public static void handleBeforeUpdate(List<Lead> Leads){
        For(Lead cLead :Leads){
            IF(cLead.Account_Reference_Number__c != NULL && cLead.Quick_Convert__c == True && cLead.Create_Group_Booking__c == False){
                LeadUtilities.setAccountReference(cLead); 
                }       
        }
    }        
    
    /*
    ##Name: LeadTrigger 
    ##Created by: Ian Womack
    ##Date: 14/01/2014
    ##Purpose: Upon Lead conversion, of a MICE lead, create a Group_Booking_Information__c record.
    */
    public static void handlAfterUpdate(Map<id,Lead> oldLeadMap, Map<id,lead> newLeadMap){
    
        //Stores a list of Lead records that will be sent over to the helper class
        List<Lead> leadsToCreateBookingInformationRecs = new List<Lead>();
        //record type of leads we are interested in
        Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Group Booking Lead').getRecordTypeId();
    
        //Loop through the leads and only filter out the leads that do not match the criteria
    
        For (Lead cLead : newLeadMap.values())
        {
            system.debug('Lead ID: '  +cLead.id);
            system.debug('nowConverted?: '  +cLead.isConverted);
            system.debug('was Converted?: ' + oldLeadMap.get(cLead.id).isConverted);
            system.debug('Recordtypeid: '   +cLead.recordtypeid );
            system.debug('Should GBI be created?: '   +cLead.Create_Group_Booking__c );
            
            //Criteria: Record Type = MICE && isConverted = true 
            IF (cLead.isConverted == true && oldLeadMap.get(cLead.id).isConverted == false && cLead.recordtypeid == RecordTypeId && cLead.Quick_Convert__c == false )
            {
            //add the lead to the list to send through for GBI creation
                leadsToCreateBookingInformationRecs.add(cLead);  
                system.debug('Lead added: ' + cLead);
            }
            else
            {
                system.debug('No leads converted');
            }
                 
        } //end for loop
        
        
        //display the list of leads for which will be sent for GBI creation
        system.debug('Leads converted: ' + leadsToCreateBookingInformationRecs );
      
        Lead2GroupBookingClass.CreateGroupBookings(leadsToCreateBookingInformationRecs);
      }
      

}