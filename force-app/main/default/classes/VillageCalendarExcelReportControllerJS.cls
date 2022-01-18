Global Class VillageCalendarExcelReportControllerJS{

    global List<SelectOption> businessFunctionOptions {get;set;}
    global List<SelectOption> channelOptions {get;set;}
    
    
    global VillageCalendarExcelReportControllerJS(){
        businessFunctionOptions = new List<SelectOption>{new SelectOption('', '')};
        channelOptions = new List<SelectOption>{new SelectOption('', '')};

        List<Schema.PicklistEntry> bFunctionPicklist = Marketing_Activity__c.Business_Function__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : bFunctionPicklist){
            businessFunctionOptions.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        }

        List<Schema.PicklistEntry> channelPicklist = Marketing_Activity__c.Channel__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : channelPicklist){
            channelOptions.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        }
    }

    /////////////////////////////////////Rolling Focus View//////////////////////////////////////////
    @RemoteAction
    global static string readThemeandCampaignsbyFocus(boolean Tbvsc,string Village, list<string> focusList, string queryYear, string theQuarter, String businessFunction, String channel){

        String instanceURL = URL.getSalesforceBaseUrl().toExternalForm();
        date theDate;

        if(queryYear != ''){
            theDate = date.newInstance( Integer.valueof(queryYear), 01, 01);
        }
        else{
            theDate = Date.today();
        }
        
        system.debug('theDate - ' + theDate);
        integer theMonth = theDate.month();
        integer theyear = theDate.year();

        system.debug('theMonth ' + theMonth);
        system.debug('theyear ' + theyear);
        

        date theStart = date.newInstance(theyear, theMonth, 01);
        date theEnd = date.newInstance(theyear + 1, theMonth - 1 , date.daysInMonth(theyear + 1, theMonth -1));
        integer theEndYear = theEnd.year();


        map<integer, string> colourMap = new map<integer, string>();
        colourMap.put(1,'#ffc7b3');
        colourMap.put(2,'#bef4f1');
        colourMap.put(3,'#d3f8d3');
        colourMap.put(4,'#ffc7b3');
        colourMap.put(5,'#bef4f1');
        colourMap.put(6,'#d3f8d3');
        colourMap.put(7,'#ffc7b3');
        colourMap.put(8,'#bef4f1');
        colourMap.put(9,'#d3f8d3');
        colourMap.put(10,'#ffc7b3');
        colourMap.put(11,'#bef4f1');

        map<integer, string> MonthColMap = new map<integer, string>();
        MonthColMap.put(1,'Jan');
        MonthColMap.put(2,'Feb');
        MonthColMap.put(3,'Mar');
        MonthColMap.put(4,'Apr');
        MonthColMap.put(5,'May');
        MonthColMap.put(6,'Jun');
        MonthColMap.put(7,'Jul');
        MonthColMap.put(8,'Aug');
        MonthColMap.put(9,'Sept');
        MonthColMap.put(10,'Oct');
        MonthColMap.put(11,'Nov');
        MonthColMap.put(12,'Dec');

        map<string, integer> standardWeeksInMonthMap = new map<string, integer>();
        integer ii = 1;
        integer y = 0;
        while ( y < 3){
            while(ii <= 12){
                standardWeeksInMonthMap.put(string.valueof(ii)+string.valueof(theyear+y),mondayCount(ii, theyear+y));
                ii ++ ;
            }
            y ++ ;
            ii = 1;
        }


        for(string str : standardWeeksInMonthMap.keyset() ){
            system.debug('standardWeeksInMonthMap ---- ' + str + ' standardWeeksInMonthMap.value : ' + standardWeeksInMonthMap.get(str));
        }



        map<string, integer> weeksInYearMap = new map<string, integer>();
        integer cumulativeWeeksInYear = 0;

        integer cumulativeTotalweeks = 0;
        map<string, integer> standardCumulativeWeeksInMonthMap = new map<string, integer>();
        for(string str : standardWeeksInMonthMap.keyset() ){
                cumulativeWeeksInYear = cumulativeWeeksInYear + standardWeeksInMonthMap.get(str);
                cumulativeTotalweeks = cumulativeTotalweeks + standardWeeksInMonthMap.get(str);
                standardCumulativeWeeksInMonthMap.put(str,cumulativeTotalweeks);  
                if(str.left(str.length()-4) == '12'){
                    weeksInYearMap.put(str.right(4),cumulativeWeeksInYear);
                    cumulativeWeeksInYear = 0;
                }          
        }

         system.debug('weeksInYearMap : ' + weeksInYearMap);

        for(string str : standardCumulativeWeeksInMonthMap.keyset() ){
            system.debug('standardCumulativeWeeksInMonthMap ---- ' + str + ' standardCumulativeWeeksInMonthMap.value : ' + standardCumulativeWeeksInMonthMap.get(str));
        }



        map<string, integer> monthSegmentMap = new map<string, integer>();
        list<string> monthSegmentList = new list<string>();
        integer yi = 1;
        integer thisMonth = theMonth;
        integer thisYearVal = theyear;
        string thisYear = string.valueof(thisYearVal);
        while(yi <= 12){

            monthSegmentMap.put(string.valueof(thisMonth)+thisYear,standardWeeksInMonthMap.get(string.valueof(thisMonth)+string.valueof(thisYear)));
            monthSegmentList.add(string.valueof(thisMonth)+thisYear);
            
            if(thisMonth + 1 == 13){
                thisMonth = 0;
                thisYear = string.valueof(thisYearVal + 1);
                system.debug('thisYearVal inside loop ' + thisYearVal);
            }

            thisMonth ++ ; 
            yi ++ ;
        }

        for(string str : monthSegmentMap.keyset() ){
            system.debug('monthSegmentMap ---- ' + str + ' monthSegmentMap.value : ' + monthSegmentMap.get(str));
        }

        for(string str : monthSegmentList ){
            system.debug('monthSegmentList ---- ' + str );
        }    

        map<string, integer> cumulativeMonthSegmentMap = new map<string, integer>();
        integer c = 0;
        for(string str : monthSegmentMap.keyset() ){
            c = c + monthSegmentMap.get(str);
            cumulativeMonthSegmentMap.put(str,c);
        }

        for(string str : cumulativeMonthSegmentMap.keyset() ){
            system.debug('cumulativeMonthSegmentMap ---- ' + str + ' ---- ' + cumulativeMonthSegmentMap.get(str) );
        }   
         
        

        list<integer> WeekValues = monthSegmentMap.values();
        integer totalWeeks = 0;
        for(integer val : WeekValues ){
            system.debug('week val : ' + val);
            totalWeeks += val;
            system.debug('totalWeeks : ' + totalWeeks);
        }

        map<string, integer> WeekinMonthMap = new map<string, integer>();

        integer cumulativeTotal = 0;
        for(string str : monthSegmentMap.keyset() ){
            cumulativeTotal = cumulativeTotal + monthSegmentMap.get(str);
            WeekinMonthMap.put(str, standardCumulativeWeeksInMonthMap.get(str));
        }

        for(string str : WeekinMonthMap.keyset() ){
            system.debug('WeekinMonthMap ---- ' + str + ' WeekinMonthMap.value : ' + WeekinMonthMap.get(str));
        }




        map<integer, string> MonthColMapRolling = new map<integer, string>();
        integer j = 0;
        integer k = 1;
        integer monthForLoop = theMonth;
        WHILE(j < 12){
            if(monthForLoop == 13){
                monthForLoop = 1;
            }
            MonthColMapRolling.put(k,MonthColMap.get(monthForLoop));
             j ++ ;
             k ++ ;
             monthForLoop ++ ;
        }

        ///-------------------------------
        
        ID TBVSCBrandCampaign = [SELECT ID, Name FROM RecordType Where sObjectType = 'Marketing_Campaign__c' and NAME = 'TBVSC Brand Campaign'].id;
        
        ID VilCampRecId = [SELECT ID, Name FROM RecordType Where sObjectType = 'Marketing_Campaign__c' and NAME = 'Village Campaign'].id;
        
        List<Marketing_Campaign__c> tbvscCampaignsList = new List<Marketing_Campaign__c>();
        List<Marketing_Campaign__c> TacticalCamps = new List<Marketing_Campaign__c>();
        if(theQuarter == 'NA'){
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c
                                 WHERE RecordTypeiD = :VilCampRecId
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd)
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd)
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd)
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart))
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name 
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];               
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd)
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q1'){
            theStart = date.newInstance(theStart.year(), 01, 01);
            theEnd = date.newInstance(theEnd.year(), 03, 31);
            if(Village != 'All Villages'){    
               TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                Village_Marketing_Budget__c, Village__r.Name
                                FROM Marketing_Campaign__c 
                                WHERE RecordTypeiD = :VilCampRecId 
                                AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                     OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                     OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                     OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU' 
                                AND Status__c != 'Cancelled' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                ORDER BY Start_Date__c ASC]; 
            }
            else if(Village == 'All Villages'){
               TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                Village_Marketing_Budget__c, Village__r.Name
                                FROM Marketing_Campaign__c 
                                WHERE RecordTypeiD = :VilCampRecId 
                                AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                     OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                     OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                     OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                And Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                ORDER BY Start_Date__c ASC];
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q2'){
            theStart = date.newInstance(theStart.year(), 04, 01);
            theEnd = date.newInstance(theEnd.year(), 06, 30);
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart))
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village And Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village And Campaign_Focus__c != 'BAU'  
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode,Name,Campaign_Focus__c,start_date__c,end_date__c,Accumulated_Campaign_Expected_Sales__c,Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                 And Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q3'){
            theStart = date.newInstance(theStart.year(), 07, 01);
            theEnd = date.newInstance(theEnd.year(), 09, 31);
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 From Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village And Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village And Campaign_Focus__c != 'BAU' 
                                 And Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];    
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c , Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU' 
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                      Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q4'){
            theStart = date.newInstance(theStart.year(), 10, 01);
            theEnd = date.newInstance(theEnd.year(), 12, 31);
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'  
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'  
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU' 
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q1-Q2'){
            theStart = date.newInstance(theStart.year(), 01, 01);
            theEnd = date.newInstance(theEnd.year(), 06, 30);
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'  
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU' 
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];                
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd)
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU' 
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q2-Q3'){
            theStart = date.newInstance(theStart.year(), 04, 01);
            theEnd = date.newInstance(theEnd.year(), 09, 31);
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU' 
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart))
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart))
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                      AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU'
                                      AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                      ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        else if(theQuarter == 'Q3-Q4'){
            theStart = date.newInstance(theStart.year(), 07, 01);
            theEnd = date.newInstance(theEnd.year(), 12, 31);
            if(Village != 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Village__r.name =: Village AND Campaign_Focus__c != 'BAU' 
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            else if(Village == 'All Villages'){
                TacticalCamps = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c,
                                 Village_Marketing_Budget__c, Village__r.Name
                                 FROM Marketing_Campaign__c 
                                 WHERE RecordTypeiD = :VilCampRecId 
                                 AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                      OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                      OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                 //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                 AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU' 
                                 AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                 ORDER BY Start_Date__c ASC];
            }
            if(Tbvsc == True){
                tbvscCampaignsList = [SELECT ID, CurrencyIsoCode, Name, Campaign_Focus__c, start_date__c, end_date__c, Accumulated_Campaign_Expected_Sales__c, Accumulated_Campaign_Expected_Footfall__c, Village_Marketing_Budget__c 
                                      FROM Marketing_Campaign__c 
                                      WHERE RecordTypeiD = :TBVSCBrandCampaign 
                                      AND ((Start_Date__c <=: theStart AND End_Date__c >=: theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c >=: theEnd AND start_date__c <= :theEnd) 
                                           OR (Start_Date__c >=: theStart AND End_Date__c <=: theEnd) 
                                           OR (Start_Date__c <=: theStart AND End_Date__c <=: theEnd AND End_Date__c >=: theStart)) 
                                      //AND Status__c != 'Cancelled' AND Status__c != 'Removed' AND Campaign_Focus__c != 'BAU'
                                        AND Status__c != 'Cancelled' AND Campaign_Focus__c != 'BAU' 
                                                                                                  AND Campaign_Focus__c != 'Non-Campaigns' AND Campaign_Focus__c in: focusList 
                                                                                                  ORDER BY Start_Date__c ASC];
                for(Marketing_Campaign__c tbvscCampaigns : tbvscCampaignsList){
                    TacticalCamps.add(tbvscCampaigns);
                }
            }
        }
        system.debug('TACTICAL CAMPAIGNSSSSSSSSSSSSSSSSSSSSSSSs - ' + TacticalCamps);

        Map<Id, Marketing_Campaign__c> campaignMap = new Map<Id, Marketing_Campaign__c>();
        List<Marketing_Activity__c> activityList = new List<Marketing_Activity__c>();
        List<Marketing_Campaign__c> campaignList = new List<Marketing_Campaign__c>();

        if(TacticalCamps != null && !TacticalCamps.isEmpty() && (channel != '' || businessFunction != '')){
            for(Marketing_Campaign__c camp : TacticalCamps){
                campaignMap.put(camp.Id, camp);
            }
            
            if(channel != '' && businessFunction != ''){
                activityList = [SELECT Id, Channel__c, Business_Function__c, Marketing_Campaign__c
                            FROM Marketing_Activity__c 
                            WHERE Marketing_Campaign__c IN :campaignMap.keyset()
                            AND Channel__c = :channel
                            AND Business_Function__c = :businessFunction];
            }
            else if(channel != '' && businessFunction == ''){
                activityList = [SELECT Id, Channel__c, Business_Function__c, Marketing_Campaign__c
                            FROM Marketing_Activity__c 
                            WHERE Marketing_Campaign__c IN :campaignMap.keyset()
                            AND Channel__c = :channel];
            }else{
                activityList = [SELECT Id, Channel__c, Business_Function__c, Marketing_Campaign__c
                            FROM Marketing_Activity__c 
                            WHERE Marketing_Campaign__c IN :campaignMap.keyset()
                            AND Business_Function__c = :businessFunction];
            }
            
            if(activityList != null && !activityList.isEmpty()){
                for(Marketing_Activity__c act : activityList){
                    if(campaignMap.keyset().contains(act.Marketing_Campaign__c)){
                        campaignList.add(campaignMap.get(act.Marketing_Campaign__c));
                    }
                }
            }
            if(campaignList != null & !campaignList.isEmpty()){
                TacticalCamps = campaignList;
            }
            else{
                TacticalCamps = new List<Marketing_Campaign__c>();
            }
        }

        //Get the values chosen from the focus picklist
        system.debug('line 1035');
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Marketing_Campaign__c.Campaign_Focus__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        system.debug('line 1042');
 
        map<string, set<Marketing_Campaign__c>> focusMap = new map<string, set<Marketing_Campaign__c>>();
            for(string str : pickListValuesList){
                focusMap.put(str,new set<Marketing_Campaign__c>());
        }

        system.debug('line 1049');
        
        //Add Marketing capaign to the correspondent set (get(keyset).add(value))
        for(Marketing_Campaign__c MC : TacticalCamps){
            focusMap.get(MC.Campaign_Focus__c).add(MC);
        }
        system.debug('line 1054');
        
        String theHTML;
        
        //draw the table caption / title
        if(TacticalCamps.size() > 0){
            theHTML = '<table id="my-table-id" style="table-layout: auto;" border="1" width="1500" ><caption><center><b> 12 Month ('+MonthColMapRolling.get(1)+' '+theyear+' - ' +MonthColMapRolling.get(12)+' '+theEndYear+') Campaign Calendar</b></center></caption><tr>';
        }
        else{
            theHTML = '<table id="my-table-id" style="table-layout: auto;" border="1" width="1500" ><caption><center><b> No Marketing Campaigns </b></center></caption><tr>';
        }

        map<String, Map<String, set<Marketing_Campaign__c>>> marketingCampaignsMap = new Map<String, Map<String, set<Marketing_Campaign__c>>>();
        
        if(tbvsc == true && !tbvscCampaignsList.isEmpty()){
            marketingCampaignsMap.put('TBVSC Brand Campaign', new map<String, set<Marketing_Campaign__c>>());
        }
        
        
        //Create the Map which contains Marketing campaigns organized by Village and Campaign Focus
        for(String marketingCampaignFocus : focusMap.keyset()){
            if (!focusMap.get(marketingCampaignFocus).isEmpty()){
                for(Marketing_Campaign__c marketingCampaign : focusMap.get(marketingCampaignFocus)){
                    if(marketingCampaign.RecordTypeId == VilCampRecId){
                        if(!marketingCampaignsMap.keyset().contains(marketingCampaign.Village__r.Name)){
                            marketingCampaignsMap.put(marketingCampaign.Village__r.Name, new Map<String, set<Marketing_Campaign__c>> {marketingCampaign.Campaign_Focus__c => new set<Marketing_Campaign__c>{marketingCampaign}});
                        }
                        else{
                            if(!marketingCampaignsMap.get(marketingCampaign.Village__r.Name).keyset().contains(marketingCampaign.Campaign_Focus__c)){
                                marketingCampaignsMap.get(marketingCampaign.Village__r.Name).put(marketingCampaign.Campaign_Focus__c, new set<Marketing_Campaign__c>{marketingCampaign});      
                            }
                            else{
                                marketingCampaignsMap.get(marketingCampaign.Village__r.Name).get(marketingCampaign.Campaign_Focus__c).add(marketingCampaign);
                            }
                        }
                    }
                    else if(marketingCampaign.RecordTypeId == TBVSCBrandCampaign){
                        if(!marketingCampaignsMap.get('TBVSC Brand Campaign').keyset().contains(marketingCampaign.Campaign_Focus__c)){
                            marketingCampaignsMap.get('TBVSC Brand Campaign').put(marketingCampaign.Campaign_Focus__c, new set<Marketing_Campaign__c>{marketingCampaign});
                            
                        }
                        else{
                            marketingCampaignsMap.get('TBVSC Brand Campaign').get(marketingCampaign.Campaign_Focus__c).add(marketingCampaign);
                        }
                    }
                }
            }
        }
        
        map<String, Map<String, set<Marketing_Campaign__c>>> orderedMarketingCampaignsMap = new map<String, Map<String, set<Marketing_Campaign__c>>>();
        List<String> orderedVillagesList = new List<String>();
        for(String mtkCamp : marketingCampaignsMap.keySet()){
            if(mtkCamp != 'TBVSC Brand Campaign'){
                orderedVillagesList.add(mtkCamp);
            }
           
        }
        orderedVillagesList.sort();
        if(tbvsc == true && !tbvscCampaignsList.isEmpty()){
            orderedMarketingCampaignsMap.put('TBVSC Brand Campaign', marketingCampaignsMap.get('TBVSC Brand Campaign'));
        }
              
        for(String village2 : orderedVillagesList){
            orderedMarketingCampaignsMap.put(village2, marketingCampaignsMap.get(village2));
        }
        
        
        Integer columnNumber = totalWeeks +1;
        Boolean hasTbvscHeader = False;
        if(orderedMarketingCampaignsMap.keySet().contains('TBVSC Brand Campaign')){
            theHTML += '<tr><th colspan = "'+ columnNumber +'" id="header_TBVSC" bgcolor="#cccccc" > GROUP </th></tr>';   
            hasTbvscHeader = True;
        }
        else if (!orderedMarketingCampaignsMap.keySet().isEmpty()){
            theHTML += '<tr><th id="header_Village" bgcolor="#cccccc" colspan="'+ columnNumber +'"> Villages </th></tr>';
        }
        for(String marketingCampaignVillage : orderedMarketingCampaignsMap.keySet()){
            
            theHTML += '<td bgcolor="#cccccc">';
            
            //Draw the month values across the table headers

            for(string str : monthSegmentList){
                system.debug('the str loop' + str);
                integer length = str.length();
                theHTML += '<th id="header'+str+'" bgcolor="#cccccc" colspan="'+monthSegmentMap.get(str)+'">' + MonthColMap.get(integer.valueof(str.left(length-4))) +'</th>';
            }
            
            theHTML += '</tr>';
            
            if(marketingCampaignVillage != 'TBVSC Brand Campaign'){
                theHtml += '</tr><tr><th bgcolor="#cccccc">' + marketingCampaignVillage + '</th>';
            }
            else{
                theHtml += '</tr><tr><th bgcolor="#cccccc"></th>';
            }
            
            system.debug('string.valueof(theMonth) ' + string.valueof(theMonth));
            system.debug('string.valueof(theyear))' + string.valueof(theyear));
    
            system.debug('string.valueof(theMonth)+string.valueof(theyear)) ' +  string.valueof(theMonth)+string.valueof(theyear));
            system.debug('standardCumulativeWeeksInMonthMap.get(string.valueof(theMonth)+string.valueof(theyear))' + standardCumulativeWeeksInMonthMap.get(string.valueof(theMonth)+string.valueof(theyear)));
            system.debug('monthSegmentMap.get(string.valueof(theMonth)+string.valueof(theyear))' + monthSegmentMap.get(string.valueof(theMonth)+string.valueof(theyear)));
    
            //Draw the wk number values across the table underneath the respective month
            integer y2 = standardCumulativeWeeksInMonthMap.get(string.valueof(theMonth)+string.valueof(theyear))-monthSegmentMap.get(string.valueof(theMonth)+string.valueof(theyear))+1;
            system.debug('y2 : ' + y2);
            integer iii = 1;
                while ( iii <= totalWeeks ){
                    if(y2 > weeksInYearMap.get(string.valueof(theyear)) ){
                        y2 = 1;
                    }
                theHTML += '<th id="wkheader'+y2+'" bgcolor="#cccccc" colspan="1">' + y2 +'</th>';
                system.debug('y = :' + y2);
                system.debug('ii = :' + iii);
                y2 ++ ;
                iii ++;
                }
            theHTML += '</tr>';
            
                    
  
            //////////TacticalCamps CAMPAIGNS//////////////////////
            integer colour = 1; 
            
            //currency formatting for Village_Marketing_Budget__c
            List<String> args = new String[]{'0','number','###,###,##0.00'};
            for(string str : orderedMarketingCampaignsMap.get(marketingCampaignVillage).keyset()){
    
                
    
                integer n = 1; 
    
                for(Marketing_Campaign__c MC :orderedMarketingCampaignsMap.get(marketingCampaignVillage).get(str)){
    
    
                    // The start (MC.Start_Date__c) and end (MC.End_Date__c) date of the current Campaign 
                    // Variables theStart and theEnd correspond to the beginning and ending of the calendar
                    string originalStartDate = String.valueOf(MC.Start_Date__c.format());
                    string originalEndDate = String.valueOf(MC.End_Date__c.format());
    
                    system.debug(MC.Name + '  ------thestart : ' + theStart + '----- MC.start: ' + MC.Start_Date__c  );
                    system.debug(MC.name + ' -----theEnd : ' + theEnd + '----- MC.end: ' + MC.End_Date__c  );
    
                    if(MC.Start_Date__c < theStart ){
                        MC.Start_Date__c = theStart;
                    }
    
                    if(MC.End_Date__c > theEnd ){
                        MC.End_Date__c = theEnd;
                    }
    
                    system.debug(MC.Name + '  ------thestartafter : ' + theStart + '----- MC.start: ' + MC.Start_Date__c  );
                    system.debug(MC.name + ' -----theEndafter : ' + theEnd + '----- MC.end: ' + MC.End_Date__c  );
    
                    integer startVal = cumulativeMonthSegmentMap.get(string.valueof(MC.start_date__c.month())+string.valueof(MC.start_date__c.year())) - monthSegmentMap.get(string.valueof(MC.start_date__c.month())+string.valueof(MC.start_date__c.year()));
                        system.debug(MC.Name + '   startVal start ' + startVal);
    
                        Date weekStart = MC.start_date__c.toStartOfMonth();
                        Datetime dt = DateTime.newInstance(weekStart, Time.newInstance(0, 0, 0, 0));
                        String dw = dt.format('EEEE'); 
    
                        system.debug(MC.name + ' ---- start of month ---  ' + dw);
    
                        startval = startval + startWeek(MC.start_date__c);
    
    
                    integer endVal =  cumulativeMonthSegmentMap.get(string.valueof(MC.end_date__c.month())+string.valueof(MC.end_date__c.year())) - monthSegmentMap.get(string.valueof(MC.end_date__c.month())+string.valueof(MC.end_date__c.year()));
                       system.debug(MC.Name + '   endVal start ' + endVal);
    
                       endVal = endVal + endWeek(MC.end_date__c);                 
                       
    
                    integer weekspreceeding = startVal ;
                    integer weeksTrailing = weeksInYearMap.get(string.valueof(theyear)) - endVal;
                    integer weeksinBetween = weeksInYearMap.get(string.valueof(theyear)) - weeksTrailing - weekspreceeding;
                    //integer weeksinBetween = endVal - startVal + 1;
    
                    system.debug(MC.Name + '   startVal final ' + startVal);
                    system.debug(MC.Name + '   endVal final ' + endVal);
                    system.debug(MC.Name + '   weekspreceeding ' + weekspreceeding);
                    system.debug(MC.Name + '   weeksTrailing ' + weeksTrailing);
                    system.debug(MC.Name + '   weeksinBetween ' + weeksinBetween);
    
                    
                    Decimal VMB1 = MC.Village_Marketing_Budget__c;
                        if(MC.Village_Marketing_Budget__c == null){
                            VMB1 = 0.00;
                        }
    
                    string VMB = String.format(VMB1.format(), args);
    
    
                    Decimal VM ;
    
                    IF(MC.Accumulated_Campaign_Expected_Footfall__c == null){
                        VM = 0;
                    }else {
                        VM = MC.Accumulated_Campaign_Expected_Footfall__c;
                    }
                      
                    String expFF = 'ExpFF: ';  
                    String VM1 = String.format(VM.format(), args);
    
                    
                    Decimal VMSales ;
    
                    IF(MC.Accumulated_Campaign_Expected_Sales__c == null){
                        VMSales = 0.00;
                    }else {
                        VMSales = MC.Accumulated_Campaign_Expected_Sales__c;
                    }
    
                      
                    String expSales = 'ExpSales: ';  
                    String VM2 = String.format(VMSales.format(), args);
    
    
    
    
                    //theHtml += '<tr id="tabRow" align="center"><td bgcolor="'+colourMap.get(colour)+'"><b>'+str+'</b></td><td colspan="'+weekspreceeding+'"></td>' + '<td bgcolor="'+colourMap.get(colour)+'" colspan="'+weeksinBetween+'"><a href="'+instanceURL+'/'+MC.id+'">'+MC.Name+' : '+MC.CurrencyIsoCode+' : '+VMB+'<br>'+originalStartDate+' -- '+originalEndDate+'</br></a></td>' + '<td colspan="'+weeksTrailing+'"></td></tr>';
    
                    //spans the whole table
                    if(weeksinBetween == weeksInYearMap.get(string.valueof(theyear))){
                        theHtml += '<tr id="tabRow" align="center"><td bgcolor="'+colourMap.get(colour)+'"><b>'+str+'</b></td><td bgcolor="'+colourMap.get(colour)+'" colspan="'+weeksinBetween+'" ><a href="'+instanceURL+'/'+MC.id+'">'+MC.Name+' : '+MC.CurrencyIsoCode+' : '+VMB+ '<br>' +expFF+ VM1+ ' ' +expSales+ VM2+' <br>'+originalStartDate+' -- '+originalEndDate+'</br></a></td></tr>';
                    }
                    //spans weeks pre and weeks between
                    else if(weekspreceeding > 0 && weeksTrailing == 0 ){
                        theHtml += '<tr id="tabRow" align="center"><td bgcolor="'+colourMap.get(colour)+'"><b>'+str+'</b></td><td colspan="'+weekspreceeding+'"></td>' + '<td bgcolor="'+colourMap.get(colour)+'" colspan="'+weeksinBetween+'" ><a href="'+instanceURL+'/'+MC.id+'">'+MC.Name+' : '+MC.CurrencyIsoCode+' : '+VMB+ '<br>' +expFF+ VM1+ ' ' +expSales+ VM2+'<br>'+originalStartDate+' -- '+originalEndDate+'</br></a></td></tr>';
                    }
    
                    else if(weeksTrailing > 0 && weekspreceeding == 0 ){
                        theHtml += '<tr id="tabRow" align="center"><td bgcolor="'+colourMap.get(colour)+'"><b>'+str+'</b></td><td bgcolor="'+colourMap.get(colour)+'" colspan="'+weeksinBetween+'" ><a href="'+instanceURL+'/'+MC.id+'">'+MC.Name+' : '+MC.CurrencyIsoCode+' : '+VMB+ '<br>' +expFF+ VM1+ ' ' +expSales+ VM2+'<br>'+originalStartDate+' -- '+originalEndDate+'</br></a></td>' + '<td colspan="'+weeksTrailing+'"></td></tr>';
                    }
    
                    else{
                        theHtml += '<tr id="tabRow" align="center"><td bgcolor="'+colourMap.get(colour)+'"><b>'+str+'</b></td><td colspan="'+weekspreceeding+'"></td>' + '<td bgcolor="'+colourMap.get(colour)+'" colspan="'+weeksinBetween+'"><a href="'+instanceURL+'/'+MC.id+'">'+MC.Name+' : '+MC.CurrencyIsoCode+' : '+VMB+ '<br>' +expFF+ VM1+ ' ' +expSales+ VM2+'<br>'+originalStartDate+' -- '+originalEndDate+'</br></a></td>' + '<td colspan="'+weeksTrailing+'"></td></tr>';
                    }
    
    

                    system.debug('n: before ' + n);
            if(n == 1){
            n ++ ;
        }else{
            n -- ;
        }
        system.debug('n: after ' + n);
        }
        system.debug('colour before ' + colour);
        colour ++ ;
        system.debug('colour after ' + colour);
        system.debug('focusr ' + str);
                    
            }
            if(hasTbvscHeader == True && marketingCampaignVillage == 'TBVSC Brand Campaign' && orderedMarketingCampaignsMap.keySet().size() > 1){
                theHTML += '<tr><th id="header_Village" bgcolor="#cccccc" colspan = "100%"> VILLAGES </th></tr>';
                hasTbvscHeader = False;  
            }
        }        

        theHTML += '</table>';
        system.debug(' the final html ' + theHtml);
        return theHTML;        
    }
            
    
    public static integer startWeek(Date MCDate){

    Date firstDay = MCDate.toStartOfMonth();
    Datetime dt = DateTime.newInstanceGMT(firstDay, Time.newInstance(0, 0, 0, 0));  
    Integer numberDaysInMonth = date.daysInMonth(MCDate.year(), MCDate.month());

    integer monCount = 0;
    integer i = 1;
    list<DateTime> weekStartList = new list<DateTime>();
    
             while(i <= numberDaysInMonth){         
                        String dayOfWeek = dt.format('EEEE'); 

                        if(dayOfWeek == 'Monday' && dt.month() == MCDate.month()){
                            weekStartList.add(dt);
                            monCount ++ ;
                            i += 7;
                            dt = dt.addDays(7);
                        }else{
                            i ++ ;
                            dt = dt.addDays(1);
                        }
            }  

        Date startOfWeek = MCDate.toStartOfWeek();
        system.debug('startOfWeek  ' + startOfWeek );
        Datetime sw = DateTime.newInstanceGMT(startOfWeek.year(), startOfWeek.month(), startOfWeek.day());  
        integer result = weekStartList.indexOf(sw) ;
        system.debug('result  ' + result );
        system.debug('weekStartList  ' + weekStartList );

        if(result == NULL || result == -1){
            return 0;
        }
        else{
            return result;
        }
    }


    public static integer endWeek(Date MCDate){
    Date firstDay = MCDate.toStartOfMonth();
    Datetime dt = DateTime.newInstanceGMT(firstDay, Time.newInstance(0, 0, 0, 0));  
    Integer numberDaysInMonth = date.daysInMonth(MCDate.year(), MCDate.month());

    integer monCount = 0;
    integer i = 1;
    list<DateTime> weekStartList = new list<DateTime>();
    

             while(i <= numberDaysInMonth){         
                        String dayOfWeek = dt.format('EEEE'); 

                        if(dayOfWeek == 'Monday' && dt.month() == MCDate.month()){
                            weekStartList.add(dt);
                            monCount ++ ;
                            i += 7;
                            dt = dt.addDays(7);
                        }else{
                            i ++ ;
                            dt = dt.addDays(1);
                        }
            }  

        Date startOfWeek = MCDate.toStartOfWeek();
        system.debug('startOfWeek  ' + startOfWeek );
        Datetime sw = DateTime.newInstanceGMT(startOfWeek.year(), startOfWeek.month(), startOfWeek.day());  
        integer result = weekStartList.indexOf(sw) + 1;
        system.debug('result  ' + result );
        system.debug('weekStartList  ' + weekStartList );

        if(result == NULL){
            return 0;
        }
        else{
            return result;
        }


    }

    public static integer mondayCount(integer month, integer year){

        Integer numberDays = date.daysInMonth(year, month);

        integer monCount = 0;

        integer i = 1;

        date firstDay = date.parse('1/'+month+'/'+year);
        Datetime dt = DateTime.newInstance(firstDay, Time.newInstance(0, 0, 0, 0));

            while(i < = numberDays){         
                String dayOfWeek = dt.format('EEEE'); 

                if(dayOfWeek == 'Monday' && dt.month() == month){
                    monCount ++ ;
                    i += 7;
                    dt = dt.addDays(7);
                }else{
                    i ++ ;
                    dt = dt.addDays(1);
                }
            }   

        system.debug('monCount  ' + monCount );
        return monCount;
    }
        

}