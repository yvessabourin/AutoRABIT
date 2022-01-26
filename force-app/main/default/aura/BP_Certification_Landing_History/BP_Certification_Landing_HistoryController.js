({
	init : function(component, event, helper) {
        helper.getHistory(component);	
	},
    
    handleExportClick : function(component, event, helper) {
        
        var id = event.target.getAttribute("data-id");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/certified-sales?id="+ id
        });
        urlEvent.fire();
    }
})