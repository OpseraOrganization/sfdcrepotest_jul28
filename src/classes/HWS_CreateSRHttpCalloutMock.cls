@isTest
Global Class HWS_CreateSRHttpCalloutMock implements HttpCalloutMock{
	Boolean  isMockResponseSuccessful; 
	public HWS_CreateSRHttpCalloutMock(Boolean isMockResponseSuccessful) {
		this.isMockResponseSuccessful  = isMockResponseSuccessful;
	}
	Global HTTPResponse respond(HTTPRequest req) {
		System.assertEquals('callout:IPASS_LOGIN', req.getEndpoint());
		System.assertEquals('POST', req.getMethod());
		HttpResponse res = new HttpResponse();
		if (this.isMockResponseSuccessful) {
			res.setHeader('Content-Type', 'application/json');
			//res.setBody('{"Status":"New","SOORequestID":"SR-1538","SRMRequestID":"500m0000008qCHIAA2","Request":{"RequestItems":[{"Status":"New","SRMServiceItemID":"500m0000008qCHJAA2"}]}}');
			res.setBody('{"Status":"New","SOORequestID":"SR-1538","SRMRequestID":"500S0000009varHIAQ","Request":{"RequestItems":[{"Status":"New","SRMServiceItemID":"500S0000009varIIAQ"}]}}');
			//res.setBody('{"Status":"Open","SRMRequestID":"500S0000009x3eqIAA","RequestorType":"Sample Type","Requestitems":[{"UnitOfMeasure":"PC","Status":"Draft","SRMServiceItemID":"500S0000009x3erIAA","SerialNumberTraced":false,"RMA":"00120412-001"}]}}');
			res.setStatusCode(200);
		}
		else{
			res.setStatusCode(400);
		}
		return res;
	}
}