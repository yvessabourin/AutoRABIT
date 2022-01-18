({
    doInit : function(component, event, helper) {
        if(component.get("v.recId") == null){ 
            component.set("v.recId", component.get("v.pageReference").state.c__recordId);
        }
        component.set("v.isLoading", true);
        helper.getLabels(component);
        helper.getTableColumns(component);
        helper.loadRecords(component, helper);
    },
     handleSelected: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows", selectedRows);
        
        var selectedRowsId = [];
        selectedRows.forEach(row => selectedRowsId.push(row.vpId));
        component.set("v.selectedRowsId", selectedRowsId);        
    },
    handleCancel: function (component, event, helper) {
        helper.redirectToMassEditBrands(component, event, helper);
    },
    handleSave: function (component, event, helper) {
        helper.saveSelectedBrands(component, event, helper);
    }
})