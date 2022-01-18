public with sharing class CampaignSearchController {
//Constructor
    public CampaignSearchController() {
    //Load up the top 10 campaigns to Display on the page when it is loaded.
        //Get the users Village so that we can filter the Campaigns per Village    
        LoggedInUSerId = UserInfo.getUserId();
            list<user> users = [SELECT id, Village__c FROM USER 
                            WHERE id = :LoggedInUSerId
                            LIMIT 1];
            usersVillage = users[0].Village__c;           

       string SearchParameter = '' + ApexPages.currentPage().getParameters().get('search');
       system.debug('@@@@@@@@@@@@@@ parameter :' + SearchParameter + ' @@@ Length: ' + SearchParameter.length()+ ' in URL');
   
       IF(SearchParameter.length() <= 1 || SearchParameter == 'Null' )
       {
           IF(SearchParameter.length() <= 1 ){
               apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.WARNING,'Invalid search: \'' + SearchParameter + '\'');
               apexpages.addmessage(msg);
           }      
         ResetSearch();
       }
       ELSE
       {
          SearchString = SearchParameter;
          SubmitSearch();
       }
    }
    
//Properties
    Public String SearchString {get;set;}
    Public list<Campaign> VillageCampaigns = new list<Campaign>();
    Public Id LoggedInUSerId{get;set;}
    Private string usersVillage;
    public string SearchHeaderMessage {public get;set;}
    Public FINAL id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();
    Public FINAL id MICERedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('MICE Redeemable Campaign').getRecordTypeId();
        
//Methods    

    //display a message if you are entering the page after sucesfully submitting a set of tags
    public void Init()
    {
      String message = '' + ApexPages.CurrentPage().GetParameters().Get('message');
      String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer'); 
    
      // Use the referrer parameter to only show the message when coming from Page 1
      if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('multiaddredemptions') && message != 'null')
      {
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
      }
    }



    public PageReference ResetSearch() {
    
    VillageCampaigns.clear();
    SearchString = null;
    SearchHeaderMessage = 'Top 20 Campaigns for ' + usersVillage  + ' sorted by Redemption count';
    
        FOR(Campaign cCampaign : [SELECT id, Name, Village__r.name, communication_Channel__c, Partner__r.Name, Description, isActive, Status,
                                    Total_Redemptions__c, Parent.Name, QR_Code_Image__c, Calculated_Status__c , COS_campaign__c
                                  FROM Campaign
                                  WHERE RecordtypeID = :RedeemableCampRecordTypeId
                                  AND startDate <= :Date.today()
                                  AND endDate >= :Date.today()
                                  AND Village__r.Name = :usersVillage 
                                  ORDER BY Total_Redemptions__c desc
                                  LIMIT 20 ] )
        {
            VillageCampaigns.add(cCampaign);
        }     
       Return NULL; 
    }

    public PageReference SubmitSearch() {
      
        system.debug('Search String : ' + SearchString +'(' + SearchString.length() + ')' ); 
            
            //Only process search terms greater than 1 character long
             if (SearchString.length() <= 1)
             {
                   system.debug('@@@@@@@@@Search String too short@@@@@@@@@@@@@@@@@@');
                    pagereference p = apexpages.Currentpage();
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.warning,'Please enter at least 2 characters in your search term. You can use wildcards(*) in your search. e.g. \'*CA*\'');
                    apexpages.addmessage(msg);
                    return null; 
             }
            List<List<SObject>> searchList = [FIND :SearchString IN ALL FIELDS 
                                              RETURNING 
                                                 Campaign (id, Name, Village__r.name, communication_Channel__c, Partner__r.Name, Description, isActive, calculated_Status__c,
                                                            Total_Redemptions__c, Parent.Name, recordtypeid, QR_Code_Image__c, Group_Booking__c, COS_campaign__c
                                                            WHERE recordtypeid IN  (:RedeemableCampRecordTypeId,:MICERedeemableCampRecordTypeId )
                                                            AND Village__r.name = :usersVillage
                                                            AND startDate <= :Date.today()
                                                            AND endDate >= :Date.today())];
           //add the campaigns that were found to this list                                  
          list<campaign> foundCampaigns = ((List<campaign>)searchList[0]);

                   IF(foundCampaigns.size() == 0)
                    {
                        apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.info,'No results Returned for: ' + SearchString + '!');
                        apexpages.addmessage(msg);
                    }
                    ELSE
                    {
                          //clear out the list so we only show searched for campaigns
                          VillageCampaigns.clear();
                          SearchHeaderMessage = 'Search results for \'' + SearchString  + '\':' ;
                          FOR(Campaign cCampaign : foundCampaigns)
                          {
                                VillageCampaigns.add(cCampaign);
                          }
                    }
        IF(foundCampaigns.size() == 1)//If there is just one result take the user straight to the redeem page
        {
             IF(foundCampaigns[0].recordtypeid != MICERedeemableCampRecordTypeId)
             {
                PageReference redeempage = new PageReference('/apex/multiaddredemptions?id=' + foundCampaigns[0].id);
                redeempage.setRedirect(true);
                return redeempage;
             }
                
        }
            return null; //Return to the same page
        }
        
    public list<Campaign> getVillageCampaigns()
    {
        return VillageCampaigns;
    }
    
    public id getRedeemableCampRecordTypeId()
    {
        return RedeemableCampRecordTypeId;
    }

    public String getURL()
    {
        return ApexPages.currentPage().getHeaders().get('referer');
    }
    
}//class end