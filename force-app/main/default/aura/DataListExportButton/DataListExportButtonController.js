({
	doInit : function(component, event, helper){

		var device = $A.get("$Browser.formFactor");

		
        if (device == 'DESKTOP'){
        	component.set("v.desktop", true);
        } else {
        	component.set("v.desktop", false);
            var theButton = component.find("exportBtn");
        	$A.util.toggleClass(theButton, "hide");
        }   	
	
	},

    doFilters : function(component, event, helper){

    	var opts = event.getParam('filterOptions');
    	var label = event.getParam('label');
    	if (!label){
    		label = '...';
    	}
    	var caller = event.getSource();
    	component.set("v.callerComponent", caller);
    	
    	console.log(' @@@@@@@@@@@@@@@@@@@@@@@@@   caller  ' + caller);
console.log('@@@@ opts    ' + opts);    	
        //if (opts) {
            component.set("v.filterOptions", opts);
        //}

        if(opts != ','){
        	var filterOptions = opts;
        }
    	if (filterOptions){
    		$A.createComponent(
	            "lightning:select",
	            {
	                "name": "filterOptions",
	                "aura:id": "filterOptions",
	                "label": label,
	                "onchange": component.getReference("c.updateList")
	            },
	            function(newList, status, errorMessage){
console.log('@@@@   status ... ' + status);	            
	                //Add the new button to the body array
	                if (status === "SUCCESS") {
	                    var body = component.get("v.body");
	                    helper.loadOptions(newList, event, helper, filterOptions);	                    
	                    body.push(newList);
	                    component.set("v.body", body);
	                    
	                }
	                else if (status === "INCOMPLETE") {
	                    console.log("No response from server or client is offline.")
	                    // Show offline error
	                }
	                else if (status === "ERROR") {
	                    console.log("Error: " + errorMessage);
	                    // Show error message
	                }
	            }
	            
	            
	        );    		
    		
    	}
    	
    },
    
    handleExportClick : function(component, event, helper) {
        
        helper.buttonDownExport(component,event, helper);
        
    },

    handleEmailClick : function(component, event, helper) {
        
        helper.buttonDownEmail(component,event, helper);
        
    },
        
    doEmail : function(component, event, helper) {

    	var params = event.getParam('arguments');
        if (params) {
            var jsonData = params.jsonData;
            var reportTitle = params.reportTitle;
            var showLabel = params.showLabel;
           
            helper.JSONToCSVConvertor(component, jsonData, reportTitle, showLabel, true);

        }      
    },
    
    doExport : function(component, event, helper) {
    
    	var params = event.getParam('arguments');
        if (params) {
            var jsonData = params.jsonData;
            var reportTitle = params.reportTitle;
            var showLabel = params.showLabel;
           
            helper.JSONToCSVConvertor(component, jsonData, reportTitle, showLabel);

        }    
    
    },
    
    updateList : function(component, event, helper){

    	//var selected = component.find("filterOptions"); // Salesforce bug, Can't find dynamic components by aura:id (as @ 03/01/2017)
    	var selected = component.find({ instancesOf : "lightning:select" })[0]; //workaround to find component
    	selected = selected.get("v.value");

    	var caller = component.get("v.callerComponent");
        caller.set("v.weekFilter", selected);
		caller.filterRecords(selected);

    }
    
})