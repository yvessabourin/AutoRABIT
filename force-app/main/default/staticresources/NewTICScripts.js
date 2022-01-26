// Validation Snippet - Ian Burton Nov 2017
// This validation code is to be used as follows:
// add the class "requiredfield" to any 'input' or 'select' element if you wish for it to be validated.
// also include a CSS class called "validationfail" to your styles, for making the field red or whatever you wish 
// then call this validation in your submit code "ValidateElements" -> returns boolean (true if all fields are OK, false if validation fails)

 
 $j = jQuery.noConflict();
 
 
	  
 function isEmail(email) {
              var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
              return regex.test(email);
        }

        function ValidateElements(){

              var validationFailed = false;
             
            $j.each($j('.requiredfield'), function (index, value) { 
                var currentFieldFailedValidation = false;
                 console.log("Validating " + value);
                if ($j(value).is("input")){
                  // lets check if its maybe an email type
                  if($j(value).attr('type').toLowerCase() == 'email')
                  {
                      if($j(value).val() == "" || !isEmail($j(value).val())){
                          currentFieldFailedValidation = true;
                      }
                  }
                  else if($j(value).attr('type').toLowerCase() == 'text'){
                     if($j(value).val() == ""){
                       currentFieldFailedValidation = true;
                     }
                  }
                  
                }

                if($j(value).is("select")){
                  if($j(value).find(":selected").is(":disabled")){
                      currentFieldFailedValidation = true;                     
                  }    
				else if($j(value).val() == null){
                      currentFieldFailedValidation = true;                     
                  }   				  
                }

                if(currentFieldFailedValidation){
                   validationFailed = true;
                    console.log("Validation failed for " + value);
                    $j(value).addClass('validationfail');
                }
                else
                {
                   console.log("Validation succeeded for " + value);
                     $j(value).removeClass('validationfail')
                }                                           
            });

            return !validationFailed; // returns true if everythign checks out.
        }
		
		// ------- End of Validation Snippet
		
	   function gotoPage(pg){
			
		var url = '/apex/' + pg;
		
		if(  ('{!$User.UIThemeDisplayed}' == 'Theme4t' || '{!$User.UIThemeDisplayed}' == 'Theme4d') || ((typeof sforce != 'undefined') && (sforce != null)) ) {
		 // running in mobile
			console.log('VIP Mobile ..');
			sforce.one.navigateToURL(url);
		} else { //desktop
			console.log('VIP Desktop..');                
			//window.open(url, '_blank');
			window.location.href = url;                    
		}  
		
	}