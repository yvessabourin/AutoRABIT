public with sharing class DSCBDashboardFinanceInitialController {
    public Id village { get; set; }
    public String periodType { get; set; }
    public String period { get; set; }
    public String status { get; set; }
    public String dashboardPage { get; set; }
    public Boolean noVillages { get; set; }
    public Boolean messageVillage { get; set; }
    public Boolean enablePeriodNames { get; set; }
    public List<SelectOption> allVillages { get; set; }
    public List<SelectOption> periodTypeValuesList { get; set; }
    public List<SelectOption> allStatus { get; set; }
    public List<SelectOption> allPeriodNames { get; set; }
    public List<Daily_Sales_Certification_Batch__c> villageCertifications { get; set; }
    
    public DSCBDashboardFinanceInitialController() {
        dashboardPage = 'DSCBDashboardFinance?id=';
        allPeriodNames = new List<SelectOption>();
        allPeriodNames.add(new SelectOption(' ','--Select a period--'));
        enablePeriodNames = true;
        getVillagesItem();
        getPickListValuesIntoList();
        getDSCBStatus();
    }
    
    public List<SelectOption> getVillagesItem(){
        
        allVillages = new List<SelectOption>();
        // HERE LEFT THE FILTER BY HOW CAN WE FILTER THE USERS.
        List<Daily_Sales_Certification_Batch__c> existingCertifications = [SELECT Village_Presence__r.Village__c FROM Daily_Sales_Certification_Batch__c];
        Set<Id> setVillages = new Set<Id>();
        if(!existingCertifications.isEmpty()){
            for(Daily_Sales_Certification_Batch__c aCert : existingCertifications){
                setVillages.add(aCert.Village_Presence__r.Village__c);
            }

            List<Village__c> existingVillages = [SELECT Id, Name FROM Village__c WHERE Id = :setVillages ORDER BY Name];

            for(Village__c eachVillage : existingVillages){
                allVillages.add(new SelectOption(eachVillage.Id,eachVillage.Name));
            }
            
            getVillagePresenceCertifications(existingVillages[0].Id);
        }

        if(allVillages.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'No villages available. Please notify your village contact.'));
            messageVillage = true;
            noVillages = false;
            return null;
        }else{
            noVillages = true;
            messageVillage = false;
            return allVillages;
        }
    }
    
    public List<SelectOption> getPickListValuesIntoList(){
        periodTypeValuesList = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Village_Presence__c.CertSales_CertPeriod_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        periodTypeValuesList.add(new SelectOption(' ','--Select a value--'));
        for(Schema.PicklistEntry pickListVal : ple){
            periodTypeValuesList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        }     
        
        return periodTypeValuesList;
    }
    
    
    public List<SelectOption> getPeriodNames(String periodType, Id village){
        allPeriodNames = new List<SelectOption>();
        
        List<Daily_Sales_Certification_Batch__c> existingPeriodNames = [SELECT Id, Period_Name__c FROM Daily_Sales_Certification_Batch__c
                                                                        WHERE Certification_Period_Type__c = :periodType
                                                                        AND Village_Presence__r.Village__c = :village
                                                                        ORDER BY Period_Name__c];

        Set<String> somePeriodNames = new Set<String>();
        
        for(Daily_Sales_Certification_Batch__c eachPeriodName : existingPeriodNames){
            somePeriodNames.add(eachPeriodName.Period_Name__c);
            system.debug(eachPeriodName);
        }

        allPeriodNames.add(new SelectOption(' ','--Select a period--'));
        if(existingPeriodNames.isEmpty()){
            enablePeriodNames = true;
        } else {
            enablePeriodNames = false;
        }
        
        for(String eachString : somePeriodNames){
            if(eachString != null){
                allPeriodNames.add(new SelectOption(eachString, eachString));
            }
        }

        return allPeriodNames;
    }
    
    public List<SelectOption> getDSCBStatus(){
        allStatus = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Daily_Sales_Certification_Batch__c.Status__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        allStatus.add(new SelectOption(' ','--Select a status--'));
        for(Schema.PicklistEntry pickListVal : ple){
            allStatus.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        }
        
        return allStatus;
    }
    
    public List<Daily_Sales_Certification_Batch__c> getVillagePresenceCertifications(Id village){
        villageCertifications = new List<Daily_Sales_Certification_Batch__c>();
        
        villageCertifications = [SELECT ID, Name, Village_Presence__c, Status__c, Village_Presence__r.Brand__r.Name
                                 FROM Daily_Sales_Certification_Batch__c
                                 WHERE Village_Presence__r.Village__c = :village
                                 ORDER BY Village_Presence__r.Brand__r.Name];

        if(villageCertifications.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Does not exist any Certification Batch for this conditions.'));
        }

        return villageCertifications;
    }
    
    public List<Daily_Sales_Certification_Batch__c> getValues(){
        String query = 'SELECT ID, Name, Village_Presence__c, Status__c, Village_Presence__r.Brand__r.Name'+
            ' FROM Daily_Sales_Certification_Batch__c' + ' WHERE Village_Presence__r.Village__c =: village';
        
        if(enablePeriodNames == false){ //verify the disablility of the picklist
            if(period != ' '){
                system.debug(period);
                query += ' AND Period_Name__c =: period';
            }
        }
        
        if(status != ' '){
            system.debug(status);
            query += ' AND Status__c =: status';
        }

        query += ' ORDER BY Village_Presence__r.Brand__r.Name';
        system.debug(query);
        
        villageCertifications = Database.query(query);
        if(villageCertifications.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Does not exist any Certification Batch for this conditions.'));
        }
        return null;
    }

    public List<Daily_Sales_Certification_Batch__c> getPeriodValue(){
        String query = 'SELECT ID, Name, Village_Presence__c, Status__c, Village_Presence__r.Brand__r.Name'+
            ' FROM Daily_Sales_Certification_Batch__c' + ' WHERE Village_Presence__r.Village__c =: village';

        if(periodType != ' '){
            query += ' AND Certification_Period_Type__c =: periodType';
            period = ' ';
            getPeriodNames(periodType, village);
        } else {
            enablePeriodNames = true;
        }

        villageCertifications = Database.query(query);
        if(villageCertifications.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Does not exist any Certification Batch for this conditions.'));
        }

        return null;
    }
}