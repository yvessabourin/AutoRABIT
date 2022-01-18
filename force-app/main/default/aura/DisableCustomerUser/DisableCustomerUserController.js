({

    doInit : function(component){

		var action = component.get("c.getCustomerStatus");

        action.setParams({
            "contactId" : component.get("v.recordId"),
        });
        
        action.setCallback(this, function(data) {			
            
            console.log('value returned ....    ' + data.getReturnValue());
			var status = data.getReturnValue();
            var msg = '';
            var btn;
            
            if (status == 'Active'){
                btn = component.find("btnEnable");
                btn.set("v.disabled",true);
                msg = $A.get("$Label.c.DAILY_SALE_USER_ACTIVE"); //'Contact is currently an Active User';
                component.set("v.customerStatus", msg);
            }
            if (status == 'InActive'){
                btn = component.find("btnDisable");
                btn.set("v.disabled",true);
 				msg = $A.get("$Label.c.DAILY_SALE_USER_INACTIVE"); //'Contact is currently not an Active User';
				component.set("v.customerStatus", msg);                
            }
            if (status == 'Null'){
                //btn = component.find("btnEnable");
                //btn.set("v.disabled",true);
				//var btn2 = component.find("btnDisable");
                //btn2.set("v.disabled",true);
 				msg = $A.get("$Label.c.DAILY_SALE_USER_NOT_ENABLED"); //Contact is not currently a valid user. Please select the Enable Customer User option if you wish to provide portal access to this contact.                
                // Display the total in a "toast" status message
                var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                    "title": "Disable/Enable User ",
                    "message": msg,
                    "duration" : "20000",
                    "type" : "info"                     
                });
                resultsToast.fire();
    
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();     
            }
            
          

        });
        $A.enqueueAction(action);                
        
    },    
    
    disableUser : function(component, event, helper) {
		
        console.log(component.get("v.recordId"));

        var action = component.get("c.updateCustomerUser");

        action.setParams({
            "contactId" : component.get("v.recordId"),
            "activeFlg" : false
        });
        
        action.setCallback(this, function(data) {			
            
            console.log('value returned ....    ' + data.getReturnValue());

			// Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
        	resultsToast.setParams({
            "title": "Disable User ",
            "message": data.getReturnValue()
        	});
        	resultsToast.fire();

        	// Close the action panel
        	var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();            

        });
        $A.enqueueAction(action);        
	},

    enableUser : function(component, event, helper) {
		
        console.log(component.get("v.recordId"));

        var action = component.get("c.updateCustomerUser");

        action.setParams({
            "contactId" : component.get("v.recordId"),
            "activeFlg" : true
        });
        
        action.setCallback(this, function(data) {			
            
            console.log('value returned ....    ' + data.getReturnValue());

			// Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
        	resultsToast.setParams({
            "title": "Disable User ",
            "message": data.getReturnValue()
        	});
        	resultsToast.fire();

        	// Close the action panel
        	var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();            

        });
        $A.enqueueAction(action);        
	},


	handleCancel: function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
    }
    
})