({
	delayedRefresh : function(milliseconds){
		  let ms = milliseconds || 500;
         window.setTimeout($A.getCallback(function(){
              $A.get('e.force:refreshView').fire();
         }), ms);
	},
    
    navService : function(component, pageReference, replace){
    let _replace = replace || false;
    let navService  = component.getSuper().find('navigationService');
    navService.navigate(pageReference, _replace);

}
})