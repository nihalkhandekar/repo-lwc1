@isTest
public class HttpResponseMock implements HttpCalloutMock {
    private String body;
    private Integer code;
    private String status;
    
    //For generic api class
    public HttpResponseMock(String body, Integer code, String status) {
        this.body = body;
        this.code = code;
        this.status = status;
    }
    
    public HTTPResponse respond(HTTPRequest request) {
 		HttpResponse res = new HttpResponse();
        
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        
        return res;       
    }
}