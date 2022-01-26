trigger VIPCardTrigger on VIP_Card_Exchange__c (before insert, after update) {
    
        ByPass_Triggers__c bpt = ByPass_Triggers__c.getInstance(UserInfo.getUserId());
        boolean thisbpt = bpt.ByPass_Triggers__c;
        
        if(!thisbpt){
            if(Trigger.isAfter && Trigger.isUpdate){
                
                set<id> ids=new set<id>();
                if(Trigger.new.size()!=0 && Trigger.new!=NULL){
                    for(VIP_Card_Exchange__c card : Trigger.new){
						if(card.Visit__c != NULL){
							ids.add(card.Visit__c);
						}                       
                    }
                    
                    if(ids.size()!=0 && ids!=null){
                        List<Visit__c> visitList = [Select Id, Total_Visit_Spend_VIP_Card__c, CurrencyISOCode FROM Visit__c WHERE Id in :ids];
                        System.Debug(' visits === ' + visitList + ' ===' + visitList.size());
                        // then also get all VIP Card Exchanges
                        List<VIP_Card_Exchange__c> cards = [Select Id, Visit__c, Total_Card_Spend__c, CurrencyISOCode FROM VIP_Card_Exchange__c WHERE Visit__c = :ids];
                        System.Debug(' cards === ' + cards + ' ===' + cards.size());
                        for(Visit__c vst :visitList){
                            Decimal vstTotalVIPSpend = 0.0;
                            for(VIP_Card_Exchange__c vip :cards){
                                if(vip.Visit__c == vst.Id){
                                    // then add the VIP Card Exchange to the list for the Sum
                                    vstTotalVIPSpend += vip.Total_Card_Spend__c;
                                    
                                    System.Debug(' vip.CurrencyISOCode MODDED === ' + vip.CurrencyISOCode);
                                }
                            }
                            
                            vst.Total_Visit_Spend_VIP_Card__c = vstTotalVIPSpend;
                            System.Debug(' vst.Total_Visit_Spend_VIP_Card__c === ' +  vst.Total_Visit_Spend_VIP_Card__c);
                        }
                        update visitList;
                    }
                    
                }
                
                
            }
            /*
Map<Id, String> visitSpendMap = new Map<Id, String>();

for(VIP_Card_Exchange__c card : Trigger.new){
if(card.Total_Card_Spend__c != Trigger.oldMap.get(card.Id).Total_Card_Spend__c){
visitSpendMap.put(card.Visit__c, String.valueOf(card.Total_Card_Spend__c));
}
}

List<Visit__c> visitList = [SELECT Id FROM Visit__c WHERE Id IN :visitSpendMap.KeySet()];

if(!visitList.isEmpty()){
for(Visit__c visit : visitList){
if(visitSpendMap.keySet().contains(visit.Id)){
visit.Total_Visit_Spend_VIP_Card__c = Decimal.valueOf(visitSpendMap.get(visit.Id));
}
}
}

UPDATE visitList;*/
        
        
        if(trigger.isInsert && trigger.isBefore)  {
            VisitRedemptionsHelper.deleteExistingCards(Trigger.new);
        }
    }
    
}