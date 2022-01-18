trigger BT_Payment_Method_Trigger on bt_stripe__Payment_Method__c (before insert, before update) {

	if (trigger.isBefore) {
		if (trigger.isInsert) {
			BT_Payment_Method_Trigger_Handler.deletePaymentMethodInformation(Trigger.new);
		}
		if (trigger.isUpdate) {
			BT_Payment_Method_Trigger_Handler.deletePaymentMethodInformation(Trigger.new);		
		}
	}

}