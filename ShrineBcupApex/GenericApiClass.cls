/******************************************************************************************************************************************
 * NAME:  GenerateChecklist
 * DESCRIPTION: This class is used to to make get and post callouts
 *
 * @AUTHOR: Rohit
 * @DATE: 29/07/2020
 *
 *
 * MODIFICATION LOG
 * DEVELOPER                         DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------------------------
 * Rohit                     		29/07/2020                         Created the first version
 ***************************************************************************************************************************************************/
public with sharing class GenericApiClass {
            public Static void makeApiClass(TaskCompletedListner listner, String requestURL, String requestString, String requestType,Decimal timeout){
            
                Integer timeourValue = Integer.valueOf(timeout);
                if(requestType == 'GET'){
                    makeGetCall(listner,requestURL,requestType,timeourValue);
                }else if(requestType == 'POST'){
                    makePostCall(listner,requestURL,requestString,requestType,timeourValue);
                }
                
            }
            
        private static  void makeGetCall(TaskCompletedListner listner, String requestURL,String requestType,Integer timeout){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(requestURL);
            request.setTimeout(timeout);
            request.setMethod(requestType);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            sendResponse(response, listner);
        }
            
            
        private static  void makePostCall(TaskCompletedListner listner, String requestURL, String requestString,String requestType,Integer timeout){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestURL);
        request.setMethod(requestType);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(timeout);
        // Set the body as a JSON object
        request.setBody(requestString);
		HttpResponse response;
        if(!Test.isRunningTest()){
            response = http.send(request);
        }
        else{
            response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(system.label.mock_response);
        }
        // Parse the JSON response
        sendResponse(response, listner);
            }
        private  static void sendResponse(HttpResponse response,TaskCompletedListner listner){
            if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types. 
            String finalresponse =response.getBody();
            listner.onSuccess(finalresponse);
        }else{
            String finalresponse =response.getBody();
            listner.onError(finalresponse);
            } 
    }
    
    public static void makePostCallwithRequestHeader(TaskCompletedListner listner, String requestURL, String requestString,String requestType,Integer timeout, Map<string,string> requestHeadersMap){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestURL);
        request.setMethod(requestType);
        //request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(timeout);
        
        /** Set headers for the request **/
        for(string key : requestHeadersMap.keySet()){
            request.setHeader(key, requestHeadersMap.get(key));
            system.debug(key+', '+requestHeadersMap.get(key));
        }
        
        // Set the body as a JSON object
        request.setBody(requestString);
        system.debug(request.getBody());
        
        system.debug(request);
        HttpResponse response;
        if(!Test.isRunningTest()){
            response = http.send(request);
        }
        else{
            response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('["Translations":{"Translation":"test"}]');
        }
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types. 
            String finalresponse =response.getBody();
            system.debug(finalresponse);
        }else{
            String finalresponse =response.getBody();
            system.debug(finalresponse);
            
        } 
        // Parse the JSON response
        //sendResponse(response, listner);
    }
}