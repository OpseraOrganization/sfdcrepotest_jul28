/****************************************
* Class Name : HWS_TokenGenerate
* Created Date: 12 December 2018
* Created By : TCS
* Last Modified by: 
* Last Modified Date: 	
* Description : HWS Token Generate Class 
*****************************************/
public without sharing class HWS_TokenGenerate {
	/****************************************
* Name : getToken
* Description : Retreives token from EDP by making a callout
* Parameters: 
* Returns : HttpResponse which contains token
*****************************************/
	public String getToken(){
		String token = '';
		boolean debug;
		HTTPResponse response;
		String pdmSource = Label.HWS_PDM_Source;
		system.debug('Token response');
		string resource = EDP_URLs__c.getInstance('resource').URL__c;
		system.debug('Token response from resource: '+resource);
		try{
			AuthProvider auth =[SELECT ConsumerKey,
								ConsumerSecret,
								DeveloperName,
								Id 
								FROM AuthProvider 
								where DeveloperName = 'AzureEDP' 
								Limit 1];
			
			string clientId = auth.ConsumerKey;
			string clientSecret = '';
			if(!pdmSource.equalsIgnoreCase('Test')){
				clientSecret = auth.ConsumerSecret; 
			}
			HttpRequest req = new HttpRequest();  
			req.setMethod('POST');
			req.setEndpoint('callout:EDP_Login');
			req.setBody('grant_type=password' +
						'&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
						'&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
						'&username={!HTMLENCODE($Credential.Username)}' +
						'&password={!HTMLENCODE($Credential.Password)}' +
						'&resource=' +EncodingUtil.urlEncode(resource, 'UTF-8')   );
			Http http = new Http();
			response = http.send(req);
			//if(debug)
			System.debug('Response received from the token: '+response.getBody());
			
			JSONParser parser = JSON.createParser(response.getBody());
			while (parser.nextToken() != null) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
					(parser.getText() == 'access_token')) {
						// Get the value. 
						parser.nextToken();
						// Get the token	
						token = parser.getText();
						System.debug('Token is ' + token);
					}
			}
			return token;
		}catch(CalloutException ex){
			System.debug('CAllout Exception: '+ex);
			if(ex.getMessage() == 'Read timed out'){
				token = getToken();
				return token;				
			}
			else{
				return null;
			}
			
		}   
	}
}