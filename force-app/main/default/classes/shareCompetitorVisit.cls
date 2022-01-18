global class shareCompetitorVisit {


    @InvocableMethod
    global static void Id(list<myeventId> passedid)  {  
    
    String communityId = null;
    Collaborationgroup chattergroup = [select Id from Collaborationgroup WHERE NAME = 'Competitor Site Visits'];
    List <Feeditem> theEvent = [SELECT id,body from FeedItem WHERE Id =: passedid[0].postid LIMIT 1 ];
    id feedElementId2 = theEvent[0].id;
    
    String feedElementId = theEvent[0].id;
    
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();

    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
      
    string mystring = passedid[0].body + '\n' +  '\n' ;

    textSegmentInput.text = mystring;
    messageBodyInput.messageSegments.add(textSegmentInput);
    
    mentionSegmentInput.id = chattergroup.id;
    messageBodyInput.messageSegments.add(mentionSegmentInput);

    feedItemInput.body = messageBodyInput;

    ConnectApi.FeedElement editedFeedElement = ConnectApi.ChatterFeeds.updateFeedElement(communityId, feedElementId, feedItemInput); 
    
    }  
    
    
    global class myeventId {
    @InvocableVariable(required=true)
    global string eventIds;
           
    @InvocableVariable(required=true)
    public string eventName;
           
    @InvocableVariable(required=true)
    public string body;
    
    @InvocableVariable(required=true)
    public string postid;
    
    }

}