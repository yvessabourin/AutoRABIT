public without sharing class HFSSpentLevelCalculatorBV implements HFSSpentLevelCalculator{
	
	private final Decimal highLevelAmount;
	private final Decimal mediumLevelAmount;
	private final Decimal internationalLevelAmount;
	private final String villageCode = 'BV';
	private final String country;
	private final List<String> formattingArgs = new String[]{'0','number','###,###,###,###.00'};
	private final String currencySymbol = '£';


	public HFSSpentLevelCalculatorBV() {
		Village__c village = [SELECT Id, HFS_High_Spend_Threshold__c, HFS_Medium_Spend_Threshold__c, HFS_International_Guest_Spend_Threshold__c, HFS_Country_of_Village__c FROM Village__c WHERE Village_Code__c =: villageCode];
		this.highLevelAmount = village.HFS_High_Spend_Threshold__c;
		this.mediumLevelAmount = village.HFS_Medium_Spend_Threshold__c;
		this.internationalLevelAmount = village.HFS_International_Guest_Spend_Threshold__c;
		this.country = village.HFS_Country_of_Village__c;
	}
	
	public HFS_SpentLevel getGuestLevel(Decimal spentAmount, String country) {
	
		if (highLevelAmount != null && mediumLevelAmount != null && internationalLevelAmount != null) {
			if (spentAmount == null) {
				return HFS_SpentLevel.LOW;
			} else if (country == this.country) {
				if (spentAmount > this.highLevelAmount) {
					return HFS_SpentLevel.HIGH;
				} else if (spentAmount > this.mediumLevelAmount) {
					return HFS_SpentLevel.MEDIUM;
				} else {
					return HFS_SpentLevel.LOW;
				}
			} else {
				if (spentAmount > this.internationalLevelAmount) {
					return HFS_SpentLevel.HIGH;
				} else {
					return HFS_SpentLevel.LOW;
				}
			}
		} else {
			return HFS_SpentLevel.LOW;
		}
	}

	public String getFormattedCurrency(Decimal spentAmount) {

		String formattedCurrency = '';

		if (spentAmount != null) {
			formattedCurrency = currencySymbol + ' ' + String.format(String.valueOf(spentAmount.setScale(2)), formattingArgs);
		}

		return formattedCurrency;
	}
}