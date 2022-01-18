global class DailySalesGraceScheduler implements Schedulable {
   
    global void execute(SchedulableContext SC) {
        database.executebatch(new DailySalesGraceProcessor(), 100);
    }
}