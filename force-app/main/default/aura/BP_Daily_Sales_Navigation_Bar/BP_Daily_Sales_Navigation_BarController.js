({
	navToDailySales : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/daily-sales"
        });
        urlEvent.fire();
	},
    
    navToConfirm : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/daily-sales?tabset-000aa=2"
        });
        urlEvent.fire();
	},
    
    navToHistory : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/daily-sales?tabset-000aa=3"
        });
        urlEvent.fire();
	},

    
})