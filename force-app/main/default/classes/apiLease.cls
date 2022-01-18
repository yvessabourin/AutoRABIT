/*
    Lease items definition class
    
    Created : 15/09/2016
    Author: Constantine Chimonides

*/

global with sharing class apiLease {

    public class cls_LeaseItem {

        /*** sample xml 
            <LeaseList>
  				<Lease Id="HBOSW1" VillageId="WV" BrandId="HBOSB" BuildingId="WV1" UnitId="WV1048" StoreCategory="GEN" OccupancyStatus="C" RetailManager="MAW" Description="Hugo Boss" RentStartDate="2011-10-04T00:00:00Z" ExecutionDate="2011-09-08T00:00:00Z" OccupancyDate="2011-10-04T00:00:00Z" BeginningDate="2011-10-04T00:00:00Z" ExpirationDate="2021-10-03T00:00:00Z" TradeCloseDate="2021-10-03T00:00:00Z" LandlordContributionContract="864000.0" Active="true" DateCreated="2016-06-14T18:06:05Z" DateUpdated="2016-09-08T17:38:14Z" BatchId="ddc83673-7621-455e-b3cb-ab5941c3bcae" VersionId="03fc3db1-7bcc-4027-ae1d-5ebee705b6d9" />
			</LeaseList>
		***/
        
        public string leaseId {get;set;}
        public string villageId {get; set;}
        public string brandId {get; set;}
        public string phaseId {get; set;}
        public string unitId {get; set;}
        public string unitNumber {get; set;}
        public string storeCategory {get; set;}
        public string occupancyStatus {get; set;}
        public string retailManager {get; set;}
        public string description {get; set;}
        public string rentStartDate {get; set;}
        public string executionDate {get; set;}
        public string occupancyDate {get; set;}
        public string beginningDate {get; set;}
        public string expirationDate {get; set;}
        public string tradeCloseDate {get; set;}
        public string landlordContributionContract {get; set;}
        public string active {get; set;}
        
        
        
    	
    	public cls_LeaseItem(){

    	}
    }

   // Method to deserialize XML string into a list of apiLease objects
    public static list<apiLease.cls_LeaseItem> parseXML(string xmlLease){
       
        list<apiLease.cls_LeaseItem> returnList = new list<apiLease.cls_LeaseItem>();

        TG_XmlNode root = null;
        TG_XmlDom dom = new TG_XmlDom(xmlLease);
        root = dom.root;            
        List<TG_XmlNode> childNodes = new list<TG_XmlNode>();

        childNodes = root.getElementsByTagName('Lease');
		
        for(TG_XmlNode node :childNodes){
            
            apiLease.cls_LeaseItem leaseItem = new apiLease.cls_LeaseItem();
            system.debug(' @@@ leaseId = ' + nullToEmptyString(node.getAttribute('Id')));
            
            leaseItem.leaseId = nullToEmptyString(node.getAttribute('Id'));
            leaseItem.villageId = nullToEmptyString(node.getAttribute('VillageId'));
            leaseItem.brandId = nullToEmptyString(node.getAttribute('BrandId'));
            leaseItem.phaseId = nullToEmptyString(node.getAttribute('PhaseId'));
            leaseItem.unitId = nullToEmptyString(node.getAttribute('UnitId'));
            leaseItem.unitNumber = nullToEmptyString(node.getAttribute('UnitNumber'));
            leaseItem.storeCategory = nullToEmptyString(node.getAttribute('StoreCategory'));
            leaseItem.occupancyStatus = nullToEmptyString(node.getAttribute('OccupancyStatus'));
            leaseItem.retailManager = nullToEmptyString(node.getAttribute('RetailManager'));
            leaseItem.description = nullToEmptyString(node.getAttribute('Description'));
            leaseItem.rentStartDate = nullToEmptyString(node.getAttribute('RentStartDate'));
            leaseItem.executionDate = nullToEmptyString(node.getAttribute('ExecutionDate'));
            leaseItem.occupancyDate = nullToEmptyString(node.getAttribute('OccupancyDate'));
            leaseItem.beginningDate = nullToEmptyString(node.getAttribute('BeginningDate'));
            leaseItem.expirationDate = nullToEmptyString(node.getAttribute('ExpirationDate'));
            leaseItem.tradeCloseDate = nullToEmptyString(node.getAttribute('TradeCloseDate'));
            leaseItem.landlordContributionContract = nullToEmptyString(node.getAttribute('LandlordContributionContract'));
            leaseItem.active = nullToEmptyString(node.getAttribute('Active'));

			returnList.add(leaseItem);            
            
        }
        
        return returnList;
    }
    
    private static string nullToEmptyString(string value){
        
        string returnVal = '';
        
        if (string.isBlank(value)){
            returnVal = '';
        } else {
            returnVal = value;
        }
        return returnVal;
        
    }
    
}