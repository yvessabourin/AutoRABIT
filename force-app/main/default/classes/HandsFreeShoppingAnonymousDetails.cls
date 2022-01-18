global class HandsFreeShoppingAnonymousDetails implements Schedulable{
    public static List<Case> allClosedCases {get;set;}
    public List<Case> casesToUpdate;
    
    public void execute(SchedulableContext SC) {
        casesToUpdate = new List<Case>();
        allClosedCases = [SELECT id, CreatedDate, Status, SuppliedEmail, SuppliedName, SuppliedPhone FROM Case
                          WHERE Status = 'Closed'];
        
        for(Case cs:allClosedCases){
            if(date.newinstance(cs.CreatedDate.year(),cs.CreatedDate.month(),cs.CreatedDate.day()) <= system.today()-14){
                cs.SuppliedEmail = null;
                cs.SuppliedName = null;
                cs.SuppliedPhone = null;
                casesToUpdate.add(cs);
            }
        }
        update casesToUpdate;
    }
}