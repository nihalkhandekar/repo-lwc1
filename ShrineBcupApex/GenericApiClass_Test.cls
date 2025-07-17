@isTest 
private class GenericApiClass_Test {
    private class TestListner implements TaskCompletedListner {
        public void onSuccess(String result) { }
        
        public void onError(String message) { }
    }
    
    @isTest
    private static void testMakeApiClassGET() {
        HttpResponseMock mock = new HttpResponseMock('SomeBody', 200, 'OK');
    	Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	GenericApiClass.makeApiClass(new TestListner(), '/requestUrl', 'requestString', 'GET', 120);
        Test.stopTest();
    }
    
    @isTest
    private static void testMakeApiClassGETError() {
        HttpResponseMock mock = new HttpResponseMock('SomeBody', 400, 'Error');
    	Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	GenericApiClass.makeApiClass(new TestListner(), '/requestUrl', 'requestString', 'GET', 120);
        Test.stopTest();
    }
    
    @isTest
    private static void testMakeApiClassPOST() {
        HttpResponseMock mock = new HttpResponseMock('SomeBody', 200, 'OK');
    	Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	GenericApiClass.makeApiClass(new TestListner(), '/requestUrl', 'requestString', 'POST', 120);
        Test.stopTest();
    }
    
    @isTest
    private static void testMakePostCallwithRequestHeader() {
        Map<String, String> requestHeadersMap = new Map<String, String>();
        requestHeadersMap.put('Content-type', 'text/plain');
        
        HttpResponseMock mock = new HttpResponseMock('SomeBody', 200, 'OK');
    	Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	GenericApiClass.makePostCallwithRequestHeader(new TestListner(), 'requestURL', 'requestString', 'POST', 120, requestHeadersMap);
        Test.stopTest();
    }
}