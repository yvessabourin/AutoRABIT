({
    searchKeyChange: function(component, event, helper) {

        //var newValue = event.getParam("value");
        //var oldValue = event.getParam("oldValue");
        //alert("value changed from '" + oldValue + "' to '" + newValue + "'");
        
        var searchString = document.querySelector('.searchKey').value;
        //var searchString = event.target.value;       
        if (searchString.length > 0){
            if (searchString.length > 2){
                if (searchString.substring(0,3) == '701'){
                    if (searchString.length < 15){
                        // do nothing
                        return;
                    }
                }
            }
        }
        
        var myEvent = $A.get("e.c:SearchKeyChange");
        //myEvent.setParams({"searchKey": event.target.value});
        myEvent.setParams({"searchKey": document.querySelector('.searchKey').value });
        myEvent.fire(); 
    },
    
	clearText: function(component) {
        component.set("v.searchKey", "");
        var myEvent = $A.get("e.c:SearchKeyChange");
        myEvent.setParams({"searchKey": "" });
        myEvent.fire();
    }    
})