({
   	init : function(component, event, helper) {		
        helper.helperMethodInit(component);   
	},   
    
    
	BrandTermsAction : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/hfs-brand-terms"
        });
        urlEvent.fire();
	},
    
    BrandOperationalGuide : function(component, event, helper) {
		
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/hfs-operational-guides"
        });
        urlEvent.fire();

	},
    
    
   	BrandSalesEntry : function(component, event, helper) {
		
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/daily-sales"
        });
        urlEvent.fire();
        
	},
    
    BrandSalesCertification : function(component, event, helper) {
		
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/certification-landing-page"
        });
        urlEvent.fire();
        
	},
    
})