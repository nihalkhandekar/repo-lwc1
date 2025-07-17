@isTest(SeeAllData=false)
private class GoogleMapsControllerTest {

    // Mock class to simulate HttpResponse
    private class GoogleMapsHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            
            // Check for specific endpoint to ensure proper URL in the test
            String url = request.getEndpoint();
            
            // Simulate successful response with a valid address
            if (url.contains('address=valid%20address')) {
                response.setStatusCode(200);
                response.setBody('{"results":[{"formatted_address":"123 Valid Address, City, Country"}]}');
            }
            // Simulate API failure
            else if (url.contains('address=invalid%20address')) {
                response.setStatusCode(200);
                response.setBody('{"results":[] }'); // No results, invalid address
            }
            // Simulate generic failure response from Google API
            else {
                response.setStatusCode(500);
                response.setBody('{"error_message":"API request failed"}');
            }

            return response;
        }
    }

    // Test for a valid address
    @isTest
    static void testValidateAddressSuccess() {
        Test.setMock(HttpCalloutMock.class, new GoogleMapsHttpMock());

        // Simulate calling the method with a valid address
        Map<String, Object> result = GoogleMapsController.validateAddress('valid address');

        // Assert that the address is valid
        System.assertEquals(true, result.get('isValid'));
        System.assertEquals('123 Valid Address, City, Country', result.get('formattedAddress'));
    }

    // Test for an invalid address (address not found)
    @isTest
    static void testValidateAddressNotFound() {
        Test.setMock(HttpCalloutMock.class, new GoogleMapsHttpMock());

        // Simulate calling the method with an invalid address
        Map<String, Object> result = GoogleMapsController.validateAddress('invalid address');

        // Assert that the address is not valid
        System.assertEquals(false, result.get('isValid'));
        System.assertEquals('Address not found', result.get('error'));
    }

    // Test for API failure
    @isTest
    static void testValidateAddressApiFailure() {
        Test.setMock(HttpCalloutMock.class, new GoogleMapsHttpMock());

        // Simulate calling the method with an unhandled URL (generic API failure)
        Map<String, Object> result = GoogleMapsController.validateAddress('api failure address');

        // Assert that the address is not valid
        System.assertEquals(false, result.get('isValid'));
        System.assertEquals('API request failed: 500', result.get('error'));
    }
}