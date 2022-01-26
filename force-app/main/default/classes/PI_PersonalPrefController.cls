/*
 * @Purpose :-  This controller class is designed to assist the vfp pi_personalpref, which is an extension to the clienteling application in order to allow the clone of
                personal preference records by clienteling users from mobile devices.
 * @CreateBy :- Barry White (Proximity Insight)
 * @CreatedDate :- 18-03-2019

=================================================================================================================================================================================================================================================================================================================================================================================================================================================
 */
public with sharing class PI_PersonalPrefController {

    private Account customer {get;set;}
    public Personal_Shopping_Preference__c personalpref {get;set;}
    public Personal_Shopping_Preference__c originalPersonalpref {get;set;}
    public String message {get;set;}
    public Boolean saved {get;set;}
    
    /*
     * @Description :- Returns either the latest personal preference record or created a new personal preference record
     * @Param :- String
     * @Param :- String 
     * @Returns :- Personal_Shopping_Preference__c
     */
    public PI_PersonalPrefController(ApexPages.StandardController StandardController) {
        list<String> fields = new list<String>{'Id'};
        if(!Test.isRunningTest()){
            StandardController.addFields(fields);
        }
        this.customer = (Account)StandardController.getRecord();

        this.personalpref = getPersonalpref(customer.Id);
        this.saved = false;
    }

    /*
     * @Description :- Returns either the latest personal preference record or created a new personal preference record
     * @Param :- String
     * @Param :- String 
     * @Returns :- Personal_Shopping_Preference__c
     */
    public static Personal_Shopping_Preference__c getPersonalpref(String accountId)
    {
        Personal_Shopping_Preference__c personalPref;

        list<Personal_Shopping_Preference__c> personalPrefs = [  SELECT Body_Shape__c, Body_Size__c, Budget__c,
                                            Colouring__c, Colours__c, Donts__c, Dos__c, 
                                            Expected_Frequency__c, Expected_Frequency_Details__c, External_Personal_Shopping__c,
                                            External_Personal_Shopping_Details__c, Fabrics__c, Lead_Source__c, Lead_Source_Details__c,
                                            Lifestyle__c, Notes__c, Shoe_Size__c,
                                            Size_Type__c,Style__c,  VIP_Guest__c
                                            FROM Personal_Shopping_Preference__c 
                                            WHERE   VIP_Guest__c = : AccountId 
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];

        if(personalPrefs.size() == 1)
        {
            personalPref = personalPrefs[0];
        }
        else 
        {
            personalPref = new Personal_Shopping_Preference__c(VIP_Guest__c = accountId);
        }
        return personalPref;
    }

    /*
     * @Description :- executes the save method for the page, will perform a clone type function
     * @Returns :- void
     */
    public void save(){

        try{
                upsert personalPref;
                message = 'Personal Preferences Saved';
        }catch (System.DmlException ex){
            message = 'Save Failed \n';
            for(Integer i = 0; i < ex.getNumDML(); i++){
                message += ex.getDmlMessage(i) + ' \n';
             }
          }
       }

    }