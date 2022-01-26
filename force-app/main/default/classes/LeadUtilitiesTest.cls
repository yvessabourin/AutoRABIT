@isTest
public class LeadUtilitiesTest {

	public Lead xpto {get; set;}

    @IsTest
    public static void setAccountReferenceTest(){

            Village__c vill = TestDataGenerator.setupVillage(false);
            vill.Oracle_Source_Template_Number__c = '123456';
            vill.Oracle_Organisation__c = 'SourceOrg';
            vill.Name = 'Bicester';
			vill.CertSales_CertPeriod_Cut_Off_Days__c = 1;
			vill.CertSales_Report_Sales_Grace_Period_Days__c = 1;
            insert vill;

                        RecordType brandRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Brand'];
            RecordType guestRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Guest'];

            Account brand = new Account();
            brand.RecordTypeId = brandRecordType.Id;
            brand.Name = 'Brand 1';
            insert brand;

            Village_Presence__c presentBrand = new Village_Presence__c();
            presentBrand.Name = 'Brand1 in village';
            presentBrand.Brand__c = brand.Id;
            presentBrand.Village__c = vill.Id;
            insert presentBrand;
  

		List<Lead> lstLead =   new List<Lead>{
                          new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',Email = 'as@gmail.com'),
                          new Lead(Company = 'Nike', LastName = 'John', Status = 'Open'),
                          new Lead(Company = 'Miles', LastName = 'Davis', Status = 'Open'),
                          new Lead(Company = 'Reebok', LastName = 'Hillen', Status = 'Open'),
                          new Lead(Company = 'Addidas', LastName = 'Shrin', Status = 'Open')
                         };  

                         insert lstLead;


		LeadUtilities.setAccountReference( lstLead[0] );
	  	LeadUtilities.displayEmailError( lstLead[0] );
	 	LeadUtilities.displayEmailCompanyError( lstLead[0] );
	  	LeadUtilities.displayvillageError( lstLead[0] );
		LeadUtilities.displayAccountRefError( lstLead[0] );
		LeadUtilities.canQuickConvert( lstLead[0] );
		//LeadUtilities.quickConvert( lstLead[0] );
		LeadUtilities.GetTourismRepresentitave('Jonh');

    }


}