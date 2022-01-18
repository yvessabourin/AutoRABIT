({
    init : function(component, event, helper) {
        helper.getOutstandingCertifications(component, event, 'Certification_Submission_Deadline__c');
    },
    
    handleExportClick : function(component, event, helper) {
        
        var id = event.target.getAttribute("data-id");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/certified-sales?id="+ id
        });
        urlEvent.fire();
    },
    
    onColumnSortClick: function(component, event, helper){
        component.set("v.selectedTabsoft", 'certificationDeadline');
        helper.sortHelper(component, event, 'Certification_Submission_Deadline__c');
    }
})