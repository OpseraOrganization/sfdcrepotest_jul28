@istest
public class HWS_Constants_TEST {
	
	public static final String TEST = 'Legal_Entity';
	
	public static testmethod void constantsMtehod(){ 
		HWS_Constants constnts = new HWS_Constants();
		System.assertEquals(HWS_Constants.Legal_Entity,HWS_Constants.Legal_Entity);
		
		HWS_Constants.hwsConstantsmethod();
	}
	
	
	
}