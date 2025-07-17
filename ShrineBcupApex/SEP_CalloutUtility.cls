/**
* SEP Callout Utility class. This class is used to make callout to external system based on business use case
*
* @author Ankit Singh
* @date 8/9/2021
*/
public class SEP_CalloutUtility {

    public static final String sSeverity = 'Critical';
    /*
    * Description: 		Used to create the callout request and calls the method based on request and return response
    * Param 1: 			String requestbody
    * Param 2:          String UseCase of api
    * Param 3:          String url params
    * Return Type: 		returns HttpResponse
    *
    */

    public static HttpResponse invokeCall(String requestBody, String useCaseName, String urlParam) {
    try{
        HttpResponse response = new HttpResponse();
        SEP_Integration_Environment__c environmentCS = SEP_Integration_Environment__c.getValues('Environment');
        SEP_API_Integration_Configuration__mdt integrationEndpoint = [SELECT DeveloperName, MasterLabel, Status__c, Org_Environment__c, Logging_Required__c, Interface_Number__c, Header_JSON__c, Endpoint__c, Http_Method__c, Custom_Timeout__c FROM SEP_API_Integration_Configuration__mdt WHERE MasterLabel = :useCaseName AND Org_Environment__c = :environmentCS.Integration_Endpoint_Environment__c LIMIT 1];
        
            if(integrationEndpoint != null && !String.isEmpty(integrationEndpoint.Http_Method__c)) {
                if(integrationEndpoint.Http_Method__c == 'POST'){
                    response = makePostCall(requestBody, integrationEndpoint);
                } else if(integrationEndpoint.Http_Method__c == 'PUT') {
                    response = makePutCall(requestBody, integrationEndpoint, urlParam);
                }
            }
            return response;
        }catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_CalloutUtility','invokeCall','',' ',sSeverity,objExp,'');
            return null;
        }
    }
    
    /*
    * Description: 		Used to make the PostCallout
    * Param 1: 			String requestbody
    * Param 2:          SEP_API_Integration_Configuration__mdt metadata record
    * Return Type: 		returns HTTPResponse
    *
    */

    public static HTTPResponse makePostCall(String requestBody, SEP_API_Integration_Configuration__mdt integrationEndpoint){
    try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        request.setEndpoint(integrationEndpoint.Endpoint__c);
        request.setMethod(integrationEndpoint.Http_Method__c);
        request.setBody(requestBody);

        if(integrationEndpoint.Custom_Timeout__c != null){
            request.setTimeout(Integer.valueOf(integrationEndpoint.Custom_Timeout__c));
            //request.setTimeout(1);
        }
        
        String header = integrationEndpoint.Header_JSON__c;
        Map<String, String> mapOfHeaders = (Map<String, String>) JSON.deserialize(header, Map<String, String>.Class);
        if(!mapOfHeaders.isEmpty()){
            for(String key : mapOfHeaders.keySet()){
                request.setHeader(key, mapOfHeaders.get(key));
            }
        }
        response = http.send(request);
        return response;
        }catch(Exception objExp){
            SEP_Utility.SEPExceptionHandler('SEP_CalloutUtility','makePostCall','',' ',sSeverity,objExp,'');
            return null;
        }
    }

    /*
    * Description: 		Used to make the PutCallout
    * Param 1: 			String requestbody
    * Param 2:          SEP_API_Integration_Configuration__mdt metadata record
    * Param 3:          String URL param
    * Return Type: 		returns HTTPResponse
    *
    */

    public static HTTPResponse makePutCall(String requestBody, SEP_API_Integration_Configuration__mdt integrationEndpoint, String urlParam){
    try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();

            request.setEndpoint(integrationEndpoint.Endpoint__c + '/' + urlParam);
            request.setMethod(integrationEndpoint.Http_Method__c);
            request.setBody(requestBody);

            if(integrationEndpoint.Custom_Timeout__c != null){
                request.setTimeout(Integer.valueOf(integrationEndpoint.Custom_Timeout__c));
            }
            
            String header = integrationEndpoint.Header_JSON__c;
            Map<String, String> mapOfHeaders = (Map<String, String>) JSON.deserialize(header, Map<String, String>.Class);
            if(!mapOfHeaders.isEmpty()){
                for(String key : mapOfHeaders.keySet()){
                    request.setHeader(key, mapOfHeaders.get(key));
                }
            }
            response = http.send(request);
            return response;
        }catch(Exception objExp){
        SEP_Utility.SEPExceptionHandler('SEP_CalloutUtility','makePutCall','',' ',sSeverity,objExp,'');
        return null;
    }
    }
}