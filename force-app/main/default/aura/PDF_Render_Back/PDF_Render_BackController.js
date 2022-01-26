({
    backFunction : function(component, event, helper) {
        
        var sPageURL = decodeURIComponent(window.location.search.substring(4));
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/certified-sales?id=" + sPageURL
        });
        urlEvent.fire();
        
    }
})