global class FutureLeadContactUpdates
{
    @future
    public static void processRecords(List<ID> recordIds)
    {            
        list<lead> theleads = [SELECT ID, Name,HasOptedOutOfEmail,ConvertedContactId FROM lead WHERE ID IN : recordIds ];
        map<id, id> contactIds = new map<id, id>();
        map<id, contact> LeadIdContactMap = new map<id, contact>();
  
        FOR (Lead cLead : theleads){
            contactIds.put(cLead.ConvertedContactId,clead.id);
        }

        list<contact> cons = [SELECT ID, Name,HasOptedOutOfEmail FROM Contact WHERE ID IN : contactIds.keyset() ];
        
        FOR (Lead cLead : theleads){
            FOR(contact con : cons){
                IF(cLead.ConvertedContactId == con.id){
                    LeadIdContactMap.put(cLead.id, con);
                }
            }
        }

        list<contact> constoUpdate = new list<contact>();

        FOR(lead cLead : theleads ){

            IF(cLead.HasOptedOutOfEmail){
                LeadIdContactMap.get(cLead.id).HasOptedOutOfEmail = False;
                constoUpdate.add(LeadIdContactMap.get(cLead.id));
            }
            else {
                LeadIdContactMap.get(cLead.id).HasOptedOutOfEmail = True;
                constoUpdate.add(LeadIdContactMap.get(cLead.id));
            }
        }

        update constoUpdate;

    }
    
    
}