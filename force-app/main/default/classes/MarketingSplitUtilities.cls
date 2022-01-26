public with sharing class MarketingSplitUtilities {

    // Receives a set of Marketing Activity record ids, and creates marketing split records
    // based on start/end date and performance figures entered
    public static void splitPeriods(set<Id> activityIds){

        try{
        
            // Retrieve Marketing Activity records, including any current Marketing Split records already
            // associated
            map<Id, Marketing_Activity__c> activityMap = new map <Id,Marketing_Activity__c>( 
                                                            [select Id, Start_Date__c, End_Date__c, Split_Type__c,
                                                                Expected_Average_Spend__c, Expected_Footfall__c,
                                                                Expected_New_Members__c, Expected_Sales__c,
                                                                Tracked_Average_Spend__c, Tracked_Footfall__c,
                                                                Tracked_New_Members__c, Tracked_Sales__c,
                                                                Reach__c,
                                                                (select Id from Marketing_Activity_Splits__r)
                                                                From Marketing_Activity__c
                                                                where Id in :activityIds]
                                                                );
            // List used for insert of new records                                                    
            list<Marketing_Activity_Split__c> splitListInsert = new list<Marketing_Activity_Split__c>();
            
            // List used for deletion of existing records in scenario where Split Type of parent 
            // Marketing Activity record is Weekly and a performance field or start/end date has been
            // amended
            set<Marketing_Activity_Split__c> splitListDelete = new set<Marketing_Activity_Split__c>();
            list<Marketing_Activity_Split__c> splitListDelete2 = new list<Marketing_Activity_Split__c>();
        
            // Loop through Marketing Activity records
            for (Marketing_Activity__c m :activityMap.values()){                              
                                
                date startDate = m.Start_Date__c;
                date endDate = m.End_Date__c;
                
                string splitType = m.Split_Type__c;

                date splitDate = null;
                Marketing_Activity_Split__c split = new Marketing_Activity_Split__c();
               
            
                if (splitType == 'Weekly'){

			 	//Populate deletion list with list of current records (if some exist)
	                if (!m.Marketing_Activity_Splits__r.isEmpty()){                    
	                    splitListDelete.addAll(m.Marketing_Activity_Splits__r);
	                }                    

                    /*** process first week ***/
                    integer wkStartDayNum = startDate.toStartOfWeek().day();
                    integer wkEndDayNum = endDate.toStartOfWeek().day();
                    integer dayCount = 1; // default to 1

                    if (endDate.toStartOfWeek() > startDate.toStartOfWeek()){ // start and end date at least a week apart
                        integer wkDayNum = getDayOfWeek(startDate); // Retrieve day number of week (Monday = 0 .. Sunday=6)
                        dayCount = 7 - wkDayNum; // Number of days remaining in first week from start date to Sunday (inclusive)

                    } 
                    splitDate = startDate;

                    split = addSplit(m, splitDate, dayCount); // Call method to add Marketing Split record to insertion list                  
                    splitListInsert.add(split);
                    
                    /*** process middle weeks  ***/
                    date currentWeekDate = startDate.addDays(7).toStartOfWeek(); // First day of second week
                    date lastFullWeekDate = endDate.addDays(-7).toStartOfWeek(); // First day of last full week of whole period
               
                    // Process middle weeks if First day of last full week is >= First day of second week 
                    if(lastFullWeekDate.toStartOfWeek() >= currentWeekDate.toStartOfWeek()){
                        // Loop through weeks until week date is greater than First day of last full week
                        while (currentWeekDate <= lastFullWeekDate){                        
                            dayCount = 7; // a complete week
                            splitDate = currentWeekDate.toStartOfWeek();

                            split = addSplit(m, splitDate, dayCount); // Call method to add Marketing Split record to insertion list
                            splitListInsert.add(split);
                            currentWeekDate = currentWeekDate.addDays(7); //increment week date by 7 days
                        }
                    }                   
                 
                    /*** process end week  ***/
                    // Process final week if start and end dates are in different weeks
                    if(endDate.toStartOfWeek()> startDate.toStartOfWeek()){                  
                        splitDate = endDate.toStartOfWeek();
                        dayCount = splitDate.daysBetween(endDate) + 1;                                                      
                    
                        split = addSplit(m, splitDate, dayCount);
                        splitListInsert.add(split);
                    }               
                }

            }

           // clear the current split values
            if (!splitListDelete.isEmpty()){
            	splitListDelete2 = new list<Marketing_Activity_Split__c>(splitListDelete);
            	system.debug (' @@@ Delete List size .. ' + splitListDelete2.size());	
                Database.DeleteResult[] resultList = null;
				resultList = Database.delete(splitListDelete2, false);                      
            }
                        
            if (!splitListInsert.isEmpty()){ //insert new records
                insert splitListInsert;
            }
            
            
        } catch (exception e){
            // Log technical error
            system.debug(e.getMessage() + ' : ' + e.getStackTraceString()); 
                
        }       
        
    }
    
    // Returns a marketing split object to be added to a list
    private static Marketing_Activity_Split__c addSplit(Marketing_Activity__c m, Date splitDate, integer dayCount){

        // Calculate total number of days for whole Marketing Activity period
        integer totalDays = m.Start_Date__c.daysBetween(m.End_Date__c) + 1;
        
        if (m.Start_Date__c.toStartOfWeek() == m.End_Date__c.toStartOfWeek()) //start and end date in same week
            totalDays = 1; // if start and end date in same week, divide all performance figures by 1 (ie. use full amount)

        // Divide each performance figure by number of days to determine a per/day figure
        //decimal expectedAverageSpend = nulltoZero(m.Expected_Average_Spend__c) / totalDays;
        decimal expectedFootfall = nulltoZero(m.Expected_Footfall__c) / totalDays;
        decimal expectedNewMembers = nulltoZero(m.Expected_New_Members__c) / totalDays;
        decimal expectedSales = nulltoZero(m.Expected_Sales__c) / totalDays;
        //decimal trackedAverageSpend = nulltoZero(m.Tracked_Average_Spend__c) /totalDays;
        decimal trackedFootfall = nulltoZero(m.Tracked_Footfall__c) / totalDays;
        decimal trackedNewMembers = nulltoZero(m.Tracked_New_Members__c) / totalDays;
        decimal trackedSales = nulltoZero(m.Tracked_Sales__c) / totalDays;      
        
        decimal reach = nulltoZero(m.Reach__c) / totalDays;
        
        Marketing_Activity_Split__c split = new Marketing_Activity_Split__c();
        
        // Create Marketing Split object using number of days for the period (ie, day, part week or full week)
        // multiplied by per/day figure to 2 decimal points
        //split.Expected_Average_Spend__c = dayCount * expectedAverageSpend.setScale(2);
        split.Expected_Footfall__c = dayCount * expectedFootfall.setScale(2);
        split.Expected_New_Members__c = dayCount * expectedNewMembers.setScale(2);
        split.Expected_Sales__c = dayCount * expectedSales.setScale(2);
        //split.Tracked_Average_Spend__c = dayCount * trackedAverageSpend.setScale(2);
        split.Tracked_Footfall__c = dayCount * trackedFootfall.setScale(2);
        split.Tracked_New_Members__c = dayCount * trackedNewMembers.setScale(2);
        split.Tracked_Sales__c = dayCount * trackedSales.setScale(2);
        split.reach__c = dayCount * reach.setScale(2);
        split.Marketing_Activity__c = m.Id;

        split.Date__c = splitDate;
        
        return split;
        
    }
    
    
    // Given a date, returns the numeric day number of the week where
    // Monday = 0, Tuesday = 1 ... Sunday = 6
    private static integer getDayOfWeek(date d){
        
        date startDate = date.newInstance(1990, 1, 1); // a Monday
        List<String> listDay = new List<String>{'Monday',
                                                'Tuesday' , 
                                                'Wednesday' ,
                                                'Thursday' ,
                                                'Friday',                                                
                                                'Saturday',
                                                'Sunday' };  

        integer remainder = Math.mod(startDate.daysBetween(d) , 7) ;  
        string dayValue = listDay.get(remainder);  
        
        return remainder;
    }
        
    // Converts a numeric field value to 0 if value is currently null
    private static decimal nulltoZero(decimal value){
        if (value == null){
            return 0;
        } else {
            return value;
        }
    }


}