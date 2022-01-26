({    
    gotoDailySale: function(component, event, helper) {
		var recId = event.getSource().get("v.value");     
        var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
  			"recordId": recId,
  			"slideDevName": "detail"
		});
		navEvt.fire();
    },
    
    getDocuments: function(component){
        var action = component.get('c.getDocuments');
        action.setCallback(this,function(actionResult){
            component.set('v.theDocuments', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
})