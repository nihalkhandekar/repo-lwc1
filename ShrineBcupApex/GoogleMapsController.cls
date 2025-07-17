public with sharing class GoogleMapsController {
    private static final String API_KEY = 'YOUR_API_KEY_HERE';
    private static final String GEOCODE_ENDPOINT = 'https://maps.googleapis.com/maps/api/geocode/json';

    @AuraEnabled
    public static Map<String, Object> validateAddress(String address) {
        String encodedAddress = EncodingUtil.urlEncode(address, 'UTF-8');
        String url = GEOCODE_ENDPOINT + '?address=' + encodedAddress + '&key=' + API_KEY;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        Map<String, Object> result = new Map<String, Object>();

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> results = (List<Object>) responseBody.get('results');

            if (!results.isEmpty()) {
                Map<String, Object> firstResult = (Map<String, Object>) results[0];
                result.put('formattedAddress', (String) firstResult.get('formatted_address'));
                result.put('isValid', true);
            } else {
                result.put('isValid', false);
                result.put('error', 'Address not found');
            }
        } else {
            result.put('isValid', false);
            result.put('error', 'API request failed: ' + response.getStatus());
        }

        return result;
    }
}