public class TravelTradeMeetingTriggerHelper {


    
    public Static void ProcessShares( list<Travel_Trade_Meeting__c> meetingsToShare)
    {
        System.debug('Class recieved these meetings to Share: ' + meetingsToShare );
        
        
        //create a maps for vr users and Accounts in the meetings so that they can be referenced in the chatter post
        set<id> Qaccounts = new set<id>();
        set<id> QUsers = new set<id>();
        
        for(Travel_Trade_Meeting__c cMeeting: meetingsToShare)
        {
            Qaccounts.add(cMeeting.Tourism_Account__c);
            Qusers.add(cMeeting.VR_Representative__c);
        }
        Map<id, Account> AccountMap  = new Map<id, Account> ([SELECT Id, Name FROM Account WHERE Id in :Qaccounts  ]);
        Map<id, User> UserMap  = new Map<id, User> ([SELECT Id, Name FROM User WHERE Id in :QUsers  ]);
        System.debug('AccountMap: '+ AccountMap  );
        System.debug('UserMap: '+ UserMap  );
        ////////////////////////////////////////////////// end of MAP lookup
       list<collaborationgroup> TTMGroupId = null;
       if(system.Test.isRunningTest()){
           TTMGroupId = new list<collaborationgroup>( [SELECT id FROM collaborationgroup WHERE Name = 'Test Chatter Group' limit 1]);  
       } else { 
           //Get the Chatter group ID for "Travel Trade Meetings"
           TTMGroupId = new list<collaborationgroup>( [SELECT id FROM collaborationgroup WHERE Name = 'Travel Trade Meetings' limit 1]);
       }
        //Loop through each meeting and create the share
        for(Travel_Trade_Meeting__c cMeeting: meetingsToShare)
        {
                
            ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegment;
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            
            //Creating the post body :: made up of a list of individual segments
            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            //first segment item is the @mention for the id of the  'Travel Trade Meetings' group.
            mentionSegment.id = TTMGroupId[0].id;
            messageInput.messageSegments.add(mentionSegment);
            
            //second segment item is the opening text of the post
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = ' A Travel Trade meeting has been entered for '
            + UserMap.get(cMeeting.VR_Representative__c).name 
            +' with '+ AccountMap.get(cMeeting.Tourism_Account__c).Name 
            + ' in the ' + cMeeting.Meeting_Location__c + '. \n\n';
            messageInput.messageSegments.add(textSegment);
            
            
            //third segment (could be joined with the above!) is a continuation of the above.
            textSegment = new ConnectApi.TextSegmentInput();
            string minutes = '';
            string shareNotes = '';
            if (!string.isBlank(cMeeting.Meeting_Minutes__c)){            	
            	minutes = cMeeting.Meeting_Minutes__c.left(5000);
            }
            if (!string.isBlank(cMeeting.Sharing_Notes__c)){            	
            	shareNotes = cMeeting.Sharing_Notes__c;
            }            
            textSegment.text = 'Meeting Notes: '+ minutes
            +'\n\n ' + shareNotes 
            + '\n\nTo Collaborate on this meeting, enter a comment, reply to the email, or post directly on the Meeting itself';
            messageInput.messageSegments.add(textSegment);
            
            //assign the messageInput list to the inputbody
            input.body = messageInput;
            
            //call the post command, sending it the items created above
            ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem('internal', feedType, cMeeting.id, input, null);

        }
        
    }

	public static void updateRelatedAccount(List<Travel_Trade_Meeting__c> travelTradeList){
        List<Id> accIdList = new List<Id>();
        
        for(Travel_Trade_Meeting__c travel : travelTradeList){
            accIdList.add(travel.Tourism_Account__c);
        }
        if(!accIdList.isEmpty()){
            UpdateRelatedAccountSchedulable schedulable = new UpdateRelatedAccountSchedulable(accIdList, 'Travel Trade Meeting');
            
            Datetime dt = Datetime.now().addMinutes(1);
   			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

            System.schedule('Schedule Account Update '+System.currentTimeMillis(), timeForScheduler , schedulable);
        }
    }
}