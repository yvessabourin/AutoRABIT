({
    doInit : function(component, event, helper) {    
        var action = component.get('c.getLink'); 
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        
        action.setCallback(this,function(response)   {
            var state=response.getState();         
            if(state==='SUCCESS'){
                var url = response.getReturnValue();
                if(url == null){ 
                    alert('The format of the Adbuilder is not supported.');
                }
                else{
                    window.open(url, '_blank');
                }
                $A.get("e.force:closeQuickAction").fire();
            }                    
        });
        $A.enqueueAction(action);
    }
})