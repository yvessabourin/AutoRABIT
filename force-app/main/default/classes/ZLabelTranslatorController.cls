public class ZLabelTranslatorController {

    public String label_lang {get;set;}
    public String label {get;set;}
     
    public  ZLabelTranslatorController(){
       Map<String, String> reqParams = ApexPages.currentPage().getParameters(); 
       label_lang = reqParams.get('label_lang');
       label = reqParams.get('label');
    }
    
}