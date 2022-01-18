({
    doInit : function(component, event, helper) {
        if(component.get("v.recId") == null){ 
            component.set("v.recId", component.get("v.pageReference").state.c__recordId);
        }
        component.set("v.isLoading", true);
        component.set("v.draftValuesMap", new Map());
        helper.getLabels(component);
        helper.getPicklistValues(component);
        helper.getTableColumns(component);
        helper.loadRecords(component);
    },
    handleSaveEdition: function (component, event, helper) {
        helper.saveEdition(component, event);
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set('v.openRow', row);
        switch (action.name) {
            case 'editStatus':
                helper.openEditStatus(component, row);
                break;
        }
    },
    handleCancelModal: function (component, event, helper) {
        helper.closeModal(component, event, helper);
    },
    handleSaveModal: function (component, event, helper) {
        helper.saveStatusChange(component, event, helper);
        helper.closeModal(component, event, helper);
    },
    handleCellChange: function (component, event, helper) {
        helper.processCellChange(component, event, helper);
    },
    handleCancel: function (component, event, helper) {
        component.set("v.draftValuesMap", new Map());
        component.set("v.draftValues", []);
        component.set("v.isLoading", true);
        component.set("v.selectedRows", []);
        component.set("v.selectedRowsId", []);
        component.set("v.statusChangedRows", {});
        component.set("v.cannotApplySelect", true);
        helper.loadRecords(component);
    },
    handleSelected: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows", selectedRows);
        component.set("v.cannotApplySelect", selectedRows.length == 0);
        
        var selectedRowsId = [];
        selectedRows.forEach(row => selectedRowsId.push(row.Id));
        component.set("v.selectedRowsId", selectedRowsId);        
    },
    handleApplyToSelected: function(component, event, helper){
        helper.applyToSelected(component, event, helper);
    },
    handleAddRemove: function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddRemoveParticipatingBrands",
            componentAttributes: {
                recId : component.get("v.recId")
            },
            isredirect: true
        });
        evt.fire();
    },
    handleClose: function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recId")
        });
        navEvt.fire();
    }
})