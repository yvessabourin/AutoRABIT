({
    doInit : function(component, event, helper) {
    	
    	var usrAction = component.get("c.getConfirmUser");
		usrAction.setCallback(this, function(a) {
                var confirmUser = a.getReturnValue();        
                component.set("v.confirmUser", confirmUser);
                 console.log('v.confirmUser ' + confirmUser);
            });
    	$A.enqueueAction(usrAction);    
    
        var action = component.get("c.getDailySalesList");
        var device = $A.get("$Browser.formFactor");
        
        if(component.get("v.confirmList")){
            component.set("v.currentList", "Confirm List");
        }
        action.setParams({
            "fieldSetName" : component.get("v.fieldSetName"),
            "listViewName" : component.get("v.listViewName"),
            "confirmList" : component.get("v.confirmList"),
            "device" : device
        });
        
        var sortColumn = component.get("v.sortColumn");
        var sortDirection = component.get("v.sortDirection");
        var storeFilter = component.get("v.storeFilter");
        
        var tableTitle = component.get("v.tableTitle");
        var idx = tableTitle.indexOf('$Label.');
        if (idx > -1){
            component.set("v.tableTitle", '');
            tableTitle = tableTitle.substring(7);
			console.log('@@@ tableTitle  ' + tableTitle); 
			var action1 = component.get("c.getLabel"); 
            action1.setParams({
                "labelReference" : tableTitle,
            });
            action1.setCallback(this, function(a) {
                var dynamicLabel = a.getReturnValue();        
                component.set("v.tableTitle", dynamicLabel);
            });
        	$A.enqueueAction(action1);
        }
        
      
        action.setCallback(this, function(data) {			
            
            console.log('Data returned ....    ' + data.getReturnValue());
            component.set("v.dailySales", data.getReturnValue());
            component.set("v.allDailySales", data.getReturnValue());
            
            var allrecords = component.get("v.dailySales");

            if (allrecords.length == 0){
        		component.set("v.norecordsMsg", $A.get("$Label.c.DAILY_SALE_NO_CONFIRM_RECORDS"));
            } else {
                component.set("v.norecordsMsg", '');
                if (storeFilter == true) {
                    var allitems = component.get("v.allDailySales");               
                	helper.storeDropdownValues(component, allitems);
                }
				helper.callExportDataInit(component, event, helper);                
            }
     
            /*  debug stuff //
            for (var i = 0; i <allrecords.length; i++){
                var ds = allrecords[i];
                var ref = ds.dailySaleItem.Name;
                for (var ii = 0 ; ii < ds.fieldValues.length; ii ++){
                    var f = ds.fieldValues[ii];
                    var vl = f.label;
                    var vv = f.value;
                    if (vl == 'Valid for Confirmation'){
                        console.log (' #####  ' + ref + ' : ' + vl + ' = ' + vv);
                    }
                }
            }
			*/
            

        });
        $A.enqueueAction(action);
        
        var action2 = component.get("c.getFields");

        action2.setParams({
            "fsName" : component.get("v.fieldSetName"),
        });
        
        action2.setCallback(this, function(data) {			

            var state = data.getState();
            if(state === 'SUCCESS'){
				var flds = data.getReturnValue();
                for (var i = 0; i < flds.length; i++){
                    var s = flds[i].label;
                    s = s.split(" ").join("<br/>");
                    console.log(s);
                    flds[i].label = s;
                }
                component.set("v.displayFields", flds);
                //component.set("v.displayFields", data.getReturnValue());                      
                var fields = component.get("v.displayFields");
            
                var allrecords = component.get("v.dailySales");
                // default sort order 
                component.set("v.currentSortColumn", sortColumn);
                component.set("v.currentSortDirection", sortDirection);
                
                //allrecords = helper.sortRecords(component, allrecords, sortColumn, sortDirection);
				helper.sortRecords(component, allrecords, sortColumn, sortDirection);
                
                //component.set("v.dailySales", allrecords);
                
             }else if (state === "ERROR") {
                console.log('Error');
            }
            
        });
        $A.enqueueAction(action2);

    },
    
    getInput : function(cmp, evt, helper) {
        var selectedItems = new Array();
        var chkobjects = cmp.find("checkbox");
        var allrecords = cmp.get("v.dailySales");
        console.log('all records ...  ' + allrecords + ' - ' + allrecords.length);

        if (allrecords.length == 1){
            if (chkobjects.get("v.value") == true){
                selectedItems.push(allrecords[0].Id);
            } 
        } else {
            for (var i=0; i<chkobjects.length; i++){
                if (chkobjects[i].get("v.value") == true){
                    selectedItems.push(allrecords[i].Id);
                }
            }
        }
        console.log('selected items ...  ' + selectedItems + ' - ' + selectedItems.length);
        if (selectedItems.length > 0){
            
            console.log(JSON.stringify(selectedItems));
    
            var action = cmp.get("c.confirmList");
             action.setParams({
          		"dsIds" : JSON.stringify(selectedItems)
        	});

            action.setCallback(this, function(response) {
                var state = response.getState();
            	if (cmp.isValid() && state === "SUCCESS") {
                	cmp.set("v.actionMessage", response.getReturnValue());
            	}
                console.log(response.getReturnValue());

				cmp.set("v.actionMessage", response.getReturnValue());

                helper.showToast(cmp, evt, helper);
                //$A.get('e.force:refreshView').fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/daily-sales?tabset-000aa=2"
                });
                urlEvent.fire();
            });
            $A.enqueueAction(action);
        } else {
            alert('At least one record should be selected');
        }
    },    
    saveList: function(cmp, evt, helper) {

        var allrecords = cmp.get("v.dailySales");
        
        console.log('all records ...  ' + allrecords + ' - ' + allrecords.length);


        if (allrecords.length > 0){
    
            var action = cmp.get("c.saveTheList");
             action.setParams({
          		"dsUpdateList" : JSON.stringify(allrecords)
        	});

            action.setCallback(this, function(response) {
                var state = response.getState();
            	if (cmp.isValid() && state === "SUCCESS") {
                	cmp.set("v.actionMessage", response.getReturnValue());
            	}
                console.log(response.getReturnValue());

				cmp.set("v.actionMessage", response.getReturnValue());

                helper.showToast(cmp, evt, helper);
                $A.get('e.force:refreshView').fire();
            });
            $A.enqueueAction(action);
        } 
      
    },    
    gotoDailySale: function(cmp, evt, helper) {
    	helper.gotoDailySale(cmp, evt, helper);
	},    	
    onColumnSortClick: function(cmp, evt, helper){
        try{
            var col = evt.currentTarget.id;
            var currentCol = cmp.get("v.currentSortColumn");
            var direction = 'ASC';
         
            if (col == currentCol){
                if (direction == cmp.get("v.currentSortDirection")){
                	cmp.set("v.currentSortDirection", "DESC"); 
                    direction = "DESC";
                }  else {                    
                    cmp.set("v.currentSortDirection", "ASC"); 
                    direction = "ASC";                
            	}               

            }  else {
				cmp.set("v.currentSortDirection", "ASC");                 
            }
			cmp.set("v.currentSortColumn", col);
            
        	var allrecords = cmp.get("v.dailySales");
            helper.sortRecords(cmp, allrecords, col, direction);
            //cmp.set("v.dailySales", allrecords);

            
        } catch (e){
            console.log(e.message);
        }
    },
	viewHistory : function(component, event, helper) {
		component.set("v.norecordsMsg", '');
        var action = component.get("c.getDailySalesList");
        var currentList = component.get("v.currentList");
        if (currentList == "Confirm List"){                                    
            
            component.set("v.fieldSetName", "History_List_View");
            component.set("v.listViewName", "Confirmed History View");
            component.set("v.confirmList", "false");
            component.set("v.tableTitle", $A.get("$Label.c.DAILY_SALE_CONFIRMED_HISTORY_LIST"));                        
			component.set("v.currentList", "Confirmed History List");
            
			var appEvent = $A.get("e.c:dsListEvent");
        	appEvent.setParams({
            	"message" : "Hide" });
        	appEvent.fire();
            
        } else {
           
            component.set("v.fieldSetName", "Community_Confirm_List");
            component.set("v.listViewName", "");
            component.set("v.confirmList", "true");
            component.set("v.tableTitle", $A.get("$Label.c.DAILY_SALE_SELECT_RECORDS_TO_CONFIRM"));             
			component.set("v.currentList", "Confirm List");
			var appEvent = $A.get("e.c:dsListEvent");
        	appEvent.setParams({
            	"message" : "Show" });
        	appEvent.fire();
        }
 
        var sortColumn = component.get("v.sortColumn");
        var sortDirection = component.get("v.sortDirection");
 		var storeFilter = component.get("v.storeFilter");
        
        action.setParams({
            "fieldSetName" : component.get("v.fieldSetName"),
            "listViewName" : component.get("v.listViewName"),
            "confirmList" : component.get("v.confirmList")
        });
        
        action.setCallback(this, function(data) {			
            
            console.log('Data returned ....    ' + data.getReturnValue());
            component.set("v.dailySales", data.getReturnValue());
            component.set("v.allDailySales", data.getReturnValue());
            
            var allrecords = component.get("v.dailySales");
            // default sort order 
			component.set("v.currentSortColumn", sortColumn);
            component.set("v.currentSortDirection", sortDirection);            
            helper.sortRecords(component, allrecords, sortColumn, sortDirection);
        });
        $A.enqueueAction(action);
        
        var action2 = component.get("c.getFields");

        action2.setParams({
            "fsName" : component.get("v.fieldSetName"),
        });
        
        action2.setCallback(this, function(data) {			

            var state = data.getState();
            if(state === 'SUCCESS'){
				var flds = data.getReturnValue();
                for (var i = 0; i < flds.length; i++){
                    var s = flds[i].label;
                    s = s.split(" ").join("<br/>");
                    console.log(s);
                    flds[i].label = s;
                }
                component.set("v.displayFields", flds);
                //component.set("v.displayFields", data.getReturnValue());                  
                var fields = component.get("v.displayFields");

             }else if (state === "ERROR") {
                console.log('Error');
            }
            
        });
        $A.enqueueAction(action2);
    },
/*
    filterStore: function(component, helper){
        try{   
            
            var dynamicCmp = component.find("InputSelectDynamic");
            var store = dynamicCmp.get("v.value");     
            
            var allrecords = component.get("v.allDailySales");  
            var sortColumn = component.get("v.currentSortColumn");
     		
            if (store == 'All'){
                component.set("v.dailySales", allrecords);
            } else {
                component.set("v.dailySales", allrecords.filter(function (el) {
                    return (el.dailySaleItem.Store_Formula__c === store);
                }).map(function(el) {
                    return el;
                }).sort());
            }
            
        } catch (e){
            
            console.log('@@@@ error ..  ' + e.message);
        }
    },
*/    
    showSpinner : function (component, event, helper) {
    	var toggleText = component.find("spinner");
    	$A.util.removeClass(toggleText,'toggle');
	},

 	hideSpinner : function (component, event, helper) {
   		var toggleText = component.find("spinner");
   		$A.util.addClass(toggleText,'toggle');
	},
    
	filterRecords : function (component, event, helper) {

        var dynamicCmp = component.find("InputSelectDynamic");
        var store = dynamicCmp.get("v.value");     
        
		var params = event.getParam('arguments');
        var sortColumn = component.get("v.sortColumn");
        var sortDirection = component.get("v.sortDirection");		
		var allrecords = component.get("v.allDailySales");
        var weekly = null;
        if (params) {
            weekly = params.filterValue;
        } else {
            weekly = component.get("v.weekFilter");
        }
        if (weekly == ""){
            weekly = null;
        }
console.log('@@@@ filter received  weekly = ' + weekly + ' store = ' + store );            
        if (weekly && store !='All'){            
            component.set("v.dailySales", allrecords.filter(function (el) {
                return (el.dailySaleItem.Week_Commencing__c === weekly && el.dailySaleItem.Store_Formula__c === store);
            }))            	
        } else  if (!weekly && store == 'All') {            
            component.set("v.dailySales", allrecords);
        } else if (!weekly && store != 'All'){
            component.set("v.dailySales", allrecords.filter(function (el) {
                return (el.dailySaleItem.Store_Formula__c === store);
            })) 		
        } else if (weekly && store == 'All'){
            component.set("v.dailySales", allrecords.filter(function (el) {
                return (el.dailySaleItem.Week_Commencing__c === weekly);
            })) 
        } else {
            component.set("v.dailySales", allrecords);
        }
        
        component.set("v.currentSortColumn", sortColumn);
        component.set("v.currentSortDirection", sortDirection);
        //helper.sortRecords(component, allrecords, sortColumn, sortDirection);
        helper.sortRecords(component, component.get("v.dailySales"), sortColumn, sortDirection);
        
	},
    
	onDataListExport: function(component, event, helper){
		
		helper.callExportData(component, event, helper);
 
	},           

	onDataListEmail: function(component, event, helper){
		
		helper.callExportData(component, event, helper, true);
 
	}
	
})