@IsTest
private class SAP_Apo_AuthorizationNetControllerTest {

    @IsTest
    static void testGeneratePaymentToken() {
        // Set Mock for HTTP Callout
        Test.setMock(HttpCalloutMock.class, new MockAuthorizationNetHttpResponse());

        String fakePaymentGatewayData = '{"amount":"100.00","email":"test@example.com","firstName":"John","lastName":"Doe","address":"123 Test St","city":"Test City","state":"CA","zip":"12345","country":"USA"}';

        Test.startTest();
        String result = SAP_Apostille_AuthorizationNetController.generatePaymentToken(fakePaymentGatewayData);
        Test.stopTest();
        
        
       System.assertNotEquals(null, result, 'Result should not be null.');
       System.assertNotEquals('', result, 'Result should not be empty.');
       System.assertEquals('test-payment-token', result, 'Returned token should match the mocked response.');

        
    }

    // Inner Mock Class for HTTP Response (Should be PRIVATE, not global)
    private class MockAuthorizationNetHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"token": "test-payment-token"}'); // Mocked Token Response
            return res;
        }
    }
}