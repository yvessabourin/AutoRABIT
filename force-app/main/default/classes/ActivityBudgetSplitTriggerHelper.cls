Public Class ActivityBudgetSplitTriggerHelper{


    Public Static void SetDefaultCurrency(list<Activity_Budget_Split__c> ABSplits){
    
        map<id, string> currencymap = new map<id, string>();
        list<id> IDList = new list<id>();
        
        for(Activity_Budget_Split__c abs : ABSplits){
            IDList.add(abs.Marketing_Activity__c);         
        }
        
        list<Marketing_Activity__c> MAList = [SELECT id, CurrencyIsoCode FROM Marketing_Activity__c where id IN:IDList];
        
        for(Marketing_Activity__c MA : MAList ){
            currencymap.put(MA.id, MA.CurrencyIsoCode); 
        }
        
        for(Activity_Budget_Split__c abs : ABSplits){
            abs.CurrencyIsoCode = currencymap.get(abs.Marketing_Activity__c);
            system.debug('abs from trigger : ' +  abs);
        }
    
    }
    
    Public Static void handleBeforeInsert(list<Activity_Budget_Split__c> newABSplits){
        set<id> MAids=new set<id>();
        for(Activity_Budget_Split__c ABS : newABSplits){
            if(ABS.Marketing_Activity__c!=null){
                MAids.add(ABS.Marketing_Activity__c);
            }
        }
        List<Activity_Budget_Split__c> absList = [SELECT id,Marketing_Activity__c, Year__c FROM Activity_Budget_Split__c WHERE Marketing_Activity__c=:MAids];
        
        for(Activity_Budget_Split__c abs : newABSplits){
            if(absList!=null && absList.size()>0){
                for(Activity_Budget_Split__c actBudgetSplit: absList){
                    if(abs.Marketing_Activity__c==actBudgetSplit.Marketing_Activity__c && abs.Year__c==actBudgetSplit.Year__c){
                        abs.addError('An Activity Budget Split for this Marketing Activity and Year already exists!');
                    }
                } 
            }
        }
    }
    

}