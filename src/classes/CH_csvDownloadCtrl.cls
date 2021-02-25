public class CH_csvDownloadCtrl {
 @AuraEnabled
   public static list <case> fetchCase(){
	  
	  List <Case> returnCaseList = new List < Case > ();
	  string uid = userinfo.getUserId();
	   list<user> cid=[Select contactId from user where id=: userinfo.getUserId()];
	   string cid1 = cid[0].contactId;
	   for(case cas: [SELECT CaseNumber,Subject, Status,Severity__c,CreatedDate,CH_Product_Name__c,CH_Reported_Date__c,ContactId  From Case where contactId=:cid1 LIMIT 1000 ]) {
			 returnCaseList.add(cas);
		  }
		 return returnCaseList;
   }
}