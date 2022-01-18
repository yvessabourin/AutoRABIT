({
	
	doInit: function(component, event, helper) {
        
        var options = component.get("v.options");
        options.push($A.get("$Label.c.DAILY_SALE_HOME"));
        options.push($A.get("$Label.c.DAILY_SALE_MY_SETTINGS"));
        options.push($A.get("$Label.c.DAILY_SALE_MY_PROFILE"));
        options.push($A.get("$Label.c.DAILY_SALE_LOGOUT"));
        component.set("v.options", options);
        
        var action = component.get("c.getCurrentUser"); // method in the apex class
        action.setCallback(this, function(a) {
            component.set("v.runningUser", a.getReturnValue()); // variable in the component
        });
        $A.enqueueAction(action);
    },

    selected : function(component, event, helper) {

        var selected = event.getParam("selectedItem");
        
        // returns label of selected item
        var selectedLabel = selected.get("v.label");
        
        console.log('selectedLabel ... ' + selectedLabel);
        
        try {
		    var urlEvent;
		    var address;			
			switch(selectedLabel) {

			    case $A.get("$Label.c.DAILY_SALE_HOME"):
				    urlEvent = $A.get("e.force:navigateToURL");
				    urlEvent.setParams({
				      "url": "/"
				    });
				    urlEvent.fire();
			        break;
			    case $A.get("$Label.c.DAILY_SALE_MY_PROFILE"):
				    urlEvent = $A.get("e.force:navigateToURL");
				    address = "/profile/" + component.get("v.runningUser.Id");
				    console.log('address ' + address);
				    urlEvent.setParams({
				      "url": address,
				      "isredirect" :false			       
				    });
				    urlEvent.fire();
			        break;
			    case $A.get("$Label.c.DAILY_SALE_MY_SETTINGS"):
				    urlEvent = $A.get("e.force:navigateToURL");
				    address = "/settings/" + component.get("v.runningUser.Id");
				    console.log('address ' + address);				    
				    urlEvent.setParams({
				      "url": address,
				      "isredirect" :false			       
				    });
				    urlEvent.fire();
			        break;
			    case $A.get("$Label.c.DAILY_SALE_LOGOUT"):
				   
				    var urlEvent = $A.get("e.force:navigateToURL");
				    var portalUrl = $A.get("$Label.c.DAILY_SALE_PORTAL_URL");
				    var unencoded = portalUrl + "/CommunitiesLanding";
				    //address = "/../secur/logout.jsp?retUrl=" + encodeURIComponent(unencoded).replace(/\+/g,"%2F");
				    
				    address = portalUrl + "/s/login/?language=en_GB";
				    window.location.replace(address);
				    
			    /*
				    urlEvent.setParams({
				      "url": address,
				      "isredirect" :false
				    });
				    urlEvent.fire();
			    */    
			        
					break;
			    default:
		    		break;
			}
		} catch (e) {
			console.log(e.message);
		
		}	        
    },
        
	handleMenuClick : function(component, event, helper) {
 
        
        console.log('handleMenuClick fired') ;
        

		
	}
})