({

    gotoDailySale: function(component, event, helper) {
		var recId = event.getSource().get("v.value");
		console.log(' @@@@ recId  ' + recId);        
        var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
  			"recordId": recId,
  			"slideDevName": "detail"
		});
		navEvt.fire();

    },

    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Result",
            "type": "success",
            "duration" : "20000",
            "mode" : "dismissable",
            "message": component.get("v.actionMessage")
        });
        toastEvent.fire();
    },
    
    sortRecords : function(component, theRecords, col, sortDir){
        try{
            var flds = component.get("v.displayFields");
            var fldType = '';
       console.log('@@@ sort col ' + col);     
            if (col == 'Trading_Date__c'){
                fldType = 'DATE';
            } else {
                for (var i = 0; i< flds.length; i++){
                    var fld = flds[i];
                    var fldName = flds[i].fieldPath;
                    console.log(fldName + ' ======== ' + col);
                    if (fldName == col){
                        fldType = fld.type;
                        break;
                    }
                    if (col == 'Name'){
                        fldType = 'STRING';
                        break;
                    }
                }
            }
console.log('@@@ fldType ..   ' + fldType);            
            //if (Date.parse(theRecords[0].dailySaleItem[col])) {
            if (fldType == 'DATE' || fldType == 'DATETIME') {
                theRecords = theRecords.sort(function (a, b){

                var dateA=new Date(a.dailySaleItem[col]); 
                var dateB=new Date(b.dailySaleItem[col]); 
                if (sortDir == 'ASC'){
                    return dateA-dateB;
                } else {
                    return dateB-dateA;
                } });
            //} else if(isNaN(Date.parse(theRecords[0].dailySaleItem[col])) && (isNaN(parseFloat(theRecords[0].dailySaleItem[col])))) {
            } else if(fldType == 'STRING' || fldType == 'PICKLIST' || fldType == 'TEXTAREA' || fldType == 'EMAIL') {    
                theRecords = theRecords.sort(function (a, b){
                    var stringA = '';
                    var stringB = '';
                    
                    if (a.dailySaleItem[col] != null)
                    	stringA = a.dailySaleItem[col].toLowerCase();                    
                    if (b.dailySaleItem[col] != null)
                    	stringB = b.dailySaleItem[col].toLowerCase();                    
                    
                    if (sortDir == 'ASC'){
                        if (stringA < stringB){ 
                            return -1;
                        } else if (stringA > stringB) {
                            return 1;
                        } else {
                            return 0;
                        }
                    } else {
                        if (stringA > stringB){
                            return -1;
                        } else if (stringA < stringB){
                            return 1;
                        } else {
                            return 0;
                        }
                    }
                }); 
                
            } else {
                theRecords = theRecords.sort(function (a, b){
                    var valA = 0;
                    var valB = 0;
                   
                    if (a.dailySaleItem[col])
                    	valA = a.dailySaleItem[col];
                    if (b.dailySaleItem[col])
                    	valB = b.dailySaleItem[col];
                    
                    if (sortDir == 'ASC'){
                        return ( valA - valB );
                    } else {
                        return ( valB - valA);
                    }    
                });            
            }
        } catch (e){
			console.log(e.message);            
        }
        
        //return theRecords; 
        console.log('### theRecords'); 
        console.log(theRecords); 
        console.log(theRecords.length);
        component.set("v.dailySales", theRecords);
        
         if (theRecords.length == 0){
        		component.set("v.norecordsMsg", $A.get("$Label.c.DAILY_SALE_NO_CONFIRM_RECORDS"));
          } else {
                component.set("v.norecordsMsg", '');
                if (component.get("v.storeFilter") == true){
                    this.storeDropdownValues(component, component.get("v.dailySales"));
                }
                
        }
                
    },
    
    
    storeDropdownValues : function (component, theRecords) {                 
        console.log('### storeDropdownValues');
        var opts = [];
        var stores = [];
        var opt = {"class": "optionClass",
                   "label": "All",
                   "value": "All"};
        
        opts.push(opt);
        for(var i = 0; i < theRecords.length; i++) {
            var label = theRecords[i].dailySaleItem.Store_Formula__c;
            
            if(label in stores == false){                    
                var opt = {"class": "optionClass",
                           "label": label,
                           "value": label};    
                opts.push(opt);
                stores[label] = label;
            }
            
        }         
        
        component.find("InputSelectDynamic").set("v.options", opts);      

    },
    
    callExportData : function (component, event, helper, email){
    
    console.log('@@@@ callExportData with email parameter ...  ' + email);
    
    	var recs = component.get("v.dailySales");
        var flds = component.get("v.displayFields");		
		        
		var viewData = { 
		    dailySales : [] 
		};

        var keys = '';

        keys = Object.keys(recs[0]);

        recs.forEach(function(item) {
                   
            keys.forEach(function(key) {
                if (key == "fieldValues"){
        			var rec = item[key];
        			//console.log(rec);
        			var jsonData = {};
        			rec.forEach(function (col){
					    flds.forEach(function(fld) 
					    {				        
					        var label = fld.label;
					        label = label.split("<br/>").join(" ");
					        //console.log(label +  ' ---- ' + col.label);
					        if (col.label == label){
					        	var value = col.value;
					        	jsonData[label] = value;
					        	//console.log(jsonData);
					        }
					    });
				    });
					viewData.dailySales.push(jsonData);
                }    
            });           
        });
        if (viewData){
        	//console.log( ' 1  ' + JSON.stringify(viewData));
        	//console.log( ' 2  email .. ' + email);
        	//console.log( ' 3  event.getSource() .. ' + event.getSource());
        	
    		var d = new Date();
    		d = d.getFullYear() + "-" + ('0' + (d.getMonth() + 1)).slice(-2) + "-" + ('0' + d.getDate()).slice(-2) + "@" + ('0' + d.getHours()).slice(-2) + ":" + ('0' + d.getMinutes()).slice(-2) + ":" + ('0' + d.getSeconds()).slice(-2);
    		try {
    			var exportBtn = event.getSource();
    			if (!email) {
    				exportBtn.Export(viewData.dailySales, 'Daily Sales Extract ' + d , 'true');
    			} else {
    				exportBtn.Email(viewData.dailySales, 'Daily Sales Extract ' + d , 'true');
    			}
    		} catch (e){
    			console.log(e.message);
    		}
        }

//console.log(JSON.stringify(viewData));
	    
    
    },
    
    callExportDataInit : function (component, event, helper){
    	
    	try {
	    	console.log('@@@@ callExportDataInit called !! ');
		
			var filterOptions = [];
			var weeks = [];
			
			filterOptions.push('');
			
			var allRecords = component.get("v.allDailySales");

			for(var i = 0; i < allRecords.length; i++) {
	            var week = allRecords[i].dailySaleItem.Week_Commencing__c;
	            
	            if(week in weeks == false){                    
	                /*var opt = {"class": "optionClass",
	                           "label": week,
	                           "value": week};*/    
	                filterOptions.push(week);
	                weeks[week] = week;
	            }
	            
	        } 
			filterOptions.sort();
			filterOptions.reverse();
			var compEvent = $A.get("e.c:DataListExportInit");
			compEvent.setParam("filterOptions", filterOptions);
			compEvent.setParam("label", $A.get("$Label.c.DAILY_SALE_WEEK_COMMENCING"));
            
			compEvent.fire();     
       } catch (e){
    	   console.log('@@@ Error .. ' + e.message);
       
       }
    }    
    

 
})