@isTest
public class HFS_Code_GeneratorController_TEST {

	static testmethod void basicInitialization(){
		
		HFS_Code_GeneratorController ctrl = new HFS_Code_GeneratorController ();
		ctrl.code = '123456';
		ctrl.codeType = 'QR';
		ctrl.format = 'png';

		system.assert(ctrl.codeUrl.contains('123456'));
		system.assert(ctrl.codeUrl.contains('QR'));
		system.assert(ctrl.codeUrl.contains('png'));

	}

}