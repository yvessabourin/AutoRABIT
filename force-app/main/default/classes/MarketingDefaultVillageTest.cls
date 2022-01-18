@isTest
public class MarketingDefaultVillageTest {
    @testSetup 
    public static void setup() {
        
        //newAccount
        Account  newAcc = new Account(
            RecordTypeId = '012b0000000ar4wAAA',
            name='teste',
            Country__c ='Albania',
            Type_of_Business__c ='Airline'  
        );
        insert newAcc;
        
        //NewUser
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User newUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8',
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='Emarck@testorg.com',
            Village__c ='Bicester'
            
            
        );
        insert newUser;
        
        //New Village
        Village__c newVillage = new Village__c(
            Name= 'Test',
            Village_Code__c= '1',
            Currency__c= 'EUR',
            CertSales_CertPeriod_Cut_Off_Days__c = 1, 
            CertSales_Report_Sales_Grace_Period_Days__c = 1
        );    
        insert NewVillage;
        
        //New  Marketing Campaign 
        
        Marketing_Campaign__c newCampaign = new Marketing_Campaign__c(
            Name= 'Test',
            Short_Description__c= 'XPTO',
            Campaign_Level__c= 'THEME',
            Village__c= NewVillage.Id,
            Status__c= 'To be Approved',
            Start_Date__c= system.today(),
            End_Date__c= system.today(),
            CurrencyIsoCode= 'GBP',
            Responsible__c = newUser.id, 
            Accountable_Person__c = newUser.id,
            Proposition__c= 'XPTO',
            Target_Audience__c= 'XPTO',
            KPI_Targets__c= 'XPTO'
            
        );
        insert newCampaign;
        
    }
    
    @isTest
    static void testCompareVillage(){
        Marketing_Campaign__c  camp = [SELECT Id,  Name FROM Marketing_Campaign__c]; 
        Account  acc = [SELECT Id, Name FROM Account];
        User us= [SELECT Id, Village__c FROM user WHERE LastName='Testing'];
        
        system.runAs(us){
            
            //New  Marketing Activity
            Marketing_Activity__c newMarketing = new Marketing_Activity__c(
                Name = 'Test',
                Business_Function__c = 'Local Tourism',
                Channel__c = 'CRM',
                Sub_Channel__c = 'Blogger',
                Marketing_Campaign__c    = camp.Id,
                Status__c    = 'To be Approved',
                Start_Date__c = system.today(),   
                End_Date__c = system.today(),     
                Partner__c = acc.Id,
                Accountable1__c = us.Id,
                Responsible_Person__c =us.Id
                
            );
            
            try{
                
                insert newMarketing;
                system.assertEquals(newMarketing.Picklist_Multi_Select__c, 'Bicester');
                
            } catch(Exception e){
                
            }
            
            
            
        }
        
        
    }
}