public with sharing class RedeemableCampaignWizardController {

    

//Class properties
private static id RedeemableCampRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Redeemable Campaign').getRecordTypeId();

public Id cID; 

public Campaign GroupCampaign =  null;

//the list sent out to the screen. Users select which ones to add and they are inserted.
list<RedeemableCampaign> newCampaigns = new list<RedeemableCampaign>();

//a list to store all the campaigns that failed because of duplicates
Public list<Campaign> DuplicateCampaigns {get;set;}
public boolean errorsonInsert{get;set;}

public String getGroupCampaignName() {
        return GroupCampaign.Name;
    }
public Pagereference refreshpage(){
    return null;
}

//Constructor
    public RedeemableCampaignWizardController() 
    {
         system.debug('@@@ In the controller, about to setup the data');
         cID = ApexPages.currentPage().getParameters().get('Id'); //grab the Campaign ID
         //get group campaign data given the id sent.
         GroupCampaign =  [SELECT id, Name, Villages__c, Communication_Channel__c, Partner__c, Referred_By__c, 
                                  Contact_Details_Required__c, Multi_Channel_Campaign__c, Multi_Village_Campaign__c,
                                  StartDate, EndDate, status, isActive, Description, COS_Campaign__c
                                  FROM Campaign WHERE id = :cid LIMIT 1];
         setupCampaigns();
         errorsonInsert = false;

    }//end constructor
    
    // overload constructor method to accept Id from script without UI context
    public RedeemableCampaignWizardController(Id campId){
         
         cID = campId;
         //get group campaign data given the id sent.
         GroupCampaign =  [SELECT id, Name, Villages__c, Communication_Channel__c, Partner__c, Referred_By__c,
                                  Contact_Details_Required__c, Multi_Channel_Campaign__c, Multi_Village_Campaign__c,
                                  StartDate, EndDate, status, isActive, Description, COS_Campaign__c
                                  FROM Campaign WHERE id = :cid LIMIT 1];
         setupCampaigns();
         errorsonInsert = false;
        
     } 

     public List<RedeemableCampaign> getCampaigns() 
     {
         return newCampaigns;
     }
 
 public String right(String s, Integer i) {
    if (s == null || s == '' || i <=0 ) {
        return '';
    } else if (i >= s.length()) {
        return s;
    } else {
        return s.subString(s.length() - i, s.length());
    }
} 
 
 
 public void setupCampaigns()
 {
    //get the villages and channel information from the group campaign (setup as a propety 
    set<string> GroupVillages = new set<string>(GroupCampaign.Villages__c.split(';'));
    set<string> GroupChannels = new set<string>(GroupCampaign.Communication_Channel__c.split(';'));
    
    //setup a lookup map to get the Village record from the string.
    MAP<string, Village__c> VillageMap = new MAP<string, Village__c>();
    
    List<Village__c> VillagesLookupList = [SELECT id, Name, Village_code__c FROM Village__c WHERE Name in :GroupVillages];
    system.debug('@@@@VillagesLookupList: '+ VillagesLookupList);
    
    FOR(Village__c cVillage : VillagesLookupList )
    {
        VillageMap.put(cVillage.Name, cVillage );
    }
    //end - setting up the village lookup map
    
    system.debug('@@@ Complete Village lookup MAP: ' + VillageMap);
    
    //Loop through each village on the Group Campaign   
    FOR ( String gVillage : GroupVillages )
    {
        //if Multi_Channel_Campaign__c is selected do not loop, just add the lot.
        IF(GroupCampaign.Multi_Channel_Campaign__c == true)
        {
               RedeemableCampaign cCampaign = new RedeemableCampaign();

               cCampaign.parentcampaignid = cID;
               cCampaign.ParentCampaignName = groupcampaign.Name;
               cCampaign.selected = true;
               //add all the channels from the group campaign.
               cCampaign.Channels = GroupCampaign.Communication_Channel__c;
               cCampaign.ContactDetailsRequired = groupcampaign.Contact_Details_Required__c;
               cCampaign.referredBy = groupcampaign.Referred_By__c;
               cCampaign.Village = VillageMap.get(gVillage);
               
               newCampaigns.add(cCampaign ); 
        }
        ELSE //Split them out
        {
         FOR ( String gChannel : GroupChannels )
          {
               RedeemableCampaign cCampaign = new RedeemableCampaign();
               
               cCampaign.ParentCampaignName = groupcampaign.Name;
               cCampaign.parentcampaignid = cID;
               cCampaign.selected = true;
               cCampaign.Channels = gChannel;
               cCampaign.ContactDetailsRequired = true;
               cCampaign.Village = VillageMap.get(gVillage);
               cCampaign.ContactDetailsRequired = groupcampaign.Contact_Details_Required__c;
               cCampaign.referredBy = groupcampaign.Referred_By__c;
               
               newCampaigns.add(cCampaign ); 
          }//end for
        }//end else     
    }//end for
 }//end setupCampaigns()

Public pagereference Cancel2()
{
        pagereference redirect = new PageReference('/' + cId);
        redirect.setRedirect(true);
        system.debug('@@@@@@@@ CAncel redirect: ' +redirect);
        return redirect;
}    

//INSERT selected campaigns to SF 
    Public pagereference SubmitCampaigns()
    {
    
    list<Campaign> CampaignsToInsert = new list<Campaign> ();
    
    //Loop through the list of records that are selected on the screen and add the ones that are selected to 'CampaignsToInsert'
        FOR ( RedeemableCampaign RCampaign :newCampaigns)
        {
            IF (RCampaign.selected == true)
            {
                Campaign iCampaign = new Campaign();
                iCampaign.recordtypeid = RedeemableCampRecordTypeId;
                //assign the values of the redeemable Campaign from the screen list        
                icampaign.Contact_Details_Required__c = RCampaign.ContactDetailsRequired;
                iCampaign.Name= RCampaign.Village.Village_code__c + String.valueOf(GroupCampaign.StartDate).substring(2,4) + ' - ' + RCampaign.Channels + ' - ' + Right(GroupCampaign.Name, GroupCampaign.Name.length() - 6);
                iCampaign.Village__c = RCampaign.Village.id;
                iCampaign.Communication_Channel__c = RCampaign.Channels;   
                //Grab the info from the Group campaign
                iCampaign.parentid = GroupCampaign.Id;
                iCampaign.StartDate= GroupCampaign.StartDate;
                iCampaign.EndDate= GroupCampaign.EndDate;
                iCampaign.status= GroupCampaign.Status;
                iCampaign.Partner__c = GroupCampaign.Partner__c;
                iCampaign.isActive= GroupCampaign.isActive;
                iCampaign.Description = 'Redeemable Campaign ' + GroupCampaign.Description;
                iCampaign.COS_Campaign__c = GroupCampaign.COS_Campaign__c;
                iCampaign.Referred_By__c = GroupCampaign.Referred_By__c;
                //only populate the Searchable (SOSL) parent_campaign_id__c field IF the group Campaign is a *Multi-Village Campaign*
                //i.e. When we run our SOSL search, the Redeemable campaign will be located(found) if the user searchs for Parent campaign ID (via QR CODE)
                //string fifteendigitparentid = GroupCampaign.Id;
                IF (GroupCampaign.Multi_Village_Campaign__c == true)
                {
                    iCampaign.parent_campaign_id__c = GroupCampaign.Id;
                }   
                CampaignsToInsert.add(iCampaign);
           }//end if
        }//end for
       
        //INSERT CampaignsToInsert;
        Database.SaveResult[] resultList = Database.INSERT(CampaignsToInsert, false);
       
        set<id> duplicatedcampaignids = new set<id>();
        integer SuccessfulInserts = 0;
        integer FailureInserts = 0;
        
        for (Database.SaveResult r : resultList){  // Examine DML errors
                   if (!r.isSuccess()){  
                          for (Database.Error e : r.getErrors()){  
                                 if(e.getStatusCode() == StatusCode.DUPLICATE_VALUE)
                                 {
                                     duplicatedcampaignids.add(right(e.getMessage(),15));           
                                     System.debug('@@@@@' + e.getStatusCode() + ': ' + e.getMessage());
                                     errorsonInsert = true;
                                     FailureInserts++;
                                 }
                          }
                    }
                    else{
                        SuccessfulInserts++;
                    }
        }
        
        system.debug('@@@@@@set of dupes: ' + duplicatedcampaignids);
        
        DuplicateCampaigns = [SELECT id, name, Village__r.name, Communication_Channel__c FROM Campaign WHERE id in :duplicatedcampaignids];
        
        if (errorsonInsert == false){
        
            pagereference redirect = new PageReference('/' + cId);
            redirect.setRedirect(true);
            system.debug('@@@@@@@@'+redirect);
            return redirect;
            }
        else{
            
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,'Campaigns Created Sucessfully:' + SuccessfulInserts + ';      Campaigns with Errors: ' + FailureInserts);
                apexpages.addmessage(msg);
                return null;
            
            }
    }

//This class is used to temporarily hold RedeemableCampaigns that will be added (if selected = true)
    class RedeemableCampaign
    {
        //All fields that need to be set to create the redeemable Campaign
        public string Parentcampaignid { get; set; } //Parent ID
        public string ParentCampaignName{ get; set; }
        public string redeemableCampaignName { get; set; }
        public string referredBy {get; set;}
        public boolean selected{ get; set; } //Whether or not to insert the row
        public string Channels{ get; set; } //Which Channels to set on the rCampaign
        public Village__c Village{ get; set; } //Link to a Village        
        public Account Partner{ get; set; } //Link to an Account
        public Boolean ContactDetailsRequired{ get; set;}    
    }

}//end of controller