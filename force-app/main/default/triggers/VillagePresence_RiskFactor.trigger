trigger VillagePresence_RiskFactor on Risk_Factor__c (Before Insert, Before Update) 
{    
         for(Risk_Factor__c  risk: Trigger.New)
         {
                if(risk.Village_Presence__c != null)
                    risk.Primary_Key__c = risk.Village_Presence__c;               
         }  
}