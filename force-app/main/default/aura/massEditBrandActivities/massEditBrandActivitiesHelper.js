({   
    getTableColumns : function(component){
        var cols = [
            {label: "Brand", fieldName: "Village_Presence__c", type:"url", resizable:true, wrapText:true,
             typeAttributes: { label: {fieldName:"Village_Presence__r_Name"}, tooltip:"Click to View (New tab)", target:"_blank"} },
            {label: "Status", type:"button", editable:true, initialWidth: 200,
             typeAttributes: { iconName: 'utility:edit', iconPosition: 'right', name: 'editStatus',  title: 'Edit', label: {fieldName:"Status__c"}}, 
             cellAttributes: { class: { fieldName: 'backgroundCellClass' }} },            
            {label: "Discount", fieldName: "Discount__c", type:"boolean", editable:true},            
            {label: "Discount %", fieldName: "Discount_Percentage__c", type:"text", editable:true},
            {label: "Min Purchase", fieldName: "Minimum_Purchase__c", type:"boolean", editable:true},            
            {label: "Min Purchase Amount", fieldName: "Minimum_Purchase_Amount__c", type:"text", editable:true},
            {label: "Gift With Purchase", fieldName: "Gift_With_Purchase__c", type:"boolean", editable:true},            
            {label: "Gift With Purchase Type", fieldName: "Gift_With_Purchase_Type__c", type:"text", editable:true},
            {label: "Feature Details", fieldName: "Feature_Details__c", type:"text", editable:true},
        ];
        component.set("v.columns", cols);    
    },
	getLabels: function(component){
    	var action = component.get("c.getMarketingActivityName");
        var recID = component.get("v.recId")+'';
        var rec18ID = recID;

            if (recID.length == 15) {
                var s = "";
                for (var i = 0; i < 3; i++) {
                    var f = 0;
                    for (var j = 0; j < 5; j++) {
                        var c = recID.charAt(i * 5 + j);
                        if (c >= "A" && c <= "Z"){
                            f += 1 << j;
                        }
                    }
                    s += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(f);
                }
                rec18ID = recID + s;
            } 
            
        action.setParams({ recordId : rec18ID });
        action.setCallback(this,function(response){
        	if(response.getState() === "SUCCESS"){
    			component.set("v.marketingActivityName", response.getReturnValue()); 
            }
        });
            
        $A.enqueueAction(action);
    },
    getPicklistValues : function(component) {
        var actionStatus = component.get("c.getPicklistValues");
        actionStatus.setParams({
            objectAPIName: "Participating_Brand__c",
            fieldAPIName: "Status__c",
            notRequired: true
        });
        actionStatus.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                var values = [];
                Object.entries(response.getReturnValue()).forEach(([key, value]) => values.push({label:key,value:value}));
                component.set('v.statusOptionsTable', values);
        		component.set('v.statusOptions', values.slice(1));
            }
            else{
                var errors = response.getError();
                var message = "Error: Unknown error";
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = "Error: " + errors[0].message;
                }
                component.set("v.error", response.getError());
                console.log("Error: "+message);
            }
        });
        $A.enqueueAction(actionStatus);
        
        var booleanOpts = [];
        booleanOpts.push({label:'',value:''});
        booleanOpts.push({label:'No',value:'false'});
        booleanOpts.push({label:'Yes',value:'true'});
        component.set('v.booleanOptions', booleanOpts);
    },
                    
    loadRecords : function(component) {
        var action = component.get("c.getParticipatingBrands");
        action.setParams({
            recordId : component.get("v.recId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                var allRecords = response.getReturnValue();
                var originalData = [];
                allRecords.forEach(value => {
                    value.Village_Presence__c = '/' + value.Village_Presence__c;
                    value.Village_Presence__r_Name = value.Village_Presence__r.Name;
                    value.Discount__c = value.Discount__c == 'Yes';
                    value.Minimum_Purchase__c = value.Minimum_Purchase__c == 'Yes';
                    value.Gift_With_Purchase__c = value.Gift_With_Purchase__c == 'Yes';
                });
                component.set("v.data", allRecords);
                component.set("v.isLoading", false);
            }else{
                var errors = response.getError();
                var message = "Error: Unknown error";
                if(errors && Array.isArray(errors) && errors.length > 0){
                    message = "Error: "+errors[0].message;
                }
                this.toastMsg('error', message);  
                console.log("Error: "+message);
            }
        });
        $A.enqueueAction(action);
    },
	closeModal : function(component,event,helper){
        component.set('v.statusValue', '');
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    openEditStatus : function(component, row) {  
        component.set('v.statusValue', row.Status__c);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
	saveEdition : function(component, event) {                  
        var action = component.get("c.updateParticipantBrands");
        action.setParams({
            "partBrands" : event.getParam('draftValues'),
            "statusChangedRows" : component.get('v.statusChangedRows')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                if (response.getReturnValue() === null){  
                    this.toastMsg('success', 'Records Saved Successfully.');  
                    $A.get('e.force:refreshView').fire();
                }
                else {   
                    this.toastMsg('error', response.getReturnValue());  
                }
            }
            else {   
                this.toastMsg('error', 'Something went wrong. Contact your system administrator.');  
            }
        });
        $A.enqueueAction(action);
    },
	saveStatusChange: function(component, event, helper){
    	var openRow = component.get('v.openRow');
        
        var draftValuesMap = component.get('v.draftValuesMap');
        var rowDraft = draftValuesMap[openRow.Id];
        if(rowDraft == null){ rowDraft = {}; }
        rowDraft["Id"] = openRow.Id;
        rowDraft.Status__c = component.get('v.statusValue');
        draftValuesMap[openRow.Id] = rowDraft;
        component.set('v.draftValuesMap', draftValuesMap);
        var draftValuesVar = [];
        for(var row in draftValuesMap){
            draftValuesVar.push(draftValuesMap[row]);
        }
        component.set('v.draftValues', draftValuesVar);
        
        var rows = component.get('v.data');
        var rowIndex = rows.map(function (row) { return row.Id; }).indexOf(openRow.Id);
        rows[rowIndex].Status__c = rowDraft.Status__c;
        rows[rowIndex].backgroundCellClass = 'backgroundCellChanged';
        component.set('v.data', rows);
        
        var statusChangedRows = component.get('v.statusChangedRows');
        statusChangedRows[openRow.Id] = component.get('v.statusValue');
        component.set('v.statusChangedRows', statusChangedRows);
        
    },
	processCellChange: function(component, event, helper){
        var draftValuesMap = component.get('v.draftValuesMap');
        var rowChanged = event.getParam('draftValues');
        
        for (const row of rowChanged) {
            for(const key in row){
                var aux = draftValuesMap[row.Id];
                if(aux == null){ aux = {}; }
                aux[key] = row[key];
                draftValuesMap[row.Id] = aux;
            }
        }

        component.set('v.draftValuesMap', draftValuesMap);
        var draftValuesVar = [];
        for(var row in draftValuesMap){
            draftValuesVar.push(draftValuesMap[row]);
        }
        component.set('v.draftValues', draftValuesVar);
    },
	applyToSelected: function(component, event, helper){
        var selectedRows = component.get("v.selectedRows");
        if(selectedRows.length == 0) return;
        
        var draftValuesMap = component.get('v.draftValuesMap');
        var rows = component.get('v.data');
        var statusChangedRows = component.get('v.statusChangedRows');

        var status = component.find("status").get("v.value");
        var discountOpts = component.find("discountOpts").get("v.value");
        var discountVal = component.find("discountVal").get("v.value");
        var minimumPurchaseOpts = component.find("minimumPurchaseOpts").get("v.value");
        var minimumPurchaseVal = component.find("minimumPurchaseVal").get("v.value");
        var giftWithPurchaseOpts = component.find("giftWithPurchaseOpts").get("v.value");
        var giftWithPurchaseVal = component.find("giftWithPurchaseVal").get("v.value");
        var featureDetailsVal = component.find("featureDetailsVal").get("v.value");

        selectedRows.forEach(row => {
            var rowDraft = draftValuesMap[row.Id];
            if(rowDraft == null){ rowDraft = {}; }
            rowDraft["Id"] = row.Id;                 
            if(status != null && status != ''){ 
            	row.Status__c = status;
            	row.backgroundCellClass = 'backgroundCellChanged';
            	rowDraft.Status__c = status;
                rowDraft.backgroundCellClass = 'backgroundCellChanged';

                var rowIndex = rows.map(function (rowVar) { return rowVar.Id; }).indexOf(row.Id);
                rows[rowIndex].Status__c = rowDraft.Status__c;
                rows[rowIndex].backgroundCellClass = 'backgroundCellChanged';
                statusChangedRows[row.Id] = status;
        	}
            if(discountOpts != ''){ 
                row.Discount__c = discountOpts == 'true'; 
                rowDraft.Discount__c = discountOpts == 'true'; 
            }
            if(discountVal != ""){ 
                row.Discount_Percentage__c = discountVal; 
                rowDraft.Discount_Percentage__c = discountVal; 
            }
            if(minimumPurchaseOpts != ""){ 
                row.Minimum_Purchase__c = minimumPurchaseOpts == 'true'; 
                rowDraft.Minimum_Purchase__c = minimumPurchaseOpts == 'true'; 
            }
            if(minimumPurchaseVal != ""){ 
                row.Minimum_Purchase_Amount__c = minimumPurchaseVal;                
                rowDraft.Minimum_Purchase_Amount__c = minimumPurchaseVal;
            }
            if(giftWithPurchaseOpts != ""){ 
                row.Gift_With_Purchase__c = giftWithPurchaseOpts == 'true'; 
                rowDraft.Gift_With_Purchase__c = giftWithPurchaseOpts == 'true'; 
            }
            if(giftWithPurchaseVal != ""){ 
                row.Gift_With_Purchase_Type__c = giftWithPurchaseVal; 
                rowDraft.Gift_With_Purchase_Type__c = giftWithPurchaseVal; 
            }
            if(featureDetailsVal != ""){ 
                row.Feature_Details__c = featureDetailsVal; 
                rowDraft.Feature_Details__c = featureDetailsVal; 
            }
            
            draftValuesMap[row.Id] = rowDraft;
        });
        component.set("v.selectedRows", selectedRows);
        component.set('v.draftValuesMap', draftValuesMap);
		component.set('v.data', rows);
        component.set('v.statusChangedRows', statusChangedRows);
                    
		var draftValuesVar = [];
        for(var row in draftValuesMap){
            draftValuesVar.push(draftValuesMap[row]);
        }
        component.set('v.draftValues', draftValuesVar);
        component.find("status").set("v.value", '');
        component.find("discountOpts").set("v.value", '');
        component.find("discountVal").set("v.value", '');
        component.find("minimumPurchaseOpts").set("v.value", '');
        component.find("minimumPurchaseVal").set("v.value", '');
        component.find("giftWithPurchaseOpts").set("v.value", '');
        component.find("giftWithPurchaseVal").set("v.value", '');
        component.find("featureDetailsVal").set("v.value", '');
    },
    toastMsg : function(strType, strMessage) {  
         var showToast = $A.get("e.force:showToast");   
         showToast.setParams({   
             message : strMessage,  
             type : strType,  
             mode : 'pester'  
         });   
         showToast.fire();   
     }  
})