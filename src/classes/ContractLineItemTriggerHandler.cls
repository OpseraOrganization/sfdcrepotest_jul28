/**
 * Created by tweinberger on 06/09/2018.
 */

public with sharing class ContractLineItemTriggerHandler extends TriggerHandler {
	private List<ContractLineItem> newContractLineItemList;
	private List<ContractLineItem> oldContractLineItemList;
	private Map<Id, ContractLineItem> newContractLineItemMap;
	private Map<Id, ContractLineItem> oldContractLineItemMap;

	public ContractLineItemTriggerHandler() {
		newContractLineItemList = (List<ContractLineItem>) Trigger.new;
		oldContractLineItemList = (List<ContractLineItem>) Trigger.old;
		newContractLineItemMap = (Map<Id, ContractLineItem>) Trigger.newMap;
		oldContractLineItemMap = (Map<Id, ContractLineItem>) Trigger.oldMap; 
	}

	protected override void beforeInsert() {
		ContractLineItemTriggerHelper.createBeforeInsertContractLineItem(newContractLineItemList);
	}

}