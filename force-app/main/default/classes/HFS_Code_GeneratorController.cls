global inherited sharing class HFS_Code_GeneratorController {

	public String code {get;set;}
	public String codeType {get;set;}
	public String format {get;set;}

	public String codeUrl {
		get {

			HFS_Code_Generator cGen = new HFS_Code_Generator(code);
			cGen.setCodeType(codeType);
			cGen.setFormat(format);
			return cGen.getCodeURL();
		}
		set;
	}
}