/*****************************************************************
Description:	This class returns json string of requested case
History																														
DATE			AUTHOR		  CHANGE
12/04/2019	  Vinod T		 Created
*****************************************************************/

Public without sharing Class HWS_CancelCaseSRRequest
{
	/*****************************************************************
Description:	Returns the string json of the requested case object 
Parameters: parentCaseId
Returns:  JSON String
Throws [Exceptions]: [optional]	
History															
DATE			AUTHOR		  CHANGE
12/04/2019	  Vinod T		 Created
*****************************************************************/
	Public SOORequestBody cancelSRRequest(Id parentCaseId,Id childId){
		try{
			Case caseRec = [SELECT id,CreatedBy.Name,Status,CreatedDate,CaseNumber,Account.NCP_P20_ID__c,
							(SELECT id,HWS_RMA_Number__c,HWS_Contract_Line_Item__r.CH_ServiceType__c,Status,NCP_Service_Contract__r.CH_ERPSystem__c,HWS_SPS_Order_No__c FROM Cases
							 WHERE Status ='Ordered')
							FROM Case
							WHERE id = :parentCaseId];
			
			system.debug('-----caserec---'+caseRec);
			system.debug('-----childId ---'+childId+'-----ParentId---'+parentCaseId);
			HWS_CancelParentCase_WRAPPER parentCase ;
			if(caseRec.Cases.size() > 0 && childId == null)
			{
				system.debug('=====Parent loop===');
				parentCase = new HWS_CancelParentCase_WRAPPER(caseRec);
				for(Case childCaseRec: caseRec.Cases){
					parentCase.Requestitems.add(new HWS_CancelChildCases_WRAPPER(childCaseRec));
				}
			} 
			else
			{
				parentCase = new HWS_CancelParentCase_WRAPPER(caseRec);
				for(Case c: caseRec.Cases){
					system.debug('===childCaseRec=='+c);
					
					system.debug('=Child before if======');
					if(c.id == childId){
						system.debug('=Child to send SOO======'+childId+'=====c.id--'+c.id);
						parentCase.Requestitems.add(new HWS_CancelChildCases_WRAPPER(c));
					}
					
				}
			} 
			String jsonString = JSON.serialize(parentCase,true);
			system.debug('---jsonString---'+jsonString);
			SOORequestBody obj=new SOORequestBody();
			obj.jsonPayload=jsonString;
			obj.caseNumber=caseRec.CaseNumber;
			system.debug('---SOORequestBody---'+obj);
			return obj;
		}
		Catch(Exception e){
			System.debug('Error in CancelCaseSRRequest***'+e.getMessage() +'on line number ' +e.getLineNumber() + ' '+ e.getCause());
			return null;
		}
	}
	public class SOORequestBody{
		public String jsonPayload;
		public String caseNumber;	 
	}
}