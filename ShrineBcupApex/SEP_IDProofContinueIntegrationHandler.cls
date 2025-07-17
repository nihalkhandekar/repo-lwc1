/* DESCRIPTION:  Integration handler class for IDproofing Continuation Request   
*
* @AUTHOR: 	Vinay Mahadevaiah
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Vinay Mahadevaiah                    9-September-2021                    Created First Version
***************************************************************************************************/
public class SEP_IDProofContinueIntegrationHandler {

    public static final String sSeverity = 'Critical';
    /*
    * Description: 		Calls the continuation API and return the response to the caller class
    * Param 1: 			SEP_RequestWrapperIdProofingPut request object. 
    * Param 2:          String conversationid from initial response. 
    * Return Type: 		Returns SEP_ResponseWrapperIdproofingPut object
    *
    */
    public static SEP_ResponseWrapperIdproofingPut idProofingContinuation(SEP_RequestWrapperIdProofingPut objContinuationRequestWrapper, String conversationId) {
        SEP_ResponseWrapperIdproofingPut objContinuationResponseWrapper = new SEP_ResponseWrapperIdproofingPut();
        SEP_Integration_Environment__c objEnvironmentCS = new SEP_Integration_Environment__c();
        objEnvironmentCS = SEP_Integration_Environment__c.getValues('Environment');
        String sEnvironmet = objEnvironmentCS.Integration_Endpoint_Environment__c;
        SEP_API_Integration_Configuration__mdt mdtIntegrationEndpoint = new SEP_API_Integration_Configuration__mdt();
        
        try{
            mdtIntegrationEndpoint = [SELECT DeveloperName, MasterLabel, Status__c, API_Type__c, Org_Environment__c, Logging_Required__c, Interface_Number__c, Header_JSON__c, Endpoint__c, Http_Method__c, Custom_Timeout__c FROM SEP_API_Integration_Configuration__mdt WHERE API_Type__c = 'Continuation' AND Org_Environment__c = :sEnvironmet LIMIT 1]; 
        } catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_IDProofInitiateIntegrationHandler','idProofingInitiation','SEP_API_Integration_Configuration__mdt',' ',sSeverity,objExp,'');
        }

        String sRequestJSON = '';
        String sResponseBody = '';
        String sResponseStatusCode = '';
        try {
            sRequestJSON = JSON.serialize(objContinuationRequestWrapper);

            if(mdtIntegrationEndpoint.Status__c == 'Active') {
                HTTPResponse objResponse = SEP_CalloutUtility.invokeCall(sRequestJSON, mdtIntegrationEndpoint.MasterLabel, conversationId);
                sResponseBody = objResponse.getBody();
                sResponseStatusCode = String.valueOf(objResponse.getStatusCode());
                if(sResponseStatusCode == '503' || sResponseStatusCode == '502'){
                    SEP_ResponseWrapperIdproofingPut.TransactionReasonCode objCode = new SEP_ResponseWrapperIdproofingPut.TransactionReasonCode('Mulesoft Down');
                    SEP_ResponseWrapperIdproofingPut.Status objstatus= new SEP_ResponseWrapperIdproofingPut.Status('','','failed',objCode,'','','');
                    SEP_ResponseWrapperIdproofingPut objRes = new SEP_ResponseWrapperIdproofingPut(objstatus);
                    SEP_Utility.SEPExceptionHandler('SEP_IDProofContinueIntegrationHandler','idProofingContinuation','Integration Log',' ',sSeverity,null,''+sResponseBody);
                    return objRes;
                }
                if(String.isNotBlank(sResponseBody)) {
                    objContinuationResponseWrapper = (SEP_ResponseWrapperIdproofingPut) JSON.deserialize(sResponseBody, SEP_ResponseWrapperIdproofingPut.class);
                }
                //Log integration
                SEP_Utility.SEPExceptionHandler('SEP_IDProofContinueIntegrationHandler','idProofingContinuation','Integration Log',' ',sSeverity,null,''+objContinuationResponseWrapper);

            } else {
                SEP_Utility.SEPExceptionHandler('SEP_IDProofContinueIntegrationHandler','idProofingContinuation','',' ',sSeverity,null,'Endpoint not active');
            }
        } catch (Exception objExp) {
            //Log exception
            SEP_Utility.SEPExceptionHandler('SEP_IDProofContinueIntegrationHandler','idProofingContinuation','',' ',sSeverity,objExp,'');

        }

        return objContinuationResponseWrapper;
    }
}