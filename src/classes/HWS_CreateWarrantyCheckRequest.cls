Public Class HWS_CreateWarrantyCheckRequest
{
	Public String createSRRequest(HWS_CheckWarranty_SVC.FlowInput objInput)
	 {
		String jsonPayload = JSON.serialize(objInput,true);
		return jsonPayload;
	}
}