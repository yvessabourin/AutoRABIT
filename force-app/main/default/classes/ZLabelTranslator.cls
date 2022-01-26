public class ZLabelTranslator {
     
    public  String translate(String labelName, String language){
            Pagereference r = Page.ZLabelTranslator;
            r.getParameters().put('label_lang', language);
            r.getParameters().put('label', labelName);
            
            string labelValue = Test.IsRunningTest() ? 'UNIT.TEST' : r.getContent().toString();
			
			
            return labelValue;
    }
     
}