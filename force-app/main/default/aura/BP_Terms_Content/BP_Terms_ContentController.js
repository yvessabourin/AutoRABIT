({
    
	init : function(component, event, helper) {		
        helper.helperMethodInit(component);
        
	},
    
    onCheck : function(component, event, helper) {
		var action = component.get("c.getTerms");   

        var checkCmp = component.find("checkbox");
		component.set("v.Buttondisable", ""+!checkCmp.get("v.value"));

        
	},

    handleClick : function (component, event, helper) {
        //alert("You clicked: " + event.getSource().get("v.label"));
        helper.helperMethodSubmit(component, event);
        window.location.reload();
    }
    
})