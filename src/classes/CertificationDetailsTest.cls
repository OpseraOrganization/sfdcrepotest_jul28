@isTest
/***
* Test Class created for the CertificationDetails class
* Created By: Accenture IDC
* Created Date: 21/3/2017
***/
private class CertificationDetailsTest 
{
	/**
	* Description : Test data to be created.
	* @param Id NA 
	* @return NA
	**/
	@testSetup 
	static void datasetup() 
	{
		User u = TestDataFactory.createUser(PRMGlobalConstants.DataLoader,'running testuser');
		Database.insert(u);
		
		Account partnerAcc = TestDataFactory.createPartnerAccount(1, PRMGlobalConstants.IndirectReseller)[0];
		Database.insert(partnerAcc);
		
		List<Contact> lstCont = TestDataFactory.createContact2(4,partnerAcc);
		Database.insert(lstCont);
		
		Accreditation__c accred = TestDataFactory.createrAccreditation(1, partnerAcc.Id, null)[0];
		Database.insert(accred);
		
		List<Curriculum_Certification_Mapping__c> ccmList = new List<Curriculum_Certification_Mapping__c>();
		ccmList.addAll(TestDataFactory.createCurriculumCertifMap(2));
		Database.insert(ccmList);
		
		List<Certification_Matrix__c> certmatrixList = new List<Certification_Matrix__c>();
		certmatrixList.addAll(TestDataFactory.createCertifMatrix(1, ccmList[0].Id , PRMGlobalConstants.TestPort2));
		certmatrixList.addAll(TestDataFactory.createCertifMatrix(1, ccmList[0].Id , PRMGlobalConstants.TestPort2));
		certmatrixList.addAll(TestDataFactory.createCertifMatrix(1, ccmList[0].Id , PRMGlobalConstants.TestPort3));
		certmatrixList.addAll(TestDataFactory.createCertifMatrix(1, ccmList[1].Id , PRMGlobalConstants.TestPort3));
		Database.insert(certmatrixList);
		
		List<Certification__c> certifList = new List<Certification__c>();
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[0].id, certmatrixList[0].id, partnerAcc.id, u.Id, PRMGlobalConstants.Approved));
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[2].id, certmatrixList[1].id, partnerAcc.id, u.Id, PRMGlobalConstants.InProgress));
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[0].id, certmatrixList[0].id, partnerAcc.id, u.Id, PRMGlobalConstants.Registered));
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[1].id, certmatrixList[2].id, partnerAcc.id, u.Id, PRMGlobalConstants.Completed));
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[3].id, certmatrixList[3].id, partnerAcc.id, u.Id, PRMGlobalConstants.Approved));
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[2].id, certmatrixList[3].id, partnerAcc.id, u.Id, PRMGlobalConstants.Completed));
		certifList.addAll(TestDataFactory.createCertification(1, lstCont[0].id, certmatrixList[3].id, partnerAcc.id, u.Id, PRMGlobalConstants.InProgress));
		Database.insert(certifList);
	}
	
	/**
	* Description : Test method to cover functionality.
	* @param Id NA 
	* @return NA
	**/
	static testmethod void test1()
	{
		Account acc = [SELECT Id FROM Account WHERE BusinessPartnerRole__c = :PRMGlobalConstants.IndirectReseller LIMIT 1];
		User u=[select id from User where lastName='running testuser' LIMIT 1];
		System.runAs(u)
		{	
			Test.startTest();
			CertificationDetails.getCertifAndAccredforComponent(acc.Id);
			Test.stopTest();
		}
	}
}