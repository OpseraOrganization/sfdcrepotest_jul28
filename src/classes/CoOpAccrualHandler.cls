/**
* @description: Trigger Handler to check specific criteria and call helper methods before/after Accrual / CoOp Allocation insert or update
* @author:	Accenture IDC.
*
* ============================================================================
* History:
* -------
* 
* VERSION	   AUTHOR				  DATE		   DETAIL				 FEATURES/CSR/TTP
* 1.0		   Sonali Kothavale		25/05/2018	 PRM Release 3
* ============================================================================ 
*/
public without sharing class CoOpAccrualHandler{
	/**********************************************************************************************************************
* author: Accenture
* Date: May-2018
* Param: List<Co_Op_Allocation__c> AccrualList
* Return: void
* Description: Method for before Accrual insert
* High Level Process : 
**********************************************************************************************************************/ 
	public static void beforeInsertOperation(List<Co_Op_Allocation__c> CoOpAllocationNewList) { 
		try{ 
			system.debug('beforeInsertCoopAllocationHelperMethod');
				CoOpAccrualHelper.beforeInsertCoopAllocationHelperMethod(CoOpAllocationNewList);
			}
		
		catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.CoopAccrualHandler,PRMGlobalConstants.beforeInsertOperation);}
	}
	
	/**********************************************************************************************************************
* author: Accenture
* Date: May-2018
* Param: List<Co_Op_Allocation__c> AccrualList, Map<Id,Co_Op_Allocation__c> accrualOldMap
* Return: void
* Description: Method for before Accrual update
* High Level Process : 
**********************************************************************************************************************/ 
	/*public static void beforeUpdateOperation(List<Co_Op_Allocation__c> newAccrualList, Map<Id,Co_Op_Allocation__c> accrualOldMap) { 
try{ 
}
catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.CoopAccrualHandler,PRMGlobalConstants.beforeUpdateOperation);}
} 
*/
	/**********************************************************************************************************************
* author: Accenture
* Date: May-2018
* Param: List<Co_Op_Allocation__c> AccrualList
* Return: void
* Description: Method for After Accrual Insert
* High Level Process : 
**********************************************************************************************************************/ 
	public static void afterInsertOperation(List<Co_Op_Allocation__c> newAccrualList) { 
		try{ 
			CoOpAccrualHelper.processHFLOFClaims(newAccrualList);
			
		}
		catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.CoopAccrualHandler,PRMGlobalConstants.afterInsertOperation);}
	}
	
	/**********************************************************************************************************************
* author: Accenture
* Date: May-2018
* Param: List<Co_Op_Allocation__c> AccrualList, Map<Id,Co_Op_Allocation__c> accrualOldMap
* Return: void
* Description: Method for After Accrual update
* High Level Process : 
**********************************************************************************************************************/	 
	public static void afterUpdateOperation(List<Co_Op_Allocation__c> newAccrualList,Map<Id,Co_Op_Allocation__c> accrualOldMap) { 
		try{	
		
	  CoOpAccrualHelper.afterUpdateCoopAllocationHelperMethod(newAccrualList,accrualOldMap);
			system.debug('after update');
			List<Co_Op_Allocation__c> balanceUpdated = new List<Co_Op_Allocation__c>();								   
			
			for(Co_Op_Allocation__c Accrual : newAccrualList){				
			   if(((accrualOldMap.get(Accrual.id).Co_Op_Allocation_Amount__c != Accrual.Co_Op_Allocation_Amount__c) && Accrual.Co_Op_Allocation_Amount__c != 0) || 
				   ((accrualOldMap.get(Accrual.id).Transfers_in_Amount__c != Accrual.Transfers_in_Amount__c) && Accrual.Transfers_in_Amount__c != 0)  ) 
				{
					balanceUpdated.add(Accrual);
				}
			}
			if(!balanceUpdated.IsEmpty()){
				CoOpAccrualHelper.processHFLOFClaims(balanceUpdated);
			}
			
			//req4940 added task for email notifications
			//CoOpAccrualHelper.sendEmailForExpiredAllocation(newAccrualList);
			
			//createNewTask..
			List<Co_Op_Allocation__c> allocationTaskCreation = new List<Co_Op_Allocation__c>();
			for(Co_Op_Allocation__c Accrual : newAccrualList){
				if((accrualOldMap.get(Accrual.id).Days_to_expire__c != Accrual.Days_to_expire__c))
				{
					allocationTaskCreation.add(Accrual);
				}
			}
			if(!allocationTaskCreation.IsEmpty()){
				CoOpAccrualHelper.createNewTask(newAccrualList);
			}   
			List<Co_Op_Allocation__c> balanceuploaded = new List<Co_Op_Allocation__c>();
			for(Co_Op_Allocation__c Accrual : newAccrualList){
				if((accrualOldMap.get(Accrual.id).Co_Op_Allocation_Amount__c != Accrual.Co_Op_Allocation_Amount__c) && 
				   (accrualOldMap.get(Accrual.id).Co_Op_Allocation_Amount__c == 0))
				{
					balanceuploaded.add(Accrual); 
				}
			}
			if(!balanceuploaded.IsEmpty()){
				//CoOpAccrualHelper.sendEmailForAlloactionupdate(newAccrualList);
			}
			List<Co_Op_Allocation__c> allocationrelatedtoclaim = new List<Co_Op_Allocation__c>();
			for(Co_Op_Allocation__c Accrual : newAccrualList){
				if((accrualOldMap.get(Accrual.id).Days_to_expire__c != Accrual.Days_to_expire__c) && 
				   (Accrual.Days_to_expire__c.equals(PRMGlobalConstants.Today)))
				{
					allocationrelatedtoclaim.add(Accrual); 
				}
				
			 }
			if(!allocationrelatedtoclaim.IsEmpty()){
				CoOpAccrualHelper.activeAllcOnSubmittedClaim(newAccrualList);
				
			}
			
		}
		catch(System.Exception e){ExceptionHandler.addException(e,PRMGlobalConstants.CoopAccrualHandler,PRMGlobalConstants.afterUpdateOperation);}
	}
}