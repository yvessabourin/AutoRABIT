public interface HFSSpentLevelCalculator {
	HFS_SpentLevel getGuestLevel(Decimal spentAmount, String country);
	String getFormattedCurrency(Decimal spentAmount);
}