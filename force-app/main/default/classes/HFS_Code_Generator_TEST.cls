@isTest
public class HFS_Code_Generator_TEST {

	
	static testmethod void basicTestDefaultValues(){
		
		HFS_Code_Generator codeGen = new HFS_Code_Generator ('123456');
		system.assert(codeGen.getCodeURL().contains('DataMatrix'));
		system.assert(codeGen.getCodeURL().contains('gif'));	
	}

	static testmethod void basicSettingGetting() {
		HFS_Code_Generator codeGen = new HFS_Code_Generator ('123456');

		codeGen.setCode('78910');
		codeGen.setCodeType('QR');
		codeGen.setFormat('png');
		
		system.assertEquals('78910', codeGen.getCode());
		system.assertEquals('QR', codeGen.getCodeType());
		system.assertEquals('png', codeGen.getFormat());

		String codeUrl = codeGen.getCodeURL();
		system.assert(codeUrl.contains('78910'));
		system.assert(codeUrl.contains('QR'));
		system.assert(codeUrl.contains('png'));
	}

	static testmethod void testHttpCodeCallout() {

		HFS_Code_Generator codeGen = new HFS_Code_Generator ('123456');
		Exception exc;

		//Correct status case

		StaticResourceCalloutMock mock = new StaticResourceCalloutMock ();
		mock.setStaticResource('TestHttpMockResponse');
		mock.setStatusCode(200);
		Test.setMock(HttpCalloutMock.class, mock);
		
		system.assertNotEquals(null, codeGen.getBlobCode());

		//Error status case	
		mock.setStatusCode(400);

		try {
			codeGen.getBlobCode();
		} catch (Exception e) {
			exc = e;
		}

		system.assertNotEquals(null, exc);
	}
}