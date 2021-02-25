/**
About
-----
Description: This Class is used as Helper for CH_KnowledgeTrigger.

Created for: Nokia Portugal COE
Created: 17 04 2019

Update History
--------------
Created: 17 04 2019 – flavio.toscano@nokia.com
-------------
**/
public with sharing class CH_KnowledgeHandler_TL {

	/*
	* @description : Validate If User can Edit Article (only if belong to the selected Workgroup)
	* @param : List<Knowledge__kav>
	* @return : void
	*/
	public static void validateIfUserCanEditArticle(List<Knowledge__kav> oCH_Knowledge) {
		final Id KnowledgeHowToRT = Utils.MapRecordType('Knowledge__kav').get('CH_HowTo');
		final Id KnowledgeStandardRT = Utils.MapRecordType('Knowledge__kav').get('CH_Standard');
		final Id KnowledgeResolutionRT = Utils.MapRecordType('Knowledge__kav').get('CH_Resolution');
		final Id KnowledgeTechnicalProcedureRT = Utils.MapRecordType('Knowledge__kav').get('CH_TechnicalProcedure');
		final Id KnowledgeAlarmRT = Utils.MapRecordType('Knowledge__kav').get('CH_Alarm');
		final Id workgroupMemberRT = Utils.MapRecordType('CH_Workgroup_Member__c').get('CH_KB_Workgroup_Members');
		
		Boolean canEdit = true;
		Id strCurrentUserId = UserInfo.getUserId();
		
		List<CH_Workgroup_Member__c> workgroupMemberList = new List<CH_Workgroup_Member__c>();
		Map <Id,Id> workgroupIdUserId = new Map<Id,Id>();
		List<Id> workgroupIdUserIdKeys = new List<Id>();
		List<Id> workgroupIdUserIdValues = new List<Id>();
				
		AggregateResult results = [SELECT count(Id) userHasPermission FROM PermissionSetAssignment WHERE AssigneeId = :strCurrentUserId AND (PermissionSet.Name = 'CH_Author' OR PermissionSet.Name = 'CH_Approver' OR PermissionSet.Name = 'CH_Publisher')];
		Integer userHasPermission = (Integer)results.get('userHasPermission');
		system.debug(results);
		
		workgroupMemberList = CH_EM_WorkgroupMember.validateIfUserIsAWorkgroupMember(Userinfo.getUserId(), workgroupMemberRT);
		system.debug(workgroupMemberList);
		system.debug('Userinfo.getUserId() --> ' + Userinfo.getUserId());
		if(!workgroupMemberList.isEmpty()){
			canEdit = true;
			for(CH_Workgroup_Member__c workgroupMember :workgroupMemberList){
				workgroupIdUserId.put(workgroupMember.CH_Workgroup__c, workgroupMember.CH_User__c);
			}
			workgroupIdUserIdKeys = new List<Id>(workgroupIdUserId.keySet());
			workgroupIdUserIdValues = workgroupIdUserId.values();
			system.debug(workgroupIdUserIdKeys);
			system.debug(workgroupIdUserIdValues);
		} else {
			canEdit = true;
		}
		for(Knowledge__kav oKnowledge: oCH_Knowledge) {
			if(oKnowledge.CH_InApproval__c == false){
				if(oKnowledge.RecordTypeId == KnowledgeHowToRT || oKnowledge.RecordTypeId == KnowledgeStandardRT || oKnowledge.RecordTypeId == KnowledgeResolutionRT || oKnowledge.RecordTypeId == KnowledgeTechnicalProcedureRT || oKnowledge.RecordTypeId == KnowledgeAlarmRT) {
					if(oKnowledge.CH_Workgroup__c != null){
						if(userHasPermission > 0){
							system.debug('aqui workgroupIdUserIdKeys --> ' + workgroupIdUserIdKeys);
							if(!workgroupIdUserIdKeys.contains(oKnowledge.CH_Workgroup__c)){
								system.debug(oKnowledge.CH_Workgroup__c);
								oKnowledge.addError('You are not allowed to update this Article, since you do not belong to the mentioned Workgroup.');
							}
						} else {
							canEdit = true;
							oKnowledge.addError('You are not allowed to update this Article, since you do not belong to the mentioned Workgroup.'); 
						}
					}
				}
			}
		}
	}
	
	/*
	* @description : Validate If User can Delete Article (only if belong to the selected Workgroup)
	* @param : List<Knowledge__kav>
	* @return : void
	*/
	public static void validateIfUserCanDeleteArticle(List<Knowledge__kav> oCH_Knowledge) {
		final Id KnowledgeHowToRT = Utils.MapRecordType('Knowledge__kav').get('CH_HowTo');
		final Id KnowledgeStandardRT = Utils.MapRecordType('Knowledge__kav').get('CH_Standard');
		final Id KnowledgeResolutionRT = Utils.MapRecordType('Knowledge__kav').get('CH_Resolution');
		final Id KnowledgeTechnicalProcedureRT = Utils.MapRecordType('Knowledge__kav').get('CH_TechnicalProcedure');
		final Id KnowledgeAlarmRT = Utils.MapRecordType('Knowledge__kav').get('CH_Alarm');
		
		Boolean canDelete = false;
		Id strCurrentUserId = UserInfo.getUserId();
				
		AggregateResult results = [SELECT count(Id) userHasPermission FROM PermissionSetAssignment WHERE AssigneeId = :strCurrentUserId AND (PermissionSet.Name = 'CH_Author' OR PermissionSet.Name = 'CH_Approver' OR PermissionSet.Name = 'CH_Publisher')];   
		Integer userHasPermission = (Integer)results.get('userHasPermission');
		
		for(Knowledge__kav oKnowledge: oCH_Knowledge) {
			system.debug('oKnowledge.PublishStatus --> ' + oKnowledge.PublishStatus);
			system.debug('oKnowledge.CH_InApproval__c --> ' + oKnowledge.CH_InApproval__c);
			if(oKnowledge.CH_InApproval__c == false && oKnowledge.PublishStatus == 'Draft' && oKnowledge.ValidationStatus != 'Needs Approver Review'){
				if(oKnowledge.RecordTypeId == KnowledgeHowToRT || oKnowledge.RecordTypeId == KnowledgeStandardRT || oKnowledge.RecordTypeId == KnowledgeResolutionRT || oKnowledge.RecordTypeId == KnowledgeTechnicalProcedureRT || oKnowledge.RecordTypeId == KnowledgeAlarmRT) {
					if(oKnowledge.CH_Workgroup__c != null && oKnowledge.CreatedById != strCurrentUserId){
						if(userHasPermission > 0){
							oKnowledge.addError('You are not allowed to delete this Article, since you do not issued the mentioned Article.');
						} else {
							canDelete = false;
							oKnowledge.addError('You are not allowed to delete this Article, since you do not issued the mentioned Article.'); 
						}
					}
				}
			}
		}
	}
	
	/*
	* @description : Assign Owner to Article, if record is on Approval Status and Update Approver
	* @param : List<Knowledge__kav>
	* @return : void
	*/
	public static void assignOwnerIfInApprovalStatus(List<Knowledge__kav> oOldCH_Knowledge, List<Knowledge__kav> oNewCH_Knowledge) {
		final Id KnowledgeHowToRT = Utils.MapRecordType('Knowledge__kav').get('CH_HowTo');
		final Id KnowledgeStandardRT = Utils.MapRecordType('Knowledge__kav').get('CH_Standard');
		final Id KnowledgeResolutionRT = Utils.MapRecordType('Knowledge__kav').get('CH_Resolution');
		final Id KnowledgeTechnicalProcedureRT = Utils.MapRecordType('Knowledge__kav').get('CH_TechnicalProcedure');
		final Id KnowledgeAlarmRT = Utils.MapRecordType('Knowledge__kav').get('CH_Alarm');
		final Id KnowledgeKnownErrorRT = Utils.MapRecordType('Knowledge__kav').get('CH_KnownError');
		
		Map <Id,String> queueIdQueueAPIName = new Map<Id,String>();
		List<Group> queueList = new List<Group>();
		List<Id> queueIdQueueAPINameKeys = new List<Id>();
		List<String> queueIdQueueAPINameValues = new List<String>();
		List<Knowledge__kav> knowledgeListToUpdate = new List<Knowledge__kav>();
		Map<Id,Id> knowledgeIdToQueueId = new Map<Id,Id>();
		List<ProcessInstanceWorkitem> processInstanceWorkitemListToUpdate = new List<ProcessInstanceWorkitem>();
		
		queueList = EM_Group.getAllKBQueues();
		
		if(!queueList.isEmpty()){
			for(Group queue :queueList){
				queueIdQueueAPIName.put(queue.Id, queue.Name);
			}
			queueIdQueueAPINameKeys = new List<Id>(queueIdQueueAPIName.keySet());
			queueIdQueueAPINameValues = queueIdQueueAPIName.values();
		}	   
		for(Knowledge__kav oOldKnowledge: oOldCH_Knowledge) {
			for(Knowledge__kav oNewKnowledge: oNewCH_Knowledge) {
				if(oOldKnowledge.Id == oNewKnowledge.Id && oNewKnowledge.CH_Workgroup__c != null && oOldKnowledge.CH_InApproval__c == false && oNewKnowledge.CH_InApproval__c == true && (oNewKnowledge.RecordTypeId == KnowledgeHowToRT || oNewKnowledge.RecordTypeId == KnowledgeStandardRT || oNewKnowledge.RecordTypeId == KnowledgeResolutionRT || oNewKnowledge.RecordTypeId == KnowledgeTechnicalProcedureRT || oNewKnowledge.RecordTypeId == KnowledgeAlarmRT || oNewKnowledge.RecordTypeId == KnowledgeKnownErrorRT)) {
					//Approval Step 1 || Approver
					if(oNewKnowledge.CH_Minor_changes__c == true && oNewKnowledge.CH_ComingFromApprovalProcess__c == false && oNewKnowledge.CH_Candidate_for_External__c == false){
			knowledgeIdToQueueId.put(oNewKnowledge.Id, queueIdQueueAPINameKeys.get(queueIdQueueAPINameValues.indexOf((oNewKnowledge.CH_WorkgroupName__c + '_AQ'))));
					//Approval Step 2 || Approver  
					} else if(oNewKnowledge.CH_Minor_changes__c == false && oNewKnowledge.CH_ComingFromApprovalProcess__c == false && oNewKnowledge.CH_Candidate_for_External__c == false){
						system.debug('queueIdQueueAPINameValues --> ' + queueIdQueueAPINameValues);
						system.debug('oNewKnowledge.CH_WorkgroupName__c --> ' + oNewKnowledge.CH_WorkgroupName__c);
			knowledgeIdToQueueId.put(oNewKnowledge.Id, queueIdQueueAPINameKeys.get(queueIdQueueAPINameValues.indexOf((oNewKnowledge.CH_WorkgroupName__c + '_AQ'))));
					//Approval Step 3 || Approver
					} else if(oNewKnowledge.CH_Minor_changes__c == true && oNewKnowledge.CH_ComingFromApprovalProcess__c == false && oNewKnowledge.CH_Candidate_for_External__c == true){
			knowledgeIdToQueueId.put(oNewKnowledge.Id, queueIdQueueAPINameKeys.get(queueIdQueueAPINameValues.indexOf((oNewKnowledge.CH_WorkgroupName__c + '_AQ'))));
					//Approval Step 4 || Approver
					} else if(oNewKnowledge.CH_Minor_changes__c == false && oNewKnowledge.CH_ComingFromApprovalProcess__c == false && oNewKnowledge.CH_Candidate_for_External__c == true){
			knowledgeIdToQueueId.put(oNewKnowledge.Id, queueIdQueueAPINameKeys.get(queueIdQueueAPINameValues.indexOf((oNewKnowledge.CH_WorkgroupName__c + '_AQ'))));
					}																							 
				} else if(oOldKnowledge.Id == oNewKnowledge.Id && oNewKnowledge.CH_Workgroup__c != null && (oNewKnowledge.ValidationStatus == 'Needs Publisher Review' || (oNewKnowledge.ValidationStatus == 'Internal Approved' && oNewKnowledge.CH_ComingFromApprovalProcess__c == true)) && oNewKnowledge.CH_InApproval__c == true && (oNewKnowledge.RecordTypeId == KnowledgeHowToRT || oNewKnowledge.RecordTypeId == KnowledgeStandardRT || oNewKnowledge.RecordTypeId == KnowledgeResolutionRT || oNewKnowledge.RecordTypeId == KnowledgeTechnicalProcedureRT || oNewKnowledge.RecordTypeId == KnowledgeAlarmRT)) {
					 
					//Approval Step 5 || Publisher
					if(oNewKnowledge.CH_Minor_changes__c == true && oNewKnowledge.CH_ComingFromApprovalProcess__c == true && oNewKnowledge.CH_Candidate_for_External__c == true){
			knowledgeIdToQueueId.put(oNewKnowledge.Id, queueIdQueueAPINameKeys.get(queueIdQueueAPINameValues.indexOf((oNewKnowledge.CH_WorkgroupName__c + '_PQ'))));
					//Approval Step 6 || Publisher
					} else if(oNewKnowledge.CH_Minor_changes__c == false && oNewKnowledge.CH_ComingFromApprovalProcess__c == true && oNewKnowledge.CH_Candidate_for_External__c == true){
			knowledgeIdToQueueId.put(oNewKnowledge.Id, queueIdQueueAPINameKeys.get(queueIdQueueAPINameValues.indexOf((oNewKnowledge.CH_WorkgroupName__c + '_PQ'))));
					}
				}
			}
		}
		
		if(!knowledgeIdToQueueId.isEmpty()){ 
			updateProcessInstanceWorkitem(knowledgeIdToQueueId);
		}
	}
	
	/*
	* @description : Future Method to Update Knowledge Approver
	* @param : Map<Id,Id>
	* @return : void
	*/
	@future
	private static void updateProcessInstanceWorkitem(Map<Id,Id> knowledgeIdToQueueId) {
		
		List<ProcessInstanceWorkitem> processInstanceWorkitemListToUpdate = new List<ProcessInstanceWorkitem>();
		system.debug(knowledgeIdToQueueId);
		if(!knowledgeIdToQueueId.isEmpty()){
			processInstanceWorkitemListToUpdate = EM_ProcessInstance.getProcessInstanceWorkitemByTargetObjectId(knowledgeIdToQueueId.keySet());	
			system.debug(processInstanceWorkitemListToUpdate);
			for(ProcessInstanceWorkitem processInstanceWorkItem : processInstanceWorkitemListToUpdate){
				processInstanceWorkItem.OriginalActorId = (knowledgeIdToQueueId.get(processInstanceWorkItem.ProcessInstance.TargetObjectId));
				processInstanceWorkItem.ActorId = (knowledgeIdToQueueId.get(processInstanceWorkItem.ProcessInstance.TargetObjectId));
			}
			if(!processInstanceWorkitemListToUpdate.isEmpty()){
				system.debug(processInstanceWorkitemListToUpdate);
				//update processInstanceWorkitemListToUpdate;
				EM_ProcessInstance.doUpdateProcessInstanceWorkitemList(processInstanceWorkitemListToUpdate);
			}
		}
	}
	
	/********************
	*Method Name: setDefaultDataCategories
	*Parameter: New Article List (Only Case Handling Record Type Records)
	*Description: Used to assign default Data Category Groups and Data Categories
	*******************/
	public static void setDefaultDataCategories(List<Knowledge__kav> articleList){
		List<Knowledge__DataCategorySelection> KnowDataSel = new List<Knowledge__DataCategorySelection>();
		System.debug('********List of Articles: ' + articleList);
		for(Knowledge__kav k : articleList){
			//List<RecordType> recordTypeList = [SELECT Id,DeveloperName FROM RecordType WHERE  Id=:k.RecordTypeId];
			//RecordType recordType = recordTypeList.get(0);
			//String recordTypeName = recordType.DeveloperName;
			//System.debug('******** RecordTypeName '+ recordTypeName);
			//if(recordTypeName.contains('CH')){
				//System.debug('*******Knowledge Article ID: '+k.Id);
				
				Knowledge__DataCategorySelection dataCategorySelection = new Knowledge__DataCategorySelection();
				//System.debug('*******DataCategorySelection after create: '+dataCategorySelection);
				dataCategorySelection.DataCategoryGroupName = 'Case_Handling';
				System.debug('*******DataCategorySelection GroupName: '+ dataCategorySelection.DataCategoryGroupName);
				//dataCategorySelection.DataCategoryName = 'All';
				//System.debug('*******DataCategorySelection CategoryName: '+dataCategorySelection.DataCategoryName);
				dataCategorySelection.DataCategoryName = 'Case_Handling';
				System.debug('*******DataCategorySelection CategoryName: '+dataCategorySelection.DataCategoryName);
				System.debug('ParentId******' + k.Id);
				dataCategorySelection.ParentId = k.Id;
				//System.debug('*******DataCategorySelection ParentId: '+dataCategorySelection.ParentId);
				KnowDataSel.add(dataCategorySelection);
				//insert dataCategorySelection;
			//}
		}
		if(KnowDataSel.size()>0){
			insert KnowDataSel;
					
		}
		
	}
	/********************
	*Method Name: getProductFromLatestVersion
	*Parameter: New Article List (Only Case Handling Record Type Records)
	*Description: Used to replicate related CH_ProductRelation__c from latest article version to new one
	*******************/
	public static void getProductFromLatestVersion(List<Knowledge__kav> articleList){
		Set<Id> parentArticleIds = new Set<Id>();
		for(Knowledge__kav kav : articleList){
			if(!parentArticleIds.contains(kav.KnowledgeArticleId)){
				parentArticleIds.add(kav.KnowledgeArticleId);
			}
		}
		List<Knowledge__ka> parentArticleList = [Select id from Knowledge__ka where id in: parentArticleIds];
		List<Knowledge__kav> allPublishedArticlesFromParents = [Select id, KnowledgeArticleId,
																(SELECT Id, CH_Knowledge__c, CH_Parent_Release__c, CH_Parent_Product__c, CH_Relation_Type__c from CH_Product_Relations__r)
																from Knowledge__kav where KnowledgeArticleId in: parentArticleIds and PublishStatus = 'Online'];
		Map<Id,Knowledge__kav> articlesMap = new Map<Id,Knowledge__kav>();
		Map<Id,List<CH_ProductRelation__c>> productRelationsMap = new Map<Id,List<CH_ProductRelation__c>>();
		
		for(Knowledge__ka ka : parentArticleList){
			for(Knowledge__kav kav : allPublishedArticlesFromParents){
				if(kav.KnowledgeArticleId == ka.id){
					articlesMap.put(ka.id,kav);
				}
			}
		}
		List<CH_ProductRelation__c> productRelationListToInsert = new List<CH_ProductRelation__c>();
		for(Knowledge__kav kav : articleList){
			if(articlesMap.keySet().contains(kav.KnowledgeArticleId)){
				if(!articlesMap.get(kav.KnowledgeArticleId).CH_Product_Relations__r.isEmpty()){
					for(CH_ProductRelation__c relation : articlesMap.get(kav.KnowledgeArticleId).CH_Product_Relations__r){
						CH_ProductRelation__c newRelation = new CH_ProductRelation__c();
						newRelation.CH_Knowledge__c = kav.id;
						newRelation.CH_Parent_Release__c = relation.CH_Parent_Release__c;
						newRelation.CH_Parent_Product__c = relation.CH_Parent_Product__c;
						newRelation.CH_Relation_Type__c = relation.CH_Relation_Type__c;
						productRelationListToInsert.add(newRelation);
					}
				}
			}
		}
		if(!productRelationListToInsert.isEmpty()){
			insert productRelationListToInsert;
		}
	}
}