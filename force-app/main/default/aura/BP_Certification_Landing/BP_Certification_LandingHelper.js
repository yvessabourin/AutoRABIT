({
    getOutstandingCertifications : function(component, event, sortField) {
        
        var action = component.get('c.getOutCertifications');
        action.setParams({
            'sortField': sortField,
            'isAsc':component.get("v.isAsc")
        });
        
        action.setCallback(this,function(actionResult){
            component.set('v.outCertifications', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);       
    },
    
    sortHelper: function(component, event, sortFieldName) {
        var currentDir = component.get("v.arrowDirection");
        if (currentDir == 'arrowdown') {
            component.set("v.arrowDirection", 'arrowup');
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        
        this.getOutstandingCertifications(component, event, sortFieldName);
    },
})