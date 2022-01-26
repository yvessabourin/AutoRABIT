({
	getHistory : function(component) {
		
        var action = component.get('c.getHistory');
        action.setCallback(this,function(actionResult){
            component.set('v.History', actionResult.getReturnValue());
        });
        
        $A.enqueueAction(action);     
        
	}
})