public with sharing class DSCBDashboardFinanceController {
 
    public Id certId { get; set; }
    public Daily_Sales_Certification_Batch__c certification { get; set; }
    public List<Daily_Sale__c> certificationDailySales { get; set; }
    public String leaseIDValue { get; set; }
    public Boolean appearButtons { get; set; }
    public Boolean reopenButton { get; set; }
    public Boolean youHaventDS { get; set; }
    public Boolean errorOnApprove { get; set; }
    public Boolean errorOnReject { get; set; }
    public Boolean rejectReason { get; set; }
    public Boolean appearRejectButton { get; set; }
    public String inputReasonReject { get; set; }
    public Boolean appearSendEmailButton { get; set; }
    public Boolean appearPDFButton { get; set; }
    public Map<String, Map<String, Decimal>> calculationValues { get; set; }
    public Boolean showRepeat { get; set; }
    
    public List<wrapper> lstwrapper {get; set;}
    
    public String sortDirection { get; set; }
    public String sortExp = 'Name';
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public DSCBDashboardFinanceController(ApexPages.StandardController controller) {
        certId = ApexPages.currentPage().getParameters().get('Id');
        certification = [SELECT Id, Status__c, BP_Validation_Context_Override__c, Reject_Reason__c, Brand_Must_Edit_Before_Submission__c FROM Daily_Sales_Certification_Batch__c WHERE Id = :certId];
        if(certification.Status__c == 'Pending Approval'){
            appearButtons = true;
            reopenButton = false;
            rejectReason = false;
            appearSendEmailButton = false;
            appearPDFButton = true;
        } else if (certification.Status__c == 'Batch Complete'){
            appearButtons = false;
            reopenButton = true;
            rejectReason = false;
            appearSendEmailButton = false;
            appearPDFButton = true;
        } else if(certification.Status__c == 'Rejected' || certification.Status__c == 'Re-opened' || certification.Status__c == 'Approved'){
            appearSendEmailButton = true;
            appearButtons = false;
            reopenButton = false;
            rejectReason = false;
            appearPDFButton = true;
        } else if(certification.Status__c == 'Open' || certification.Status__c == 'Generated'){
            appearSendEmailButton = true;
            appearButtons = false;
            reopenButton = false;
            rejectReason = false;
            appearPDFButton = false;
        }
        getLeaseID();
        getDailySales();
    }
    
    public List<Daily_Sale__c> getDailySales(){
        
        certificationDailySales = [SELECT Id, Name, Trading_Date__c, MRI_Suite_Id__c, Store_Closed__c, Total_NET_SALES__c,
                                   NET_Value_of_Discounts__c, Brand_Reported_Amount__c, Certified_Amount_NetTotal_Input__c,
                                   Certified_Amount_Discount_Input__c, Certified_Amount__c, Variance_Amount__c,
                                   Certification_Comment__c, Lease_ID__c, MRI_Phase_Id__c
                                   FROM Daily_Sale__c
                                   WHERE Certification_Batch__c = :certId
                                   ORDER BY Trading_Date__c ASC];
        
        if(certificationDailySales.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Does not exist any Daily Sales for this Certification Batch'));
            youHaventDS = true;
            errorOnApprove = false;
            errorOnReject = false;
            rejectReason = false;
            appearSendEmailButton = false;
            appearPDFButton = false;
        }
        
        return certificationDailySales;
    }
    
    public List<Daily_Sale__c> getSortedValues(){
        String query = 'SELECT Id, Name, Trading_Date__c, MRI_Suite_Id__c, Store_Closed__c, Total_NET_SALES__c, ' +
            'NET_Value_of_Discounts__c, Brand_Reported_Amount__c, Certified_Amount_NetTotal_Input__c, ' +
            'Certified_Amount_Discount_Input__c, Certified_Amount__c, Variance_Amount__c, ' +
            'Certification_Comment__c, Lease_ID__c, MRI_Phase_Id__c ' +
            'FROM Daily_Sale__c ' +
            'WHERE Certification_Batch__c = :certId ';
        
        String sortFullExp = sortExpression  + ' ' + sortDirection;
        query = query + 'ORDER BY ' + sortFullExp;
        query += ' NULLS LAST';
        system.debug(query);
        certificationDailySales = Database.query(query);
        
        if(certificationDailySales.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Does not exist any Daily Sales for this Certification Batch'));
            youHaventDS = true;
            errorOnApprove = false;
            errorOnReject = false;
            rejectReason = false;
            appearSendEmailButton = false;
            appearPDFButton = false;
        }
        
        return null;
    }
    
    public PageReference cancelAction(){
        
        PageReference returnPage = Page.DSCBDashboardFinanceInitial;
        return returnPage;
    }
    
    public PageReference cancelActionReject(){
        appearButtons = true;
        rejectReason = false;
        return null;
    }
    
    public void saveLeaseIDPhaseIDUnit(){
        List<Daily_Sale__c> oldDS = [SELECT ID, Lease_ID__c, MRI_Phase_Id__c, MRI_Suite_Id__c FROM Daily_Sale__c WHERE Certification_Batch__c = :certId];
        List<Daily_Sale__c> updatedDS = new List<Daily_Sale__c>();

        for(Daily_Sale__c ds : certificationDailySales){
            for(Daily_Sale__c old : oldDS){
                if(ds.Id == old.Id &&(ds.Lease_ID__c != old.Lease_ID__c || ds.MRI_Phase_Id__c != old.MRI_Phase_Id__c || ds.MRI_Suite_Id__c != old.MRI_Suite_Id__c)){
                    updatedDS.add(ds);
                }
            }
        }

        try{
            update updatedDS;
        } catch (Exception e){
            logFile__c log = new logFile__c();
            log.Body__c = 'Error on update a list of Daily Sales in DSCBDashboardFinanceController class. It is related with Certification Id: ' + certification.Id + '. With the following mesage: ' + e.getMessage();
            log.Type__c = 'Update a list of Daily Sales through Certification Dashboard';
            insert log;
            system.debug('Exist an error on update a list of Daily Sales in DSCBDashboardFinanceController class. With the following mesage: ' + e.getMessage());
        }
        
        getLeaseID();
    }
    
    public PageReference rejectAction(){
        errorOnReject = false;
        errorOnApprove = false;
        youHaventDS = false;
        rejectReason = true;
        appearButtons = false;
        appearSendEmailButton = false;
        appearPDFButton = false;
        return null;
    }
    
    public PageReference approveAction(){
        saveLeaseIDPhaseIDUnit();
        
        List<Daily_Sale__c> updateAllDS = new List<Daily_Sale__c>();
        for(Daily_Sale__c ds:certificationDailySales){
            if(ds.Lease_ID__c == null || ds.MRI_Phase_Id__c == null || ds.MRI_Suite_Id__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'All Daily Sales records must have Lease ID, Phase ID and Unit completed before the Sales Certification can be approved.'));
                errorOnReject = false;
                errorOnApprove = true;
                youHaventDS = false;
                rejectReason = false;
                return null;
            }
            ds.Status__c = 'Certified Approved';
            updateAllDS.add(ds);
        }

        try{    
            update updateAllDS;
        } catch (Exception e){
            logFile__c log = new logFile__c();
            log.Body__c = 'Error on update a list of Daily Sales in DSCBDashboardFinanceController class. It is related with Certification Id: ' + certification.Id + '. With the following mesage: ' + e.getMessage();
            log.Type__c = 'Update a list of Daily Sales through Certification Dashboard';
            insert log;
            system.debug('Exist an error on update a list of Daily Sales in DSCBDashboardFinanceController class. With the following mesage: ' + e.getMessage());
        }


        certification.Status__c = 'Approved';

        try{
            update certification;
        } catch (Exception e){
            logFile__c log = new logFile__c();
            log.Body__c = 'Error on update the certification on DSCBDashboardFinanceController class. It is related with Certification Id: ' + certification.Id + '. With the following mesage: ' + e.getMessage();
            log.Type__c = 'Update a list of Daily Sales through Certification Dashboard';
            insert log;
            system.debug('Exist an error on update the certification on DSCBDashboardFinanceController class. With the following mesage: ' + e.getMessage());
        }

        PageReference returnPage = Page.DSCBDashboardFinanceInitial;
        return returnPage;
    }
    
    public PageReference reopenAction(){
        
        List<Daily_Sale__c> updateAllDS = new List<Daily_Sale__c>();
        for(Daily_Sale__c ds:certificationDailySales){
            ds.Status__c = 'Certified Re-opened';
            updateAllDS.add(ds);
        }
        
        try{
            update updateAllDS;
        } catch (Exception e){
            logFile__c log = new logFile__c();
            log.Body__c = 'Error on update a list of Daily Sales in DSCBDashboardFinanceController class. It is related with Certification Id: ' + certification.Id + '. With the following mesage: ' + e.getMessage();
            log.Type__c = 'Update a list of Daily Sales through Certification Dashboard';
            insert log;
            system.debug('Exist an error on update a list of Daily Sales in DSCBDashboardFinanceController class. With the following mesage: ' + e.getMessage());
        }

        certification.Status__c = 'Re-opened';
        certification.Brand_Must_Edit_Before_Submission__c = true;

        try{
            update certification;
        } catch (Exception e){
            logFile__c log = new logFile__c();
            log.Body__c = 'Error on update the certification on DSCBDashboardFinanceController class. It is related with Certification Id: ' + certification.Id + '. With the following mesage: ' + e.getMessage();
            log.Type__c = 'Update a list of Daily Sales through Certification Dashboard';
            insert log;
            system.debug('Exist an error on update the certification on DSCBDashboardFinanceController class. With the following mesage: ' + e.getMessage());
        }
        
        PageReference returnPage = Page.DSCBDashboardFinanceInitial;
        return returnPage;
    }
    
    public PageReference saveRejection(){
        if(String.isBlank(inputReasonReject)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'You need to introduce a Reject Reason'));
            errorOnReject = true;
            errorOnApprove = false;
            youHaventDS = false;
            return null;
        } else {
            saveLeaseIDPhaseIDUnit();
            
            String nameUser = UserInfo.getName();
            
            certification.Status__c = 'Rejected';
            
            String newComment;
            if(certification.Reject_Reason__c != null){
                newComment = certification.Reject_Reason__c + '\n' + nameUser + ' - ' + system.now() + ': ' + '\n' + inputReasonReject + '\n';
            } else {
                newComment = nameUser + ' - ' + system.now() + ': ' + '\n' + inputReasonReject + '\n';
            }

            certification.Reject_Reason__c = newComment;
            certification.Brand_Must_Edit_Before_Submission__c = true;
            
            try{
                update certification;
            } catch (Exception e){
                logFile__c log = new logFile__c();
                log.Body__c = 'Error on update the certification on DSCBDashboardFinanceController class. It is related with Certification Id: ' + certification.Id + '. With the following mesage: ' + e.getMessage();
                log.Type__c = 'Update a list of Daily Sales through Certification Dashboard';
                insert log;
                system.debug('Exist an error on update the certification on DSCBDashboardFinanceController class. With the following mesage: ' + e.getMessage());
            }

            PageReference returnPage = Page.DSCBDashboardFinanceInitial;
            return returnPage;
        }
    }
    
    public PageReference exportPDF(){
        PageReference returnPage = new PageReference('/apex/BP_PDF_Render?id=' + certId);
        returnPage.setRedirect(true);
        return returnPage;
    }

    public void sendEmail(){
        
    }
    
    public PageReference exportToCSV(){
        
        PageReference retURLExcel = new PageReference('/apex/DSCBDashboardFinanceExportFile');
        return retURLExcel;
    }
    
    public void exportToExcel(){
        lstwrapper = new List<wrapper>();
        for(Daily_Sale__c ds :certificationDailySales){
            wrapper w = new wrapper();
            w.tradingDate = ds.Trading_Date__c.format();
            w.mriUnit = ds.MRI_Suite_Id__c;
            if(ds.Store_Closed__c == true){
                w.storeClose = 'YES';
            } else{
                w.storeClose = 'NO';
            }
            
            w.totalNETSales = ds.Total_NET_SALES__c;
            w.certifiedNETSales = ds.Certified_Amount_NetTotal_Input__c;
            w.netDiscounts = ds.NET_Value_of_Discounts__c;
            w.certifiedNETDiscounts = ds.Certified_Amount_Discount_Input__c;
            w.reportedAmount = ds.Brand_Reported_Amount__c;
            w.certifiedAmount = ds.Certified_Amount__c;
            w.varianceAmount = ds.Variance_Amount__c;
            w.comment = ds.Certification_Comment__c;
            w.leaseID = ds.Lease_ID__c;
            w.phaseID = ds.MRI_Phase_Id__c;
            lstwrapper.add(w);
        }
    }
    
    public class wrapper{
        public String tradingDate {get; set;}
        public String mriUnit {get; set;}
        public String storeClose {get; set;}
        public Decimal totalNETSales {get; set;}
        public Decimal certifiedNETSales {get; set;}
        public Decimal netDiscounts {get; set;}
        public Decimal certifiedNETDiscounts {get; set;}
        public Decimal reportedAmount {get; set;}
        public Decimal certifiedAmount {get; set;}
        public Decimal varianceAmount {get; set;}
        public String comment {get; set;}
        public String leaseID {get; set;}
        public String phaseID {get; set;}
    }
    
    public Map<String, Map<String, Decimal>> getLeaseID(){
        
        List<Daily_Sale__c> dsList= [SELECT Lease_ID__c, Total_NET_SALES__c, NET_Value_of_Discounts__c, Brand_Reported_Amount__c, Certified_Amount_NetTotal__c,
                                           Certified_Amount_Discount__c, Certified_Amount__c, Variance_Amount__c
                                           FROM Daily_Sale__c
                                           WHERE Certification_Batch__c = :certId
                                           ORDER BY Lease_ID__c ASC NULLS LAST];
        
        Set<String> leaseSet = new Set<String>();
        for(Daily_Sale__c ds : dsList){
            leaseSet.add(ds.Lease_ID__c);
        }
        
        if(leaseSet.size() > 1){
            showRepeat = true;
            Map<String, Decimal> leaseIDMap = new Map<String, Decimal>();
            calculationValues = new Map <String, Map<String, Decimal>>();
            
            for(Daily_Sale__c ds : dsList){
                if(ds.Lease_ID__c != NULL){
                    if(calculationValues.containsKey(ds.Lease_ID__c) == false){
                        leaseIDMap = new Map<String, Decimal>();
                        
                        if(ds.Brand_Reported_Amount__c != null){
                            leaseIDMap.put('totalBRA',ds.Brand_Reported_Amount__c);
                        } else{
                            leaseIDMap.put('totalBRA',0);
                        }
                        
                        if(ds.Certified_Amount_NetTotal__c != null){
                            leaseIDMap.put('totalCNSA',ds.Certified_Amount_NetTotal__c);
                        } else{
                            leaseIDMap.put('totalCNSA',0);
                        }
                        
                        if(ds.Certified_Amount__c != null){
                            leaseIDMap.put('totalCA',ds.Certified_Amount__c);
                        } else{
                            leaseIDMap.put('totalCA',0);
                        }
                        
                        if(ds.Certified_Amount_Discount__c != null){
                            leaseIDMap.put('totalCDA',ds.Certified_Amount_Discount__c);
                        } else{
                            leaseIDMap.put('totalCDA',0);
                        }
                        
                        if(ds.Variance_Amount__c != null){
                            leaseIDMap.put('totalVA',ds.Variance_Amount__c);
                        } else{
                            leaseIDMap.put('totalVA',0);
                        }
                        
                        calculationValues.put(ds.Lease_ID__c, leaseIDMap);
                        system.debug(calculationValues);
                        
                    } else {
                        leaseIDMap = calculationValues.get(ds.Lease_ID__c);
                        
                        if(ds.Brand_Reported_Amount__c != null){
                            Decimal totalBRA = leaseIDMap.get('totalBRA');
                            if(totalBRA != null){
                                leaseIDMAp.put('totalBRA',ds.Brand_Reported_Amount__c + totalBRA);
                            } else {
                                leaseIDMAp.put('totalBRA',ds.Brand_Reported_Amount__c);
                            }
                        }
                        
                        if(ds.Certified_Amount_NetTotal__c != null){
                            Decimal totalCNSA = leaseIDMap.get('totalCNSA');
                            if(totalCNSA != null){
                                leaseIDMAp.put('totalCNSA',ds.Certified_Amount_NetTotal__c + totalCNSA );
                            } else {
                                leaseIDMAp.put('totalCNSA',ds.Certified_Amount_NetTotal__c);
                            }
                        }
                        
                        if(ds.Certified_Amount__c != null){
                            Decimal totalCA = leaseIDMap.get('totalCA');
                            if(totalCA != null){
                                leaseIDMAp.put('totalCA',ds.Certified_Amount__c + totalCA);
                            } else {
                                leaseIDMAp.put('totalCA',ds.Certified_Amount__c);
                            }
                        }
                                                
                        if(ds.Certified_Amount_Discount__c != null){
                            Decimal totalCDA = leaseIDMap.get('totalCDA');
                            if(totalCDA!= null){
                                leaseIDMAp.put('totalCDA',ds.Certified_Amount_Discount__c + totalCDA);
                            } else {
                                leaseIDMAp.put('totalCDA',ds.Certified_Amount_Discount__c);
                            }
                        }
                        
                        if(ds.Variance_Amount__c != null){
                            Decimal totalVA = leaseIDMap.get('totalVA');
                            if(totalVA != null){
                                leaseIDMAp.put('totalVA',ds.Variance_Amount__c + totalVA);
                            } else {
                                leaseIDMAp.put('totalVA',ds.Variance_Amount__c);
                            }
                        }
                        
                    }
                    system.debug(calculationValues);
                }
            }
            
            return calculationValues;
        } else {
            showRepeat = false;
            return null;
        }
    }
}