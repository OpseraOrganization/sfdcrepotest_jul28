public without sharing class HWS_CancelCase {
	
	@auraEnabled
	public static List<String> cancelChildCases(String casId){
		List<String> caseList = new List<String>(); 
		List<Case> caseList2 = new List<Case>();
		List<Case> orderChildCases = new List<Case>();
		try{
			//US-1409 Used to capture parentcaseId when user clicks "Cancel" button on parent
			id parentCaseIdToSend;
			HWS_BypassStatusChangeValidation__c custSetting= HWS_BypassStatusChangeValidation__c.getInstance(); 
			Id getParentCasId=Id.valueOf(casId);  
			if(custSetting == null){
				custSetting = new HWS_BypassStatusChangeValidation__c();
			}
			List<case> lstCase = [Select id,parentId,Status,HWS_CancelConfirm__c from Case where Status != 'Cancelled' AND (parentId=:getParentCasId OR id=:getParentCasId)];
			Id orderedPraentId;
			if(!lstCase.isEmpty()){
				
				if(lstCase.size()>1){
					// result will come parent and child records
					for(Case c : lstCase){
						system.debug('----lstCase---'+c);
						//get the parent Id
						if(c.parentId != null && c.status == 'Ordered'){
							orderedPraentId = c.parentId;
							orderChildCases.add(c);
							system.debug('----orderChildCases---'+orderChildCases);
						}
						else if(c.Status == 'On Hold' || c.Status == 'Draft' || c.Status == 'New'){
							custSetting.HWS_BypassCaseStatusValidation__c = true;
							
							caseList.add(c.status);
							c.Status= 'Cancelled';
							caseList2.add(c); 
						}
						else if(c.Status == 'Shipped' || c.Status == 'Delivered' || c.Status == 'Partially Shipped') {
							caseList.add(c.status);
						}
						else if(c.Status == 'Request to Cancel'){caseList.add('child'+c.status);}
					}
					if(orderedPraentId != null)
					{
						custSetting.HWS_BypassCaseStatusValidation__c = true;
						// Passing Other method to make callout
						HWS_CancelcaseSendSRtoSOO_SVC.processResponse pr= HWS_CancelcaseSendSRtoSOO_SVC.sendToSOO(orderedPraentId,null);
						system.debug('pr:'+pr);
						if(!pr.isError){
							for(case c : orderChildCases){
								if(c.HWS_CancelConfirm__c == 'No')
								{
									c.HWS_CancelConfirm__c = 'Retried To Cancel';
								}
								c.Status = 'Request to Cancel';
								caseList.add(c.status);
								caseList2.add(c); 
								parentCaseIdToSend = c.parentId;
								
								
							}
						}
						else{
							for(case c : orderChildCases){
								if(c.HWS_CancelConfirm__c == 'No')
								{
									c.HWS_CancelConfirm__c = 'Retried To Cancel';
								}
								c.Status = 'Ordered';
								caseList.add(c.status);
								caseList2.add(c); 
								
								
							}
						}
					}
				}
				else{
					if(lstCase[0].status == 'Ordered'){
						HWS_CancelcaseSendSRtoSOO_SVC.processResponse pr = HWS_CancelcaseSendSRtoSOO_SVC.sendToSOO(lstCase[0].parentId,lstCase[0].Id);
						custSetting.HWS_BypassCaseStatusValidation__c = true;
						if(lstCase[0].HWS_CancelConfirm__c == 'No')
						{
							lstCase[0].HWS_CancelConfirm__c = 'Retried To Cancel';
						}
						if(!pr.isError){
							
							lstCase[0].Status = 'Request to Cancel';
							caseList.add(lstCase[0].status);
							caseList2.add(lstCase[0]); 
							parentCaseIdToSend = lstCase[0].parentId;
						}
						else{
							lstCase[0].Status = 'Ordered';
							caseList.add(lstCase[0].status);
							caseList2.add(lstCase[0]); 
						}
						
					}
					else if(lstCase[0].Status == 'On Hold' || lstCase[0].Status == 'Draft' || lstCase[0].Status == 'New'){
						custSetting.HWS_BypassCaseStatusValidation__c = true;
						
						caseList.add(lstCase[0].status);
						lstCase[0].Status= 'Cancelled';
						caseList2.add(lstCase[0]); 
					}
					else if(lstCase[0].Status == 'Shipped' || lstCase[0].Status == 'Delivered' || lstCase[0].Status == 'Partially Shipped'){
						caseList.add('child'+lstCase[0].status);
					}
					else if(lstCase[0].Status == 'Request to Cancel' ){caseList.add('child'+lstCase[0].status);}
				}
			}
			if(custSetting != null ) {
				upsert custSetting;
			}
			if(!caseList2.isEmpty()){
				system.debug('caseList2:'+caseList2);   
				Database.SaveResult[] updateChildCases = Database.update(caseList2);
				custSetting.HWS_BypassCaseStatusValidation__c = false;
			}
			if(custSetting!=null){
				update custSetting;
			}
			return caseList;
		}
		
		Catch(Exception e){
			System.debug('Error in CancelCase***'+e.getMessage() +'on line number ' +e.getLineNumber() + ' '+ e.getCause());
			return null;
		}
	}
}