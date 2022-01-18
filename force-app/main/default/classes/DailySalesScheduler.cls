global class DailySalesScheduler implements Schedulable {
   
    global void execute(SchedulableContext SC) {
        database.executebatch(new DailySalesBatchProcessor(), 30);
    }
}