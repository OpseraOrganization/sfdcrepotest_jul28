public without sharing class OfferTeamWrapper
{	
	@AuraEnabled
	public String userName { get; set;}
	@AuraEnabled
	public String userId { get; set; }
	@AuraEnabled
	public String teamRole { get; set; }  
	@AuraEnabled
	public String teamRoleLabel { get; set; } 
	@AuraEnabled
	public String additionalTeamRole { get; set; }
	@AuraEnabled
	public String offerAccess { get; set; }
	@AuraEnabled
	public boolean nsaCompliant { get; set; } 
	@AuraEnabled
	public String leadBG { get; set; }
	
	public String oppOwnerId { get; set; }
	public String oppOwnerName { get; set; } 
	public boolean oppOwnerNSA { get; set; } 
}