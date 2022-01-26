public  class productLoanEmailController
{
    public Id ProductLoanID {get;set;}
    public List<Product_Loan_Item__c> getPLitems()
    {
        List<Product_Loan_Item__c> plItems;
        plItems = [SELECT ID, Name, Colour_of_product__c, Damage_Description__c,Damaged_on_collection__c,Damaged_on_return__c,Description_of_product__c,Outlet_Price__c,Product_Loan__c             
,Product_Reference_SKU__c,Quantity_of_product__c,Retail_Price__c,Sample_Product__c,Sample_Product_Price__c FROM Product_Loan_Item__c WHERE Product_Loan__c =: ProductLoanID];
        return plItems;
    }
}