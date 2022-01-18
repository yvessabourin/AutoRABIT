({
    doInit : function(component, event, helper) {
        var sortF = component.get("v.selectedTabsoft");
        helper.getTheDSRelated(component, event, sortF);
        helper.getTheCertification(component, event, helper);
        helper.getCertificationName(component, event, helper);
        helper.getCertificationRange(component, event, helper);
        helper.getCertificationComment(component, event, helper);
        helper.getCurrencyCode(component, event, helper);
    },
    
    brandSalesCertification: function (component, event, helper) {
        var flag = component.get('v.checkEditing');
        if(flag == false){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/certification-landing-page"
            });
            urlEvent.fire();
        } else {
            component.set('v.unsavedChangesisOpen',true);
        }
    },   
    
    // ## function call on Click on the "Download As CSV" Button.
    downloadCsv : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.data");
        var villageName = component.get("v.village");
        var certPeriod = component.get("v.certificationPeriod");
        var totalData = component.get("v.dataT");
        var overallC = component.get("v.overallComment");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData,villageName,certPeriod,totalData,overallC);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####      
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=UTF-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    
    cancelSubmit: function(component, event, helper) {
        component.set("v.submitMessageisOpen", false);
    },
    
    confirmSubmit: function(component, event, helper) {
        helper.submitCertification(component, event, helper, true);
    },
    
    handleClickSubmit: function(component, event, helper){
        helper.submitCertification(component, event, helper, false);
        //component.set("v.submitMessageisOpen", true);
    },
    
    cancelUnsavedChanges: function(component, event, helper){
        component.set("v.unsavedChangesisOpen", false);
    },
    
    confirmUnsavedChanges: function(component, event, helper){  
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/certification-landing-page"
        });
        urlEvent.fire();
    },
    
    handleRowAction: function (cmp, event,helper) {
        var id=event.getSource().get("v.text");
        helper.editRowStatus(cmp,id);
        cmp.set("v.showSaveCancelBtn",true);
        cmp.set("v.disableOnEdit", true);
    },
    
    save: function(component, event, helper) {
        // Check required fields(Name) first in helper method which is return true/false
        
        // call the saveAccount apex method for update inline edit fields update 
        var button2 = component.find('btn2');  
        var button3 = component.find('btn3');  
        button2.set('v.disabled', true); 
        button3.set('v.disabled', true);   
        var urlEvent = $A.get("e.force:navigateToURL");
        var sPageURL = decodeURIComponent(window.location.search.substring(4));  
        var action = component.get("c.saveDaily");
        var overallCom = component.get("v.overallComment");
        action.setParams({
            'lstDaily': component.get("v.data"),
            'certId'  : sPageURL,
            'overallComment' : overallCom
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set AccountList list with return value from server.
                component.set("v.data", storeResponse);
                
                
                component.set("v.overallComment", overallCom);
                // Hide the save and cancel buttons by setting the 'showSaveCancelBtn' false 
                // component.set("v.showSaveCancelBtn",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.BP_Success"),
                    message: $A.get("$Label.c.BP_Records_Successfull_Updated"),
                    type: "success"
                });
                toastEvent.fire();  
                urlEvent.setParams({
                    "url": "/certified-sales?id=" + sPageURL
                });
                urlEvent.fire();                
            }else{
                // Configure error toast
                var errors = response.getError();
                let toastParams = {
                    title: $A.get("$Label.c.BP_Error"),
                    message: $A.get("$Label.c.BP_Something_Went_Wrong"), // Default error message
                    type: "error",
                    durantion: 10000
                };
                // Pass the error message if any
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastParams.message = errors[0].message;
                }
                // Fire error toast
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();                
                urlEvent.setParams({
                    "url": "/certified-sales?id=" + sPageURL
                });
                urlEvent.fire();   
            }
        });
        $A.enqueueAction(action);
        
    },
    
    cancel : function(component,event,helper){
        // on cancel refresh the view (This event is handled by the one.app container. It’s supported in Lightning Experience, the Salesforce app, and Lightning communities. ) 
        //$A.get('e.force:refreshView').fire(); BUT ON refreshView, DONT USE refreshView
        var urlEvent = $A.get("e.force:navigateToURL");
        var sPageURL = decodeURIComponent(window.location.search.substring(4));  
        urlEvent.setParams({
            "url": "/certified-sales?id=" + sPageURL
        }); 
        urlEvent.fire();   
    },
    
    onChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        // if(event.getSource().get("v.value").trim() != ''){ 
        component.set("v.showSaveCancelBtn",true);
        component.set("v.checkEditing",true);
        component.set("v.disableOnEdit", true);
        // }
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    sortDate: function(component, event, helper) {
        
        component.set("v.selectedTabsoft", 'Trading_Day_with_date__c');
        
        helper.sortHelper(component, event, 'Trading_Day_with_date__c');
        
    },
    
    sortUnit: function(component, event, helper) {
        
        component.set("v.selectedTabsoft", 'MRI_Suite_Id__c');
        
        helper.sortHelper(component, event, 'MRI_Suite_Id__c');
        
    },    
    
    sortVariance: function(component, event, helper) {
        
        component.set("v.selectedTabsoft", 'Variance_Amount__c');
        
        helper.sortHelper(component, event, 'Variance_Amount__c');
        
    },
    
    openPDFwindow : function(component, event, helper) {
                
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/reportpage?id='+ sPageURL 
        });
        urlEvent.fire();        
    },
    
    handleClickUpload: function(component, event, helper){
        
        component.set("v.UploadMessageisOpen", true); 
    },
    
    cancelUpload: function(component, event, helper) {
        
        component.set("v.UploadMessageisOpen", false);
    },

    readCSV: function(component, event, helper) { 
        
        var infolst = component.get("v.data");
        var filename = event.getSource().get("v.files"); 
        var textdata;
        var reader = new FileReader();
        var storeClosed = false;   
        var validation = true;
        var fileEvent = event.getParam("files")[0];
        var uploadedFileName = fileEvent.name;
        var uploadedFileSize = fileEvent.size;
        
        if( (uploadedFileName.indexOf('.csv') > -0)  && (uploadedFileSize < 1000000)){
            
            reader.onload = function(){  			
                var text = reader.result; /*Get the data stored in file*/
                textdata = text;
                var rows = textdata.split('\r\n'); /*Spilt based on new line to get each row*/       
                var endrow = 'x';
                var delimiter = true;
                
                /* Ignore the first row (header)  and start from second*/
                for (var i = 4; (i < rows.length) && (endrow[0] != '') && delimiter; i = i + 1) {
                    
                    var cells = rows[i].split(','); 
                    endrow = rows[i+1].split(',');                
                    
                    if(cells.length == 1){ //In case, the delimiter is changed from , to ; , we can handle both
                        cells = cells[0].split(';');
                        endrow = rows[i+1].split(';');
                        //If still no division, fire warning related to delimiter
                        if(cells.length == 1){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: $A.get("$Label.c.BP_Error"), 
                                message: $A.get("$Label.c.BP_PDF_Delimiter"), 
                                duration: "10000",
                                mode: "dismissible",
                                type: "error"
                            });
                            toastEvent.fire();     
                            delimiter = false;
                        }                       
                    }
                    
                    try{ 
                        if( cells[2] == 'Y' || cells[2] == 'y'){                            
                            infolst[i-4].Store_Closed__c = true; 
                            infolst[i-4].Certified_Amount_NetTotal_Input__c = '';
                            infolst[i-4].Certified_Amount_Discount_Input__c = '';
                        }else if( cells[2] == 'N' || cells[2] == 'n' ){                            
                            infolst[i-4].Store_Closed__c = false; 
                            infolst[i-4].Certified_Amount_NetTotal_Input__c = cells[4];
                            infolst[i-4].Certified_Amount_Discount_Input__c = cells[6];
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: $A.get("$Label.c.BP_Error"), 
                                message: $A.get("$Label.c.BP_Template_Not_Supported"),
                                duration: "10000",
                                mode: "dismissible",
                                type: "error",
                            });
                            toastEvent.fire();     
                            delimiter = false;
                        }
                    }catch(e){
                        alert("Error: " );            
                    }
                    
                }                     
                if(delimiter){
                    
                    try{
                        component.set("v.data",infolst);   
                    }catch(e){
                        alert("Error: ");            
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.BP_Success"), 
                        message: $A.get("$Label.c.BP_File_Success_Upload"),
                        type: "success"
                    });
                    toastEvent.fire();   
                }                      
            }
            
            if (filename[0] !== undefined && filename[0] !== null && filename[0] !== '') {
                reader.readAsText(filename[0]);
            }
            
            component.set("v.UploadMessageisOpen", false);           
            var a = component.get('c.onChange');
            $A.enqueueAction(a);     
            
        }else{
            
            if( uploadedFileSize >= 1000000 ){                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.BP_Error"), 
                    message: $A.get("$Label.c.BP_File_Upload_Size"),
                    duration: "10000",
                    mode: "dismissible",
                    type: "error"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.BP_Error"), 
                    message: $A.get("$Label.c.BP_File_Not_Supported"),
                    duration: "10000",
                    mode: "dismissible",
                    type: "error"
                });
                toastEvent.fire();                 
            }
        }
    }
})