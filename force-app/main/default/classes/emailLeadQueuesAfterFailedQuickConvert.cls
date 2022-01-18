global class emailLeadQueuesAfterFailedQuickConvert {


    @InvocableMethod
    public static void Id(list<sendEmailDetails> details)  {  

        String miceQueue = 'MICE Lead Queue - ';
        String leisureQueue = 'LEISURE Lead Queue - ';
        
        
        String TransReqd;
        if(details[0].transportRequired == true){
                    TransReqd = 'Yes';}
                    else {
                    TransReqd = 'No';
                    }
                    
        String modeofTrans;
        if(details[0].modeTransport == ''){
                    modeofTrans = 'N/A';}
                    else {
                    modeofTrans = details[0].modeTransport;
                    }
                    
        String foodBev;
        if(details[0].foodBeverage == true){
                    foodBev = 'Yes';}
                    else {
                    foodBev = 'No';
                    }
                    
        String boutique;
        if(details[0].boutiquePrivateViewing == true){
                    boutique = 'Yes';}
                    else {
                    boutique = 'No';
                    }
                    
        String strGift;
        if(details[0].gift == true){
                    strGift = 'Yes';}
                    else {
                    strGift = 'No';
                    }
                    
        String strGiftCard;
        if(details[0].giftCard == true){
                    strGiftCard = 'Yes';}
                    else {
                    strGiftCard = 'No';
                    }
                    
        String strVIPLounge;
        if(details[0].VIPLounge == true){
                    strVIPLounge = 'Yes';}
                    else {
                    strVIPLounge = 'No';
                    }
                    
        String strWelcomePack;
        if(details[0].welcomePack == true){
                    strWelcomePack = 'Yes';}
                    else {
                    strWelcomePack = 'No';
                    }
  
    MAP<Id, Group> QueueIDs = new MAP<Id, Group>(); 
   
     if(details[0].GroupType == 'MICE'){
         for(Group grp : [Select Id,Name from Group where type='Queue' and Name=:miceQueue + details[0].PrimaryVillageofInterest ]){
             QueueIDs.put(grp.id, grp);    
         }
     }   
     else{
        for(Group grp : [Select Id,Name from Group where type='Queue' and Name=:leisureQueue + details[0].PrimaryVillageofInterest]){
            QueueIDs.put(grp.id, grp);    
        }
     }     
     system.debug('QueueIDs ' +QueueIDs );
     list<GroupMember> queueUsers =  [Select id,UserOrGroupId From GroupMember where GroupId IN:QueueIDs.keyset()];
     
     List<String> Userids = new List<String>();
     for(GroupMember grp : queueUsers ){
         Userids.add(grp.UserOrGroupId);
     }     
     
     list<User> queueMemberList = [Select Id, Name, Email FROM User WHERE id IN :Userids];
         
     //Get the id for the senders "FROM" address
     OrgWideEmailAddress OWA = [SELECT id FROM OrgWideEmailAddress WHERE Address = 'traveltrade@chicoutletshopping.com' limit 1];
     
     LIST<string> toaddresses = new List<string>();
     for(User usr : queueMemberList ){
         toaddresses.add(usr.email);
     }
     
     String instanceURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+details[0].LeadId;
     system.debug('URL '+instanceURL );
     

     try{
     Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
     List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
     msg.setSubject('A '+details[0].GroupType+' Group Booking Lead had a problem Auto Converting');
     msg.setHtmlBody('<html><body><style>ul,li,p,a{background:white; font-family:Arial,sans-serif;}</style><p>A '+details[0].GroupType+' Group Booking Lead for ' 
     + details[0].PrimaryVillageofInterest + ' has failed to Quick Convert and needs attention, please review it here:' +
     ' <a href="'+instanceURL+'">'+instanceURL+'</a></p>' + 
     '<ul><li>Partner : '+details[0].partner+'</li>' +
     '<li>Expected Arrival Date : '+details[0].expectedArrivalDate+'</li>' +
     '<li>Expected Number of Guests : '+details[0].expectedNumberGuests+'</li>' +
     '<li>Country of Residence : '+details[0].countryofResidence+'</li>' +
     '</ul>'+
     '<p style="padding-left: 30px;"><span style="text-decoration: underline;">Additional Services</span></p>'+
     '<ul>'+
     '<li>Transport Required : ' +TransReqd+'</li>'+
     '<li>Mode of Transport : ' +modeofTrans+'</li>'+
     '<li>Food and Beverage : ' +foodBev+'</li>'+
     '<li>Boutique Private Viewing : '+boutique+'</li>'+
     '<li>Gift : '+strGift+'</li>'+
     '<li>Gift Card : '+strGiftCard+'</li>'+
     '<li>VIP Lounge Access : '+strVIPLounge+'</li>'+
     '<li>Welcome Pack : '+strWelcomePack+'</li>'+
     '<li>Notes and Additional Comments :'+details[0].notesAndComments+'</li></ul></body></html>');msg.setTargetObjectId(queueMemberList[0].id);
     msg.setToAddresses(toaddresses);
     msg.setOrgWideEmailAddressId(OWA.id);
     msg.setWhatId(details[0].LeadId);
     msg.saveAsActivity = False;
     lstMsgs.add(msg);     

     Messaging.sendEmail(lstMsgs);
         
     }
    catch (System.EmailException e){
                Throw e;
    }  
    catch (Exception e){
                Throw e;
    }

    }
    
    
    
    
    global class sendEmailDetails {
    
    @InvocableVariable(required=true)
    global id LeadId;
    
    @InvocableVariable(required=true)
    global String GroupType;
    
    @InvocableVariable(required=true)
    global string PrimaryVillageofInterest;
    
    @InvocableVariable(required=true)
    global datetime expectedArrivalDate ;
    
    @InvocableVariable(required=true)
    global string partner;
    
    @InvocableVariable(required=true)
    global integer expectedNumberGuests;
    
    @InvocableVariable(required=false)
    global boolean transportRequired;
    
    @InvocableVariable(required=false)
    global string modeTransport;
    
    @InvocableVariable(required=false)
    global boolean foodBeverage;
    
    @InvocableVariable(required=false)
    global boolean boutiquePrivateViewing;
    
    @InvocableVariable(required=false)
    global boolean gift;
    
    @InvocableVariable(required=false)
    global boolean giftCard;
    
    @InvocableVariable(required=false)
    global boolean VIPLounge;
    
    @InvocableVariable(required=false)
    global boolean welcomePack;
    
    @InvocableVariable(required=false)
    global string notesAndComments;
    
    @InvocableVariable(required=false)
    global string countryofResidence;
             
    }

}