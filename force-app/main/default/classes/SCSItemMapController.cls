public with sharing class SCSItemMapController {

//////////to be deleted
 /*
    public SCSItemMapController (ApexPages.StandardController controller) {
    set<string> validStatuses = new set<string>{'Requested','Runner On Way', 'With Runner'};
    
    //extention####################################################
    //set of unique VPids
    set<id> VPIds = new set<id>();
    string MyVillageName = [SELECT Village__c FROM USER WHERE ID = :UserInfo.getUserId()].Village__c;
    
    for (AggregateResult results : [select  Brand__c from HFS_Item__c
                                        WHERE status__c in :validStatuses
                                        AND Brand__r.Village__r.name = :MyVillageName 
                                        GROUP BY Brand__c])  
    { 
       VPIds.add((ID)results.get('Brand__c')); 
    }
       
     list<Village_presence__c> SCSVPs = [SELECT id, Brand__r.Name, unit__r.Unit_GeoLocation__latitude__s, unit__r.Unit_GeoLocation__longitude__s,
                                                                          (SELECT id, name, Drop_Location__c, Runner__r.name, Brand__c, map_marker__c, status__c 
                                                                            FROM HFS_Items__r 
                                                                            WHERE status__c in :validStatuses
                                                                             )
                                         FROM Village_presence__c
                                         WHERE id in :VPIds];
                                         
       myMapPoints = new list<mapPoint>();
   
            for(Village_presence__c cVP : SCSVPs ){
                   
                boolean runnerallocated = false;
                decimal markerScore = 0;     
                   
                   mapPoint nMP = new mapPoint();
                   nMP.BrandName= cVP.Brand__r.Name ;
                   nMP.Lat= cVP.unit__r.Unit_GeoLocation__latitude__s;
                   nMP.Lng= cVP.unit__r.Unit_GeoLocation__longitude__s;
                   nMP.vpid = cVP.id;
                   nMP.scsrequests = new  list<SCSrequest> ();
                   
                  system.debug('Lat: ' + nMP.Lat + ',   Long: ' + nMP.Lng); 
                    
                    //now add remote request lists to each VPmarker
                    for(HFS_Item__c cRequest : cVP.HFS_Items__r){
                   
                            SCSrequest nRequest = new SCSrequest();
                            
                            nRequest.requestid = cRequest.id;
                            nRequest.status = cRequest.status__c;
                            
                            if(string.isnotblank(cRequest.Drop_Location__c) ){
                                nRequest.droplocation = cRequest.Drop_Location__c;
                            }
                            else{
                                nRequest.droplocation = 'Drop Location not set';
                            }
                            
                            if(string.isnotblank(cRequest.runner__r.name)){
                                nRequest.droplocation  += ' (' + cRequest.Runner__r.name + ')';
                                runnerallocated = true;
                            }
                            
                            
                            nRequest.droplocation  += ' - ' + cRequest.Status__c;
         
                            nMP.scsrequests.add(nRequest);
                            
                            //map marker based on location
                            if (cRequest.map_marker__c > markerScore)
                            {
                                markerScore = cRequest.map_marker__c;
                            }
                            
                                                  
                 }//end of adding requests to VP list
                 
                 
                 if(markerScore == 5){
                         nMP.marker = 'Crown-Map-Marker.png';
                 }
                 else if(markerScore == 4){
                         nMP.marker = 'trainstationmarker.png';
                 }
                 else if(markerScore == 3){
                         nMP.marker = 'infomapmarker.png';
                 }
                 else if(markerScore == 2){
                         nMP.marker = 'mapmarkergreen.png';
                 }
                 else if(markerScore == 1){
                         nMP.marker = 'mapmarkergreen.png';
                 }
                 else if(markerScore == 0){
                         nMP.marker = 'mapmarkergreen.png';
                 }
                 
            
 
                myMapPoints.add(nMP);
            }
            
       //set map default center point
       Village__c myVillage =  [select id, Village_GeoLocation__latitude__s, Village_GeoLocation__longitude__s FROM Village__c WHERE name = :MyVillageName LIMIT 1];
       homeVillageGeoLocation = '{latitude: ' +  myVillage.Village_GeoLocation__latitude__s + ', longitude: ' + myVillage.Village_GeoLocation__longitude__s + ' }';
     
    
     
    }//end of constructor


//Properties
//public list<SCS_Remote_Request__c> RemoteRequests {get;set;}
public list<mapPoint> myMapPoints{get;set;}
public string homeVillageGeoLocation {get;set;}

       
    public class mapPoint
    {
        public id vpid{get; set;}
        public id requestid {get; set;}
        public string BrandName{get; set;}
        public list<SCSrequest> scsrequests{get; set;}
        public decimal Lat{get; set;}
        public decimal Lng{get; set;}
        public string marker{get; set;}
    }

    public class SCSrequest
    {
        
        public id requestid{get; set;}
        //public id vpid{get; set;}
        public string status{get; set;}
        public string droplocation{get; set;}
    }

*/

}