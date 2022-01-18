Public Class MarketingActivityUtilities{


    Public static void setCurrencyOnActivityBudgetSplits(list<Marketing_Activity__c> mas){
    
    try{  
    
    map<id, list<Activity_Budget_Split__c>> MABSmap = new map<id, list<Activity_Budget_Split__c>>();
        
    list<Activity_Budget_Split__c> ABSs = [Select id,X01_January__c,X02_Febraury__c,X03_March__c,
    X04_April__c,X05_May__c,X06_June__c,X07_July__c,X08_August__c,X09_September__c,X10_October__c,
    X11_November__c,X12_December__c, name,CurrencyIsoCode,Marketing_Activity__c from Activity_Budget_Split__c WHERE Marketing_Activity__c IN:mas];  

        for(Activity_Budget_Split__c abs : ABSs){
            if(MABSmap.get(abs.Marketing_Activity__c) == NULL){
                MABSmap.put(abs.Marketing_Activity__c, new list<Activity_Budget_Split__c>{abs});    
            }
            else{
                MABSmap.get(abs.Marketing_Activity__c).add(abs); 
            }
        }
          
        for(Marketing_Activity__c ma : mas){
            if(MABSmap.get(ma.id) != NULL){            
                for(Activity_Budget_Split__c abs : MABSmap.get(ma.id)){
                    abs.CurrencyIsoCode = ma.CurrencyIsoCode;
                    //retain the values on change of currency
                    abs.X01_January__c = abs.X01_January__c;
                    abs.X02_Febraury__c = abs.X02_Febraury__c;
                    abs.X03_March__c = abs.X03_March__c;
                    abs.X04_April__c = abs.X04_April__c;
                    abs.X05_May__c = abs.X05_May__c;
                    abs.X06_June__c = abs.X06_June__c;
                    abs.X07_July__c = abs.X07_July__c;
                    abs.X08_August__c = abs.X08_August__c;
                    abs.X09_September__c = abs.X09_September__c;
                    abs.X10_October__c = abs.X10_October__c;
                    abs.X11_November__c = abs.X11_November__c;
                    abs.X12_December__c = abs.X12_December__c;
                }
            }
        
        }
        
        list<Activity_Budget_Split__c> absUpdate = new list<Activity_Budget_Split__c>();
        for(id i : MABSmap.keyset()){
            for(Activity_Budget_Split__c abs : MABSmap.get(i)){
                absUpdate.add(abs);
            }
 
        }
        
        
        update absUpdate;
        }
        Catch(Exception e){
            system.debug('Exception e:' + e);
            throw(e);   
        }
         
    }


    Public static void checkAssociatedRecords(list<Marketing_Activity__c> mas){

        string errormsg = '';

        list<Marketing_Activity__c> closingMAs = new list<Marketing_Activity__c>();

        for(Marketing_Activity__c ma : mas){
            if(ma.status__c == 'Cancelled'  || ma.status__c == 'Completed'){
                closingMAs.add(ma);
            }
        }

        

        //In Village Brand Activities Check
        map<id, list<In_Village_Brand_Activity__c>> theinVillageBAMap = new map<id, list<In_Village_Brand_Activity__c>>();
        list<In_Village_Brand_Activity__c> theInVilBAs = [SELECT id, Name,Marketing_Activity__c,Status__c FROM In_Village_Brand_Activity__c WHERE Marketing_Activity__c IN: closingMAs];


        for(In_Village_Brand_Activity__c inv : theInVilBAs ){
            if(!theinVillageBAMap.containskey(inv.Marketing_Activity__c)){
                theinVillageBAMap.put(inv.Marketing_Activity__c,new list<In_Village_Brand_Activity__c>{inv});
            }
            else{
                if(!theinVillageBAMap.get(inv.Marketing_Activity__c).contains(inv)){
                    theinVillageBAMap.get(inv.Marketing_Activity__c).add(inv);
                }
            }   
        }


        list<In_Village_Brand_Activity__c> inVilCheck = new list<In_Village_Brand_Activity__c>();
        for(Marketing_Activity__c ma : mas){
            if(theinVillageBAMap.containskey(ma.id)){
                if(theinVillageBAMap.get(ma.id) != NULL){
                    for(In_Village_Brand_Activity__c inv :theinVillageBAMap.get(ma.id)){
                        if(inv.status__c != 'Completed' && inv.status__c != 'Cancelled'){
                            inVilCheck.add(inv);
                        }
                    }
                }

            }

            if(inVilCheck.size() > 0 && inVilCheck != NULL){
                String systemURL = URL.getSalesforceBaseUrl().toExternalForm(); 
                errormsg += '<b><u>In-Village Brand Activity Errors</u></b><br/>';
                for(In_Village_Brand_Activity__c inv : inVilCheck){
                    
                    errormsg += '<a href=\''+systemURL+'/'+inv.id + '\'  target="_blank">'+ inv.name + '</a> <br/>';
                    errormsg += '<br/>';
                }
                ma.addError('<br/>This record cannot be closed as there are open related records : </br>' + errormsg, false );
            }

        }




        //Product Loan Check
        map<id, list<Product_Loan__c>> theProdLoanMap = new map<id, list<Product_Loan__c>>();
        list<Product_Loan__c> theloanItems = [SELECT id, Name,Reason_For_Loan__c, Status__c FROM Product_Loan__c WHERE Reason_For_Loan__c IN: closingMAs];
        
        for(Product_Loan__c pl : theloanItems ){
            if(!theProdLoanMap.containskey(pl.Reason_For_Loan__c)){
                theProdLoanMap.put(pl.Reason_For_Loan__c,new list<Product_Loan__c>{pl});
            }
            else{
                if(!theProdLoanMap.get(pl.Reason_For_Loan__c).contains(pl)){
                    theProdLoanMap.get(pl.Reason_For_Loan__c).add(pl);
                }
            }   
        }


        list<Product_Loan__c> prodLoanCheck = new list<Product_Loan__c>();
        for(Marketing_Activity__c ma : mas){
            if(theProdLoanMap.containskey(ma.id)){
                if(theProdLoanMap.get(ma.id) != NULL){
                    for(Product_Loan__c pl :theProdLoanMap.get(ma.id)){
                        if(pl.status__c != 'Completed'){
                            prodLoanCheck.add(pl);
                        }
                    }
                }

            }

            if(prodLoanCheck.size() > 0 && prodLoanCheck != NULL){
                String systemURL = URL.getSalesforceBaseUrl().toExternalForm(); 
                errormsg += '<b><u>Product Loan Errors</u></b><br/>';
                for(Product_Loan__c pl : prodLoanCheck){
                    
                    errormsg += '<a href=\''+systemURL+'/'+pl.id + '\'  target="_blank">'+ pl.name + '</a> <br/>';
                    errormsg += '<br/>';
                }

                ma.addError('<br/>This record cannot be closed as there are open related records : </br>' + errormsg, false );
            }

        } 

    
    }

    public class MyException extends Exception {}


}