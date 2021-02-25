/*****************************************************************
Description:  Calls external webservice i.e iPass/SOO to check the Warranty status  
Requested values 
- MaterialCode 
- SerialNumber
- Customer Number
- Source System
Response values
-WarrantyCheck Status
History																														
DATE		 AUTHOR		   Change
11/13/2018   Nikita Jain	Created
*****************************************************************/
Public Class HWS_SendWarrantyCheckRequesttoSOO {
	/*****************************************************************
Description:  This method will callout to external service to iPASS/SOO
Parameters: - MaterialCode,SerialNumber,Customer Number,Source System
Returns: Warranty Status recieved from SOO.
Throws [Exceptions]: [optional]														  
History															
DATE		   AUTHOR		   Change
11/11/2018	 Shiv Maila	  Created
12/17/2018	 Vinod Ch		 Updated
*****************************************************************/
	Public String sendToSOO(HWS_CheckWarranty_SVC.FlowInput objInput)
	{ 
		String exceptionMessage;
		try{
			HTTPRequest feedRequest = new HTTPRequest();
			feedRequest.setHeader('Content-Type','application/json');
			feedRequest.setEndpoint('callout:IPAAS_WARRANTY_CHECK');
			HWS_CreateWarrantyCheckRequest objSR = new HWS_CreateWarrantyCheckRequest();
			String createSRJSON = objSR.createSRRequest(objInput);
			feedRequest.setMethod('POST');
			feedRequest.setbody(createSRJSON);
			//feedRequest.setbody(null);
			HTTP http = new HTTP();
			system.debug('Feed request sent:'+ createSRJSON);
			HTTPResponse feedResponse = http.send(feedRequest);
			system.debug('Feed response Code:'+feedResponse.getStatusCode());
			 if(feedResponse.getStatusCode()==200){
				warrantyCheck w = (warrantyCheck)JSon.deserialize(feedResponse.getBody(),warrantyCheck.class);
				return w.WarrantyStatus == 'Undefined' ? 'Unknown':w.WarrantyStatus;
			}else{
				System.debug('****** feed response  '+feedResponse.getStatusCode());
				return null;
			}
		}catch(Exception Ex){
			exceptionMessage='Facing issues in the response. please try again later';
			return exceptionMessage;			
		}
	}
	//Wrapper class to process Json response
	Public Class warrantyCheck{
		Public string SerialNumber;
		Public String MaterialCode;
		Public String WarrantyStatus;
	}
}