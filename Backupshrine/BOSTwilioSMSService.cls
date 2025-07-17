/*********************************************************************************************
 * NAME:  BOSTwilioSMSService
 * DESCRIPTION: Service class for twilio API. 
 *
 * @AUTHOR: 
 * @DATE: 09/16/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Pooja Dubey                   09/16/2020                       Created the first version
 *
*************************************************************************************************/
global without sharing class BOSTwilioSMSService { 
    
    public static final string CLASSNAME = 'BOSTwilioSMSService';
    public static final String methodName = 'sendSMS';
    public static final String userObject = 'User';
    public static final String severity = 'High';
    
    /********************************************************************************************
        METHOD NAME    : sendSMS
        DESCRIPTION    : calling the twilio API for sending SMS
        RETURN TYPE    : wrapperResult
        PARAMETER      : String,String
    ********************************************************************************************/
    public static WrapperResult sendSMS(String accountSID, String toPhNumber, String messageBody){
        WrapperResult result = new WrapperResult();
        try{            
            TwilioSF.TwilioApiClient api = new TwilioSF.TwilioApiClient();
            api.addUrlPart(Label.ACCOUNTS);
            api.addUrlPart(accountSID);
            api.addUrlPart(Label.JSON_MESSAGES);

            api.addParam(Label.TO,toPhNumber);
            api.addParam(Label.FROM,Label.SMS_Phone);   
            api.addParam(Label.BODY,messageBody);

            TwilioSF.TwilioApiClientResponse response = api.doPost();
            if(response.hasError()){
                result.smsStatus = 'failed';
                result.message = response.getErrorMessage();  
            }
        }
        catch(Exception ex){
            result.smsStatus = 'failed';
            result.message = ex.getMessage();
            BOS_Utility.ExceptionHandlerAsync(className, methodName,null,null,null,ex,ex.getMessage());
        }
        return result;
    }
    /********************************************************************************************
        Class NAME     : WrapperResult
        DESCRIPTION    : Result wrapper class.
    ********************************************************************************************/
    global without sharing class WrapperResult{
        global String message;
        global String smsStatus;
    }
}