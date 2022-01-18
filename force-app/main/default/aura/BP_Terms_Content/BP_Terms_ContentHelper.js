({
	helperMethodInit : function(component) {		
        var action = component.get("c.getTerms");         
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.Terms_S",response.getReturnValue());                
                console.log('eliminar');
            }else {
                //ERRO
                console.log("Failed with state: " + response.getError()[0].message);
			}
        });
        // Send action off to be executed
        $A.enqueueAction(action);  
        
        var action2 = component.get("c.getTermsUser");         
        // Add callback behavior for when response is received
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if(response.getReturnValue() == null){
                    component.set("v.Terms_Approver",' Terms were not approved yet!');   
                    //Standard value is true (Because of loading time), so we need to set it to false
                    component.set("v.Buttondisable", "false");
                    component.set("v.Checkdisable", "false");
                }else{                    
                    component.set("v.Terms_Approver",response.getReturnValue());  
                    component.set("v.Buttondisable", "true");
                    component.set("v.Checkdisable", "true");
                }                                 
                
            }else {
                //ERRO
                console.log("Failed with state: " + response.getError()[0].message);            
			}
        });
        // Send action off to be executed
        $A.enqueueAction(action2);     
        
        
	},
    
   	helperMethodSubmit : function(component, event) {		
        var action = component.get("c.getSubmit");         
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
        		component.set("v.Terms_S",response.getReturnValue());                
                console.log('eliminar');
                //$A.get('e.force:refreshView';).fire();
            }else {
                //ERRO
                console.log("Failed with state: " + response.getError()[0].message);
			}            
        });
        // Send action off to be executed
        $A.enqueueAction(action);  
	}
    
    
})