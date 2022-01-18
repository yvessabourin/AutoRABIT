({
	editRecord : function(component) {
		console.log('in the zone...');
        console.log(component.get("v.recordId"));
		       
        var editRecordEvent = $A.get("e.force:editRecord");
        
        console.log(component.get("v.recordId"));
        
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId")            
        });

        editRecordEvent.fire();  
    
    } ,
    
	gotoUrl : function(component) {

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "../../apex/DailySalesCommunityEdit?Id=" + component.get("v.recordId") 
        });
        urlEvent.fire();          
  
    
    }    
})