({
	helperMethodInit : function(component) {
		
        var action = component.get("c.getDailySalesPermission");         
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.isDailySalesActive",response.getReturnValue());  
            }else {
                //ERRO
                console.log("Failed with state: " + response.getError()[0].message);            
			}
        });
        // Send action off to be executed
        $A.enqueueAction(action);  
        
       	var hfsaction = component.get("c.getHFSPermission");         
        // Add callback behavior for when response is received
        hfsaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.isHFSActive",response.getReturnValue());  
            }else {
                //ERRO
                console.log("Failed with state: " + response.getError()[0].message);            
			}
        });
        // Send action off to be executed
        $A.enqueueAction(hfsaction);    
        
        var certaction = component.get("c.getCertPermission");         
        // Add callback behavior for when response is received
        certaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.isCertifiedActive",response.getReturnValue());  
            }else {
                //ERRO
                console.log("Failed with state: " + response.getError()[0].message);            
			}
        });
        // Send action off to be executed
        $A.enqueueAction(certaction);    
        
        
        
	}
})