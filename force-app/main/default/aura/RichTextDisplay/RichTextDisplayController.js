({
	
    doInit: function(component, event, helper) {
        try {
            var textSource = component.get("v.textSource");
            var idx = textSource.indexOf('$Label.');
            if (idx > -1){
                component.set("v.textSource", '');
            }
            var useVillage = component.get("v.useVillage");
            
            console.log(' @@@ useVillage ' + useVillage);
            
            var language = 'en';
            
            var action = component.get("c.getCurrentUserDetails"); 
            action.setCallback(this, function(a) {
                var uv = a.getReturnValue();
                console.log(' @@@ uv ' + uv);
                component.set("v.runningUser", uv );
                language = uv.user.LanguageLocaleKey;
                if (useVillage){                	
                    if (!uv.message){
                        component.set("v.textSource", '');
                    } else {
                    	component.set("v.textSource", uv.message);
                    }
                }
                

            });
            $A.enqueueAction(action);
            
            if (!useVillage){
                var regexp = /\$Label./g;
	            var match; 
                var matches = [];
                
                while ((match = regexp.exec(textSource)) != null) {
                    matches.push(match.index);
                }
                console.log(' @@@ matches  ' + matches);
                var labelReference = '';
                var labelName = '';
                for (var i=0; i<matches.length;i++){
                    var s  = textSource.substring(matches[i]);
                    var start = s.indexOf('.');
                    var end = s.indexOf('}');
                    if (end > -1 && start > -1){
                        labelName = s.substring(start + 1, end);
                        console.log(' @@@ labelName ' + i + labelName);
                        labelReference += $A.getReference("$Label." + labelName) + ',';
                        console.log(' @@@ labelReference ' + i + labelReference);
                    }
                    
                }
                if (labelReference != ''){
                    var action = component.get("c.getLabel"); 
                    console.log('@@@@ language  ' + language);
                    action.setParams({
                        "labelReference" : labelReference,
                        "language" : '',
                    });
                    action.setCallback(this, function(a) {
                        var dynamicLabel = a.getReturnValue();
                        console.log(' @@@ dynamicLabel ' +  dynamicLabel);
						var obj = JSON.parse(dynamicLabel);
                		for (var key in obj) {
                            if (obj.hasOwnProperty(key)) {                        
                                console.log(' @@@ key ' + key + ' - ' + obj[key])
                                textSource = textSource.replace(key, obj[key]);                        
                        	}    
                            
                        }
                        
                        console.log('@@@@ textSource  ' + textSource);
                        
                        component.set("v.textSource", textSource);
                    });
                    $A.enqueueAction(action);
                    
                }
            }
        } catch (e){
            console.log(e.message);
        }

        
    },

    handle_dsListEvent : function(cmp, event) {
        var message = event.getParam("message");
        
        var richTxt = cmp.find("richTxt");
        $A.util.toggleClass(richTxt, "toggle");
        
    }
    

	
    
    
})