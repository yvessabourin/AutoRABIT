@isTest
public class HFSSpentLevelCalculatorTest {

	@testSetup
	static void setupData () {

		Village__c bicesterVillage = TestDataGenerator.setupVillage(false);
		bicesterVillage.Village_Code__c = 'BV';
		bicesterVillage.HFS_Medium_Spend_Threshold__c = 1500;
		bicesterVillage.HFS_High_Spend_Threshold__c = 3000;
		bicesterVillage.HFS_International_Guest_Spend_Threshold__c = 5000;
		bicesterVillage.HFS_Country_of_Village__c = 'United Kingdom';

		Village__c fidenzaVillage = TestDataGenerator.setupVillage(false);
		fidenzaVillage.Village_Code__c = 'FV';
		fidenzaVillage.HFS_Medium_Spend_Threshold__c = 1000;
		fidenzaVillage.HFS_High_Spend_Threshold__c = 2000;
		fidenzaVillage.HFS_International_Guest_Spend_Threshold__c = 4000;
		fidenzaVillage.HFS_Country_of_Village__c = 'Italy';

		Village__c laValleeVillage = TestDataGenerator.setupVillage(false);
		laValleeVillage.Village_Code__c = 'LV';
		laValleeVillage.HFS_Country_of_Village__c = 'France';

		insert new List<Village__c> {bicesterVillage, fidenzaVillage, laValleeVillage};	

	}

	static testmethod void mainTest() {
		
		HFSSpentLevelCalculator calculator1 = HFS_Utils.getCurrencyLevelCalculator('BV');

		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(null, 'United Kingdom'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(1400, 'United Kingdom'));
		system.assertEquals(HFS_SpentLevel.MEDIUM, calculator1.getGuestLevel(2000, 'United Kingdom'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(2900, 'Spain'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(3100, 'Spain'));
		system.assertEquals(HFS_SpentLevel.HIGH, calculator1.getGuestLevel(3100, 'United Kingdom'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(3100, 'Spain'));
		system.assertEquals(HFS_SpentLevel.HIGH, calculator1.getGuestLevel(6000, 'Spain'));

		system.assertEquals('',calculator1.getFormattedCurrency(null));
		system.assertEquals('£ 250.00',calculator1.getFormattedCurrency(250));

		calculator1 = HFS_Utils.getCurrencyLevelCalculator('FV');

		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(null, 'Italy'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(900, 'Italy'));
		system.assertEquals(HFS_SpentLevel.MEDIUM, calculator1.getGuestLevel(1500, 'Italy'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(1500, 'Spain'));
		system.assertEquals(HFS_SpentLevel.HIGH, calculator1.getGuestLevel(2100, 'Italy'));
		system.assertEquals(HFS_SpentLevel.HIGH, calculator1.getGuestLevel(4100, 'Italy'));
		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(3100, 'Spain'));
		system.assertEquals(HFS_SpentLevel.HIGH, calculator1.getGuestLevel(4100, 'Spain'));

		system.assertEquals('',calculator1.getFormattedCurrency(null));
		system.assertEquals('250.00 €',calculator1.getFormattedCurrency(250));

		calculator1 = HFS_Utils.getCurrencyLevelCalculator('LV');

		system.assertEquals(HFS_SpentLevel.LOW, calculator1.getGuestLevel(5000, 'France'));


	}

}