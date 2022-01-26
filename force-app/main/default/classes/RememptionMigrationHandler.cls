global class RememptionMigrationHandler implements Database.Batchable<sObject>, Database.Stateful{

    global String query;
    global map<id,id> batchcampaignid2newActivityidMap = new map<id,id> ();
    global string batchObjectType = '';
    global list<string> batchidSet;
    
    global RememptionMigrationHandler(id maId){
        batchidSet = new list<string>();
        batchidSet.add(maId);
    }
            
    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        system.debug('MigrateRedemptions Fired. List to process: ' + batchidSet);

        list<group_booking__c> GroupBookingList= new list<group_booking__c> ();
        list<Marketing_Activity__c> MarketingActivityList= new list<Marketing_Activity__c> ();
        //id1 = redeemablecampaignid, id2 = newobjectid

//******discover object type and setup campaignid2newActivityidMap which maps the Redemtion_Campaign_id to groupbBooking/markActy********
        If (batchidSet.get(0).left(3) == 'a0U'){
            batchobjectType = 'GroupBooking';
            GroupBookingList = [SELECT id, Old_Redemption_Campaign_ID__c
                                FROM group_booking__c
                                WHERE id in :batchidSet];
            for(group_booking__c gb : GroupBookingList)
            {
                batchcampaignid2newActivityidMap.put(gb.Old_Redemption_Campaign_ID__c, gb.id );
                
            }
           
        }
        else if (batchidSet[0].left(3) == 'a0y') {
            batchobjectType = 'MarketingActivity';
            MarketingActivityList = [SELECT id, Old_Redemption_Campaign_ID__c 
                                    FROM Marketing_Activity__c
                                    WHERE id in :batchidSet];
            for(Marketing_Activity__c ma : MarketingActivityList)
            {
                batchcampaignid2newActivityidMap.put(ma.Old_Redemption_Campaign_ID__c, ma.id );
            }   
        }
        else{
            batchobjectType = '';
        }
                                                         
                                                                
        set<Id> idList = batchcampaignid2newActivityidMap.keySet(); 
        query = 'SELECT id, Voucher_Code__c, Redeem_Date__c,Visit_Type__c,';
        query += 'Redeemable_Campaign__c,CreatedDate,';       
        query += 'Country_of_Origin__c, customer__r.email__c,Location__c,';
        query += 'Mode_of_Transport__c, Redeemable_Campaign__r.Transfer_Code__c,';
        query += 'Redeemable_Campaign__r.Village__c, Redeemable_Campaign__r.VIP_2_0_Activity_ID__c';
        query += ' FROM Promotion_Redemption__c';
        query += ' WHERE Redeemable_Campaign__r.VIP_2_0_Activity_ID__c = null';
        query += ' AND Redeemable_Campaign__r.Transfer_Code__c in : idList';
                                                        
system.debug('@@@@ query ... ' + query); 
system.debug('@@@@ batchcampaignid2newActivityidMap ... ' + batchcampaignid2newActivityidMap);
                                                       
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Sobject> scope)
    {

 
  //********End of campaignid2newActivityidMap mapping setup******************
 

            map<id, Sobject> Promoid2fullrecordMap = new Map<Id, Sobject>(scope);  


system.debug('@@@ scope ... ' + scope);
system.debug('@@@@ Promoid2fullrecordMap ' + Promoid2fullrecordMap );

system.debug('@@@@ batchcampaignid2newActivityidMap ... 2 .. ' + batchcampaignid2newActivityidMap);
   
            map<string, list<string>> vouchercodeMap = new map<string, list<string>>();
            //loop through all the promo redemptions
            for ( Sobject cpr : Promoid2fullrecordMap.values()){

system.debug('@@@ cpr ... ' + cpr);
system.debug('@@@ vip activity 1 .. ' + string.valueOf(cpr.getSobject('Redeemable_Campaign__r').get('Transfer_Code__c')));
                
                //id newVIPActivity = campaignid2newActivityidMap.get(cpr.Redeemable_Campaign__c);//gets the new VIP activity object ID
                id newVIPActivity = batchcampaignid2newActivityidMap.get(string.valueOf(cpr.getSobject('Redeemable_Campaign__r').get('Transfer_Code__c')));//gets the new VIP activity object ID

                system.debug('newVIPActivity: ' + newVIPActivity);
                
                string key =  string.valueOf(cpr.getSobject('Redeemable_Campaign__r').get('Transfer_Code__c')) + '~' +  string.valueOf(cpr.get('CreatedDate'))  + '~' +  string.valueOf(cpr.get('Mode_of_Transport__c'));
                       key += '~' + string.valueOf(cpr.get('Country_of_Origin__c'));
                       key += '~' + string.valueOf(cpr.getSobject('Redeemable_Campaign__r').get('Village__c')) + '~' + newVIPActivity + '~' + string.valueOf(cpr.get('Location__c')) ;
                
                list<string> voucherCodes =  vouchercodeMap.get(key);
                
                if (voucherCodes==null)
                {
                    voucherCodes = new list<string>();
                }
                
                voucherCodes.add(string.valueOf(cpr.get('Voucher_Code__c')));
                vouchercodeMap.put(key, voucherCodes);  
            }
            
           list<visit__c> NewVisitList = new  list<visit__c>();
           
            for(string cVisit:vouchercodeMap.keyset()){
              
                list<string> visitFields = cVisit.split('~');
            
                visit__c newVisit = new visit__c();
                //visitFields[1] is 2015-08-13 00:00:00
                list<string> dateandtimecomponents = visitFields[1].split(' ');
                list<string> datecomponents = dateandtimecomponents[0].split('-');
                list<string> timecomponents = dateandtimecomponents[1].split(':');
                
                system.debug('unformatted date: ' + visitFields[1]);
                DateTime formateddatetime = DateTime.newInstanceGMT(integer.valueOf(datecomponents[0]), integer.valueOf(datecomponents[1]), integer.valueOf(datecomponents[2]), 
                                                                    integer.valueOf(timecomponents[0]), integer.valueOf(timecomponents[1]), integer.valueOf(timecomponents[2]));
                system.debug('Check in date/time: ' + formateddatetime);
                
                
                newVisit.Visit_Date_Time__c = formateddatetime;
               
                if (visitFields[2] != 'null')
                                            newVisit.Mode_of_Transport__c = visitFields[2];
                if (visitFields[3] != 'null')
                                            newVisit.Country_of_Origin__c  = visitFields[3];
                
                newVisit.Village__c = visitFields[4];
                
                if (batchobjectType == 'GroupBooking'){
                    newVisit.Group_Booking__c = visitFields[5];
                }
                else if (batchobjectType == 'MarketingActivity'){
                    newVisit.Partnership_Promotion__c = visitFields[5];
                }
               newVisit.Migration_Key__c = cvisit; 
               newVisit.type__c = 'Leisure';
               
                if (visitFields[6] != 'null') 
                                 newVisit.Location__c = visitFields[6];
                
               NewVisitList.add(newVisit);
            
            }//end of loop through  vouchercodeMap.keyset 
        insert NewVisitList;
system.debug('@@@ NewVisitList ... ' + NewVisitList);        
                    
      list<visit__c> InsertedVisits = [SELECT id, Migration_Key__c from visit__c where  Migration_Key__c in :vouchercodeMap.keyset() ] ; 
            
            list<VIP_Card_Exchange__c> exchangeList = new list<VIP_Card_Exchange__c>();
                
                for(visit__c v : InsertedVisits ){
                   list<string> VIPcodes = vouchercodeMap.get(v.Migration_Key__c);
                       for (string VIPcode :VIPcodes ){
                           VIP_Card_Exchange__c iVIP = new VIP_Card_Exchange__c();
                           iVIP.Offer_Type__c = 'VIP Card';
                           iVIP.VIP_Card_Code__c = VIPcode;
                           iVIP.Visit__c = v.id;   
                       
                           exchangeList.add(iVIP); 
                       }    
                }
             insert exchangeList;
system.debug('@@@ exchangeList ... ' + exchangeList);        
            //Lock old campaigns (mark them as transfered)
            list<campaign> transferedcampaigns = [SELECT id, Transfer_Code__c, VIP_2_0_Activity_ID__c  FROM campaign
                                                  WHERE Transfer_Code__c in : batchcampaignid2newActivityidMap.keySet()];
            
            for(campaign c: transferedcampaigns){
                c.VIP_2_0_Activity_ID__c = batchcampaignid2newActivityidMap.get(c.Transfer_Code__c);
            }
            update transferedcampaigns;
            



          
    }

    global void finish(Database.BatchableContext BC)
    {
    
    }
                
    @future
    public static void MigrateRedemptions(list<string> idSet)
    {
        system.debug('MigrateRedemptions Fired. List to process: ' + idSet);
        string ObjectType; 
        list<group_booking__c> GroupBookingList= new list<group_booking__c> ();
        list<Marketing_Activity__c> MarketingActivityList= new list<Marketing_Activity__c> ();
        //id1 = redeemablecampaignid, id2 = newobjectid
        map<id,id> campaignid2newActivityidMap = new map<id,id> ();

//******discover object type and setup campaignid2newActivityidMap which maps the Redemtion_Campaign_id to groupbBooking/markActy********
        If (idSet.get(0).left(3) == 'a0U'){
            ObjectType = 'GroupBooking';
            GroupBookingList = [SELECT id, Old_Redemption_Campaign_ID__c
                                FROM group_booking__c
                                WHERE id in :idSet];
            for(group_booking__c gb : GroupBookingList)
            {
                campaignid2newActivityidMap.put(gb.Old_Redemption_Campaign_ID__c, gb.id );
                
            }
           
        }
        else if (idSet[0].left(3) == 'a0y') {
            ObjectType = 'MarketingActivity';
            MarketingActivityList = [SELECT id, Old_Redemption_Campaign_ID__c 
                                    FROM Marketing_Activity__c
                                    WHERE id in :idSet];
            for(Marketing_Activity__c ma : MarketingActivityList)
            {
                campaignid2newActivityidMap.put(ma.Old_Redemption_Campaign_ID__c, ma.id );
            }   
        }
        else{
            ObjectType = '';
        }
  //********End of campaignid2newActivityidMap mapping setup******************
 
        if (string.isNotBlank(ObjectType))
        {
      
            
        //map of promo redemptions. The id part can translate to booking/activity using the campaignid2newActivityidMap     
        map<id, Promotion_Redemption__c> Promoid2fullrecordMap =  new map<Id,Promotion_Redemption__c>( [
                                                        SELECT id, Voucher_Code__c, Redeem_Date__c,Visit_Type__c,
                                                        Redeemable_Campaign__c,CreatedDate,
                                                        Country_of_Origin__c, customer__r.email__c,Location__c,
                                                        Mode_of_Transport__c, Redeemable_Campaign__r.Transfer_Code__c,
                                                        Redeemable_Campaign__r.Village__c, Redeemable_Campaign__r.VIP_2_0_Activity_ID__c
                                                        FROM Promotion_Redemption__c
                                                        WHERE Redeemable_Campaign__r.VIP_2_0_Activity_ID__c = null
                                                        AND Redeemable_Campaign__r.Transfer_Code__c in :campaignid2newActivityidMap.keyset()]);
   
            map<string, list<string>> vouchercodeMap = new map<string, list<string>>();
            //loop through all the promo redemptions
            for ( Promotion_Redemption__c cpr : Promoid2fullrecordMap.values()){
                
                //id newVIPActivity = campaignid2newActivityidMap.get(cpr.Redeemable_Campaign__c);//gets the new VIP activity object ID
                id newVIPActivity = campaignid2newActivityidMap.get(cpr.Redeemable_Campaign__r.Transfer_Code__c);//gets the new VIP activity object ID
                system.debug('looking up cpr.Redeemable_Campaign__c in map: ' + cpr.Redeemable_Campaign__c);
                system.debug('cprID: ' + cpr.Id);
                system.debug('newVIPActivity: ' + newVIPActivity);
                
                string key =  cpr.Redeemable_Campaign__r.Transfer_Code__c + '~' +  cpr.CreatedDate  + '~' +  cpr.Mode_of_Transport__c + '~' + cpr.Country_of_Origin__c;
                       key += '~' + cpr.Redeemable_Campaign__r.Village__c + '~' + newVIPActivity + '~' + cpr.Location__c ;
                
                list<string> voucherCodes =  vouchercodeMap.get(key);
                
                if (voucherCodes==null)
                {
                    voucherCodes = new list<string>();
                }
                
                voucherCodes.add(cpr.Voucher_Code__c);
                vouchercodeMap.put(key, voucherCodes);  
            }
            
           list<visit__c> NewVisitList = new  list<visit__c>();
           
            for(string cVisit:vouchercodeMap.keyset()){
              
                list<string> visitFields = cVisit.split('~');
            
                visit__c newVisit = new visit__c();
                //visitFields[1] is 2015-08-13 00:00:00
                list<string> dateandtimecomponents = visitFields[1].split(' ');
                list<string> datecomponents = dateandtimecomponents[0].split('-');
                list<string> timecomponents = dateandtimecomponents[1].split(':');
                
                system.debug('unformatted date: ' + visitFields[1]);
                DateTime formateddatetime = DateTime.newInstanceGMT(integer.valueOf(datecomponents[0]), integer.valueOf(datecomponents[1]), integer.valueOf(datecomponents[2]), 
                                                                    integer.valueOf(timecomponents[0]), integer.valueOf(timecomponents[1]), integer.valueOf(timecomponents[2]));
                system.debug('Check in date/time: ' + formateddatetime);
                
                
                newVisit.Visit_Date_Time__c = formateddatetime;
               
                if (visitFields[2] != 'null')
                                            newVisit.Mode_of_Transport__c = visitFields[2];
                if (visitFields[3] != 'null')
                                            newVisit.Country_of_Origin__c  = visitFields[3];
                
                newVisit.Village__c = visitFields[4];
                
                if (ObjectType == 'GroupBooking'){
                    newVisit.Group_Booking__c = visitFields[5];
                }
                else if (ObjectType == 'MarketingActivity'){
                    newVisit.Partnership_Promotion__c = visitFields[5];
                }
               newVisit.Migration_Key__c = cvisit; 
               newVisit.type__c = 'Leisure';
               
                if (visitFields[6] != 'null') 
                                 newVisit.Location__c = visitFields[6];
                
               NewVisitList.add(newVisit);
            
            }//end of loop through  vouchercodeMap.keyset 
        insert NewVisitList;
            
      list<visit__c> InsertedVisits = [SELECT id, Migration_Key__c from visit__c where  Migration_Key__c in :vouchercodeMap.keyset() ] ; 
            
            list<VIP_Card_Exchange__c> exchangeList = new list<VIP_Card_Exchange__c>();
                
                for(visit__c v : InsertedVisits ){
                   list<string> VIPcodes = vouchercodeMap.get(v.Migration_Key__c);
                       for (string VIPcode :VIPcodes ){
                           VIP_Card_Exchange__c iVIP = new VIP_Card_Exchange__c();
                           iVIP.Offer_Type__c = 'VIP Card';
                           iVIP.VIP_Card_Code__c = VIPcode;
                           iVIP.Visit__c = v.id;   
                       
                           exchangeList.add(iVIP); 
                       }    
                }
             insert exchangeList;
        
            //Lock old campaigns (mark them as transfered)
            list<campaign> transferedcampaigns = [SELECT id, Transfer_Code__c, VIP_2_0_Activity_ID__c  FROM campaign
                                                  WHERE Transfer_Code__c in : campaignid2newActivityidMap.keySet()];
            
            for(campaign c: transferedcampaigns){
                c.VIP_2_0_Activity_ID__c = campaignid2newActivityidMap.get(c.Transfer_Code__c);
            }
            update transferedcampaigns;
            
        }//end of isNotBlank(ObjectType) IF
        
            
        
    }
    
}