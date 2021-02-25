@isTest
private class NIA_SurveyController_Test {
	
	static testMethod void testSurvey() {
		User oAdminUser = TestDataFactory.createUser('Admin', 'Test');
		
		System.runAs(oAdminUser) {
			/*

			List<Survey> surveyList = TestDataFactory.createSurvey(1);
			insert surveyList;
			System.assertEquals(false, surveyList.isEmpty());
			
			List<Survey> surveyVersionList = TestDataFactory.createSurveyVersions(1, surveyList);
			insert surveyVersionList;
			System.assertEquals(false, surveyVersionList.isEmpty());
			
			List<SurveyQuestion> questions = TestDataFactory.createQuestionsOnSurveys(1, surveyList, surveyVersionList[0].id);
			insert questions;
			System.assertEquals(false, questions.isEmpty());
			
			
			
			
			
			Test.startTest();
			NIA_SurveyController.getActiveSurveys();
			NIA_SurveyController.getSurveyQuestionsPerSurvey(surveyVersionList[0].id);
			
			
			Test.stopTest();
			*/
			
			
		}
			
	}

}