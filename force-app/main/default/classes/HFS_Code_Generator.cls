/* 
	Class that allows for the generation of 2D BarCodes.
	Instructions: 
		1-. Create an instance of the class passing in the message that needs to be encoded.
		2-. Use the methods getCodeURL() to get the code URL or get the base64 encoded by calling the getBlobCode() method
*/

public with sharing class HFS_Code_Generator {
	
	//Identifiers for the Query parameters
	private static final String CODE_ID = 'msg';
	private static final String TYPE_ID = 'type';
	private static final String FORMAT_ID = 'fmt';
	private static final String QZ_ID = 'qz';

	private PageReference basePageReference;   //Base Page Reference with the inital base URL
	private Map <String, String> queryParameters; //Query parameters for the PageReference URL

	public HFS_Code_Generator(String code) {

		basePageReference = new PageReference (Label.HFS_Code_Gen_URL);
		queryParameters = basePageReference.getParameters();
		//Set initial and default values
		queryParameters.put(CODE_ID,code);
		queryParameters.put(TYPE_ID,'DataMatrix');
		queryParameters.put(FORMAT_ID,'gif');
		queryParameters.put(QZ_ID,'disable');
		
	}

	public void setCode (String code) {
		queryParameters.put(CODE_ID,code);
	}

	public void setCodeType (String codeType) {
		queryParameters.put(TYPE_ID,codeType);
	}

	public void setFormat (String format) {
		queryParameters.put(FORMAT_ID,format);
	}

	public String getCode () {
		return queryParameters.get(CODE_ID);
	}

	public String getCodeType () {
		return queryParameters.get(TYPE_ID);
	}

	public String getFormat () {
		return queryParameters.get(FORMAT_ID);
	}

	public String getCodeURL () {
		return basePageReference.getUrl();
	}

	public Blob getBlobCode () {

		Http h = new Http();
		HttpRequest rq = new HttpRequest ();
		rq.setMethod('GET');
		rq.setEndpoint(basePageReference.getUrl());
		
		try {
			HttpResponse rp = h.send(rq);
			if (rp.getStatusCode() == 200 || rp.getStatusCode() == 201) {
				return rp.getBodyAsBlob();
			} else {
				throw new CodeGeneratorException('An error has been found while trying to get the Barcode.');
			}
		} catch (Exception e) {
			system.debug(e.getMessage());
			system.debug(e.getStackTraceString());
			throw new CodeGeneratorException('An error has been found while trying to get the Barcode.');
		}
	}

	class CodeGeneratorException extends Exception {}
	
}