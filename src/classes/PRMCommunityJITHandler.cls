/**
* @description  : This class covers JIT implementation for PRM Partner portal
* @author	   :	Accenture IDC.
*
* ============================================================================
* History:
* -------
* 
* VERSION	   AUTHOR				  DATE		   DETAIL				 FEATURES/CSR/TTP
* 1.0		   Sonali Kothavale		18/06/2018	 PRM Release 4
* ============================================================================ 
**/

global class PRMCommunityJITHandler implements Auth.SamlJitHandler {
	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : Id samlSsoProviderId, Id communityId, Id portalId,
				String federationIdentifier, Map<String, String> attributes, String assertion
	* Return	: User
	* Description: Method to createUser in JIT inerface
	**********************************************************************************************************************/ 
	private class JitException extends Exception{}
  global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
						  String federationIdentifier, Map<String, String> attributes, String assertion){
		System.debug('In createUser:'+attributes);
		User newUser = new User();
		handleJitPRM(true, newUser, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
		return newUser;
	}
	
	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
				String federationIdentifier, Map<String, String> attributes, String assertion
	* Return	: none
	* Description: Method to update User in JIT inerface
	**********************************************************************************************************************/ 
	
	global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
			String federationIdentifier, Map<String, String> attributes, String assertion) {
	
	System.debug('In updateUser: '+attributes);
		User newUser = new User();
		User existingUser = [SELECT Id,NCP_Relationship__c, contactId, isActive, ProfileId, Profile.Name FROM User WHERE Id = :userId Limit : (Limits.getLimitQueryRows() - Limits.getQueryRows())];
		if(existingUser.ProfileId != System.Label.PRM_Partner_Profile_Id
		   && existingUser.ProfileId != System.Label.PRM_Unauthorized_Partner_Profile && existingUser.ProfileId != System.Label.PRM_Partner_Relationship_Manager_Login_ID &&existingUser.isActive) {
			throw new JitException('Single Sign On Error: You do not have access to the Nokia Partner Portal' + serializeMap(attributes));
		}
		if (existingUser.isActive) {
			handleJitPRM(false, existingUser, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
		} else {
			handleJitPRM(true, newUser, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
		}
	}
	
	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : IBoolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
				String federationIdentifier, Map<String, String> attributes, String assertion
	* Return	: none
	* Description: Method to handle New and Update user post process for JIT
	**********************************************************************************************************************/ 
	
	private void handleJitPRM(Boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
			String federationIdentifier, Map<String, String> attributes, String assertion) {
		System.debug('attributes: '+attributes);
		for(string keys : attributes.keyset() ){
			system.debug('Attribute Name :->'+keys+ ' ||Attribute Value--> '+attributes.get(keys));
		}
		System.debug('Inside handleJitPRM@@@@ ');
		System.debug('communityId>>> '+communityId);
		System.debug('portalId>>> '+portalId);
		String relationship = attributes.get('Relationship');
		System.debug('relationship>>> '+relationship);
		if(String.isBlank(relationship) || relationship == PRMGlobalConstants.NULL_VALUE){
			throw new JitException('Relationship not identified!'+ serializeMap(attributes));
		}
		if (PRMGlobalConstants.Internal.equalsIgnoreCase(relationship) || PRMGlobalConstants.PARTNER.equalsIgnoreCase(relationship)){
		  String contactId = '';
		  String accID = '';
	  Id OwnerId;
		  if (communityId != null || portalId != null) {
				accID = jitAccountHandlerPRM(create, u, attributes);
				system.debug('accID-at the time of login'+accID);
			  Account acct;
				String parentAccountId;
			   String acctname;
				try{
				  acct = [SELECT Id,name, parentId, parent.OwnerId, parent.Partner_Type__c FROM Account WHERE id = :accID limit 1];
				  parentAccountId = acct.parentId;
				  acctname = acct.name;
		  OwnerId = acct.parent.OwnerId;
				}catch(Exception e){
					System.debug('Error ##66 ##' + e);
					throw new JitException('ParentAccount Id or Account Id not identified! '+ '	' +e +serializeMap(attributes));
				}
				contactId = jitContactHandlerPRM(create, accID, parentAccountId,acctname, u, attributes, acct.parent.Partner_Type__c);
				if(String.isBlank(contactId) || contactId == PRMGlobalConstants.NULL_VALUE){
					throw new JitException('Contact can not be identified!'+ serializeMap(attributes));
				}
				jitUserHandlerPRM(create, u, contactId, accID, OwnerId, attributes, federationIdentifier, false);
		  } else {
				jitUserHandlerPRM(create, u, contactId, accID, OwnerId, attributes, federationIdentifier, true);
		  }
		}
	}

	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : IBoolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
				String federationIdentifier, Map<String, String> attributes, String assertion
	* Return	: none
	* Description: Method to handle New and Update user post process for JIT
	**********************************************************************************************************************/ 
	 private string jitAccountHandlerPRM(Boolean create, User u, Map<String, String> attributes) {
		System.debug('Inside jitAccountHandlerPRM@@@@ ');
		string accountId = '';
		String parentAccountId = '';
		String accountName = '';
		String accountNumber = '';
		String userApprovalStatus = '';
		String p20Id = '';
		String alcrId = '';
		String horizontalFlag = '';
	Account acct;
	
		if (attributes.containsKey('ApprovalStatus')) {
			userApprovalStatus = attributes.get('ApprovalStatus');
		}
		if (attributes.containsKey('Customer Name')) {
			accountName = attributes.get('Customer Name');
		}
		if (attributes.containsKey('P20')) {
			p20Id = attributes.get('P20');
		}
		if (attributes.containsKey('ALCR')) {
			alcrId = attributes.get('ALCR');
		}		
	  //System.debug('p20Id ##p20Id ##' + p20Id);  
	  //System.debug('userApprovalStatus ##userApprovalStatus ##' + userApprovalStatus);
	  
	if (userApprovalStatus != 'Approved') {
		 if (alcrId != '' && alcrid != null){
			  try{
				 acct = [SELECT Id, parentId FROM Account where acc_no__c = :alcrId LIMIT 1];
				  //acct = [SELECT Id, parentId FROM Account where id = '0014100001yU42y' LIMIT 1];
			  }catch(Exception e){
				System.debug('Error ##11 ##' + e);
				  throw new JitException('ParentAccount Id or Account Id not identified for not Approved user using AlcrID!'+ '	' +e +serializeMap(attributes));
			  }
			  accountId = acct.Id;
			  parentAccountId = acct.parentId;
		  }
		  else if (p20Id != '' && p20Id != null){
		  try{
			  acct = [SELECT Id, parentId FROM Account where NCP_P20_ID__c = :p20Id LIMIT 1];
		  }catch(Exception e){
			  System.debug('Error ##22 ##' + e);
			  throw new JitException('ParentAccount Id or Account Id not identified for not Approved user using P20ID !'+ '	' +e + serializeMap(attributes));
		   }
		accountId = acct.Id;
		parentAccountId = acct.parentId;
		  }else{
			  accountName = NCP_CustomerCommunitySetting__c.getValues('Default').Customer_Account__c;
			  accountNumber = NCP_CustomerCommunitySetting__c.getValues('Default').Customer_Account_Number__c;
		  try{
				//get accountId and parentAccountId
				acct = [SELECT Id, parentId FROM Account WHERE accountNumber = :accountNumber AND name = :accountName LIMIT 1];
			}
			catch(Exception e){
				System.debug('Error ##33 ##' + e);
				throw new JitException('ParentAccount Id or Account Id not identified for non Approved User!'+ '	' +e + serializeMap(attributes));
			}
		  }
		  accountId = acct.Id;
		  parentAccountId = acct.parentId;
	  } else {// user status is approved
			//system.debug('inside else loop');
			//system.debug('inside else loop alcr'+alcrId);
			//system.debug('inside else loop pid'+p20Id);
			if(String.isNotBlank(alcrId) && alcrId != '0'){
			  try{
			  //system.debug('inside else loop alcr chk inside'+alcrId);
				  acct = [SELECT Id, parentId FROM Account where acc_no__c = :alcrId LIMIT 1];
			  }catch(Exception e){
				System.debug('Error #44 ##' + e);
				throw new JitException('ParentAccount Id or Account Id not identified using AlcrID!'+ '	' +e + serializeMap(attributes));
			  }
				accountId = acct.Id;
				parentAccountId = acct.parentId;
			  }
			  else if(String.isNotBlank(p20Id)  && p20Id != '0') {
				try{
				//system.debug('inside else loop p20id chk inside'+alcrId);
				  acct = [SELECT Id, parentId FROM Account where NCP_P20_ID__c = :p20Id LIMIT 1];
				  // system.debug('accountId after approved acct'+acct.Id);
				}catch(Exception e){
					System.debug('Error ##55 ##' + e);
					throw new JitException('ParentAccount Id or Account Id not identified using P20ID !'+ '	' +e +serializeMap(attributes));
				}
				  accountId = acct.Id;
				  //system.debug('accountId after approved'+accountId);
				  parentAccountId = acct.parentId;
				  //system.debug('parentAccountId after approved'+parentAccountId);
			  }
	   }	
		return accountId;
	}
	
	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : IBoolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
				String federationIdentifier, Map<String, String> attributes, String assertion
	* Return	: none
	* Description: Method to handle New and Update user post process for JIT
	**********************************************************************************************************************/ 
	private String jitContactHandlerPRM(Boolean create, String accountId, String parentAccountId,  String acctname,User u, Map<String, String> attributes, String accPartnerType) {
		 Contact userContact = new Contact();
		try{
		 List<Contact> contacts;
		System.debug('Inside jitContactHandlerPRM@@@@ ');
	   
		if (attributes.containsKey('emailID')) {
			String email = attributes.get('emailID');
			contacts = [SELECT Id, lastName, firstName, Email, AccountId,User_Partner_Type__c,MailingCountryCode,CH_ContactType__c,NCP_External_Contact_Id__c FROM Contact WHERE id = :u.ContactId OR email = :email LIMIT 1];
		} else {
			contacts = [SELECT Id, lastName, firstName, Email, AccountId,User_Partner_Type__c,MailingCountryCode,CH_ContactType__c,NCP_External_Contact_Id__c FROM Contact WHERE id = :u.ContactId LIMIT 1];
		}
	   
		if (!contacts.isEmpty()) {
			System.debug('contactList>>>'+contacts);
			
			userContact = contacts[0];
		}
		System.debug('userContact.id, name: '+userContact.Id+', '+userContact.lastName+', '+userContact.FirstName+', email:'+userContact.email);
		System.debug('userContact.accountId: '+userContact.accountId);
		System.debug('accountId: '+accountId);
		System.debug('parentAccountId: '+parentAccountId);
		if (String.isNotBlank(accountId) && String.isNotBlank(parentAccountId)) {
			 system.debug('in if::');
			if(userContact.accountId != parentAccountId){
			  userContact.AccountId = parentAccountId;
			} 
		}
			system.debug('userContact.AccountId::'+userContact.AccountId);
			system.debug('parentAccountId::'+parentAccountId);
		userContact.CH_Legal_Entity_Name__c = acctname;
		   userContact.User_Create_Status__c= 'Completed';
		   //userContact.email = 'smokeprm3@gmail.com';
			System.debug('before : '+userContact.User_Partner_Type__c);
		   userContact.User_Partner_Type__c = accPartnerType;
			System.debug('after: '+userContact.User_Partner_Type__c);
		  userContact.SystemL__c = acctname;
		  System.debug('CH_Legal_Entity_Name__c: '+userContact.CH_Legal_Entity_Name__c);
		/*if (String.isNotBlank(accountId)){
			userContact.AccountId = accountId;
		}*/
		if (attributes.containsKey('Fname')) {
			userContact.FirstName = attributes.get('Fname');
		}
		if (attributes.containsKey('Lname')) {
			userContact.LastName = attributes.get('Lname');
		}
		if (attributes.containsKey('City')) {
			userContact.City__c = attributes.get('City');
		}
		if (attributes.containsKey('Street')) {
			userContact.Street__c = attributes.get('Street');
		}
		if (attributes.containsKey('State')) {
			userContact.State__c = attributes.get('State');
		}
		if (attributes.containsKey('emailID')) {
			userContact.Email = attributes.get('emailID');
		}
		if (attributes.containsKey('Phone')) {
			userContact.Phone = attributes.get('Phone');
		}
		if (attributes.containsKey('MobilePhone')) {
			userContact.MobilePhone = attributes.get('MobilePhone');
		}
		if (attributes.containsKey('Country')) {
			userContact.Country__c = attributes.get('Country');
			userContact.CH_ContactType__c = 'Partner';
		}
		 if (attributes.containsKey('SSOPID')) {
			userContact.NCP_External_Contact_Id__c = attributes.get('SSOPID');
	   }   

		if (contacts.isEmpty()) {
			if (!Schema.sObjectType.Contact.isCreateable()) {
				System.debug(LoggingLevel.Error, 'you don\'t have access to create Contact');
			} else {
				insert userContact;
				 System.debug('Insert: ');
			}
		} else {
			if (!Schema.sObjectType.Contact.isUpdateable()) {
				System.debug(LoggingLevel.Error, 'you don\'t have access to update Contact ');
			} else {
				System.debug('CH_Legal_Entity_Name__c: before update'+userContact.CH_Legal_Entity_Name__c);
				update userContact;
				 System.debug('update: ');
			}
		}
		
		System.debug('accountId: '+accountId);
		System.debug('userContact: '+userContact.Id);
		System.debug('userContact: '+userContact);
		//added by priyanka
		//
		//
		 if (String.isNotBlank(accountId)) {
	  //delete not correct Account Contact Relation records(not proper accountid)
	  List <AccountContactRelation> delACRList = [SELECT Id, contactId, accountId, NCP_Entitlement_Relationship__c from AccountContactRelation where contactId = :userContact.Id AND accountId != :accountId AND IsDirect != TRUE Limit : (Limits.getLimitQueryRows() - Limits.getQueryRows())];
	  if(delACRList.size() != 0){
		delete delACRList;
	  }


			String userApprovalStatus = '';
			if (attributes.containsKey('ApprovalStatus')) {
			  userApprovalStatus = attributes.get('ApprovalStatus');
			}				  
	  //get correct accoutContactRelation record. If not exist , create new
	  //List <AccountContactRelation> correctEntitlementRelationshipACRList = [SELECT Id, contactId, accountId, NCP_Entitlement_Relationship__c from AccountContactRelation where contactId = :c.Id AND accountId = :accountId AND  NCP_Entitlement_Relationship__c = True AND IsDirect != True];
	  List <AccountContactRelation> correctEntitlementRelationshipACRList = [SELECT Id, contactId, accountId, NCP_Entitlement_Relationship__c from AccountContactRelation where contactId = :userContact.Id AND accountId = :accountId AND IsDirect != True Limit : (Limits.getLimitQueryRows() - Limits.getQueryRows())];

			if(correctEntitlementRelationshipACRList.size() == 0){
			  AccountContactRelation acr = new AccountContactRelation();
			  acr.AccountId = accountId;
			  acr.ContactId = userContact.Id;

			  if(PRMGlobalConstants.Approved.equalsIgnoreCase(userApprovalStatus)){
				acr.NCP_Entitlement_Relationship__c = True;
			  }
			  else{
				acr.NCP_Entitlement_Relationship__c = False;
			  }
			  
			  insert acr;
				
			}
			else if(correctEntitlementRelationshipACRList.size() == 1){

			  if(PRMGlobalConstants.Approved.equalsIgnoreCase(userApprovalStatus)){
				correctEntitlementRelationshipACRList[0].NCP_Entitlement_Relationship__c = True;
			  }
			  else{
				correctEntitlementRelationshipACRList[0].NCP_Entitlement_Relationship__c = False;
			  }
			  //system.debug('attributes---  '+attributes);
			  update (correctEntitlementRelationshipACRList[0]);
			}
			
			//gAccountId = accountId;
		}
		
		//ends here
	   
			}
		 catch(Exception Ex)
		 {
			 throw new JitException('Contact cannot be updated!'+ '	' +Ex +serializeMap(attributes));
		 }
		return userContact.id;
	}
	@future
	public static void futureUpdateUser(id userid, Map<String, String> attributes,String federationIdentifier, String accID, Id OwnerId, String profileName) {
	   User u = new User(Id=userid);
	   if(PRMGlobalConstants.Approved.equalsIgnoreCase(attributes.get(PRMGlobalConstants.ApprovalStatus))) {
		   if(profileName.contains('Manager')) {
			   u.ProfileId = System.Label.PRM_Partner_Relationship_Manager_Login_ID;
		   }else {
			   u.ProfileId = System.Label.PRM_Partner_Profile_Id;
		   }
	   }else {
			u.ProfileId = System.Label.PRM_Unauthorized_Partner_Profile;
	   }
	   if(Test.isRunningTest()){
		   u.ProfileId = System.Label.PRM_Partner_Profile_Id;
	   }
	   if (attributes.containsKey('emailID')) {
		   u.Email = attributes.get('emailID');
		   u.NCP_CDB_Contact_ID__c = attributes.get('emailID');
	   }else{
		   u.Email = 'Test@test.com';
		   u.NCP_CDB_Contact_ID__c = attributes.get('emailID')+'.'+federationIdentifier;
	   }
	   if (attributes.containsKey('PersonalID')) {
		   u.NokiaUID__c = attributes.get('PersonalID');
	   }
	   if (attributes.containsKey('Lname')) {
		   u.LastName = attributes.get('Lname');
	   }
	   if (attributes.containsKey('Fname')) {
		   u.FirstName = attributes.get('Fname');
	   }
	   if (attributes.containsKey('Phone')) {
		   u.Phone = attributes.get('Phone');
	   }
	   if (attributes.containsKey('MobilePhone')) {
		   u.MobilePhone = attributes.get('MobilePhone');
	   }
	   if (attributes.containsKey('Country')) {
		   u.Country__c = attributes.get('Country');
	   }
	   if (attributes.containsKey('Street')) {
		   u.Street = attributes.get('Street');
	   }
	   if (attributes.containsKey('City')) {
		   u.City = attributes.get('City');
	   }
	   if (attributes.containsKey('State')) {
		   u.State__c = attributes.get('State');
	   }
	   if (attributes.containsKey('PostalCode')) {
		   u.PostalCode = attributes.get('PostalCode');
	   }		
	   if (attributes.containsKey('CountryCode')) {
		   u.CountryCode = attributes.get('CountryCode');
		   u.Market__c = ISO_Country_Codes__c.getvalues(u.CountryCode).Market__c;
		   u.Country__c = ISO_Country_Codes__c.getvalues(u.CountryCode).Country_Name__c;
	   }
	  /* if (attributes.containsKey('ApprovalStatus')) {
		   u.NCP_Approval_Status__c = attributes.get('ApprovalStatus');
	   }*/
	   if (attributes.containsKey('HorizontalFlag')) {
		   if(attributes.get('HorizontalFlag') == '1'){
			   u.NCP_IsHorizontal__c = True;
		   }else{
			   u.NCP_IsHorizontal__c = False;
		   }
	   }
	   if (attributes.containsKey('HorizontalCustomerName')) {
		   u.NCP_Horizontal_Company_Name__c = attributes.get('HorizontalCustomerName');
	   }
	   if (attributes.containsKey('SSOPID')) {
			u.NCP_SSOPID__c = attributes.get('SSOPID');
	   }
	   if (attributes.containsKey('Relationship')) {
			u.NCP_Relationship__c = attributes.get('Relationship');
	   }
	   if (PRMGlobalConstants.PARTNER.equalsIgnoreCase(u.NCP_Relationship__c)) {
		   u.UserPermissionsSFContentUser = True;
	   } else {
		   u.UserPermissionsSFContentUser = False;
	   }
	   Account companyAccount = [Select name from account where id = :accID LIMIT 1];
	   if (companyAccount != null) {
		   u.CompanyName = companyAccount.name;
	   }
	   if(OwnerId != null) {
		   u.managerId = OwnerId;
	   }
	   if (!Schema.sObjectType.Contact.isUpdateable()) {
			System.debug(LoggingLevel.Error, 'you don\'t have access to update User');
	   } else {
		   if(!Test.isRunningTest()){
			   update(u);
		   }
		   
	   }
	   
	}
	
	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : Boolean create, User u, String contactId, Map<String, String> attributes,
				  String federationIdentifier, Boolean isStandard
	* Return	: none
	* Description: Method to handle New and Update user post process for JIT
	**********************************************************************************************************************/ 
	private void jitUserHandlerPRM(Boolean create, User u, String contactId, String accID, Id OwnerId, Map<String, String> attributes,
			String federationIdentifier, Boolean isStandard) {
		System.debug('Inside jitUserHandlerPRM@@@@ ');
		if (!create) {
			futureUpdateUser(u.Id, attributes, federationIdentifier, accID, OwnerId, u.profile.Name);
		}
		if (create) {
			if(PRMGlobalConstants.Approved.equalsIgnoreCase(attributes.get(PRMGlobalConstants.ApprovalStatus))) {
				u.ProfileId = System.Label.PRM_Partner_Profile_Id;
			}else {
				u.ProfileId = System.Label.PRM_Unauthorized_Partner_Profile;
				if(Test.isRunningTest()){
				 u.ProfileId = System.Label.PRM_Partner_Profile_Id;
			 }
			}
			// PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = '0PS41000002Ed3m', AssigneeId = u.Id);
		   // insert psa; 
			if (attributes.containsKey('FederationIdentifier')) {
				u.FederationIdentifier = attributes.get('FederationIdentifier');
			} else {
				u.FederationIdentifier = federationIdentifier;
			}
			if(attributes.get('emailID') == PRMGlobalConstants.NULL_VALUE){
				u.Username = 'Test@singlecrm.accenture.com';
			}else {
				String[] emailPart = attributes.get('emailID').split('@');
				//u.Username = emailPart[0]+'@singlecrm.'+emailPart[1];
				u.Username = emailPart[0]+'@singlecrm.'+emailPart[1]+'.'+UserInfo.getUserName().substringAfterLast('.').toUpperCase();
				//u.Username = attributes.get('emailID').SubStringBefore('@')+'@singlecrm.accenture.com';
				Datetime Currdtime = System.now();
				string Strdtime = string.valueof(Currdtime);
				String TempComNickName=attributes.get('emailID').SubStringBefore('@')+'.'+Strdtime;
			   // u.CommunityNickname = attributes.get('emailID').SubStringBefore('@')+'.'+Strdtime;
				u.CommunityNickname = TempComNickName.right(36);
			  
				}
			String PrimaryAccount = 'true';
			if (attributes.containsKey('nsnPrimaryAccountFlag')) {
				PrimaryAccount = attributes.get('nsnPrimaryAccountFlag');
			}
			if(PRMGlobalConstants.true_val.equalsIgnoreCase(PrimaryAccount)) {
				u.NCP_CDB_Contact_ID__c = attributes.get('emailID');
			}else if(PRMGlobalConstants.false_val.equalsIgnoreCase(PrimaryAccount)) {
				u.NCP_CDB_Contact_ID__c = attributes.get('emailID')+'.'+federationIdentifier;
			}
			if (attributes.containsKey('PersonalID')) {
				u.Nokia_ID__c = attributes.get('PersonalID');
			}
		}

		if (attributes.containsKey('emailID')) {
			u.Email = attributes.get('emailID');
		  u.NCP_CDB_Contact_ID__c = attributes.get('emailID');
		}else{
			u.Email = 'Test@test.com';
		  u.NCP_CDB_Contact_ID__c = attributes.get('emailID')+'.'+federationIdentifier;
	}
		if (attributes.containsKey('PersonalID')) {
			u.NokiaUID__c = attributes.get('PersonalID');
		}
		if (attributes.containsKey('Lname')) {
			u.LastName = attributes.get('Lname');
		}
		if (attributes.containsKey('Fname')) {
			u.FirstName = attributes.get('Fname');
		}
		if (create && !String.isBlank(contactId)) {
			u.ContactId = contactId;
		}
		if (attributes.containsKey('Phone')) {
			u.Phone = attributes.get('Phone');
		}
		if (attributes.containsKey('MobilePhone')) {
			u.MobilePhone = attributes.get('MobilePhone');
		}
		
		if (attributes.containsKey('Country')) {
			u.Country__c = attributes.get('Country');
		}
	
	  //added by priyanka
	  if (attributes.containsKey('Street')) {
			u.Street = attributes.get('Street');
		}
		if (attributes.containsKey('City')) {
			u.City = attributes.get('City');
		}
		if (attributes.containsKey('State')) {
			u.State__c = attributes.get('State');
			//u.StateCode = attributes.get('State');
		}
	  if (attributes.containsKey('PostalCode')) {
			u.PostalCode = attributes.get('PostalCode');
		}		
		if (attributes.containsKey('CountryCode')) {
			u.CountryCode = attributes.get('CountryCode');
			u.Market__c = ISO_Country_Codes__c.getvalues(u.CountryCode).Market__c;
			u.Country__c = ISO_Country_Codes__c.getvalues(u.CountryCode).Country_Name__c;
		}
	   if (attributes.containsKey('ApprovalStatus')) {
			u.NCP_Approval_Status__c = attributes.get('ApprovalStatus');
		}
		if (attributes.containsKey('NSNID')) {
		  //if(PrimaryAccount == 'true'){
			  //u.NCP_NSN_ID__c = attributes.get('NSNID');
		//  }
		}
		
		if (attributes.containsKey('HorizontalFlag')) {
		  if(attributes.get('HorizontalFlag') == '1'){
			u.NCP_IsHorizontal__c = True;
		  }else{
			u.NCP_IsHorizontal__c = False;
		  }
		}
		//if (attributes.containsKey('HorizontalFlag')) {
		  //  u.NCP_IsHorizontal__c = attributes.get('HorizontalFlag').equals('True');
		//}
		if (attributes.containsKey('HorizontalCustomerName')) {
			u.NCP_Horizontal_Company_Name__c = attributes.get('HorizontalCustomerName');
		}
	
		if (attributes.containsKey('SSOPID')) {
			u.NCP_SSOPID__c = attributes.get('SSOPID');
		}
		if (attributes.containsKey('Relationship')) {
			u.NCP_Relationship__c = attributes.get('Relationship');
		}
	  //added by priyanka
	//
	
		
		
		if (PRMGlobalConstants.PARTNER.equalsIgnoreCase(u.NCP_Relationship__c)) {
			u.UserPermissionsSFContentUser = True;
		} else {
			u.UserPermissionsSFContentUser = False;
		}
		Account companyAccount = [Select name from account where id = :accID LIMIT 1];
		if (companyAccount != null) {
			u.CompanyName = companyAccount.name;
		}
		if (create) {
			
			u.Alias = u.LastName.left(4) + '1';
			u.TimeZoneSidKey = 'Europe/Amsterdam';
			u.LanguageLocaleKey = 'en_US';
			u.EmailEncodingKey = 'UTF-8';
			u.LocaleSidKey = 'en_GB';
		}
		if(OwnerId != null) {
				u.managerId = OwnerId;
			}

		if (!create) {
			if (!Schema.sObjectType.Contact.isUpdateable()) {
				System.debug(LoggingLevel.Error, 'you don\'t have access to update User');
			} else {
				Contact con = new Contact(Id = contactId);
				con.OwnerId = u.Id;
				if(PRMGlobalConstants.Approved.equalsIgnoreCase(attributes.get(PRMGlobalConstants.ApprovalStatus))) {
					update u;
					update con;
				}
			}
			
		} else {
			if (!Schema.sObjectType.Contact.isCreateable()) {
				System.debug(LoggingLevel.Error, 'you don\'t have access to create User');
			} else {
				try {
					
					system.debug('User details>>>>>>>>'+u.profileId);
					insert(u);
		  Contact con = new Contact(Id = contactId);
		  con.OwnerId = u.Id;
		  if(PRMGlobalConstants.Approved.equalsIgnoreCase(attributes.get(PRMGlobalConstants.ApprovalStatus))) {
			  update con;
		  }
				} catch (DMLException e) {
					throw new JitException('User can not be created!'+ '	' +e +serializeMap(attributes));
				}
			}
		}
		jitUserHandlerPRMFuture(u.id);
	}
	
	/**********************************************************************************************************************
	* author	: Accenture
	* Date	  : July 2018
	* Param	 : Boolean create, User u, String contactId, Map<String, String> attributes,
				  String federationIdentifier, Boolean isStandard
	* Return	: none
	* Description: Method to handle New and Update user post process for JIT
	**********************************************************************************************************************/ 
	private String serializeMap(Map<String, String> attributes) {
		return(JSON.serialize(attributes));
  }
	
	@future
	public static void jitUserHandlerPRMFuture(id userid) {
		system.debug('entered into future method');
		List<PermissionSetAssignment>  perSet = [select PermissionSetId ,AssigneeId 
										  from PermissionSetAssignment where AssigneeId =: userid 
											  AND PermissionSetId ='0PS41000002Ed3m' limit 1];
		if(perSet.size()==0){
			PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = '0PS41000002Ed3m', AssigneeId = userid);
			insert psa; 
		}
	}
}