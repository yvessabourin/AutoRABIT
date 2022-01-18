global class CertificationOpenDaysScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        database.executebatch(new CertificationOpenDaysProcessor(), 100);
    }
}