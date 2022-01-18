({    
	onRender : function(component, event, helper) {  
        
         if (confirm('Are you sure you want to share this report with the business?')) {
            
    		var action = component.get("c.share");
             
            action.setParams({
            theid : component.get("v.recordId")
            });
             
        	action.setCallback(this, function(response){
            var name = response.getState();
                
            if (response.getReturnValue() == "Success") {
               alert('You have shared the report, please press ok to close the window');
               helper.exitpage(component, event);
            }
            else if (response.getReturnValue() == "This Visit has already been shared") {
            alert(response.getReturnValue() + ', if you wish to re-share please contact your System Administrator');
       		helper.exitpage(component, event);
        	}   
            else {
                alert(response.getReturnValue() + 'Please contact you System Administrator');
       			helper.exitpage(component, event);  
            }
        });
     	$A.enqueueAction(action);
        } 
        else {
            
       		helper.exitpage(component, event);
        }     
    }      
})