/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */

/************************************************
Author : Constantine Chimonides
Purpose : Class created to handle inbound emails from
	Retail Live users used for Brand collaboration.
	The class creates a Retail_Live_Email__c object and posts
	to a relevant chatter group based on user (email sender) department
	and village context of email. 
	The class is called by an Email Service and therefore
	implements the Messaging.InboundEmailHandler interface.

Version History:
================
Created  : 18/03/2014

************************************************/


global class RetailLiveEmailHandler implements Messaging.InboundEmailHandler {

	// Main method handling the email handling logic, called by Email Service 
	// Returns: Messaging.InboundEmailResult class object indicating success/failure
	// Inputs: Messaging.InboundEmail email object
	//			Messaging.InboundEnvelope envelope object
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        // return variable
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

system.debug( ' @@@  email  ' + email);
system.debug( ' @@@  envelope  ' + envelope);

		// Extract contents of email, and populate local variables
        string emailSubject = ''; 
        string emailTextBody = '';
        string emailHtmlBody = '';
        string emailFrom = '';
        string emailFromAddress = '';
        string emailMessageId = '';
        list<string> emailReferences = new list<string>();
        boolean possibleReply = false;
        
        list<string> emailccAddress = new list<string>();
        list<string> emailToAddress = new list<string>();
        Retail_Live_Email__c  retailLiveEmail = null;
        
        string brand = '';
        string village = '';
        
        try {
			
            if (email.toAddresses.size() > 0){
                emailToAddress = email.toAddresses;
            }
            
            if (!string.isBlank(email.Subject)){
                emailSubject = email.Subject;
            }

            if (!string.isBlank(email.plainTextBody)){
                emailTextBody = email.plainTextBody;
            }

            if (!string.isBlank(email.htmlBody)){
                emailHtmlBody = email.htmlBody;
            }
            if (!string.isBlank(email.messageId)){
            	emailMessageId = email.messageId;
            }
            if (email.references != null){
                emailReferences = email.references;
            }
                        
            emailFrom = email.fromName;
            emailFromAddress = email.fromAddress;
            emailccAddress = email.ccAddresses;

            string subjectUnique = '';          
            string toAddresses = '';
            string ccAddresses = '';
            integer iPos = -1;
            integer iPos2 = -1;
            
            // convert email.toAddresses list to a semi-colon separated
            // string
            for(string s :emailToAddress){
                toAddresses += s + ';';             
            }
            iPos = toAddresses.lastIndexOf(';');
            toAddresses = toAddresses.substring(0, iPos);
            
            // convert email.ccAddresses list to a semi-colon
            //separated list
            if (emailccAddress  != null){
                if(emailccAddress.size() > 0){
                    for(string s :emailccAddress){
                        ccAddresses += s + ';';             
                    }
                    iPos = ccAddresses.lastIndexOf(';');
                    ccAddresses = ccAddresses.substring(0,iPos);
                }               
            }
  system.debug (' @@@ subject .. ' + emailSubject);          
            // check whether message is a possible reply
            possibleReply = emailSubject.containsIgnoreCase('RE:');
            if(!possibleReply){
            	possibleReply = emailSubject.containsIgnoreCase('FW:');
            }
            if(!possibleReply){
            	possibleReply = emailSubject.containsIgnoreCase('FWD:');
            }
            if(!possibleReply){
            	possibleReply = emailSubject.containsIgnoreCase('Email:');
            }
  system.debug (' @@@ possible reply .. ' + possibleReply);          
            // Transform the email subject to determine a unique 
            // subject string.
            // Where reply/forward emails are being processed, remove the 
            // RE:, fw: ..etc strings which are appended to the email subject
            // by the sender's email server.
            iPos = emailSubject.indexOf(': ');
			emailSubject = emailSubject.replace('RE: ', '');
            emailSubject = emailSubject.replace('RE:', '');
			emailSubject = emailSubject.replace('Re: ', '');
            emailSubject = emailSubject.replace('Re:', '');
            emailSubject = emailSubject.replace('FW: ', '');
            emailSubject = emailSubject.replace('FW:', '');            
            emailSubject = emailSubject.replace('Fw: ', '');
            emailSubject = emailSubject.replace('Fw:', ''); 
            emailSubject = emailSubject.replace('FWD: ', '');
            emailSubject = emailSubject.replace('FWD:', '');
            emailSubject = emailSubject.replace('fwd: ', '');
			emailSubject = emailSubject.replace('fwd:', '');
			emailSubject = emailSubject.replace('Email:', ''); // Maybe from Outlook app
			
            if (emailSubject.length() > 255){                               
                subjectUnique = emailSubject.substring(0 , 255).trim();
            } else {                
                subjectUnique =  emailSubject.trim();
            }
			
			// Call method to determine whether email subject string exists already
			// on a Retail_Live_Email__c object, in which case the email should be treated
			// as a reply. For a reply, a chatter post should be created and associated with the
			// original email record.            
            retailLiveEmail = findTweet(subjectUnique, emailHtmlBody, 
            								emailFromAddress, emailTextBody,
            								emailReferences);
            
            if (string.isBlank(retailLiveEmail.village__c)){ // New email received, create new record            	
                // Extract village and brand from email body #tags (eg. #BV#TedBaker)
                iPos = emailTextBody.indexOf('#');
                iPos2 = emailTextBody.lastindexOf('#');
                if (iPos > -1 && iPos2 > -1 ){
	                if (iPos2 == iPos){
						iPos2 = emailTextBody.indexOf('\n', iPos);
		                if (iPos2 > -1){
		                	village = emailTextBody.substring(iPos + 1, iPos2);
		                	village = village.trim().toUpperCase();
		                } else {
		                	iPos2 = emailTextBody.indexOf(' ', iPos);
		                	if (iPos > -1){
		                		village = emailTextBody.substring(iPos + 1, iPos2);
		                		village = village.trim().toUpperCase();	                	
		                	}
		                }
		                iPos2 = iPos;    	
	                } else {
	                	village = emailTextBody.substring(iPos + 1, iPos2);
	                	village = village.trim().toUpperCase();
	                }
	                if (iPos2 > iPos){
		                iPos = emailTextBody.indexOf('\n', iPos2);
		                if (iPos > -1){
		                	brand = emailTextBody.substring(iPos2 + 1, iPos);
		                } else {
		                	iPos = emailTextBody.indexOf(' ', iPos2);
		                	if (iPos > -1){
		                		brand = emailTextBody.substring(iPos2 + 1, iPos);	                	
		                	}
		                }
		                brand = brand.trim();
		                // If there are any spaces, only consider all text upto the first space
		                iPos = brand.indexOf(' ');
		                if (iPos > -1){
		                	brand = brand.left(iPos);
		                }
	                }
                }
                // extract body text
                iPos = emailTextBody.indexOf('---'); // search text for ---
                if (iPos > -1){	// return all text before --- if found, otherwise return all text.
                	emailTextBody = emailTextBody.left(iPos);
                }
                string guid = retailLiveEmail.Guid__c;
                // Call method to create the Retail_Live_Email__c object
                createTweet(emailSubject, emailFrom, emailTextBody, brand, village, toAddresses, 
                					subjectUnique, emailFromAddress, ccAddresses, email, guid,
                					emailMessageId, possibleReply);
            } else { // Subject has been found on an existing Retail_Live_Email__c record, therefore treat as a reply
                iPos = emailTextBody.indexOf('---');
                string chatterReplyText = emailTextBody;
                if (iPos > -1){
                	chatterReplyText = emailTextBody.left(iPos);
                }
                // chatter post reply
                chatterReply(retailLiveEmail, chatterReplyText, emailFrom);
                
                // process any email attachments
                addAttachments(retailLiveEmail, email);
                
            }
        
        }       
        catch (exception e){
            
            system.debug('ERROR .... ERROR .... ERROR ... ERROR ....    ' + e.getMessage() + ' : ' + e.getStackTraceString());             
        
        }
        
        result.success = true; 
        return result;
          
    }
    
    // Method to query the Retail_Live_Email__c object for a record containing
    // the email subject string.
    // Return:void
    // Inputs: transformed email subject string with trailing/leading spaces removed
    //  and all mail server prefixes (eg. RE:, fwd: ..etc) removed.         
    private Retail_Live_Email__c findTweet(string subjectUnique, string htmlBody, 
    										string fromAddress, string plainBody,
    										list<string> references){
        
        Retail_Live_Email__c retailLiveEmail = null;
        integer iPos1 = htmlBody.IndexOf('~');
        boolean found = false;
        string guid = '';
		integer ipos2 = htmlBody.lastIndexOf('~');
		
system.debug(' @@@ htmlbody ...  ' + htmlBody);
system.debug(' @@@ plainbody ...  ' + plainBody);
system.debug(' @@@@ tilda ... ' + ipos2);
        
        // extract GUID
        if (iPos2 > -1){
        	guid = htmlBody.substring(iPos1 + 1, iPos2 );	        	
        }
        
        // first try and match on message Id (references)
    	if (references != null){
	    	if (references.size() > 0){
		    	try { 
		    	retailLiveEmail = [select id, Reply_Count__c, chatter_post_id__c, village__c, brand__c, guid__c
		        				 from Retail_Live_Email__c where message_Id__c in :references LIMIT 1];
		    	} catch (exception e){
		    		retailLiveEmail = null;
		    	}
	    	
				if (retailLiveEmail != null){
        			found = true;
system.debug (' @@@ MATCHED ON Message id');        			
					createActivity(subjectUnique, plainBody,
									fromAddress, retailLiveEmail.Id);
        		} 	    	
	    	}
    	}
    		        
        // If no match, match on GUID
        if (!found && string.isnotBlank(guid)){
        	
system.debug(' @@@@ guid ... ' + guid);        	
        	try { 
        	retailLiveEmail = [select id, Reply_Count__c, chatter_post_id__c, village__c, brand__c, guid__c
            				 from Retail_Live_Email__c where guid__c = :guid LIMIT 1];
        	} catch (exception e){
        		retailLiveEmail = null;
        	}

        	if (retailLiveEmail != null){
        		found = true;
system.debug (' @@@ MATCHED ON GUID');        		
				createActivity(subjectUnique, plainBody,
									fromAddress, retailLiveEmail.Id);
        	} 
        }
		
		
		// if still no match try and match on unique subject, created in last 2 weeks       
        if (!found) {
	        string searchString = '%' + subjectUnique;
	        if (subjectUnique.length() > 250){
	        	searchString = '%' + subjectUnique + '%';
	        }
	        try {
	            retailLiveEmail = [select id, Reply_Count__c, chatter_post_id__c, village__c, brand__c
	            				 from Retail_Live_Email__c where (CreatedDate = LAST_N_DAYS:14
	            				 and Subject_Unique__c like :searchString) LIMIT 1];
	            				 
	        	if (retailLiveEmail != null){
	        		found = true;
system.debug (' @@@ MATCHED ON Subject');	        		
					createActivity(subjectUnique, plainBody,
										fromAddress, retailLiveEmail.Id);
	        	} 	
	        } catch (exception e){
	            retailLiveEmail = null;
	             system.debug('ERROR .... ERROR .... ERROR ... ERROR ....  Creating Activity for Matched Retail Live   ' 
	             						+ e.getMessage() + ' : ' + e.getStackTraceString());             
	        }
        }
        
        // If no matches, treat as new retail LIVE (NOT a reply)
        if (!found){
        	retailLiveEmail = new Retail_Live_Email__c(Guid__c = guid);
        }
        
        return retailLiveEmail; 
    }
    
	private void createActivity(string subjectUnique, string plainBody,
									string fromAddress, string retailLiveId){
		
		
		// create activity		
		Task activity = new Task();
		activity.ActivityDate = system.today();
		activity.subject = subjectUnique;
		if (plainBody.length() > 255){
			activity.Retail_LIVE_Reply__c = plainBody.substring(0, 254);
		} else {
			activity.Retail_LIVE_Reply__c = plainBody;
		}
		activity.Description = plainBody;
		activity.Retail_LIVE_From__c = fromAddress;
		activity.Retail_Live__c = true;
		activity.whatId=  retailLiveId;
		string whoId = getSenderId(fromAddress);
		
		if (string.isnotBlank(whoId))
			activity.whoid = whoId;
		
		activity.status = 'Completed';
		insert activity;		

	}
	
    private string getSenderId(string email){
    	
    	string senderId = '';
    	id brandContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Brand Contact').RecordTypeId;
    	
    	try{
    		senderId = [select Id from Contact where email =:email and RecordTypeId =:brandContactRecordTypeId].Id;
    	} catch (exception e){
    		senderId = '';	
    	}
    	
    	/*
    	if (string.isBlank(senderId)){
    		try {
    			senderId = [select Id from User where email = :email].Id;
    		} catch (exception e){
    			senderId = '';
    		} 	
    	}
    	*/
    	if (string.isBlank(senderId))
    		senderId = '';
    		
    	return senderId;
    	
    }
    
    // Method to create a Retail_Live_Email__c object, based on inbound email details. 
    private void createTweet(string subject, string fromName, string body, 
                                string brand, string village, string toAddress, string subjectUnique, 
                                string fromAddress, string ccAddress, 
                                Messaging.InboundEmail email, string guid,
                                string messageId, boolean possibleReply){
     	
     	Id brandRecType = Schema.SobjectType.Account.RecordTypeInfosByName.get('Brand').RecordTypeId;
     	
        // Check user is valid by comparing sender's email address with Salesforce User object.
        // Only VR user's should be creating the Retail Live Eamil object. 
        User usr = null;
        if (!string.isBlank(fromAddress)){
            try{
                usr = [Select Id, Tweet_Department__c from User where Email = :fromAddress and isActive = true order by Tweet_Department__c desc LIMIT 1];
            } catch (exception e){ // log error if user not found
                system.debug(' **** User Not found during Tweet creation, no record created ***');
                usr = null;
            }
            
        }
        string nameText = subjectUnique;
        if (nameText.length() > 77){
        	nameText = nameText.subString(0,76) + '...';
        }
        // Create record if user is valid
        if (usr != null){
            Retail_Live_Email__c retailLiveEmail = new Retail_Live_Email__c(Subject__c = subject, 
                                                    From__c = fromName, 
                                                    Body__c = body, 
                                                    Brand__c = brand,
                                                    ToAddress__c = toAddress,
                                                    ccAddresses__c = ccAddress,
                                                    Subject_Unique__c = subjectUnique,
                                                    Name = nameText,
                                                    OwnerId = usr.Id,
                                                 	Department__c = usr.Tweet_Department__c,
                                                 	Guid__c = guid,
                                                 	Message_Id__c = messageId,
                                                 	Possible_Reply__c = possibleReply
                                                 	);
            
            
            // Check account against the #tag brand string from the email body.
            // This is a fuzzy-type search to associate the email with a brand account
            // if possible based on the #tag string entered in the email body
            list<Account> accList = null;
            string brandSearch =  brand + '%';
            
            string description = '';
            Account account;
            boolean createVP =  false;
            
            if (string.isnotBlank(brand)){
	            try{
	            	accList = [select id,Name from Account where No_Whitespace_Name__c like :brandSearch
	            	 and RecordTypeId = :brandRecType
	            	 order by Name LIMIT 1];
	            	if (accList != null){
	            		if (accList.size() == 1){
	            			retailLiveEmail.Brand_Reference__c = accList[0].id;
	            		
					        // Find whether there is an associated village presence record
					        string villagePresenceId = '';
					        Village_Presence__c villagePresence = VillagePresenceUtilities.getVillagePresence(village, accList[0].Name);      
					        if (villagePresence != null){
					        	villagePresenceId = villagePresence.Id;
					        	retailLiveEmail.Village_Presence__c = villagePresenceId;
					        } else {
								createVP = true;
								account  = accList[0]; 				        	
					        }
	            		}	            		
	            	}
	            } catch (exception e){ // No account found, simply continue inserting record with no account association
	            	accList = null;
	            }
            }
            // Validate village #tag 2 character code entered on email against village object
            // only write to village field on Retail Live Email record if village code is valid
            Village__c vlg = null;
            if (string.isnotBlank(village)){
            	try {
            		vlg = [select Name From Village__c where Village_Code__c = :village LIMIT 1];
            		if (vlg != null){
            			retailLiveEmail.Village__c = village;
            		}
            	} catch (exception e){
            		vlg = null;
            	}
            }

            insert retailLiveEmail;
            if (createVP){
            	retailLiveEmail = [select Id, Village_Presence__c, Department__c, 
            						Subject__c, chatter_post_id__c from Retail_Live_Email__c where Id =:retailLiveEmail.Id];           	

	        	Village_Presence__c villagePresence = VillagePresenceUtilities.createVillagePresence(account.Id, village);
	        	retailLiveEmail.Village_Presence__c = villagePresence.Id;
	        	update retailLiveEmail; 	            	
            }
			
			//post topic to retail live record - village and brand
			if (string.isnotBlank(village)){
				ConnectApi.Topic topic1 = ConnectApi.Topics.assignTopicByName('Internal', retailLiveEmail.Id, village);
			}
			if (string.isnotBlank(brand)){
				ConnectApi.Topic topic2 = ConnectApi.Topics.assignTopicByName('Internal', retailLiveEmail.Id, brand);
			}			
			

			
            // Process any email attachments
            addAttachments(retailLiveEmail, email);
            
            // Call method to post to chatter group
            postToGroup(retailLiveEmail, village, fromName, '');                        
        }
        
    }    
	
	private void postToGroup(Retail_Live_Email__c retailLiveEmail, string village, string fromName, string comment){

		feeditem newTweet = new feeditem();
		string linkURL = URL.getSalesforceBaseUrl().toExternalForm() +'/'+retailLiveEmail.id;
		string department = retailLiveEmail.Department__c;
		string searchText = '';
        string parentChatterGroup = '';	
        string postId = '';
        	
		//Check if post is a reply to an existing chatter group post record
		postId = retailLiveEmail.chatter_post_id__c;
		
        // If Village exists, find the correct Chatter Group

        if (string.isnotBlank(village) && string.isBlank(postId)){
        	try {
        		searchText = 'Retail LIVE ' + department + ' ' + village;
	       		CollaborationGroup chatterGrp  = [SELECT Id,Name From CollaborationGroup WHERE Name = :searchText];
        		parentChatterGroup = chatterGrp.Id;
        	} catch (exception e){
        		parentChatterGroup = '';
        	}
        }

        if (string.isnotBlank(comment) && string.isnotBlank (postId)) {
        	try {
        		newTweet = [select id from feedItem where id =:retailLiveEmail.chatter_post_id__c];	
        		feedComment commentItem = new feedComment();
        		commentItem.CommentBody = comment;
        		commentItem.FeedItemId = newTweet.Id;
        		
        		insert commentItem;
        	} catch (exception e){
        		newTweet = null;
        		system.debug (' *** An error occurred posting a comment to ' + retailLiveEmail.id + ' -- ' +  e.getMessage() + ' : ' + e.getStackTraceString() +  ' *** ');
        		system.debug (' *** Could not find original Tweet to post comment to for Tweet Id : ' + retailLiveEmail.id + ' *** ');
        	}
        	
        	
        } else {

	        //IW addition - Post tweet details to a group
	        
	        if (string.isnotBlank(parentChatterGroup) && string.isBlank(postId)){
				newTweet.parentid = parentChatterGroup;
	
		        newTweet.linkURL = linkURL;
		        string brandRef = retailLiveEmail.brand__c;
		        if (string.isnotBlank(retailLiveEmail.Brand_Reference__c)){
		        	Account acc = [Select Name from Account where id = :retailLiveEmail.Brand_Reference__c];
		        	brandRef = acc.Name;
		        }
		        if (string.isnotBlank(retailLiveEmail.brand__c))
		        	newTweet.Title = 'New Retail LIVE Email for ' + brandRef;
		        else{
		        	newTweet.Title = 'New Retail LIVE Email';
		        }
				newTweet.Body = fromName + ' : ' + retailLiveEmail.Subject__c;
	
		        system.debug('Inserting Chatter Group Post');
		        insert newTweet;
		        retailLiveEmail.chatter_post_id__c = newTweet.Id;
			    update retailLiveEmail;		
	        }
        }		
	}
	
    private void chatterReply(Retail_Live_Email__c retailLiveEmail, string chatterText, string fromName){
        
        feedItem reply = new feedItem();
        string fullText = '';
        
        fullText = fromName + ' : ' + chatterText;
        
        reply.Parentid = retailLiveEmail.Id;
        reply.Body = fullText;
        
        insert reply;
        
        //increment the reply count by 1
        retailLiveEmail.Reply_Count__c = retailLiveEmail.Reply_Count__c + 1;
        update retailLiveEmail;

		postToGroup(retailLiveEmail, retailLiveEmail.Village__c, '', fullText);
        
    }
    
    private void addAttachments(Retail_Live_Email__c retailLiveEmail, Messaging.InboundEmail email){
        
    // Save attachments, if any
        if (email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment: email.textAttachments) {
                Attachment attachment = new Attachment();
     
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = retailLiveEmail.Id;
                insert attachment;
            }
        }
        if (email.binaryAttachments != null) {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment: email.binaryAttachments) {
                Attachment attachment = new Attachment();
             
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = retailLiveEmail.Id;
                insert attachment;
            }
       } 
        
    }

}