@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
   
    global HTTPResponse respond(HTTPRequest req) {      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ErrorString":"ErrorString" , "ResultCode":"200", "results":[address1 : {"text": "Ford", "AddressLine1":"AddressLine1":"PostalCode":"50032","street_line":"street_line","city":"CTcity"}, address2 :{"text": "Ford", "AddressLine1":"AddressLine1":"PostalCode":"50032","street_line":"street_line","city":"CTcity"}]}');
        res.setStatusCode(200);
        return res;
    }
}