Public Class ProductLoanTriggerHandler{


    Public Static void isBeforeisInsert(List<Product_Loan__c> pls){

        for(Product_Loan__c pl : pls){
            if(pl.currency__c != NULL){
                if(pl.currency__c == 'GBP'){
                    pl.CurrencyIsoCode = 'GBP';
                }
                else {
                    pl.CurrencyIsoCode = 'EUR';
                }
            }
        }
    }



    Public Static void isBeforeUpdate(List<Product_Loan__c> pls){

        for(Product_Loan__c pl : pls){

            if(pl.currency__c != NULL){
                if(pl.currency__c == 'GBP'){
                    pl.CurrencyIsoCode = 'GBP';
                }
                else {
                    pl.CurrencyIsoCode = 'EUR';
                }
            }
        }
    }
    
    
    
    Public Static void isAfterInsert(map<id, Product_Loan__c> newmap){
        for(id i : newmap.keyset()){
            if(newmap.get(i).status__c != 'Request for collection'){
                emailLegalDepartmentProductLoan.sendEmail(newmap.get(i));
            }
        }
    }
    
    
    
    Public Static void isAfterUpdate(map<id, Product_Loan__c> oldmap, map<id, Product_Loan__c> newmap){
        for(id i : newmap.keyset()){
                if(newmap.get(i).status__c != oldmap.get(i).status__c && newmap.get(i).status__c != 'Request for collection'){
                    emailLegalDepartmentProductLoan.sendEmail(newmap.get(i));
                }
            }  
    }
    

}