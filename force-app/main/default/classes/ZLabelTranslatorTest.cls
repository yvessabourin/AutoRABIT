@isTest
private class ZLabelTranslatorTest {
	
	private static string labelName = 'DAILY_SALE_NO_CONFIRM_RECORDS';
	private static string labelLang = 'en';
	
    static testMethod void unitTest() {

		PageReference pg = new PageReference('/apex/ZLabelTranslator');
    	pg.getParameters().put('label', labelName);
    	pg.getParameters().put('label_lang', labelLang);
    	Test.setCurrentPage(pg);
    					    	

		ZLabelTranslatorController controller = new ZLabelTranslatorController();
		
		test.startTest();
			
		ZLabelTranslator t = new ZLabelTranslator();
		string lbl_text = t.translate(labelName,labelLang);	
		system.assertEquals(lbl_text, 'UNIT.TEST');	
		
		lbl_text = DailySalesListController.getLabel(labelName);
		system.assertEquals(lbl_text, 'UNIT.TEST');
		
		test.stopTest();
        
    }
}