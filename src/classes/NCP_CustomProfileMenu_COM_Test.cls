@isTest
private class NCP_CustomProfileMenu_COM_Test{
	@isTest
	static void TestIsAuthenticated(){
		Test.startTest();
		Boolean isAut = NCP_CustomProfileMenu_COM.isAuthenticated();
		System.debug('### isAu '+isAut);
		System.assertEquals(isAut,true);
		Test.stopTest();
	}

	@isTest
	static void TestGetUserDetails(){
		Test.startTest();
		String detail = NCP_CustomProfileMenu_COM.getUserDetails();
		System.debug('### detail '+detail);
		System.assertNotEquals(null,detail);
		Test.stopTest();
	}
}