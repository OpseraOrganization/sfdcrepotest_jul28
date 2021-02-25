/*****************************************************************
Description:	Service request to Submit the Json created by HWS_CancelSRRequest class to SOO 
History																														
DATE		AUTHOR		  CHANGE
12/04/2019	  Vinod T		 Created
*****************************************************************/
Public without sharing class HWS_CancelcaseSendSRtoSOO_SVC{
	//Public  HWS_SendServiceRequesttoSOO_SVC(){}
	//@AuraEnabled
	//Public Boolean isSenttoSOO; 
	/*****************************************************************
Description: Future method callout to submit parent case to SOO
Parameters: ParentCaseId
Returns: NA
Throws [Exceptions]: [optional]														  
History															
DATE			AUTHOR		  CHANGE
12/04/2019	  Vinod T		 Created
*****************************************************************/
	@AuraEnabled
	Public Static processResponse sendToSOO(Id parentCaseId,Id childId)
	{ 
		ProcessResponse pr=new ProcessResponse();
		HWS_CancelCaseSRRequest objSR = new HWS_CancelCaseSRRequest();
		HWS_CancelCaseSRRequest.SOORequestBody createSRJSON =objSR.cancelSRRequest(parentCaseId,childId);	
		HTTP http; 
		HTTPResponse response; 
		HTTPRequest request ;
		String stCaseNumber=createSRJSON.caseNumber;
		try{ 
			String caseNumber;
			request = new HTTPRequest();
			request.setEndpoint('callout:IPAAS_CANCEL_SR');
			System.debug('Json created ===='+createSRJSON);
			request.setHeader('Content-Type','application/json');
			request.setbody(createSRJSON.jsonPayload);
			System.debug('====Request Body to send SOO===='+createSRJSON.jsonPayload);
		  //  request.setbody(null);
			request.setMethod('POST');
			request.setTimeout(12000);
			http = new HTTP();
			 response =http.send(request);
			 System.debug('Code**'+response.getStatus());
			Case parentCase = new Case(id=parentCaseId);
			//parentCase.HWS_Sent_To_SOO__c =true;
			if(response.getStatusCode()==200){
				 System.debug('**Response Body**'+response.getBody());
				pr = (ProcessResponse)JSon.deserialize(response.getBody(),ProcessResponse.class);
				pr.isError=false;
				pr.statusCode=response.getStatusCode();
				pr.message=response.getStatus();
				System.debug('response status'+pr.Status);
			}else{
		   
				pr.isError=true;
				pr.SOORequestID=null;
				pr.statusCode=response.getStatusCode();
				pr.message=response.getStatus();  
				createOutboundErrorLog(pr,parentCaseId,null,stCaseNumber);
			}
		
			
		}catch(exception ex){
			pr.isError=true;
			pr.SOORequestID=null;
			pr.statusCode=null;
			pr.message=ex.getMessage();
			System.debug('Exception ===== '+ex.getMessage());
			createOutboundErrorLog(pr,parentCaseId,null,stCaseNumber); 
		   
		}
		return pr;
	}
	//Method used to log the inbound response errors
	Public Static void createOutboundErrorLog(ProcessResponse response,Id caseId,Integer resStatusCode,String caseNumber){
		
		try{
			Interface_log__c ilogCallout = new Interface_log__c();
			ilogCallout.Name='CaseNumber ' + caseNumber;
			ilogCallout.Interface_Type__c = 'SOO';
			ilogCallout.Message_Type__c = 'Outbound';
			ilogCallout.Status__c ='Failure';
			ilogCallout.Comment__c=response.message;	
			Database.insert(ilogCallout);
			
		}
		catch(exception ex){
			 System.debug('Exception***'+ex.getMessage());
		   
		}
	}
	
	Public class ProcessResponse{
		@AuraEnabled Public String message;
		@AuraEnabled Public Integer statusCode;
		@AuraEnabled Public String SOORequestID;
		@AuraEnabled Public Boolean isError;
		@AuraEnabled Public String Status;
		public ProcessResponse(){
			message='';
			isError=false;
			
		}
	}
}