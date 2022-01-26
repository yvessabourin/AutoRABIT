({
    init: function (component, event, helper) {
		helper.getDocuments(component);
    },
    
    gotoDailySale: function(component, event, helper) {
    	helper.gotoDailySale(component, event, helper);
	},
    
    handleExportClick : function(component, event, helper) {
        var id = event.target.getAttribute("data-id");
        
        var action = component.get("c.DownloadAttachment");
        
        action.setParams({
            "DownloadAttachmentID": id
        });
        
        action.setCallback(this,function(response){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": response.getReturnValue()
            });
            
            urlEvent.fire();
        });
        $A.enqueueAction(action);
    }
})