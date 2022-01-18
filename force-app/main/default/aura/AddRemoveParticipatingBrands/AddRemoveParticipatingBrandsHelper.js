({
    getTableColumns : function(component){
        var cols = [
            {label: "Brand", fieldName: "vpUrl", type:"url", resizable:true, wrapText:true, typeAttributes: { label: {fieldName:"vpName"}, tooltip:"Click to View (New tab)", target:"_blank"} },
            {label: "Status", fieldName: "status", type:"text", resizable:true, wrapText:true},
            {label: "Primary Contact", fieldName: "primaryMarketingContact", type:"text", resizable:true, wrapText:true},
            {label: "Pre-Approvals", fieldName: "preApproval", type:"text", resizable:true, wrapText:true},
            {label: "Pre-Approval Expiry", fieldName: "approvalEndDate", type:"text", resizable:true, wrapText:true},
            {label: "Approval Comments", fieldName: "preApproval", type:"text", resizable:true, wrapText:true},
            {label: "Marketing Manager", fieldName: "marketingManager", type:"text", resizable:true, wrapText:true},
            {label: "Expected Exit Date", fieldName: "brandExitDate", type:"text", resizable:true, wrapText:true},
            {label: "Market Position", fieldName: "marketPosition", type:"text", resizable:true, wrapText:true},
            {label: "Group Marketing Brand", fieldName: "groupMarketing", type:"boolean", resizable:true, wrapText:true},
            {label: "Department", fieldName: "department", type:"text", resizable:true, wrapText:true},
            {label: "Village Presence Status", fieldName: "vpStatus", type:"text", resizable:true, wrapText:true}
        ];
        component.set("v.columns", cols);    
    },
    getLabels : function(component){
        var action = component.get("c.getMarketingActivityName");
        action.setParams({ recordId : component.get("v.recId") });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.marketingActivityName", response.getReturnValue()); 
            }
      	});
        
        $A.enqueueAction(action);
	},
    loadRecords : function(component, helper) {
        var action = component.get("c.getPotentialParticipatingBrands");
        action.setParams({
            recordId : component.get("v.recId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                var allRecords = response.getReturnValue();
                var selectedRows = [];
                var selectedRowsId = [];

                allRecords.forEach(value => {
                    if(value.isSelected){
                        selectedRows.push(value);
                        selectedRowsId.push(value.vpId);
                    }
                });
                component.set("v.data", allRecords);
                component.set("v.isLoading", false);
                component.set("v.selectedRows", selectedRows);
                component.set("v.selectedRowsId", selectedRowsId);
            }else{
                var errors = response.getError();
                var message = "Error: Unknown error";
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = "Error: "+errors[0].message;
                }
                this.toastMsg('error', message);  
                component.set("v.isLoading", false);
                helper.redirectToMassEditBrands(component, event, helper);
                console.log("Error: "+message);
            }
        });
        $A.enqueueAction(action);
    },
    saveSelectedBrands: function(component, event, helper){
        if(component.get("v.isSaving")) {
            return;
        }
        
        component.set("v.isSaving", true);
        var action = component.get("c.savePotentialBrands");
        action.setParams({
            "recordId" : component.get('v.recId'),
            "selectedListJSON" : JSON.stringify(component.get('v.selectedRows'))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                if (response.getReturnValue() === null){  
                    this.toastMsg('success', 'Records Saved Successfully.');  
                    $A.get('e.force:refreshView').fire();
                    helper.redirectToMassEditBrands(component, event, helper);
                    component.set("v.isSaving", false);
                }
                else {   
                    this.toastMsg('error', response.getReturnValue());
                    component.set("v.isSaving", false);
                }
            }
            else {   
                this.toastMsg('error', 'Something went wrong. Contact your system administrator.');
                component.set("v.isSaving", false);
            }
        });
        $A.enqueueAction(action);
    },
    toastMsg : function(strType, strMessage) {  
        var showToast = $A.get("e.force:showToast");   
        showToast.setParams({   
            message : strMessage,  
            type : strType,  
            mode : 'pester'  
        });   
        showToast.fire();   
    },
    redirectToMassEditBrands: function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:massEditBrandActivities",
            componentAttributes: {
                recId : component.get("v.recId")
            },
            isredirect: true
        });
        evt.fire();
    }
})