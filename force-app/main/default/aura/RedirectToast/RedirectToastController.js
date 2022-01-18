({
    Refresh : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var recordId = pageRef.state.c__recordId; 
        
        component.find("navService").navigate({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Marketing_Activity__c',
                actionName: 'view'
                
            }
            
        });
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Checked!",
            //"message": "Please select the Creative Agency Access To Salesforce",
            message: $A.get("$Label.c.Toast_Message_Migration_LC"),
            type: 'Error',
            // mode: 'pester'
            
        });
        
        toastEvent.fire();
        $A.get('e.force:closeQuickAction').fire();
        helper.navService(component, pageReference);
        helper.delayedRefresh();  
        
        
        
    }
    
    
})