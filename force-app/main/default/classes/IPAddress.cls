public with sharing class IPAddress {


    //Variable to hold the IP Address value for current logged in user
    public String ipAddress {get; set;}
    public string clientIP {get; set;}
    public string sfIP {get; set;}
    public string userName {get; set;}

    //Constructor
    public IPAddress() {
		
		userName = userinfo.getName();
		
        //Map to hold current URL header parameters
        Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();   

		if (test.isRunningTest()){
			mapHeaders = new map<string, string>();
			mapHeaders.put('X-Salesforce-SIP', '00.00.00');	
		}
    //Proceed further only and only if map of header parameter have not null value with it
        if(mapHeaders != null) {
			clientIP = mapHeaders.get('True-Client-IP');
			sfIP = mapHeaders.get('X-Salesforce-SIP');
            ipAddress = mapHeaders.get('True-Client-IP');
            if(ipAddress == null){
                ipAddress = mapHeaders.get('X-Salesforce-SIP');
            }
        }
    }

}