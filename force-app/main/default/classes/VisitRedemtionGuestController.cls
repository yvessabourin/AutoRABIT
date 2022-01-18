public with sharing class VisitRedemtionGuestController {

	private final sObject mysObject;

    public String promotionNotes {get; set;}

    public VisitRedemtionGuestController(){
        ID maId = (ID)ApexPages.currentPage().getParameters().get('promoId');
        if('Marketing_Activity__c' == String.valueOf(maId.getsobjecttype())){
            List<Marketing_Activity__c> ma = [Select Other_Notes__c, ID FROM Marketing_Activity__c WHERE ID = :maId];
            if(ma != null){
                if(ma[0].Other_Notes__c != null){
                    promotionNotes = ma[0].Other_Notes__c;
                }
                else
                {
                    promotionNotes = '';
                }
                promotionNotes = promotionNotes.replaceAll('\r\n', '<br />');
            }
            else{
                promotionNotes = 'no notes';
            }
        }
        else
        {
            promotionNotes = '';
        }

    }
 
}