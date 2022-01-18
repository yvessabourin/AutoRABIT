({
    getTheDSRelated : function(component, event, sortField) {
        var action = component.get('c.getDalySales');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        action.setParams({
            certId:sPageURL,
            'sortField': sortField,
            'isAsc': component.get("v.isAsc")
        });
        
        action.setCallback(this,function(actionResult){
            component.set('v.data', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    getTheCertification : function(component, event, helper){
        var action = component.get('c.getCertification');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        action.setParams({
            certId:sPageURL
        });
        action.setCallback(this,function(actionResult){
            
            var status = actionResult.getReturnValue().Status__c;
            var enableEdit;
            var overallC = component.find('overall');         
            
            if( (status == "Pending Approval") || (status == "Approved") || (status == "Batch Complete") ){            	        
                component.set('v.isHistory', true); 
                component.set('v.isSubmit', false);
                overallC.set('v.disabled', true); 
                enableEdit = false;    
            }else{
                component.set('v.isHistory', false); 
                component.set('v.isSubmit', true);
                overallC.set('v.disabled', false); 
                enableEdit = true;    
            }
            
            actionResult.getReturnValue().Name = $A.get("$Label.c.BP_Total");
            component.set('v.dataT', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    getCertificationName : function(component, event, helper) {
        var action = component.get('c.getCertificationName');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        action.setParams({
            certId:sPageURL
        });
        
        action.setCallback(this,function(actionResult){
            component.set('v.village', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    getCertificationRange : function(component, event, helper) {
        var action = component.get('c.getCertificationRG');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        action.setParams({
            certId:sPageURL
        });
        
        action.setCallback(this,function(actionResult){
            component.set('v.certificationPeriod', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    getCertificationComment : function(component, event, helper) {
        var action = component.get('c.getCertificationComm');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        action.setParams({
            certId:sPageURL
        });
        
        action.setCallback(this,function(actionResult){
            component.set('v.overallComment', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    getCurrencyCode : function(component, event, helper) {
        var action = component.get('c.getCurrenCode');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        action.setParams({
            certId:sPageURL
        });
        
        action.setCallback(this,function(actionResult){
            component.set('v.certCurrencyCode', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
	},
    
    convertArrayOfObjectsToCSV : function(component,objectRecords,villageName,certPeriod,totalData,overallC){
        // declare variables
        var csvStringResult, counter, keysAPI, columnDivider, lineDivider,keysLabel;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        //Test Comment
        if (overallC == undefined) {
            overallC = '';
        }        
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\r\n';
        
        //Set Brand and Certification period
        
        csvStringResult = villageName; 
        csvStringResult += lineDivider;
        csvStringResult += $A.get("$Label.c.BP_Certification_Period") + ': '+ certPeriod; 
        csvStringResult += lineDivider;
        csvStringResult += lineDivider;
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keysAPI = ['Trading_Date__c','MRI_Suite_Id__c','Store_Closed__c','Total_NET_SALES__c','Certified_Amount_NetTotal_Input__c','NET_Value_of_Discounts__c','Certified_Amount_Discount_Input__c','Brand_Reported_Amount__c','Certified_Amount__c','Variance_Amount__c','Certification_Comment__c' ];
        keysLabel = [$A.get("$Label.c.BP_Date"),$A.get("$Label.c.BP_Unit"),$A.get("$Label.c.BP_Store_Close"),$A.get("$Label.c.BP_Brand_Sales"),$A.get("$Label.c.BP_Enter_Sales"),$A.get("$Label.c.BP_VIP_Discount"),$A.get("$Label.c.BP_Enter_Certified_VIP_Amount"), $A.get("$Label.c.BP_Reported"),$A.get("$Label.c.BP_Certified_Amount"),$A.get("$Label.c.BP_Variance"),$A.get("$Label.c.BP_Comments") ];
        
        csvStringResult += ''; 
        csvStringResult += keysLabel.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keysAPI) {
                var skey = keysAPI[sTempkey] ;  
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                
                if(objectRecords[i][skey] != undefined){
                    
                    if(skey == 'Store_Closed__c'){
                        if(objectRecords[i][skey]){
                            csvStringResult +=  'Y' ;    
                        }else{
                            csvStringResult +=  'N' ;
                        }
                        
                    }else {
                        csvStringResult +=  objectRecords[i][skey];                        
                    }
                    
                }else{
                    csvStringResult +=  '' ;
                }
                
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        //Add total and overal comment
        
        csvStringResult += lineDivider;     
        csvStringResult += $A.get("$Label.c.BP_Total") + ': '+columnDivider+columnDivider+columnDivider+columnDivider+columnDivider+columnDivider+ columnDivider+totalData[0].Total_Brand_Reported_Amount__c +columnDivider+ totalData[0].Total_Certified_Amount__c +columnDivider+totalData[0].Total_Variance_Amount__c;        
        csvStringResult += lineDivider; 
        csvStringResult += lineDivider;
        csvStringResult += $A.get("$Label.c.BP_Overall_Comment") + ': ' +  overallC;
        
        //Adding \ufeff -> the charset is set up as BOM -> conjugated with UTF-8 allows that accents and strange characters are well visibile in CSV files (when open through Excel)
        return '\ufeff' + csvStringResult;        
    },
    
    submitCertification : function(component, event, helper, isToSubmit){
        var action = component.get('c.submitCertification');
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        var comment = component.get('v.overallComment');
        action.setParams({
            certId:sPageURL,
            overallComment:comment,
            isToSubmit:isToSubmit
        });
        
        action.setCallback(this,function(response){
            var state = response.getState(); 
            if(state === "SUCCESS") {
                if(isToSubmit == false){
                    component.set("v.submitMessageisOpen", true);
                }else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.BP_Success"),
                        message: $A.get("$Label.c.BP_Certification_Success"),
                        type: "success"
                    });
                    toastEvent.fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"
                    });
                    urlEvent.fire();
                }
            } else if(state === "ERROR") {
                
                var errors = response.getError();
                
                if(errors) {
                    
                    if(errors[0] && errors[0].message) {
                        console.log(errors[0]);
                        console.log(errors[0].message);
                        
                        if(errors[0].message == "Error on Submit Update"){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: $A.get("$Label.c.BP_Error"),
                                message: $A.get("$Label.c.BP_Something_Went_Wrong"),
                                duration: "10000",
                                mode: "dismissible",
                                type: "error"
                            });
                            toastEvent.fire();
                        } else if(errors[0].message == 'Please add a Comment to the Certification'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: $A.get("$Label.c.BP_Warning"),
                                message: $A.get("$Label.c.BP_Mandatory_Comment"),
                                duration: "10000",
                                mode: "dismissible",
                                type: "warning"
                            });
                            toastEvent.fire();
                        } else if(errors[0].message == 'Certified Amount must not be empty'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: $A.get("$Label.c.BP_Error"),
                                message: $A.get("$Label.c.BP_Mandatory_Certified_Amount"),
                                duration: "10000",
                                mode: "dismissible",
                                type: "error"
                            });
                            toastEvent.fire();
                        } else if(errors[0].message == 'Please edit a field'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: $A.get("$Label.c.BP_Error"),
                                message: $A.get("$Label.c.BP_Mandatory_Edit"),
                                duration: "10000",
                                mode: "dismissible",
                                type: "error"
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    editRowStatus: function (cmp,id) {
        var data = cmp.get('v.data');
        
        for (var i = 0; i < data.length; i++) {
            console.log(''+ data.length);
            if (data[i].Id == id) {
                if(!data[i].Store_Closed__c){ 
                    data[i].Store_Closed__c = false;   
                }else{
                    data[i].Store_Closed__c = true;  
                    data[i].Certified_Amount_Discount_Input__c = ''; 
                    data[i].Certified_Amount_NetTotal_Input__c= '';
                    data[i].Certified_Amount_Discount__c = '';
                    data[i].Certified_Amount__c= '';     
                    //data[i].Variance_Amount__c= ''; 
                    data[i].Certification_Comment__c= '';                   
                }
                
            }
        }
        cmp.set("v.data", data);
    },
    
    sortHelper: function(component, event, sortFieldName) {
        
        if (sortFieldName == 'Trading_Day_with_date__c'){
            var currentDir = component.get("v.arrowDirection");
            
            if (currentDir == 'arrowdown') {
                component.set("v.arrowDirection", 'arrowup');  
                component.set("v.isAsc", true);
            } else {
                component.set("v.arrowDirection", 'arrowdown');
                component.set("v.isAsc", false);
            }
        } else if (sortFieldName == 'MRI_Suite_Id__c'){
            
            var currentDir = component.get("v.arrowDirectionUnit");
            
            if (currentDir == 'arrowdown') {
                component.set("v.arrowDirectionUnit", 'arrowup');  
                component.set("v.isAsc", true);
            } else {
                component.set("v.arrowDirectionUnit", 'arrowdown');
                component.set("v.isAsc", false);
            }
        } else if (sortFieldName == 'Variance_Amount__c'){
            
            var currentDir = component.get("v.arrowDirectionVariance");
            
            if (currentDir == 'arrowdown') {
                component.set("v.arrowDirectionVariance", 'arrowup');  
                component.set("v.isAsc", true);
            } else {
                component.set("v.arrowDirectionVariance", 'arrowdown');
                component.set("v.isAsc", false);
            }
            
        }
        this.getTheDSRelated(component, event, sortFieldName);
    }
})