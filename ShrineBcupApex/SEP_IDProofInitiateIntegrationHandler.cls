/* DESCRIPTION:  Integration handler class for IDproofing Initiate request   
*
* @AUTHOR: 	Vinay Mahadevaiah
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Vinay Mahadevaiah                    9-September-2021                    Created First Version
***************************************************************************************************/
public class SEP_IDProofInitiateIntegrationHandler {
    public static final String sSeverity = 'Critical';
    /*
    * Description: 		Calls the initiation API and return the response to the caller class
    * Param 1: 			SEP_RequestWrapperIdProofingPost request object 
    * Return Type: 		Returns SEP_ResponseWrapperIdProofingPost object
    *
    */
    public static SEP_ResponseWrapperIdProofingPost idProofingInitiation(SEP_RequestWrapperIdProofingPost objInitiateRequestWrapper) {
        //String sRequestName =  objInitiateRequestWrapper.Persons[0].Name;
        SEP_ResponseWrapperIdProofingPost objInitiateResponseWrapper = new SEP_ResponseWrapperIdProofingPost();
        SEP_Integration_Environment__c objEnvironmentCS = new SEP_Integration_Environment__c();
        objEnvironmentCS = SEP_Integration_Environment__c.getValues('Environment');
        String sEnvironmet = objEnvironmentCS.Integration_Endpoint_Environment__c;
        SEP_API_Integration_Configuration__mdt mdtIntegrationEndpoint = new SEP_API_Integration_Configuration__mdt();
        try{
            mdtIntegrationEndpoint = [SELECT DeveloperName, MasterLabel, Status__c, API_Type__c, Org_Environment__c, Logging_Required__c, Interface_Number__c, Header_JSON__c, Endpoint__c, Http_Method__c, Custom_Timeout__c FROM SEP_API_Integration_Configuration__mdt WHERE API_Type__c = 'Initiation' AND Org_Environment__c =: sEnvironmet LIMIT 1];
        } catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_IDProofInitiateIntegrationHandler','idProofingInitiation','SEP_API_Integration_Configuration__mdt',' ',sSeverity,objExp,'');
        }

        String sRequestJSON = '';
        String sResponseBody = '';
        String sResponseStatusCode = '';
        try{
           
           
            sRequestJSON = JSON.serialize(objInitiateRequestWrapper);
            
            sRequestJSON = sRequestJSON.replace('PNumber','Number');
            sRequestJSON = sRequestJSON.replace('SSNumber','Number');

            if(mdtIntegrationEndpoint.Status__c == 'Active') {
                HTTPResponse objResponse = SEP_CalloutUtility.invokeCall(sRequestJSON, mdtIntegrationEndpoint.MasterLabel, null);
                sResponseBody = objResponse.getBody();
                sResponseStatusCode = String.valueOf(objResponse.getStatusCode());
                if(sResponseStatusCode == '503' || sResponseStatusCode == '502'){
                    SEP_ResponseWrapperIdProofingPost.TransactionReasonCode objCode = new SEP_ResponseWrapperIdProofingPost.TransactionReasonCode('Mulesoft Down');
                    SEP_ResponseWrapperIdProofingPost.Status objstatus= new SEP_ResponseWrapperIdProofingPost.Status('','','failed',objCode,'','','');
                    SEP_ResponseWrapperIdProofingPost objRes = new SEP_ResponseWrapperIdProofingPost(objstatus);
                    SEP_Utility.SEPExceptionHandler('SEP_IDProofInitiateIntegrationHandler','idProofingInitiation','Integration Log',' ',sSeverity,null,''+sResponseBody);

                    return objRes;
                }
                if(String.isNotBlank(sResponseBody)) {
                    objInitiateResponseWrapper = (SEP_ResponseWrapperIdProofingPost) JSON.deserialize(sResponseBody, SEP_ResponseWrapperIdProofingPost.class);
                }
                //Log integration
                SEP_Utility.SEPExceptionHandler('SEP_IDProofInitiateIntegrationHandler','idProofingInitiation','Integration Log',' ',sSeverity,null,''+objInitiateResponseWrapper);
            } else {
            SEP_Utility.SEPExceptionHandler('SEP_IDProofInitiateIntegrationHandler','idProofingInitiation','',' ',sSeverity,null,'Endpoint not active');
            }
        } catch (Exception objExp) {
            //Log exception
            SEP_Utility.SEPExceptionHandler('SEP_IDProofInitiateIntegrationHandler','idProofingInitiation','',' ',sSeverity,objExp,'');

        }

        return objInitiateResponseWrapper;
    }
}