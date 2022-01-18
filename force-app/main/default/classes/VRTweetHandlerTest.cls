/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class VRTweetHandlerTest {

    static testMethod void myUnitTest() {
 /*		
 		// Create test user
 		User usr = TestData_User.setupAdminUser(true);
 		string emailFrom = usr.Email;
 		
 		// Create test Chatter group
 		CollaborationGroup chatterGrp = new CollaborationGroup (name = 'Test Test ChatterGroup',
 																CollaborationType = 'Public');
 		insert chatterGrp;
 		
 		Village__c testVillage = new Village__c();
 		testVillage.Name = 'Test Test';
 		testVillage.Village_Code__c = 'TT';
 		insert testVillage;
 		
 		list<string> toList = new list<string>();
 		toList.add('test1@sf.com');
 		toList.add('test2@sf.com');

 		list<string> ccList = new list<string>();
 		ccList.add('test1cc@sf.com');
 		ccList.add('test2cc@sf.com');
 		 		
 		// create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'A test Tweet';
        email.toAddresses = toList;
        email.ccAddresses = ccList;
        email.fromAddress = emailFrom;
        email.fromname = usr.FirstName + ' ' + usr.LastName;
        
        env.fromAddress = emailFrom;
            

        string sBody = '#TT#TestBrand  ';
        sBody +=  'enjoy the test tweet';
        sBody += '+++'; 
        
        email.plainTextBody = sBody;
        
        test.startTest();
        // call the email service class and test it with the data in the testMethod
        VRTweetHandler emailService = new VRTweetHandler();
        emailService.handleInboundEmail(email, env); 

        // check VR Tweet object
        VR_Tweet__c tweet = [select Id, Name, Subject__c, ccAddresses__c, ToAddress__c, village__c, chatter_post_id__c,
        						brand__c from VR_Tweet__c where Subject_unique__c = 'A test Tweet' LIMIT 1];
		
		system.assertEquals(tweet.toAddress__c, 'test1@sf.com;test2@sf.com' );
		system.assertEquals(tweet.ccAddresses__c, 'test1cc@sf.com;test2cc@sf.com' );        						
        system.assertEquals(tweet.brand__c, 'TestBrand');
        system.assertEquals(tweet.village__c, 'TT');
        						
        // check chatter feed
        feedItem chatterFeed = [select title, body from feedItem where id = :tweet.chatter_post_id__c LIMIT 1];
        
        system.assertEquals(chatterFeed.body, email.fromName + ' : '+ email.subject);
        						        
        // post reply
        sBody = '#TT#TestBrand  ';
        sBody +=  'enjoy the test tweet REPLY';
        sBody += '+++'; 
        email.plainTextBody = sBody;
        
        emailService.handleInboundEmail(email, env); 

		tweet = [select Id, Name, Subject__c, reply_count__c, village__c, chatter_post_id__c,
        						brand__c from VR_Tweet__c where Subject_unique__c = 'A test Tweet' LIMIT 1];
        						
        system.assertEquals(tweet.reply_count__c, 1);						        
        
        // Add attachments

		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfile.txt';
		attachment.mimeTypeSubType = 'text/plain';
		 
		email.binaryAttachments =
    	new Messaging.inboundEmail.BinaryAttachment[] { attachment };        

		Messaging.InboundEmail.TextAttachment attachment2 = new Messaging.InboundEmail.TextAttachment();
		attachment2.body = 'my attachment text2';
		attachment2.fileName = 'textfile2.txt';
		attachment2.mimeTypeSubType = 'text/plain';
		 
		email.textAttachments =
    	new Messaging.inboundEmail.TextAttachment[] { attachment2 };  
        
        emailService.handleInboundEmail(email, env);
		
		// find the attachment
  		Attachment a = [select name, ContentType from attachment where parentId  = :tweet.id and name = 'textfile.txt'];

  		system.assertEquals(a.name,'textfile.txt');        

        // post without brand
		sBody = '#TT ';
        sBody +=  'enjoy the test tweet with no brand';
        sBody += '+++'; 
        email.subject = 'A test Tweet with no brand';
        email.plainTextBody = sBody;        
		emailService.handleInboundEmail(email, env); 

        // check VR Tweet object
        VR_Tweet__c tweet2 = [select Id, Name, Subject__c, ccAddresses__c, ToAddress__c, village__c, chatter_post_id__c,
        						brand__c from VR_Tweet__c where Subject_unique__c = 'A test Tweet with no brand' LIMIT 1];
        
        system.assertEquals(tweet2.brand__c, null);

        test.stopTest();
*/        
    }
}