/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class VRTweetHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
/*
        string emailSubject = '';
        string emailTextBody = '';
        string emailFrom = '';
        string emailFromAddress = '';
        list<string> emailccAddress = new list<string>();
        list<string> emailToAddress = new list<string>();
        VR_Tweet__c  vrTweet = null;
        
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
            
            emailFrom = email.fromName;
            emailFromAddress = email.fromAddress;
            emailccAddress = email.ccAddresses;

            string subjectUnique = '';          
            string toAddresses = '';
            string ccAddresses = '';
            integer iPos = -1;
            integer iPos2 = -1;
            
            for(string s :emailToAddress){
                toAddresses += s + ';';             
            }
            iPos = toAddresses.lastIndexOf(';');
            toAddresses = toAddresses.substring(0, iPos);
            
            if (emailccAddress  != null){
                if(emailccAddress.size() > 0){
                    for(string s :emailccAddress){
                        ccAddresses += s + ';';             
                    }
                    iPos = ccAddresses.lastIndexOf(';');
                    ccAddresses = ccAddresses.substring(0,iPos);
                }               
            }
            
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
			
            if (emailSubject.length() > 255){                               
                subjectUnique = emailSubject.substring(0 , 255).trim();
            } else {                
                subjectUnique =  emailSubject.trim();
            }
           
            vrTweet = findTweet(subjectUnique);
            if (vrTweet == null){
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
	                }
                }
                // extract body text
                iPos = emailTextBody.indexOf('+++'); // search text for +++
                if (iPos > -1){	// return all text before +++ if found, otherwise return all text.
                	emailTextBody = emailTextBody.left(iPos);
                }
                createTweet(emailSubject, emailFrom, emailTextBody, brand, village, toAddresses, 
                					subjectUnique, emailFromAddress, ccAddresses, email);
            } else {
                iPos = emailTextBody.indexOf('+++');
                string chatterReplyText = emailTextBody;
                if (iPos > -1){
                	chatterReplyText = emailTextBody.left(iPos);
                }
                // chatter post 
                chatterReply(vrTweet, chatterReplyText, emailFrom);
                addAttachments(vrTweet, email);
                
            }
        
        }       
        catch (exception e){
            
            system.debug('ERROR .... ERROR .... ERROR ... ERROR ....    ' + e.getMessage() + ' : ' + e.getStackTraceString());             
        
        }
 */       
        result.success = true; 
        return result;
          
    }
 
 /*   
           
    private VR_Tweet__c findTweet(string subjectUnique){
        
        VR_Tweet__c vrTweet = null;
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    :' + subjectUnique);        
        string searchString = '%' + subjectUnique;
        try {
            vrTweet = [select id, Reply_Count__c, chatter_post_id__c, village__c, brand__c
            				 from VR_Tweet__c where Subject_Unique__c like :searchString LIMIT 1];
        } catch (exception e){
            vrTweet = null;
        }
        
        return vrTweet; 
    }
    
    private void createTweet(string subject, string fromName, string body, 
                                string brand, string village, string toAddress, string subjectUnique, 
                                string fromAddress, string ccAddress, 
                                Messaging.InboundEmail email){
     
        User usr = null;
        if (!string.isBlank(fromAddress)){
            try{
                usr = [Select Id, Tweet_Department__c from User where Email = :fromAddress LIMIT 1];
            } catch (exception e){
                system.debug(' **** User Not found during Tweet creation, no record created ***');
                usr = null;
            }
            
        }
        
        if (usr != null){
            VR_Tweet__c vrTweet = new VR_Tweet__c(Subject__c = subject, 
                                                    From__c = fromName, 
                                                    Body__c = body, 
                                                    Brand__c = brand,
                                                    Village__c = village,
                                                    ToAddress__c = toAddress,
                                                    ccAddresses__c = ccAddress,
                                                    Subject_Unique__c = subjectUnique,
                                                    OwnerId = usr.Id,
                                                 	Department__c = usr.Tweet_Department__c);
            
            
            Account acc = null;
            string brandSearch = '%' + brand + '%';
            try{
            	acc = [select id from Account where No_Whitespace_Name__c like :brandSearch LIMIT 1];
            	if (acc != null){
            		vrTweet.Brand_Reference__c = acc.id;
            	}
            } catch (exception e){
            	acc = null;
            }
            
            insert vrTweet;
			
            addAttachments(vrTweet, email);
            postToGroup(vrTweet, village, fromName, '');                        
        }
        
    }    
	
	private void postToGroup(VR_Tweet__c vrTweet, string village, string fromName, string comment){

		feeditem newTweet = new feeditem();
		string linkURL = URL.getSalesforceBaseUrl().toExternalForm() +'/'+vrTweet.id;
		string department = vrTweet.Department__c;
		string searchText = '';
		
        // If Village exists, find the correct Chatter Group
        string parentChatterGroup = '';
        if (string.isnotBlank(village)){
        	try {
        		searchText = 'Retail LIVE ' + department + ' ' + village;
        		// Village__c vlg = [select Name From Village__c where Village_Code__c = :village LIMIT 1];
        		// string chatterGroupName = '%' + vlg.Name + '%';
        		// CollaborationGroup chatterGrp  = [SELECT Id,Name From CollaborationGroup WHERE Name like :chatterGroupName];
        		CollaborationGroup chatterGrp  = [SELECT Id,Name From CollaborationGroup WHERE Name = :searchText];
        		parentChatterGroup = chatterGrp.Id;
        	} catch (exception e){
        		parentChatterGroup = '';
        	}
        }

        if (string.isnotBlank(parentChatterGroup) && string.isnotBlank(comment) && string.isnotBlank (vrTweet.chatter_post_id__c)) {
        	try {
        		newTweet = [select id from feedItem where id =:vrTweet.chatter_post_id__c and parentId = :parentChatterGroup];	
        		feedComment commentItem = new feedComment();
        		commentItem.CommentBody = comment;
        		commentItem.FeedItemId = newTweet.Id;
        		
        		insert commentItem;
        	} catch (exception e){
        		newTweet = null;
        		system.debug (' *** An error occurred posting a comment to ' + vrTweet.id + ' -- ' +  e.getMessage() + ' : ' + e.getStackTraceString() +  ' *** ');
        		system.debug (' *** Could not find original Tweet to post comment to for Tweet Id : ' + vrTweet.id + ' *** ');
        	}
        	
        	
        } else {

	        //IW addition - Post tweet details to a group
	        
	        if (string.isnotBlank(parentChatterGroup) && string.isBlank(vrTweet.chatter_post_id__c)){
				newTweet.parentid = parentChatterGroup;
	
		        newTweet.linkURL = linkURL;
		        if (string.isnotBlank(vrTweet.brand__c))
		        	newTweet.Title = 'New Tweet for ' + vrTweet.brand__c;
		        else{
		        	newTweet.Title = 'New Tweet';
		        }
		 //       newTweet.CreatedById = vrTweet.OwnerId;
				newTweet.Body = fromName + ' : ' + vrTweet.Subject__c;
	
		        system.debug('Inserting Chatter Group Post');
		        insert newTweet;
		        vrTweet.chatter_post_id__c = newTweet.Id;
			    update vrTweet;		
	        }
        }		
	}
	
    private void chatterReply(VR_Tweet__c vrTweet, string chatterText, string fromName){
        
        feedItem reply = new feedItem();
        string fullText = '';
        
        fullText = fromName + ' : ' + chatterText;
        
        reply.Parentid = vrTweet.Id;
        reply.Body = fullText;
        
        insert reply;
        
        //increment the reply count by 1
        vrTweet.Reply_Count__c = vrTweet.Reply_Count__c + 1;
        update vrTweet;

		postToGroup(vrTweet, vrTweet.Village__c, '', fullText);
        
    }
    
    private void addAttachments(VR_Tweet__c vrTweet, Messaging.InboundEmail email){
        
    // Save attachments, if any
        if (email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment: email.textAttachments) {
                Attachment attachment = new Attachment();
     
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = vrTweet.Id;
                insert attachment;
            }
        }
        if (email.binaryAttachments != null) {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment: email.binaryAttachments) {
                Attachment attachment = new Attachment();
             
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = vrTweet.Id;
                insert attachment;
            }
       } 
        
    }
*/
}