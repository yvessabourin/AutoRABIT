public class BP_PDF_Render_Controller {

    public Id recordId { get; set; }
    public List <Daily_Sale__c> theCert {get; set;}

    public Daily_Sales_Certification_Batch__c dscbFields {get; set;}
    public Account brandAccount {get; set;} 
    
    public Decimal spaceTotal {get; set;} 
    public Boolean renderValue {get; set;}

    public Decimal totalNet {get; set;} 
    public Decimal totalVip {get; set;} 
    public String startDate {get; set;}
    public String finalDate {get; set;} 
    public String villagePresenceName {get; set;} 
    public String certifiedBy {get; set;}
    public String brandName {get; set;}
    public String currencyCode {get; set;}
    public String currencySeparator {get; set;}
    
    public Date certifiedDate {get; set;}
    public String certifiedDateWithoutTime {get;set;}
    
    
    public String villageName {get; set;}
    public String villageCode {get; set;}
    public String villageLanguage {get; set;}
    public String printLanguage {get; set;}
    public Village__c theVillage {get; set;} 
    public String logo {get; set;} 
    
    public BP_PDF_Render_Controller() {
    
        // get record id from query parameters        
        recordId = ApexPages.currentPage().getParameters().get('id');        
        theCert = [SELECT Id, Trading_Day_with_date__c, Trading_Date__c, MRI_Suite_Id__c, Store_Closed__c, Certified_Amount_NetTotal__c, Certified_Amount_Discount__c,
                   Certified_Amount_NetTotal_Input__c, Certified_Amount_Discount_Input__c, Certified_Amount__c
                   FROM Daily_Sale__c
                   WHERE Certification_Batch__c = :recordId 
                   ORDER BY Trading_Day_with_date__c ASC];
        
        dscbFields = [SELECT Id, Total_Certified_Amount__c, Period_Start_Date__c, Period_End_Date__c, Village_Presence__r.Name, Certified_by__c, Village_Presence__r.Brand__c,
                      Certified_Date_Time__c, Village_Presence__r.Village__c, CurrencyIsoCode
                      FROM Daily_Sales_Certification_Batch__c
                      WHERE Id = :recordId];
        
        brandAccount = [SELECT Name FROM Account WHERE Id = :dscbFields.Village_Presence__r.Brand__c];
        
        theVillage = [SELECT Id, Integration_Village_Name__c, Integration_Language_Name__c, CertS_Brand_Turnover_Cert_Decl_Statement__c, Village_Code__c
                   FROM Village__c
                   WHERE Id = : dscbFields.Village_Presence__r.Village__c]; 
         
        currencyCode = String.valueOf(dscbFields.CurrencyIsoCode);
        
        villageName = theVillage.Integration_Village_Name__c;
        villageCode = theVillage.Village_Code__c;
        villageLanguage = theVillage.Integration_Language_Name__c;
        system.debug(villageLanguage);
        
        switch on villageLanguage{
            
            when 'English' {
                printLanguage = 'en_US';
            }
            when 'French' {
                printLanguage = 'fr';
            }
            when 'Spanish'{
                printLanguage = 'es';
            }
            when 'German'{
                printLanguage = 'de'; 
            }
            when 'Italian'{
                printLanguage = 'it';
            }
            when else{
                printLanguage = 'en_US';
            }                          
        }
        
        if (villageCode == 'MV'){
            printLanguage = 'en_US'; 
        }
        
        if (villageCode == 'BV' || villageCode == 'KV'){
            currencySeparator = 'CT'; 
        }else{
            currencySeparator = 'DT';            
        }  

        logo = theVillage.Village_Code__c + '.jpg';
        system.debug('Logo de agora '+logo);
        
        brandName = brandAccount.Name;
        certifiedBy = dscbFields.Certified_by__c;
                
        Datetime certifiedDateTime = dscbFields.Certified_Date_Time__c;
        certifiedDate = date.newInstance(certifiedDateTime.year(), certifiedDateTime.month(), certifiedDateTime.day());
        certifiedDateWithoutTime = certifiedDate.format();
        villagePresenceName = dscbFields.Village_Presence__r.Name;
                
        startDate = dscbFields.Period_Start_Date__c.format();
        finalDate = dscbFields.Period_End_Date__c.format();
       
        totalNet = 0;
        totalVip = 0;
        renderValue = false;        
               
        for(Daily_Sale__c ds : theCert ){
            if (ds.Store_Closed__c == false ){
                totalNet = totalNet + ds.Certified_Amount_NetTotal__c;
                totalVip = totalVip + ds.Certified_Amount_Discount__c;                
            }else{
                renderValue = true;
            }
        }
       
       spaceTotal = theCert.size();
       system.debug(spaceTotal);

       //setup a default file name
       string fileName = 'PDF Certificate'+'.pdf';
       Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName );

    }
    
}