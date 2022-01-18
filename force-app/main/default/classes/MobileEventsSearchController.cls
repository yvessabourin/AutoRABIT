public with sharing class MobileEventsSearchController {

    private string searchString;
    public list<Event> resultsList{get; set;}
    
    public void setsearchString(string value){
        searchString = value;
  
    }
    
    public string getsearchString(){
        return searchString;
    }
    
    // Retrieve search string from page parameter
    public MobileEventsSearchController( ApexPages.StandardController stdController ) {
            
            
            string input = ApexPages.currentPage().getParameters().get('searchString');
            if (!string.isBlank(input)){
                searchString = input;
            }
                
    }

    public void DoSearch(){
   
        if (!string.isBlank(searchString)){                     

            list<Event[]> searchResults = [FIND  :searchString  IN ALL FIELDS RETURNING Event(Subject, StartDateTime, Event_Headline__c, Description where whatId != null)];
            if (searchResults != null){
                if(!searchResults.isEmpty()){
                    resultsList = searchResults[0];

                }
                
            }

        }

        
    }

}