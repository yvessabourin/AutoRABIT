({
     exitpage :  function(component, event){        
         if( (typeof sforce != 'undefined') && (sforce != null) ) {  
             var id = component.get("v.recordId");
             sforce.one.navigateToSObject(id);                      
         }
         else{
          	 window.close();
        }
  	} 
})