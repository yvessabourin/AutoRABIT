({
    doInit : function(component, event) {
        var action = component.get("c.findCampaigns");
        action.setCallback(this, function(a) {
            component.set("v.campaigns", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
	searchKeyChange: function(component, event) {
    var searchKey = event.getParam("searchKey");
    var action = component.get("c.findCampaigns");
    action.setParams({
      "searchKey": searchKey
    });
    action.setCallback(this, function(a) {
        component.set("v.campaigns", a.getReturnValue());
    });
    $A.enqueueAction(action);
    
	},

	hideSpinner : function (component, event, helper) {
       var spinner = component.find('spinner');
       var evt = spinner.get("e.toggle");
       evt.setParams({ isVisible : false });
       evt.fire();    
    },
    
    listItemSelected: function(component, event){
    	// show spinner
		var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
	}
})