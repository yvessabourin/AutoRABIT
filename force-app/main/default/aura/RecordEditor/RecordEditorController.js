({
    doInit : function(component){
 		var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP'){
            var theButton = component.find("theButton");
        	$A.util.toggleClass(theButton, "hide");
        }   
	},
 
    doEdit : function(component, event, helper) {

        var device = $A.get("$Browser.formFactor");

        if (device == 'TABLET'){ 
        	helper.editRecord(component);
        } else {
			helper.gotoUrl(component);            
        }

        
    }
    
})