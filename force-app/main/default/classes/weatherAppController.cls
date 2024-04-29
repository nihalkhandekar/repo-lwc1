public with sharing class weatherAppController {

    @AuraEnabled
    public static string getWeatherDetails(String input){
    String url = 'https://api.openweathermap.org/data/2.5/weather?q=' + input + + '&units=metric' + getKey();
    String response = getResponse(url);
    return response;
    }

    public static  string getResponse(string strUrl){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setMethod('GET');
        req.setEndpoint(strUrl);
        req.setTimeout(120000);

        res = http.send(req);
        String responseBody = res.getBody();
        return responseBody; 
    }

    public static string getKey(){
        string key = '2334defe372c420b29577995b66e9fb7'; //we can also store this key in a custom label and use by ==>> System.label.weatherApiKey
        string output = '&appid=' + key; 
        return output;
    }   
 
}