global with sharing class PrescanGroupBookingController {


 public PrescanGroupBookingController() {

 }

     @RemoteAction
    global static string savePreScannedVisit(string codes,string visitId){
		return VisitRedemptionsHelper.savePreScannedVisit(codes,visitId);
    }
}