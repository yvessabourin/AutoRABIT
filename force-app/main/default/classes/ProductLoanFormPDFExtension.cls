Public Class ProductLoanFormPDFExtension{

	public string html {get;set;}

	public id theID {get;set;}

    public ProductLoanFormPDFExtension(ApexPages.StandardController StdController){

	    theID = StdController.getid();
	    html = '';

	    if(theID != NULL){
		    list<cProductLoanItem> loanItems = new list<cProductLoanItem>();

		   	list<Product_Loan_Item__c> theLoanItemList = [SELECT Id, Name,description_of_product__c,Colour_of_product__c,Quantity_of_product__c,Product_Reference_SKU__c,Retail_Price__c,Outlet_Price__c,Damaged_on_collection__c,Damaged_on_return__c,Damage_Description__c FROM Product_Loan_Item__c WHERE Product_Loan__c =:theID ORDER BY Createddate];

		   	integer i = 1;
		   	WHILE (i <= theLoanItemList.size() ){
			   		for(Product_Loan_Item__c pli : theLoanItemList ){
			            loanItems.add(new cProductLoanItem(pli, i) );
			            i ++ ;
			        }
			    }
			
			html += '<table id="productItemTable" cellspacing="0"><tr><th width="3%" rowspan="2"></th><th bgcolor="#cccccc" scope="col" width="30%" rowspan="2">Description</th><th bgcolor="#cccccc" scope="col" width="6%" rowspan="2">Colour</th><th bgcolor="#cccccc" scope="col" width="4%" rowspan="2">QTY</th><th bgcolor="#cccccc" scope="col" width="13%" rowspan="2">Product REF/SKU</th><th bgcolor="#cccccc" scope="col" width="8%" rowspan="2">Retail Price</th><th bgcolor="#cccccc" scope="col" width="8%" rowspan="2">Outlet Price</th><th bgcolor="#cccccc" width="10%" rowspan="1" colspan="6" scope="col">Damage Details</th></tr>';
			html += '<tr><th bgcolor="#cccccc" rowspan="1" colspan="1" scope="col">Collection</th><th bgcolor="#cccccc" rowspan="1" colspan="1" scope="col">Return</th><th bgcolor="#cccccc" rowspan="1" scope="col" colspan="4">Description</th></tr>';

				for(cProductLoanItem thepli : loanItems){

					html += '<tr><td bgcolor="#cccccc" align="center" valign="middle">'+thepli.itemCount+'</td><td>'+thepli.pli.description_of_product__c+'</td><td>'+thepli.pli.Colour_of_product__c+'</td><td>'+thepli.pli.Quantity_of_product__c+'</td><td>'+thepli.pli.Product_Reference_SKU__c+'</td><td>'+thepli.pli.Retail_Price__c+'</td><td>'+thepli.pli.Outlet_Price__c+'</td><td>'+urlCheck(thepli.pli.Damaged_on_collection__c)+'</td><td>'+urlCheck(thepli.pli.Damaged_on_return__c)+'</td><td colspan="4">'+(thepli.pli.Damage_Description__c != NULL?thepli.pli.Damage_Description__c:'')+'</td></tr>';

				}
			html += '</table>';	
		}

		else{

			////////////Empty Table html
			string url = '<img src="/img/checkbox_unchecked.gif"/>';
			html += '<table id="emptytable" cellspacing="0"><tr><th width="3%" rowspan="2"></th><th bgcolor="#cccccc" scope="col" width="15%" rowspan="2">Description</th><th bgcolor="#cccccc" scope="col" width="6%" rowspan="2">Colour</th><th bgcolor="#cccccc" scope="col" width="4%" rowspan="2">QTY</th><th bgcolor="#cccccc" scope="col" width="13%" rowspan="2">Product REF/SKU</th><th bgcolor="#cccccc" scope="col" width="8%" rowspan="2">Retail Price</th><th bgcolor="#cccccc" scope="col" width="8%" rowspan="2">Outlet Price</th><th bgcolor="#cccccc" width="25%" rowspan="1" colspan="6" scope="col">Damage Details</th></tr>';
			html += '<tr><th bgcolor="#cccccc" rowspan="1" colspan="1" scope="col">Collection</th><th bgcolor="#cccccc" rowspan="1" colspan="1" scope="col">Return</th><th bgcolor="#cccccc" rowspan="1" scope="col" colspan="4">Description</th></tr>';

			integer i = 1;
			WHILE(i <= 10){
				html += '<tr ><td bgcolor="#cccccc" align="center" valign="middle"  >'+i+'</td><td></td><td></td><td></td><td></td><td></td><td></td><td>'+url+'</td><td>'+url+'</td><td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>';
				i ++ ;
			}

			html += '</table>';	
		}

	}


	public static string urlCheck(boolean bool){
		string url = '';
		if (bool){
			url = '<img src="/img/checkbox_checked.gif"/>';
		}
		else{
			url = '<img src="/img/checkbox_unchecked.gif"/>';
		}

		return url;
	}


    public class cProductLoanItem{
        public Product_Loan_Item__c pli {get; set;}
        public integer itemCount {get; set;}

        public cProductLoanItem(Product_Loan_Item__c thepli, integer count) {
            pli = thepli;
            itemCount = count;

        }


    }


}