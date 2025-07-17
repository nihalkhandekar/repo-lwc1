/* DESCRIPTION: This class to expose a rest api to Mulesoft for fetching Exclusion Consent Records    
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                             1-September-2021                     Created First Version
***************************************************************************************************/
@RestResource(urlMapping='/FetchConsentRecords')
global with sharing class SEP_FetchConsentService {
    public static String sRequest = '';
    public static String sResponse = '';
    public static final String sSeverity = 'Critical';
    /*
    * Description: 	    Method that defined what happens when GET request is recieved
    *                   Fetched the Consent records from the backend and returns response in from of a JSON.
    * Param 1: 			none
    * Return Type: 		none
    *
    */
    @HttpGet
    global static void fetchConsentRecords() {
        try{

            List<SEP_FetchConsentResponseWrapper.Consentwrapper> lstConsentWrapper = new List<SEP_FetchConsentResponseWrapper.Consentwrapper>();
            List<SEP_Exclusion_Consent__c> lstConsentObject = new List<SEP_Exclusion_Consent__c>();
            string query = 'SELECT Name,First_Name__c,Middle_Name__c,Last_Name__c,Date_Of_Birth__c,	Unique_Identifier_Number__c,Address__c,Unit_Apt__c,City__c,State__c,Zip_Code__c,Address_Not_Provided__c,Exclusion_Consent_Status__c,Exclusion_Status_Change_Date__c,(SELECT IsVerified__c,Email_Address__c,VerifiedEmail_Phone__c,IsPrimary__c FROM SEP_Contact_Details__r WHERE IsVerified__c = true) FROM SEP_Exclusion_Consent__c WHERE Exclusion_Consent_Status__c = \'Active\' OR Exclusion_Consent_Status__c = \'Removed\'';
            lstConsentObject = database.query(query); 
            for(SEP_Exclusion_Consent__c oConsentRecord : lstConsentObject){
                List<SEP_FetchConsentResponseWrapper.ContactDetailWrapper> lstcontactdetailsWrapper = new List<SEP_FetchConsentResponseWrapper.ContactDetailWrapper>();
                for(SEP_Contact_Detail__c oContactDetail : oConsentRecord.SEP_Contact_Details__r ){
                    if(oContactDetail.Email_Address__c == null || oContactDetail.Email_Address__c == ''){
                     SEP_FetchConsentResponseWrapper.ContactDetailWrapper oContactDetailWrapper = new SEP_FetchConsentResponseWrapper.ContactDetailWrapper('',oContactDetail.VerifiedEmail_Phone__c,String.valueOf(oContactDetail.IsPrimary__c));
                     lstcontactdetailsWrapper.add(oContactDetailWrapper);
                    }else{
                        SEP_FetchConsentResponseWrapper.ContactDetailWrapper oContactDetailWrapper = new SEP_FetchConsentResponseWrapper.ContactDetailWrapper(oContactDetail.VerifiedEmail_Phone__c,'',String.ValueOf(oContactDetail.IsPrimary__c));
                        lstcontactdetailsWrapper.add(oContactDetailWrapper);
                    }
                }
                SEP_FetchConsentResponseWrapper.Consentwrapper oWrapper = new SEP_FetchConsentResponseWrapper.Consentwrapper(oConsentRecord.Name,oConsentRecord.First_Name__c,oConsentRecord.Middle_Name__c,oConsentRecord.Last_Name__c,String.valueOf(oConsentRecord.Date_Of_Birth__c),oConsentRecord.Unique_Identifier_Number__c,oConsentRecord.Address__c,oConsentRecord.Unit_Apt__c,oConsentRecord.City__c,oConsentRecord.State__c,oConsentRecord.Zip_Code__c,String.valueOf(oConsentRecord.Address_Not_Provided__c),oConsentRecord.Exclusion_Consent_Status__c,String.valueOf(oConsentRecord.Exclusion_Status_Change_Date__c.date()),lstcontactdetailsWrapper);
                lstConsentWrapper.add(oWrapper);
                }
            sResponse = populateIntegrationError(null, 200,'Success', Json.serialize(lstConsentWrapper));
        }Catch(exception oException){
            SEP_Utility.SEPExceptionHandler('SEP_FetchConsentService','fetchConsentRecords','SEP_Exclusion_Consent__c',' ',sSeverity,oException,'');
            sResponse = populateIntegrationError(null, 400,'Failure',oException.getMessage());
        }
    }

    /*
    * Description: 	    Method that defined the response of the api
    * Param 1: 			Exception object,Integer status code,string message,string description
    * Return Type: 		String
    *
    */
    private static String populateIntegrationError(Exception oEx, Integer iStatusCode, String sMessage, String sDescription) {
    try{ 
        String sReturnedMssg;
        if(!Test.isRunningTest()){
        RestContext.response.statusCode = iStatusCode;    
        RestContext.response.addHeader('Content-Type', 'application/json');
        sReturnedMssg = String.isBlank(sMessage)?oEx.getMessage():sDescription;
        }
        String sJsonResponse = '{"ResponseMetadata": {"responseText": "'+  sMessage +'", "responseCode": "'+ iStatusCode +'", "responseDescriptionText": '+sReturnedMssg+' }}';
        RestContext.response.responseBody = blob.valueOf(sJsonResponse);
        return sJsonResponse;
        }catch(Exception objExe){
            SEP_Utility.SEPExceptionHandler('SEP_FetchConsentService','populateIntegrationError','',' ',sSeverity,objExe,'Error in response generation method');
            return 'Error response Creation';
        }
    }
}