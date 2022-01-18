/*
-----How to Call this batchable Class from Dev Console-------
DateTime startDate = Datetime.newInstance(2015,6,12,0,0,0); 
DateTime endDate = Datetime.newInstance(2016,6,30,0,0,0);
transferRedemptionsBatchable myBatchObject = new transferRedemptionsBatchable('701b0000000YSFH',startDate,endDate);     WHERE Arg1 = Campaign Id
Id batchId = Database.executeBatch(myBatchObject);  
*/

global class transferRedemptionsBatchable implements Database.Batchable<sObject> {

    global Integer recordsProcessed = 0;

    private string campaignid;
    private Datetime thisStartDate;
    private Datetime thisEndDate;
    
    

    global transferRedemptionsBatchable(string campid, Datetime startDate, Datetime endDate){
        campaignid = campid;
        thisStartDate = startDate;
        thisEndDate = endDate;
        //System.debug('Start Date = ' + String.valueOf(startDate));
        //System.debug('End Date = ' + String.valueOf(endDate));
        
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
      String sql = 'SELECT Id,visit_type__c,mode_of_transport__c,Country_of_Origin__c, ' +
                 
                 'Voucher_Code__c,Redeem_Date__c,Location__c,Redeemable_Campaign__r.Village__c,Redeemable_Campaign__r.VIP_2_0_Activity_ID__c FROM Promotion_Redemption__c ' +
                 
                 'Where Redeemable_Campaign__c =\'' + campaignid + '\' AND Has_Been_Transfered__c = False AND Redeem_Date__c >= ' + thisStartDate.format('yyyy-MM-dd')  + ' AND Redeem_date__c <= ' + thisEndDate.format('yyyy-MM-dd') + ' ' ;
                 System.debug('This SQL = ' + sql);
            return Database.getQueryLocator(sql); 
        }
        
    
    global void execute(Database.BatchableContext bc, List<Promotion_Redemption__c> records){
    
    boolean error = FALSE;
    system.debug('class records '+records);
    
    LIST<Visit__c> visits = new LIST<Visit__c>();
    LIST<Visit__c> newVisits = new LIST<Visit__c>();
    LIST<Promotion_Redemption__c> updatedReds = new LIST<Promotion_Redemption__c>();
    LIST<VIP_Card_Exchange__c> newVIPCards = new LIST<VIP_Card_Exchange__c>();
    

    recordtype recordtypeid = [SELECT id from Recordtype WHERE name = 'Standard' AND sobjectType = 'Visit__c'];  
           for(Promotion_Redemption__c oldReds : records){             
               
               visit__c v = new Visit__c();
               v.recordtypeid= recordtypeid.id;
               v.Partnership_Promotion__c = oldReds.Redeemable_Campaign__r.VIP_2_0_Activity_ID__c;
               v.village__c = oldReds.Redeemable_Campaign__r.Village__c;
               v.type__c = 'Leisure';   
               v.Visit_Date_Time__c = oldReds.Redeem_Date__c;  
               v.mode_of_transport__c = oldReds.mode_of_transport__c;
               v.country_of_origin__c = oldReds.Country_of_Origin__c;  
               v.location__c = oldReds.location__c; 
               v.number_of_guests__c = 1;
               v.Visit_Notes__c = oldReds.Voucher_Code__c;
               visits.add(v);
               
               oldReds.Has_Been_Transfered__c = TRUE;
               updatedREDS.add(oldReds);
       
           }
       Try{
       system.debug('class visits ' + visits);
       system.debug('class reds ' + updatedReds);
       insert visits;
       update updatedReds;
       }catch(exception ex){
       error = true;
       throw ex;
       }
       //-----------------------------------------
       if(!error){
       LIST<Campaign> updatedcamp = [SELECT id, VIP_2_0_Activity_ID__c,Redemptions_Transfered__c,village__c FROM Campaign WHERE id =:campaignid];
       updatedcamp[0].Redemptions_Transfered__c = updatedcamp[0].Redemptions_Transfered__c + updatedreds.size();
       update updatedcamp[0];
   
           for(Visit__c vis :visits){
           
           VIP_Card_Exchange__c VIP = new VIP_Card_Exchange__c();
           VIP.Visit__c = vis.id;
           VIP.VIP_Card_Code__c = vis.Visit_Notes__c;
           newVIPCards.add(VIP);
                     
           }
           
           insert newVIPCards;
           recordsProcessed = recordsProcessed + 1;
           
        }
    }
    
    global void finish(Database.BatchableContext bc){
   System.debug(recordsProcessed + ' records processed. Shazam!');

   
   }
    
    
}