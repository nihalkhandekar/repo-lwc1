public class SalesforceConnect {
public static String getCasesFromSF1(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://sakshiservicespvtltd-dev-ed.my.salesforce.com/services/apexrest/Cases');
        request.setMethod('GET');
    	request.setHeader('Authorization', 'Bearer !ARgAQJD0LZEnsy7EvPDEGlRuXyXk3r5Z0j68xy_jEABf7gicpIPVX0iegFN5coikbilZGxMVd60pkSUQanGejDX2dYrk1q4T');
        
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            system.debug(response.getBody());
            return response.getBody();
        }
        return '';
    }
}