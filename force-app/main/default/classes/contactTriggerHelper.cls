Public Class contactTriggerHelper{

    Public Static void primaryContactCheck(list<contact> cons){
    
    id conId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Tourism Contact').RecordTypeId;
        
        set<id> acntIds = new set<id>();     
        for(Contact con : cons){
            if(con.Primary_Relationship_Contact__c == true && con.RecordtypeId == conId){
                acntIds.add(con.accountid);       
            }           
        }
        
        list<contact> existingPrimaryCons = [SELECT Id, Name,accountid FROM Contact WHERE Contact.accountid IN : acntIds AND Primary_Relationship_Contact__c = true AND id NOT IN : CONS AND RecordTypeId =: conId];
        map<id,contact> existingPrimaryConsMap = new map<id,contact>();
        
        for(contact con : existingPrimaryCons){
            existingPrimaryConsMap.put(con.accountid,con);
        }
        
        for(contact con : cons){
            if(existingPrimaryConsMap.get(con.accountId) != null){
                con.adderror('This Account already has a Primary Contact, please uncheck the other record before you save this one');
            }
        }
    
    }
	
    public static void updateRelatedAccount(List<Contact> contactList){
        List<Id> accIdList = new List<Id>();
        
        for(Contact cont : contactList){
            accIdList.add(cont.AccountId);
        }
        if(!accIdList.isEmpty()){
            UpdateRelatedAccountSchedulable schedulable = new UpdateRelatedAccountSchedulable(accIdList, 'Contact');
            
            Datetime dt = Datetime.now().addMinutes(1);
   			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

            System.schedule('Schedule Account Update '+System.currentTimeMillis(), timeForScheduler , schedulable);
        }
    }
    
    public static void checkDuplicate(List<Contact> contactList){
        Set<String> setEmail = new Set<String>();
        Map<String, Contact> mapEmail = new Map<String, Contact>();

        for(Contact cont : contactList){
            if(cont.email != null){
                setEmail.add(cont.Email);               
            }
        }

        List<Contact> lstContact = [Select Id,Email from Contact where email IN :setEmail and IsPersonAccount = false];

        for(Contact cont :lstContact ){
            mapEmail.put(cont.Email, cont);
        }

        for(Contact cont : contactList){
            System.debug('>>>>> cont.email'+cont.email);
            Boolean checkDuplicate = mapEmail.containsKey(cont.email);

            if(checkDuplicate){
                cont.addError('Duplicate Value on Record');
            } 
        }
    }

    public static void populateUniqueKey(List<Contact> contactList){
        ID rTypeTourism = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Tourism Contact').RecordTypeId;
        ID rTypeBrand = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Brand Contact').RecordTypeId;


        for(Contact cont : contactList){
            if((cont.RecordtypeId == rTypeTourism || cont.RecordtypeId == rTypeBrand ) && cont.email != null) {
                if(cont.RecordtypeId == rTypeTourism){
                    cont.Contact_Unique_Key__c = cont.Email  +  'Tourism Contact';
                } else if (cont.RecordtypeId == rTypeBrand){
                    cont.Contact_Unique_Key__c = cont.Email  +  'Brand Contact';
                }
            }
        } 
    }
}