global class VIPCardSchedule implements Schedulable{

    global void execute(SchedulableContext SC) {
        List<VIP_Card_Exchange__c> vipCardList = new List<VIP_Card_Exchange__c>();
        List<Id> vipCardIdList = new List<Id>();
		Date dateForCards;
        
        if(Test.isRunningTest()){
            dateForCards = Date.today().addDays(1);
        }else{
            dateForCards = Date.today().addDays(1);
        }
        
        Date oldDateForCards = dateForCards.addMonths(-4);

        vipCardList = [SELECT Id, VIP_Card_Code__c FROM VIP_Card_Exchange__c 
                        WHERE CreatedDate < :dateForCards AND CreatedDate > :oldDateForCards];
        
        if(!vipCardList.isEmpty()){
            for(VIP_Card_Exchange__c card : vipCardList){
                vipCardIdList.add(card.Id);
            }
        }

        //Create and execute batch
        if(!vipCardList.isEmpty()){
            VIPCardBatch batch = new VIPCardBatch();
            batch.cardIdList = vipCardIdList;
            batch.query = 'SELECT Id, VIP_Card_Code__c \n' + 
            'FROM VIP_Card_Exchange__c \n' + 
            'WHERE Id IN :cardIdList';
            database.executebatch(batch, 200);
        }
    }
}