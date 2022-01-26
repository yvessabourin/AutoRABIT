({
invoke : function(component, event, helper) {
var redirectToVillagePrecenseRecord = $A.get( "e.force:navigateToSObject" );

redirectToVillagePrecenseRecord.setParams({
"recordId": component.get( "v.VilPreId" ),
"slideDevName": "detail"
});
redirectToVillagePrecenseRecord.fire();
}
})